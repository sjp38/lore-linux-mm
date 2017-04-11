Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 251D26B03BA
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 14:30:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 194so558390wmq.23
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 11:30:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n124si4173912wmd.81.2017.04.11.11.30.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 11:30:41 -0700 (PDT)
Date: Tue, 11 Apr 2017 20:30:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170411183035.GD21171@dhcp22.suse.cz>
References: <20170404194220.GT15132@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
 <20170404201334.GV15132@dhcp22.suse.cz>
 <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
 <20170411134618.GN6729@dhcp22.suse.cz>
 <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
 <20170411164134.GA21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 11-04-17 13:03:01, Cristopher Lameter wrote:
> On Tue, 11 Apr 2017, Michal Hocko wrote:
> 
> > >
> > > There is a flag SLAB_DEBUG_OBJECTS that is available for this check.
> >
> > Which is way too late, at least for the kfree path. page->slab_cache
> > on anything else than PageSlab is just a garbage. And my understanding
> > of the patch objective is to stop those from happening.
> 
> We are looking here at SLAB. SLUB code can legitimately have a compound
> page there because large allocations fallback to the page allocator.
> 
> Garbage would be attempting to free a page that has !PageSLAB set but also
> is no compound page. That condition is already checked in kfree() with a
> BUG_ON() and that BUG_ON has been there for a long time.

Are you talking about SLAB or SLUB here?  The only
BUG_ON(PageSlab(page)) in SLAB I can see is in kmem_freepages and that
is way too late because we already rely on cachep which is not
trustworthy. Or am I missing some other place you have in mind?

> Certainly we can
> make SLAB consistent if there is no check there already. Slab just
> attempts a free on that object which will fail too.
> 
> So we are already handling that condition. Why change things? Add a BUG_ON
> if you want to make SLAB consistent.

I hate to repeat myself but let me do it for the last time in this
thread. BUG_ON for something that is recoverable is completely
inappropriate. And I consider kfree with a bogus pointer something that
we can easily recover from. There are other cases where the internal
state of the allocator is compromised to the point where continuing is
not possible and BUGing there is acceptable but kfree(garbage) is not
that case. 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
