Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C58756B027C
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 00:07:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p2so13258926pfk.13
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 21:07:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3sor84703pgt.340.2017.11.06.21.07.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 21:07:19 -0800 (PST)
Date: Tue, 7 Nov 2017 16:07:05 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
Message-ID: <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
In-Reply-To: <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
	<20171105231850.5e313e46@roar.ozlabs.ibm.com>
	<871slcszfl.fsf@linux.vnet.ibm.com>
	<20171106174707.19f6c495@roar.ozlabs.ibm.com>
	<24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
	<20171106192524.12ea3187@roar.ozlabs.ibm.com>
	<d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
	<546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

C'ing everyone who was on the x86 56-bit user virtual address patch.

I think we need more time to discuss this behaviour, in light of the
regression Florian uncovered. I would propose we turn off the 56-bit
user virtual address support for x86 for 4.14, and powerpc would
follow and turn off its 512T support until we can get a better handle
on the problems. (Actually Florian initially hit a couple of bugs in
powerpc implementation, but pulling that string uncovers a whole lot
of difficulties.)

The bi-modal behavior switched based on a combination of mmap address
hint and MAP_FIXED just sucks. It's segregating our VA space with
some non-standard heuristics, and it doesn't seem to work very well.

What are we trying to do? Allow SAP HANA etc use huge address spaces
by coding to these specific mmap heuristics we're going to add,
rather than solving it properly in a way that requires adding a new
syscall or personality or prctl or sysctl. Okay, but the cost is that
despite best efforts, it still changes ABI behaviour for existing
applications and these heuristics will become baked into the ABI that
we will have to support. Not a good tradeoff IMO.

First of all, using addr and MAP_FIXED to develop our heuristic can
never really give unchanged ABI. It's an in-band signal. brk() is a
good example that steadily keeps incrementing address, so depending
on malloc usage and address space randomization, you will get a brk()
that ends exactly at 128T, then the next one will be >
DEFAULT_MAP_WINDOW, and it will switch you to 56 bit address space.

Second, the kernel can never completely solve the problem this way.
How do we know a malloc library will not ask for > 128TB addresses
and pass them to an unknowing application?

And lastly, there are a fair few bugs and places where description
in changelogs and mailing lists does not match code. You don't want
to know the mess in powerpc, but even x86 has two I can see:
MAP_FIXED succeeds even when crossing 128TB addresses (where changelog
indicated it should not), arch_get_unmapped_area_topdown() with an
address hint is checking against TASK_SIZE rather than the limited
128TB address, so it looks like it won't follow the heuristics.

So unless everyone else thinks I'm crazy and disagrees, I'd ask for
a bit more time to make sure we get this interface right. I would
hope for something like prctl PR_SET_MM which can be used to set
our user virtual address bits on a fine grained basis. Maybe a
sysctl, maybe a personality. Something out-of-band. I don't wan to
get too far into that discussion yet. First we need to agree whether
or not the code in the tree today is a problem.

Thanks,
Nick

On Mon, 6 Nov 2017 09:32:25 +0100
Florian Weimer <fweimer@redhat.com> wrote:

> On 11/06/2017 09:30 AM, Aneesh Kumar K.V wrote:
> > On 11/06/2017 01:55 PM, Nicholas Piggin wrote:  
> >> On Mon, 6 Nov 2017 09:11:37 +0100
> >> Florian Weimer <fweimer@redhat.com> wrote:
> >>  
> >>> On 11/06/2017 07:47 AM, Nicholas Piggin wrote:  
> >>>> "You get < 128TB unless explicitly requested."
> >>>>
> >>>> Simple, reasonable, obvious rule. Avoids breaking apps that store
> >>>> some bits in the top of pointers (provided that memory allocator
> >>>> userspace libraries also do the right thing).  
> >>>
> >>> So brk would simplify fail instead of crossing the 128 TiB threshold?  
> >>
> >> Yes, that was the intention and that's what x86 seems to do.
> >>  
> >>>
> >>> glibc malloc should cope with that and switch to malloc, but this code
> >>> path is obviously less well-tested than the regular way.  
> >>
> >> Switch to mmap() I guess you meant?  
> 
> Yes, sorry.
> 
> >> powerpc has a couple of bugs in corner cases, so those should be fixed
> >> according to intended policy for stable kernels I think.
> >>
> >> But I question the policy. Just seems like an ugly and ineffective wart.
> >> Exactly for such cases as this -- behaviour would change from run to run
> >> depending on your address space randomization for example! In case your
> >> brk happens to land nicely on 128TB then the next one would succeed.  
> > 
> > Why ? It should not change between run to run. We limit the free
> > area search range based on hint address. So we should get consistent 
> > results across run. even if we changed the context.addr_limit.  
> 
> The size of the gap to the 128 TiB limit varies between runs because of 
> ASLR.  So some runs would use brk alone, others would use brk + malloc. 
> That's not really desirable IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
