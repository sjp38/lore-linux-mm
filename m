Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 66A516B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 17:21:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h9-v6so5907023qti.19
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 14:21:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r41-v6si9197612qtc.165.2018.04.20.14.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 14:21:27 -0700 (PDT)
Date: Fri, 20 Apr 2018 17:21:26 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180420210200.GH10788@bombadil.infradead.org>
Message-ID: <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Fri, 20 Apr 2018, Matthew Wilcox wrote:

> On Fri, Apr 20, 2018 at 04:54:53PM -0400, Mikulas Patocka wrote:
> > On Fri, 20 Apr 2018, Michal Hocko wrote:
> > > No way. This is just wrong! First of all, you will explode most likely
> > > on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
> > > enabled quite often.
> > 
> > You're an evil person who doesn't want to fix bugs.
> 
> Steady on.  There's no need for that.  Michal isn't evil.  Please
> apologise.

I see this attitude from Michal again and again.

He didn't want to fix vmalloc(GFP_NOIO), he didn't want to fix alloc_pages 
sleeping when __GFP_NORETRY is used. So what should I say? Fix them and 
you won't be evil :-)

(he could also fix the oom killer, so that it is triggered when 
free_memory+cache+free_swap goes beyond a threshold and not when you loop 
too long in the allocator)

> > You refused to fix vmalloc(GFP_NOIO) misbehavior a year ago (did you make 
> > some progress with it since that time?) and you refuse to fix kvmalloc 
> > misuses.
> 
> I understand you're frustrated, but this is not the way to get the problems
> fixed.
> 
> > I tried this patch on text-only virtual machine and /proc/vmallocinfo 
> > shows 614kB more memory. I tried it on a desktop machine with the chrome 
> > browser open and /proc/vmallocinfo space is increased by 7MB. So no - this 
> > won't exhaust memory and kill the machine.
> 
> This is good data, thank you for providing it.
> 
> > Arguing that this increases memory consumption is as bogus as arguing that 
> > CONFIG_LOCKDEP increses memory consumption. No one is forcing you to 
> > enable CONFIG_LOCKDEP and no one is forcing you to enable this kvmalloc 
> > test too.
> 
> I think there's a real problem which is that CONFIG_DEBUG_VM is too broad.
> It inserts code in a *lot* of places, some of which is quite expensive.
> We would do better to split it into more granular pieces ... although
> an explosion of configuration options isn't great either.  Maybe just
> CONFIG_DEBUG_VM and CONFIG_DEBUG_VM_EXPENSIVE.
> 
> Michal may be wrong, but he's not evil.

I already said that we can change it from CONFIG_DEBUG_VM to 
CONFIG_DEBUG_SG - or to whatever other option you may want, just to make 
sure that it is enabled in distro debug kernels by default.

Mikulas
