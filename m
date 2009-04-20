Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C3EF95F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 22:23:46 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so1288969rvb.26
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 19:23:47 -0700 (PDT)
Message-ID: <49EBDC67.2060204@gmail.com>
Date: Mon, 20 Apr 2009 10:22:31 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
References: <49E8292D.7050904@gmail.com> <20090418151620.1258.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090418151620.1258.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro a??e??:
> Hi
>
>   
>> "
>> +/**
>> + * get_user_pages_fast() - pin user pages in memory
>> + * @start:     starting user address
>> + * @nr_pages:  number of pages from start to pin
>> + * @write:     whether pages will be written to
>> + * @pages:     array that receives pointers to the pages pinned.
>> + *             Should be at least nr_pages long.
>> "
>>
>>    But after I digged the code of kswap and the get_user_pages(called by 
>> get_user_pages_fast),
>> I did not find how the pages pinned in memory.I really need the pages 
>> pinned in memory.
>>
>>    Assume page A is one of the pages obtained by get_user_pages_fast() 
>> during page-fault.
>>
>> [1] page A will on the LRU_ACTIVE_ANON list;
>>    the _count of page A increment by one;
>>    PTE for page A will be set ACCESSED.
>>
>> [2] kswapd will scan the lru list,and move page A from LRU_ACTIVE_ANON  
>> to LRU_INACTIVE_ANON.
>>    In the shrink_page_list(), there is nothing can stop page A been 
>> swapped out.
>>    I don't think the page_reference() can move page A back to 
>> LRU_ACTIVE_ANON.In my driver,
>>    I am not sure if the VLC can access the page A.
>>
>>    Is this a bug? or I miss something?
>>    Thanks .
>>     
>
> BUG.
>
> We are talking about it just now.
>
> see the following thread in lkml
> 	"[RFC][PATCH 0/6] IO pinning(get_user_pages()) vs fork race fix"
>
>   
thanks, I read the thread as well as your patch.
What about to put the gup() page back in the isolate_pages_global()?
> but unfortunately, we don't have no painful fix. perhaps you need change
> your code...
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
