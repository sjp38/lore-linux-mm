Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 153DC6B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 11:50:36 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m21so13644732qkk.12
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:50:36 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x4-v6si502293qtk.160.2018.04.24.08.50.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 08:50:35 -0700 (PDT)
Date: Tue, 24 Apr 2018 11:50:30 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH v3] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG
In-Reply-To: <20180424125121.GA17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1804181350050.17942@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1804191207380.31175@file01.intranet.prod.int.rdu2.redhat.com> <20180420130852.GC16083@dhcp22.suse.cz> <alpine.LRH.2.02.1804201635180.25408@file01.intranet.prod.int.rdu2.redhat.com>
 <20180420210200.GH10788@bombadil.infradead.org> <alpine.LRH.2.02.1804201704580.25408@file01.intranet.prod.int.rdu2.redhat.com> <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com> <20180424125121.GA17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>



On Tue, 24 Apr 2018, Michal Hocko wrote:

> On Mon 23-04-18 20:06:16, Mikulas Patocka wrote:
> [...]
> > @@ -404,6 +405,12 @@ void *kvmalloc_node(size_t size, gfp_t f
> >  	 */
> >  	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> >  
> > +#ifdef CONFIG_DEBUG_SG
> > +	/* Catch bugs when the caller uses DMA API on the result of kvmalloc. */
> > +	if (!(prandom_u32_max(2) & 1))
> > +		goto do_vmalloc;
> > +#endif
> 
> I really do not think there is anything DEBUG_SG specific here. Why you
> simply do not follow should_failslab path or even reuse the function?

CONFIG_DEBUG_SG is enabled by default in RHEL and Fedora debug kernel (if 
you don't like CONFIG_DEBUG_SG, pick any other option that is enabled 
there).

Fail-injection framework is if off by default and it must be explicitly 
enabled and configured by the user - and most users won't enable it.

Mikulas

> > +
> >  	/*
> >  	 * We want to attempt a large physically contiguous block first because
> >  	 * it is less likely to fragment multiple larger blocks and therefore
> > @@ -427,6 +434,9 @@ void *kvmalloc_node(size_t size, gfp_t f
> >  	if (ret || size <= PAGE_SIZE)
> >  		return ret;
> >  
> > +#ifdef CONFIG_DEBUG_SG
> > +do_vmalloc:
> > +#endif
> >  	return __vmalloc_node_flags_caller(size, node, flags,
> >  			__builtin_return_address(0));
> >  }
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
