Message-ID: <46D66D40.4040302@yahoo.com.au>
Date: Thu, 30 Aug 2007 17:09:52 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Selective swap out of processes
References: <1188320070.11543.85.camel@bastion-laptop>	 <46D4DBF7.7060102@yahoo.com.au> <1188383827.11270.36.camel@bastion-laptop>
In-Reply-To: <1188383827.11270.36.camel@bastion-laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?UTF-8?B?SmF2aWVyIENhYmV6YXMg77+9?= <jcabezas@ac.upc.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Javier Cabezas RodrA-guez wrote:
> El miA(C), 29-08-2007 a las 12:37 +1000, Nick Piggin escribiA3:
> 
>>Simplest will be just to set referenced to 0 right after calling
>>page_referenced, in the case you want to forcefully swap out the
>>page.
>>
>>try_to_unmap will get called later in the same function.
> 
> 
> I have tried this solution, but 0 pages are freed...
> 
> - RO/EXEC pages mapped from the executable are now skipped due to this
> check:
> 
> if (!mapping || !remove_mapping(mapping, page))
> 	goto keep_locked;
> 
> The offender is this check in remove_mapping:
> 
> if (unlikely(page_count(page) != 2))
> 	goto cannot_free;
> 
> - RW pages mapped from the executable are skipped because pageout
> returns PAGE_KEEP.
> 
> - Other pages are skipped because try_to_unmap returns SWAP_FAIL.

You still actually have to call page_referenced to clear the young
bits in the ptes, right? That should prevent try_to_unmap returning
SWAP_FAIL. It can be mapped by multiple processes, so just clearing
the young bit for one pte won't help (especially for exec pages,
which are very likely to be used by more than one process).

If your page_count is elevated after the page has been unmapped,
then there is something else using the page or your function isn't
doing the correct refcounting.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
