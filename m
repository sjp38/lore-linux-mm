Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 8D7646B0032
	for <linux-mm@kvack.org>; Tue, 28 May 2013 07:57:18 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519E3D01.7080101@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-13-git-send-email-kirill.shutemov@linux.intel.com>
 <519BD206.3040603@sr71.net>
 <20130523143656.B8B73E0090@blue.fi.intel.com>
 <519E3D01.7080101@sr71.net>
Subject: Re: [PATCHv4 12/39] thp, mm: rewrite add_to_page_cache_locked() to
 support huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130528115946.0F1D8E0090@blue.fi.intel.com>
Date: Tue, 28 May 2013 14:59:46 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> You could create a hpagecache_nr_pages() helper or something I guess.

Makes sense.
> 
> >>> +	}
> >>> +	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
> >>> +	if (PageTransHuge(page))
> >>> +		__inc_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
> >>> +	mapping->nrpages += nr;
> >>> +	spin_unlock_irq(&mapping->tree_lock);
> >>> +	radix_tree_preload_end();
> >>> +	trace_mm_filemap_add_to_page_cache(page);
> >>> +	return 0;
> >>> +err:
> >>> +	if (i != 0)
> >>> +		error = -ENOSPC; /* no space for a huge page */
> >>> +	page_cache_release(page + i);
> >>> +	page[i].mapping = NULL;
> >>
> >> I guess it's a slight behaviour change (I think it's harmless) but if
> >> you delay doing the page_cache_get() and page[i].mapping= until after
> >> the radix tree insertion, you can avoid these two lines.
> > 
> > Hm. I don't think it's safe. The spinlock protects radix-tree against
> > modification, but find_get_page() can see it just after
> > radix_tree_insert().
> 
> Except that the mapping->tree_lock is still held.  I don't think
> find_get_page() can find it in the radix tree without taking the lock.

It can. Lookup is rcu-protected. ->tree_lock is only for add/delete/replace.

> 
> > The page is locked and IIUC never uptodate at this point, so nobody will
> > be able to do much with it, but leave it without valid ->mapping is a bad
> > idea.
> 
> ->mapping changes are protected by lock_page().  You can't keep
> ->mapping stable without holding it.  If you unlock_page(), you have to
> recheck ->mapping after you reacquire the lock.
> 
> In other words, I think the code is fine.

You are right.

> 
> >> I'm also trying to figure out how and when you'd actually have to unroll
> >> a partial-huge-page worth of radix_tree_insert().  In the small-page
> >> case, you can collide with another guy inserting in to the page cache.
> >> But, can that happen in the _middle_ of a THP?
> > 
> > E.g. if you enable THP after some uptime, the mapping can contain small pages
> > already.
> > Or if a process map the file with bad alignement (MAP_FIXED) and touch the
> > area, it will get small pages.
> 
> Could you put a comment in explaining this case a bit?  It's a bit subtle.

okay.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
