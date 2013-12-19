Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 596686B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 19:24:23 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so361073pdj.16
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 16:24:22 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id am2si1233436pad.67.2013.12.18.16.24.20
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 16:24:20 -0800 (PST)
Message-ID: <52B23CAF.809@sr71.net>
Date: Wed, 18 Dec 2013 16:24:15 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/7] re-shrink 'struct page' when SLUB is on.
References: <20131213235903.8236C539@viggo.jf.intel.com> <20131216160128.aa1f1eb8039f5eee578cf560@linux-foundation.org> <52AF9EB9.7080606@sr71.net> <0000014301223b3e-a73f3d59-8234-48f1-9888-9af32709a879-000000@email.amazonses.com>
In-Reply-To: <0000014301223b3e-a73f3d59-8234-48f1-9888-9af32709a879-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Pekka Enberg <penberg@kernel.org>

On 12/17/2013 07:17 AM, Christoph Lameter wrote:
> On Mon, 16 Dec 2013, Dave Hansen wrote:
> 
>> I'll do some testing and see if I can coax out any delta from the
>> optimization myself.  Christoph went to a lot of trouble to put this
>> together, so I assumed that he had a really good reason, although the
>> changelogs don't really mention any.
> 
> The cmpxchg on the struct page avoids disabling interrupts etc and
> therefore simplifies the code significantly.
> 
>> I honestly can't imagine that a cmpxchg16 is going to be *THAT* much
>> cheaper than a per-page spinlock.  The contended case of the cmpxchg is
>> way more expensive than spinlock contention for sure.
> 
> Make sure slub does not set __CMPXCHG_DOUBLE in the kmem_cache flags
> and it will fall back to spinlocks if you want to do a comparison. Most
> non x86 arches will use that fallback code.


I did four tests.  The first workload allocs a bunch of stuff, then
frees it all with both the cmpxchg-enabled 64-byte struct page and the
48-byte one that is supposed to use a spinlock.  I confirmed the 'struct
page' size in both cases by looking at dmesg.

Essentially, I see no worthwhile benefit from using the double-cmpxchg
over the spinlock.  In fact, the increased cache footprint makes it
*substantially* worse when doing a tight loop.

Unless somebody can find some holes in this, I think we have no choice
but to unset the HAVE_ALIGNED_STRUCT_PAGE config option and revert using
the cmpxchg, at least for now.

Kernel config:
https://www.sr71.net/~dave/intel/config-20131218-structpagesize
System was an 80-core "Westmere" Xeon

I suspect that the original data:

> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8a5ec0b

are invalid because the data there were not done with the increased
'struct page' padding.

---------------------------

First test:

	for (i = 0; i < kmalloc_iterations; i++)
        	gunk[i] = kmalloc(kmalloc_size, GFP_KERNEL);
	for (i = 0; i < kmalloc_iterations; i++)
		kfree(gunk[i]);

All units are all in nanoseconds, lower is better.

		size of 'struct page':
kmalloc size	64-byte 48-byte
8		98.2	105.7
32		123.7	125.8
128		293.9	289.9
256		572.4	577.9
1024		621.0	639.3
4096		733.3	746.7
8192		968.3	948.6

As you can see, it's mostly a wash.  The 64-byte one looks to have a
~8ns advantage, but any advantage disappears in to the noise on the
other sizes.

---------------------------

Second test did the same 'struct page sizes', but instead did a
kmalloc() immediately followed by a kfree:

	for (i = 0; i < kmalloc_iterations; i++) {
        	gunk[i] = kmalloc(kmalloc_size, GFP_KERNEL);
		kfree(gunk[i]);
	}

		size of 'struct page':
kmalloc size	64-byte 48-byte
8		58.6	43.0
32		59.3	43.0
128		59.4	43.2
256		57.4	42.8
1024		80.4	43.0
4096		76.0	43.8
8192		79.9	43.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
