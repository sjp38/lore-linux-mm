Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34B5B6B0009
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 13:38:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e9so13632737pfn.16
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 10:38:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f34-v6si14550572plf.362.2018.04.24.10.38.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Apr 2018 10:38:42 -0700 (PDT)
Date: Tue, 24 Apr 2018 11:38:36 -0600
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] kvmalloc: always use vmalloc if CONFIG_DEBUG_SG
Message-ID: <20180424173836.GR17484@dhcp22.suse.cz>
References: <20180421144757.GC14610@bombadil.infradead.org>
 <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180423151545.GU17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424125121.GA17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424162906.GM17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424170349.GQ17484@dhcp22.suse.cz>
 <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

On Tue 24-04-18 13:28:49, Mikulas Patocka wrote:
> 
> 
> On Tue, 24 Apr 2018, Michal Hocko wrote:
> 
> > On Tue 24-04-18 13:00:11, Mikulas Patocka wrote:
> > > 
> > > 
> > > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > > 
> > > > On Tue 24-04-18 11:50:30, Mikulas Patocka wrote:
> > > > > 
> > > > > 
> > > > > On Tue, 24 Apr 2018, Michal Hocko wrote:
> > > > > 
> > > > > > On Mon 23-04-18 20:06:16, Mikulas Patocka wrote:
> > > > > > [...]
> > > > > > > @@ -404,6 +405,12 @@ void *kvmalloc_node(size_t size, gfp_t f
> > > > > > >  	 */
> > > > > > >  	WARN_ON_ONCE((flags & GFP_KERNEL) != GFP_KERNEL);
> > > > > > >  
> > > > > > > +#ifdef CONFIG_DEBUG_SG
> > > > > > > +	/* Catch bugs when the caller uses DMA API on the result of kvmalloc. */
> > > > > > > +	if (!(prandom_u32_max(2) & 1))
> > > > > > > +		goto do_vmalloc;
> > > > > > > +#endif
> > > > > > 
> > > > > > I really do not think there is anything DEBUG_SG specific here. Why you
> > > > > > simply do not follow should_failslab path or even reuse the function?
> > > > > 
> > > > > CONFIG_DEBUG_SG is enabled by default in RHEL and Fedora debug kernel (if 
> > > > > you don't like CONFIG_DEBUG_SG, pick any other option that is enabled 
> > > > > there).
> > > > 
> > > > Are you telling me that you are shaping a debugging functionality basing
> > > > on what RHEL has enabled? And you call me evil. This is just rediculous.
> > > > 
> > > > > Fail-injection framework is if off by default and it must be explicitly 
> > > > > enabled and configured by the user - and most users won't enable it.
> > > > 
> > > > It can be enabled easily. And if you care enough for your debugging
> > > > kernel then just make it enabled unconditionally.
> > > 
> > > So, should we add a new option CONFIG_KVMALLOC_FALLBACK_DEFAULT? I'm not 
> > > quite sure if 3 lines of debugging code need an extra option, but if you 
> > > don't want to reuse any existing debug option, it may be possible. Adding 
> > > it to the RHEL debug kernel would be trivial.
> > 
> > Wouldn't it be equally trivial to simply enable the fault injection? You
> > would get additional failure paths testing as a bonus.
> 
> The RHEL and Fedora debugging kernels are compiled with fault injection. 
> But the fault-injection framework will do nothing unless it is enabled by 
> a kernel parameter or debugfs write.
> 
> Most users don't know about the fault injection kernel parameters or 
> debugfs files and won't enabled it. We need a CONFIG_ option to enable it 
> by default in the debugging kernels (and we could add a kernel parameter 
> to override the default, fine-tune the fallback probability etc.)

If it is a real issue to install the debugging kernel with the required
kernel parameter then I a config option for the default on makes sense
to me.
-- 
Michal Hocko
SUSE Labs
