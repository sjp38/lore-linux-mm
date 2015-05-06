Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 013D56B0032
	for <linux-mm@kvack.org>; Wed,  6 May 2015 16:27:47 -0400 (EDT)
Received: by qgeb100 with SMTP id b100so10908259qge.3
        for <linux-mm@kvack.org>; Wed, 06 May 2015 13:27:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f8si2109085qkh.5.2015.05.06.13.27.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 13:27:46 -0700 (PDT)
Message-ID: <554A793F.3070001@redhat.com>
Date: Wed, 06 May 2015 13:27:43 -0700
From: Alexander Duyck <alexander.h.duyck@redhat.com>
MIME-Version: 1.0
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>	<20150504231448.1538.84164.stgit@ahduyck-vm-fedora22> <20150506123840.312f41000e8d46f1ef9ce046@linux-foundation.org>
In-Reply-To: <20150506123840.312f41000e8d46f1ef9ce046@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>



On 05/06/2015 12:38 PM, Andrew Morton wrote:
> On Mon, 04 May 2015 16:14:48 -0700 Alexander Duyck <alexander.h.duyck@redhat.com> wrote:
>
>> +/**
>> + * skb_free_frag - free a page fragment
>> + * @head: virtual address of page fragment
>> + *
>> + * Frees a page fragment allocated out of either a compound or order 0 page.
>> + * The function itself is a hybrid between free_pages and free_compound_page
>> + * which can be found in mm/page_alloc.c
>> + */
>> +void skb_free_frag(void *head)
>> +{
>> +	struct page *page = virt_to_head_page(head);
>> +
>> +	if (unlikely(put_page_testzero(page))) {
>> +		if (likely(PageHead(page)))
>> +			__free_pages_ok(page, compound_order(page));
>> +		else
>> +			free_hot_cold_page(page, false);
>> +	}
>> +}
> Why are we testing for PageHead in here?  If the code were to simply do
>
> 	if (unlikely(put_page_testzero(page)))
> 		__free_pages_ok(page, compound_order(page));
>
> that would still work?

My assumption was that there was a performance difference between 
__free_pages_ok and free_hot_cold_page for order 0 pages.  From what I 
can tell free_hot_cold_page will do bulk cleanup via free_pcppages_bulk 
while __free_pages_ok just calls free_one_page.

> There's nothing networking-specific in here.  I suggest the function be
> renamed and moved to page_alloc.c.  Add an inlined skb_free_frag() in a
> net header which calls it.  This way the mm developers know about it
> and will hopefully maintain it.  It would need a comment explaining
> when and why people should and shouldn't use it.

That's true.  While I am at it I should probably pull the allocation out 
as well just so it is all in one location.

> The term "page fragment" is a net thing and isn't something we know
> about.  What is it?  From context I'm thinking a definition would look
> something like
>
>    An arbitrary-length arbitrary-offset area of memory which resides
>    within a 0 or higher order page.  Multiple fragments within that page
>    are individually refcounted, in the page's reference counter.
>
> Is that correct and complete?

Yeah that is pretty complete.  I've added Eric who originally authored 
this to the Cc in case there is something he wants to add. I'll see 
about updating this and will likely have a v2 ready in the next couple 
of hours.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
