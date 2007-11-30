Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAUHRh8d018844
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 12:27:43 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAUHRh4K492272
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 12:27:43 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAUHRh01003078
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 12:27:43 -0500
Subject: Re: [PATCH] mm: fix confusing __GFP_REPEAT related comments
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071130041922.GQ13444@us.ibm.com>
References: <20071129214828.GD20882@us.ibm.com>
	 <1196378080.18851.116.camel@localhost>  <20071130041922.GQ13444@us.ibm.com>
Content-Type: text/plain
Date: Fri, 30 Nov 2007 10:27:40 -0800
Message-Id: <1196447260.19681.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, mel@skynet.ie, wli@holomorphy.com, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-11-29 at 20:19 -0800, Nishanth Aravamudan wrote: 
> "In looking at the callers using __GFP_REPEAT, not all handle failure --
> should they be using __NOFAIL?"
> 
> I *think* that all the current __GFP_REPEAT users are order <=
> PAGE_ALLOC_CSOTLY_ORDER. Perhaps they all mean to use __GPF_NOFAIL? Some
> don't handle failure immediately, but maybe their callers do, I haven't
> had time to investigate fully.

I think we treat pagetable allocations just like normal ones with error
handling.  If I saw a pte_alloc() in a patch that was used without
checking for NULL, I'd certainly bitch about it.

In any case, if we want to nitpick, the *callers* haven't asked for
__GFP_NOFAIL, so they shouldn't be depending on a lack of failures.

> And the whole gist, per the comments in mm/page_alloc.c, is that this is
> all dependent upon this implementation of the VM. I think that means you
> can't rely on those semantics being valid forever. So it's best for
> callers to be as explicit as possible ... but in this case, I'm not sure
> that the desired semantics actually exist.

I don't really buy this "in this implementation of the VM" crap.  When
people go to figure out which functions and flags to use, they don't
just go look at headers.  They look at and depend on the
implementations.  If we change the implementations, we go change all the
callers, too.

Your patch highlights an existing problem: we're not being very good
with __GFP_REPEAT.  All of the pagetable users (on x86 at least) are
using __GFP_REPEAT, but effectively getting __GFP_NOFAIL.  There are
some other users around that might have larger buffers, but I think
pagetable pages are pretty guaranteed to stay <= 1 page in size. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
