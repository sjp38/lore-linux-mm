Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1E9E15F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 01:06:49 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so1326150rvb.26
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 22:06:54 -0700 (PDT)
Message-ID: <49EC029D.1060807@gmail.com>
Date: Mon, 20 Apr 2009 13:05:33 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
References: <49E8292D.7050904@gmail.com>	<20090420084533.7f701e16.minchan.kim@barrios-desktop>	<49EBDADB.4040307@gmail.com>	<20090420114236.dda3de34.minchan.kim@barrios-desktop>	<49EBEBC0.8090102@gmail.com> <20090420135323.08015e32.minchan.kim@barrios-desktop>
In-Reply-To: <20090420135323.08015e32.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Minchan Kim a??e??:
> On Mon, 20 Apr 2009 11:28:00 +0800
> Huang Shijie <shijie8@gmail.com> wrote:
>
> I will summarize your method. 
> Is right ?
>
>
> kernel(driver)					application 
>
> 						posix_memalign(buffer)
> 						ioctl(buffer)
>
> ioctl handler
> get_user_pages(pages);
> /* This pages are mapped at user's vma' 
> address space */
> vaddr = vmap(pages);
> /* This pages are mapped at vmalloc space */
> .
> .
> <after sometime, 
> It may change to other process context>
> .
> .
> interrupt handler in your driver 
> memcpy(vaddr, src, len); 
> notify_user();
>
> 						processing(buffer);
>
> It's rather awkward use case of get_user_pages. 
>
> If you want to share one big buffer between kernel and user, 
> You can vmalloc and remap_pfn_range.
>   
The v4l2 method IO_METHOD_MMAP does use the vmaloc() method you told above ,
our driver also support this method,we user vmalloc /remap_vmalloc_range().

But the v4l2 method IO_METHOD_USERPTR must use the method I told above.
> You can refer cpia_mmap in drivers/media/video/cpia.c
>  
>
>
>   
>> Minchan Kim a??e??:
>>     
>>> On Mon, 20 Apr 2009 10:15:55 +0800
>>> Huang Shijie <shijie8@gmail.com> wrote:
>>>
>>>   
>>>       
>>>> Minchan Kim a??e??:
>>>>     
>>>>         
>>>>> On Fri, 17 Apr 2009 15:01:01 +0800
>>>>> Huang Shijie <shijie8@gmail.com> wrote:
>>>>>
>>>>>   
>>>>>       
>>>>>           
>>>>>>    I'm writting a driver for a video card with the V4L2 interface .
>>>>>>    V4L2 interface supports the USER-POINTER method for the video frame 
>>>>>> handling.
>>>>>>
>>>>>>    VLC player supports the USER-POINTER method,while MPALYER does not.
>>>>>>
>>>>>>    In the USER-POINTER method, VLC will call the posix_memalign() to 
>>>>>> allocate
>>>>>> 203 pages in certain PAL mode (that is 720*576*2) for a single frame.
>>>>>>    In my driver , I call the get_user_pages_fast() to obtain the pages 
>>>>>> array,and then call
>>>>>> the vmap() to map the pages to VMALLOC space for the memcpy().The code 
>>>>>> shows below:
>>>>>>    ....................
>>>>>>    get_user_pages_fast();
>>>>>>    ...
>>>>>>    f->data = vmap();
>>>>>>    .......................
>>>>>>     
>>>>>>         
>>>>>>             
>>>>> What I understand is that you get the pages of posix_memalign by get_user_pages_fast 
>>>>> and then that pages are mapped at kernel vmalloc space by vmap. 
>>>>>
>>>>> Is it for removing copy overhead from kernel to user ?
>>>>>
>>>>>   
>>>>>       
>>>>>           
>>>> I need a large range of virtual contigous memory to store my video 
>>>> frame(about 203 pages). When I received a full frame ,I will queue the 
>>>> buffer in
>>>> a VIDIOC queue,which will be remove by the VIDIOC_DQBUF.'
>>>>     
>>>>         
>>> I can't understand your point. 
>>> Sorry for that. 
>>>
>>> Could you explain more detail relation (user buffer which is allocated by posix_memalign) and (kernel buffer which is mapped by vmap) ?
>>>
>>>   
>>>       
>> :) sorry for my poor english.
>> [1] VLC uses the posix_memalign to allocate a big buffer for a single 
>> frame(203 pages).
>> [2] vmap sets up the mapping of virtual contigous address for gup()'s 
>> pages array(the pages are not consecutive).
>>    memcpy() needs a contiguous address to copy in kernel mode.
>> [3] my driver do some specail operations  to  received data, then 
>> memcopy the data to the buffer get in step [2].
>> [4] when the buffer is full ,I will give the the user process (VLC).
>>
>> That's all.
>>     
>
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
