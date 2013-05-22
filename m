Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 67A7A6B00AE
	for <linux-mm@kvack.org>; Wed, 22 May 2013 08:01:35 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BC3BE.3070702@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-5-git-send-email-kirill.shutemov@linux.intel.com>
 <519BC3BE.3070702@sr71.net>
Subject: Re: [PATCHv4 04/39] radix-tree: implement preload for multiple
 contiguous elements
Content-Transfer-Encoding: 7bit
Message-Id: <20130522120356.9CB12E0090@blue.fi.intel.com>
Date: Wed, 22 May 2013 15:03:56 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > This patch introduces radix_tree_preload_count(). It allows to
> > preallocate nodes enough to insert a number of *contiguous* elements.
> 
> Would radix_tree_preload_contig() be a better name, then?

Yes. Will rename.

> ...
> > On 64-bit system:
> > For RADIX_TREE_MAP_SHIFT=3, old array size is 43, new is 107.
> > For RADIX_TREE_MAP_SHIFT=4, old array size is 31, new is 63.
> > For RADIX_TREE_MAP_SHIFT=6, old array size is 21, new is 30.
> > 
> > On 32-bit system:
> > For RADIX_TREE_MAP_SHIFT=3, old array size is 21, new is 84.
> > For RADIX_TREE_MAP_SHIFT=4, old array size is 15, new is 46.
> > For RADIX_TREE_MAP_SHIFT=6, old array size is 11, new is 19.
> > 
> > On most machines we will have RADIX_TREE_MAP_SHIFT=6.
> 
> Thanks for adding that to the description.  The array you're talking
> about is just pointers, right?
> 
> 107-43 = 64.  So, we have 64 extra pointers * NR_CPUS, plus 64 extra
> radix tree nodes that we will keep around most of the time.  On x86_64,
> that's 512 bytes plus 64*560 bytes of nodes which is ~35k of memory per CPU.
> 
> That's not bad I guess, but I do bet it's something that some folks want
> to configure out.  Please make sure to call out the actual size cost in
> bytes per CPU in future patch postings, at least for the common case
> (64-bit non-CONFIG_BASE_SMALL).

I will add this to the commit message:

On most machines we will have RADIX_TREE_MAP_SHIFT=6. In this case,
on 64-bit system the per-CPU feature overhead is
 for preload array:
   (30 - 21) * sizeof(void*) = 72 bytes
 plus, if the preload array is full
   (30 - 21) * sizeof(struct radix_tree_node) = 9 * 560 = 5040 bytes
 total: 5112 bytes

on 32-bit system the per-CPU feature overhead is
 for preload array:
   (19 - 11) * sizeof(void*) = 32 bytes
 plus, if the preload array is full
   (19 - 11) * sizeof(struct radix_tree_node) = 8 * 296 = 2368 bytes
 total: 2400 bytes
---

Is it good enough?

I probably, will add !BASE_SMALL dependency to
TRANSPARENT_HUGEPAGE_PAGECACHE config option.

> 
> > Since only THP uses batched preload at the , we disable (set max preload
> > to 1) it if !CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE. This can be changed
> > in the future.
> 
> "at the..."  Is there something missing in that sentence?

at the moment :)

> No major nits, so:
> 
> Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

Thanks!

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
