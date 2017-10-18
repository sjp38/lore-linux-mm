Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C004B6B0260
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 13:19:43 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x82so6781175qkb.11
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 10:19:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k7si1392256qtk.147.2017.10.18.10.19.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 10:19:43 -0700 (PDT)
Date: Wed, 18 Oct 2017 20:19:40 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_balloon: fix deadlock on OOM
Message-ID: <20171018201700-mutt-send-email-mst@kernel.org>
References: <1507900754-32239-1-git-send-email-mst@redhat.com>
 <201710132306.FBC78628.OJLHFVQSFOtOMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710132306.FBC78628.OJLHFVQSFOtOMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-kernel@vger.kernel.org, mhocko@suse.com, wei.w.wang@intel.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

On Fri, Oct 13, 2017 at 11:06:23PM +0900, Tetsuo Handa wrote:
> Michael S. Tsirkin wrote:
> > This is a replacement for
> > 	[PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
> > but unlike that patch it actually deflates on oom even in presence of
> > lock contention.
> 
> But Wei Wang is proposing VIRTIO_BALLOON_F_SG which will try to allocate
> memory, isn't he?

Hopefully that can be fixed by allocating outside the lock.


> > 
> >  drivers/virtio/virtio_balloon.c    | 30 ++++++++++++++++++++++--------
> >  include/linux/balloon_compaction.h | 38 +++++++++++++++++++++++++++++++++++++-
> >  mm/balloon_compaction.c            | 27 +++++++++++++++++++++------
> >  3 files changed, 80 insertions(+), 15 deletions(-)
> > 
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > index f0b3a0b..725e366 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -143,16 +143,14 @@ static void set_page_pfns(struct virtio_balloon *vb,
> >  
> >  static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> >  {
> > -	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
> >  	unsigned num_allocated_pages;
> > +	unsigned num_pfns;
> > +	struct page *page;
> > +	LIST_HEAD(pages);
> >  
> > -	/* We can only do one array worth at a time. */
> > -	num = min(num, ARRAY_SIZE(vb->pfns));
> > -
> 
> I don't think moving this min() to later is correct, for
> "num" can be e.g. 1048576, can't it?


Good catch, will fix. Thanks!

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
> > @@ -162,6 +160,22 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> >  			msleep(200);
> >  			break;
> >  		}
> > +
> > +		balloon_page_push(&pages, page);
> > +	}
> 
> If balloon_page_alloc() did not fail, it will queue "num"
> (e.g. 1048576) pages into pages list, won't it?
> 
> > +
> > +	/* We can only do one array worth at a time. */
> > +	num = min(num, ARRAY_SIZE(vb->pfns));
> > +
> 
> Now we cap "num" to VIRTIO_BALLOON_ARRAY_PFNS_MAX (which is 256), but
> 
> > +	mutex_lock(&vb->balloon_lock);
> > +
> > +	vb->num_pfns = 0;
> > +
> > +	while ((page = balloon_page_pop(&pages))) {
> 
> this loop will repeat for e.g. 1048576 times, and
> 
> > +		balloon_page_enqueue(&vb->vb_dev_info, page);
> > +
> > +		vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE;
> > +
> 
> we increment vb->num_pfns for e.g. 1048576 times which will go
> beyond VIRTIO_BALLOON_ARRAY_PFNS_MAX array index.
> 
> >  		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> >  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> >  		if (!virtio_has_feature(vb->vdev,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
