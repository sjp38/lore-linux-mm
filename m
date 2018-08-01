Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 83D6D6B000E
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 07:34:47 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id v26-v6so4480308eds.9
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 04:34:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k50-v6si3432857ede.444.2018.08.01.04.34.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 04:34:46 -0700 (PDT)
Date: Wed, 1 Aug 2018 13:34:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] virtio_balloon: replace oom notifier with shrinker
Message-ID: <20180801113444.GK16767@dhcp22.suse.cz>
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
 <1532683495-31974-3-git-send-email-wei.w.wang@intel.com>
 <20180730090041.GC24267@dhcp22.suse.cz>
 <5B619599.1000307@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5B619599.1000307@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org

On Wed 01-08-18 19:12:25, Wei Wang wrote:
> On 07/30/2018 05:00 PM, Michal Hocko wrote:
> > On Fri 27-07-18 17:24:55, Wei Wang wrote:
> > > The OOM notifier is getting deprecated to use for the reasons mentioned
> > > here by Michal Hocko: https://lkml.org/lkml/2018/7/12/314
> > > 
> > > This patch replaces the virtio-balloon oom notifier with a shrinker
> > > to release balloon pages on memory pressure.
> > It would be great to document the replacement. This is not a small
> > change...
> 
> OK. I plan to document the following to the commit log:
> 
>   The OOM notifier is getting deprecated to use for the reasons:
>     - As a callout from the oom context, it is too subtle and easy to
>       generate bugs and corner cases which are hard to track;
>     - It is called too late (after the reclaiming has been performed).
>       Drivers with large amuont of reclaimable memory is expected to be
>       released them at an early age of memory pressure;
>     - The notifier callback isn't aware of the oom contrains;
>     Link: https://lkml.org/lkml/2018/7/12/314
> 
>     This patch replaces the virtio-balloon oom notifier with a shrinker
>     to release balloon pages on memory pressure. Users can set the amount of
>     memory pages to release each time a shrinker_scan is called via the
>     module parameter balloon_pages_to_shrink, and the default amount is 256
>     pages. Historically, the feature VIRTIO_BALLOON_F_DEFLATE_ON_OOM has
>     been used to release balloon pages on OOM. We continue to use this
>     feature bit for the shrinker, so the shrinker is only registered when
>     this feature bit has been negotiated with host.

Do you have any numbers for how does this work in practice? Let's say
you have a medium page cache workload which triggers kswapd to do a
light reclaim? Hardcoded shrinking sounds quite dubious to me but I have
no idea how people expect this to work. Shouldn't this be more
adaptive? How precious are those pages anyway?
-- 
Michal Hocko
SUSE Labs
