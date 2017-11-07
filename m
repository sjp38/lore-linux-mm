Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CD72280245
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 06:15:48 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o88so7463196wrb.18
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 03:15:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y14sor766345ede.42.2017.11.07.03.15.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 03:15:46 -0800 (PST)
Date: Tue, 7 Nov 2017 14:15:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171107111543.ep57evfxxbwwlhdh@node.shutemov.name>
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
 <20171105231850.5e313e46@roar.ozlabs.ibm.com>
 <871slcszfl.fsf@linux.vnet.ibm.com>
 <20171106174707.19f6c495@roar.ozlabs.ibm.com>
 <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
 <20171106192524.12ea3187@roar.ozlabs.ibm.com>
 <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
 <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
 <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Florian Weimer <fweimer@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Nov 07, 2017 at 04:07:05PM +1100, Nicholas Piggin wrote:
> C'ing everyone who was on the x86 56-bit user virtual address patch.
> 
> I think we need more time to discuss this behaviour, in light of the
> regression Florian uncovered. I would propose we turn off the 56-bit
> user virtual address support for x86 for 4.14, and powerpc would
> follow and turn off its 512T support until we can get a better handle
> on the problems. (Actually Florian initially hit a couple of bugs in
> powerpc implementation, but pulling that string uncovers a whole lot
> of difficulties.)
> 
> The bi-modal behavior switched based on a combination of mmap address
> hint and MAP_FIXED just sucks. It's segregating our VA space with
> some non-standard heuristics, and it doesn't seem to work very well.
> 
> What are we trying to do? Allow SAP HANA etc use huge address spaces
> by coding to these specific mmap heuristics we're going to add,
> rather than solving it properly in a way that requires adding a new
> syscall or personality or prctl or sysctl. Okay, but the cost is that
> despite best efforts, it still changes ABI behaviour for existing
> applications and these heuristics will become baked into the ABI that
> we will have to support. Not a good tradeoff IMO.
> 
> First of all, using addr and MAP_FIXED to develop our heuristic can
> never really give unchanged ABI. It's an in-band signal. brk() is a
> good example that steadily keeps incrementing address, so depending
> on malloc usage and address space randomization, you will get a brk()
> that ends exactly at 128T, then the next one will be >
> DEFAULT_MAP_WINDOW, and it will switch you to 56 bit address space.

No, it won't. You will hit stack first.

> Second, the kernel can never completely solve the problem this way.
> How do we know a malloc library will not ask for > 128TB addresses
> and pass them to an unknowing application?

The idea is that an application can provide hint (mallopt() ?) to malloc
implementation that it's ready to full address space. In this case, malloc
can use mmap((void *) -1,...) for its allocations and get full address
space this way.

> And lastly, there are a fair few bugs and places where description
> in changelogs and mailing lists does not match code. You don't want
> to know the mess in powerpc, but even x86 has two I can see:
> MAP_FIXED succeeds even when crossing 128TB addresses (where changelog
> indicated it should not),

Hm. I don't see where the changelog indicated that MAP_FIXED across 128TB
shouldn't work. My intention was that it should, although I haven't stated
it in the changelog.

The idea was we shouldn't allow to slip above 47-bits by accidentally.

Correctly functioning program would never request addr+len above 47-bit
with MAP_FIXED, unless it's ready to handle such addresses. Otherwise the
request would simply fail on machine that doesn't support large VA.

In contrast, addr+len above 47-bit without MAP_FIXED will not fail on
machine that doesn't support large VA, kernel will find another place
under 47-bit. And I can imagine a reasonable application that does
something like this.

So we cannot rely that application is ready to handle large
addresses if we see addr+len without MAP_FIXED.

> arch_get_unmapped_area_topdown() with an address hint is checking
> against TASK_SIZE rather than the limited 128TB address, so it looks
> like it won't follow the heuristics.

You are right. This is broken. If user would request mapping above vdso,
but below DEFAULT_MAP_WINDOW it will succeed.

I'll send patch to fix this. But it doesn't look as a show-stopper to me.

Re-checking things for this reply I found actual bug, see:

http://lkml.kernel.org/r/20171107103804.47341-1-kirill.shutemov@linux.intel.com

> So unless everyone else thinks I'm crazy and disagrees, I'd ask for
> a bit more time to make sure we get this interface right. I would
> hope for something like prctl PR_SET_MM which can be used to set
> our user virtual address bits on a fine grained basis. Maybe a
> sysctl, maybe a personality. Something out-of-band. I don't wan to
> get too far into that discussion yet. First we need to agree whether
> or not the code in the tree today is a problem.

Well, we've discussed before all options you are proposing.
Linus wanted a minimalistic interface, so we took this path for now.
We can always add more ways to get access to full address space later.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
