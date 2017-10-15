Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 723736B0033
	for <linux-mm@kvack.org>; Sat, 14 Oct 2017 20:23:01 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o187so10656999qke.1
        for <linux-mm@kvack.org>; Sat, 14 Oct 2017 17:23:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f12si1233209qtc.279.2017.10.14.17.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Oct 2017 17:23:00 -0700 (PDT)
Date: Sun, 15 Oct 2017 03:22:57 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio: avoid possible OOM lockup at
 virtballoon_oom_notify()
Message-ID: <20171015030921-mutt-send-email-mst@kernel.org>
References: <1507632457-4611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171013162134-mutt-send-email-mst@kernel.org>
 <201710140141.JFF26087.FLQHOFOOtFMVSJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710140141.JFF26087.FLQHOFOOtFMVSJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, wei.w.wang@intel.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

On Sat, Oct 14, 2017 at 01:41:14AM +0900, Tetsuo Handa wrote:
> Michael S. Tsirkin wrote:
> > On Tue, Oct 10, 2017 at 07:47:37PM +0900, Tetsuo Handa wrote:
> > > In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> > > serialize against fill_balloon(). But in fill_balloon(),
> > > alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> > > called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
> > > implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
> > > is specified, this allocation attempt might indirectly depend on somebody
> > > else's __GFP_DIRECT_RECLAIM memory allocation. And such indirect
> > > __GFP_DIRECT_RECLAIM memory allocation might call leak_balloon() via
> > > virtballoon_oom_notify() via blocking_notifier_call_chain() callback via
> > > out_of_memory() when it reached __alloc_pages_may_oom() and held oom_lock
> > > mutex. Since vb->balloon_lock mutex is already held by fill_balloon(), it
> > > will cause OOM lockup. Thus, do not wait for vb->balloon_lock mutex if
> > > leak_balloon() is called from out_of_memory().
> > > 
> > >   Thread1                                       Thread2
> > >     fill_balloon()
> > >       takes a balloon_lock
> > >       balloon_page_enqueue()
> > >         alloc_page(GFP_HIGHUSER_MOVABLE)
> > >           direct reclaim (__GFP_FS context)       takes a fs lock
> > >             waits for that fs lock                  alloc_page(GFP_NOFS)
> > >                                                       __alloc_pages_may_oom()
> > >                                                         takes the oom_lock
> > >                                                         out_of_memory()
> > >                                                           blocking_notifier_call_chain()
> > >                                                             leak_balloon()
> > >                                                               tries to take that balloon_lock and deadlocks
> > > 
> > > Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > 
> > This doesn't deflate on oom if lock is contended, and we acked
> > DEFLATE_ON_OOM so host actually expects us to.
> 
> I still don't understand what is wrong with not deflating on OOM.

Well the point of this flag is that when it's acked,
host knows that it's safe to inflate the balloon
to a large portion of guest memory and this won't
cause an OOM situation.

Without this flag, if you inflate after OOM, then it's
fine as allocations fail, but if you inflate and then
enter OOM, balloon won't give up memory.

The flag is unfortunately hard for management tools to use
which led to it still not being supported by hosts.


> According to https://lists.oasis-open.org/archives/virtio-dev/201504/msg00084.html ,
> 
>   If VIRTIO_BALLOON_F_DEFLATE_ON_OOM has been negotiated, the
>   driver MAY use pages from the balloon when \field{num_pages}
>   is less than or equal to the actual number of pages in the
>   balloon if this is required for system stability
>   (e.g. if memory is required by applications running within
>   the guest).
> 
> it says "MAY" rather than "MUST". I think it is legal to be a no-op.
> Maybe I don't understand the difference between "deflate the balloon" and
> "use pages from the balloon" ?

Maybe we should strengthen this to SHOULD.


> According to https://lists.linuxfoundation.org/pipermail/virtualization/2014-October/027807.html ,
> it seems to me that the expected behavior after deflating while inflating
> was not defined when VIRTIO_BALLOON_F_DEFLATE_ON_OOM was proposed.

I think the assumption is that it fill back up eventually
when guest does have some free memory.

> When the host increased "struct virtio_balloon_config"->num_pages and
> kicked the guest, the guest's update_balloon_size_func() starts calling
> fill_balloon() until "struct virtio_balloon"->num_pages reaches
> "struct virtio_balloon_config"->num_pages, doesn't it?
> 
>   struct virtio_balloon_config {
>   	/* Number of pages host wants Guest to give up. */
>   	__u32 num_pages;
>   	/* Number of pages we've actually got in balloon. */
>   	__u32 actual;
>   };
> 
> If leak_balloon() is called via out_of_memory(), leak_balloon()
> will decrease "struct virtio_balloon"->num_pages.
> But, is "struct virtio_balloon_config"->num_pages updated when
> leak_balloon() is called via out_of_memory() ?
> If yes, update_balloon_size_func() would stop calling fill_balloon()
> when leak_balloon() was called via out_of_memory().
> If no, update_balloon_size_func() would continue calling fill_balloon()
> when leak_balloon() was called via out_of_memory() via fill_balloon()
> via update_balloon_size_func(). That is, when fill_balloon() tries to
> increase "struct virtio_balloon"->num_pages, leak_balloon() which
> decreases "struct virtio_balloon"->num_pages is called due to indirect
> __GFP_DIRECT_RECLAIM dependency via out_of_memory().
> As a result, fill_balloon() will continue trying to increase
> "struct virtio_balloon"->num_pages and leak_balloon() will continue
> decreasing "struct virtio_balloon"->num_pages when leak_balloon()
> is called via fill_balloon() via update_balloon_size_func() due to
> host increased "struct virtio_balloon_config"->num_pages and kicked
> the guest. We deflate the balloon in order to inflate the balloon.
> That is OOM lockup, isn't it? How is such situation better than
> invoking the OOM killer in order to inflate the balloon?

I don't think it's a lockup see below.

> > 
> > The proper fix isn't that hard - just avoid allocations under lock.
> > 
> > Patch posted, pls take a look.
> 
> Your patch allocates pages in order to inflate the balloon, but
> your patch will allow leak_balloon() to deflate the balloon.
> How deflating the balloon (i.e. calling leak_balloon()) makes sense
> when allocating pages for inflating the balloon (i.e. calling
> fill_balloon()) ?

The idea is that fill_balloon is allocating memory with __GFP_NORETRY
so it will avoid disruptive actions like the OOM killer.
Under pressure it will normally fail and retry in half a second or so.

Calling leak_balloon in that situation could benefit the system as a whole.

I might be misunderstanding the meaning of the relevant GFP flags,
pls correct me if I'm wrong.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
