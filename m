Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 981986B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 17:52:43 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so19106428wiv.13
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 14:52:43 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id hc7si32312370wjc.87.2014.12.01.14.52.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 14:52:42 -0800 (PST)
Date: Mon, 1 Dec 2014 17:52:34 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc patch] mm: protect set_page_dirty() from ongoing truncation
Message-ID: <20141201225234.GA4559@phnom.home.cmpxchg.org>
References: <1416944921-14164-1-git-send-email-hannes@cmpxchg.org>
 <20141126140006.d6f71f447b69cd4fadc42c26@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141126140006.d6f71f447b69cd4fadc42c26@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Nov 26, 2014 at 02:00:06PM -0800, Andrew Morton wrote:
> On Tue, 25 Nov 2014 14:48:41 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> >  The
> > same btw applies for the page_mkwrite case: how is mapping safe to
> > pass to balance_dirty_pages() after unlocking page table and page?
> 
> I'm not sure which code you're referring to here, but it's likely that
> the switch-balancing-to-bdi approach will address that as well?

This code in do_wp_page():

		pte_unmap_unlock(page_table, ptl);
[...]
		put_page(dirty_page);
		if (page_mkwrite) {
			struct address_space *mapping = dirty_page->mapping;

			set_page_dirty(dirty_page);
			unlock_page(dirty_page);
			page_cache_release(dirty_page);
			if (mapping)	{
				/*
				 * Some device drivers do not set page.mapping
				 * but still dirty their pages
				 */
				balance_dirty_pages_ratelimited(mapping);
			}
		}

And there is also this code in do_shared_fault():

	pte_unmap_unlock(pte, ptl);

	if (set_page_dirty(fault_page))
		dirtied = 1;
	mapping = fault_page->mapping;
	unlock_page(fault_page);
	if ((dirtied || vma->vm_ops->page_mkwrite) && mapping) {
		/*
		 * Some device drivers do not set page.mapping but still
		 * dirty their pages
		 */
		balance_dirty_pages_ratelimited(mapping);
	}

I don't see anything that ensures mapping stays alive by the time it's
passed to balance_dirty_pages() in either case.

Argh, but of course there is.  The mmap_sem.  That pins the vma, which
pins the file, which pins the inode.  In all cases.  So I think we can
just stick with passing mapping to balance_dirty_pages() for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
