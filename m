Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 998C86B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 05:42:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so62380581wmr.0
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 02:42:47 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0129.outbound.protection.outlook.com. [104.47.1.129])
        by mx.google.com with ESMTPS id qd5si2405728wjb.196.2016.07.04.02.42.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Jul 2016 02:42:45 -0700 (PDT)
Subject: Re: [PATCH v3] kasan/quarantine: fix bugs on qlist_move_cache()
References: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
 <57767B66.7070904@virtuozzo.com> <20160704043647.GA14840@js1304-P5Q-DELUXE>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <577A2FD0.4040800@virtuozzo.com>
Date: Mon, 4 Jul 2016 12:43:44 +0300
MIME-Version: 1.0
In-Reply-To: <20160704043647.GA14840@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 07/04/2016 07:36 AM, Joonsoo Kim wrote:
> On Fri, Jul 01, 2016 at 05:17:10PM +0300, Andrey Ryabinin wrote:
>>
>>
>> On 07/01/2016 05:02 PM, js1304@gmail.com wrote:
>>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>>
>>> There are two bugs on qlist_move_cache(). One is that qlist's tail
>>> isn't set properly. curr->next can be NULL since it is singly linked
>>> list and NULL value on tail is invalid if there is one item on qlist.
>>> Another one is that if cache is matched, qlist_put() is called and
>>> it will set curr->next to NULL. It would cause to stop the loop
>>> prematurely.
>>>
>>> These problems come from complicated implementation so I'd like to
>>> re-implement it completely. Implementation in this patch is really
>>> simple. Iterate all qlist_nodes and put them to appropriate list.
>>>
>>> Unfortunately, I got this bug sometime ago and lose oops message.
>>> But, the bug looks trivial and no need to attach oops.
>>>
>>> v3: fix build warning
>>>
>>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>> ---
>>>  mm/kasan/quarantine.c | 21 +++++++--------------
>>>  1 file changed, 7 insertions(+), 14 deletions(-)
>>>
>>> diff --git a/mm/kasan/quarantine.c b/mm/kasan/quarantine.c
>>> index 4973505..cf92494 100644
>>> --- a/mm/kasan/quarantine.c
>>> +++ b/mm/kasan/quarantine.c
>>> @@ -238,30 +238,23 @@ static void qlist_move_cache(struct qlist_head *from,
>>>  				   struct qlist_head *to,
>>>  				   struct kmem_cache *cache)
>>>  {
>>> -	struct qlist_node *prev = NULL, *curr;
>>> +	struct qlist_node *curr;
>>>  
>>>  	if (unlikely(qlist_empty(from)))
>>>  		return;
>>>  
>>>  	curr = from->head;
>>> +	qlist_init(from);
>>>  	while (curr) {
>>>  		struct qlist_node *qlink = curr;
>>
>> Can you please also get rid of either qlink or curr.
>> Those are essentially the same pointers.
> 
> Hello,
> 
> Before putting the qlist_node to the list, we need to calculate
> curr->next and remember it to iterate the list. I use curr
> for this purpose so qlink and curr are not the same pointer.
> 

Right, I missed the fact that qlist_put() changes ->next pointer, thus we  can't fetch ->next after qlist_put().

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
