Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 51ADB6B0033
	for <linux-mm@kvack.org>; Tue, 21 May 2013 14:58:08 -0400 (EDT)
Message-ID: <519BC3BE.3070702@sr71.net>
Date: Tue, 21 May 2013 11:58:06 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 04/39] radix-tree: implement preload for multiple contiguous
 elements
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> Currently radix_tree_preload() only guarantees enough nodes to insert
> one element. It's a hard limit. For transparent huge page cache we want
> to insert HPAGE_PMD_NR (512 on x86-64) entires to address_space at once.

                                       ^^entries

> This patch introduces radix_tree_preload_count(). It allows to
> preallocate nodes enough to insert a number of *contiguous* elements.

Would radix_tree_preload_contig() be a better name, then?

...
> On 64-bit system:
> For RADIX_TREE_MAP_SHIFT=3, old array size is 43, new is 107.
> For RADIX_TREE_MAP_SHIFT=4, old array size is 31, new is 63.
> For RADIX_TREE_MAP_SHIFT=6, old array size is 21, new is 30.
> 
> On 32-bit system:
> For RADIX_TREE_MAP_SHIFT=3, old array size is 21, new is 84.
> For RADIX_TREE_MAP_SHIFT=4, old array size is 15, new is 46.
> For RADIX_TREE_MAP_SHIFT=6, old array size is 11, new is 19.
> 
> On most machines we will have RADIX_TREE_MAP_SHIFT=6.

Thanks for adding that to the description.  The array you're talking
about is just pointers, right?

107-43 = 64.  So, we have 64 extra pointers * NR_CPUS, plus 64 extra
radix tree nodes that we will keep around most of the time.  On x86_64,
that's 512 bytes plus 64*560 bytes of nodes which is ~35k of memory per CPU.

That's not bad I guess, but I do bet it's something that some folks want
to configure out.  Please make sure to call out the actual size cost in
bytes per CPU in future patch postings, at least for the common case
(64-bit non-CONFIG_BASE_SMALL).

> Since only THP uses batched preload at the , we disable (set max preload
> to 1) it if !CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE. This can be changed
> in the future.

"at the..."  Is there something missing in that sentence?

No major nits, so:

Acked-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
