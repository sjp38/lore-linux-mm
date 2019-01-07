Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4E918E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 14:25:18 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id d18so910562pfe.0
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 11:25:18 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id e17si10458736pgj.142.2019.01.07.11.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 11:25:17 -0800 (PST)
Subject: Re: [PATCH] drop_caches: Allow unmapping pages
References: <20190107130239.3417-1-vincent.whitchurch@axis.com>
 <20190107141545.GX6310@bombadil.infradead.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <67dac226-00ca-dd0a-800e-0867e12d3ad5@intel.com>
Date: Mon, 7 Jan 2019 11:25:16 -0800
MIME-Version: 1.0
In-Reply-To: <20190107141545.GX6310@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Vincent Whitchurch <vincent.whitchurch@axis.com>
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mcgrof@kernel.org, keescook@chromium.org, corbet@lwn.net, linux-doc@vger.kernel.org, Vincent Whitchurch <rabinv@axis.com>

On 1/7/19 6:15 AM, Matthew Wilcox wrote:
> You're going to get data corruption doing this.  try_to_unmap_one()
> does:
> 
>          /* Move the dirty bit to the page. Now the pte is gone. */
>          if (pte_dirty(pteval))
>                  set_page_dirty(page);
> 
> so PageDirty() can be false above, but made true by calling
> try_to_unmap().

I don't think that PageDirty() check is _required_ for correctness.  You
can always safely try_to_unmap() no matter the state of the PTE.  We
can't lock out the hardware from setting the Dirty bit, ever.

It's also just fine to unmap PageDirty() pages, as long as when the PTE
is created, we move the dirty bit from the PTE into the 'struct page'
(which try_to_unmap() does, as you noticed).

> I also think the way you've done this is expedient at the cost of
> efficiency and layering violations.  I think you should first tear
> down the mappings of userspace processes (which will reclaim a lot
> of pages allocated to page tables), then you won't need to touch the
> invalidate_inode_pages paths at all.

By "tear down the mappings", do you mean something analogous to munmap()
where the VMA goes away?  Or madvise(MADV_DONTNEED) where the PTE is
destroyed but the VMA remains?

Last time I checked, we only did free_pgtables() when tearing down VMAs,
but not for pure unmappings like reclaim or MADV_DONTNEED.  I've thought
it might be fun to make a shrinker that scanned page tables looking for
zero'd pages, but I've never run into a system where empty page table
pages were actually causing a noticeable problem.
