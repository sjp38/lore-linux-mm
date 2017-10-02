Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 555C16B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 10:29:52 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w63so4723000qkd.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 07:29:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r6si4637147qkb.318.2017.10.02.07.29.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 07:29:51 -0700 (PDT)
Date: Mon, 2 Oct 2017 17:29:47 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] [PATCH] mm,oom: Offload OOM notify callback to a kernel
 thread.
Message-ID: <20171002172349-mutt-send-email-mst@kernel.org>
References: <20170929065654-mutt-send-email-mst@kernel.org>
 <201709291344.FID60965.VHtMQFFJFSLOOO@I-love.SAKURA.ne.jp>
 <201710011444.IBD05725.VJSFHOOMOFtLQF@I-love.SAKURA.ne.jp>
 <20171002065801-mutt-send-email-mst@kernel.org>
 <20171002090627.547gkmzvutrsamex@dhcp22.suse.cz>
 <201710022033.GFE82801.HLOVOFFJtSFQMO@I-love.SAKURA.ne.jp>
 <20171002115035.7sph6ul6hsszdwa4@dhcp22.suse.cz>
 <20171002170642-mutt-send-email-mst@kernel.org>
 <20171002141900.acmcbilwhqethfhq@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171002141900.acmcbilwhqethfhq@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, jasowang@redhat.com, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, rodrigo.vivi@intel.com, airlied@linux.ie, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, virtualization@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org

On Mon, Oct 02, 2017 at 04:19:00PM +0200, Michal Hocko wrote:
> On Mon 02-10-17 17:11:55, Michael S. Tsirkin wrote:
> > On Mon, Oct 02, 2017 at 01:50:35PM +0200, Michal Hocko wrote:
> [...]
> > > and some
> > > other call path is allocating while holding the lock. But you seem to be
> > > right and
> > > leak_balloon
> > >   tell_host
> > >     virtqueue_add_outbuf
> > >       virtqueue_add
> > > 
> > > can do GFP_KERNEL allocation and this is clearly wrong. Nobody should
> > > try to allocate while we are in the OOM path. Michael, is there any way
> > > to drop this?
> > 
> > Yes - in practice it won't ever allocate - that path is never taken
> > with add_outbuf - it is for add_sgs only.
> > 
> > IMHO the issue is balloon inflation which needs to allocate
> > memory. It does it under a mutex, and oom handler tries to take the
> > same mutex.
> 
> try_lock for the oom notifier path should heal the problem then, righ?
> At least for as a quick fix.

IMHO it definitely fixes the deadlock. But it does not fix the bug
that balloon isn't sometimes deflated on oom even though the deflate on
oom flag is set.

> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
