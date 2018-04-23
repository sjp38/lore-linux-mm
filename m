Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D43E16B0007
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:15:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q15so10714921pff.15
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:15:54 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x15-v6si8279411plr.391.2018.04.23.08.15.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 08:15:53 -0700 (PDT)
Date: Mon, 23 Apr 2018 09:15:45 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180423151545.GU17484@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420130852.GC16083@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180421144757.GC14610@bombadil.infradead.org>
 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Mon 23-04-18 10:06:08, Mikulas Patocka wrote:
> 
> 
> On Sat, 21 Apr 2018, Matthew Wilcox wrote:
> 
> > On Fri, Apr 20, 2018 at 05:21:26PM -0400, Mikulas Patocka wrote:
> > > On Fri, 20 Apr 2018, Matthew Wilcox wrote:
> > > > On Fri, Apr 20, 2018 at 04:54:53PM -0400, Mikulas Patocka wrote:
> > > > > On Fri, 20 Apr 2018, Michal Hocko wrote:
> > > > > > No way. This is just wrong! First of all, you will explode most likely
> > > > > > on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
> > > > > > enabled quite often.
> > > > > 
> > > > > You're an evil person who doesn't want to fix bugs.
> > > > 
> > > > Steady on.  There's no need for that.  Michal isn't evil.  Please
> > > > apologise.
> > > 
> > > I see this attitude from Michal again and again.
> > 
> > Fine; then *say that*.  I also see Michal saying "No" a lot.  Sometimes
> > I agree with him, sometimes I don't.  I think he genuinely wants the best
> > code in the kernel, and saying "No" is part of it.
> > 
> > > He didn't want to fix vmalloc(GFP_NOIO)
> > 
> > I don't remember that conversation, so I don't know whether I agree with
> > his reasoning or not.  But we are supposed to be moving away from GFP_NOIO
> > towards marking regions with memalloc_noio_save() / restore.  If you do
> > that, you won't need vmalloc(GFP_NOIO).
> 
> He said the same thing a year ago. And there was small progress. 6 out of 
> 27 __vmalloc calls were converted to memalloc_noio_save in a year - 5 in 
> infiniband and 1 in btrfs. (the whole discussion is here 
> http://lkml.iu.edu/hypermail/linux/kernel/1706.3/04681.html )

Well this is not that easy. It requires a cooperation from maintainers.
I can only do as much. I've posted patches in the past and actively
bringing up this topic at LSFMM last two years...

> He refuses 15-line patch to fix GFP_NOIO bug because he believes that in 4 
> years, the kernel will be refactored and GFP_NOIO will be eliminated. Why 
> does he have veto over this part of the code? I'd much rather argue with 
> people who have constructive comments about fixing bugs than with him.

I didn't NACK the patch AFAIR. I've said it is not a good idea longterm.
I would be much more willing to change my mind if you would back your
patch by a real bug report. Hacks are acceptable when we have a real
issue in hands. But if we want to fix potential issue then better make
it properly.

[...]

> I sent the CONFIG_DEBUG_SG patch before (I wonder why he didn't repond to 
> it). I'll send a third version of the patch that actually randomly chooses 
> between kmalloc and vmalloc, because some abuses can only be detected with 
> kmalloc and we should test both.
> 
> For bisecting, it is better to always fallback to vmalloc, but for general 
> testing, it is better to test both branches.

Agreed!

-- 
Michal Hocko
SUSE Labs
