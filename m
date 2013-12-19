Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8DDB86B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 19:41:13 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id w10so376543pde.6
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 16:41:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id wh6si1232206pac.190.2013.12.18.16.41.11
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 16:41:11 -0800 (PST)
Date: Wed, 18 Dec 2013 16:41:09 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/7] re-shrink 'struct page' when SLUB is on.
Message-Id: <20131218164109.5e169e258378fac44ec5212d@linux-foundation.org>
In-Reply-To: <52B23CAF.809@sr71.net>
References: <20131213235903.8236C539@viggo.jf.intel.com>
	<20131216160128.aa1f1eb8039f5eee578cf560@linux-foundation.org>
	<52AF9EB9.7080606@sr71.net>
	<0000014301223b3e-a73f3d59-8234-48f1-9888-9af32709a879-000000@email.amazonses.com>
	<52B23CAF.809@sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pravin B Shelar <pshelar@nicira.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Pekka Enberg <penberg@kernel.org>

On Wed, 18 Dec 2013 16:24:15 -0800 Dave Hansen <dave@sr71.net> wrote:

> On 12/17/2013 07:17 AM, Christoph Lameter wrote:
> > On Mon, 16 Dec 2013, Dave Hansen wrote:
> > 
> >> I'll do some testing and see if I can coax out any delta from the
> >> optimization myself.  Christoph went to a lot of trouble to put this
> >> together, so I assumed that he had a really good reason, although the
> >> changelogs don't really mention any.
> > 
> > The cmpxchg on the struct page avoids disabling interrupts etc and
> > therefore simplifies the code significantly.
> > 
> >> I honestly can't imagine that a cmpxchg16 is going to be *THAT* much
> >> cheaper than a per-page spinlock.  The contended case of the cmpxchg is
> >> way more expensive than spinlock contention for sure.
> > 
> > Make sure slub does not set __CMPXCHG_DOUBLE in the kmem_cache flags
> > and it will fall back to spinlocks if you want to do a comparison. Most
> > non x86 arches will use that fallback code.
> 
> 
> I did four tests.  The first workload allocs a bunch of stuff, then
> frees it all with both the cmpxchg-enabled 64-byte struct page and the
> 48-byte one that is supposed to use a spinlock.  I confirmed the 'struct
> page' size in both cases by looking at dmesg.
> 
> Essentially, I see no worthwhile benefit from using the double-cmpxchg
> over the spinlock.  In fact, the increased cache footprint makes it
> *substantially* worse when doing a tight loop.
> 
> Unless somebody can find some holes in this, I think we have no choice
> but to unset the HAVE_ALIGNED_STRUCT_PAGE config option and revert using
> the cmpxchg, at least for now.
> 

So your scary patch series which shrinks struct page while retaining
the cmpxchg_double() might reclaim most of this loss?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
