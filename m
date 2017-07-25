Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 064A06B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:26:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id c14so168123428pgn.11
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 18:26:08 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id f22si7879759pli.265.2017.07.24.18.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jul 2017 18:26:07 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: pcpu allocator on large NUMA machines
In-Reply-To: <20170724142826.GN25221@dhcp22.suse.cz>
References: <20170724134240.GL25221@dhcp22.suse.cz> <20170724135714.GA3240919@devbig577.frc2.facebook.com> <20170724142826.GN25221@dhcp22.suse.cz>
Date: Tue, 25 Jul 2017 11:26:03 +1000
Message-ID: <877eyxz4r8.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>
Cc: Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Michal Hocko <mhocko@kernel.org> writes:

> On Mon 24-07-17 09:57:14, Tejun Heo wrote:
>> On Mon, Jul 24, 2017 at 03:42:40PM +0200, Michal Hocko wrote:
> [...]
>> > My understanding of the pcpu allocator is basically close to zero but it
>> > seems weird to me that we would need many TB of vmalloc address space
>> > just to allocate vmalloc areas that are in range of hundreds of MB. So I
>> > am wondering whether this is an expected behavior of the allocator or
>> > there is a problem somwehere else.
>> 
>> It's not actually using the entire region but the area allocations try
>> to follow the same topology as kernel linear address layouts.  ie. if
>> kernel address for different NUMA nodes are apart by certain amount,
>> the percpu allocator tries to replicate that for dynamic allocations
>> which allows leaving the static and first dynamic area in the kernel
>> linear address which helps reducing TLB pressure.
>> 
>> This optimization can be turned off when vmalloc area isn't spacious
>> enough by using pcpu_page_first_chunk() instead of
>> pcpu_embed_first_chunk() while initializing percpu allocator.
>
> Thanks for the clarification, this is really helpful!
>
>> Can you
>> see whether replacing that in arch/powerpc/kernel/setup_64.c fixes the
>> issue?  If so, all it needs to do is figuring out what conditions we
>> need to check to opt out of embedding the first chunk.  Note that x86
>> 32bit does about the same thing.
>
> Hmm, I will need some help from PPC guys here. I cannot find something
> ready to implement pcpup_populate_pte and I am not familiar with ppc
> memory model to implement one myself.

I don't think we want to stop using embed first chunk unless we have to.

We have code that accesses percpu variables in real mode (with the MMU
off), and that wouldn't work easily if the first chunk wasn't in the
linear mapping. So it's not just an optimisation for us.

We can fairly easily make the vmalloc space 56T, and I'm working on a
patch to make it ~500T on newer machines.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
