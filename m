Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC856B0071
	for <linux-mm@kvack.org>; Thu, 25 Mar 2010 01:18:36 -0400 (EDT)
Message-ID: <4BAAF20D.1050705@cray.com>
Date: Thu, 25 Mar 2010 00:18:05 -0500
From: Andrew Hastings <abh@cray.com>
MIME-Version: 1.0
Subject: Re: BUG: Use after free in free_huge_page()
References: <201003222028.o2MKSDsD006611@pogo.us.cray.com> <4BA8C9E0.2090300@us.ibm.com> <20100323175639.GA5870@csn.ul.ie>
In-Reply-To: <20100323175639.GA5870@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Adam Litke <agl@us.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:
> On Tue, Mar 23, 2010 at 09:02:08AM -0500, Adam Litke wrote:
>> Hi Andrew, thanks for the detailed report.  I am taking a look at this  
>> but it seems a lot has happened since I last looked at this code.  (If  
>> anyone else knows what might be going on here, please do chime in).
>>
>> Andrew Hastings wrote:
>>> I think what happens is:
>>> 1.  Driver does get_user_pages() for pages mapped by hugetlbfs.
>>> 2.  Process exits.
>>> 3.  hugetlbfs file is closed; the vma->vm_file->f_mapping value stored in
>>>     page_private now points to freed memory
>>> 4.  Driver file is closed; driver's release() function calls put_page()
>>>     which calls free_huge_page() which passes bogus mapping value to
>>>     hugetlb_put_quota().
>> :( Definitely seems plausible.
>>
> 
> I haven't had a chance to look at this closely yet and it'll be a
> minimum of a few days before I do. Hopefully Adam will spot something in
> the meantime but I do have a question.
> 
> What driver is calling get_user_pages() on pages mapped by hugetlbfs?
> It's not clear what "driver file" is involved but clearly it's not mapped
> or it would have called get_file() as part of the mapping.
> 
> Again, without thinking about this too much, it seems more like a
> reference-count problem rather than a race if the file is disappaering
> before the pages being backed by it are freed.

Mel:

Yeah, this is certainly a reference-counting problem, but I think it's probably in hugetlbfs.  

We are developing a device driver under GPL for a future product, our "Gemini" interconnect.  The "device file" I mentioned is simply the entry in sysfs that user space libraries use to communicate with the device driver.  The "Gemini" device supports RDMA, so the driver will "pin" user pages via get_user_pages() on user request, and "unpin" those pages via put_page() on user request or process exit.  The pages being "pinned" may or may not be pages mapped by hugetlbfs.  (Device drivers shouldn't have to know whether the pages they are doing DMA on are pages mapped by hugetlbfs, should they?) 

The "Gemini" device driver may be somewhat unusual in that it tends to "pin" pages for longer periods and is thus more likely to hit this race, but this race should exist for any driver that calls get_user_pages() on hugetlbfs-backed pages for an asynchronous DMA just before process exit, and does not complete that DMA until after the hugetlbfs file is released at exit time,  I'd imagine that this could happen with e.g. NFS and O_DIRECT if O_DIRECT is supported and the NFS server is slow.

It seems to me that hugetlbfs ought to take an extra reference on the vma or vm_file or f_mapping or _something_ if vma->vm_file->f_mapping is needed by free_huge_page().

Or is there something our "Gemini" driver should be doing to ensure DMAs complete before exit time?

Thanks for your insights into this problem!


>>> I'd like to help with a fix, but it's not immediately obvious to me what
>>> the right path is.  Should hugetlb_no_page() always call add_to_page_cache()
>>> even if VM_MAYSHARE is clear?
>> Are you seeing any corruption in the HugePages_Rsvd: counter?  Would it  
>> be possible for you to run the libhugetlbfs test suite before and after  
>> trigerring the bug and let me know if any additional tests fail after  
>> you reproduce this?

Adam:

Thanks!  I'll work on collecting the information you requested.


Best regards,
-Andrew Hastings
 Cray Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
