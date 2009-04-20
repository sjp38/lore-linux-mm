Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B8D95F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 01:42:38 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id v27so853567wah.22
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 22:43:17 -0700 (PDT)
Message-ID: <49EC0B2A.5080600@gmail.com>
Date: Mon, 20 Apr 2009 13:42:02 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
References: <49E8292D.7050904@gmail.com>	<20090420084533.7f701e16.minchan.kim@barrios-desktop>	<49EBDADB.4040307@gmail.com>	<20090420114236.dda3de34.minchan.kim@barrios-desktop>	<49EBEBC0.8090102@gmail.com>	<20090420135323.08015e32.minchan.kim@barrios-desktop>	<49EC029D.1060807@gmail.com> <20090420142422.ff1a2a66.minchan.kim@barrios-desktop>
In-Reply-To: <20090420142422.ff1a2a66.minchan.kim@barrios-desktop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Minchan Kim a??e??:
> On Mon, 20 Apr 2009 13:05:33 +0800
> Huang Shijie <shijie8@gmail.com> wrote:
>
>   
>> Minchan Kim a??e??:
>>     
>>> On Mon, 20 Apr 2009 11:28:00 +0800
>>> Huang Shijie <shijie8@gmail.com> wrote:
>>>
>>> I will summarize your method. 
>>> Is right ?
>>>
>>>
>>> kernel(driver)					application 
>>>
>>> 						posix_memalign(buffer)
>>> 						ioctl(buffer)
>>>
>>> ioctl handler
>>> get_user_pages(pages);
>>> /* This pages are mapped at user's vma' 
>>> address space */
>>> vaddr = vmap(pages);
>>> /* This pages are mapped at vmalloc space */
>>> .
>>> .
>>> <after sometime, 
>>> It may change to other process context>
>>> .
>>> .
>>> interrupt handler in your driver 
>>> memcpy(vaddr, src, len); 
>>> notify_user();
>>>
>>> 						processing(buffer);
>>>
>>> It's rather awkward use case of get_user_pages. 
>>>
>>> If you want to share one big buffer between kernel and user, 
>>> You can vmalloc and remap_pfn_range.
>>>   
>>>       
>> The v4l2 method IO_METHOD_MMAP does use the vmaloc() method you told above ,
>> our driver also support this method,we user vmalloc /remap_vmalloc_range().
>>
>> But the v4l2 method IO_METHOD_USERPTR must use the method I told above.
>>     
>
> I can't understand IO_METHOD_USERPTR's benefit compared with IO_METHOD_MMAP. 
> I think both solution can support that application programmer can handle buffer as like pointer and kernel can reduce copy overhead from kernel to user. 
>
>   
yes ,I agree with you .
But the application programmers do not know which method is more efficient.

> Why do you have to support IO_METHOD_USERPTR?
>   
just for fun. For the v4l2 spec has the method ,why I don't realize it?

> If you can justify your goal, we can add locked GUP. 
>
>   
I can't .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
