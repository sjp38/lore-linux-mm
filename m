Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8EBD26B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 02:37:53 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id j18-v6so3911436wme.5
        for <linux-mm@kvack.org>; Sun, 03 Jun 2018 23:37:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z12-v6si869885edi.394.2018.06.03.23.37.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Jun 2018 23:37:52 -0700 (PDT)
Date: Mon, 4 Jun 2018 08:37:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: kvmalloc does not fallback to vmalloc for
 incompatible gfp flags
Message-ID: <20180604063750.GB19202@dhcp22.suse.cz>
References: <20180601115329.27807-1-mhocko@kernel.org>
 <CA+55aFwaYEn8rA=-8hi1v8wWiLGJJsvkuEvBOxgvnmfUBfg4Vg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwaYEn8rA=-8hi1v8wWiLGJJsvkuEvBOxgvnmfUBfg4Vg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, tom@quantonium.net, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Sat 02-06-18 09:43:56, Linus Torvalds wrote:
> On Fri, Jun 1, 2018 at 4:53 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > for more context. Linus has pointed out [1] that our (well mine)
> > insisting on GFP_KERNEL compatible gfp flags for kvmalloc* can actually
> > lead to a worse code because people will work around the restriction.
> > So this patch allows kvmalloc to be more permissive and silently skip
> > vmalloc path for incompatible gfp flags.
> 
> Ack.
> 
> > This will not help my original
> > plan to enforce people to think about GFP_NOFS usage more deeply but
> > I can live with that obviously...
> 
> Is it NOFS in particular you care about?

Yes, mostly.

> The only reason for that
> should be the whole "don't recurse", and I think the naming is
> historical and slightly odd.
> 
> It was historically just about allocations that were in the writeout
> path for a block layer or filesystem - and the name made sense in that
> context. These days, I think it's just shorthand for "you can do
> simple direct reclaim from the mm itself, but you can't  block or call
> anything else".

It is still mostly used by fs code these days. There are few exceptions
though. David Chinner mentioned some DRM code which does use NOFS to
prevent recursing into their slab shrinkers.

> So I think the name and the semantics are a bit unclear, but it's
> obviously still useful.

agreed
 
> It's entirely possible that direct reclaim should never do any of the
> more complicated callback cases anyway, but we'd still need the whole
> "don't wait for the complex case" logic to avoid deadlocks.

This is problematic because we can sit on a huge amount of reclaimable
memory and the direct reclaim is the only context to trigger the oom
killer so we have to either find some other way to do the same or invoke
even the complex reclaimers. My long term plan was to convert direct NOFS
users to the scope API (see memalloc_no{fs,io}_{save,restore}) which
would mark "reclaim recursion critical sections" and all allocations
within that scope would not trigger shrinkers that could deadlock. The
current API is quite coarse but there are plans to make it more fine
grained.

Anyway, this is not directly related to this patch. Current kvmalloc
users seem to be GFP_KERNEL compliant. Let's hope it stays that way.
-- 
Michal Hocko
SUSE Labs
