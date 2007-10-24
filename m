Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9OK26qP000717
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 16:02:06 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9OK25Tk064482
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 14:02:05 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9OK25qE006758
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 14:02:05 -0600
Subject: Re: [PATCH 1/3] [FIX] hugetlb: Fix broken fs quota management
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <b040c32a0710241221m9151f6xd0fe09e00608a597@mail.gmail.com>
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132345.13013.36192.stgit@kernel>
	 <1193251414.4039.14.camel@localhost>
	 <1193252583.18417.52.camel@localhost.localdomain>
	 <b040c32a0710241221m9151f6xd0fe09e00608a597@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 24 Oct 2007 15:02:04 -0500
Message-Id: <1193256124.18417.70.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-24 at 12:21 -0700, Ken Chen wrote:
> On 10/24/07, Adam Litke <agl@us.ibm.com> wrote:
> > On Wed, 2007-10-24 at 11:43 -0700, Dave Hansen wrote:
> > > This particular nugget is for MAP_PRIVATE pages only, right?  The shared
> > > ones should have another ref out on them for the 'mapping' too, so won't
> > > get released at unmap, right?
> >
> > Yep that's right.  Shared pages are released by truncate_hugepages()
> > when the ref for the mapping is dropped.
> 
> I think as a follow up patch, we should debit the quota in
> free_huge_page(), so you don't have to open code it like this and also
> consolidate calls to hugetlb_put_quota() in one place.  It's cleaner
> that way.

At free_huge_page() time, you can't associate the page with a struct
address_space so it becomes hard to credit the proper filesystem.  When
freeing the page, page->mapping is no longer valid (even for shared
pages). 

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
