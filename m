Date: Mon, 29 Jan 2007 17:26:56 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] Don't allow the stack to grow into hugetlb reserved
 regions
In-Reply-To: <b040c32a0701281227r11fe02eblba07df7aa7400787@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0701291703530.31023@blonde.wat.veritas.com>
References: <20070125214052.22841.33449.stgit@localhost.localdomain>
 <Pine.LNX.4.64.0701262025590.22196@blonde.wat.veritas.com>
 <b040c32a0701261448k122f5cc7q5368b3b16ee1dc1f@mail.gmail.com>
 <Pine.LNX.4.64.0701270904360.15686@blonde.wat.veritas.com>
 <b040c32a0701281227r11fe02eblba07df7aa7400787@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@osdl.org>, William Irwin <wli@holomorphy.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Jan 2007, Ken Chen wrote:
> 
> For ia64, the hugetlb address region is reserved at the top of user
> space address.  Stacks are below that region.  Throw in the mix, we
> have two stacks, one memory stack that grows down and one register
> stack backing store that grows up.  These two stacks are always in
> pair and grow towards each other. And lastly, we have virtual address
> holes in between regions.  It's just impossible to grow any of these
> two stacks into hugetlb region no matter how I played it.
> 
> So, AFAICS this bug doesn't apply to ia64 (and certainly not x86). The
> new check of is_hugepage_only_range() is really a noop for both arches.

Certainly not a problem on x86.

But, never mind hugetlb, you still not quite convinced me that there's
no problem at all with get_user_pages find_extend_vma growing on ia64.

I repeat that ia64_do_page_fault has REGION tests to guard against
expanding either kind of stack across into another region.  ia64_brk,
ia64_mmap_check and arch_get_unmapped_area have RGN_MAP_LIMIT checks.
But where is the equivalent paranoia when ptrace calls get_user_pages
calls find_extend_vma?

If your usual stacks face each other across the same region, they're
not going to pose problem.  But what if someone mmaps MAP_GROWSDOWN
near the base of a region, then uses ptrace to touch an address near
the top of the region below?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
