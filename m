Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 111CB6B009F
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 02:09:56 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so1316628wah.22
        for <linux-mm@kvack.org>; Tue, 21 Apr 2009 23:10:05 -0700 (PDT)
Message-ID: <49EEB46D.90802@gmail.com>
Date: Wed, 22 Apr 2009 14:08:45 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
References: <49E8292D.7050904@gmail.com>	<20090420084533.7f701e16.minchan.kim@barrios-desktop>	<49EBDADB.4040307@gmail.com> <20090420114236.dda3de34.minchan.kim@barrios-desktop>
In-Reply-To: <20090420114236.dda3de34.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

 
>> I read the kernel code again. In my case ,the kernel will pin the pages 
>> in memory.
>> I missed function is_page_cache_freeable() in the pageout().
>>
>> In my case, is_page_cache_freeable()will return false ,for 
>> page_count(page) is 3 now:
>> <1> one is from alloc_page_* in page fault.
>> <2> one is from get_usr_pages()
>> <3> one is from add_to_swap() in shrink_page_list()
>>     
>
> One more, try_to_unmap will call page_cache_release. 
> So, count is 2. 
>
>   
I found I missed something.When code reachs is_page_cache_freeable(). 
page_count(page) is 3:

<1> alloc_page_* in page fault . [page count is 1]
<2> get_usr_pages().             [page count is 2]
<3> isolate_pages_global()	 [page count is 3]
<4> add_to_swap()                [page count is 4]
<5> try_to_unmap()               [page count is 3]

so it not a bug, just a vicious circle.

Do i miss something?
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
