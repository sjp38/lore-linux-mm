Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k18Jceow028399
	for <linux-mm@kvack.org>; Wed, 8 Feb 2006 14:38:40 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k18JcbD2219298
	for <linux-mm@kvack.org>; Wed, 8 Feb 2006 14:38:40 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k18JcbdY031880
	for <linux-mm@kvack.org>; Wed, 8 Feb 2006 14:38:37 -0500
Subject: Re: [RFC] Removing page->flags
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1139381183.22509.186.camel@localhost>
References: <1139381183.22509.186.camel@localhost>
Content-Type: text/plain
Date: Wed, 08 Feb 2006 11:37:57 -0800
Message-Id: <1139427478.9452.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-mm@kvack.org, Magnus Damm <damm@opensource.se>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-02-08 at 15:46 +0900, Magnus Damm wrote: 
> Removing type B bits:
> 
> Instead of using the highest bits of page->flags to locate zones, nodes
> or sparsemem section, let's remove them and locate them using alignment!
> 
> To locate which zone, node and sparsemem section a page belongs to, just
> use struct page (source_page) and aligment! The page that contains the
> specific struct page (and also contains other parts of mem_map), it's
> struct page is located using something like this:
> 
>   memmap_page = virt_to_page(source_page) 

We actually discussed this a number of times when developing sparsemem
and its predecessors.  It does seem silly to store stuff like the node
information in *so* *many* copies all over the place.

Andy's argument at the time (if I remember correctly) was that nobody
was using those particular page flags for anything, so what shouldn't we
use them?  Plus, this gives better cache locality.

You hinted at it, but you are completely right that the 'struct pages'
backing other 'struct pages' aren't used for anything.  They are often
bootmem-allocated, so that probably have PageReserved set, and have
never seen the allocator.  All of their fields are basically free for
any use that we'd like.

The biggest killer for this idea for me is not when the zones or section
edges are not aligned on big powers of 2, but when the 'struct page' is
oddly sized.  When it is 32 or 64 bytes, you get a nice, even number of
them in a full page.  But, when you have a 40-byte 'struct page', things
go downhill in a hurry.  This can be affected by things like spinlock
debugging, so it is hard to predict and handle in advance.

The really basic implementation (without the odd page size handling) is
here, if you care:

http://www.sr71.net/patches/2.6.10/2.6.10-rc2-mm4-mhp3/broken-out/C6-nonlinear-no-page-section.patch

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
