Received: from talaria.fm.intel.com (talaria.fm.intel.com [10.1.192.39])
	by hermes.fm.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.51 2002/09/23 20:43:23 dmccart Exp $) with ESMTP id gAM1r3r17444
	for <linux-mm@kvack.org>; Fri, 22 Nov 2002 01:53:03 GMT
Received: from fmsmsxv040-1.fm.intel.com (fmsmsxvs040.fm.intel.com [132.233.42.124])
	by talaria.fm.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.27 2002/10/16 23:46:59 dmccart Exp $) with SMTP id gAM1vSJ25386
	for <linux-mm@kvack.org>; Fri, 22 Nov 2002 01:57:29 GMT
Message-ID: <25282B06EFB8D31198BF00508B66D4FA03EA5B12@fmsmsx114.fm.intel.com>
From: "Seth, Rohit" <rohit.seth@intel.com>
Subject: RE: hugetlb page patch for 2.5.48-bug fixes
Date: Thu, 21 Nov 2002 17:54:22 -0800
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'William Lee Irwin III' <wli@holomorphy.com>, "Seth, Rohit" <rohit.seth@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@digeo.com, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Thanks Bill for your comments. 

> Okay, first off why are you using a list linked through page->private?
> page->list is fully available for such tasks.

Don't really need a list_head kind of thing for always inorder complete
traversal. list_head (slightly) adds fat in data structures as well as
insertaion/removal. Please le me know if anything that prohibits the use of
page_private field for internal use.
> 
> Second, the if (key == NULL) check in hugetlb_release_key() 
> is bogus; someone is forgetting to check for NULL, probably 
> in alloc_shared_hugetlb_pages().
> 
This if condition will be removed.  It does not serve any purpose.  As there
is no way to release_key without a valid key.

> Third, the hugetlb_release_key() in unmap_hugepage_range() is 
> the one that should be removed [along with its corresponding 
> mark_key_busy()], not the one in sys_free_hugepages(). 
> unmap_hugepage_range() is doing neither setup nor teardown of 
> the key itself, only the pages and PTE's. I would say 
> key-level refcounting belongs to sys_free_hugepages().
> 
> Bill
> 
It is not mandatory that user app calls free_pages.  Or even in case of app
aborts this call will not be made.  The internal structures are always
released during the exit (with last ref count) along with free of underlying
physical pages.  

rohit
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
