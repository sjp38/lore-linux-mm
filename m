Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AEFC86B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 23:12:00 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fb1so2509470pad.25
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 20:12:00 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id pp4si9097897pbb.47.2014.10.15.20.11.59
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 20:11:59 -0700 (PDT)
Date: Wed, 15 Oct 2014 23:11:54 -0400 (EDT)
Message-Id: <20141015.231154.1804074463934900124.davem@davemloft.net>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@davemloft.net>
In-Reply-To: <alpine.LRH.2.11.1410152310080.11974@adalberg.ut.ee>
References: <alpine.LRH.2.11.1410151059520.8050@adalberg.ut.ee>
	<20141015.143624.941838991598108211.davem@davemloft.net>
	<alpine.LRH.2.11.1410152310080.11974@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Wed, 15 Oct 2014 23:11:34 +0300 (EEST)

>> >> The gcc-4.9 case is interesting, are you saying that a gcc-4.9 compiled
>> >> kernel works fine on other systems?
>> > 
>> > Yes, all USII based systems work fine with Debian gcc-4.9, as does 
>> > T2000. Of USIII* systems, V210 and V440 exhibit the boot hang with 
>> > gcc-4.9 and V480 crashes wit FATAL exception during boot that is 
>> > probably earlier than the gcc boot hang so I do not know about V480 and 
>> > gcc-4.9. V240 not tested because of fan failures, V245 is in the queue 
>> > for setup but not tested so far.
>> 
>> Ok, on the V210/V440 can you boot with "-p" on the kernel boot command
>> line and post the log?  Let's start by seeing how far it gets, maybe
>> we can figure out roughly where it dies.
> 
> http://www.spinics.net/lists/sparclinux/msg12238.html and 
> http://www.spinics.net/lists/sparclinux/msg12468.html are my relevant 
> posts about it. Should I get something more? It would be easy because of 
> ALOM.

Less information than I had hoped :-/

I thought it was hanging "during boot" meaning before we try to
execute userspace.  When in fact it seems to die exactly when we start
running the init process.

Wrt. disassembly of fault_in_user_windows(), that's not likely the
cause because if it were being miscompiled it would equally not work
on the other systems.

Something in the UltraSPARC-III specific code paths is going wrong
(either it is miscompiled, or the code makes an assumption that isn't
valid which has happened in the past).

Do you happen to have both gcc-4.9 and a previously working compiler
on these systems?  If you do, we can build a kernel with gcc-4.9 and
then selectively compile certain failes with the older working
compiler to narrow down what compiles into something non-working with
gcc-4.9

I would start with the following files:

	arch/sparc/mm/init_64.c
	arch/sparc/mm/tlb.c
	arch/sparc/mm/tsb.c
	arch/sparc/mm/fault_64.c

And failing that, go for various files under arch/sparc/kernel/ such as:

	arch/sparc/kernel/process_64.c
	arch/sparc/kernel/smp_64.c
	arch/sparc/kernel/sys_sparc_64.c
	arch/sparc/kernel/sys_sparc32.c
	arch/sparc/kernel/traps_64.c

Hopefully, this should be a simply matter of doing a complete build
with gcc-4.9, then removing the object file we want to selectively
build with the older compiler and then going:

	make CC="gcc-4.6" arch/sparc/mm/init_64.o

then relinking with plain 'make'.

If the build system rebuilds the object file on you when you try
to relink the final kernel image, we'll have to do some of this
by hand to make the test.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
