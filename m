Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 295136B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 16:56:14 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v187so6451168qka.5
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:56:14 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u123si1767538qkb.241.2018.04.20.13.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 13:56:13 -0700 (PDT)
Date: Fri, 20 Apr 2018 16:56:07 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] kvmalloc: always use vmalloc if CONFIG_DEBUG_VM
In-Reply-To: <20180420134901.GB17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804201141420.1535@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181029270.19294@file01.intranet.prod.int.rdu2.redhat.com> <3e65977e-53cd-bf09-bc4b-0ce40e9091fe@gmail.com> <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net>
 <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <20180420134136.GD10788@bombadil.infradead.org>
 <20180420134901.GB17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, bhutchings@solarflare.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Fri, 20 Apr 2018, Michal Hocko wrote:

> On Fri 20-04-18 06:41:36, Matthew Wilcox wrote:
> > On Fri, Apr 20, 2018 at 03:08:52PM +0200, Michal Hocko wrote:
> > > > In order to detect these bugs reliably I submit this patch that changes
> > > > kvmalloc to always use vmalloc if CONFIG_DEBUG_VM is turned on.
> > > 
> > > No way. This is just wrong! First of all, you will explode most likely
> > > on many allocations of small sizes. Second, CONFIG_DEBUG_VM tends to be
> > > enabled quite often.
> > 
> > I think it'll still suit Mikulas' debugging needs if we always use
> > vmalloc for sizes above PAGE_SIZE?
> 
> Even if that was the case then this doesn't sounds like CONFIG_DEBUG_VM
> material. We do not want a completely different behavior when the config
> 
> -- 
> Michal Hocko
> SUSE Labs

I'm not arguing that it must be turned on exactly by CONFIG_DEBUG_VM. It 
may be turned on some other option that is enabled in debug kernels 
(CONFIG_DEBUG_SG may be a better option, because you'll get meaningful 
stracktraces from DMA API then).

> is enabled. If we really need some better fallback testing coverage
> then the fault injection, as suggested by Vlastimil, sounds much more
> reasonable to me

People who test kernels will install the kernel-debug package, reboot to 
the debug kernel and run their testsuites. They won't turn on magic 
options in debugfs or use some hideous kernel commandline arguments. If 
the kvmalloc test isn't in the debug kernel, then the testing crew won't 
test it - that's it.

Mikulas
