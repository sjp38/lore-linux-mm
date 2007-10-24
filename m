Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OMCRE1022506
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 18:12:27 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OMCQCq119988
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 18:12:26 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OMCQtj002366
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 18:12:26 -0400
Subject: Re: [PATCH 1/3] [FIX] hugetlb: Fix broken fs quota management
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193256124.18417.70.camel@localhost.localdomain>
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132345.13013.36192.stgit@kernel>
	 <1193251414.4039.14.camel@localhost>
	 <1193252583.18417.52.camel@localhost.localdomain>
	 <b040c32a0710241221m9151f6xd0fe09e00608a597@mail.gmail.com>
	 <1193256124.18417.70.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 15:12:24 -0700
Message-Id: <1193263944.4039.87.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Ken Chen <kenchen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-24 at 15:02 -0500, Adam Litke wrote:
> > I think as a follow up patch, we should debit the quota in
> > free_huge_page(), so you don't have to open code it like this and also
> > consolidate calls to hugetlb_put_quota() in one place.  It's cleaner
> > that way.
> 
> At free_huge_page() time, you can't associate the page with a struct
> address_space so it becomes hard to credit the proper filesystem.  When
> freeing the page, page->mapping is no longer valid (even for shared
> pages). 

Why is that?  Because we rely on put_page() calling into the
destructors, and don't pass along mapping?

There are basically two free paths: shared file truncating and the last
vma using a MAP_PRIVATE page being munmap()'d.

Your code just made it so that regular put_page() isn't called for the
MAP_PRIVATE free case.  The destructor is called manually.  So, it
doesn't really apply.

For the shared case, the quota calls aren't even done during allocation
and free, but at truncation, so they wouldn't have a VMA available to
determine shared/private.

But, I think what I'm realizing is that the free paths for shared vs.
private are actually quite distinct.  Even more now after your patches
abolish using and actual put_page() (and the destructors) on private
pages losing their last mapping.

I think it may make a lot of sense to have
{alloc,free}_{private,shared}_huge_page().  It'll really help
readability, and I _think_ it gives you a handy dandy place to add the
different quota operations needed.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
