Message-ID: <40D358C5.9060003@colorfullife.com>
Date: Fri, 18 Jun 2004 23:04:05 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH]: Option to run cache reap in thread mode
References: <40D08225.6060900@colorfullife.com>	<20040616180208.GD6069@sgi.com>	<40D09872.4090107@colorfullife.com>	<20040617131031.GB8473@sgi.com>	<20040617214035.01e38285.akpm@osdl.org>	<20040618143332.GA11056@sgi.com> <20040618134045.2b7ce5c5.akpm@osdl.org>
In-Reply-To: <20040618134045.2b7ce5c5.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>, linux-kernel@vger.kernel.org, lse-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>Dimitri Sivanich <sivanich@sgi.com> wrote:
>  
>
>>At the time of the holdoff (the point where we've spent a total of 30 usec in
>>the timer_interrupt), we've looped through more than 100 of the 131 caches,
>>usually closer to 120.
>>    
>>
>
>ahh, ooh, ow, of course.
>
>Manfred, we need a separate list of "slabs which might need reaping".
>  
>
A cache that might need reaping is a cache that has seen at least one 
kmem_cache_free(). The list would trade less time in the timer context 
at the expense of slower kmem_cache_free calls. I'm fairly certain that 
this would be end up as a big net loss.

>That'll help the average case.  To help the worst case we should change
>cache_reap() to only reap (say) ten caches from the head of the new list
>and to then return.
>
I'll write something:
- allow to disable the DMA kmalloc caches for archs that do not need them.
- increase the timer frequency and scan only a few caches in each timer.
- perhaps a quicker test for cache_reap to notice that nothing needs to 
be done. Right now four tests are done (!flags & _NO_REAP, 
ac->touched==0, ac->avail != 0, global timer not yet expired). It's 
possible to skip some tests. e.g. move the _NO_REAP caches on a separate 
list, replace the time_after(.next_reap,jiffies) with a separate timer.

--
    Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
