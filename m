Message-ID: <461492A5.1030905@cosmosbay.com>
Date: Thu, 05 Apr 2007 08:09:41 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com>	<20070403202937.GE355@devserv.devel.redhat.com>	<20070403144948.fe8eede6.akpm@linux-foundation.org>	<4612DCC6.7000504@cosmosbay.com>	<46130BC8.9050905@yahoo.com.au>	<1175675146.6483.26.camel@twins>	<461367F6.10705@yahoo.com.au>	<20070404113447.17ccbefa.dada1@cosmosbay.com>	<46137882.6050708@yahoo.com.au> <20070404135458.4f1a7059.dada1@cosmosbay.com> <4614585F.1050200@yahoo.com.au>
In-Reply-To: <4614585F.1050200@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin a ecrit :
> Eric Dumazet wrote:
> >> This was not a working patch, just to throw the idea, since the
>> answers I got showed I was not understood.
>>
>> In this case, find_extend_vma() should of course have one struct 
>> vm_area_cache * argument, like find_vma()
>>
>> One single cache on one mm is not scalable. oprofile badly hits it on 
>> a dual cpu config.
> 
> Oh, what sort of workload are you using to show this? The only reason 
> that I
> didn't submit my thread cache patches was that I didn't show a big enough
> improvement.
> 

Database workload, where the user multi threaded app is constantly accessing 
GBytes of data, so L2 cache hit is very small. If you want to oprofile it, 
with say a CPU_CLK_UNHALTED:5000 event, then find_vma() is in the top 5.

Each time oprofile has an NMI, it calls find_vma(EIP/RIP) and blows out the 
target process cache (usually plugged on the data vma containing user land 
futexes). Event with private futexes, it will probably be plugged on the brk() 
vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
