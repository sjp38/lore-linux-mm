Date: Thu, 12 Jun 2008 20:20:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] 2.6.26-rc5-mm3 kernel BUG at mm/filemap.c:575!
Message-Id: <20080612202003.db871cac.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080612015746.172c4b56.akpm@linux-foundation.org>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<4850E1E5.90806@linux.vnet.ibm.com>
	<20080612015746.172c4b56.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 01:57:46 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > Call Trace:
> >  [<ffffffff80270d9c>] truncate_inode_pages_range+0xc5/0x305
> >  [<ffffffff802a7177>] generic_delete_inode+0xc9/0x133
> >  [<ffffffff8029e3cd>] do_unlinkat+0xf0/0x160
> >  [<ffffffff8020bd0b>] system_call_after_swapgs+0x7b/0x80
> > 
> > 
> > Code: 00 00 48 85 c0 74 0b 48 8b 40 10 48 85 c0 74 02 ff d0 e8 75 ec 32 00 41 5b 31 c0 c3 53 48 89 fb f0 0f ba 37 00 19 c0 85 c0 75 04 <0f> 0b eb fe e8 56 f5 ff ff 48 89 de 48 89 c7 31 d2 5b e9 47 be 
> > RIP  [<ffffffff80268155>] unlock_page+0xf/0x26
> >  RSP <ffff81003f9e1dc8>
> > ---[ end trace 27b1d01b03af7c12 ]---
> 
> Another unlock of an unlocked page.  Presumably when reclaim hadn't
> done anything yet. 
> 
> Don't know, sorry.  Strange.
> 
at first look,

==
truncate_inode_pages_range()
	-> TestSetPageLocked()  //
        	-> truncate_complete_page()
			-> remove_from_page_cache() // makes page->mapping to be NULL.
			-> clear_page_mlock()
				-> __clear_page_mlock()
					-> putback_lru_page()
						-> unlock_page() // page->mapping is NULL
	-> unlock_page() //BUG
==

It seems truncate_complete_page() is bad.
==
static void
truncate_complete_page(struct address_space *mapping, struct page *page)
{
        if (page->mapping != mapping)
                return;

        if (PagePrivate(page))
                do_invalidatepage(page, 0);

        cancel_dirty_page(page, PAGE_CACHE_SIZE);

        remove_from_page_cache(page);     -----------------(A)
        clear_page_mlock(page);           -----------------(B)
        ClearPageUptodate(page);
        ClearPageMappedToDisk(page);
        page_cache_release(page);       /* pagecache ref */
}
==

(B) should be called before (A) as invalidate_complete_page() does.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
