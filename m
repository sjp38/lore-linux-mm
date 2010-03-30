Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B60216B01F3
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 07:19:16 -0400 (EDT)
Date: Tue, 30 Mar 2010 12:18:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: BUG: Use after free in free_huge_page()
Message-ID: <20100330111855.GC15466@csn.ul.ie>
References: <201003222028.o2MKSDsD006611@pogo.us.cray.com> <4BA8C9E0.2090300@us.ibm.com> <20100323175639.GA5870@csn.ul.ie> <4BAAF20D.1050705@cray.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BAAF20D.1050705@cray.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Hastings <abh@cray.com>
Cc: Adam Litke <agl@us.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 25, 2010 at 12:18:05AM -0500, Andrew Hastings wrote:
> Mel Gorman wrote:
>> On Tue, Mar 23, 2010 at 09:02:08AM -0500, Adam Litke wrote:
>>> Hi Andrew, thanks for the detailed report.  I am taking a look at 
>>> this  but it seems a lot has happened since I last looked at this 
>>> code.  (If  anyone else knows what might be going on here, please do 
>>> chime in).
>>>
>>> Andrew Hastings wrote:
>>>> I think what happens is:
>>>> 1.  Driver does get_user_pages() for pages mapped by hugetlbfs.
>>>> 2.  Process exits.
>>>> 3.  hugetlbfs file is closed; the vma->vm_file->f_mapping value stored in
>>>>     page_private now points to freed memory
>>>> 4.  Driver file is closed; driver's release() function calls put_page()
>>>>     which calls free_huge_page() which passes bogus mapping value to
>>>>     hugetlb_put_quota().
>>> :( Definitely seems plausible.
>>>
>>
>> I haven't had a chance to look at this closely yet and it'll be a
>> minimum of a few days before I do. Hopefully Adam will spot something in
>> the meantime but I do have a question.
>>
>> What driver is calling get_user_pages() on pages mapped by hugetlbfs?
>> It's not clear what "driver file" is involved but clearly it's not mapped
>> or it would have called get_file() as part of the mapping.
>>
>> Again, without thinking about this too much, it seems more like a
>> reference-count problem rather than a race if the file is disappaering
>> before the pages being backed by it are freed.
>
> Mel:
>
> Yeah, this is certainly a reference-counting problem, but I think it's 
> probably in hugetlbfs.  
>
> We are developing a device driver under GPL for a future product, our 
> "Gemini" interconnect.  The "device file" I mentioned is simply the entry 
> in sysfs that user space libraries use to communicate with the device 
> driver.  The "Gemini" device supports RDMA, so the driver will "pin" user 
> pages via get_user_pages() on user request, and "unpin" those pages via 
> put_page() on user request or process exit.  The pages being "pinned" may 
> or may not be pages mapped by hugetlbfs.  (Device drivers shouldn't have 
> to know whether the pages they are doing DMA on are pages mapped by 
> hugetlbfs, should they?) 
>

No, they shouldn't but I'm having a wee bit of trouble seeing why DMA to a page
that is no longer reachable by any process is happening. I'm somewhat taking
your word for it that there is a proper use case. Even if RDMA is involved,
it does not explain what happens the sending process when it's end-point
has disappeared. My feeling is that more likely this is an "anomolous"
situation but the kernel shouldn't shoot itself when it occurs.

> The "Gemini" device driver may be somewhat unusual in that it tends to
> "pin" pages for longer periods and is thus more likely to hit this race,
> but this race should exist for any driver that calls get_user_pages() on
> hugetlbfs-backed pages for an asynchronous DMA just before process exit,
> and does not complete that DMA until after the hugetlbfs file is released
> at exit time,  I'd imagine that this could happen with e.g. NFS and O_DIRECT
> if O_DIRECT is supported and the NFS server is slow.
>
> It seems to me that hugetlbfs ought to take an extra reference on the vma
> or vm_file or f_mapping or _something_ if vma->vm_file->f_mapping is needed
> by free_huge_page().

Again, I haven't looked closely at this but a reference count on the VMA
wouldn't help. After all, the VMAs have already been cleared up and the
page tables. As far as the code is concerned, that file is no longer in
use. I'd also not try reference counting during get_user_pages and
someohw releasing that count later. Too much mess.

The most likely avenue is to store a reference to the superblock instead
of the mapping in page->private which is what put_quota is really
interested in. There might still be a race there if hugetlbfs managed to
get unmounted before the pages were freed though - not 100% sure.

> Or is there something our "Gemini" driver should be doing to ensure DMAs complete before exit time?
>

I'm not familiar enough with how RDMA should be implemented to answer
that question offhand.

> Thanks for your insights into this problem!
>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
