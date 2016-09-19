Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 855F96B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 10:39:21 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b130so6624178wmc.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 07:39:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si23532114wjt.255.2016.09.19.07.39.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Sep 2016 07:39:20 -0700 (PDT)
Date: Mon, 19 Sep 2016 16:39:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: More OOM problems
Message-ID: <20160919143915.GS10785@dhcp22.suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
 <87twdc4rzs.fsf@tassilo.jf.intel.com>
 <alpine.DEB.2.20.1609190836540.12121@east.gentwo.org>
 <20160919143106.GX5871@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160919143106.GX5871@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Mon 19-09-16 07:31:06, Andi Kleen wrote:
> On Mon, Sep 19, 2016 at 08:37:36AM -0500, Christoph Lameter wrote:
> > On Sun, 18 Sep 2016, Andi Kleen wrote:
> > 
> > > > Sounds like SLUB. SLAB would use order-0 as long as things fit. I would
> > > > hope for SLUB to fallback to order-0 (or order-1 for 8kB) instead of
> > > > OOM, though. Guess not...
> > >
> > > It's already trying to do that, perhaps just some flags need to be
> > > changed?
> > 
> > SLUB tries order-N and falls back to order 0 on failure.
> 
> Right it tries, but Linus apparently got an OOM in the order-N
> allocation. So somehow the flag combination that it passes first
> is not preventing the OOM killer.

It does AFAICS:
	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
	if ((alloc_gfp & __GFP_DIRECT_RECLAIM) && oo_order(oo) > oo_order(s->min))
		alloc_gfp = (alloc_gfp | __GFP_NOMEMALLOC) & ~(__GFP_RECLAIM|__GFP_NOFAIL);

	page = alloc_slab_page(s, alloc_gfp, node, oo);
	if (unlikely(!page)) {
		oo = s->min;
		alloc_gfp = flags;
		/*
		 * Allocation may have failed due to fragmentation.
		 * Try a lower order alloc if possible
		 */
		page = alloc_slab_page(s, alloc_gfp, node, oo);

I think that Linus just see a genuine order-3 request
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
