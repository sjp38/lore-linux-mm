Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 59C2D5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 03:02:14 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so613253rvb.26
        for <linux-mm@kvack.org>; Fri, 17 Apr 2009 00:02:15 -0700 (PDT)
Message-ID: <49E8292D.7050904@gmail.com>
Date: Fri, 17 Apr 2009 15:01:01 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Does get_user_pages_fast lock the user pages in memory in my case?
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


   I'm writting a driver for a video card with the V4L2 interface .
   V4L2 interface supports the USER-POINTER method for the video frame 
handling.

   VLC player supports the USER-POINTER method,while MPALYER does not.

   In the USER-POINTER method, VLC will call the posix_memalign() to 
allocate
203 pages in certain PAL mode (that is 720*576*2) for a single frame.
   In my driver , I call the get_user_pages_fast() to obtain the pages 
array,and then call
the vmap() to map the pages to VMALLOC space for the memcpy().The code 
shows below:
   ....................
   get_user_pages_fast();
   ...
   f->data = vmap();
   .......................

   In comments, it said :
"
+/**
+ * get_user_pages_fast() - pin user pages in memory
+ * @start:     starting user address
+ * @nr_pages:  number of pages from start to pin
+ * @write:     whether pages will be written to
+ * @pages:     array that receives pointers to the pages pinned.
+ *             Should be at least nr_pages long.
"

   But after I digged the code of kswap and the get_user_pages(called by 
get_user_pages_fast),
I did not find how the pages pinned in memory.I really need the pages 
pinned in memory.

   Assume page A is one of the pages obtained by get_user_pages_fast() 
during page-fault.

[1] page A will on the LRU_ACTIVE_ANON list;
   the _count of page A increment by one;
   PTE for page A will be set ACCESSED.

[2] kswapd will scan the lru list,and move page A from LRU_ACTIVE_ANON  
to LRU_INACTIVE_ANON.
   In the shrink_page_list(), there is nothing can stop page A been 
swapped out.
   I don't think the page_reference() can move page A back to 
LRU_ACTIVE_ANON.In my driver,
   I am not sure if the VLC can access the page A.

   Is this a bug? or I miss something?
   Thanks .


 






 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
