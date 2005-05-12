Date: Fri, 13 May 2005 08:50:34 +0900 (JST)
Message-Id: <20050513.085034.74732081.taka@valinux.co.jp>
Subject: Re: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2 --
 add-sys_migrate_pages-rc2.patch
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <42838742.3030903@engr.sgi.com>
References: <4282115C.40207@engr.sgi.com>
	<20050512.154148.52902091.taka@valinux.co.jp>
	<42838742.3030903@engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@engr.sgi.com
Cc: raybry@sgi.com, marcelo.tosatti@cyclades.com, ak@suse.de, haveblue@us.ibm.com, hch@infradead.org, linux-mm@kvack.org, nathans@sgi.com, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi Ray,

> > I just thought of the page, belonging to some file which is
> > mmap()ed to the target process to be migrated. The page may
> > not be accessed and the associated PTE isn't set yet.
> > if vma->vm_file->f_mapping equals page_mapping(page), the page
> > should be migrated. 
> > 
> > Pages in the swap-cache have the same problem since the related
> > PTEs may be clean.
> > 
> > But these cases may be rare and your approach seems to be good
> > enough in most cases.
> > 
> > 
> 
> Well, what could be done would be the following, I suppose:
> 
> If follow_page() returns NULL and the vma maps a file, we could
> lookup the page in the radix tree, and if we find it, and if it
> is on a node that we are migrating from, we could add the page
> to the set of pages to be migrated.
> 
> The disadvantage of this is that we could do a LOT of radix
> tree lookups and find relatively few pages.  (Our approach of


How about find_get_pages() for whole mmap()'ed ranges?
With it, you may not need to call follow_page().


> releasing free page cache pages first makes such pages just
> "go away".  But we don't have "release free page cache pages"
> in the mainline yet.  :-( )
>
> Similarly, if we modified follow_page() (e. g. follow_page_ex())
> to return the pte, check to see if it is a swap pte (!pte_none()
> && !pte_file()), if so then use pte_to_swap_entry() to get
> the swap entry, and then use that to look up the page in the
> swapper space radix tree.  Then handle it as above (hmmm...
> will your migration code handle a page in the swap cache?)


Sure. The code can also migrate pages in the swap cache.


> Once again, this could lead to lots of lookups.  This is
> especially a concern for a large multithreaded app, since the
> address spaces are the same for each process id, hence we look
> up the same info over and over in each page table scan.
> 
> -- 
> Best Regards,
> Ray

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
