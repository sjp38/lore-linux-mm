Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id C43B16B0033
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 16:25:24 -0400 (EDT)
Date: Tue, 23 Apr 2013 13:25:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Message-Id: <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
In-Reply-To: <bug-56881-27@https.bugzilla.kernel.org/>
References: <bug-56881-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 20 Apr 2013 03:00:30 +0000 (UTC) bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=56881
> 
>            Summary: MAP_HUGETLB mmap fails for certain sizes
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 3.5.0-27

Thanks.

It's a post-3.4 regression, testcase included.  Does someone want to
take a look, please?

>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: akpm@linux-foundation.org
>         ReportedBy: iceman_dvd@yahoo.com
>         Regression: No
> 
> 
> This is on an Ubuntu 12.10 desktop, but the same issue has been found on 12.04
> with 3.5.0 kernel.
> See the sample program. An allocation with MAP_HUGETLB consistently fails with
> certain sizes, while it succeeds with others.
> The allocation sizes are well below the number of free huge pages.
> 
> $ uname -a Linux davide-lnx2 3.5.0-27-generic #46-Ubuntu SMP Mon Mar 25
> 19:58:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> # echo 100 > /proc/sys/vm/nr_hugepages
> 
> # cat /proc/meminfo
> ...
> AnonHugePages:         0 kB
> HugePages_Total:     100
> HugePages_Free:      100
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> 
> 
> $ ./mmappu $((5 * 2 * 1024 * 1024 - 4096))
> size=10481664    0x9ff000
> hugepage mmap: Invalid argument
> 
> 
> $ ./mmappu $((5 * 2 * 1024 * 1024 - 4095))
> size=10481665    0x9ff001
> OK!
> 
> 
> It seems the trigger point is a normal page size.
> The same binary works flawlessly in previous kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
