Subject: Re: User switchable HW mappings & cie
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <452A35FF.50009@tungstengraphics.com>
References: <1160347065.5926.52.camel@localhost.localdomain>
	 <452A35FF.50009@tungstengraphics.com>
Content-Type: text/plain
Date: Mon, 09 Oct 2006 21:51:01 +1000
Message-Id: <1160394662.10229.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas =?ISO-8859-1?Q?Hellstr=F6m?= <thomas@tungstengraphics.com>
Cc: linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, Arnd Bergmann <arnd@arndb.de>, Linus Torvalds <torvalds@osdl.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> I'm very much for this approach, possibly with the extension that we 
> could have a multiple-page version as well, as populating the whole vma 
> sometimes may be cheaper than populating each pte with a fault. That 
> would basically be an io_remap_pfn_range() which is safe when the 
> mmap_sem is taken in read mode (from do_no_page).
> 
> One problem that occurs is that the rule for ptes with non-backing 
> struct pages
> Which I think was introduced in 2.6.16:
> 
>     pfn_of_page == vma->vm_pgoff + ((addr - vma->vm_start) >> PAGE_SHIFT)
> 
> cannot be honored, at least not with the DRM memory manager, since the 
> graphics object will be associated with a vma and not the underlying 
> physical address. User space will have vma->vm_pgoff as a handle to the 
> object, which may move around in graphics memory.

That's a problem with VM_PFNMAP set indeed. get_user_pages() is a
non-issue with VM_IO set too but I'm not sure about other code path that
might try to hit here... though I think we don't hit that if MAP_SHARED,
Nick ?

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
