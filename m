Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE860800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 07:26:48 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id f8so327521wmi.9
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 04:26:48 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4si5227584wmc.263.2018.01.23.04.26.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Jan 2018 04:26:47 -0800 (PST)
Date: Tue, 23 Jan 2018 13:26:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Matthew's minor MM topics
Message-ID: <20180123122646.GJ1526@dhcp22.suse.cz>
References: <20180116141354.GB30073@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116141354.GB30073@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue 16-01-18 06:13:54, Matthew Wilcox wrote:
> (trying again with the right MM mailing list address.  Sorry.)
> 
> I have a number of things I'd like to discuss that are purely MM related.
> I don't know if any of them rise to the level of an entire session,
> but maybe lightning talks, or maybe we can dispose of them on the list
> before the summit.
> 
> 1. GFP_DMA / GFP_HIGHMEM / GFP_DMA32
> 
> The documentation is clear that only one of these three bits is allowed
> to be set.  Indeed, we have code that checks that only one of these
> three bits is set.  So why do we have three bits?  Surely this encoding
> works better:
> 
> 00b (normal)
> 01b GFP_DMA
> 10b GFP_DMA32
> 11b GFP_HIGHMEM
> (or some other clever encoding that maps well to the zone_type index)

Didn't you forget about movable zone? Anyway, if you can simplify this
thing I would be more than happy. GFP_ZONE_TABLE makes my head spin
anytime I dare to look.

> 2. kvzalloc_ab_c()
> 
> We could bikeshed on this name all summit long, but the idea is to provide
> an equivalent of kvmalloc_array() which works for array-plus-header.
> These allocations are legion throughout the kernel.  Here's the first
> one I found with a grep:
> 
> drivers/vhost/vhost.c:  newmem = kvzalloc(size + mem.nregions * sizeof(*m->regions), GFP_KERNEL);
> 
> ... and, yep, that one's a security hole.
> 
> The implementation is not hard, viz:
> 
> +static inline void *kvzalloc_ab_c(size_t n, size_t size, size_t c, gfp_t flags)
> +{
> +       if (size != 0 && n > (SIZE_MAX - c) / size)
> +               return NULL;
> +
> +       return kvmalloc(n * size + c, flags);
> +}
> 
> but the name will tie us in knots and getting people to actually use
> it will be worse.  (I actually stole the name from another project,
> but I can't find it now).
> 
> We also need to go through and convert dozens of callers that are
> doing kvzalloc(a * b) into kvzalloc_array(a, b).  Maybe we can ask for
> some coccinelle / smatch / checkpatch help here.

I do not see anything controversial here. Is there anything to be
discussed here? If there is a common pattern then a helper shouldn't be
a big deal, no?

> 3. Maybe we could rename kvfree() to just free()?  Please?  There's
> nothing special about it.  One fewer thing for somebody to learn when
> coming fresh to kernel programming.

I guess one has to learn about kvmalloc already and kvfree is nicely
symmetric to it.

> 4. vmf_insert_(page|pfn|mixed|...)
> 
> vm_insert_foo are invariably called from fault handlers, usually as
> the last thing we do before returning a VM_FAULT code.  As such, why do
> they return an errno that has to be translated?  We would be better off
> returning VM_FAULT codes from these functions.

Which tree are you looking at? git grep vmf_insert_ doesn't show much.
vmf_insert_pfn_p[mu]d and those already return VM_FAULT error code from
a quick look.

> Related, I'd like to introduce a new vm_fault_t typedef for unsigned
> int that indicates that the function returns VM_FAULT flags rather than
> an errno.  We've had so many mistakes in this area.

This sounds like a reasonable thing to do.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
