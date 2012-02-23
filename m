Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 0EDB86B004D
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:27:00 -0500 (EST)
Date: Thu, 23 Feb 2012 14:54:17 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 0/2] speed up arch_get_unmapped_area
Message-ID: <20120223145417.261225fd@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, hughd@google.com

Many years ago, we introduced a limit on the number of VMAs per
process and set that limit to 64k, because there are processes
that end up using tens of thousands of VMAs.

Unfortunately, arch_get_unmapped_area and 
arch_get_unmapped_area_topdown have serious scalability issues
when a process has thousands of VMAs.

Luckily, it turns out those are fairly easy to fix.

I have torture tested the arch_get_unmapped_area code with a
little program that does tens of thousands of anonymous mmaps,
followed by a bunch of unmaps, followed by more maps in a loop.
The program measures the time each mmap call takes, I have run
the program in both 64 and 32 bit mode, but performance between
them is indistinguishable.

Without my patches, the average time for mmap is 242 milliseconds,
with the maximum being close to half a second.  The number of VMAs
in the process seems to vary between about 35k and 60k.

$ ./agua_frag_test_64 
..........

Min Time (ms): 4
Avg. Time (ms): 242.0000
Max Time (ms): 454
Std Dev (ms): 91.5856
Standard deviation exceeds 10

With my patches, the average time for mmap is 8 milliseconds, with
the maximum up to about 20 milliseconds in many test runs. The number
of VMAs in the process seems to vary between about 40k and 70k.

$ ./agua_frag_test_64 
..........

Min Time (ms): 5
Avg. Time (ms): 8.0000
Max Time (ms): 15
Std Dev (ms): 1.3715
All checks pass

In short, my patches introduce a little extra space overhead (about 1/8th
more virtual address space), but reduce the amount of CPU time taken by
mmap in this test case by about a factor 30.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
