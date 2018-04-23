Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74C6E6B0003
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:06:16 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l9-v6so11905333qtp.23
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 07:06:16 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d42-v6si2771547qta.379.2018.04.23.07.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 07:06:15 -0700 (PDT)
Date: Mon, 23 Apr 2018 10:06:08 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180421144757.GC14610@bombadil.infradead.org>
Message-ID: <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org> <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Sat, 21 Apr 2018, Matthew Wilcox wrote:

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
> 
> > He didn't want to fix vmalloc(GFP_NOIO)
> 
> I don't remember that conversation, so I don't know whether I agree with
> his reasoning or not.  But we are supposed to be moving away from GFP_NOIO
> towards marking regions with memalloc_noio_save() / restore.  If you do
> that, you won't need vmalloc(GFP_NOIO).

He said the same thing a year ago. And there was small progress. 6 out of 
27 __vmalloc calls were converted to memalloc_noio_save in a year - 5 in 
infiniband and 1 in btrfs. (the whole discussion is here 
http://lkml.iu.edu/hypermail/linux/kernel/1706.3/04681.html )

He refuses 15-line patch to fix GFP_NOIO bug because he believes that in 4 
years, the kernel will be refactored and GFP_NOIO will be eliminated. Why 
does he have veto over this part of the code? I'd much rather argue with 
people who have constructive comments about fixing bugs than with him.

(note that even if the refactoring eventually succeeds, it will not be 
backported to stable branches. The small vmalloc patch could be 
backported)

> > he didn't want to fix alloc_pages sleeping when __GFP_NORETRY is used.
> 
> The GFP flags are a mess, still.

That's the problem - the flag doesn't have a clear contract and the 
developers change behavior ad hoc according to bug reports.

> > So what should I say? Fix them and you won't be evil :-)
>
> No, you should reserve calling somebody evil for truly evil things.

How would you call it? Michal falsely believes that a 15-line patch would 
prevent him from doing long-term refactoring work and so he refuses it.

> > I already said that we can change it from CONFIG_DEBUG_VM to 
> > CONFIG_DEBUG_SG - or to whatever other option you may want, just to make 
> > sure that it is enabled in distro debug kernels by default.
> 
> Yes, and I think that's the right idea.  So send a v2 and ignore the
> replies that are clearly relating to an earlier version of the patch.
> Not everybody reads every mail in the thread before responding to one they
> find interesting.  Yes, ideally, one would, but sometimes one doesn't.

I sent the CONFIG_DEBUG_SG patch before (I wonder why he didn't repond to 
it). I'll send a third version of the patch that actually randomly chooses 
between kmalloc and vmalloc, because some abuses can only be detected with 
kmalloc and we should test both.

For bisecting, it is better to always fallback to vmalloc, but for general 
testing, it is better to test both branches.

Mikulas
