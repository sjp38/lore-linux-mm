Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBB28D003B
	for <linux-mm@kvack.org>; Fri, 20 May 2011 15:53:14 -0400 (EDT)
Date: Fri, 20 May 2011 12:51:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 35512] New: firefox hang, congestion_wait
Message-Id: <20110520125147.a8baa51a.akpm@linux-foundation.org>
In-Reply-To: <bug-35512-10286@https.bugzilla.kernel.org/>
References: <bug-35512-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
Cc: bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org, urykhy@gmail.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 20 May 2011 19:45:43 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=35512
> 
>            Summary: firefox hang, congestion_wait
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 2.6.39
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: urykhy@gmail.com
>         Regression: No
> 
> 
> Created an attachment (id=58822)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=58822)
> kernel config
> 
> some times FF is hang for a long time (10..20.. and more seconds)
> 
> vmstat:
> $vmstat 1
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  0  2   1232  82508     40 503448    0    0    46    21  505 1148 15  9 66  9
>  1  2   1232  82384     40 503416    0    0     0     0  320 1424  9  5  0 86
>  0  2   1232  82384     40 503416    0    0     0     0  358  716  3  2  0 95
>  0  2   1232  82384     40 503416    0    0     0     8  705  692  3  6  0 91
>  1  2   1232  82260     40 503652    0    0   236     0  728  763  2  2  0 96
>  0  2   1232  82260     40 503652    0    0     0     0  459  620  3  1  0 96
>  0  2   1232  82260     40 503652    0    0     0     0  249  642  2  2  0 96
>  0  2   1232  82260     40 503652    0    0     0     0  250  662  2  3  0 95
>  0  2   1232  82260     40 503652    0    0     0     0  267  667  2  4  0 94
>  0  2   1232  82260     40 503652    0    0     0    16  285  707  3  1  0 96
>  0  2   1232  82260     40 503652    0    0     0     0  259  691  3  3  0 94
>  0  2   1232  82260     40 503652    0    0     0     0  254  623  2  4  0 94
>  0  2   1232  83128     40 502576    0    0     0     0  344 1473  4 10  0 86
> 
> $iostat -x 1
> avg-cpu:  %user   %nice %system %iowait  %steal   %idle
>            4,04    0,00    9,09   86,87    0,00    0,00
> 
> Device:         rrqm/s   wrqm/s     r/s     w/s   rsec/s   wsec/s avgrq-sz
> avgqu-sz   await  svctm  %util
> hda               0,00     0,00    0,00    0,00     0,00     0,00     0,00    
> 0,00    0,00   0,00   0,00
> dm-0              0,00     0,00    0,00    0,00     0,00     0,00     0,00    
> 0,00    0,00   0,00   0,00
> sda               0,00     0,00    0,00    0,00     0,00     0,00     0,00    
> 0,00    0,00   0,00   0,00
> dm-1              0,00     0,00    0,00    0,00     0,00     0,00     0,00    
> 0,00    0,00   0,00   0,00
> 
> stack:
> $cat /proc/4014/stack
> [<c108ad00>] congestion_wait+0x5a/0xae
> [<c109ba1b>] compact_zone+0xd6/0x583
> [<c109bfc3>] compact_zone_order+0x88/0x90
> [<c109c040>] try_to_compact_pages+0x75/0xc1
> [<c107ef34>] __alloc_pages_direct_compact+0x6d/0x101
> [<c107f2ee>] __alloc_pages_nodemask+0x326/0x5db
> [<c10a2ca1>] do_huge_pmd_anonymous_page+0xb4/0x293
> [<c108f6c6>] handle_mm_fault+0x72/0x129
> [<c10195e9>] do_page_fault+0x32e/0x346
> [<c12b1a09>] error_code+0x5d/0x64
> [<ffffffff>] 0xffffffff
> 
> 
> meminfo:
> $cat /proc/meminfo 
> MemTotal:        1271456 kB
> MemFree:          117988 kB
> Buffers:              40 kB
> Cached:           472048 kB
> SwapCached:          480 kB
> Active:           514172 kB
> Inactive:         531052 kB
> Active(anon):     329116 kB
> Inactive(anon):   347324 kB
> Active(file):     185056 kB
> Inactive(file):   183728 kB
> Unevictable:           4 kB
> Mlocked:               4 kB
> HighTotal:        384968 kB
> HighFree:          14476 kB
> LowTotal:         886488 kB
> LowFree:          103512 kB
> SwapTotal:       1023996 kB
> SwapFree:        1019724 kB
> Dirty:                 4 kB
> Writeback:             0 kB
> AnonPages:        572684 kB
> Mapped:            82244 kB
> Shmem:            103304 kB
> Slab:              45156 kB
> SReclaimable:      27256 kB
> SUnreclaim:        17900 kB
> KernelStack:        2160 kB
> PageTables:         3956 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:     1659724 kB
> Committed_AS:    1343792 kB
> VmallocTotal:     122880 kB
> VmallocUsed:        8004 kB
> VmallocChunk:      89032 kB
> AnonHugePages:    110592 kB
> DirectMap4k:       24568 kB
> DirectMap4M:      884736 kB
> 
> 
> what more information shoud i provide?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
