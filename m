Date: Thu, 30 Nov 2006 13:11:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/1] Node-based reclaim/migration
Message-Id: <20061130131104.b3bd70dd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
References: <20061129030655.941148000@menage.corp.google.com>
	<20061130093105.d872c49d.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830611291631hd6d3e52y971c35708004db00@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Nov 2006 16:31:22 -0800
"Paul Menage" <menage@google.com> wrote:

> On 11/29/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> > 2. AFAIK, migrating pages without taking write lock of any mm->sem will
> >    cause problem. anon_vma can be freed while migration.
> 
> Hmm, isn't migration just analagous to swapping out and swapping back
> in again, but without the actual swapping?
> 
I'm sorry if there is no problem in *current* kernel
== See ==
http://lkml.org/lkml/2006/4/17/168
>mmap_sem must be held during page migration due to the way we retrieve the 
>anonymous vma.
========

Logic
Considering migrate oldpage to newpage..

1. We unmap a oldpage at migraiton. page->mapcount turns to be 0.
2. copy contents of the oldpage to a newpage. page->mapcount of both pages are 0.
3. map the newpage. this uses copied newpage->mapping. page->mapcount goes up.

And see rmap.c
==
 511 void page_remove_rmap(struct page *page)
 512 {
 513         if (atomic_add_negative(-1, &page->_mapcount)) {
 514 #ifdef CONFIG_DEBUG_VM
 515                 if (unlikely(page_mapcount(page) < 0)) {
 516                         printk (KERN_EMERG "Eeek! page_mapcount(page) went negative! (%d)\n", page_mapcount(page));
 517                         printk (KERN_EMERG "  page->flags = %lx\n", page->flags);
 518                         printk (KERN_EMERG "  page->count = %x\n", page_count(page));
 519                         printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
 520                 }
 521 #endif
 522                 BUG_ON(page_mapcount(page) < 0);
 523                 /*
 524                  * It would be tidy to reset the PageAnon mapping here,
 525                  * but that might overwrite a racing page_add_anon_rmap
 526                  * which increments mapcount after us but sets mapping
 527                  * before us: so leave the reset to free_hot_cold_page,
 528                  * and remember that it's only reliable while mapped.
 529                  * Leaving it set also helps swapoff to reinstate ptes
 530                  * faster for those pages still in swapcache.
 531                  */
 532                 if (page_test_and_clear_dirty(page))
 533                         set_page_dirty(page);
 534                 __dec_zone_page_state(page,
 535                                 PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
 536         }
====
We cannot trust page->mapping if page->mapcount == 0.
File pages are guarded by address_space's lock.

if mm->sem is held, the oldpage's anon_vma/vm_area_struct will not change.
Then, the relationship between oldpage/anon_vma will not change.
So, page migration with mm->sem is safe.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
