Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10FAA6B02FA
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 10:28:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id m4so7951570wmi.14
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 07:28:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 93si9488488wra.429.2017.07.24.07.28.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Jul 2017 07:28:29 -0700 (PDT)
Date: Mon, 24 Jul 2017 16:28:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: pcpu allocator on large NUMA machines
Message-ID: <20170724142826.GN25221@dhcp22.suse.cz>
References: <20170724134240.GL25221@dhcp22.suse.cz>
 <20170724135714.GA3240919@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170724135714.GA3240919@devbig577.frc2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 24-07-17 09:57:14, Tejun Heo wrote:
> Hello,

Hi,
and thanks for ths swift answer

> On Mon, Jul 24, 2017 at 03:42:40PM +0200, Michal Hocko wrote:
[...]
> > My understanding of the pcpu allocator is basically close to zero but it
> > seems weird to me that we would need many TB of vmalloc address space
> > just to allocate vmalloc areas that are in range of hundreds of MB. So I
> > am wondering whether this is an expected behavior of the allocator or
> > there is a problem somwehere else.
> 
> It's not actually using the entire region but the area allocations try
> to follow the same topology as kernel linear address layouts.  ie. if
> kernel address for different NUMA nodes are apart by certain amount,
> the percpu allocator tries to replicate that for dynamic allocations
> which allows leaving the static and first dynamic area in the kernel
> linear address which helps reducing TLB pressure.
> 
> This optimization can be turned off when vmalloc area isn't spacious
> enough by using pcpu_page_first_chunk() instead of
> pcpu_embed_first_chunk() while initializing percpu allocator.

Thanks for the clarification, this is really helpful!

> Can you
> see whether replacing that in arch/powerpc/kernel/setup_64.c fixes the
> issue?  If so, all it needs to do is figuring out what conditions we
> need to check to opt out of embedding the first chunk.  Note that x86
> 32bit does about the same thing.

Hmm, I will need some help from PPC guys here. I cannot find something
ready to implement pcpup_populate_pte and I am not familiar with ppc
memory model to implement one myself.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
