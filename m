Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0F556B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 07:04:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d9-v6so14320639qtj.20
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 04:04:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u123si11122549qkb.241.2018.04.24.04.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 04:04:28 -0700 (PDT)
Date: Tue, 24 Apr 2018 07:04:23 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH v3] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG
In-Reply-To: <alpine.DEB.2.21.1804231945410.58980@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1804240701590.28016@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181218270.19136@file01.intranet.prod.int.rdu2.redhat.com> <20180418.134651.2225112489265654270.davem@davemloft.net> <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180420210200.GH10788@bombadil.infradead.org>
 <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com> <20180423151545.GU17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.21.1804231945410.58980@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Mon, 23 Apr 2018, David Rientjes wrote:

> On Mon, 23 Apr 2018, Mikulas Patocka wrote:
> 
> > The kvmalloc function tries to use kmalloc and falls back to vmalloc if
> > kmalloc fails.
> > 
> > Unfortunatelly, some kernel code has bugs - it uses kvmalloc and then
> > uses DMA-API on the returned memory or frees it with kfree. Such bugs were
> > found in the virtio-net driver, dm-integrity or RHEL7 powerpc-specific
> > code.
> > 
> > These bugs are hard to reproduce because kvmalloc falls back to vmalloc
> > only if memory is fragmented.
> > 
> > In order to detect these bugs reliably I submit this patch that changes
> > kvmalloc to fall back to vmalloc with 1/2 probability if CONFIG_DEBUG_SG
> > is turned on. CONFIG_DEBUG_SG is used, because it makes the DMA API layer
> > verify the addresses passed to it, and so the user will get a reliable
> > stacktrace.
> 
> Why not just do it unconditionally?  Sounds better than "50% of the time 
> this will catch bugs".

Because kmalloc (with slub_debug) detects buffer overflows better than 
vmalloc. vmalloc detects buffer overflows only at a page boundary. This is 
intended for debugging kernels and debugging kernels should detect as many 
bugs as possible.

Mikulas
