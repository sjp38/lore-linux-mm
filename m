Received: by uproxy.gmail.com with SMTP id o2so709444uge
        for <linux-mm@kvack.org>; Tue, 21 Mar 2006 07:20:12 -0800 (PST)
Message-ID: <bc56f2f0603210720q332b0fdbu@mail.gmail.com>
Date: Tue, 21 Mar 2006 10:20:12 -0500
From: "Stone Wang" <pwstone@gmail.com>
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced mlock-LRU semantic
In-Reply-To: <Pine.LNX.4.64.0603200923560.24138@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
	 <Pine.LNX.4.64.0603200923560.24138@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Checked, mlocked pages dont take part in swapping-writeback,
unlike normal mmaped pages :

linux-2.6.16/mm/rmap.c

try_to_unmap_one()

    603     if ((vma->vm_flags & VM_LOCKED) ||
    604             (ptep_clear_flush_young(vma, address, pte)
    605                 && !ignore_refs)) {
    606         ret = SWAP_FAIL;
    607         goto out_unmap;
    608     }
    609
    610     /* Nuke the page table entry. */
    611     flush_cache_page(vma, address, page_to_pfn(page));
    612     pteval = ptep_clear_flush(vma, address, pte);
    613
    614     /* Move the dirty bit to the physical page now the pte is gone. */
    615     if (pte_dirty(pteval))
    616         set_page_dirty(page);

For VM_LOCKED page, it goes back(line 607) without set_page_dirty(line 616).



2006/3/20, Christoph Lameter <clameter@sgi.com>:
> On Mon, 20 Mar 2006, Stone Wang wrote:
>
> > 2. More consistent LRU semantics in Memory Management.
> >    Mlocked pages is placed on a separate LRU list: Wired List.
> >    The pages dont take part in LRU algorithms,for they could never be swapped,
> >    until munlocked.
>
> This also implies that dirty bits of the pte for mlocked pages are never
> checked.
>
> Currently light swapping (which is very common) will scan over all pages
> and move the dirty bits from the pte into struct page. This may take
> awhile but at least at some point we will write out dirtied pages.
>
> The result of not scanning mlocked pages will be that mmapped files will
> not be updated unless either the process terminates or msync() is called.
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
