Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D720E6B0069
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 00:26:20 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so6997629pgc.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 21:26:20 -0800 (PST)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id u189si28121493pfu.124.2016.11.22.21.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 21:26:20 -0800 (PST)
Received: by mail-pg0-x22d.google.com with SMTP id p66so1755570pga.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 21:26:20 -0800 (PST)
Date: Tue, 22 Nov 2016 21:26:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Intel-gfx] [PATCH 2/2] drm/i915: Make GPU pages movable
In-Reply-To: <CAM0jSHPsD3+sAgK9bqDW3cm-C+PeAb-ojJq2JnEzC--HtyfMGg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1611222046510.1902@eggly.anvils>
References: <1478271776-1194-1-git-send-email-akash.goel@intel.com> <1478271776-1194-2-git-send-email-akash.goel@intel.com> <20161109112835.kivhola7ux3lw4s6@phenom.ffwll.local> <alpine.LSU.2.11.1611091034470.1547@eggly.anvils>
 <CAM0jSHPsD3+sAgK9bqDW3cm-C+PeAb-ojJq2JnEzC--HtyfMGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.william.auld@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Daniel Vetter <daniel@ffwll.ch>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Sourab Gupta <sourab.gupta@intel.com>, linux-mm@kvack.org, akash.goel@intel.com

On Tue, 22 Nov 2016, Matthew Auld wrote:
> On 9 November 2016 at 18:36, Hugh Dickins <hughd@google.com> wrote:
> > On Wed, 9 Nov 2016, Daniel Vetter wrote:
> >>
> >> Hi all -mm folks!
> >>
> >> Any feedback on these two? It's kinda an intermediate step towards a
> >> full-blown gemfs, and I think useful for that. Or do we need to go
> >> directly to our own backing storage thing? Aside from ack/nack from -mm I
> >> think this is ready for merging.
> >
> > I'm currently considering them at last: will report back later.
> >
> > Full-blown gemfs does not come in here, of course; but let me
> > fire a warning shot since you mention it: if it's going to use swap,
> > then we shall probably have to nak it in favour of continuing to use
> > infrastructure from mm/shmem.c.  I very much understand why you would
> > love to avoid that dependence, but I doubt it can be safely bypassed.
>
> Could you please elaborate on what specifically you don't like about
> gemfs implementing swap, just to make sure I'm following?

If we're talking about swap as implemented in mm/swapfile.c, and
managed for tmpfs mainly through shmem_getpage_gfp(): that's slippery
stuff, private to mm, and I would not want such trickiness duplicated
somewhere down in drivers/gpu/drm, where mm developers and drm developers
will keep on forgetting to keep it working correctly.

But you write of gemfs "implementing" swap (and I see Daniel wrote of
"our own backing storage"): perhaps you intend a disk or slow-mem file
of your own, dedicated to paging gemfs objects according to your own
rules, poked from memory reclaim via a shrinker.  I certainly don't
have the same quick objection to that: it may be a good way forward,
though I'm not at all sure (and would prefer a name distinct from
swap, so we wouldn't get confused - maybe gemswap).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
