Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id EE1AD6B006E
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 17:33:20 -0400 (EDT)
Received: by dakp5 with SMTP id p5so11144630dak.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 14:33:20 -0700 (PDT)
Date: Tue, 19 Jun 2012 14:33:15 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4] mm/memblock: fix overlapping allocation when
 doubling reserved array
Message-ID: <20120619213315.GL32733@google.com>
References: <1340063278-31601-1-git-send-email-greg.pearson@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340063278-31601-1-git-send-email-greg.pearson@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Pearson <greg.pearson@hp.com>
Cc: hpa@linux.intel.com, akpm@linux-foundation.org, shangw@linux.vnet.ibm.com, mingo@elte.hu, yinghai@kernel.org, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 18, 2012 at 05:47:58PM -0600, Greg Pearson wrote:
> The __alloc_memory_core_early() routine will ask memblock for a range
> of memory then try to reserve it. If the reserved region array lacks
> space for the new range, memblock_double_array() is called to allocate
> more space for the array. If memblock is used to allocate memory for
> the new array it can end up using a range that overlaps with the range
> originally allocated in __alloc_memory_core_early(), leading to possible
> data corruption.
> 
> With this patch memblock_double_array() now calls memblock_find_in_range()
> with a narrowed candidate range (in cases where the reserved.regions array
> is being doubled) so any memory allocated will not overlap with the original
> range that was being reserved. The range is narrowed by passing in the
> starting address and size of the previously allocated range. Then the
> range above the ending address is searched and if a candidate is not
> found, the range below the starting address is searched.
> 
> Changes from v1 to v2 (based on comments from Yinghai Lu):
> - use obase instead of base in memblock_add_region() for excluding start address
> - pass in both the starting and ending address of the exclude range to
>   memblock_double_array()
> - have memblock_double_array() search above the exclude ending address
>   and below the exclude starting address for a free range
> 
> Changes from v2 to v3 (based on comments from Yinghai Lu):
> - pass in exclude_start and exclude_size to memblock_double_array()
> - only exclude a range if doubling the reserved.regions array
> - make sure narrowed range passed to memblock_find_in_range() is accessible
> - to make the code less confusing, change memblock_isolate_range() to
>   pass in exclude_start and exclude_size
> - remove unneeded comment in memblock_add_region() between while and
>   one line loop body
> 
> Changes from v3 to v4 (based on comments from Tejun Heo):
> - change parameter names passed to memblock_double_array() so they
>   are not misleading and better signify the reason why the array is
>   being doubled
> - add function comment block to memblock_double_arry() to ensure
>   the details of the possible overlap are explained
> 
> Signed-off-by: Greg Pearson <greg.pearson@hp.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>

Acked-by: Tejun Heo <tj@kernel.org>

The SOB tag from Yinghai is a bit weird tho.  SOB indicates the chain
of custody for the patch, so the above SOBs indicate that the patch is
originally from Greg and then routed (rolled into series or branch) by
Yinghai which isn't the case here.  I suppose it's either Reviewed-by:
or Acked-by:?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
