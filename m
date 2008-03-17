Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2HE6YXQ032467
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 10:06:35 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HE4XoW247058
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 10:04:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HE4Xx4001533
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 10:04:33 -0400
Message-ID: <47DE7A71.1000805@us.ibm.com>
Date: Mon, 17 Mar 2008 07:04:33 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: grow_dev_page's __GFP_MOVABLE
References: <Pine.LNX.4.64.0803112116380.18085@blonde.site> <20080312140831.GD6072@csn.ul.ie> <Pine.LNX.4.64.0803121740170.32508@blonde.site> <20080313120755.GC12351@csn.ul.ie> <1205420758.19403.6.camel@dyn9047017100.beaverton.ibm.com> <20080313154428.GD12351@csn.ul.ie> <1205455806.19403.47.camel@dyn9047017100.beaverton.ibm.com> <20080314114705.GA18381@csn.ul.ie> <1205510734.19403.53.camel@dyn9047017100.beaverton.ibm.com> <1205520765.19403.59.camel@dyn9047017100.beaverton.ibm.com> <20080317105412.GA3124@shadowen.org>
In-Reply-To: <20080317105412.GA3124@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> On Fri, Mar 14, 2008 at 10:52:45AM -0800, Badari Pulavarty wrote:
>   
>> On Fri, 2008-03-14 at 08:05 -0800, Badari Pulavarty wrote:
>>     
>>> On Fri, 2008-03-14 at 11:47 +0000, Mel Gorman wrote:
>>>       
>>>> On (13/03/08 16:50), Badari Pulavarty didst pronounce:
>>>>         
>>>>>>> <SNIP>
>>>>>>> page_owner shows:
>>>>>>>
>>>>>>> Page allocated via order 0, mask 0x120050
>>>>>>> PFN 30625 Block 7 type 2          Flags      L
>>>>>>>               
>>>>>> This page is indicated as being on the LRU so it should have been possible
>>>>>> to reclaim. Is memory hot-remove making any effort to reclaim this page or
>>>>>> is it depending only on page migration?
>>>>>>             
>>>>> offline_pages() finds all the pages on LRU and tries to migrate them by
>>>>> calling unmap_and_move(). I don't see any explicit attempt to reclaim.
>>>>> It tries to migrate the page (move_to_new_page()), but what I have seen
>>>>> in the past is that these pages have buffer heads attached to them. 
>>>>> So, migrate_page_move_mapping() fails to release the page. (BTW,
>>>>> I narrowed this in Oct 2007 and forgot most of the details). I can
>>>>> take a closer look again. Can we reclaim these pages easily ?
>>>>>
>>>>>           
>>>> They should be, or huge page allocations using lumpy reclaim would also
>>>> be failing all the time.
>>>>         
>>> Hi Mel,
>>>
>>> These pages are on LRU and clean. In order to reclaim these pages
>>> (looking at pageout()), all we need to do is try_to_release_page().
>>> fallback_migrate_page() does this but fails to free it up. What
>>> else I can do here to force reclaim these ?
>>>       
>> In other words, caller has a ref on the buffer_head by calling
>> getblk(). So, try_to_release_page() would fail since buffer_busy().
>> These buffers could be holding meta-data (super block, bitmaps etc.)
>> for a file system. Till fs gets rid of the ref, there is nothing
>> much we can do. Isn't it ?
>>     
>
> Cirtainly when fragmentation avoidance was young we did see a lot of
> this as some of the meta-data was badly marked.  What filesystem is this
> running on?
>
> -apw
>   
I have seen this with reiserfs and ext3.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
