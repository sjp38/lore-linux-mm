Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F02C8900138
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 07:13:41 -0400 (EDT)
Received: by fxg9 with SMTP id 9so4958794fxg.14
        for <linux-mm@kvack.org>; Sun, 28 Aug 2011 04:13:38 -0700 (PDT)
Message-ID: <4E5A22DF.1080100@openvz.org>
Date: Sun, 28 Aug 2011 15:13:35 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 40262] New: PROBLEM: I/O storm from hell on
 kernel 3.0.0 when touch swap (swapfile or partition)
References: <bug-40262-10286@https.bugzilla.kernel.org/> <20110826163247.6ed99365.akpm@linux-foundation.org>
In-Reply-To: <20110826163247.6ed99365.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "g0re@null.net" <g0re@null.net>, "StMichalke@web.de" <StMichalke@web.de>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Andrew Morton wrote:
 >
 > (switched to email.  Please respond via emailed reply-to-all, not via the
 > bugzilla web interface).
 >
 > On Thu, 28 Jul 2011 12:41:03 GMT
 > bugzilla-daemon@bugzilla.kernel.org wrote:
 >
 >> https://bugzilla.kernel.org/show_bug.cgi?id=40262
 >
 > Two people are reporting this - there are some additional details in
 > bugzilla.
 >
 > We seem to be going around in circles here.
 >
 > I'll ask Rafael and Maciej to track this as a regression :(
 >

>>
>> issue occurs in new kernel 3.0.
>> does not occurs in 2.6.39.3/2.6.38.8
>>

I guess this can be caused by commit v2.6.39-6846-g246e87a "memcg: fix vmscan count in small memcgs"
(it also tweaked kswapd besides of memcg reclaimer)
it was fixed in v3.0-5361-g4508378 "memcg: fix get_scan_count() for small targets"

commit 4508378b9523e22a2a0175d8bf64d932fb10a67d
Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date:   Tue Jul 26 16:08:24 2011 -0700

     memcg: fix vmscan count in small memcgs

     Commit 246e87a93934 ("memcg: fix get_scan_count() for small targets")
     fixes the memcg/kswapd behavior against small targets and prevent vmscan
     priority too high.

     But the implementation is too naive and adds another problem to small
     memcg.  It always force scan to 32 pages of file/anon and doesn't handle
     swappiness and other rotate_info.  It makes vmscan to scan anon LRU
     regardless of swappiness and make reclaim bad.  This patch fixes it by
     adjusting scanning count with regard to swappiness at el.

     At a test "cat 1G file under 300M limit." (swappiness=20)
      before patch
             scanned_pages_by_limit 360919
             scanned_anon_pages_by_limit 180469
             scanned_file_pages_by_limit 180450
             rotated_pages_by_limit 31
             rotated_anon_pages_by_limit 25
             rotated_file_pages_by_limit 6
             freed_pages_by_limit 180458
             freed_anon_pages_by_limit 19
             freed_file_pages_by_limit 180439
             elapsed_ns_by_limit 429758872
      after patch
             scanned_pages_by_limit 180674
             scanned_anon_pages_by_limit 24
             scanned_file_pages_by_limit 180650
             rotated_pages_by_limit 35
             rotated_anon_pages_by_limit 24
             rotated_file_pages_by_limit 11
             freed_pages_by_limit 180634
             freed_anon_pages_by_limit 0
             freed_file_pages_by_limit 180634
             elapsed_ns_by_limit 367119089
             scanned_pages_by_system 0

     the numbers of scanning anon are decreased(as expected), and elapsed time
     reduced. By this patch, small memcgs will work better.
     (*) Because the amount of file-cache is much bigger than anon,
         recalaim_stat's rotate-scan counter make scanning files more.


KAMEZAWA Hiroyuki added to CC

>> copy a file bigger than ram size (tar/cp/scp/dd/smb , local and remote)
>> load some .torrent with rtorrent (debian dvd isofiles)
>>
>> observed in 3.0, the cache is not shrinking when another app request ram and
>> swap occurs (mouse lag+keyboard lag+window redraw lag+ssh lag...)
>> observed in 2.6.3x.y, the cache is shrinking when another app request ram
>> (opera/thunderbird/seamonkey/rdesktop) and swap occurs only when the cache is
>> very low (and smoothly)
>>
>> tested I/O schedulers: noop deadline cfq (no difference)
>> tested FS: XFS, JFS, EXT4, reiser3 (no difference)
>> tested HDDs: WDC WD400BB-60JKA0 (40GB - PATA) (to test pata_via)
>>               SAMSUNG SP0802N (80GB - PATA) (to test pata_via)
>>           SAMSUNG HD103SI (1TB - SATA) (to test sata_via)
>>               SAMSUNG HM100UX (1TB - SATA) (to test sata_via)
>>
>> obs:
>> nice -n 20 ionice -c3 trick does not work
>> tune vfs_cache_pressure/swappiness/dirty_ratio/dirty_background_ratio does not
>> help too
>>
>> some nfo when storm begins
>> /proc/meminfo
>> MemTotal:         446532 kB
>> MemFree:            5392 kB
>> Buffers:            3664 kB
>> Cached:           368872 kB
>> SwapCached:        20412 kB
>> Active:            89000 kB
>> Inactive:         331392 kB
>> Active(anon):      23048 kB
>> Inactive(anon):    24840 kB
>> Active(file):      65952 kB
>> Inactive(file):   306552 kB
>> Unevictable:           0 kB
>> Mlocked:               0 kB
>> HighTotal:             0 kB
>> HighFree:              0 kB
>> LowTotal:         446532 kB
>> LowFree:            5392 kB
>> SwapTotal:        681980 kB
>> SwapFree:         600028 kB
>> Dirty:                20 kB
>> Writeback:             0 kB
>> AnonPages:         37972 kB
>> Mapped:            31592 kB
>> Shmem:                16 kB
>> Slab:              12304 kB
>> SReclaimable:       7596 kB
>> SUnreclaim:         4708 kB
>> KernelStack:         696 kB
>> PageTables:          960 kB
>> NFS_Unstable:          0 kB
>> Bounce:                0 kB
>> WritebackTmp:          0 kB
>> CommitLimit:      905244 kB
>> Committed_AS:     187440 kB
>> VmallocTotal:     573496 kB
>> VmallocUsed:        5032 kB
>> VmallocChunk:     565776 kB
>> HardwareCorrupted:     0 kB
>> AnonHugePages:         0 kB
>> HugePages_Total:       0
>> HugePages_Free:        0
>> HugePages_Rsvd:        0
>> HugePages_Surp:        0
>> Hugepagesize:       4096 kB
>> DirectMap4k:       24512 kB
>> DirectMap4M:      434176 kB
>>
>> extra: /proc/cmdline == printk.time=1 noisapnp libata.force=noncq logo.nologo
>> maxcpus=4 nohz=off pci=nomsi pcie_pme=nomsi vga=normal video=vesafb:ywrap
>> elevator=cfq libata.force=1.5Gbps loglevel=7
>>
>> ...
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
