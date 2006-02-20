From: Blaisorblade <blaisorblade@yahoo.it>
Subject: remap_file_pages - Bug with _PAGE_PROTNONE - is it used in current kernels?
Date: Mon, 20 Feb 2006 23:54:48 +0100
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Message-Id: <200602202354.48851.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I've been hitting a bug on a patch I'm working on and have considered (and 
more or less tested with good results) doing this change:

-#define pte_present(x)  ((x).pte_low & (_PAGE_PRESENT | _PAGE_PROTNONE))
+#define pte_present(x)  ((x).pte_low & (_PAGE_PRESENT))

(and the corresponding thing on other architecture).

In general, the question is whether __P000 and __S000 in protection_map are 
ever used except for MAP_POPULATE, and even then if they work well.

I'm seeking for objections to this change and/or anything I'm missing.

This bug showed up while porting remap_file_pages protection support to 
2.6.16-rc3. It always existed but couldn't trigger before the PageReserved 
changes.

Consider a _PAGE_PROTNONE pte, which has then pte_pfn(pte) == 0 (with 
remap_file_pages you need them to exist). Obviously pte_pfn(pte) on such a PTE 
doesn't make sense, but since pte_present(pte) gives true the code doesn't 
know that.

Consider a call to munmap on this range. We get to zap_pte_range() which (in 
condensed source code):

zap_pte_range() 
...
                if (pte_present(ptent)) {
//This test is passed
                        struct page *page = vm_normal_page(vma, addr, ptent);
//Now page points to page 0 - which is wrong, page should be NULL
                        page_remove_rmap(page);
//Which doesn't make any sense.
//If mem_map[0] wasn't mapped we hit a BUG now, if it was we'll hit it later - 
//i.e. negative page_mapcount().

Now, since this code doesn't work in this situation, I wonder whether PROTNONE 
is indeed used anywhere in the code *at the moment*, since faults on pages 
mapped as such are handled with SIGSEGV.

The only possible application, which is only possible in 2.6 and not in 2.4 
where _PAGE_PROTNONE still exists, is mmap(MAP_POPULATE) with prot == 
PROT_NONE.

Instead I need to make use of PROTNONE, so the handling of it may need 
changes. In particular, I wonder about why:

#define pte_present(x)  ((x).pte_low & (_PAGE_PRESENT | _PAGE_PROTNONE))

I see why that _PAGE_PROTNONE can make sense, but in the above code it 
doesn't.
-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade


	

	
		
___________________________________ 
Yahoo! Mail: gratis 1GB per i messaggi e allegati da 10MB 
http://mail.yahoo.it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
