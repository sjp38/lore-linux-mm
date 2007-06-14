Date: Thu, 14 Jun 2007 16:41:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
Message-Id: <20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
	<20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007 00:22:10 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> But the code is checking for an anonymous page and then checks if it is 
> mapped.
> 
Ouch, here ?
+	if (PageAnon(page) && page_mapped(page)) {
+		anon_vma = page_lock_anon_vma(page);

In my understanding:

PageAnon(page) checks (page->mapping & 0x1). And, as you know, page->mapping
is not cleared even if the page is removed from rmap.

See zap_pte_range(), it does
==
                        page = vm_normal_page(vma, addr, ptent);
                        if (unlikely(details) && page) {
                            <snip>
                        }
                        ptent = ptep_get_and_clear_full(mm, addr, pte,
                                                        tlb->fullmm);
                        tlb_remove_tlb_entry(tlb, pte, addr);
                        <snip>
                        if (PageAnon(page))
                                anon_rss--;
                        else {
                                if (pte_dirty(ptent))
                                        set_page_dirty(page);
                                if (pte_young(ptent))
                                        SetPageReferenced(page);
                                file_rss--;
                        }
                        page_remove_rmap(page, vma);
                        tlb_remove_page(tlb, page); <-------------- page is freed here.
==
When a page is freed , the page is not locked. There is no lock.

But... page_lock_anon_vma() check page_mapped() by itself.

My patch should be
==
+	if (PageAnon(page)) {
+		anon_vma = page_lock_anon_vma(page);
==
This is my mistake.


-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
