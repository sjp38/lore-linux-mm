Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 07A2D6B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 11:56:16 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so28779586wiw.2
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 08:56:15 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id wl10si35876132wjc.129.2014.12.02.08.56.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Dec 2014 08:56:14 -0800 (PST)
Date: Tue, 2 Dec 2014 11:56:07 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: memory: merge shared-writable dirtying branches
 in do_wp_page()
Message-ID: <20141202165607.GD8401@phnom.home.cmpxchg.org>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
 <1417474682-29326-3-git-send-email-hannes@cmpxchg.org>
 <20141202091939.GC9092@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141202091939.GC9092@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 02, 2014 at 10:19:39AM +0100, Jan Kara wrote:
> On Mon 01-12-14 17:58:02, Johannes Weiner wrote:
> > Whether there is a vm_ops->page_mkwrite or not, the page dirtying is
> > pretty much the same.  Make sure the page references are the same in
> > both cases, then merge the two branches.
> > 
> > It's tempting to go even further and page-lock the !page_mkwrite case,
> > to get it in line with everybody else setting the page table and thus
> > further simplify the model.  But that's not quite compelling enough to
> > justify dropping the pte lock, then relocking and verifying the entry
> > for filesystems without ->page_mkwrite, which notably includes tmpfs.
> > Leave it for now and lock the page late in the !page_mkwrite case.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/memory.c | 46 ++++++++++++++++------------------------------
> >  1 file changed, 16 insertions(+), 30 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 2a2e3648ed65..ff92abfa5303 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> ...
> > @@ -2147,42 +2147,28 @@ reuse:
> >  		pte_unmap_unlock(page_table, ptl);
> >  		ret |= VM_FAULT_WRITE;
> >  
> > -		if (!dirty_page)
> > -			return ret;
> > -
> > -		if (!page_mkwrite) {
> > +		if (dirty_shared) {
> >  			struct address_space *mapping;
> >  			int dirtied;
> >  
> > -			lock_page(dirty_page);
> > -			dirtied = set_page_dirty(dirty_page);
> > -			mapping = dirty_page->mapping;
> > -			unlock_page(dirty_page);
> > +			if (!page_mkwrite)
> > +				lock_page(old_page);
> >  
> > -			if (dirtied && mapping) {
> > -				/*
> > -				 * Some device drivers do not set page.mapping
> > -				 * but still dirty their pages
> > -				 */
> > -				balance_dirty_pages_ratelimited(mapping);
> > -			}
> > +			dirtied = set_page_dirty(old_page);
> > +			mapping = old_page->mapping;
> > +			unlock_page(old_page);
> > +			page_cache_release(old_page);
> >  
> > -			file_update_time(vma->vm_file);
> > -		}
> > -		put_page(dirty_page);
> > -		if (page_mkwrite) {
> > -			struct address_space *mapping = dirty_page->mapping;
> > -
> > -			set_page_dirty(dirty_page);
> > -			unlock_page(dirty_page);
> > -			page_cache_release(dirty_page);
> > -			if (mapping)	{
> > +			if ((dirtied || page_mkwrite) && mapping) {
>   Why do we actually call balance_dirty_pages_ratelimited() even if we
> didn't dirty the page when ->page_mkwrite() exists? Is it because
> filesystem may dirty the page in ->page_mkwrite() and we don't want it to
> deal with calling balance_dirty_pages_ratelimited()?

Yes, ->page_mkwrite() can dirty the page, but balance_dirty_pages(),
as you noted, is not allowed under the page lock.  However, it also
can't drop the page lock if that is the final set_page_dirty() as the
pte isn't dirty yet, and clear_page_dirty_for_io() relies on the pte
to be dirtied before the page outside the page lock.

That being said, the page lock semantics in there are strange.  It
seems to me that page_mkwrite semantics inherited fault semantics,
which don't allow the page lock to be dropped between verifying the
page->mapping and installing the page table, to make sure we don't map
a truncated page.  That's why when ->page_mkwrite() returns with the
page unlocked, do_page_mkwrite() locks it and verifies page->mapping,
only to hold the page lock until after the page table update is done.

However, unlike during a nopage fault, we fault against an existing
read-only pte mapping of the page, and truncation needs to unmap it.
Even if we dropped both the page lock and the pte lock, that
pte_same() check after re-locking the page table would reliably tell
us if somebody swooped in and truncated the page behind our backs.

So AFAICS ->page_mkwrite() could safely return with the page unlocked
in terms of correctness.  But OTOH if it locks the page anyway, it's
cheaper to just keep it until we need it again for set_page_dirty().
Either way, I think the truncation verification in do_page_mkwrite()
is unnecessary.

> Otherwise the patch looks good to me.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
