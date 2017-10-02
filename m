Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6446B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 05:06:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p5so13525725pgn.7
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 02:06:36 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y124si7349350pgb.661.2017.10.02.02.06.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 02:06:35 -0700 (PDT)
Date: Mon, 2 Oct 2017 11:06:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel
 thread.
Message-ID: <20171002090627.547gkmzvutrsamex@dhcp22.suse.cz>
References: <201709111927.IDD00574.tFVJHLOSOOMQFF@I-love.SAKURA.ne.jp>
 <20170929065654-mutt-send-email-mst@kernel.org>
 <201709291344.FID60965.VHtMQFFJFSLOOO@I-love.SAKURA.ne.jp>
 <201710011444.IBD05725.VJSFHOOMOFtLQF@I-love.SAKURA.ne.jp>
 <20171002065801-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171002065801-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, jasowang@redhat.com, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, rodrigo.vivi@intel.com, airlied@linux.ie, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, virtualization@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org

[Hmm, I do not see the original patch which this has been a reply to]

On Mon 02-10-17 06:59:12, Michael S. Tsirkin wrote:
> On Sun, Oct 01, 2017 at 02:44:34PM +0900, Tetsuo Handa wrote:
> > Tetsuo Handa wrote:
> > > Michael S. Tsirkin wrote:
> > > > On Mon, Sep 11, 2017 at 07:27:19PM +0900, Tetsuo Handa wrote:
> > > > > Hello.
> > > > > 
> > > > > I noticed that virtio_balloon is using register_oom_notifier() and
> > > > > leak_balloon() from virtballoon_oom_notify() might depend on
> > > > > __GFP_DIRECT_RECLAIM memory allocation.
> > > > > 
> > > > > In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> > > > > serialize against fill_balloon(). But in fill_balloon(),
> > > > > alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> > > > > called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE] implies
> > > > > __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, this allocation attempt might
> > > > > depend on somebody else's __GFP_DIRECT_RECLAIM | !__GFP_NORETRY memory
> > > > > allocation. Such __GFP_DIRECT_RECLAIM | !__GFP_NORETRY allocation can reach
> > > > > __alloc_pages_may_oom() and hold oom_lock mutex and call out_of_memory().
> > > > > And leak_balloon() is called by virtballoon_oom_notify() via
> > > > > blocking_notifier_call_chain() callback when vb->balloon_lock mutex is already
> > > > > held by fill_balloon(). As a result, despite __GFP_NORETRY is specified,
> > > > > fill_balloon() can indirectly get stuck waiting for vb->balloon_lock mutex
> > > > > at leak_balloon().

This is really nasty! And I would argue that this is an abuse of the oom
notifier interface from the virtio code. OOM notifiers are an ugly hack
on its own but all its users have to be really careful to not depend on
any allocation request because that is a straight deadlock situation.

I do not think that making oom notifier API more complex is the way to
go. Can we simply change the lock to try_lock? If the lock is held we
would simply fall back to the normal OOM handling. As a follow up it
would be great if virtio could use some other form of aging e.g.
shrinker.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
