Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 33AF66B0055
	for <linux-mm@kvack.org>; Tue, 19 May 2009 03:16:07 -0400 (EDT)
Date: Tue, 19 May 2009 15:15:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090519071554.GA26646@localhost>
References: <alpine.DEB.1.10.0905181045340.20244@qirst.com> <20090519032759.GA7608@localhost> <20090519133422.4ECC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090519133422.4ECC.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 19, 2009 at 12:41:38PM +0800, KOSAKI Motohiro wrote:
> Hi
> 
> Thanks for great works.
> 
> 
> > SUMMARY
> > =======
> > The patch decreases the number of major faults from 50 to 3 during 10% cache hot reads.
> > 
> > 
> > SCENARIO
> > ========
> > The test scenario is to do 100000 pread(size=110 pages, offset=(i*100) pages),
> > where 10% of the pages will be activated:
> > 
> >         for i in `seq 0 100 10000000`; do echo $i 110;  done > pattern-hot-10
> >         iotrace.rb --load pattern-hot-10 --play /b/sparse
> 
> 
> Which can I download iotrace.rb?
> 
> 
> > and monitor /proc/vmstat during the time. The test box has 2G memory.
> > 
> > 
> > ANALYZES
> > ========
> > 
> > I carried out two runs on fresh booted console mode 2.6.29 with the VM_EXEC
> > patch, and fetched the vmstat numbers on
> > 
> > (1) begin:   shortly after the big read IO starts;
> > (2) end:     just before the big read IO stops;
> > (3) restore: the big read IO stops and the zsh working set restored
> > 
> >         nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
> > begin:       2481             2237             8694              630                0           574299
> > end:          275           231976           233914              633           776271         20933042
> > restore:      370           232154           234524              691           777183         20958453
> > 
> > begin:       2434             2237             8493              629                0           574195
> > end:          284           231970           233536              632           771918         20896129
> > restore:      399           232218           234789              690           774526         20957909
> > 
> > and another run on 2.6.30-rc4-mm with the VM_EXEC logic disabled:
> 
> I don't think it is proper comparision.
> you need either following comparision. otherwise we insert many guess into the analysis.
> 
>  - 2.6.29 with and without VM_EXEC patch
>  - 2.6.30-rc4-mm with and without VM_EXEC patch
> 
> 
> > 
> > begin:       2479             2344             9659              210                0           579643
> > end:          284           232010           234142              260           772776         20917184
> > restore:      379           232159           234371              301           774888         20967849
> > 
> > The numbers show that
> > 
> > - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
> >   I'd attribute that improvement to the mmap readahead improvements :-)
> > 
> > - The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
> >   That's a huge improvement - which means with the VM_EXEC protection logic,
> >   active mmap pages is pretty safe even under partially cache hot streaming IO.
> > 
> > - when active:inactive file lru size reaches 1:1, their scan rates is 1:20.8
> >   under 10% cache hot IO. (computed with formula Dpgdeactivate:Dpgfree)
> >   That roughly means the active mmap pages get 20.8 more chances to get
> >   re-referenced to stay in memory.
> > 
> > - The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
> >   dropped pages are mostly inactive ones. The patch has almost no impact in
> >   this aspect, that means it won't unnecessarily increase memory pressure.
> >   (In contrast, your 20% mmap protection ratio will keep them all, and
> >   therefore eliminate the extra 41 major faults to restore working set
> >   of zsh etc.)

More results on X desktop, kernel 2.6.30-rc4-mm:

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree

VM_EXEC protection ON:
begin:       9740             8920            64075              561                0           678360
end:          768           218254           220029              565           798953         21057006
restore:      857           218543           220987              606           799462         21075710
restore X:   2414           218560           225344              797           799462         21080795

VM_EXEC protection OFF:
begin:       9368             5035            26389              554                0           633391
end:          770           218449           221230              661           646472         17832500
restore:     1113           218466           220978              710           649881         17905235
restore X:   2687           218650           225484              947           802700         21083584

The added "restore X" means after IO, switch back and forth between the urxvt
and firefox windows to restore their working set. I cannot explain why the
absolute nr_mapped grows larger at the end of VM_EXEC OFF case. Maybe it's
because urxvt is the foreground window during the first run, and firefox is the
foreground window during the second run?

Like the console mode, the absolute nr_mapped drops considerably - to 1/13 of
the original size - during the streaming IO.

The delta of pgmajfault is 3 vs 107 during IO, or 236 vs 393 during the whole
process.


RAW DATA
--------
status before tests:

wfg@hp ~% ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.8  0.0  10316   792 ?        Ss   14:38   0:02 init [2]
root         2  0.0  0.0      0     0 ?        S<   14:38   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        S<   14:38   0:00 [migration/0]
root         4  0.0  0.0      0     0 ?        S<   14:38   0:00 [ksoftirqd/0]
root         5  0.0  0.0      0     0 ?        S<   14:38   0:00 [watchdog/0]
root         6  0.0  0.0      0     0 ?        S<   14:38   0:00 [migration/1]
root         7  0.0  0.0      0     0 ?        S<   14:38   0:00 [ksoftirqd/1]
root         8  0.0  0.0      0     0 ?        S<   14:38   0:00 [watchdog/1]
root         9  0.0  0.0      0     0 ?        S<   14:38   0:00 [events/0]
root        10  0.0  0.0      0     0 ?        S<   14:38   0:00 [events/1]
root        11  0.0  0.0      0     0 ?        S<   14:38   0:00 [khelper]
root        16  0.0  0.0      0     0 ?        S<   14:38   0:00 [async/mgr]
root       160  0.0  0.0      0     0 ?        S<   14:38   0:00 [kintegrityd/0]
root       161  0.0  0.0      0     0 ?        S<   14:38   0:00 [kintegrityd/1]
root       163  0.0  0.0      0     0 ?        S<   14:38   0:00 [kblockd/0]
root       164  0.0  0.0      0     0 ?        S<   14:38   0:00 [kblockd/1]
root       165  0.0  0.0      0     0 ?        S<   14:38   0:00 [kacpid]
root       166  0.0  0.0      0     0 ?        S<   14:38   0:00 [kacpi_notify]
root       274  0.0  0.0      0     0 ?        S<   14:38   0:00 [ata/0]
root       275  0.0  0.0      0     0 ?        S<   14:38   0:00 [ata/1]
root       276  0.0  0.0      0     0 ?        S<   14:38   0:00 [ata_aux]
root       280  0.0  0.0      0     0 ?        S<   14:38   0:00 [ksuspend_usbd]
root       284  0.0  0.0      0     0 ?        S<   14:38   0:00 [khubd]
root       287  0.0  0.0      0     0 ?        S<   14:38   0:00 [kseriod]
root       329  0.0  0.0      0     0 ?        S<   14:38   0:00 [kondemand/0]
root       330  0.0  0.0      0     0 ?        S<   14:38   0:00 [kondemand/1]
root       365  0.0  0.0      0     0 ?        S<   14:38   0:00 [rt-test-0]
root       367  0.0  0.0      0     0 ?        S<   14:38   0:00 [rt-test-1]
root       369  0.0  0.0      0     0 ?        S<   14:38   0:00 [rt-test-2]
root       371  0.0  0.0      0     0 ?        S<   14:38   0:00 [rt-test-3]
root       373  0.0  0.0      0     0 ?        S<   14:38   0:00 [rt-test-4]
root       375  0.0  0.0      0     0 ?        S<   14:38   0:00 [rt-test-5]
root       377  0.0  0.0      0     0 ?        S<   14:38   0:00 [rt-test-6]
root       379  0.0  0.0      0     0 ?        S<   14:38   0:00 [rt-test-7]
root       382  0.0  0.0      0     0 ?        S    14:38   0:00 [khungtaskd]
root       383  0.0  0.0      0     0 ?        S    14:38   0:00 [pdflush]
root       384  0.0  0.0      0     0 ?        S    14:38   0:00 [pdflush]
root       385  0.0  0.0      0     0 ?        S<   14:38   0:00 [kswapd0]
root       386  0.0  0.0      0     0 ?        S<   14:38   0:00 [aio/0]
root       387  0.0  0.0      0     0 ?        S<   14:38   0:00 [aio/1]
root       388  0.0  0.0      0     0 ?        S<   14:38   0:00 [nfsiod]
root       390  0.0  0.0      0     0 ?        S<   14:38   0:00 [crypto/0]
root       391  0.0  0.0      0     0 ?        S<   14:38   0:00 [crypto/1]
root      1118  0.0  0.0      0     0 ?        S<   14:38   0:00 [iscsi_eh]
root      1122  0.0  0.0      0     0 ?        S<   14:38   0:00 [scsi_eh_0]
root      1125  0.0  0.0      0     0 ?        S<   14:38   0:00 [scsi_eh_1]
root      1128  0.0  0.0      0     0 ?        S<   14:38   0:00 [scsi_eh_2]
root      1136  0.0  0.0      0     0 ?        S<   14:38   0:00 [scsi_eh_3]
root      1139  0.0  0.0      0     0 ?        S<   14:38   0:00 [scsi_eh_4]
root      1276  0.0  0.0      0     0 ?        S<   14:38   0:00 [kpsmoused]
root      1301  0.0  0.0      0     0 ?        S<   14:38   0:00 [usbhid_resumer]
root      1312  0.0  0.0      0     0 ?        S<   14:38   0:00 [rpciod/0]
root      1313  0.0  0.0      0     0 ?        S<   14:38   0:00 [rpciod/1]
root      1488  0.0  0.0      0     0 ?        S<   14:38   0:00 [iwlagn]
root      1490  0.0  0.0      0     0 ?        S<   14:38   0:00 [phy0]
root      1524  0.0  0.0      0     0 ?        S<   14:38   0:00 [hd-audio0]
root      1577  0.0  0.0      0     0 ?        S<   14:38   0:00 [kjournald2]
root      1578  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-worker-0]
root      1579  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-submit-0]
root      1580  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-delalloc-]
root      1581  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-fixup-0]
root      1582  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-0]
root      1583  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-2]
root      1584  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-4]
root      1585  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-6]
root      1586  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-met]
root      1587  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-met]
root      1588  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-met]
root      1589  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-met]
root      1590  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-met]
root      1591  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-met]
root      1592  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-met]
root      1593  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-met]
root      1594  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-wri]
root      1595  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-wri]
root      1596  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-wri]
root      1597  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-endio-wri]
root      1598  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-cleaner]
root      1599  0.0  0.0      0     0 ?        S<   14:38   0:00 [btrfs-transacti]
daemon    1658  0.0  0.0   8024   528 ?        Ss   14:38   0:00 /sbin/portmap
root      1670  0.0  0.0  10136   792 ?        Ss   14:38   0:00 /sbin/rpc.statd
root      1679  0.0  0.0  26952   660 ?        Ss   14:38   0:00 /usr/sbin/rpc.idmapd
root      1789  0.0  0.0   3800   648 ?        Ss   14:39   0:00 /usr/sbin/acpid
104       1799  0.0  0.0  21084   996 ?        Ss   14:40   0:00 /usr/bin/dbus-daemon --system
root      1811  0.0  0.0  48872  1208 ?        Ss   14:40   0:00 /usr/sbin/sshd
root      1844  0.0  0.0      0     0 ?        S<   14:40   0:00 [lockd]
root      1845  0.0  0.0      0     0 ?        S<   14:40   0:00 [nfsd]
root      1846  0.0  0.0      0     0 ?        S<   14:40   0:00 [nfsd]
root      1847  0.0  0.0      0     0 ?        S<   14:40   0:00 [nfsd]
root      1848  0.0  0.0      0     0 ?        S<   14:40   0:00 [nfsd]
root      1849  0.0  0.0      0     0 ?        S<   14:40   0:00 [nfsd]
root      1850  0.0  0.0      0     0 ?        S<   14:40   0:00 [nfsd]
root      1851  0.0  0.0      0     0 ?        S<   14:40   0:00 [nfsd]
root      1852  0.0  0.0      0     0 ?        S<   14:40   0:00 [nfsd]
root      1856  0.0  0.0  14464   420 ?        Ss   14:40   0:00 /usr/sbin/rpc.mountd --manage-gids
106       1867  0.2  0.2  29280  4164 ?        Ss   14:40   0:00 /usr/sbin/hald
root      1868  0.0  0.0  17812  1172 ?        S    14:40   0:00 hald-runner
root      1891  0.0  0.0  19936  1132 ?        S    14:40   0:00 /usr/lib/hal/hald-addon-cpufreq
106       1892  0.0  0.0  16608   988 ?        S    14:40   0:00 hald-addon-acpi: listening on acpid socket /var/run/acpid.socket
pulse     1902  0.0  0.1 102024  2664 ?        S<s  14:40   0:00 /usr/bin/pulseaudio --system --daemonize --high-priority --log-targe
pulse     1903  0.0  0.1  56024  2768 ?        S    14:40   0:00 /usr/lib/pulseaudio/pulse/gconf-helper
pulse     1905  0.0  0.1  37356  2700 ?        S    14:40   0:00 /usr/lib/libgconf2-4/gconfd-2 4
root      1932  0.0  0.0  45636  1268 tty1     Ss   14:40   0:00 /bin/login --
root      1933  0.0  0.0   3800   584 tty2     Ss+  14:40   0:00 /sbin/getty 38400 tty2
root      1934  0.0  0.0   3800   584 tty3     Ss+  14:40   0:00 /sbin/getty 38400 tty3
root      1935  0.0  0.0   3800   588 tty4     Ss+  14:40   0:00 /sbin/getty 38400 tty4
root      1936  0.0  0.0   3800   588 tty5     Ss+  14:40   0:00 /sbin/getty 38400 tty5
root      1937  0.0  0.0   3800   584 tty6     Ss+  14:40   0:00 /sbin/getty 38400 tty6
root      1938  0.0  0.0   3800   592 ttyS0    Ss+  14:40   0:00 /sbin/getty -L ttyS0 115200 vt102
wfg       1939  0.1  0.1  40028  3156 tty1     S    14:40   0:00 -zsh
wfg       1955  0.0  0.0   9388  1496 tty1     S+   14:40   0:00 /bin/bash /usr/bin/startx
wfg       1972  0.0  0.0  15444   920 tty1     S+   14:40   0:00 xinit /etc/X11/xinit/xinitrc -- /etc/X11/xinit/xserverrc :0 -auth /t
root      1973  2.4  0.8  97148 16272 tty7     Ss+  14:40   0:05 /usr/bin/X11/X -nolisten tcp
wfg       2016  0.7  0.2 104840  5812 tty1     S    14:41   0:01 /usr/bin/fluxbox
wfg       2047  0.0  0.0  35868   676 ?        Ss   14:41   0:00 /usr/bin/ssh-agent /usr/bin/dbus-launch --exit-with-session /home/wf
wfg       2050  0.0  0.0  23868   736 tty1     S    14:41   0:00 /usr/bin/dbus-launch --exit-with-session /home/wfg/.xsession
wfg       2051  0.0  0.0  21084   532 ?        Ss   14:41   0:00 /usr/bin/dbus-daemon --fork --print-pid 5 --print-address 7 --sessio
wfg       2061  0.0  0.0  31548   940 ?        Ss   14:41   0:00 /usr/lib/scim-1.0/scim-helper-manager
wfg       2062  0.1  0.2 144616  5772 ?        Ssl  14:41   0:00 /usr/lib/scim-1.0/scim-panel-gtk --display :0.0 -c simple -d --no-st
wfg       2064  0.1  0.5  55928  9932 ?        Ss   14:41   0:00 /usr/lib/scim-1.0/scim-launcher -d -c simple -e pinyin -f x11
wfg       2065  0.2  0.4 139192  9352 tty1     S    14:41   0:00 urxvt
wfg       2068  0.9  0.1  46664  3876 pts/0    Ss+  14:41   0:01 zsh
wfg       2084  3.3  2.5 438088 49824 pts/0    SNl  14:42   0:03 /usr/lib/iceweasel/firefox-bin -a iceweasel
wfg       2086  0.1  0.1  41580  2800 pts/0    SN   14:42   0:00 /usr/lib/libgconf2-4/gconfd-2 11
root      2118  1.0  0.1  63868  2956 ?        Ss   14:44   0:00 sshd: wfg [priv]
wfg       2120  0.6  0.0  63996  1744 ?        S    14:44   0:00 sshd: wfg@pts/1
wfg       2121  4.3  0.1  44284  3260 pts/1    Ss   14:44   0:00 -zsh
root      2142  0.8  0.1  63868  2956 ?        Ss   14:44   0:00 sshd: wfg [priv]
wfg       2144  0.2  0.0  63996  1768 ?        S    14:44   0:00 sshd: wfg@pts/2
wfg       2145  5.1  0.1  44284  3272 pts/2    Ss+  14:44   0:00 -zsh
wfg       2170  0.0  0.0  18984  1116 pts/1    R+   14:44   0:00 ps aux

wfg@hp ~% cat /proc/meminfo
MemTotal:        1979588 kB
MemFree:         1663652 kB
Buffers:             152 kB
Cached:           132152 kB
SwapCached:            0 kB
Active:            95964 kB
Inactive:         106692 kB
Active(anon):      75760 kB
Inactive(anon):        0 kB
Active(file):      20204 kB
Inactive(file):   106692 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         70444 kB
Mapped:            38184 kB
Slab:              49192 kB
SReclaimable:      37324 kB
SUnreclaim:        11868 kB
PageTables:         4920 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      989792 kB
Committed_AS:     166344 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      355912 kB
VmallocChunk:   34359354931 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       93888 kB
DirectMap2M:     1961984 kB


VM_EXEC protection ON:
% vmmon nr_mapped nr_active_file nr_inactive_file pgmajfault pgdeactivate pgfree

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             9737             5147            29955              561                0           637722
             9740             8920            64075              561                0           678360
             9740            12791            98061              561                0           718865
             9740            16539           132232              561                0           759370
             9740            20372           166287              561                0           801824
             9740            24205           201365              561                0           842329
             9740            28064           235953              561                0           884676
             9740            31854           269988              561                0           927029
             9740            35746           305535              561                0           967535
             9740            39536           339478              561                0          1009880
             9740            43417           373641              561                0          1050389
             9740            54729           381210              561             6912          1109898
             9740            58435           377330              561             7328          1183666
             9740            61997           374070              561             7328          1257928
             9740            65040           370950              561             7328          1332616
             9740            68491           368348              561             7328          1406342
             9740            71889           364481              561             7328          1481793
             9740            74833           361684              561             7328          1556333
             9740            77826           358745              561             7328          1632841
             9740            81287           356122              561             7328          1707073
             9740            84845           352501              561             7328          1781928
             9740            88442           349293              561             7328          1856702
             9740            92007           345926              561             7328          1931420
             9740            95537           343428              561             7328          2004754

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             9740            99076           339752              561             7328          2079395
             9740           102617           336155              561             7328          2153574
             9740           106227           332575              561             7328          2228162
             9740           109757           329434              561             7328          2302880
             9740           113322           326653              561             7328          2377673
             9740           116920           322555              561             7328          2452726
             9740           120541           318326              561             7328          2527851
             9740           124101           315354              561             7328          2602099
             9740           127692           311539              561             7328          2676899
             9740           131259           307116              561             7328          2751590
             9740           134799           304935              561             7328          2824614
             9740           138298           301002              561             7328          2898581
             9740           141890           297370              561             7328          2973273
             9740           145455           294740              561             7328          3046973
             9740           149056           290937              561             7328          3121656
             9740           152595           287499              561             7328          3196095
             9740           156165           284079              561             7328          3270639
             9740           159706           279972              561             7328          3344822
             9740           163184           276041              561             7328          3419006
             9740           166767           272461              561             7328          3492500
             9740           170337           268830              561             7328          3566045
             9740           173919           265143              561             7328          3640676
             9740           177478           261685              561             7328          3715228
             9740           181040           258126              561             7328          3789731

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             9740           184631           254802              561             7328          3863980
             9740           188182           251125              561             7328          3938712
             9740           191773           246756              561             7328          4013327
             9740           195241           244868              561             7328          4085672
             9740           198805           240257              561             7328          4160538
             9740           202313           237616              561             7328          4234145
             9740           205883           232906              561             7328          4308496
             9740           209435           229485              561             7328          4381419
             9740           212977           226463              561             7328          4455412
             9740           216454           223230              561             7328          4528635
             9740           218700           220407              561             8614          4600912
             9740           218565           220153              561            12267          4674967
             9740           218435           221182              561            15894          4748415
             9740           218547           220048              561            19348          4822991
             9740           218386           220145              561            23027          4895718
             9740           218327           220460              561            26635          4969965
             9616           218528           220848              561            29983          5042835
             9620           218381           220500              561            33648          5117058
             9620           218263           220336              561            37284          5191698
             9620           218112           220231              561            40994          5264628
             9620           218335           219960              561            44344          5338229
             9620           218243           220260              561            47916          5411545
             9620           218081           220230              561            51565          5484453
             9620           218384           219952              561            54837          5557957

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             9620           218233           220589              561            58538          5632008
             9620           218481           220082              561            61815          5705965
             9620           218361           220972              561            65463          5779613
             9620           218310           220031              561            69063          5854200
             7849           218353           219904              561            72552          5926925
             5073           218245           220358              562            76221          6001144
             2496           218189           220285              562            79836          6075799
             2496           218054           219980              562            83551          6150499
             2496           218309           219909              562            86861          6224055
             2496           218246           220356              562            90494          6298165
             2496           218076           220046              562            94141          6372175
             2496           218328           220853              562            97448          6445627
             2498           218320           220278              564           100995          6520225
             2498           218357           219945              564           104559          6594735
             2498           218253           219914              564           108171          6668947
             2498           218203           220376              564           111807          6741552
             2498           218189           220294              564           115370          6816163
             2498           218125           219765              564           119014          6890796
             2498           218313           219947              564           122394          6964372
             2498           218310           219950              564           125987          7038875
             2498           218089           221069              564           129695          7112421
             2498           218340           219942              564           133041          7187200
             2498           218350           220677              564           136611          7260586
             2498           218408           220854              564           140067          7334883

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             2498           218398           219873              564           143626          7409357
             2498           218344           220269              564           147260          7483508
             2498           218134           220223              564           150988          7558268
             2498           218060           220169              564           154621          7632472
             2498           218306           220355              564           157941          7706417
             2498           218273           219987              564           161554          7780305
             2498           218172           220024              564           165204          7853585
             2498           218325           219904              564           168617          7928056
             2498           218300           220323              564           172232          8002176
             2498           218203           220346              564           175878          8076745
             2498           218092           220233              564           179569          8151473
             2498           218306           219890              564           182921          8225080
             2498           218323           219937              564           186494          8299522
             2498           218162           220258              564           190204          8373861
             2498           218378           220492              564           193523          8447890
             2498           218398           220024              564           197083          8521832
             2498           218375           220909              564           200610          8595504
             2498           218341           219888              564           204193          8670039
             2498           218257           220324              564           207805          8742357
             2498           218138           220251              564           211473          8817052
             2498           218295           219871              564           214906          8890706
             2498           218397           220311              564           218360          8964713
             2498           218217           220140              564           222037          9038549
             2498           218051           220235              564           225683          9112128

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             2498           218328           219932              564           228979          9186631
             2498           218189           219975              564           232677          9259389
             2498           218298           219931              564           236155          9333829
             2498           218243           219890              564           239769          9408429
             2498           218230           220351              564           243331          9482485
             1130           218151           219747              564           246990          9556988
              775           218318           221286              564           250327          9629446
              775           218241           220802              564           253963          9704045
              775           218109           220216              564           257582          9778461
              775           218333           220019              564           260955          9852288
              775           218310           219886              564           264527          9924983
              775           218168           221020              564           268200          9998462
              775           218374           220018              564           271551         10072805
              775           218317           220907              564           275105         10146423
              775           218299           219934              564           278658         10220928
              775           218300           219965              564           282206         10293576
              775           218286           219979              564           285810         10368090
              775           218161           219956              564           289484         10442377
              774           218421           220899              564           292728         10515045
              774           218242           220528              564           296456         10589300
              774           218128           220297              564           300067         10663953
              774           218000           220233              564           303775         10736841
              774           218351           219945              564           306990         10810260
              774           218295           219978              564           310635         10884800

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              774           218420           220558              564           314014         10958616
              774           218407           220101              564           317617         11032589
              774           218320           221071              564           321222         11106217
              774           218388           220165              564           324689         11180786
              774           218365           219941              564           328230         11253418
              774           218206           220324              564           331948         11327698
              774           218228           219847              564           335506         11401879
              770           218454           220139              564           338846         11475601
              770           218252           220989              564           342535         11549227
              770           218102           220268              564           346182         11623826
              770           218340           220368              564           349510         11697371
              770           218345           219960              564           353085         11770033
              770           218191           220530              564           356788         11844095
              770           218448           220019              564           360066         11917812
              768           218277           220277              564           363703         11991470
              768           218334           219919              564           367181         12064481
              768           218377           220185              564           370718         12138384
              768           218231           219849              564           374413         12212439
              768           218426           220284              564           377691         12285601
              768           218320           219986              564           381325         12358448
              768           218212           220414              564           384982         12432479
              768           218104           220266              564           388670         12507241
              768           218325           219916              564           392015         12580849
              768           218345           220024              564           395585         12655192

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              768           218154           220274              564           399263         12728833
              768           218385           220943              564           402536         12802248
              768           218333           219940              564           406137         12875088
              768           218310           219950              564           409712         12949461
              768           218397           220271              564           413198         13023563
              768           218288           219876              564           416856         13098002
              768           218389           220474              564           420228         13170929
              768           218348           219958              564           423787         13243559
              768           218242           219858              564           427452         13317693
              768           218484           220791              564           430745         13390565
              768           218357           220333              564           434390         13464639
              768           218156           220278              564           438078         13537783
              768           218118           220220              564           441706         13612159
              768           218367           219970              564           445023         13685638
              768           218347           220229              565           448623         13759886
              769           218165           220923              565           452323         13833912
              769           218489           220057              565           455565         13907931
              769           218309           220970              565           459273         13981707
              769           218410           219921              565           462707         14056149
              769           218308           219949              565           466327         14128875
              769           218289           220353              565           469927         14202994
              769           218235           219857              565           473540         14277225
              769           218390           220001              565           476858         14350371
              769           218229           220381              565           480506         14423884

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              769           218136           220250              565           484179         14497379
              769           218333           219935              565           487535         14570954
              769           218249           220915              565           491129         14644242
              769           218122           220136              565           494805         14718972
              769           218369           220975              565           498093         14792388
              769           218346           220065              565           501696         14866987
              769           218330           219960              565           505247         14939588
              769           218312           219982              565           508818         15014087
              769           218299           220315              565           512421         15088240
              769           218297           219934              565           515972         15162148
              769           218316           221198              565           519426         15235217
              769           218336           220682              565           522986         15309720
              769           218125           220201              565           526694         15383119
              769           218052           220210              565           530347         15457278
              769           218340           219953              565           533625         15530728
              769           218267           220058              565           537257         15605205
              769           218390           220352              565           540721         15679276
              769           218346           219977              565           544293         15753302
              769           218318           221029              565           547839         15826714
              769           218385           220258              565           551316         15901240
              769           218249           220054              565           554970         15973871
              769           218234           220357              565           558544         16048093
              769           218137           220326              565           562221         16122725
              769           218342           219928              565           565582         16196396

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              769           218255           221137              565           569156         16269720
              769           218127           220208              565           572843         16344319
              769           218324           220286              565           576150         16417895
              769           218292           220042              565           579762         16490463
              769           218359           219944              565           583261         16565000
              769           218283           220500              565           586855         16639023
              769           218330           219940              565           590398         16713063
              769           218463           220831              565           593800         16786496
              769           218368           219903              565           597382         16861000
              769           218267           220324              565           601032         16933344
              769           218118           220281              565           604740         17008040
              769           218020           219878              565           608418         17082703
              769           218364           220546              565           611609         17155480
              769           218229           220202              565           615262         17229471
              769           218359           220594              565           618636         17303079
              769           218347           219955              565           622207         17375756
              769           218271           220063              565           625832         17450228
              769           218334           220449              565           629335         17524283
              769           218429           220515              565           632789         17597558
              769           218426           220608              565           636282         17671695
              769           218313           219958              565           639906         17744423
              769           218255           219852              565           643513         17818191
              769           218389           220132              565           646839         17891351
              769           218325           219979              565           650443         17964015

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              769           218210           219793              565           654108         18038167
              769           218373           220424              565           657427         18111070
              769           218207           220385              565           661102         18183350
              769           218173           220386              565           664685         18257885
              769           218473           220072              565           667960         18331346
              769           218251           221022              565           671670         18404849
              769           218206           220193              565           675264         18479513
              769           218057           220182              565           678931         18552337
              769           218339           219996              565           682225         18625722
              769           218210           220092              565           685903         18700257
              769           218405           220569              565           689232         18774089
              769           218421           220905              565           692786         18847221
              769           218380           219950              565           696317         18921725
              769           218309           219908              565           699920         18994483
              769           218273           220013              565           703505         19068446
              769           218433           220911              565           706825         19141317
              768           218301           219970              565           710468         19215533
              768           218258           220365              565           714091         19288197
              768           218098           220333              565           717810         19362893
              768           218463           220159              565           721011         19436162
              768           218284           221113              565           724677         19509709
              768           218094           220241              565           728354         19582627
              768           218343           219927              565           731671         19656171
              768           218344           219926              565           735260         19730678

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              768           218110           221120              565           739012         19804222
              768           218454           220426              565           742234         19877989
              768           218337           220677              565           745838         19952146
              768           218335           219926              565           749365         20024804
              768           218286           220117              565           752977         20099148
              768           218382           220150              565           756440         20172469
              768           218377           220548              565           759918         20246301
              768           218258           220369              565           763555         20318579
              768           218221           220310              565           767151         20393181
              768           218105           219711              565           770847         20467744
              768           218365           220869              565           774122         20540442
              768           218259           220304              565           777746         20614615
              768           218069           220270              565           781433         20687502
              768           218347           219927              565           784721         20761046
              768           218305           219914              565           788352         20835605
              768           218143           221068              565           792032         20909100
              768           218460           220845              565           795281         20982533
              768           218254           220029              565           798953         21057006
              857           218543           220987              606           799462         21075710
              857           218543           220987              606           799462         21075713
              857           218543           220987              606           799462         21075934
              857           218543           220987              606           799462         21075937
              857           218543           220987              606           799462         21075939
              857           218543           220987              606           799462         21076151

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              857           218543           220987              606           799462         21076153
              857           218543           220987              606           799462         21076156
              857           218543           220987              606           799462         21076272
              857           218543           220987              606           799462         21076275
              857           218543           220987              606           799462         21076277
             1221           218543           223637              671           799462         21076494
             2379           218544           225770              795           799462         21079005
             2411           218544           225360              797           799462         21079616
             2411           218544           225360              797           799462         21079884
             2411           218544           225360              797           799462         21079887
             2411           218544           225360              797           799462         21079889
             2411           218544           225360              797           799462         21080174
             2411           218544           225360              797           799462         21080176
             2411           218560           225344              797           799462         21080245
             2411           218560           225344              797           799462         21080459
             2411           218560           225344              797           799462         21080618
             2414           218560           225344              797           799462         21080620
             2414           218560           225344              797           799462         21080747
             2414           218560           225344              797           799462         21080749
             2414           218560           225344              797           799462         21080752
             2414           218560           225344              797           799462         21080779
             2414           218560           225344              797           799462         21080782
             2414           218560           225344              797           799462         21080784
             2414           218560           225344              797           799462         21080795

VM_EXEC protection OFF:
~% vmmon nr_mapped nr_active_file nr_inactive_file pgmajfault pgdeactivate pgfree

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             9368             5035            26389              554                0           633391
             9368             5035            26389              554                0           633397
             9559             5036            26836              561                0           633888
             9559             5036            26924              561                0           633891
             9562             7682            52723              561                0           660980
             9566            11451            85796              561                0           703380
             9566            15272           120910              561                0           743891
             9626            19105           154964              561                0           784401
             9627            22855           188885              561                0           826784
             9627            26726           223137              561                0           867294
             9627            30517           257231              561                0           909640
             9658            34389           292240              561                0           950160
             9658            38198           326910              561                0           992506
             9658            42038           361419              561                0          1033010
             9658            45802           391241              561             3136          1078165
             9658            56707           380157              561             7200          1145085
             9658            60225           376640              561             7200          1219657
             9658            63603           373594              561             7200          1293906
             9658            66626           370429              561             7232          1368607
             9658            70123           366132              561             7232          1443441
             9658            73720           363346              561             7232          1517044
             9658            77217           360004              561             7232          1593619
             9658            80502           356975              561             7232          1665902
             9658            84019           353154              561             7232          1740955

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             9658            87480           349734              561             7232          1815507
             9658            91067           346656              561             7232          1891608
             9658            94589           343203              561             7232          1964477
             9658            98179           339367              561             7232          2039321
             9658           101725           335960              561             7232          2113511
             9658           105278           332913              561             7232          2187360
             9658           108681           329423              561             7232          2262025
             9658           112251           325864              561             7232          2338186
             9658           115621           323150              561             7232          2412595
             9658           119144           320330              561             7232          2487342
             9658           122626           315657              561             7232          2560440
             9658           126277           313211              561             7232          2635624
             9658           129796           309471              561             7232          2710325
             9658           133386           305410              561             7232          2784874
             9658           136913           301492              561             7232          2859128
             9658           140470           298382              561             7232          2933644
             9658           144123           294611              561             7232          3008344
             9658           147701           291873              561             7232          3082991
             9658           151312           287947              561             7232          3158135
             9658           154913           284134              561             7232          3232826
             9658           158451           280777              561             7232          3307472
             9658           162055           276654              561             7232          3381431
             9658           165555           274108              561             7232          3455039
             9658           169125           270786              561             7232          3529200

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             9658           172695           266946              561             7232          3604088
             9658           176296           263486              561             7232          3678732
             9658           179866           259475              561             7232          3753866
             9658           183436           255670              561             7232          3828625
             9658           187037           251425              561             7232          3903257
             9658           190587           249279              561             7232          3976094
             9658           194086           245178              561             7232          4050424
             9658           197689           241212              561             7232          4125056
             9658           201271           237632              561             7232          4199737
             9658           204841           233834              561             7232          4274720
             9658           208431           230131              561             7232          4349220
             9658           212011           227400              561             7232          4422819
             9658           215489           223735              561             7232          4497071
             9658           218385           220541              561             7867          4571286
             9658           218322           220444              561            11479          4644623
             9658           218216           220390              561            15175          4720412
             9658           218493           220943              561            18547          4794378
             9658           218358           220087              561            22179          4867094
             9658           218209           220140              561            25877          4941694
             9658           218351           219984              561            29296          5015486
             7781           218355           220984              561            32985          5088777
             7765           218410           220692              561            36465          5163337
             7765           218335           219950              561            40058          5237934
             7765           218322           220475              561            43651          5310193

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             7766           218179           219812              562            47343          5384969
             7766           218433           220367              562            50572          5457723
             7766           218249           220490              562            54243          5530170
             7766           218150           220397              562            57922          5604916
             7766           218462           220052              562            61176          5679897
             7766           218399           220019              562            64819          5753551
             7766           218324           220222              572            68454          5827860
             7811           218436           220907              590            71846          5901072
             6117           218400           220469              592            75586          5975733
             3100           218390           220672              592            79362          6050300
              930           218403           220296              592            83163          6124830
              921           218372           219981              593            86784          6199369
              925           218291           220301              593            90429          6273641
              925           218102           220339              593            94177          6346459
              925           218392           220984              593            97399          6418998
              925           218284           220728              593           101066          6493286
              925           218210           220392              593           104720          6568020
              925           218493           220917              593           108034          6641495
              925           218373           221009              593           111669          6716048
              925           218425           220525              593           115157          6790465
              925           218361           219997              593           118760          6863999
              925           218329           220445              593           122363          6937327
              925           218234           220411              593           126007          7011965
              925           218156           220297              593           129675          7086660

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              925           218401           219989              593           133003          7160612
              925           218374           220046              593           136607          7234710
              936           218251           220052              598           140275          7309538
              936           218332           220483              598           143729          7383530
              936           218418           220022              598           147207          7457646
              936           218533           220729              598           150674          7531093
              936           218443           220227              598           154254          7605487
              936           218325           220378              598           157881          7679318
              936           218238           220364              598           161554          7752429
              936           218117           220293              598           165255          7827124
              936           218385           219992              598           168553          7900642
              936           218359           220082              598           172159          7975081
              936           218396           220013              598           175687          8049617
              936           218351           220175              598           179261          8123723
              936           218454           220064              598           182717          8197492
              936           218506           220927              598           186221          8271099
              936           218411           220710              598           189834          8345669
              936           218333           220921              598           193492          8419884
              936           218316           220411              598           197099          8494388
              936           218141           220141              598           200823          8569245
              936           218469           220963              598           204061          8642597
              936           218303           220913              598           207755          8717068
              936           218405           220272              598           211229          8791638
              936           218427           219983              598           214777          8866109

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              936           218326           220404              598           218427          8940293
              936           218209           220393              598           222093          9013086
              936           218102           220308              598           225790          9087782
              936           218392           220915              598           229066          9163134
              936           218400           220629              598           232669          9237613
              936           218418           221040              598           236210          9312084
              936           218437           220500              598           239778          9386620
              936           218412           220091              598           243393          9461127
              936           218273           220393              598           247081          9535375
              936           218125           220285              598           250747          9608293
              936           218448           220055              598           254021          9683584
              936           218396           220045              598           257632          9756246
              936           218246           220451              598           261331          9830494
              936           218368           220556              598           264744          9904713
              936           218463           220745              598           268229          9977937
              931           218435           220973              598           271896         10052242
              931           218423           219928              598           275487         10126797
              931           218335           220421              598           279124         10200916
              931           218239           220357              598           282769         10273743
              931           218080           220292              598           286518         10348497
              931           218372           220031              598           289792         10421955
              931           218382           220053              598           293362         10496440
              931           218283           220152              598           297010         10570962
              931           218395           220041              598           300464         10645474

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              931           218415           220063              598           304034         10719964
              933           218254           220412              600           307745         10794403
              933           218249           219863              600           311330         10868756
              907           218481           220498              600           314754         10942054
              794           218374           221250              600           318455         11015828
              649           218266           220274              600           322184         11090583
              605           218553           220393              600           325545         11164588
              605           218410           221124              600           329221         11238537
              556           218480           220528              600           332686         11313045
              704           218320           220508              618           336333         11386329
              706           218362           220113              618           339757         11459257
              706           218452           220024              618           343233         11533762
              706           218399           220013              618           346835         11606489
              706           218325           220507              618           350493         11680614
              706           218179           220301              618           354198         11755470
              706           218143           220310              618           357979         11830002
              706           218423           220029              618           361265         11904778
              706           218359           220061              618           364888         11978024
              706           218421           220064              618           368413         12052464
              706           218419           220034              618           371974         12127002
              706           218360           220464              618           375600         12201122
              706           218284           220393              618           379238         12275786
              706           218200           220038              618           382912         12350452
              706           218440           220076              618           386238         12423931

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              737           218232           221260              626           389933         12497799
              769           218544           220262              632           393218         12572303
              769           218491           220954              632           396820         12646135
              765           218377           221004              632           400462         12720702
              758           218458           220869              632           403937         12795088
              758           218411           220356              632           407574         12869591
              758           218335           220565              632           411265         12943900
              758           218291           220323              632           414865         13018508
              758           218131           220387              632           418574         13091621
              758           218455           220868              632           421816         13166587
              758           218411           220042              632           425440         13241159
              758           218402           220052              632           429015         13314754
              758           218434           220030              632           432542         13388325
              758           218378           220108              632           436178         13462798
              758           218267           220443              632           439838         13537078
              758           218158           219803              632           443537         13611737
              758           218462           220759              632           446768         13684545
              758           218304           220589              632           450444         13758650
              758           218238           220248              632           454059         13833282
              758           218508           221032              632           457355         13906731
              758           218411           221097              632           461011         13981268
              758           218502           220088              632           464486         14055739
              758           218425           220029              632           468081         14128468
              758           218442           220044              632           471644         14202939

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              758           218197           219980              632           475448         14277412
              758           218585           220582              632           478626         14350235
              758           218362           220844              632           482336         14424181
              758           218153           220397              632           486032         14497989
              758           218432           220085              632           489319         14572359
              759           218401           220035              633           492940         14645117
              764           218249           221189              636           496579         14718804
              764           218550           220378              636           499875         14792815
              764           218434           220757              636           503478         14866765
              764           218419           220028              636           507028         14940308
              764           218416           220043              636           510720         15013964
              764           218396           220430              636           514377         15088108
              764           218244           220335              636           518083         15162735
              764           218234           219856              636           521683         15236999
              764           218406           220072              636           525067         15310945
              764           218309           221065              636           528692         15384520
              764           218250           220602              636           532300         15458898
              764           218500           221032              636           535616         15532409
              764           218402           220849              636           539211         15606981
              764           218438           220475              636           542762         15681424
              764           218447           220000              636           546312         15755963
              763           218384           220457              637           549924         15828821
              764           218246           220435              637           553643         15902955
              764           218192           220381              637           557403         15977566

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              765           218439           220074              638           560815         16051161
              765           218395           220026              642           564490         16125937
              772           218402           220052              642           568049         16200409
              770           218422           220577              642           571579         16274367
              770           218366           220009              642           575194         16349028
              770           218386           220038              642           578754         16422937
              770           218496           220983              642           582180         16496402
              770           218495           221041              642           585755         16570865
              770           218321           221144              642           589474         16645209
              770           218189           220274              642           593186         16720032
              770           218543           220914              642           596429         16793418
              605           218404           220790              642           600041         16867953
              773           218294           219959              661           603686         16941696
              770           218391           220014              661           607162         17016224
              770           218337           220410              661           610796         17090376
              770           218177           220346              661           614505         17165103
              770           218193           219840              661           618079         17239467
              770           218423           220035              661           621415         17313220
              770           218428           220163              661           625155         17387573
              770           218289           220174              661           628843         17462224
              770           218398           220610              661           632300         17536184
              770           218390           220252              661           635867         17610815
              770           218358           219976              661           639479         17684919
              770           218546           220973              661           642826         17758160

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
              770           218449           221230              661           646472         17832500
             1113           218466           220978              710           649881         17905235
             1076           218426           220949              710           653464         17979769
             1081           218262           221048              710           657208         18054048
             1081           218283           220346              710           660767         18128602
             1081           218481           221042              710           664104         18202209
             1081           218446           221045              710           667698         18276745
             1081           218323           220509              710           671714         18351262
             1081           218405           220088              710           675167         18424047
             1081           218405           220024              710           678747         18498460
             1081           218297           220388              710           682435         18572710
             1081           218220           219850              710           686071         18647021
             1081           218348           221302              710           689416         18719541
             1081           218211           220410              710           693040         18792907
             1081           218187           220338              710           696654         18866997
             1081           218416           220076              710           699981         18940508
             1081           218327           221285              710           703567         19013863
             1081           218228           220265              710           707215         19088494
             1116           218412           220030              717           710535         19160438
             1114           218292           220086              717           714214         19235035
             1114           218522           220497              717           717540         19308867
             1114           218414           220057              717           721207         19383050
             1114           218364           221101              717           724775         19456441
             1114           218405           219974              717           728238         19531008

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             1114           218318           220510              717           731907         19603222
             1114           218221           220447              717           735563         19677888
             1114           218252           219866              717           739112         19752104
             1114           218459           220432              717           742471         19825615
             1114           218279           220849              717           746138         19899513
             1114           218162           220345              717           749783         19974000
             1114           218438           220372              717           753228         20047534
             1113           218353           220148              717           756893         20120166
             1108           218431           220039              717           760381         20194702
             1108           218378           220511              717           763952         20268693
             1108           218385           221011              717           767504         20341759
             1108           218467           220654              717           770926         20416167
             1108           218349           220025              717           774562         20488926
             1108           218271           220391              717           778220         20563143
             1108           218260           219883              717           781790         20637373
             1108           218455           220686              717           785130         20710614
             1108           218355           220926              717           788748         20784642
             1108           218282           220284              717           792401         20859209
             1108           218471           220991              717           795877         20932815
             1108           218350           220146              717           799583         21007268
             1201           218499           220933              750           802700         21078409
             1213           218649           221046              757           802700         21079123
             1213           218649           221046              757           802700         21079257
             1213           218649           221046              757           802700         21079259

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             1213           218649           221046              757           802700         21079275
             1213           218649           221046              757           802700         21079510
             1213           218649           221046              757           802700         21079513
             1213           218649           221046              757           802700         21079515
             1213           218649           221046              757           802700         21079562
             1213           218649           221046              757           802700         21079564
             1213           218649           221046              757           802700         21079567
             1213           218649           221046              757           802700         21079582
             1213           218649           221046              757           802700         21079585
             1213           218649           221046              757           802700         21079587
             1213           218649           221046              757           802700         21079592
             1213           218649           221046              757           802700         21079594
             1213           218649           221046              757           802700         21079597
             1213           218649           221108              759           802700         21079615
             1215           218649           221105              759           802700         21079618
             1215           218649           221105              759           802700         21079621
             1215           218649           221105              759           802700         21079651
             1215           218649           221105              759           802700         21079653
             1215           218649           221105              759           802700         21079656
             1215           218649           221105              759           802700         21079677
             1215           218649           221105              759           802700         21079680
             1215           218649           221105              759           802700         21079682
             1215           218649           221105              759           802700         21079687
             1215           218649           221105              759           802700         21079689

        nr_mapped   nr_active_file nr_inactive_file       pgmajfault     pgdeactivate           pgfree
             1215           218649           221105              759           802700         21079692
             1215           218649           221105              759           802700         21079696
             1215           218649           221105              759           802700         21079699
             1215           218649           221105              759           802700         21079701
             1215           218649           221105              759           802700         21079713
             1215           218649           221167              760           802700         21079720
             1219           218649           221213              761           802700         21079738
             1219           218649           221216              761           802700         21079777
             1219           218649           221216              761           802700         21079780
             1343           218649           222487              786           802700         21079801
             2517           218649           225754              940           802700         21082357
             2676           218650           225479              947           802700         21082932
             2686           218650           225475              947           802700         21083014
             2687           218650           225484              947           802700         21083327
             2687           218650           225484              947           802700         21083330
             2687           218650           225484              947           802700         21083332
             2687           218650           225484              947           802700         21083578
             2687           218650           225484              947           802700         21083580
             2687           218650           225484              947           802700         21083584
           

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
