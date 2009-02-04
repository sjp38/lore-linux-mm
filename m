Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B06B16B003D
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 23:22:29 -0500 (EST)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch] SLQB slab allocator
Date: Wed, 4 Feb 2009 15:22:00 +1100
References: <20090114155923.GC1616@wotan.suse.de> <84144f020902031042i31eaec14v53a0e7a203acd28b@mail.gmail.com> <84144f020902031047o2e117652w28886efb495688c4@mail.gmail.com>
In-Reply-To: <84144f020902031047o2e117652w28886efb495688c4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200902041522.01307.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, Lin Ming <ming.m.lin@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 04 February 2009 05:47:48 Pekka Enberg wrote:
> On Tue, Feb 3, 2009 at 8:42 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> >> It will grow unconstrained if you elect to defer queue processing. That
> >> was what we discussed.
> >
> > Well, the slab_hiwater() check in __slab_free() of mm/slqb.c will cap
> > the size of the queue. But we do the same thing in SLAB with
> > alien->limit in cache_free_alien() and ac->limit in __cache_free(). So
> > I'm not sure what you mean when you say that the queues will "grow
> > unconstrained" (in either of the allocators). Hmm?
>
> That said, I can imagine a worst-case scenario where a queue with N
> objects is pinning N mostly empty slabs. As soon as we hit the
> periodical flush, we might need to do tons of work. That's pretty hard
> to control with watermarks as well as the scenario is solely dependent
> on allocation/free patterns.

That's very true, and we touched on this earlier. It is I guess
you can say a downside of queueing. But an analogous situation
in SLUB would be that lots of pages on the partial list with
very few free objects, or freeing objects to pages with few
objects in them. Basically SLUB will have to do the extra work
in the fastpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
