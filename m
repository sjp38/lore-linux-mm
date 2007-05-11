Message-ID: <46449F61.2060004@cosmosbay.com>
Date: Fri, 11 May 2007 18:52:49 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] convert mmap_sem to a scalable rw_mutex
References: <20070511131541.992688403@chello.nl> <20070511155621.GA13150@elte.hu>
In-Reply-To: <20070511155621.GA13150@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Ingo Molnar a ecrit :
> * Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
>> I was toying with a scalable rw_mutex and found that it gives ~10% 
>> reduction in system time on ebizzy runs (without the MADV_FREE patch).
>>
>> 2-way x86_64 pentium D box:
>>
>> 2.6.21
>>
>> /usr/bin/time ./ebizzy -m -P
>> 59.49user 137.74system 1:49.22elapsed 180%CPU (0avgtext+0avgdata 0maxresident)k
>> 0inputs+0outputs (0major+33555877minor)pagefaults 0swaps
>>
>> 2.6.21-rw_mutex
>>
>> /usr/bin/time ./ebizzy -m -P
>> 57.85user 124.30system 1:42.99elapsed 176%CPU (0avgtext+0avgdata 0maxresident)k
>> 0inputs+0outputs (0major+33555877minor)pagefaults 0swaps
> 
> nice! This 6% runtime reduction on a 2-way box will i suspect get 
> exponentially better on systems with more CPUs/cores.

As long you only have readers, yes.

But I personally find this new rw_mutex not scalable at all if you have some 
writers around.

percpu_counter_sum is just a L1 cache eater, and O(NR_CPUS)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
