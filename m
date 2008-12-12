Return-Path: <linux-kernel-owner+w=401wt.eu-S1757939AbYLLHYU@vger.kernel.org>
Date: Fri, 12 Dec 2008 08:23:55 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] SLQB slab allocator
Message-ID: <20081212072355.GG15804@wotan.suse.de>
References: <20081212002518.GH8294@wotan.suse.de> <4941F8D2.4060807@cosmosbay.com> <20081212055051.GE15804@wotan.suse.de> <49420DAB.7090604@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <49420DAB.7090604@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 12, 2008 at 08:07:23AM +0100, Eric Dumazet wrote:
> Nick Piggin a écrit :
> > Is SLAB still bad at the test with the slab-rcu patch in place?
> > SLAB has a pretty optimal fastpath as well, although if its queues
> > start overflowing, it can run into contention quite easily.
> 
> Yes, I forgot I applied Christoph patch (SLAB_DESTROY_BY_RCU for struct file) 
> in the meantime, silly me, this was with the v2 of my serie, with only 5 patches.
> 
> With SLAB, results are quite good !
> 
> # time ./socketallocbench
> 
> real    0m1.201s
> user    0m0.071s
> sys     0m1.122s
> # time ./socketallocbench -n8
> 
> real    0m1.616s
> user    0m0.578s
> sys     0m12.220s

Yeah, SLAB is actually very hard to beat, much of the time.


> >> c0281e10 <kmem_cache_alloc>: /* kmem_cache_alloc total: 140659 10.8277 */
> > 
> > I guess you're compiling with -Os? I find gcc can pack the fastpath
> > much better with -O2, and actually decrease the effective icache
> > footprint size even if the total text size increases...
> 
> No, I dont use -Os, unless something got wrong
> 
> # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
> # CONFIG_OPTIMIZE_INLINING is not set

Oh OK. Hmm, you do have SLQB debugging compiled in by the looks. I
haven't really been looking at code generation in that case. I don't
expect that would cause a significant difference in your case,
though.

Anyway, I'll see if I can work out why SLQB is slower. Do you have
socketallocbench online?
