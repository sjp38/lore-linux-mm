Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C11265F0001
	for <linux-mm@kvack.org>; Sun, 19 Apr 2009 19:44:59 -0400 (EDT)
Received: by ti-out-0910.google.com with SMTP id a21so1115624tia.8
        for <linux-mm@kvack.org>; Sun, 19 Apr 2009 16:45:40 -0700 (PDT)
Date: Mon, 20 Apr 2009 08:45:33 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: Does get_user_pages_fast lock the user pages in memory in my
 case?
Message-Id: <20090420084533.7f701e16.minchan.kim@barrios-desktop>
In-Reply-To: <49E8292D.7050904@gmail.com>
References: <49E8292D.7050904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Apr 2009 15:01:01 +0800
Huang Shijie <shijie8@gmail.com> wrote:

> 
>    I'm writting a driver for a video card with the V4L2 interface .
>    V4L2 interface supports the USER-POINTER method for the video frame 
> handling.
> 
>    VLC player supports the USER-POINTER method,while MPALYER does not.
> 
>    In the USER-POINTER method, VLC will call the posix_memalign() to 
> allocate
> 203 pages in certain PAL mode (that is 720*576*2) for a single frame.
>    In my driver , I call the get_user_pages_fast() to obtain the pages 
> array,and then call
> the vmap() to map the pages to VMALLOC space for the memcpy().The code 
> shows below:
>    ....................
>    get_user_pages_fast();
>    ...
>    f->data = vmap();
>    .......................


What I understand is that you get the pages of posix_memalign by get_user_pages_fast 
and then that pages are mapped at kernel vmalloc space by vmap. 

Is it for removing copy overhead from kernel to user ?

>    In comments, it said :
> "
> +/**
> + * get_user_pages_fast() - pin user pages in memory
> + * @start:     starting user address
> + * @nr_pages:  number of pages from start to pin
> + * @write:     whether pages will be written to
> + * @pages:     array that receives pointers to the pages pinned.
> + *             Should be at least nr_pages long.
> "
> 
>    But after I digged the code of kswap and the get_user_pages(called by 
> get_user_pages_fast),
> I did not find how the pages pinned in memory.I really need the pages 
> pinned in memory.
> 
>    Assume page A is one of the pages obtained by get_user_pages_fast() 
> during page-fault.
> 
> [1] page A will on the LRU_ACTIVE_ANON list;
>    the _count of page A increment by one;
>    PTE for page A will be set ACCESSED.
> 
> [2] kswapd will scan the lru list,and move page A from LRU_ACTIVE_ANON  
> to LRU_INACTIVE_ANON.
>    In the shrink_page_list(), there is nothing can stop page A been 
> swapped out.
>    I don't think the page_reference() can move page A back to 
> LRU_ACTIVE_ANON.In my driver,
>    I am not sure if the VLC can access the page A.
> 
>    Is this a bug? or I miss something?
>    Thanks .

If above my assumption is right, It's not a BUG. 
You get the application's pages by get_user_pages_fast. 
'Page pinning' means it shouldn't be freed. 
Application's pages always can be swapped out. 
If you don't want to swap out the page, you should use mlock. 
If you use mlock, kernel won't insert the page to lru [in]active list.
So the page never can be swapped out. 

> 
> 
>  
> 
> 
> 
> 
> 
> 
>  
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
