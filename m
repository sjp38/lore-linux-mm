Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 952BE6B0085
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 19:01:32 -0500 (EST)
Date: Wed, 10 Mar 2010 01:01:21 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: further plans on bootmem, was: Re: - bootmem-avoid-dma32-zone-by-default.patch removed from -mm tree
Message-ID: <20100310000121.GA9985@cmpxchg.org>
References: <201003091940.o29Je4Iq000754@imap1.linux-foundation.org> <4B96B923.7020805@kernel.org> <20100309134902.171ba2ae.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100309134902.171ba2ae.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>, x86@kernel.org, linux-arch@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 01:49:02PM -0800, Andrew Morton wrote:
> On Tue, 09 Mar 2010 13:09:55 -0800
> Yinghai Lu <yinghai@kernel.org> wrote:
> 
> > On 03/09/2010 11:40 AM, akpm@linux-foundation.org wrote:
> > > The patch titled
> > >      bootmem: avoid DMA32 zone by default
> > > has been removed from the -mm tree.  Its filename was
> > >      bootmem-avoid-dma32-zone-by-default.patch
> > > 
> > > This patch was dropped because I'm all confused
> > > 
> > 
> > Thanks for that...
> 
> Well.  I did drop it because I'm all confused.  It may come back.
> 
> If Johannes is working in the direction of removing and simplifying
> code then that's a high priority.  So I'm waiting to see where this
> discussion leads (on the mailing list, please!)

I am not working on simplifying in this area at the moment.  I am just
questioning the discrepancy between the motivation of Yinghai's patch
series to skip bootmem on x86 and its actual outcome.

The stated reason for the series was that the amount of memory allocators
involved in bootstrapping mm on x86 'seemed a bit excessive'. [1]

I am perfectly fine with the theory: select one mechanism and see whether
it can be bridged and consequently _removed_.  To shrink the code base,
shrink text size, make the boot process less complex, more robust etc.

What I take away from this patchset, however, is that all it really does
is make the early_res stuff from x86 generic code and add a semantically
different version of the bootmem API on top of it, selectable with a config
option.  The diffstat balance is an increase of around 900 lines of code.

Note that it still uses bootmem to actually bootstrap the page allocator,
that we now have two implementations of the bootmem interface and no real
plan - as far as I am informed - to actually change this.

I also found it weird that it makes x86 skip an allocator level that all
the other architectures are using, and replaces it with 'generic' code that
nobody but x86 is using (sparc, powerpc, sh and microblaze  appear to have
lib/lmb.c at this stage and for this purpose? lmb was also suggested by
benh [4] but I have to admit I do not understand Yinghai's response to it).

When I asked Yinghai for the benefits of this change, he responded with
this [2]:

nobootmem:                                                                                                                                   
   text    data     bss     dec     hex filename                                                                                             
19185736        4148404 12170736        35504876        21dc2ec vmlinux.nobootmem
Memory: 1058662820k/1075838976k available (11388k kernel code, 2106480k absent, 15069676k reserved, 8589k data, 2744k init
[  220.947157] calling  ip_auto_config+0x0/0x24d @ 1


bootmem:                   
   text    data     bss     dec     hex filename
19188441        4153956 12170736        35513133        21de32d vmlinux.bootmem
Memory: 1058662796k/1075838976k available (11388k kernel code, 2106480k absent, 15069700k reserved, 8589k data, 2752k init
[  236.765364] calling  ip_auto_config+0x0/0x24d @ 1

but compare this with the diffstat and memory savings of Joe Perches'
latest dev_<level> macro changes [3].

So the questions I still have is this: can early_res replace bootmem
for other architectures too (and will this be pushed!) or are we stuck
with two implementations of the bootmem API forever?

Or more generically, I can not see that this series is a complete act
of reduction but I also can not see what is supposed to follow up in
order to finish it.  And apparently I am not alone with this.  Can
Yinghai or somebody else of the x86 team shed some light on this?

Thanks.

	Hannes

PS: I think it is common practice on LKML that if you have plans for
a piece of code, you involve all its users and people who last worked
on it in the discussions.  So please check your Cc lists next time
before stuff is about to get merged.  Thanks again.

[1] http://archives.free.net.ph/message/20100209.193211.48e131c7.en.html
[2] http://lkml.org/lkml/2010/3/5/414
[3] http://lkml.org/lkml/2010/3/4/17
[4] http://lkml.org/lkml/2010/2/14/321

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
