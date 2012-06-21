Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 3E1166B00BB
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 07:07:09 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 915653EE0BD
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:07:07 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 780FF45DE50
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:07:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 571A545DD78
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:07:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 472C41DB803E
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:07:07 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F04DD1DB803C
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 20:07:06 +0900 (JST)
Message-ID: <4FE2FFDA.6000009@jp.fujitsu.com>
Date: Thu, 21 Jun 2012 20:04:58 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] don't do __ClearPageSlab before freeing slab page.
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206210103350.31077@chino.kir.corp.google.com> <4FE2D7B2.8060204@parallels.com>
In-Reply-To: <4FE2D7B2.8060204@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>

(2012/06/21 17:13), Glauber Costa wrote:
> On 06/21/2012 12:04 PM, David Rientjes wrote:
>> On Thu, 21 Jun 2012, Glauber Costa wrote:
>>
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index 6092f33..fdec73e 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -698,8 +698,10 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
>>>
>>> if (PageAnon(page))
>>> page->mapping = NULL;
>>> - for (i = 0; i < (1 << order); i++)
>>> + for (i = 0; i < (1 << order); i++) {
>>> + __ClearPageSlab(page + i);
>>> bad += free_pages_check(page + i);
>>> + }
>>> if (bad)
>>> return false;
>>>
>>> @@ -2561,6 +2563,7 @@ EXPORT_SYMBOL(get_zeroed_page);
>>> void __free_pages(struct page *page, unsigned int order)
>>> {
>>> if (put_page_testzero(page)) {
>>> + __ClearPageSlab(page);
>>> if (order == 0)
>>> free_hot_cold_page(page, 0);
>>> else
>>
>> These are called from a number of different places that has nothing to do
>> with slab so it's certainly out of place here. Is there really no
>> alternative way of doing this?
>
> Well, if the requirement is that we must handle this from the page allocator, how else should I know if I must call the corresponding free functions ?
>
> Also note that other bits are tested inside the page allocator as well, such as MLock.
>
> I saw no other way, but if you have suggestions, I'd be open to try them, of course.
>

I'm sorry I don't understand the logic enough well.

Why check in __free_pages() is better than check in callers of slab.c/slub.c ?

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
