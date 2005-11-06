Date: Sun, 6 Nov 2005 05:56:42 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Does shmem_getpage==>shmem_alloc_page==>alloc_page_vma hold
 mmap_sem?
In-Reply-To: <20051105212133.714da0d2.pj@sgi.com>
Message-ID: <Pine.LNX.4.61.0511060547120.14675@goblin.wat.veritas.com>
References: <20051105212133.714da0d2.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <ak@suse.de>, akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 5 Nov 2005, Paul Jackson wrote:
> 
> The comment in mm/mempolicy.c for alloc_page_vma() states:
> 
>   Should be called with the mm_sem of the vma hold.
> 
> However it seems that the call chain (#ifdef CONFIG_NUMA):
> 
>   shmem_getpage ==> shmem_alloc_page ==> alloc_page_vma
> 
> where shmem_getpage() is called from many of the mm/shmem.c file
> operations, is called without holding mmap_sem.  There is no
> mention of mmap_sem in the entire mm/shmem.c file.

It's safe but horrid.  Look closer and you'll find there isn't even
an mm to hold the mmap_sem of.  The struct vm_area_struct is on the
stack of shmem_alloc_page, and exists solely to apply mempolicy to
a shmem file via an interface designed for mempolicy on vmas.

So far as I know, it works fine; but that interface really ought
to be redesigned some time - it looks like a quick hack that stuck.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
