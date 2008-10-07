Message-ID: <48EB62F9.9040409@linux-foundation.org>
Date: Tue, 07 Oct 2008 08:24:09 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH next 1/3] slub defrag: unpin writeback pages
References: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0810050319001.22004@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> A repetitive swapping load on powerpc G5 went progressively slower after
> nine hours: Inactive(file) was rising, as if inactive file pages pinned.
> Yes, slub defrag's kick_buffers() was forgetting to put_page() whenever
> it met a page already under writeback.

Thanks for finding that.

> That PageWriteback test should be made while PageLocked in trigger_write(),
> just as it is in try_to_free_buffers() - if there are complex reasons why
> that's not actually necessary, I'd rather not have to think through them.
> A preliminary check before taking the lock?  No, it's not that important.

The writeback check in kick_buffers() is a performance optimization. If the
page is under writeback then there is no point in trying to kick out the page.
That will only succeed after writeback is complete.

If a page is under writeback then try_to_free_buffers() will fail immediately.
So no need to check under pagelock.


> And trigger_write() must remember to unlock_page() in each of the cases
> where it doesn't reach the writepage().

Ack.


> --- 2.6.27-rc7-mmotm/fs/buffer.c	2008-09-26 13:18:50.000000000 +0100
> +++ linux/fs/buffer.c	2008-10-03 19:43:44.000000000 +0100
> @@ -3354,13 +3354,16 @@ static void trigger_write(struct page *p
>  		.for_reclaim = 0
>  	};
>  
> +	if (PageWriteback(page))
> +		goto unlock;
> +

Is that necessary? Wont writepage do the appropriate thing?


  >  /*
> @@ -3420,7 +3423,7 @@ static void kick_buffers(struct kmem_cac
>  	for (i = 0; i < nr; i++) {
>  		page = v[i];
>  
> -		if (!page || PageWriteback(page))
> +		if (!page)
>  			continue;

Thats just an optimization. No need to lock a page if its under writeback
which would make try_to_free_buffers() fail.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
