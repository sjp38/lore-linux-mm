Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 299446B0071
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 13:23:44 -0500 (EST)
Date: Wed, 6 Jan 2010 18:22:43 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/7] Memory compaction core
Message-ID: <20100106182243.GC5426@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-5-git-send-email-mel@csn.ul.ie> <20100106175031.GB5426@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100106175031.GB5426@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 06, 2010 at 05:50:32PM +0000, Mel Gorman wrote:
> > +		/* Found a free page, break it into order-0 pages */
> > +		isolated = split_free_page(page);
> > +		total_isolated += isolated;
> > +		for (i = 0; i < isolated; i++) {
> > +			list_add(&page->lru, freelist);
> > +			page++;
> 
> 
> > +			blockpfn += isolated - 1;
> 
> *sigh*
> 
> This increment is wrong. It pushs blockpfn forward too fast and takes fewer
> free pages than it should from that pageblock.
> 

I should point out that the consequence of this is that pages are not
being isolated properly and the free scanner moves too quickly. This
both aborts the compaction early and the end result is not as compact.

With this stupidity repaired, the results become

Starting page count: 0
Requesting at each increment: 50 huge pages
1: 50 pages Success time:0.09 rclm:8192 cblock:59 csuccess:20 alloc: 50/50
2: 100 pages Success time:0.09 rclm:3924 cblock:80 csuccess:28 alloc: 50/50
3: 150 pages Success time:0.08 rclm:4088 cblock:110 csuccess:26 alloc: 50/50
4: 200 pages Success time:0.15 rclm:4749 cblock:148 csuccess:32 alloc: 50/50
5: 250 pages Success time:0.05 rclm:7142 cblock:56 csuccess:17 alloc: 50/50
6: 300 pages Success time:0.08 rclm:6361 cblock:38 csuccess:11 alloc: 50/50
7: 350 pages Success time:0.04 rclm:6220 cblock:40 csuccess:11 alloc: 50/50
8: 400 pages Success time:0.01 rclm:1037 cblock:12 csuccess:11 alloc: 50/50
9: 450 pages Success time:0.01 rclm:203 cblock:13 csuccess:14 alloc: 50/50
10: 500 pages Success time:0.06 rclm:32 cblock:137 csuccess:33 alloc: 50/50
11: 550 pages Success time:0.03 rclm:0 cblock:67 csuccess:16 alloc: 50/50
12: 600 pages Success time:0.01 rclm:0 cblock:11 csuccess:11 alloc: 50/50
13: 650 pages Success time:0.00 rclm:0 cblock:0 csuccess:2 alloc: 50/50
14: 700 pages Success time:0.01 rclm:0 cblock:0 csuccess:5 alloc: 50/50
15: 750 pages Success time:0.00 rclm:0 cblock:0 csuccess:0 alloc: 50/50
16: 800 pages Success time:0.00 rclm:0 cblock:3 csuccess:17 alloc: 50/50
17: 850 pages Success time:0.01 rclm:0 cblock:6 csuccess:3 alloc: 50/50
18: 895 pages Success time:0.30 rclm:70 cblock:62 csuccess:16 alloc: 45/50
19: 900 pages Success time:0.39 rclm:415 cblock:78 csuccess:2 alloc: 5/50
20: 900 pages Failed time:0.09 rclm:53 cblock:48 csuccess:0
21: 902 pages Success time:0.04 rclm:0 cblock:21 csuccess:1 alloc: 2/50
22: 902 pages Failed time:0.04 rclm:0 cblock:21 csuccess:0
23: 902 pages Failed time:0.09 rclm:1017 cblock:47 csuccess:0
24: 903 pages Success time:0.04 rclm:0 cblock:22 csuccess:0 alloc: 1/50
25: 903 pages Failed time:0.58 rclm:464 cblock:67 csuccess:0
26: 911 pages Success time:0.06 rclm:0 cblock:22 csuccess:1 alloc: 8/50
27: 911 pages Failed time:0.04 rclm:0 cblock:21 csuccess:0
28: 917 pages Success time:0.86 rclm:224 cblock:94 csuccess:2 alloc: 6/50
29: 918 pages Success time:0.04 rclm:0 cblock:23 csuccess:1 alloc: 1/50
30: 918 pages Failed time:0.30 rclm:413 cblock:48 csuccess:0
31: 919 pages Success time:0.19 rclm:486 cblock:52 csuccess:0 alloc: 1/50
32: 919 pages Failed time:0.04 rclm:0 cblock:14 csuccess:0
33: 919 pages Failed time:0.23 rclm:425 cblock:52 csuccess:0
34: 919 pages Failed time:0.04 rclm:0 cblock:14 csuccess:0
35: 919 pages Failed time:0.15 rclm:420 cblock:48 csuccess:0
36: 919 pages Failed time:0.04 rclm:0 cblock:14 csuccess:0
Final page count:            919
Total pages reclaimed:       45935
Total blocks compacted:      1548
Total compact pages alloced: 280

So that it works much more as expected. Reclaims are way down, allocation
success rates are still very high.

Credit goes to Eric Munson who pointed the bug out to be on IRC.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
