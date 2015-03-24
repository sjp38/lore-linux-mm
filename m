Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id AC6E66B006C
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:33:13 -0400 (EDT)
Received: by wegp1 with SMTP id p1so166334371weg.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:33:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pd4si17623493wic.0.2015.03.24.08.33.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 08:33:11 -0700 (PDT)
Date: Tue, 24 Mar 2015 15:33:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] Reduce system overhead of automatic NUMA balancing
Message-ID: <20150324153306.GG4701@suse.de>
References: <1427113443-20973-1-git-send-email-mgorman@suse.de>
 <20150324115141.GS28621@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150324115141.GS28621@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, linuxppc-dev@lists.ozlabs.org

On Tue, Mar 24, 2015 at 10:51:41PM +1100, Dave Chinner wrote:
> On Mon, Mar 23, 2015 at 12:24:00PM +0000, Mel Gorman wrote:
> > These are three follow-on patches based on the xfsrepair workload Dave
> > Chinner reported was problematic in 4.0-rc1 due to changes in page table
> > management -- https://lkml.org/lkml/2015/3/1/226.
> > 
> > Much of the problem was reduced by commit 53da3bc2ba9e ("mm: fix up numa
> > read-only thread grouping logic") and commit ba68bc0115eb ("mm: thp:
> > Return the correct value for change_huge_pmd"). It was known that the performance
> > in 3.19 was still better even if is far less safe. This series aims to
> > restore the performance without compromising on safety.
> > 
> > Dave, you already tested patch 1 on its own but it would be nice to test
> > patches 1+2 and 1+2+3 separately just to be certain.
> 
> 			   3.19  4.0-rc4    +p1      +p2      +p3
> mm_migrate_pages	266,750  572,839  558,632  223,706  201,429
> run time		  4m54s    7m50s    7m20s    5m07s    4m31s
> 

Excellent, this is in line with predictions and roughly matches what I
was seeing on bare metal + real NUMA + spinning disk instead of KVM +
fake NUMA + SSD.

Editting slightly;

> numa stats form p1+p2:    numa_pte_updates 46109698
> numa stats form p1+p2+p3: numa_pte_updates 24460492

The big drop in PTE updates matches what I expected -- migration
failures should not lead to increased scan rates which is what patch 3
fixes. I'm also pleased that there was not a drop in performance.

> 
> OK, the summary with all patches applied:
> 
> config                          3.19   4.0-rc1  4.0-rc4  4.0-rc5+
> defaults                       8m08s     9m34s    9m14s    6m57s
> -o ag_stride=-1                4m04s     4m38s    4m11s    4m06s
> -o bhash=101073                6m04s    17m43s    7m35s    6m13s
> -o ag_stride=-1,bhash=101073   4m54s     9m58s    7m50s    4m31s
> 
> So it looks like the patch set fixes the remaining regression and in
> 2 of the four cases actually improves performance....
> 

\o/

Linus, these three patches plus the small fixlet for pmd_mkyoung (to match
pte_mkyoung) is already in Andrew's tree. I'm expecting it'll arrive to
you before 4.0 assuming nothing else goes pear shaped.

> Thanks, Linus and Mel, for tracking this tricky problem down! 
> 

Thanks Dave for persisting with this and collecting the necessary data.
FWIW, I've marked the xfsrepair test case as a "large memory test".
It'll take time before the test machines have historical data for it but
in theory if this regresses again then I should spot it eventually.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
