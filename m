Message-ID: <404D06AA.6070100@cyberone.com.au>
Date: Tue, 09 Mar 2004 10:50:02 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: blk_congestion_wait racy?
References: <OF335311D8.7BCE1E48-ONC1256E51.0049DBF1-C1256E51.004AEA2A@de.ibm.com>
In-Reply-To: <OF335311D8.7BCE1E48-ONC1256E51.0049DBF1-C1256E51.004AEA2A@de.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:

>
>
>
>>Gad, that'll make the VM scan its guts out.
>>
>Yes, I expected something like this.
>
>
>>>2.6.4-rc2 + "fix" with 1 cpu
>>>sys     0m0.880s
>>>
>>>2.6.4-rc2 + "fix" with 2 cpu
>>>sys     0m1.560s
>>>
>>system time was doubled though.
>>
>That would be the additional cost for not waiting.
>
>

I'd say its more like cacheline contention or something: reclaim
won't simply be spinning with nothing to do because you're dirtying
plenty of memory. And if any queues were full it will mostly just be
blocking in the block layer.

>>Nope, something is obviously broken.   I'll take a look.
>>
>That would be very much appreciated.
>

I'm looking at 2.6.1 source, so apologies if I'm wrong, but
drivers/block/ll_rw_blk.c:
freed_request does not need the memory barrier because the queue is
protected by the per queue spinlock. And I think clear_queue_congested
should have a memory barrier right before if (waitqueue_active(wqh)).

Another problem is that if there are no requests anywhere in the system,
sleepers in blk_congestion_wait will not get kicked. blk_congestion_wait
could probably have blk_run_queues moved after prepare_to_wait, which
might help.

Just some ideas.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
