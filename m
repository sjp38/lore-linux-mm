Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id DF6EA6B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 15:24:25 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id c10so19569987pfc.2
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 12:24:25 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id j10si6988102pap.82.2016.02.24.12.24.23
        for <linux-mm@kvack.org>;
        Wed, 24 Feb 2016 12:24:23 -0800 (PST)
Date: Wed, 24 Feb 2016 13:24:06 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 0/8] Support multi-order entries in the radix tree
Message-ID: <20160224202406.GA13473@linux.intel.com>
References: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453213533-6040-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 19, 2016 at 09:25:25AM -0500, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> In order to support huge pages in the page cache, Kirill has proposed
> simply creating 512 entries.  I think this runs into problems with
> fsync() tracking dirty bits in the radix tree.  Ross inserts a special
> entry to represent the PMD at the index for the start of the PMD, but
> this requires probing the tree twice; once for the PTE and once for the PMD.
> When we add PUD entries, that will become three times.
> 
> The approach in this patch set is to modify the radix tree to support
> multi-order entries.  Pointers to internal radix tree nodes mostly do not
> have the 'indirect' bit set.  I change that so they always have that bit
> set; then any pointer without the indirect bit set is a multi-order entry.
> 
> If the order of the entry is a multiple of the fanout of the tree,
> then all is well.  If not, it is necessary to insert alias nodes into
> the tree that point to the canonical entry.  At this point, I have not
> added support for entries which are smaller than the last-level fanout of
> the tree (and I put a BUG_ON in to prevent that usage).  Adding support
> would be a simple matter of one last pointer-chase when we get to the
> bottom of the tree, but I am not aware of any reason to add support for
> smaller multi-order entries at this point, so I haven't.
> 
> Note that no actual users are modified at this point.  I think it'd be
> mostly a matter of deleting code from the DAX fsync support at this point,
> but with that code in flux, I'm a little reluctant to add more churn
> to it.  I'm also not entriely sure where Kirill is on the page-cache
> modifications; he seems to have his hands full fixing up the MM right now.
> 
> Before diving into the important modifications, I add Andrew Morton's
> radix tree test harness to the tree in patches 1 & 2.  It was absolutely
> invaluable in catching some of my bugs.  Patches 3 & 4 are minor tweaks.
> Patches 5-7 are the interesting ones.  Patch 8 we might want to leave
> out entirely or shift over to the test harness.  I found it useful during
> debugging and others might too.
> 
> Matthew Wilcox (8):
>   radix-tree: Add an explicit include of bitops.h
>   radix tree test harness
>   radix-tree: Cleanups
>   radix_tree: Convert some variables to unsigned types
>   radix_tree: Tag all internal tree nodes as indirect pointers
>   radix_tree: Loop based on shift count, not height
>   radix_tree: Add support for multi-order entries
>   radix_tree: Add radix_tree_dump

I like the idea of this approach - I'll work on integrating it into DAX *sync.

One quick note - some of the patches are prefixed with "radix-tree" and others
with "radix_tree".

Also, if we go through the trouble of including the radix tree test harness,
should we include a new test at the end of the series that tests out
multi-order radix tree entries?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
