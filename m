Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PGkGVb028737
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:46:16 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PGkGTE085824
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:46:16 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PGkFke025778
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:46:16 -0400
Subject: Re: RFC/POC Make Page Tables Relocatable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 09:46:14 -0700
Message-Id: <1193330774.4039.136.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 11:16 -0400, Ross Biro wrote:
> 1) Add a separate meta-data allocation to the slab and slub allocator
> and allocate full pages through kmem_cache_alloc instead of get_page.
> The primary motivation of this is that we could shrink struct page by
> using kmem_cache_alloc to allocate whole pages and put the supported
> data in the meta_data area instead of struct page. 

The idea seems cool, but I think I'm missing a lot of your motivation
here.

First of all, which meta-data, exactly, is causing 'struct page' to be
larger than it could be?  Which meta-data can be moved?

> 2) Add support for relocating memory allocated via kmem_cache_alloc.
> When a cache is created, optional relocation information can be
> provided.  If a relocation function is provided, caches can be
> defragmented and overall memory consumption can be reduced.

We may truly need this some day, but I'm not sure we need it for
pagetables.  If I were a stupid, naive kernel developer and I wanted to
get a pte page back, I might simply hold the page table lock, walk the
pagetables to the pmd, lock and invalidate the pmd, copy the pagetable
contents into a new page, update the pmd, and be on my merry way.  Why
doesn't this work?  I'm just fishing for a good explanation why we need
all the slab silliness.

I applaud you for posting early and posting often, but there is an
absolute ton of code in your patch.  For your subsequent postings, I'd
highly recommend trying to break it up in some logical ways.  Your 4
steps would be an excellent start.

You might also want to run checkpatch.pl on your patch.  It has some
style issues that also need to get worked out.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
