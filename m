Message-ID: <440CE797.1010303@yahoo.com.au>
Date: Tue, 07 Mar 2006 12:53:27 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] avoid atomic op on page free
References: <20060307001015.GG32565@linux.intel.com>
In-Reply-To: <20060307001015.GG32565@linux.intel.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@linux.intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:

>Hello Andrew et al,
>
>The patch below adds a fast path that avoids the atomic dec and test 
>operation and spinlock acquire/release on page free.  This is especially 
>important to the network stack which uses put_page() to free user 
>buffers.  Removing these atomic ops helps improve netperf on the P4 
>from ~8126Mbit/s to ~8199Mbit/s (although that number fluctuates quite a 
>bit with some runs getting 8243Mbit/s).  There are probably better 
>workloads to see an improvement from this on, but removing 3 atomics and 
>an irq save/restore is good.
>
>		-ben
>

You can't do this because you can't test PageLRU like that.

Have a look in the lkml archives a few months back, where I proposed
a way to do this for __free_pages(). You can't do it for put_page.

BTW I have quite a large backlog of patches in -mm which should end
up avoiding an atomic or two around these parts.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
