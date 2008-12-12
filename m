Return-Path: <linux-kernel-owner+w=401wt.eu-S1757446AbYLLIGD@vger.kernel.org>
Message-ID: <49421B5D.7060207@cosmosbay.com>
Date: Fri, 12 Dec 2008 09:05:49 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch] SLQB slab allocator
References: <20081212002518.GH8294@wotan.suse.de> <4941F8D2.4060807@cosmosbay.com> <20081212055051.GE15804@wotan.suse.de> <49420DAB.7090604@cosmosbay.com> <20081212072355.GG15804@wotan.suse.de>
In-Reply-To: <20081212072355.GG15804@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin a écrit :
> On Fri, Dec 12, 2008 at 08:07:23AM +0100, Eric Dumazet wrote:
>> Nick Piggin a écrit :
>>> Is SLAB still bad at the test with the slab-rcu patch in place?
>>> SLAB has a pretty optimal fastpath as well, although if its queues
>>> start overflowing, it can run into contention quite easily.
>> Yes, I forgot I applied Christoph patch (SLAB_DESTROY_BY_RCU for struct file) 
>> in the meantime, silly me, this was with the v2 of my serie, with only 5 patches.
>>
>> With SLAB, results are quite good !
>>
>> # time ./socketallocbench
>>
>> real    0m1.201s
>> user    0m0.071s
>> sys     0m1.122s
>> # time ./socketallocbench -n8
>>
>> real    0m1.616s
>> user    0m0.578s
>> sys     0m12.220s
> 
> Yeah, SLAB is actually very hard to beat, much of the time.
> 
> 
>>>> c0281e10 <kmem_cache_alloc>: /* kmem_cache_alloc total: 140659 10.8277 */
>>> I guess you're compiling with -Os? I find gcc can pack the fastpath
>>> much better with -O2, and actually decrease the effective icache
>>> footprint size even if the total text size increases...
>> No, I dont use -Os, unless something got wrong
>>
>> # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
>> # CONFIG_OPTIMIZE_INLINING is not set
> 
> Oh OK. Hmm, you do have SLQB debugging compiled in by the looks. I
> haven't really been looking at code generation in that case. I don't
> expect that would cause a significant difference in your case,
> though.
> 

One thing that might give a difference is to not use kmem_cache_zalloc()
in get_empty_filp(), because on 32bits, sizeof(struct file)=132

So kmem_cache_zalloc() clears 192 bytes, while if done by a memset()
inside get_empty_filp(), we would clear 132 bytes exactly.

OK, I tried without SLQB debugging and got :

# time ./socketallocbench

real    0m1.261s
user    0m0.078s
sys     0m1.183s
# time ./socketallocbench -n 8

real    0m1.640s
user    0m0.638s
sys     0m12.346s


> Anyway, I'll see if I can work out why SLQB is slower. Do you have
> socketallocbench online?


Well, it's so trivial, you probably can code it in perl or whatever in 4 lines :)

its a basic

	for (i = 0; i < 1000000; i++)
		close(socket(AF_INET, SOCK_STREAM, 0));

and -n 8 starts 8 processes doing this same loop in //
