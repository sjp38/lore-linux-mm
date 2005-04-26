Date: Mon, 25 Apr 2005 20:57:06 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: VM 5/8 async-writepage
Message-Id: <20050425205706.55fe9833.akpm@osdl.org>
In-Reply-To: <16994.40662.865338.484778@gargle.gargle.HOWL>
References: <16994.40662.865338.484778@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
>  Perform some calls to the ->writepage() asynchronously.
> 
>  VM scanner starts pageout for dirty pages found at tail of the inactive list
>  during scan. It is supposed (or at least desired) that under normal conditions
>  amount of such write back is small.
> 
>  Even if few pages are paged out by scanner, they still stall "direct reclaim"
>  path (__alloc_pages()->try_to_free_pages()->...->shrink_list()->writepage()),
>  and to decrease allocation latency it makes sense to perform pageout
>  asynchronously.
> 
>  Current design is very simple: at the boot-up fixed number of pageout threads
>  is started. If shrink_list() decides that page is eligible for the
>  asynchronous pageout, it is placed into shared queue and later processed by
>  one of pageout threads.
> 
>  Most interesting part of this patch is async_writepage() that decides when
>  page should be paged out asynchronously.

I don't understand this at all.  ->writepage() is _already_ asynchronous. 
It will only block under rare circumstances such as needing to perform a
metadata read or encountering disk queue congestion.

In a way, kswapd already does what these new threads are supposed to do
anyway.  If you were to do your PG_skipped trick with direct-reclaim
threads and not with kswapd then you'd get a smiliar effect to this patch,
no?

Anyway, I'll cautiously take a pass on this patch.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
