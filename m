Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 745B6800E0
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 15:48:30 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id k76so1905532iod.12
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:48:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c123si7527260itc.108.2018.01.23.12.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jan 2018 12:48:29 -0800 (PST)
Date: Tue, 23 Jan 2018 12:48:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Matthew's minor MM topics
Message-ID: <20180123204827.GB5565@bombadil.infradead.org>
References: <20180116141354.GB30073@bombadil.infradead.org>
 <20180123122646.GJ1526@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123122646.GJ1526@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 23, 2018 at 01:26:46PM +0100, Michal Hocko wrote:
> On Tue 16-01-18 06:13:54, Matthew Wilcox wrote:
> > 1. GFP_DMA / GFP_HIGHMEM / GFP_DMA32
> > 
> > The documentation is clear that only one of these three bits is allowed
> > to be set.  Indeed, we have code that checks that only one of these
> > three bits is set.  So why do we have three bits?  Surely this encoding
> > works better:
> > 
> > 00b (normal)
> > 01b GFP_DMA
> > 10b GFP_DMA32
> > 11b GFP_HIGHMEM
> > (or some other clever encoding that maps well to the zone_type index)
> 
> Didn't you forget about movable zone? Anyway, if you can simplify this
> thing I would be more than happy. GFP_ZONE_TABLE makes my head spin
> anytime I dare to look.

I didn't *forget* about it, exactly.  I just didn't include it because
(as I understand it), it's legitimate to ask for GFP_DMA | GFP_MOVABLE.
To quote:

 * The zone fallback order is MOVABLE=>HIGHMEM=>NORMAL=>DMA32=>DMA.
 * But GFP_MOVABLE is not only a zone specifier but also an allocation
 * policy. Therefore __GFP_MOVABLE plus another zone selector is valid.
 * Only 1 bit of the lowest 3 bits (DMA,DMA32,HIGHMEM) can be set to "1".

I don't understand this, personally.  I assumed it made sense to someone,
but if we can collapse GFP_MOVABLE into this and just use the bottom three
bits as the zone number, then that would be an even better cleanup.

> > 2. kvzalloc_ab_c()
> > 
> > We also need to go through and convert dozens of callers that are
> > doing kvzalloc(a * b) into kvzalloc_array(a, b).  Maybe we can ask for
> > some coccinelle / smatch / checkpatch help here.
> 
> I do not see anything controversial here. Is there anything to be
> discussed here? If there is a common pattern then a helper shouldn't be
> a big deal, no?

Good!  Let's try and dispose of this quickly.

> > 4. vmf_insert_(page|pfn|mixed|...)
> > 
> > vm_insert_foo are invariably called from fault handlers, usually as
> > the last thing we do before returning a VM_FAULT code.  As such, why do
> > they return an errno that has to be translated?  We would be better off
> > returning VM_FAULT codes from these functions.
> 
> Which tree are you looking at? git grep vmf_insert_ doesn't show much.
> vmf_insert_pfn_p[mu]d and those already return VM_FAULT error code from
> a quick look.

I didn't explain this well.  Today, vm_insert_page() returns -EFAULT,
-EINVAL, -ENOMEM or -EBUSY.  I'd like to see it replaced with a new
function called vmf_insert_page() which returns a vm_fault_t rather
than have every caller of vm_insert_page() convert that errno into
a vm_fault_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
