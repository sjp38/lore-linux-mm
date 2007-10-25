Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PEt0O9000776
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 10:55:00 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PEt0mK108752
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 08:55:00 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PEsxbe021183
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 08:54:59 -0600
Subject: Re: [PATCH 1/3] [FIX] hugetlb: Fix broken fs quota management
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <b040c32a0710242220w615be4f0kd34f86a9d9b048c5@mail.gmail.com>
References: <20071024132335.13013.76227.stgit@kernel>
	 <20071024132345.13013.36192.stgit@kernel>
	 <1193251414.4039.14.camel@localhost>
	 <1193252583.18417.52.camel@localhost.localdomain>
	 <b040c32a0710241221m9151f6xd0fe09e00608a597@mail.gmail.com>
	 <1193256124.18417.70.camel@localhost.localdomain>
	 <1193263944.4039.87.camel@localhost>
	 <b040c32a0710242220w615be4f0kd34f86a9d9b048c5@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 09:54:58 -0500
Message-Id: <1193324098.18417.80.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-24 at 22:20 -0700, Ken Chen wrote:
> On 10/24/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> > But, I think what I'm realizing is that the free paths for shared vs.
> > private are actually quite distinct.  Even more now after your patches
> > abolish using and actual put_page() (and the destructors) on private
> > pages losing their last mapping.
> >
> > I think it may make a lot of sense to have
> > {alloc,free}_{private,shared}_huge_page().  It'll really help
> > readability, and I _think_ it gives you a handy dandy place to add the
> > different quota operations needed.
> 
> Here is my version of re-factoring hugetlb_put_quota() into
> free_huge_page.  Not exactly what Dave suggested, but at least
> consolidate quota credit in one place.

I think consolidating quota into alloc/free_huge_page is a laudable
goal, but it has some problems (see below) that I feel go beyond simply
fixing the broken accounting (the initial purpose of the patches I was
targeting for -rc2).

<snip>
> @@ -369,6 +375,7 @@ static struct page *alloc_huge_page(
> 
>  	spin_unlock(&hugetlb_lock);
>  	set_page_refcounted(page);
> +	set_page_private(page, (unsigned long) vma->vm_file->f_mapping);
>  	return page;
> 
>  fail:

This seems like a layering violation to me.  We set page->private here,
but if add_to_page_cache() is called on this page later, it will set
page->mapping.  Granted it will overwrite the exact same value, but it
does so using a different field in the union.  So I don't think we
should be messing with page->private in this way.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
