Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 62F865F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 23:28:51 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so833688wah.22
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 20:29:17 -0700 (PDT)
Message-ID: <49EBEBC0.8090102@gmail.com>
Date: Mon, 20 Apr 2009 11:28:00 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
References: <49E8292D.7050904@gmail.com>	<20090420084533.7f701e16.minchan.kim@barrios-desktop>	<49EBDADB.4040307@gmail.com> <20090420114236.dda3de34.minchan.kim@barrios-desktop>
In-Reply-To: <20090420114236.dda3de34.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Minchan Kim a??e??:
> On Mon, 20 Apr 2009 10:15:55 +0800
> Huang Shijie <shijie8@gmail.com> wrote:
>
>   
>> Minchan Kim a??e??:
>>     
>>> On Fri, 17 Apr 2009 15:01:01 +0800
>>> Huang Shijie <shijie8@gmail.com> wrote:
>>>
>>>   
>>>       
>>>>    I'm writting a driver for a video card with the V4L2 interface .
>>>>    V4L2 interface supports the USER-POINTER method for the video frame 
>>>> handling.
>>>>
>>>>    VLC player supports the USER-POINTER method,while MPALYER does not.
>>>>
>>>>    In the USER-POINTER method, VLC will call the posix_memalign() to 
>>>> allocate
>>>> 203 pages in certain PAL mode (that is 720*576*2) for a single frame.
>>>>    In my driver , I call the get_user_pages_fast() to obtain the pages 
>>>> array,and then call
>>>> the vmap() to map the pages to VMALLOC space for the memcpy().The code 
>>>> shows below:
>>>>    ....................
>>>>    get_user_pages_fast();
>>>>    ...
>>>>    f->data = vmap();
>>>>    .......................
>>>>     
>>>>         
>>> What I understand is that you get the pages of posix_memalign by get_user_pages_fast 
>>> and then that pages are mapped at kernel vmalloc space by vmap. 
>>>
>>> Is it for removing copy overhead from kernel to user ?
>>>
>>>   
>>>       
>> I need a large range of virtual contigous memory to store my video 
>> frame(about 203 pages). When I received a full frame ,I will queue the 
>> buffer in
>> a VIDIOC queue,which will be remove by the VIDIOC_DQBUF.'
>>     
>
> I can't understand your point. 
> Sorry for that. 
>
> Could you explain more detail relation (user buffer which is allocated by posix_memalign) and (kernel buffer which is mapped by vmap) ?
>
>   
:) sorry for my poor english.
[1] VLC uses the posix_memalign to allocate a big buffer for a single 
frame(203 pages).
[2] vmap sets up the mapping of virtual contigous address for gup()'s 
pages array(the pages are not consecutive).
   memcpy() needs a contiguous address to copy in kernel mode.
[3] my driver do some specail operations  to  received data, then 
memcopy the data to the buffer get in step [2].
[4] when the buffer is full ,I will give the the user process (VLC).

That's all.
>>>>    In comments, it said :
>>>> "
>>>> +/**
>>>> + * get_user_pages_fast() - pin user pages in memory
>>>> + * @start:     starting user address
>>>> + * @nr_pages:  number of pages from start to pin
>>>> + * @write:     whether pages will be written to
>>>> + * @pages:     array that receives pointers to the pages pinned.
>>>> + *             Should be at least nr_pages long.
>>>> "
>>>>
>>>>    But after I digged the code of kswap and the get_user_pages(called by 
>>>> get_user_pages_fast),
>>>> I did not find how the pages pinned in memory.I really need the pages 
>>>> pinned in memory.
>>>>
>>>>    Assume page A is one of the pages obtained by get_user_pages_fast() 
>>>> during page-fault.
>>>>
>>>> [1] page A will on the LRU_ACTIVE_ANON list;
>>>>    the _count of page A increment by one;
>>>>    PTE for page A will be set ACCESSED.
>>>>
>>>> [2] kswapd will scan the lru list,and move page A from LRU_ACTIVE_ANON  
>>>> to LRU_INACTIVE_ANON.
>>>>    In the shrink_page_list(), there is nothing can stop page A been 
>>>> swapped out.
>>>>    I don't think the page_reference() can move page A back to 
>>>> LRU_ACTIVE_ANON.In my driver,
>>>>    I am not sure if the VLC can access the page A.
>>>>
>>>>    Is this a bug? or I miss something?
>>>>    Thanks .
>>>>     
>>>>         
>>> If above my assumption is right, It's not a BUG. 
>>> You get the application's pages by get_user_pages_fast. 
>>> 'Page pinning' means it shouldn't be freed. 
>>> Application's pages always can be swapped out. 
>>> If you don't want to swap out the page, you should use mlock. 
>>> If you use mlock, kernel won't insert the page to lru [in]active list.
>>> So the page never can be swapped out. 
>>>
>>>   
>>>       
>> Yes, it not a bug .
>>
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
Yes, you are right. I missed the page_cache_release() in try_to_unmap().
:(
>> So ,there is no need to use the mlock, it will mess my driver.
>> is_page_cache_freeable()will return PAGE_KEEP, and page is locked in 
>> swap cache.
>>
>>     
>
> I can't understand your point exactly yet.
> But what I mean is following as in user mode
>
> posix_memalignq(&buffer);
> mlock(buffer,  buffer_len); 
>
>   
I also wish the VLC use  the mlock,but it does not.If it uses mlock(),
the pages will be put in LRU_UNEVICETABL LIST.

Maybe the programmer of VLC thinks: Why i add mlock, for the kernel has the
gup() which could pin the pages in memory?

> I will not dirty your driver. 
> Do I miss something ?
>
>   
I did add the Mlock bit to the VMA->vm_flags in my driver before,but I 
think that's ugly.



>> Unfortunately, the page is unmaped, and the PTE of the page has been 
>> replaced by a swp_entry_t .
>> When the process read the page ,it will raise a page fault again, the 
>> kernel will find the page in the
>> swap cache, and requeue the page in LRU_ACTIVE_ANON, ---I think it is a 
>> vicious circle for the kernel.
>>
>> I think there two places to put back the gup() pages.
>> <1> isolate_page_glable()
>> <2> in the shrink_page_list(), before called the try_to_unmap().
>> KOSAKI Motohiro 's patch takes effect in the second place.
>> I think the first place is better.
>>
>>
>>
>>
>>
>>
>>
>>
>>     
>
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
