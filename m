Message-ID: <4456D7B8.2000004@yahoo.com.au>
Date: Tue, 02 May 2006 13:53:28 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 11/14] remap_file_pages protection support: pte_present
 should not trigger on PTE_FILE PROTNONE ptes
References: <20060430172953.409399000@zion.home.lan> <20060430173025.752423000@zion.home.lan>
In-Reply-To: <20060430173025.752423000@zion.home.lan>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: blaisorblade@yahoo.it
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

blaisorblade@yahoo.it wrote:
> From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
> 
> pte_present(pte) implies that pte_pfn(pte) is valid. Normally even with a
> _PAGE_PROTNONE pte this holds, but not when such a PTE is installed by
> the new install_file_pte; previously it didn't store protections, only file
> offsets, with the patches it also stores protections, and can set
> _PAGE_PROTNONE|_PAGE_FILE.

Why is this combination useful? Can't you just drop the _PAGE_FILE from
_PAGE_PROTNONE ptes?

> 
> zap_pte_range, when acting on such a pte, calls vm_normal_page and gets
> &mem_map[0], does page_remove_rmap, and we're easily in trouble, because it
> happens to find a page with mapcount == 0. And it BUGs on this!
> 
> I've seen this trigger easily and repeatably on UML on 2.6.16-rc3. This was
> likely avoided in the past by the PageReserved test - page 0 *had* to be
> reserved on i386 (dunno on UML).
> 
> Implementation follows for UML and i386.
> 
> To avoid additional overhead, I also considered adding likely() for
> _PAGE_PRESENT and unlikely() for the rest, but I'm uncertain about validity of
> possible [un]likely(pte_present()) occurrences.

Not present pages are likely to be pretty common when unmapping.

I don't like this patch much.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
