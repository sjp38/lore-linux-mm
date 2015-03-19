Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id ED27E6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 07:04:09 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so20154558igb.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 04:04:09 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n2si1299862icu.81.2015.03.19.04.04.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Mar 2015 04:04:08 -0700 (PDT)
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150316074607.GA24885@dhcp22.suse.cz>
	<201503172013.HCI87500.QFHtOOMLOVFSJF@I-love.SAKURA.ne.jp>
	<20150317131501.GH28112@dhcp22.suse.cz>
	<201503182033.CFI43269.FOJFOFtQHLSOMV@I-love.SAKURA.ne.jp>
	<20150318122343.GF17241@dhcp22.suse.cz>
In-Reply-To: <20150318122343.GF17241@dhcp22.suse.cz>
Message-Id: <201503192003.ADB43774.JLHOSMVFtQOFFO@I-love.SAKURA.ne.jp>
Date: Thu, 19 Mar 2015 20:03:50 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > So, your patch introduces a trigger to involve OOM killer for !__GFP_FS
> > allocation. I myself think that we should trigger OOM killer for !__GFP_FS
> > allocation in order to make forward progress in case the OOM victim is blocked.
> > What is the reason we did not involve OOM killer for !__GFP_FS allocation?
> 
> Because the reclaim context for these allocations is very restricted. We
> might have a lot of cache which needs to be written down before it will
> be reclaimed. If we triggered OOM from this path we would see a lot of
> pre-mature OOM killers triggered.

I see. I was worrying that the reason is related to possible deadlocks.

Not giving up waiting for cache which _needs to be_ written down before
it will be reclaimed (sysctl_nr_alloc_retry == ULONG_MAX) is causing
system lockups we are seeing, isn't it?

Giving up waiting for cache which _needs to be_ written down before
it will be reclaimed (sysctl_nr_alloc_retry == 1) is also causing
a lot of pre-mature page allocation failures I'm seeing, isn't it?

    /*
     * If we fail to make progress by freeing individual
     * pages, but the allocation wants us to keep going,
     * start OOM killing tasks.
     */
    if (!did_some_progress) {
            page = __alloc_pages_may_oom(gfp_mask, order, ac,
                                            &did_some_progress);
            if (page)
                    goto got_pg;
            if (!did_some_progress)
                    goto nopage;

            nr_retries++;
    }
    /* Wait for some write requests to complete then retry */
    wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
    goto retry;

If we can somehow tell that there is no more cache which _can be_
written down before it will be reclaimed, we don't need to use
sysctl_nr_alloc_retry, and we can trigger OOM killer, right?



Today's stress testing found another problem your patch did not care.
If page fault caused SIGBUS signal when the first OOM victim cannot be
terminated due to mutex_lock() dependency, the process which triggered
the page fault will likely be killed. If the process is the global init,
kernel panic is triggered like shown below.

(From http://I-love.SAKURA.ne.jp/tmp/serial-20150319-1.txt.xz )
----------
[ 1277.833918] a.out           D ffff880066503bc8     0  8374   5141 0x00000080
[ 1277.835930]  ffff880066503bc8 ffff88007d1180d0 ffff8800664fd070 ffff880066503bc8
[ 1277.838052]  ffffffff8122a0eb ffff88007b8edc20 ffff880066500010 ffff88007fc93740
[ 1277.840102]  7fffffffffffffff ffff880066503d20 0000000000000002 ffff880066503be8
[ 1277.842128] Call Trace:
[ 1277.842766]  [<ffffffff8122a0eb>] ? blk_peek_request+0x8b/0x2a0
[ 1277.844222]  [<ffffffff814d1aee>] schedule+0x3e/0x90
[ 1277.845459]  [<ffffffff814d3dfd>] schedule_timeout+0x12d/0x1a0
[ 1277.846885]  [<ffffffff810b5b16>] ? ktime_get+0x46/0xb0
[ 1277.848189]  [<ffffffff814d0faa>] io_schedule_timeout+0xaa/0x130
[ 1277.849702]  [<ffffffff8108c610>] ? prepare_to_wait+0x60/0x90
[ 1277.851173]  [<ffffffff814d1d90>] ? bit_wait_io_timeout+0x80/0x80
[ 1277.852661]  [<ffffffff814d1dc6>] bit_wait_io+0x36/0x50
[ 1277.853946]  [<ffffffff814d2125>] __wait_on_bit+0x65/0x90
[ 1277.855005] ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 320)
[ 1277.855083] ata4: EH complete
[ 1277.855174] sd 4:0:0:0: [sdb] tag#27 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855175] sd 4:0:0:0: [sdb] tag#21 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855177] sd 4:0:0:0: [sdb] tag#18 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855178] sd 4:0:0:0: [sdb] tag#21 CDB: Read(10) 28 00 05 33 29 37 00 00 08 00
[ 1277.855179] sd 4:0:0:0: [sdb] tag#27 CDB: Read(10) 28 00 05 33 53 6f 00 00 08 00
[ 1277.855179] sd 4:0:0:0: [sdb] tag#18 CDB: Write(10) 2a 00 05 34 be 67 00 00 08 00
[ 1277.855183] blk_update_request: I/O error, dev sdb, sector 87249775
[ 1277.855256] sd 4:0:0:0: [sdb] tag#22 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855257] sd 4:0:0:0: [sdb] tag#28 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855258] sd 4:0:0:0: [sdb] tag#22 CDB: Read(10) 28 00 05 33 4e 2f 00 00 08 00
[ 1277.855259] sd 4:0:0:0: [sdb] tag#19 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855260] blk_update_request: I/O error, dev sdb, sector 87248431
[ 1277.855260] sd 4:0:0:0: [sdb] tag#28 CDB: Write(10) 2a 00 05 33 5a 27 00 00 18 00
[ 1277.855261] sd 4:0:0:0: [sdb] tag#19 CDB: Read(10) 28 00 05 34 ba a7 00 00 08 00
[ 1277.855261] blk_update_request: I/O error, dev sdb, sector 87251495
[ 1277.855262] blk_update_request: I/O error, dev sdb, sector 87341735
[ 1277.855319] sd 4:0:0:0: [sdb] tag#20 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855320] sd 4:0:0:0: [sdb] tag#29 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855320] sd 4:0:0:0: [sdb] tag#20 CDB: Write(10) 2a 00 05 33 4d 37 00 00 08 00
[ 1277.855321] sd 4:0:0:0: [sdb] tag#24 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855322] blk_update_request: I/O error, dev sdb, sector 87248183
[ 1277.855322] sd 4:0:0:0: [sdb] tag#29 CDB: Write(10) 2a 00 05 34 c1 2f 00 00 10 00
[ 1277.855323] sd 4:0:0:0: [sdb] tag#24 CDB: Read(10) 28 00 05 33 52 9f 00 00 08 00
[ 1277.855323] blk_update_request: I/O error, dev sdb, sector 87343407
[ 1277.855324] blk_update_request: I/O error, dev sdb, sector 87249567
[ 1277.855373] sd 4:0:0:0: [sdb] tag#30 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[ 1277.855374] blk_update_request: I/O error, dev sdb, sector 87343167
[ 1277.855374] sd 4:0:0:0: [sdb] tag#30 CDB: Read(10) 28 00 05 33 23 af 00 00 08 00
[ 1277.855375] blk_update_request: I/O error, dev sdb, sector 87237551
[ 1277.855376] blk_update_request: I/O error, dev sdb, sector 87250175
[ 1277.855728] Buffer I/O error on dev sdb1, logical block 1069738, lost async page write
[ 1277.855736] Buffer I/O error on dev sdb1, logical block 10917863, lost async page write
[ 1277.855739] Buffer I/O error on dev sdb1, logical block 10917864, lost async page write
[ 1277.855741] Buffer I/O error on dev sdb1, logical block 10917885, lost async page write
[ 1277.855744] Buffer I/O error on dev sdb1, logical block 11933189, lost async page write
[ 1277.855749] Buffer I/O error on dev sdb1, logical block 10917840, lost async page write
[ 1277.855768] Buffer I/O error on dev sdb1, logical block 10917829, lost async page write
[ 1277.856003] Buffer I/O error on dev sdb1, logical block 10906429, lost async page write
[ 1277.856008] Buffer I/O error on dev sdb1, logical block 10906430, lost async page write
[ 1277.856011] Buffer I/O error on dev sdb1, logical block 10906431, lost async page write
[ 1277.856847] XFS (sdb1): metadata I/O error: block 0x50080d0 ("xlog_iodone") error 5 numblks 64
[ 1277.856850] XFS (sdb1): xfs_do_force_shutdown(0x2) called from line 1180 of file fs/xfs/xfs_log.c.  Return address = 0xffffffffa00f31a9
[ 1277.857054] XFS (sdb1): Log I/O Error Detected.  Shutting down filesystem
[ 1277.857055] XFS (sdb1): Please umount the filesystem and rectify the problem(s)
[ 1277.858225] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 1 0 0 1426725983 e pipe failed
[ 1277.858320] Core dump to |/usr/libexec/abrt-hook-ccpp 7 16777216 4995 0 0 1426725983 e pipe failed
[ 1277.858385] Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000007

[ 1277.858387] CPU: 1 PID: 1 Comm: init Tainted: G            E   4.0.0-rc4+ #15
[ 1277.858388] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[ 1277.858390]  ffff880037baf740 ffff88007d07bc38 ffffffff814d0ee5 000000000000fffe
[ 1277.858391]  ffffffff81701f18 ffff88007d07bcb8 ffffffff814d0c6c ffffffff00000010
[ 1277.858392]  ffff88007d07bcc8 ffff88007d07bc68 0000000000000008 ffff88007d07bcb8
[ 1277.858392] Call Trace:
[ 1277.858398]  [<ffffffff814d0ee5>] dump_stack+0x48/0x5b
[ 1277.858400]  [<ffffffff814d0c6c>] panic+0xbb/0x1fa
[ 1277.858403]  [<ffffffff81055871>] do_exit+0xb51/0xb90
[ 1277.858404]  [<ffffffff81055901>] do_group_exit+0x51/0xc0
[ 1277.858406]  [<ffffffff81061dd2>] get_signal+0x222/0x590
[ 1277.858408]  [<ffffffff81002496>] do_signal+0x36/0x710
[ 1277.858411]  [<ffffffff810461d0>] ? mm_fault_error+0xd0/0x160
[ 1277.858413]  [<ffffffff8104661b>] ? __do_page_fault+0x3bb/0x430
[ 1277.858414]  [<ffffffff81002bb8>] do_notify_resume+0x48/0x60
[ 1277.858416]  [<ffffffff814d59a7>] retint_signal+0x41/0x7a
----------

(From http://I-love.SAKURA.ne.jp/tmp/serial-20150319-2.txt.xz )
----------
[ 2822.642453] scsi_io_completion: 21 callbacks suppressed
[ 2822.644049] sd 4:0:0:0: [sdb] tag#10 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.646453] sd 4:0:0:0: [sdb] tag#10 CDB: Read(10) 28 00 05 32 28 ff 00 00 08 00
[ 2822.648630] blk_update_request: 21 callbacks suppressed
[ 2822.648631] blk_update_request: I/O error, dev sdb, sector 87173375
[ 2822.648663] sd 4:0:0:0: [sdb] tag#11 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648665] sd 4:0:0:0: [sdb] tag#11 CDB: Write(10) 2a 00 05 32 25 6f 00 00 08 00
[ 2822.648665] blk_update_request: I/O error, dev sdb, sector 87172463
[ 2822.648676] sd 4:0:0:0: [sdb] tag#12 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648677] sd 4:0:0:0: [sdb] tag#12 CDB: Read(10) 28 00 05 32 1e 8f 00 00 08 00
[ 2822.648678] blk_update_request: I/O error, dev sdb, sector 87170703
[ 2822.648700] sd 4:0:0:0: [sdb] tag#13 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648701] sd 4:0:0:0: [sdb] tag#13 CDB: Write(10) 2a 00 05 32 35 17 00 00 08 00
[ 2822.648701] blk_update_request: I/O error, dev sdb, sector 87176471
[ 2822.648711] sd 4:0:0:0: [sdb] tag#14 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648712] sd 4:0:0:0: [sdb] tag#14 CDB: Write(10) 2a 00 05 32 8c 77 00 00 08 00
[ 2822.648713] blk_update_request: I/O error, dev sdb, sector 87198839
[ 2822.648722] sd 4:0:0:0: [sdb] tag#15 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648723] sd 4:0:0:0: [sdb] tag#15 CDB: Read(10) 28 00 05 0b fb 8f 00 00 08 00
[ 2822.648723] blk_update_request: I/O error, dev sdb, sector 84671375
[ 2822.648742] sd 4:0:0:0: [sdb] tag#16 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648743] sd 4:0:0:0: [sdb] tag#16 CDB: Read(10) 28 00 05 33 3e f7 00 00 08 00
[ 2822.648744] blk_update_request: I/O error, dev sdb, sector 87244535
[ 2822.648753] sd 4:0:0:0: [sdb] tag#17 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648754] sd 4:0:0:0: [sdb] tag#17 CDB: Write(10) 2a 00 05 d1 eb 77 00 00 08 00
[ 2822.648755] blk_update_request: I/O error, dev sdb, sector 97643383
[ 2822.648759] sd 4:0:0:0: [sdb] tag#19 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648760] sd 4:0:0:0: [sdb] tag#19 CDB: Read(10) 28 00 05 32 f9 7f 00 00 08 00
[ 2822.648760] blk_update_request: I/O error, dev sdb, sector 87226751
[ 2822.648778] sd 4:0:0:0: [sdb] tag#18 FAILED Result: hostbyte=DID_OK driverbyte=DRIVER_TIMEOUT
[ 2822.648780] sd 4:0:0:0: [sdb] tag#18 CDB: Read(10) 28 00 05 32 e3 37 00 00 08 00
[ 2822.648780] blk_update_request: I/O error, dev sdb, sector 87221047
[ 2822.649830] buffer_io_error: 122 callbacks suppressed
[ 2822.649832] Buffer I/O error on dev sdb1, logical block 10896550, lost async page write
[ 2822.649850] Buffer I/O error on dev sdb1, logical block 10897051, lost async page write
[ 2822.649864] Buffer I/O error on dev sdb1, logical block 10899847, lost async page write
[ 2822.649878] Buffer I/O error on dev sdb1, logical block 12205415, lost async page write
[ 2822.649893] Buffer I/O error on dev sdb1, logical block 10903400, lost async page write
[ 2822.649900] Buffer I/O error on dev sdb1, logical block 10905034, lost async page write
[ 2822.649902] Buffer I/O error on dev sdb1, logical block 10905077, lost async page write
[ 2822.649908] Buffer I/O error on dev sdb1, logical block 10900244, lost async page write
[ 2822.649910] Buffer I/O error on dev sdb1, logical block 10901263, lost async page write
[ 2822.649915] Buffer I/O error on dev sdb1, logical block 10899976, lost async page write
[ 2822.649920] XFS (sdb1): metadata I/O error: block 0x50046c8 ("xlog_iodone") error 5 numblks 64
[ 2822.649924] XFS (sdb1): xfs_do_force_shutdown(0x2) called from line 1180 of file fs/xfs/xfs_log.c.  Return address = 0xffffffffa00f31a9
[ 2822.650440] XFS (sdb1): Log I/O Error Detected.  Shutting down filesystem
[ 2822.650440] XFS (sdb1): Please umount the filesystem and rectify the problem(s)
[ 2822.650444] XFS (sdb1): metadata I/O error: block 0x5004701 ("xlog_iodone") error 5 numblks 64
[ 2822.650445] XFS (sdb1): xfs_do_force_shutdown(0x2) called from line 1180 of file fs/xfs/xfs_log.c.  Return address = 0xffffffffa00f31a9
[ 2822.650446] XFS (sdb1): metadata I/O error: block 0x5004741 ("xlog_iodone") error 5 numblks 64
[ 2822.650447] XFS (sdb1): xfs_do_force_shutdown(0x2) called from line 1180 of file fs/xfs/xfs_log.c.  Return address = 0xffffffffa00f31a9
[ 2822.650819] XFS (sdb1): xfs_log_force: error -5 returned.
[ 2822.676108] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 2233 0 0 1426728845 e pipe failed
[ 2822.676268] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 1847 0 0 1426728845 e pipe failed
[ 2822.761872] XFS (sdb1): xfs_imap_to_bp: xfs_trans_read_buf() returned error -5.
[ 2822.814996] XFS (sdb1): xfs_log_force: error -5 returned.
[ 2823.210912] audit: *NO* daemon at audit_pid=1847
[ 2823.212289] audit: audit_lost=1 audit_rate_limit=0 audit_backlog_limit=320
[ 2823.214238] audit: auditd disappeared
[ 2823.215419] audit: type=1701 audit(1426728846.212:69): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=2196 comm="master" exe="/usr/libexec/postfix/master" sig=7
[ 2823.219662] audit: type=1701 audit(1426728846.214:70): auid=4294967295 uid=89 gid=89 ses=4294967295 pid=9984 comm="pickup" exe="/usr/libexec/postfix/pickup" sig=7
[ 2823.228854] audit: type=1701 audit(1426728846.229:71): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=1880 comm="rsyslogd" exe="/sbin/rsyslogd" sig=7
[ 2823.232849] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 1877 0 0 1426728846 e pipe failed
[ 2823.240671] audit: type=1701 audit(1426728846.241:72): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=2265 comm="smbd" exe="/usr/sbin/smbd" sig=7
[ 2823.244547] Core dump to |/usr/libexec/abrt-hook-ccpp 7 16777216 2265 0 0 1426728846 e pipe failed
[ 2823.247697] audit: type=1701 audit(1426728846.248:73): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=2242 comm="smbd" exe="/usr/sbin/smbd" sig=7
[ 2823.252653] Core dump to |/usr/libexec/abrt-hook-ccpp 7 16777216 2242 0 0 1426728846 e pipe failed
[ 2823.263635] audit: type=1701 audit(1426728846.264:74): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=1801 comm="dhclient" exe="/sbin/dhclient" sig=7
[ 2823.267442] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 1801 0 0 1426728846 e pipe failed
[ 2848.437629] audit: type=1701 audit(1426728871.443:75): auid=0 uid=0 gid=0 ses=5 pid=10052 comm="bash" exe="/bin/bash" sig=7
[ 2848.444223] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 10052 0 0 1426728871 e pipe failed
[ 2848.449033] audit: type=1701 audit(1426728871.454:76): auid=0 uid=0 gid=0 ses=5 pid=9958 comm="login" exe="/bin/login" sig=7
[ 2848.455734] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 9958 0 0 1426728871 e pipe failed
[ 2848.460683] audit: type=1701 audit(1426728871.466:77): auid=4294967295 uid=81 gid=81 ses=4294967295 pid=2048 comm="dbus-daemon" exe="/bin/dbus-daemon" sig=7
[ 2848.464454] audit: type=1701 audit(1426728871.470:78): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=1 comm="init" exe="/sbin/init" sig=7
[ 2848.464577] audit: type=1701 audit(1426728871.470:79): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=9986 comm="console-kit-dae" exe="/usr/sbin/console-kit-daemon" sig=7
[ 2848.464578] audit: type=1701 audit(1426728871.470:80): auid=4294967295 uid=70 gid=70 ses=4294967295 pid=2060 comm="avahi-daemon" exe="/usr/sbin/avahi-daemon" sig=7
[ 2848.465160] audit: type=1701 audit(1426728871.470:81): auid=4294967295 uid=70 gid=70 ses=4294967295 pid=2061 comm="avahi-daemon" exe="/usr/sbin/avahi-daemon" sig=7
[ 2848.476649] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 9986 0 0 1426728871 e pipe failed
[ 2848.481923] Core dump to |/usr/libexec/abrt-hook-ccpp 7 0 1 0 0 1426728871 e pipe failed
[ 2848.484090] Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000007
[ 2848.484090] 
[ 2848.486554] CPU: 2 PID: 1 Comm: init Tainted: G            E   4.0.0-rc4+ #15
[ 2848.488377] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[ 2848.491120]  ffff880037be4ac0 ffff88007d07bc38 ffffffff814d0ee5 000000000000fffe
[ 2848.493549]  ffffffff81701f18 ffff88007d07bcb8 ffffffff814d0c6c ffffffff00000010
[ 2848.495723]  ffff88007d07bcc8 ffff88007d07bc68 0000000000000008 ffff88007d07bcb8
[ 2848.498043] Call Trace:
[ 2848.498738]  [<ffffffff814d0ee5>] dump_stack+0x48/0x5b
[ 2848.500114]  [<ffffffff814d0c6c>] panic+0xbb/0x1fa
[ 2848.501394]  [<ffffffff81055871>] do_exit+0xb51/0xb90
[ 2848.502710]  [<ffffffff81055901>] do_group_exit+0x51/0xc0
[ 2848.504128]  [<ffffffff81061dd2>] get_signal+0x222/0x590
[ 2848.505509]  [<ffffffff81002496>] do_signal+0x36/0x710
[ 2848.506848]  [<ffffffff810461d0>] ? mm_fault_error+0xd0/0x160
[ 2848.508421]  [<ffffffff8104661b>] ? __do_page_fault+0x3bb/0x430
[ 2848.509966]  [<ffffffff81002bb8>] do_notify_resume+0x48/0x60
[ 2848.511435]  [<ffffffff814d59a7>] retint_signal+0x41/0x7a
----------

Innocent (possibly critical) process can be killed unexpectedly than
return -ENOMEM to the system calls or return NULL to e.g. kmalloc() users.
This is much worse than choosing the second OOM victim upon timeout.

Why not change each caller to use either __GFP_NOFAIL or __GFP_NORETRY
than introduce global sysctl_nr_alloc_retry which will unconditionally
allow small allocations to fail?



Also found yet another problem. kernel worker thread seems to be stalling at
bdi_writeback_workfn() => xfs_vm_writepage() => xfs_buf_allocate_memory() =>
alloc_pages_current() => shrink_inactive_list() => congestion_wait() forever
while kswapd0 seems to be stalling at shrink_inactive_list() =>
xfs_vm_writepage() => xlog_grant_head_wait() forever.

(From http://I-love.SAKURA.ne.jp/tmp/serial-20150319-3.txt.xz )
----------
[ 1392.529392] sysrq: SysRq : Show Blocked State
[ 1392.532232]   task                        PC stack   pid father
[ 1392.535229] kswapd0         D ffff88007c3a3728     0    40      2 0x00000000
[ 1392.538916]  ffff88007c3a3728 ffff88007c5514b0 ffff88007cddac00 0000000000000008
[ 1392.543034]  0000000000000286 ffff88007ac35a42 ffff88007c3a0010 ffff88007c11fdc0
[ 1392.547234]  ffff880037af61c0 00000000000009cc 00000000000147a0 ffff88007c3a3748
[ 1392.551350] Call Trace:
[ 1392.552673]  [<ffffffff814d1aee>] schedule+0x3e/0x90
[ 1392.555285]  [<ffffffffa00f4377>] xlog_grant_head_wait+0xb7/0x1c0 [xfs]
[ 1392.558611]  [<ffffffffa00f4546>] xlog_grant_head_check+0xc6/0xe0 [xfs]
[ 1392.561938]  [<ffffffffa00f4642>] xfs_log_reserve+0xe2/0x220 [xfs]
[ 1392.565083]  [<ffffffffa00efc85>] xfs_trans_reserve+0x1e5/0x220 [xfs]
[ 1392.568312]  [<ffffffffa00efe9a>] ? _xfs_trans_alloc+0x3a/0xa0 [xfs]
[ 1392.570965]  [<ffffffffa00ca76a>] xfs_setfilesize_trans_alloc+0x4a/0xb0 [xfs]
[ 1392.572670]  [<ffffffffa00ccb15>] xfs_vm_writepage+0x4a5/0x5a0 [xfs]
[ 1392.574173]  [<ffffffff81139aac>] shrink_page_list+0x43c/0x9d0
[ 1392.575566]  [<ffffffff8113a6c5>] shrink_inactive_list+0x275/0x500
[ 1392.577084]  [<ffffffff812565c0>] ? radix_tree_gang_lookup_tag+0x90/0xd0
[ 1392.578657]  [<ffffffff8113b2e1>] shrink_lruvec+0x641/0x730
[ 1392.580093]  [<ffffffff8108098a>] ? set_next_entity+0x2a/0x60
[ 1392.581516]  [<ffffffff810aeaac>] ? lock_timer_base+0x3c/0x70
[ 1392.582915]  [<ffffffff810aed93>] ? try_to_del_timer_sync+0x53/0x70
[ 1392.584408]  [<ffffffff8113b8c5>] shrink_zone+0x75/0x1b0
[ 1392.585669]  [<ffffffff8113c19e>] kswapd+0x4de/0x9a0
[ 1392.586967]  [<ffffffff8113bcc0>] ? zone_reclaim+0x2c0/0x2c0
[ 1392.588363]  [<ffffffff8113bcc0>] ? zone_reclaim+0x2c0/0x2c0
[ 1392.589738]  [<ffffffff8106f0ae>] kthread+0xce/0xf0
[ 1392.590967]  [<ffffffff8106efe0>] ? kthread_freezable_should_stop+0x70/0x70
[ 1392.592629]  [<ffffffff814d4c88>] ret_from_fork+0x58/0x90
[ 1392.593909]  [<ffffffff8106efe0>] ? kthread_freezable_should_stop+0x70/0x70
[ 1392.595582] kworker/u16:29  D ffff88007b28e8e8     0   440      2 0x00000000
[ 1392.597428] Workqueue: writeback bdi_writeback_workfn (flush-8:0)
[ 1392.598998]  ffff88007b28e8e8 ffff88007c9288c0 ffff88007b27aa80 ffff88007b28e8e8
[ 1392.600983]  ffffffff810aed93 ffff88007fc93740 ffff88007b28c010 ffff88007d1b8000
[ 1392.603045]  000000010010ac98 ffff88007d1b8000 000000010010ac34 ffff88007b28e908
[ 1392.605052] Call Trace:
[ 1392.605698]  [<ffffffff810aed93>] ? try_to_del_timer_sync+0x53/0x70
[ 1392.607218]  [<ffffffff814d1aee>] schedule+0x3e/0x90
[ 1392.608421]  [<ffffffff814d3dc9>] schedule_timeout+0xf9/0x1a0
[ 1392.609785]  [<ffffffff810aefd0>] ? add_timer_on+0xd0/0xd0
[ 1392.611093]  [<ffffffff814d0faa>] io_schedule_timeout+0xaa/0x130
[ 1392.612599]  [<ffffffff811447af>] congestion_wait+0x7f/0x100
[ 1392.614043]  [<ffffffff8108c170>] ? woken_wake_function+0x20/0x20
[ 1392.615530]  [<ffffffff8113a8f4>] shrink_inactive_list+0x4a4/0x500
[ 1392.617051]  [<ffffffff8113b2e1>] shrink_lruvec+0x641/0x730
[ 1392.618446]  [<ffffffff8114d850>] ? list_lru_count_one+0x20/0x30
[ 1392.619926]  [<ffffffff8113b8c5>] shrink_zone+0x75/0x1b0
[ 1392.621223]  [<ffffffff8113c7f3>] do_try_to_free_pages+0x193/0x340
[ 1392.622680]  [<ffffffff8113caf7>] try_to_free_pages+0xb7/0x140
[ 1392.624074]  [<ffffffff811305bf>] __alloc_pages_nodemask+0x58f/0x9a0
[ 1392.625567]  [<ffffffff81170d87>] alloc_pages_current+0xa7/0x170
[ 1392.626992]  [<ffffffffa00d2a05>] xfs_buf_allocate_memory+0x1a5/0x290 [xfs]
[ 1392.628650]  [<ffffffffa00d3fe0>] xfs_buf_get_map+0x130/0x180 [xfs]
[ 1392.630281]  [<ffffffffa00d4060>] xfs_buf_read_map+0x30/0x100 [xfs]
[ 1392.631815]  [<ffffffffa00fffb9>] xfs_trans_read_buf_map+0xd9/0x300 [xfs]
[ 1392.633666]  [<ffffffffa00aa029>] xfs_btree_read_buf_block+0x79/0xc0 [xfs]
[ 1392.635398]  [<ffffffffa00aa274>] xfs_btree_lookup_get_block+0x84/0xf0 [xfs]
[ 1392.637112]  [<ffffffffa00aac8f>] xfs_btree_lookup+0xcf/0x4b0 [xfs]
[ 1392.638594]  [<ffffffff81179573>] ? kmem_cache_alloc+0x163/0x1d0
[ 1392.640033]  [<ffffffffa0092e39>] xfs_alloc_lookup_eq+0x19/0x20 [xfs]
[ 1392.641556]  [<ffffffffa0093155>] xfs_alloc_fixup_trees+0x2a5/0x340 [xfs]
[ 1392.643156]  [<ffffffffa0094b8d>] xfs_alloc_ag_vextent_near+0x9ad/0xb60 [xfs]
[ 1392.644850]  [<ffffffffa0095c1d>] ? xfs_alloc_fix_freelist+0x3dd/0x470 [xfs]
[ 1392.646615]  [<ffffffffa00950a5>] xfs_alloc_ag_vextent+0xd5/0x100 [xfs]
[ 1392.648262]  [<ffffffffa0095f64>] xfs_alloc_vextent+0x2b4/0x600 [xfs]
[ 1392.649855]  [<ffffffffa00a4c48>] xfs_bmap_btalloc+0x388/0x750 [xfs]
[ 1392.651412]  [<ffffffffa00a86e8>] ? xfs_bmbt_get_all+0x18/0x20 [xfs]
[ 1392.652917]  [<ffffffffa00a5034>] xfs_bmap_alloc+0x24/0x40 [xfs]
[ 1392.654343]  [<ffffffffa00a7742>] xfs_bmapi_write+0x5a2/0xa20 [xfs]
[ 1392.655846]  [<ffffffffa009e8d0>] ? xfs_bmap_last_offset+0x50/0xc0 [xfs]
[ 1392.657431]  [<ffffffffa00df6fe>] xfs_iomap_write_allocate+0x14e/0x380 [xfs]
[ 1392.659110]  [<ffffffffa00cbb79>] xfs_map_blocks+0x139/0x220 [xfs]
[ 1392.660576]  [<ffffffffa00cc7f6>] xfs_vm_writepage+0x186/0x5a0 [xfs]
[ 1392.662193]  [<ffffffff81130b47>] __writepage+0x17/0x40
[ 1392.663635]  [<ffffffff81131d57>] write_cache_pages+0x247/0x510
[ 1392.665121]  [<ffffffff81130b30>] ? set_page_dirty+0x60/0x60
[ 1392.666503]  [<ffffffff81132071>] generic_writepages+0x51/0x80
[ 1392.667966]  [<ffffffffa00cba03>] xfs_vm_writepages+0x53/0x70 [xfs]
[ 1392.669445]  [<ffffffff811320c0>] do_writepages+0x20/0x40
[ 1392.670730]  [<ffffffff811b1569>] __writeback_single_inode+0x49/0x2e0
[ 1392.672267]  [<ffffffff8108c80f>] ? wake_up_bit+0x2f/0x40
[ 1392.673681]  [<ffffffff811b1c3a>] writeback_sb_inodes+0x28a/0x4e0
[ 1392.675167]  [<ffffffff811b1f2e>] __writeback_inodes_wb+0x9e/0xd0
[ 1392.676661]  [<ffffffff811b215b>] wb_writeback+0x1fb/0x2c0
[ 1392.678000]  [<ffffffff811b22a1>] wb_do_writeback+0x81/0x1f0
[ 1392.679492]  [<ffffffff81086f3b>] ? pick_next_task_fair+0x40b/0x550
[ 1392.681076]  [<ffffffff811b2480>] bdi_writeback_workfn+0x70/0x200
[ 1392.682564]  [<ffffffff81076961>] ? dequeue_task+0x61/0x90
[ 1392.683902]  [<ffffffff8106976a>] process_one_work+0x13a/0x420
[ 1392.685287]  [<ffffffff81069b73>] worker_thread+0x123/0x4f0
[ 1392.686610]  [<ffffffff81069a50>] ? process_one_work+0x420/0x420
[ 1392.688045]  [<ffffffff81069a50>] ? process_one_work+0x420/0x420
[ 1392.689466]  [<ffffffff8106f0ae>] kthread+0xce/0xf0
[ 1392.690630]  [<ffffffff8106efe0>] ? kthread_freezable_should_stop+0x70/0x70
[ 1392.692329]  [<ffffffff814d4c88>] ret_from_fork+0x58/0x90
[ 1392.693617]  [<ffffffff8106efe0>] ? kthread_freezable_should_stop+0x70/0x70
(...snipped...)
[ 1714.888104] sysrq: SysRq : Show Blocked State
[ 1714.890786]   task                        PC stack   pid father
[ 1714.894315] kswapd0         D ffff88007c3a3728     0    40      2 0x00000000
[ 1714.898427]  ffff88007c3a3728 ffff88007c5514b0 ffff88007cddac00 0000000000000008
[ 1714.902908]  0000000000000286 ffff88007ac35a42 ffff88007c3a0010 ffff88007c11fdc0
[ 1714.907032]  ffff880037af61c0 00000000000009cc 00000000000147a0 ffff88007c3a3748
[ 1714.909212] Call Trace:
[ 1714.909909]  [<ffffffff814d1aee>] schedule+0x3e/0x90
[ 1714.911283]  [<ffffffffa00f4377>] xlog_grant_head_wait+0xb7/0x1c0 [xfs]
[ 1714.913067]  [<ffffffffa00f4546>] xlog_grant_head_check+0xc6/0xe0 [xfs]
[ 1714.914850]  [<ffffffffa00f4642>] xfs_log_reserve+0xe2/0x220 [xfs]
[ 1714.916496]  [<ffffffffa00efc85>] xfs_trans_reserve+0x1e5/0x220 [xfs]
[ 1714.918216]  [<ffffffffa00efe9a>] ? _xfs_trans_alloc+0x3a/0xa0 [xfs]
[ 1714.919904]  [<ffffffffa00ca76a>] xfs_setfilesize_trans_alloc+0x4a/0xb0 [xfs]
[ 1714.921796]  [<ffffffffa00ccb15>] xfs_vm_writepage+0x4a5/0x5a0 [xfs]
[ 1714.923484]  [<ffffffff81139aac>] shrink_page_list+0x43c/0x9d0
[ 1714.925037]  [<ffffffff8113a6c5>] shrink_inactive_list+0x275/0x500
[ 1714.926706]  [<ffffffff812565c0>] ? radix_tree_gang_lookup_tag+0x90/0xd0
[ 1714.928511]  [<ffffffff8113b2e1>] shrink_lruvec+0x641/0x730
[ 1714.930028]  [<ffffffff8108098a>] ? set_next_entity+0x2a/0x60
[ 1714.931562]  [<ffffffff810aeaac>] ? lock_timer_base+0x3c/0x70
[ 1714.933089]  [<ffffffff810aed93>] ? try_to_del_timer_sync+0x53/0x70
[ 1714.934781]  [<ffffffff8113b8c5>] shrink_zone+0x75/0x1b0
[ 1714.936197]  [<ffffffff8113c19e>] kswapd+0x4de/0x9a0
[ 1714.937549]  [<ffffffff8113bcc0>] ? zone_reclaim+0x2c0/0x2c0
[ 1714.939067]  [<ffffffff8113bcc0>] ? zone_reclaim+0x2c0/0x2c0
[ 1714.940593]  [<ffffffff8106f0ae>] kthread+0xce/0xf0
[ 1714.941908]  [<ffffffff8106efe0>] ? kthread_freezable_should_stop+0x70/0x70
[ 1714.943773]  [<ffffffff814d4c88>] ret_from_fork+0x58/0x90
[ 1714.945216]  [<ffffffff8106efe0>] ? kthread_freezable_should_stop+0x70/0x70
[ 1714.947069] kworker/u16:29  D ffff88007b28e8e8     0   440      2 0x00000000
[ 1714.949024] Workqueue: writeback bdi_writeback_workfn (flush-8:0)
[ 1714.950742]  ffff88007b28e8e8 ffff88007c9288c0 ffff88007b27aa80 ffff88007b28e8e8
[ 1714.953192]  ffffffff810aed93 0000000000000002 ffff88007b28c010 ffff88007d1b8000
[ 1714.955407]  0000000100159847 ffff88007d1b8000 00000001001597e3 ffff88007b28e908
[ 1714.957577] Call Trace:
[ 1714.958269]  [<ffffffff810aed93>] ? try_to_del_timer_sync+0x53/0x70
[ 1714.959931]  [<ffffffff814d1aee>] schedule+0x3e/0x90
[ 1714.961291]  [<ffffffff814d3dc9>] schedule_timeout+0xf9/0x1a0
[ 1714.962838]  [<ffffffff810aefd0>] ? add_timer_on+0xd0/0xd0
[ 1714.964305]  [<ffffffff814d0faa>] io_schedule_timeout+0xaa/0x130
[ 1714.965903]  [<ffffffff811447af>] congestion_wait+0x7f/0x100
[ 1714.967906]  [<ffffffff8108c170>] ? woken_wake_function+0x20/0x20
[ 1714.969604]  [<ffffffff8113a8f4>] shrink_inactive_list+0x4a4/0x500
[ 1714.971251]  [<ffffffff8113b2e1>] shrink_lruvec+0x641/0x730
[ 1714.972743]  [<ffffffff8114d850>] ? list_lru_count_one+0x20/0x30
[ 1714.974338]  [<ffffffff8113b8c5>] shrink_zone+0x75/0x1b0
[ 1714.975801]  [<ffffffff8113c7f3>] do_try_to_free_pages+0x193/0x340
[ 1714.977471]  [<ffffffff8113caf7>] try_to_free_pages+0xb7/0x140
[ 1714.979048]  [<ffffffff811305bf>] __alloc_pages_nodemask+0x58f/0x9a0
[ 1714.980734]  [<ffffffff81170d87>] alloc_pages_current+0xa7/0x170
[ 1714.982347]  [<ffffffffa00d2a05>] xfs_buf_allocate_memory+0x1a5/0x290 [xfs]
[ 1714.984239]  [<ffffffffa00d3fe0>] xfs_buf_get_map+0x130/0x180 [xfs]
[ 1714.985925]  [<ffffffffa00d4060>] xfs_buf_read_map+0x30/0x100 [xfs]
[ 1714.987611]  [<ffffffffa00fffb9>] xfs_trans_read_buf_map+0xd9/0x300 [xfs]
[ 1714.989421]  [<ffffffffa00aa029>] xfs_btree_read_buf_block+0x79/0xc0 [xfs]
[ 1714.991257]  [<ffffffffa00aa274>] xfs_btree_lookup_get_block+0x84/0xf0 [xfs]
[ 1714.993342]  [<ffffffffa00aac8f>] xfs_btree_lookup+0xcf/0x4b0 [xfs]
[ 1714.995038]  [<ffffffff81179573>] ? kmem_cache_alloc+0x163/0x1d0
[ 1714.996655]  [<ffffffffa0092e39>] xfs_alloc_lookup_eq+0x19/0x20 [xfs]
[ 1714.998429]  [<ffffffffa0093155>] xfs_alloc_fixup_trees+0x2a5/0x340 [xfs]
[ 1715.000242]  [<ffffffffa0094b8d>] xfs_alloc_ag_vextent_near+0x9ad/0xb60 [xfs]
[ 1715.002137]  [<ffffffffa0095c1d>] ? xfs_alloc_fix_freelist+0x3dd/0x470 [xfs]
[ 1715.004003]  [<ffffffffa00950a5>] xfs_alloc_ag_vextent+0xd5/0x100 [xfs]
[ 1715.005761]  [<ffffffffa0095f64>] xfs_alloc_vextent+0x2b4/0x600 [xfs]
[ 1715.007482]  [<ffffffffa00a4c48>] xfs_bmap_btalloc+0x388/0x750 [xfs]
[ 1715.009177]  [<ffffffffa00a86e8>] ? xfs_bmbt_get_all+0x18/0x20 [xfs]
[ 1715.010896]  [<ffffffffa00a5034>] xfs_bmap_alloc+0x24/0x40 [xfs]
[ 1715.012551]  [<ffffffffa00a7742>] xfs_bmapi_write+0x5a2/0xa20 [xfs]
[ 1715.014248]  [<ffffffffa009e8d0>] ? xfs_bmap_last_offset+0x50/0xc0 [xfs]
[ 1715.016071]  [<ffffffffa00df6fe>] xfs_iomap_write_allocate+0x14e/0x380 [xfs]
[ 1715.017965]  [<ffffffffa00cbb79>] xfs_map_blocks+0x139/0x220 [xfs]
[ 1715.019631]  [<ffffffffa00cc7f6>] xfs_vm_writepage+0x186/0x5a0 [xfs]
[ 1715.021345]  [<ffffffff81130b47>] __writepage+0x17/0x40
[ 1715.022762]  [<ffffffff81131d57>] write_cache_pages+0x247/0x510
[ 1715.024370]  [<ffffffff81130b30>] ? set_page_dirty+0x60/0x60
[ 1715.025885]  [<ffffffff81132071>] generic_writepages+0x51/0x80
[ 1715.027614]  [<ffffffffa00cba03>] xfs_vm_writepages+0x53/0x70 [xfs]
[ 1715.029179]  [<ffffffff811320c0>] do_writepages+0x20/0x40
[ 1715.030559]  [<ffffffff811b1569>] __writeback_single_inode+0x49/0x2e0
[ 1715.032154]  [<ffffffff8108c80f>] ? wake_up_bit+0x2f/0x40
[ 1715.033498]  [<ffffffff811b1c3a>] writeback_sb_inodes+0x28a/0x4e0
[ 1715.035025]  [<ffffffff811b1f2e>] __writeback_inodes_wb+0x9e/0xd0
[ 1715.036551]  [<ffffffff811b215b>] wb_writeback+0x1fb/0x2c0
[ 1715.037916]  [<ffffffff811b22a1>] wb_do_writeback+0x81/0x1f0
[ 1715.039317]  [<ffffffff81086f3b>] ? pick_next_task_fair+0x40b/0x550
[ 1715.040897]  [<ffffffff811b2480>] bdi_writeback_workfn+0x70/0x200
[ 1715.042415]  [<ffffffff81076961>] ? dequeue_task+0x61/0x90
[ 1715.043798]  [<ffffffff8106976a>] process_one_work+0x13a/0x420
[ 1715.045260]  [<ffffffff81069b73>] worker_thread+0x123/0x4f0
[ 1715.046665]  [<ffffffff81069a50>] ? process_one_work+0x420/0x420
[ 1715.048154]  [<ffffffff81069a50>] ? process_one_work+0x420/0x420
[ 1715.049659]  [<ffffffff8106f0ae>] kthread+0xce/0xf0
[ 1715.050880]  [<ffffffff8106efe0>] ? kthread_freezable_should_stop+0x70/0x70
[ 1715.052608]  [<ffffffff814d4c88>] ret_from_fork+0x58/0x90
[ 1715.053958]  [<ffffffff8106efe0>] ? kthread_freezable_should_stop+0x70/0x70
----------

I do want hints like http://www.spinics.net/lists/linux-mm/msg81409.html for
guessing whether forward progress is made or not. I'm fine with enabling
such hints with CONFIG_DEBUG_something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
