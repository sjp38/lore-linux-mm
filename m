Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 85BE96B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 19:33:15 -0400 (EDT)
Date: Fri, 26 Aug 2011 16:32:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 40262] New: PROBLEM: I/O storm from hell on
 kernel 3.0.0 when touch swap (swapfile or partition)
Message-Id: <20110826163247.6ed99365.akpm@linux-foundation.org>
In-Reply-To: <bug-40262-10286@https.bugzilla.kernel.org/>
References: <bug-40262-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugme-daemon@bugzilla.kernel.org, g0re@null.net, StMichalke@web.de, Mel Gorman <mel@csn.ul.ie>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 28 Jul 2011 12:41:03 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=40262

Two people are reporting this - there are some additional details in
bugzilla.

We seem to be going around in circles here.

I'll ask Rafael and Maciej to track this as a regression :(

>            Summary: PROBLEM: I/O storm from hell on kernel 3.0.0 when
>                     touch swap (swapfile or partition)
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.0.0
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: g0re@null.net
>         Regression: No
> 
> 
> Created an attachment (id=66982)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=66982)
> kernel config based on ARCH linux distro
> 
> issue occurs in new kernel 3.0. 
> does not occurs in 2.6.39.3/2.6.38.8
> 
> copy a file bigger than ram size (tar/cp/scp/dd/smb , local and remote)
> load some .torrent with rtorrent (debian dvd isofiles)
> 
> observed in 3.0, the cache is not shrinking when another app request ram and
> swap occurs (mouse lag+keyboard lag+window redraw lag+ssh lag...)
> observed in 2.6.3x.y, the cache is shrinking when another app request ram
> (opera/thunderbird/seamonkey/rdesktop) and swap occurs only when the cache is
> very low (and smoothly)
> 
> tested I/O schedulers: noop deadline cfq (no difference)
> tested FS: XFS, JFS, EXT4, reiser3 (no difference)
> tested HDDs: WDC WD400BB-60JKA0 (40GB - PATA) (to test pata_via)
>              SAMSUNG SP0802N (80GB - PATA) (to test pata_via)
>          SAMSUNG HD103SI (1TB - SATA) (to test sata_via)
>              SAMSUNG HM100UX (1TB - SATA) (to test sata_via)
> 
> obs:
> nice -n 20 ionice -c3 trick does not work
> tune vfs_cache_pressure/swappiness/dirty_ratio/dirty_background_ratio does not
> help too
> 
> some nfo when storm begins
> /proc/meminfo
> MemTotal:         446532 kB
> MemFree:            5392 kB
> Buffers:            3664 kB
> Cached:           368872 kB
> SwapCached:        20412 kB
> Active:            89000 kB
> Inactive:         331392 kB
> Active(anon):      23048 kB
> Inactive(anon):    24840 kB
> Active(file):      65952 kB
> Inactive(file):   306552 kB
> Unevictable:           0 kB
> Mlocked:               0 kB
> HighTotal:             0 kB
> HighFree:              0 kB
> LowTotal:         446532 kB
> LowFree:            5392 kB
> SwapTotal:        681980 kB
> SwapFree:         600028 kB
> Dirty:                20 kB
> Writeback:             0 kB
> AnonPages:         37972 kB
> Mapped:            31592 kB
> Shmem:                16 kB
> Slab:              12304 kB
> SReclaimable:       7596 kB
> SUnreclaim:         4708 kB
> KernelStack:         696 kB
> PageTables:          960 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:      905244 kB
> Committed_AS:     187440 kB
> VmallocTotal:     573496 kB
> VmallocUsed:        5032 kB
> VmallocChunk:     565776 kB
> HardwareCorrupted:     0 kB
> AnonHugePages:         0 kB
> HugePages_Total:       0
> HugePages_Free:        0
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       4096 kB
> DirectMap4k:       24512 kB
> DirectMap4M:      434176 kB
> 
> extra: /proc/cmdline == printk.time=1 noisapnp libata.force=noncq logo.nologo
> maxcpus=4 nohz=off pci=nomsi pcie_pme=nomsi vga=normal video=vesafb:ywrap
> elevator=cfq libata.force=1.5Gbps loglevel=7
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
