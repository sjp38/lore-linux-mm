Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iA51tgCO174376
	for <linux-mm@kvack.org>; Thu, 4 Nov 2004 20:55:42 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iA51tgQ7284034
	for <linux-mm@kvack.org>; Thu, 4 Nov 2004 20:55:42 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iA51tf1S001010
	for <linux-mm@kvack.org>; Thu, 4 Nov 2004 20:55:41 -0500
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041105005344.GG8229@dualathlon.random>
References: <20041102220720.GV3571@dualathlon.random>
	 <41880E0A.3000805@us.ibm.com> <4188118A.5050300@us.ibm.com>
	 <20041103013511.GC3571@dualathlon.random> <418837D1.402@us.ibm.com>
	 <20041103022606.GI3571@dualathlon.random> <418846E9.1060906@us.ibm.com>
	 <20041103030558.GK3571@dualathlon.random>
	 <1099612923.1022.10.camel@localhost> <1099615248.5819.0.camel@localhost>
	 <20041105005344.GG8229@dualathlon.random>
Content-Type: text/plain
Message-Id: <1099619740.5819.65.camel@localhost>
Mime-Version: 1.0
Date: Thu, 04 Nov 2004 17:55:40 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-11-04 at 16:53, Andrea Arcangeli wrote:
> The only chance for kpte_page to be freed, is to be == 1 in that place.
> If kpte_page is == 1, it will be freed via list_add and the master page
> will be regenerated giving it a chance to get performance back. If it's
> 0, it means we leaked memory as far as I can tell.
>
> It's impossible a pte had a 0 page_count() and not to be in the freelist
> already. There is no put_page at all in that whole path, there's only a
> __put_page, so it's a memleak to get == 0 in there on any pte or pmd or
> whatever else we cannot have put in the freelist already.

Ahhh.  I forgot about the allocator's reference on the page.  However,
there still seems to be something fishy here.

The page that's causing trouble's pfn is 0x0000000f.  It's also set as
PageReserved().  We may have some imbalance with page counts when the
page is PageReserved() that this is catching.  I can't find any
asymmetric use of kernel_map_pages().  Both the slab and the allocator
appear to be behaving themselves.  

I don't even see a case where that particular page has a get_page() done
on it before the first __change_page_attr() call on it.  So, it probably
still has its page_count()==0 from the original set in
memmap_init_zone().

What happens when a pte page is bootmem-allocated?  I *think* that's the
situation that I'm hitting.  In that case, we can either try to hunt
down the real 'struct pages' after everything is brought up, or we can
just skip the BUG_ON() if the page is reserved.  Any thoughts?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
