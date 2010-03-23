Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EBE836B01AE
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 13:56:59 -0400 (EDT)
Date: Tue, 23 Mar 2010 17:56:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: BUG: Use after free in free_huge_page()
Message-ID: <20100323175639.GA5870@csn.ul.ie>
References: <201003222028.o2MKSDsD006611@pogo.us.cray.com> <4BA8C9E0.2090300@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4BA8C9E0.2090300@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Hastings <abh@cray.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 09:02:08AM -0500, Adam Litke wrote:
> Hi Andrew, thanks for the detailed report.  I am taking a look at this  
> but it seems a lot has happened since I last looked at this code.  (If  
> anyone else knows what might be going on here, please do chime in).
>
> Andrew Hastings wrote:
>> I think what happens is:
>> 1.  Driver does get_user_pages() for pages mapped by hugetlbfs.
>> 2.  Process exits.
>> 3.  hugetlbfs file is closed; the vma->vm_file->f_mapping value stored in
>>     page_private now points to freed memory
>> 4.  Driver file is closed; driver's release() function calls put_page()
>>     which calls free_huge_page() which passes bogus mapping value to
>>     hugetlb_put_quota().
>
> :( Definitely seems plausible.
>

I haven't had a chance to look at this closely yet and it'll be a
minimum of a few days before I do. Hopefully Adam will spot something in
the meantime but I do have a question.

What driver is calling get_user_pages() on pages mapped by hugetlbfs?
It's not clear what "driver file" is involved but clearly it's not mapped
or it would have called get_file() as part of the mapping.

Again, without thinking about this too much, it seems more like a
reference-count problem rather than a race if the file is disappaering
before the pages being backed by it are freed.

>> I'd like to help with a fix, but it's not immediately obvious to me what
>> the right path is.  Should hugetlb_no_page() always call add_to_page_cache()
>> even if VM_MAYSHARE is clear?
>
> Are you seeing any corruption in the HugePages_Rsvd: counter?  Would it  
> be possible for you to run the libhugetlbfs test suite before and after  
> trigerring the bug and let me know if any additional tests fail after  
> you reproduce this?
>
> Thanks.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
