Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 77BA56B0007
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 09:04:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k16-v6so12174843wrh.6
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 06:04:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z41si5694860edb.370.2018.04.22.06.04.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 22 Apr 2018 06:04:01 -0700 (PDT)
Date: Sun, 22 Apr 2018 07:03:56 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180422130356.GG17484@dhcp22.suse.cz>
References: <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com>
 <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420130852.GC16083@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180421144757.GC14610@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180421144757.GC14610@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mikulas Patocka <mpatocka@redhat.com>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Sat 21-04-18 07:47:57, Matthew Wilcox wrote:
> On Fri, Apr 20, 2018 at 05:21:26PM -0400, Mikulas Patocka wrote:
> > On Fri, 20 Apr 2018, Matthew Wilcox wrote:
> > > On Fri, Apr 20, 2018 at 04:54:53PM -0400, Mikulas Patocka wrote:
> > > > On Fri, 20 Apr 2018, Michal Hocko wrote:
> > > > > No way. This is just wrong! First of all, you will explode most likely
> > > > > on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
> > > > > enabled quite often.
> > > > 
> > > > You're an evil person who doesn't want to fix bugs.
> > > 
> > > Steady on.  There's no need for that.  Michal isn't evil.  Please
> > > apologise.
> > 
> > I see this attitude from Michal again and again.
> 
> Fine; then *say that*.  I also see Michal saying "No" a lot.  Sometimes
> I agree with him, sometimes I don't.  I think he genuinely wants the best
> code in the kernel, and saying "No" is part of it.

Exactly! We have a lot of legacy herritage and random semantic because
we were too eager to merge stuff. I think it is time to stop that and
think twice before merging someothing. If you call that evil then I am
fine to be evil.

> > He didn't want to fix vmalloc(GFP_NOIO)
> 
> I don't remember that conversation, so I don't know whether I agree with
> his reasoning or not.  But we are supposed to be moving away from GFP_NOIO
> towards marking regions with memalloc_noio_save() / restore.  If you do
> that, you won't need vmalloc(GFP_NOIO).

It was basically to detect GFP_NOIO context _inside_ vmalloc and use the
scope API to enforce it there. Does it solve potential problems? Yes it
does. Does it solve any existing report, no I am not aware of any. Is
it a good fix longterm? Absolutely no, because the scope API should be
used _at the place_ where the scope starts rather than a random utility
function. If we are going the easier way now, we will never teach users
to use the API properly. And I am willing to risk to keep a broken
code which we have for years rather than allow a random hack that will
seemingly fix it.

Btw. I was pretty much explicit with this reasoning when rejecting the
patch. Do you still call that evil?

> > he didn't want to fix alloc_pages sleeping when __GFP_NORETRY is used.
> 
> The GFP flags are a mess, still.

I do not remember that one but __GFP_NORETRY is _allowed_ to sleep. And
yes I do _agree_ gfp flags are a mess which is really hard to get fixed
because they are lacking a good design from the very beginning. Fixing
some of those issues today is a completely PITA.

> > So what should I say? Fix them and 
> > you won't be evil :-)
> 
> No, you should reserve calling somebody evil for truly evil things.
> 
> > (he could also fix the oom killer, so that it is triggered when 
> > free_memory+cache+free_swap goes beyond a threshold and not when you loop 
> > too long in the allocator)
> 
> ... that also doesn't make somebody evil.

And again, it is way much more easier to claim that something will get
fixed when the reality is much more complicated. I've tried to explain
those risks as well.

> > I already said that we can change it from CONFIG_DEBUG_VM to 
> > CONFIG_DEBUG_SG - or to whatever other option you may want, just to make 
> > sure that it is enabled in distro debug kernels by default.
> 
> Yes, and I think that's the right idea.  So send a v2 and ignore the
> replies that are clearly relating to an earlier version of the patch.
> Not everybody reads every mail in the thread before responding to one they
> find interesting.  Yes, ideally, one would, but sometimes one doesn't.

And look here. This is yet another ad-hoc idea. We have many users of
kvmalloc which have no relation to SG, yet you are going to control
their behavior by CONFIG_DEBUG_SG? No way! (yeah evil again)

Really, we have a fault injection framework and this sounds like
something to hook in there.
-- 
Michal Hocko
SUSE Labs
