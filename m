Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 417C26B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 17:02:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n78so5253871pfj.4
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 14:02:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i75si5345370pgd.399.2018.04.20.14.02.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 14:02:05 -0700 (PDT)
Date: Fri, 20 Apr 2018 14:02:00 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
Message-ID: <20180420210200.GH10788@bombadil.infradead.org>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com>
 <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com>
 <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com>
 <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420130852.GC16083@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Fri, Apr 20, 2018 at 04:54:53PM -0400, Mikulas Patocka wrote:
> On Fri, 20 Apr 2018, Michal Hocko wrote:
> > No way. This is just wrong! First of all, you will explode most likely
> > on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
> > enabled quite often.
> 
> You're an evil person who doesn't want to fix bugs.

Steady on.  There's no need for that.  Michal isn't evil.  Please
apologise.

> You refused to fix vmalloc(GFP_NOIO) misbehavior a year ago (did you make 
> some progress with it since that time?) and you refuse to fix kvmalloc 
> misuses.

I understand you're frustrated, but this is not the way to get the problems
fixed.

> I tried this patch on text-only virtual machine and /proc/vmallocinfo 
> shows 614kB more memory. I tried it on a desktop machine with the chrome 
> browser open and /proc/vmallocinfo space is increased by 7MB. So no - this 
> won't exhaust memory and kill the machine.

This is good data, thank you for providing it.

> Arguing that this increases memory consumption is as bogus as arguing that 
> CONFIG_LOCKDEP increses memory consumption. No one is forcing you to 
> enable CONFIG_LOCKDEP and no one is forcing you to enable this kvmalloc 
> test too.

I think there's a real problem which is that CONFIG_DEBUG_VM is too broad.
It inserts code in a *lot* of places, some of which is quite expensive.
We would do better to split it into more granular pieces ... although
an explosion of configuration options isn't great either.  Maybe just
CONFIG_DEBUG_VM and CONFIG_DEBUG_VM_EXPENSIVE.

Michal may be wrong, but he's not evil.
