Subject: Re: [PATCH 2/2] Updating ctime and mtime at syncing
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <4df4ef0c0801150918l71504c81s49fc8c9e427896f3@mail.gmail.com>
References: <12004129652397-git-send-email-salikhmetov@gmail.com>
	 <1200412978699-git-send-email-salikhmetov@gmail.com>
	 <1200414911.26045.32.camel@twins>
	 <4df4ef0c0801150918l71504c81s49fc8c9e427896f3@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 15 Jan 2008 20:30:20 +0100
Message-Id: <1200425420.26045.42.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

On Tue, 2008-01-15 at 20:18 +0300, Anton Salikhmetov wrote:
> 2008/1/15, Peter Zijlstra <a.p.zijlstra@chello.nl>:
> >
> > On Tue, 2008-01-15 at 19:02 +0300, Anton Salikhmetov wrote:
> >
> > > diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> > > index 3d3848f..53d0e34 100644
> > > --- a/mm/page-writeback.c
> > > +++ b/mm/page-writeback.c
> > > @@ -997,35 +997,39 @@ int __set_page_dirty_no_writeback(struct page *page)
> > >   */
> > >  int __set_page_dirty_nobuffers(struct page *page)
> > >  {
> > > -     if (!TestSetPageDirty(page)) {
> > > -             struct address_space *mapping = page_mapping(page);
> > > -             struct address_space *mapping2;
> > > +     struct address_space *mapping = page_mapping(page);
> > > +     struct address_space *mapping2;
> > >
> > > -             if (!mapping)
> > > -                     return 1;
> > > +     if (!mapping)
> > > +             return 1;
> > >
> > > -             write_lock_irq(&mapping->tree_lock);
> > > -             mapping2 = page_mapping(page);
> > > -             if (mapping2) { /* Race with truncate? */
> > > -                     BUG_ON(mapping2 != mapping);
> > > -                     WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
> > > -                     if (mapping_cap_account_dirty(mapping)) {
> > > -                             __inc_zone_page_state(page, NR_FILE_DIRTY);
> > > -                             __inc_bdi_stat(mapping->backing_dev_info,
> > > -                                             BDI_RECLAIMABLE);
> > > -                             task_io_account_write(PAGE_CACHE_SIZE);
> > > -                     }
> > > -                     radix_tree_tag_set(&mapping->page_tree,
> > > -                             page_index(page), PAGECACHE_TAG_DIRTY);
> > > -             }
> > > -             write_unlock_irq(&mapping->tree_lock);
> > > -             if (mapping->host) {
> > > -                     /* !PageAnon && !swapper_space */
> > > -                     __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> > > +     mapping->mtime = CURRENT_TIME;
> > > +     set_bit(AS_MCTIME, &mapping->flags);
> >
> > This seems vulnerable to the race we have against truncate, handled by
> > the mapping2 magic below. Do we care?
> >
> > > +
> > > +     if (TestSetPageDirty(page))
> > > +             return 0;
> > > +
> > > +     write_lock_irq(&mapping->tree_lock);
> > > +     mapping2 = page_mapping(page);
> > > +     if (mapping2) {
> > > +             /* Race with truncate? */
> > > +             BUG_ON(mapping2 != mapping);
> > > +             WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
> > > +             if (mapping_cap_account_dirty(mapping)) {
> > > +                     __inc_zone_page_state(page, NR_FILE_DIRTY);
> > > +                     __inc_bdi_stat(mapping->backing_dev_info,
> > > +                                     BDI_RECLAIMABLE);
> > > +                     task_io_account_write(PAGE_CACHE_SIZE);
> > >               }
> > > -             return 1;
> > > +             radix_tree_tag_set(&mapping->page_tree,
> > > +                             page_index(page), PAGECACHE_TAG_DIRTY);
> > >       }
> > > -     return 0;
> > > +     write_unlock_irq(&mapping->tree_lock);
> > > +
> > > +     if (mapping->host)
> > > +             __mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
> 
> The inode gets marked dirty using the same "mapping" variable
> as my code does. So, AFAIU, my change does not introduce any new
> vulnerabilities. I would nevertherless be grateful to you for a scenario
> where the race would be triggered.

Ah, right, so that would be a resounding no to my previous question :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
