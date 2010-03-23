Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 59E936B01B4
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 10:02:50 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2NDs9nZ024953
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 09:54:09 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2NE2hA6084184
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 10:02:43 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2NE2W6w012013
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 11:02:33 -0300
Message-ID: <4BA8C9E0.2090300@us.ibm.com>
Date: Tue, 23 Mar 2010 09:02:08 -0500
From: Adam Litke <agl@us.ibm.com>
MIME-Version: 1.0
Subject: Re: BUG: Use after free in free_huge_page()
References: <201003222028.o2MKSDsD006611@pogo.us.cray.com>
In-Reply-To: <201003222028.o2MKSDsD006611@pogo.us.cray.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Hastings <abh@cray.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew, thanks for the detailed report.  I am taking a look at this 
but it seems a lot has happened since I last looked at this code.  (If 
anyone else knows what might be going on here, please do chime in).

Andrew Hastings wrote:
> I think what happens is:
> 1.  Driver does get_user_pages() for pages mapped by hugetlbfs.
> 2.  Process exits.
> 3.  hugetlbfs file is closed; the vma->vm_file->f_mapping value stored in
>     page_private now points to freed memory
> 4.  Driver file is closed; driver's release() function calls put_page()
>     which calls free_huge_page() which passes bogus mapping value to
>     hugetlb_put_quota().

:( Definitely seems plausible.

> I'd like to help with a fix, but it's not immediately obvious to me what
> the right path is.  Should hugetlb_no_page() always call add_to_page_cache()
> even if VM_MAYSHARE is clear?

Are you seeing any corruption in the HugePages_Rsvd: counter?  Would it 
be possible for you to run the libhugetlbfs test suite before and after 
trigerring the bug and let me know if any additional tests fail after 
you reproduce this?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
