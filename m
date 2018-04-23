Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE79E6B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:24:05 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u8so11057062qkg.15
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 07:24:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p13-v6si7522293qtg.64.2018.04.23.07.24.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 07:24:03 -0700 (PDT)
Date: Mon, 23 Apr 2018 10:24:02 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180422130356.GG17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804231006440.22488@file01.intranet.prod.int.rdu2.redhat.com>
References: <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net> <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org> <20180422130356.GG17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Sun, 22 Apr 2018, Michal Hocko wrote:

> On Sat 21-04-18 07:47:57, Matthew Wilcox wrote:
> 
> > > He didn't want to fix vmalloc(GFP_NOIO)
> > 
> > I don't remember that conversation, so I don't know whether I agree with
> > his reasoning or not.  But we are supposed to be moving away from GFP_NOIO
> > towards marking regions with memalloc_noio_save() / restore.  If you do
> > that, you won't need vmalloc(GFP_NOIO).
> 
> It was basically to detect GFP_NOIO context _inside_ vmalloc and use the
> scope API to enforce it there. Does it solve potential problems? Yes it
> does. Does it solve any existing report, no I am not aware of any. Is
> it a good fix longterm? Absolutely no, because the scope API should be
> used _at the place_ where the scope starts rather than a random utility
> function. If we are going the easier way now, we will never teach users
> to use the API properly. And I am willing to risk to keep a broken
> code which we have for years rather than allow a random hack that will
> seemingly fix it.
> 
> Btw. I was pretty much explicit with this reasoning when rejecting the
> patch. Do you still call that evil?

You are making nonsensical excuses.

That patch doesn't prevent you from refactoring the kernel and eliminating 
GFP_NOIO in the long term. You can apply the patch and then continue 
working on GFP_NOIO refactoring as well as before.

> > > he didn't want to fix alloc_pages sleeping when __GFP_NORETRY is used.
> > 
> > The GFP flags are a mess, still.
> 
> I do not remember that one but __GFP_NORETRY is _allowed_ to sleep. And
> yes I do _agree_ gfp flags are a mess which is really hard to get fixed
> because they are lacking a good design from the very beginning. Fixing
> some of those issues today is a completely PITA.

It may sleep, but if it sleeps regularly, it slows down swapping (because 
the swapping code does mempool_alloc and mempool_alloc does __GFP_NORETRY 
allocation). And there were two INTENTIONAL sleeps with schedule_timeout. 
You removed one and left the other, claiming that __GFP_NORETRY allocation 
should sleep.

> > > I already said that we can change it from CONFIG_DEBUG_VM to 
> > > CONFIG_DEBUG_SG - or to whatever other option you may want, just to make 
> > > sure that it is enabled in distro debug kernels by default.
> > 
> > Yes, and I think that's the right idea.  So send a v2 and ignore the
> > replies that are clearly relating to an earlier version of the patch.
> > Not everybody reads every mail in the thread before responding to one they
> > find interesting.  Yes, ideally, one would, but sometimes one doesn't.
> 
> And look here. This is yet another ad-hoc idea. We have many users of
> kvmalloc which have no relation to SG, yet you are going to control
> their behavior by CONFIG_DEBUG_SG? No way! (yeah evil again)

Why aren't you constructive and pick up pick up the CONFIG flag?

> Really, we have a fault injection framework and this sounds like
> something to hook in there.

The testing people won't set it up. They install the "kernel-debug" 
package and run the tests in it.

If you introduce a hidden option that no one knows about, no one will use 
it.

> -- 
> Michal Hocko
> SUSE Labs

Mikulas
