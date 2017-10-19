Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 488FF6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 07:52:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u27so5709778pfg.12
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 04:52:28 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 205si9191034pfy.38.2017.10.19.04.52.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 04:52:26 -0700 (PDT)
Subject: Re: [PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201710151438.FAD86443.tOOFHVOSFQJLMF@I-love.SAKURA.ne.jp>
	<201710161958.IAE65151.HFOLMQSFOVFJtO@I-love.SAKURA.ne.jp>
	<20171016195317-mutt-send-email-mst@kernel.org>
	<201710181959.ACI05296.JLMVQOOFtHSOFF@I-love.SAKURA.ne.jp>
	<20171018201013-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171018201013-mutt-send-email-mst@kernel.org>
Message-Id: <201710192052.JCE26064.OFtOLSFJVFQOMH@I-love.SAKURA.ne.jp>
Date: Thu, 19 Oct 2017 20:52:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: mhocko@kernel.org, wei.w.wang@intel.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, rmaksudova@parallels.com, den@openvz.org

Michael S. Tsirkin wrote:
> On Wed, Oct 18, 2017 at 07:59:23PM +0900, Tetsuo Handa wrote:
> > Do you see anything wrong with the patch I used for emulating
> > VIRTIO_BALLOON_F_DEFLATE_ON_OOM path (shown below) ?
> > 
> > ----------------------------------------
> > diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
> > index f0b3a0b..a679ac2 100644
> > --- a/drivers/virtio/virtio_balloon.c
> > +++ b/drivers/virtio/virtio_balloon.c
> > @@ -164,7 +164,7 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> >  		}
> >  		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
> >  		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
> > -		if (!virtio_has_feature(vb->vdev,
> > +		if (virtio_has_feature(vb->vdev,
> >  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> >  			adjust_managed_page_count(page, -1);
> >  	}
> > @@ -184,7 +184,7 @@ static void release_pages_balloon(struct virtio_balloon *vb,
> >  	struct page *page, *next;
> >  
> >  	list_for_each_entry_safe(page, next, pages, lru) {
> > -		if (!virtio_has_feature(vb->vdev,
> > +		if (virtio_has_feature(vb->vdev,
> >  					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> >  			adjust_managed_page_count(page, 1);
> >  		list_del(&page->lru);
> > @@ -363,7 +363,7 @@ static int virtballoon_oom_notify(struct notifier_block *self,
> >  	unsigned num_freed_pages;
> >  
> >  	vb = container_of(self, struct virtio_balloon, nb);
> > -	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> >  		return NOTIFY_OK;
> >  
> >  	freed = parm;
> > ----------------------------------------
> 
> Looks right but it's probably easier to configure qemu to set that
> feature bit. Basically you just add deflate-on-oom=on to the
> balloon device.

I'm using CentOS 7 where qemu does not recognize deflate-on-oom option. ;-)

> OK. Or if you use my patch, you can just set a flag and go
> 	if (vb->oom)
> 		msleep(1000);
> at beginning of fill_balloon.

I don't think it is a good manner to sleep for long from the point of view of
system_freezable_wq, for system_freezable_wq is expected to flush shortly
according to include/linux/workqueue.h . I think that using delayed_work is better.

> > While response was better than now, inflating again spoiled the effort.
> > Retrying to inflate until allocation fails is already too painful.
> > 
> > Michael S. Tsirkin wrote:
> > > I think that's the case. Question is, when can we inflate again?
> > 
> > I think that it is when the host explicitly asked again, for
> > VIRTIO_BALLOON_F_DEFLATE_ON_OOM path does not schedule for later inflation.
> 
> Problem is host has no idea when it's safe.
> If we expect host to ask again after X seconds we
> might just as well do it in the guest.

To me, fill_balloon() with VIRTIO_BALLOON_F_DEFLATE_ON_OOM sounds like
doing

  echo 3 > /proc/sys/vm/drop_caches

where nobody knows whether it won't impact the system.
Thus, I don't think it is a problem. It will be up to administrator
who enters that command.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
