Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31AF5800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 03:56:45 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 79so2038885pge.16
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 00:56:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3si15804233pgt.217.2018.01.24.00.56.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 00:56:43 -0800 (PST)
Date: Wed, 24 Jan 2018 09:56:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Matthew's minor MM topics
Message-ID: <20180124085640.GG1526@dhcp22.suse.cz>
References: <20180116141354.GB30073@bombadil.infradead.org>
 <20180123122646.GJ1526@dhcp22.suse.cz>
 <20180123204827.GB5565@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123204827.GB5565@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue 23-01-18 12:48:27, Matthew Wilcox wrote:
> On Tue, Jan 23, 2018 at 01:26:46PM +0100, Michal Hocko wrote:
> > On Tue 16-01-18 06:13:54, Matthew Wilcox wrote:
> > > 1. GFP_DMA / GFP_HIGHMEM / GFP_DMA32
> > > 
> > > The documentation is clear that only one of these three bits is allowed
> > > to be set.  Indeed, we have code that checks that only one of these
> > > three bits is set.  So why do we have three bits?  Surely this encoding
> > > works better:
> > > 
> > > 00b (normal)
> > > 01b GFP_DMA
> > > 10b GFP_DMA32
> > > 11b GFP_HIGHMEM
> > > (or some other clever encoding that maps well to the zone_type index)
> > 
> > Didn't you forget about movable zone? Anyway, if you can simplify this
> > thing I would be more than happy. GFP_ZONE_TABLE makes my head spin
> > anytime I dare to look.
> 
> I didn't *forget* about it, exactly.  I just didn't include it because
> (as I understand it), it's legitimate to ask for GFP_DMA | GFP_MOVABLE.
> To quote:
> 
>  * The zone fallback order is MOVABLE=>HIGHMEM=>NORMAL=>DMA32=>DMA.
>  * But GFP_MOVABLE is not only a zone specifier but also an allocation
>  * policy. Therefore __GFP_MOVABLE plus another zone selector is valid.
>  * Only 1 bit of the lowest 3 bits (DMA,DMA32,HIGHMEM) can be set to "1".
> 
> I don't understand this, personally.  I assumed it made sense to someone,
> but if we can collapse GFP_MOVABLE into this and just use the bottom three
> bits as the zone number, then that would be an even better cleanup.

Well, I always forget details because MOVABLE zone and its gfp flag are
just very special... If you can make it simple I am all for it. I am
just worried that this will be hard to discuss because most people just
do not have that code cached. So if you have some code to show and
discuss then why not I suspect discussing it on the mailing list might
result to be much more productive .

[...]
> > > 4. vmf_insert_(page|pfn|mixed|...)
> > > 
> > > vm_insert_foo are invariably called from fault handlers, usually as
> > > the last thing we do before returning a VM_FAULT code.  As such, why do
> > > they return an errno that has to be translated?  We would be better off
> > > returning VM_FAULT codes from these functions.
> > 
> > Which tree are you looking at? git grep vmf_insert_ doesn't show much.
> > vmf_insert_pfn_p[mu]d and those already return VM_FAULT error code from
> > a quick look.
> 
> I didn't explain this well.  Today, vm_insert_page() returns -EFAULT,
> -EINVAL, -ENOMEM or -EBUSY.  I'd like to see it replaced with a new
> function called vmf_insert_page() which returns a vm_fault_t rather
> than have every caller of vm_insert_page() convert that errno into
> a vm_fault_t.

makes sense to me

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
