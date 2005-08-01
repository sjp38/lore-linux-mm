Date: Mon, 1 Aug 2005 13:16:20 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <20050801125700.4ba0807b.akpm@osdl.org>
Message-ID: <Pine.LNX.4.58.0508011311260.3341@g5.osdl.org>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
 <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
 <Pine.LNX.4.61.0508012024330.5373@goblin.wat.veritas.com>
 <20050801125700.4ba0807b.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, nickpiggin@yahoo.com.au, holt@sgi.com, roland@redhat.com, schwidefsky@de.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 1 Aug 2005, Andrew Morton wrote:
> 
> That was introduced 19 months ago by the s390 guys (see patch below). 

This really is a very broken patch, btw. 

> +		if (write && !pte_write(pte))
> +			goto out;
> +		if (write && !pte_dirty(pte)) {
> +			struct page *page = pte_page(pte);
> +			if (!PageDirty(page))
> +				set_page_dirty(page);
> +		}
> +		pfn = pte_pfn(pte);
> +		if (pfn_valid(pfn)) {
> +			struct page *page = pfn_to_page(pfn);
> +			
> +			mark_page_accessed(page);
> +			return page;

Note how it doesn't do any "pfn_valid()" stuff for the dirty bit setting, 
so it will set random bits in memory if the pte points to some IO page. 

Maybe that doesn't happen on s390, but..

Anyway, if the s390 people just have a sw-writable bit in their page table
layout, I bet they can fix their problem by just having a "sw dirty"  
bit, and then make "pte_mkdirty()" set that bit. Nobody else will care, 
but ptrace will then just work correctly for them too.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
