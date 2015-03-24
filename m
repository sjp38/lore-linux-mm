Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 016BC6B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:51:47 -0400 (EDT)
Received: by padcy3 with SMTP id cy3so223492810pad.3
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 04:51:46 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id np3si5418494pbc.25.2015.03.24.04.51.44
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 04:51:46 -0700 (PDT)
Date: Tue, 24 Mar 2015 22:51:41 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/3] Reduce system overhead of automatic NUMA balancing
Message-ID: <20150324115141.GS28621@dastard>
References: <1427113443-20973-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427113443-20973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org

On Mon, Mar 23, 2015 at 12:24:00PM +0000, Mel Gorman wrote:
> These are three follow-on patches based on the xfsrepair workload Dave
> Chinner reported was problematic in 4.0-rc1 due to changes in page table
> management -- https://lkml.org/lkml/2015/3/1/226.
> 
> Much of the problem was reduced by commit 53da3bc2ba9e ("mm: fix up numa
> read-only thread grouping logic") and commit ba68bc0115eb ("mm: thp:
> Return the correct value for change_huge_pmd"). It was known that the performance
> in 3.19 was still better even if is far less safe. This series aims to
> restore the performance without compromising on safety.
> 
> Dave, you already tested patch 1 on its own but it would be nice to test
> patches 1+2 and 1+2+3 separately just to be certain.

			   3.19  4.0-rc4    +p1      +p2      +p3
mm_migrate_pages	266,750  572,839  558,632  223,706  201,429
run time		  4m54s    7m50s    7m20s    5m07s    4m31s

numa stats form p1+p2:

numa_hit 8436537
numa_miss 0
numa_foreign 0
numa_interleave 30765
numa_local 8409240
numa_other 27297
numa_pte_updates 46109698
numa_huge_pte_updates 0
numa_hint_faults 44756389
numa_hint_faults_local 11841095
numa_pages_migrated 4868674
pgmigrate_success 4868674
pgmigrate_fail 0


numa stats form p1+p2+p3:

numa_hit 6991596
numa_miss 0
numa_foreign 0
numa_interleave 10336
numa_local 6983144
numa_other 8452
numa_pte_updates 24460492
numa_huge_pte_updates 0
numa_hint_faults 23677262
numa_hint_faults_local 5952273
numa_pages_migrated 3557928
pgmigrate_success 3557928
pgmigrate_fail 0

OK, the summary with all patches applied:

config                          3.19   4.0-rc1  4.0-rc4  4.0-rc5+
defaults                       8m08s     9m34s    9m14s    6m57s
-o ag_stride=-1                4m04s     4m38s    4m11s    4m06s
-o bhash=101073                6m04s    17m43s    7m35s    6m13s
-o ag_stride=-1,bhash=101073   4m54s     9m58s    7m50s    4m31s

So it looks like the patch set fixes the remaining regression and in
2 of the four cases actually improves performance....

Thanks, Linus and Mel, for tracking this tricky problem down! 

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
