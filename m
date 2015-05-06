Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9DF6B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 16:55:47 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so15009602qkg.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 13:55:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d63si1302564qgd.60.2015.05.06.13.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 13:55:46 -0700 (PDT)
Message-ID: <554A7FC9.5010506@redhat.com>
Date: Wed, 06 May 2015 13:55:37 -0700
From: Alexander Duyck <alexander.h.duyck@redhat.com>
MIME-Version: 1.0
Subject: Re: [net-next PATCH 1/6] net: Add skb_free_frag to replace use of
 put_page in freeing skb->head
References: <20150504231000.1538.70520.stgit@ahduyck-vm-fedora22>	<20150504231448.1538.84164.stgit@ahduyck-vm-fedora22>	<20150506123840.312f41000e8d46f1ef9ce046@linux-foundation.org>	<554A793F.3070001@redhat.com> <20150506134102.b01faad32e07ff3d308e1a09@linux-foundation.org>
In-Reply-To: <20150506134102.b01faad32e07ff3d308e1a09@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>



On 05/06/2015 01:41 PM, Andrew Morton wrote:
> On Wed, 06 May 2015 13:27:43 -0700 Alexander Duyck <alexander.h.duyck@redhat.com> wrote:
>
>>>> +void skb_free_frag(void *head)
>>>> +{
>>>> +	struct page *page = virt_to_head_page(head);
>>>> +
>>>> +	if (unlikely(put_page_testzero(page))) {
>>>> +		if (likely(PageHead(page)))
>>>> +			__free_pages_ok(page, compound_order(page));
>>>> +		else
>>>> +			free_hot_cold_page(page, false);
>>>> +	}
>>>> +}
>>> Why are we testing for PageHead in here?  If the code were to simply do
>>>
>>> 	if (unlikely(put_page_testzero(page)))
>>> 		__free_pages_ok(page, compound_order(page));
>>>
>>> that would still work?
>> My assumption was that there was a performance difference between
>> __free_pages_ok and free_hot_cold_page for order 0 pages.  From what I
>> can tell free_hot_cold_page will do bulk cleanup via free_pcppages_bulk
>> while __free_pages_ok just calls free_one_page.
> Could be.  Plus there's hopefully some performance advantage if the
> page is genuinely cache-hot.  I don't think that anyone has verified
> the benefits of the hot/cold optimisation in the last decade or two,
> and it was always pretty marginal..

Either way it doesn't make much difference.  If you would prefer I can 
probably just call __free_pages_ok for all cases.

> Is the PageHead thing really "likely"?  We're usually dealing with
> order>0 pages here?

On any system that only supports 4K pages the default is to allocate an 
order 3 page (32K) and then pull the fragments out of that.  So if 
__free_pages_ok works for an order 0 page I'll just call it since it 
shouldn't be a very common occurrence anyway unless we are under memory 
pressure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
