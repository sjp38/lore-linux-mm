Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA1726B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 09:42:10 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f27so5184157ote.16
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 06:42:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i29si2474534otd.152.2017.12.01.06.42.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 06:42:09 -0800 (PST)
Date: Fri, 1 Dec 2017 16:42:01 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Memory corruption in powerpc guests with virtio_balloon (was Re:
 [PATCH v3] virtio_balloon: fix deadlock on OOM)
Message-ID: <20171201164129-mutt-send-email-mst@kernel.org>
References: <1510154064-9709-1-git-send-email-mst@redhat.com>
 <87o9nid3zn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87o9nid3zn.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Wei Wang <wei.w.wang@intel.com>, Jason Wang <jasowang@redhat.com>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Fri, Dec 01, 2017 at 11:31:08PM +1100, Michael Ellerman wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> 
> > fill_balloon doing memory allocations under balloon_lock
> > can cause a deadlock when leak_balloon is called from
> > virtballoon_oom_notify and tries to take same lock.
> >
> > To fix, split page allocation and enqueue and do allocations outside the lock.
> >
> > Here's a detailed analysis of the deadlock by Tetsuo Handa:
> >
> > In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> > serialize against fill_balloon(). But in fill_balloon(),
> > alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> > called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
> > implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
> > is specified, this allocation attempt might indirectly depend on somebody
> > else's __GFP_DIRECT_RECLAIM memory allocation. And such indirect
> > __GFP_DIRECT_RECLAIM memory allocation might call leak_balloon() via
> > virtballoon_oom_notify() via blocking_notifier_call_chain() callback via
> > out_of_memory() when it reached __alloc_pages_may_oom() and held oom_lock
> > mutex. Since vb->balloon_lock mutex is already held by fill_balloon(), it
> > will cause OOM lockup.
> >
> >   Thread1                                       Thread2
> >     fill_balloon()
> >       takes a balloon_lock
> >       balloon_page_enqueue()
> >         alloc_page(GFP_HIGHUSER_MOVABLE)
> >           direct reclaim (__GFP_FS context)       takes a fs lock
> >             waits for that fs lock                  alloc_page(GFP_NOFS)
> >                                                       __alloc_pages_may_oom()
> >                                                         takes the oom_lock
> >                                                         out_of_memory()
> >                                                           blocking_notifier_call_chain()
> >                                                             leak_balloon()
> >                                                               tries to take that balloon_lock and deadlocks
> >
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Wei Wang <wei.w.wang@intel.com>
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >
> >  drivers/virtio/virtio_balloon.c    | 24 +++++++++++++++++++-----
> >  include/linux/balloon_compaction.h | 35 ++++++++++++++++++++++++++++++++++-
> >  mm/balloon_compaction.c            | 28 +++++++++++++++++++++-------
> >  3 files changed, 74 insertions(+), 13 deletions(-)
> 
> 
> Somehow this commit seems to be killing powerpc guests.
> 
> The symptom is that the first page (64K) of the guests memory gets over
> written with zeroes, which is where our interrupt handlers are, so the
> system rapidly locks up due to illegal instructions in the illegal
> instruction handler.
> 
> There seems to be some element of a race, because it doesn't always
> crash. Sometimes I can boot to a shell, but not often. When it does
> happen it's fairly late in boot, but before I get to a shell.
> 
> I had a few bisects go off into the weeds due to the intermittent
> nature. But once I realised that I changed my script to boot 5 times
> before declaring a kernel good, and that bisected straight here.
> 
> I can also revert this commit on v4.15-rc1 and everything's fine again -
> I got through ~250 boots with that kernel.
> 
> So I'm pretty sure this commit is triggering/exposing/causing the bug.
> 
> The other data point is that the page that's overwritten is mapped read
> only in the guest kernel. So either the guest kernel is writing to it in
> real mode (MMU off), or the hypervisor/DMA is doing it.
> 
> I haven't isolated if it's host kernel/qemu version dependent, at the
> moment I'm just using distro packaged versions of both.
> 
> Anyway I'll try and dig further into it on Monday, but I thought I'd let
> you know in case this is a known bug with a fix in the pipeline, or
> rings any bells or whatever.
> 
> cheers

Thanks for the report!
A fix was just posted:
virtio_balloon: fix increment of vb->num_pfns in fill_balloon()

Would appreciate testing.

> 
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > index f0b3a0b..7960746 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -143,16 +143,17 @@ static void set_page_pfns(struct virtio_balloon *vb,
> >  
> >  static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> >  {
> > -	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
> >  	unsigned num_allocated_pages;
> > +	unsigned num_pfns;
> > +	struct page *page;
> > +	LIST_HEAD(pages);
> >  
> >  	/* We can only do one array worth at a time. */
> >  	num = min(num, ARRAY_SIZE(vb->pfns));
> >  
> > -	mutex_lock(&vb->balloon_lock);
> > -	for (vb->num_pfns = 0; vb->num_pfns < num;
> > -	     vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> > -		struct page *page = balloon_page_enqueue(vb_dev_info);
> > +	for (num_pfns = 0; num_pfns < num;
> > +	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> > +		struct page *page = balloon_page_alloc();
> >  
> >  		if (!page) {
> >  			dev_info_ratelimited(&vb->vdev->dev,
> > @@ -162,6 +163,19 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> >  			msleep(200);
> >  			break;
> >  		}
> > +
> > +		balloon_page_push(&pages, page);
> > +	}
> > +
> > +	mutex_lock(&vb->balloon_lock);
> > +
> > +	vb->num_pfns = 0;
> > +
> > +	while ((page = balloon_page_pop(&pages))) {
> > +		balloon_page_enqueue(&vb->vb_dev_info, page);
> > +
> > +		vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE;
> > +
> >  		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> >  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> >  		if (!virtio_has_feature(vb->vdev,
> > diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> > index fbbe6da..c4c8df9 100644
> > --- a/include/linux/balloon_compaction.h
> > +++ b/include/linux/balloon_compaction.h
> > @@ -50,6 +50,7 @@
> >  #include <linux/gfp.h>
> >  #include <linux/err.h>
> >  #include <linux/fs.h>
> > +#include <linux/list.h>
> >  
> >  /*
> >   * Balloon device information descriptor.
> > @@ -67,7 +68,9 @@ struct balloon_dev_info {
> >  	struct inode *inode;
> >  };
> >  
> > -extern struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info);
> > +extern struct page *balloon_page_alloc(void);
> > +extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
> > +				 struct page *page);
> >  extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
> >  
> >  static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
> > @@ -89,6 +92,36 @@ extern int balloon_page_migrate(struct address_space *mapping,
> >  				struct page *page, enum migrate_mode mode);
> >  
> >  /*
> > + * balloon_page_push - insert a page into a page list.
> > + * @head : pointer to list
> > + * @page : page to be added
> > + *
> > + * Caller must ensure the page is private and protect the list.
> > + */
> > +static inline void balloon_page_push(struct list_head *pages, struct page *page)
> > +{
> > +	list_add(&page->lru, pages);
> > +}
> > +
> > +/*
> > + * balloon_page_pop - remove a page from a page list.
> > + * @head : pointer to list
> > + * @page : page to be added
> > + *
> > + * Caller must ensure the page is private and protect the list.
> > + */
> > +static inline struct page *balloon_page_pop(struct list_head *pages)
> > +{
> > +	struct page *page = list_first_entry_or_null(pages, struct page, lru);
> > +
> > +	if (!page)
> > +		return NULL;
> > +
> > +	list_del(&page->lru);
> > +	return page;
> > +}
> > +
> > +/*
> >   * balloon_page_insert - insert a page into the balloon's page list and make
> >   *			 the page->private assignment accordingly.
> >   * @balloon : pointer to balloon device
> > diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> > index 68d2892..ef858d5 100644
> > --- a/mm/balloon_compaction.c
> > +++ b/mm/balloon_compaction.c
> > @@ -11,22 +11,37 @@
> >  #include <linux/balloon_compaction.h>
> >  
> >  /*
> > + * balloon_page_alloc - allocates a new page for insertion into the balloon
> > + *			  page list.
> > + *
> > + * Driver must call it to properly allocate a new enlisted balloon page.
> > + * Driver must call balloon_page_enqueue before definitively removing it from
> > + * the guest system.  This function returns the page address for the recently
> > + * allocated page or NULL in the case we fail to allocate a new page this turn.
> > + */
> > +struct page *balloon_page_alloc(void)
> > +{
> > +	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
> > +				       __GFP_NOMEMALLOC | __GFP_NORETRY);
> > +	return page;
> > +}
> > +EXPORT_SYMBOL_GPL(balloon_page_alloc);
> > +
> > +/*
> >   * balloon_page_enqueue - allocates a new page and inserts it into the balloon
> >   *			  page list.
> >   * @b_dev_info: balloon device descriptor where we will insert a new page to
> > + * @page: new page to enqueue - allocated using balloon_page_alloc.
> >   *
> > - * Driver must call it to properly allocate a new enlisted balloon page
> > + * Driver must call it to properly enqueue a new allocated balloon page
> >   * before definitively removing it from the guest system.
> >   * This function returns the page address for the recently enqueued page or
> >   * NULL in the case we fail to allocate a new page this turn.
> >   */
> > -struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
> > +void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
> > +			  struct page *page)
> >  {
> >  	unsigned long flags;
> > -	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
> > -				       __GFP_NOMEMALLOC | __GFP_NORETRY);
> > -	if (!page)
> > -		return NULL;
> >  
> >  	/*
> >  	 * Block others from accessing the 'page' when we get around to
> > @@ -39,7 +54,6 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
> >  	__count_vm_event(BALLOON_INFLATE);
> >  	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> >  	unlock_page(page);
> > -	return page;
> >  }
> >  EXPORT_SYMBOL_GPL(balloon_page_enqueue);
> >  
> > -- 
> > MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
