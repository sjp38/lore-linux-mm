Message-ID: <404EA645.8010900@cyberone.com.au>
Date: Wed, 10 Mar 2004 16:23:17 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: blk_congestion_wait racy?
References: <OFAAC6B1AC.5886C5F2-ONC1256E52.0061A30B-C1256E52.0062656E@de.ibm.com>
In-Reply-To: <OFAAC6B1AC.5886C5F2-ONC1256E52.0061A30B-C1256E52.0062656E@de.ibm.com>
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
>Hi Nick,
>
>
>>Another problem is that if there are no requests anywhere in the system,
>>sleepers in blk_congestion_wait will not get kicked. blk_congestion_wait
>>could probably have blk_run_queues moved after prepare_to_wait, which
>>might help.
>>
>I tried putting blk_run_queues after prepare_to_wait, it worked but it
>didn't help. The test still needs close to a minute.
>
>

OK. This was *with* the memory barrier changes too, was it? Not that
they should make that much difference. The test is still racy, but
the window just gets smaller.

But I'm guessing that you have no requests in flight by the time
blk_congestion_wait gets called, so nothing ever gets kicked.

I prefer something more like this model: if 'current' submits a request
to a congested queue then it gets put on the congestion waitqueue.
You can then run blk_congestion_wait afterwards and it won't block if
the queue you've written to has come out of congestion at any time.

This also means that you can (should, in fact) stop uncongested queues
from waking up the waiters every time they complete a request. Hmm, I
like it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
