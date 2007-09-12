Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8C8kSHC018392
	for <linux-mm@kvack.org>; Wed, 12 Sep 2007 18:46:28 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8C8kGiF069754
	for <linux-mm@kvack.org>; Wed, 12 Sep 2007 18:46:16 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8C8gQZS023142
	for <linux-mm@kvack.org>; Wed, 12 Sep 2007 18:42:26 +1000
Message-ID: <46E7A666.7080409@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2007 14:12:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] overwride page->mapping [0/3] intro
References: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, "Martin J. Bligh" <mbligh@google.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> In general, we cannot inclease size of 'struct page'. So, overriding and
> adding prural meanings to page struct's member is done in many situation.
> 

Hi, Kamezawa,

We discussed the struct page size issue at VM summit. If I remember
correctly, Linus suggested that we consider using pfn's instead of
pointers for pointer members in struct page.

> But to do some kind of precise VM mamangement, page struct itself seems to be
> too small. This patchset overrides page->mapping and add on-demand page
> information.
> 
> like this:
> 
> ==
> page->mapping points to address_space or anon_vma or mapping_info
> 

Could you elaborate a little here, on what is the basis to decide
what page->mapping should point to?

> mapping_info is strucutured as 
> 
> struct mapping_info {
> 	union {
> 		anon_vma;
> 		address_space;
> 	};
> 	/* Additional Information to this page */
> };
> 
> ==
> This works based on "adding page->mapping interface" patch set, I posted.
> 
> My main target is move page_container information to this mapping_info.
> By this, we can avoid increasing size of struct page when container is used.
> 

I am not against this goal, but wouldn't we end up with too many
dereferences to get to the container?
i.e, page->mapping->page_container->mem_container.

> Maybe other men may have other information they want to remember.
> This patch set implements mlock_counter on mapping_info as *exmaple*.
> (About mlock_counter, overriding page->lru may be able to be used.)
> 
> 
> This approach will consume some amount of memory. But I believe this *additional
> information* can be tunred off easily if the user doesn't want this.
> 
> I'm glad if I can get some comments.
> 


I'll review your patchset and respond if I have any comments or
suggestions.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
