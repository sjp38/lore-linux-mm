Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
References: <Pine.LNX.4.21.0006132355560.7792-100000@inspiron.random>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Andrea Arcangeli's message of "Wed, 14 Jun 2000 01:07:23 +0200 (CEST)"
Date: 14 Jun 2000 01:41:42 +0200
Message-ID: <ytthfax87yh.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

>>>>> "andrea" == Andrea Arcangeli <andrea@suse.de> writes:

Hi

andrea> How can you be sure of that? So I'll make you an obvious case where
andrea> it will shrink not twice, not three times but _forever_.

andrea> Assume the pages_min of the normal zone watermark triggers when the normal
andrea> zone is allocated at 95% and assume that all such 95% of the normal zone
andrea> is been allocated all in mlocked memory and kernel mem_map_t array. Can't
andrea> somebody (for example an oracle database) allocate 95% of the normal zone
andrea> in mlocked shm memory? Do you agree? Or you are telling me it can't or
andrea> that if it does so it should then expect the linux kernel to explode
andrea> (actually it would cause kswapd to loop forever trying to free the normal
andrea> zone even if there's still 15mbyte of ZONE_DMA memory free).

andrea> So let's make the whole picture from the start starting with all the
andrea> memory free: assume oracle allocates all the normal zone in shm mlocked
andrea> memory. You still have 15mbyte free for the cache in the ZONE_DMA, OK?
andrea> Then you allocate the 95% of such 15mbyte in the cache and then kswapd
andrea> triggers and it will never stop because it will try to free the
andrea> zone_normal forever, even if it just recycled enough memory from the
andrea> ZONE_DMA (so even if __alloc_pages wouldn't start memory balancing
andrea> anymore!). See????

andrea> The classzone patch will fix the above bad behaviour completly because
andrea> kswapd in classzone will notice that there's enough memory for allocation
andrea> from both ZONE_DMA and ZONE_NORMAL because the cache in the ZONE_DMA is
andrea> been recycled successfully.

andrea> Without classzone you'll always get the above case wrong and I don't mind
andrea> if it's a corner case or not, we have to handle it right! I will hate a
andrea> kernel that works fine only as far as you only compile kernels on it.

I think that if you have a program that mlocked 95% of your normal
memory you have two options:
       - tweak the values of freepages.{min,low,high}
       - buy more memory

What is the difference with the case where we mlocked *all* memory.
If we allocate all memory we don't expect the system to work.  Pass
one limit, there is no way to solve the problem.  The limit just now
in freepages.high.  If you don't like that limit, change it.

Notice also that the actual allocator will give the shm segment pages
in the DMA zone and in the normal zone, that the case that it
allocates all the NORMAL zone but nothing of the DMA zone is not the
normal case, nor should happend.  It should get their pages from the
DMA zone and the NORMAL zone.  If we have the 95% of the DMA zone and
the 95% of the NORMAL zone mlocked, we are really in problems....

>> I think you're overlooking the fact that kswapd's freeing of
>> pages is something that occurs only *once*...

andrea> Since the normal zone will never return over pages_low it will run more
andrea> than once.

as I told before, if you want to have 95% of your memory mlocked, you
should tweak the values of freepages.*

andrea> My argument of the classzone design is to get correctness in the corner
andrea> case: to fix the drawbacks.

andrea> Then I also included into such patch some performance stuff and that's why
andrea> it also improve performances siginficantly but I'm not interested about
andrea> such part for now. Since such part is stable as well you can get both
andrea> correctness and improvement at the same time but I can drop the
andrea> performance part if there will be an interest only on the other part.

At least _I_ am interested in *only* the performance part.  I would
like to test the actual aproach with your performance improvements and
then compare the design.  I conceptually preffer the zones desing, but
I can be proved wrong.

andrea> I don't mind about the other part of the email at this moment, I only mind
andrea> about the global design of the allocator at this moment.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
