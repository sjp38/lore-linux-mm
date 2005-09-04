Message-ID: <431A4767.4030403@yahoo.com.au>
Date: Sun, 04 Sep 2005 11:01:27 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.13] lockless pagecache 2/7
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au>	 <4317F136.4040601@yahoo.com.au>	 <1125666486.30867.11.camel@localhost.localdomain>	 <p73k6hzqk1w.fsf@verdi.suse.de>  <4318C28A.5010000@yahoo.com.au>	 <1125705471.30867.40.camel@localhost.localdomain>	 <4318FF2B.6000805@yahoo.com.au> <1125768697.14987.7.camel@localhost.localdomain>
In-Reply-To: <1125768697.14987.7.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <ak@suse.de>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> On Sad, 2005-09-03 at 11:40 +1000, Nick Piggin wrote:
> 
>>We'll see how things go. I'm fairly sure that for my usage it will
>>be a win even if it is costly. It is replacing an atomic_inc_return,
>>and a read_lock/read_unlock pair.
> 
> 
> Make sure you bench both AMD and Intel - I'd expect it to be a big loss
> on AMD because the AMD stuff will perform atomic locked operations very
> efficiently if they are already exclusive on this CPU or a prefetch_w()
> on them was done 200+ clocks before.
> 

I will try to get numbers for both.

I would be surprised if it was a big loss... but I'm assuming
a locked cmpxchg isn't outlandishly expensive. Basically:

   read_lock_irqsave(cacheline1);
   atomic_inc_return(cacheline2);
   read_unlock_irqrestore(cacheline1);

Turns into

   atomic_cmpxchg();

I'll do some microbenchmarks and get back to you. I'm quite
interested now ;) What sort of AMDs did you have in mind,
Opterons?

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
