Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D25866B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 12:41:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e64so9195614pfk.0
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 09:41:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p9si765326pgq.533.2017.10.13.09.41.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Oct 2017 09:41:27 -0700 (PDT)
Subject: Re: [PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1507632457-4611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171013162134-mutt-send-email-mst@kernel.org>
In-Reply-To: <20171013162134-mutt-send-email-mst@kernel.org>
Message-Id: <201710140141.JFF26087.FLQHOFOOtFMVSJ@I-love.SAKURA.ne.jp>
Date: Sat, 14 Oct 2017 01:41:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: mhocko@kernel.org, wei.w.wang@intel.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

Michael S. Tsirkin wrote:
> On Tue, Oct 10, 2017 at 07:47:37PM +0900, Tetsuo Handa wrote:
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
> > will cause OOM lockup. Thus, do not wait for vb->balloon_lock mutex if
> > leak_balloon() is called from out_of_memory().
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
> > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> This doesn't deflate on oom if lock is contended, and we acked
> DEFLATE_ON_OOM so host actually expects us to.

I still don't understand what is wrong with not deflating on OOM.
According to https://lists.oasis-open.org/archives/virtio-dev/201504/msg00084.html ,

  If VIRTIO_BALLOON_F_DEFLATE_ON_OOM has been negotiated, the
  driver MAY use pages from the balloon when \field{num_pages}
  is less than or equal to the actual number of pages in the
  balloon if this is required for system stability
  (e.g. if memory is required by applications running within
  the guest).

it says "MAY" rather than "MUST". I think it is legal to be a no-op.
Maybe I don't understand the difference between "deflate the balloon" and
"use pages from the balloon" ?

According to https://lists.linuxfoundation.org/pipermail/virtualization/2014-October/027807.html ,
it seems to me that the expected behavior after deflating while inflating
was not defined when VIRTIO_BALLOON_F_DEFLATE_ON_OOM was proposed.

When the host increased "struct virtio_balloon_config"->num_pages and
kicked the guest, the guest's update_balloon_size_func() starts calling
fill_balloon() until "struct virtio_balloon"->num_pages reaches
"struct virtio_balloon_config"->num_pages, doesn't it?

  struct virtio_balloon_config {
  	/* Number of pages host wants Guest to give up. */
  	__u32 num_pages;
  	/* Number of pages we've actually got in balloon. */
  	__u32 actual;
  };

If leak_balloon() is called via out_of_memory(), leak_balloon()
will decrease "struct virtio_balloon"->num_pages.
But, is "struct virtio_balloon_config"->num_pages updated when
leak_balloon() is called via out_of_memory() ?
If yes, update_balloon_size_func() would stop calling fill_balloon()
when leak_balloon() was called via out_of_memory().
If no, update_balloon_size_func() would continue calling fill_balloon()
when leak_balloon() was called via out_of_memory() via fill_balloon()
via update_balloon_size_func(). That is, when fill_balloon() tries to
increase "struct virtio_balloon"->num_pages, leak_balloon() which
decreases "struct virtio_balloon"->num_pages is called due to indirect
__GFP_DIRECT_RECLAIM dependency via out_of_memory().
As a result, fill_balloon() will continue trying to increase
"struct virtio_balloon"->num_pages and leak_balloon() will continue
decreasing "struct virtio_balloon"->num_pages when leak_balloon()
is called via fill_balloon() via update_balloon_size_func() due to
host increased "struct virtio_balloon_config"->num_pages and kicked
the guest. We deflate the balloon in order to inflate the balloon.
That is OOM lockup, isn't it? How is such situation better than
invoking the OOM killer in order to inflate the balloon?

> 
> The proper fix isn't that hard - just avoid allocations under lock.
> 
> Patch posted, pls take a look.

Your patch allocates pages in order to inflate the balloon, but
your patch will allow leak_balloon() to deflate the balloon.
How deflating the balloon (i.e. calling leak_balloon()) makes sense
when allocating pages for inflating the balloon (i.e. calling
fill_balloon()) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
