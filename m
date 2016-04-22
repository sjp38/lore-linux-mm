Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45E446B007E
	for <linux-mm@kvack.org>; Fri, 22 Apr 2016 05:44:35 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s63so6507632wme.2
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 02:44:35 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id f1si4253908lfb.44.2016.04.22.02.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Apr 2016 02:44:33 -0700 (PDT)
Received: by mail-lb0-x22a.google.com with SMTP id be4so3176486lbc.0
        for <linux-mm@kvack.org>; Fri, 22 Apr 2016 02:44:33 -0700 (PDT)
Date: Fri, 22 Apr 2016 12:44:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: make fault_around_bytes configurable
Message-ID: <20160422094430.GA7336@node.shutemov.name>
References: <1460992636-711-1-git-send-email-vinmenon@codeaurora.org>
 <20160421170150.b492ffe35d073270b53f0e4d@linux-foundation.org>
 <5719E494.20302@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5719E494.20302@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dan.j.williams@intel.com, mgorman@suse.de, vbabka@suse.cz, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, hughd@google.com

On Fri, Apr 22, 2016 at 02:15:08PM +0530, Vinayak Menon wrote:
> On 04/22/2016 05:31 AM, Andrew Morton wrote:
> >On Mon, 18 Apr 2016 20:47:16 +0530 Vinayak Menon <vinmenon@codeaurora.org> wrote:
> >
> >>Mapping pages around fault is found to cause performance degradation
> >>in certain use cases. The test performed here is launch of 10 apps
> >>one by one, doing something with the app each time, and then repeating
> >>the same sequence once more, on an ARM 64-bit Android device with 2GB
> >>of RAM. The time taken to launch the apps is found to be better when
> >>fault around feature is disabled by setting fault_around_bytes to page
> >>size (4096 in this case).
> >
> >Well that's one workload, and a somewhat strange one.  What is the
> >effect on other workloads (of which there are a lot!).
> >
> This workload emulates the way a user would use his mobile device, opening
> an application, using it for some time, switching to next, and then coming
> back to the same application later. Another stat which shows significant
> degradation on Android with fault_around is device boot up time. I have not
> tried any other workload other than these.
> 
> >>The tests were done on 3.18 kernel. 4 extra vmstat counters were added
> >>for debugging. pgpgoutclean accounts the clean pages reclaimed via
> >>__delete_from_page_cache. pageref_activate, pageref_activate_vm_exec,
> >>and pageref_keep accounts the mapped file pages activated and retained
> >>by page_check_references.
> >>
> >>=== Without swap ===
> >>                           3.18             3.18-fault_around_bytes=4096
> >>-----------------------------------------------------------------------
> >>workingset_refault        691100           664339
> >>workingset_activate       210379           179139
> >>pgpgin                    4676096          4492780
> >>pgpgout                   163967           96711
> >>pgpgoutclean              1090664          990659
> >>pgalloc_dma               3463111          3328299
> >>pgfree                    3502365          3363866
> >>pgactivate                568134           238570
> >>pgdeactivate              752260           392138
> >>pageref_activate          315078           121705
> >>pageref_activate_vm_exec  162940           55815
> >>pageref_keep              141354           51011
> >>pgmajfault                24863            23633
> >>pgrefill_dma              1116370          544042
> >>pgscan_kswapd_dma         1735186          1234622
> >>pgsteal_kswapd_dma        1121769          1005725
> >>pgscan_direct_dma         12966            1090
> >>pgsteal_direct_dma        6209             967
> >>slabs_scanned             1539849          977351
> >>pageoutrun                1260             1333
> >>allocstall                47               7
> >>
> >>=== With swap ===
> >>                           3.18             3.18-fault_around_bytes=4096
> >>-----------------------------------------------------------------------
> >>workingset_refault        597687           878109
> >>workingset_activate       167169           254037
> >>pgpgin                    4035424          5157348
> >>pgpgout                   162151           85231
> >>pgpgoutclean              928587           1225029
> >>pswpin                    46033            17100
> >>pswpout                   237952           127686
> >>pgalloc_dma               3305034          3542614
> >>pgfree                    3354989          3592132
> >>pgactivate                626468           355275
> >>pgdeactivate              990205           771902
> >>pageref_activate          294780           157106
> >>pageref_activate_vm_exec  141722           63469
> >>pageref_keep              121931           63028
> >>pgmajfault                67818            45643
> >>pgrefill_dma              1324023          977192
> >>pgscan_kswapd_dma         1825267          1720322
> >>pgsteal_kswapd_dma        1181882          1365500
> >>pgscan_direct_dma         41957            9622
> >>pgsteal_direct_dma        25136            6759
> >>slabs_scanned             689575           542705
> >>pageoutrun                1234             1538
> >>allocstall                110              26
> >>
> >>Looks like with fault_around, there is more pressure on reclaim because
> >>of the presence of more mapped pages, resulting in more IO activity,
> >>more faults, more swapping, and allocstalls.
> >
> >A few of those things did get a bit worse?
> I think some numbers (like workingset, pgpgin, pgpgoutclean etc) looks
> better with fault_around because, increased number of mapped pages is
> resulting in less number of file pages being reclaimed (pageref_activate,
> pageref_activate_vm_exec, pageref_keep above), but increased swapping.
> Latency numbers are far bad with fault_around_bytes + swap, possibly because
> of increased swapping, decrease in kswapd efficiency and increase in
> allocstalls.
> So the problem looks to be that unwanted pages are mapped around the fault
> and page_check_references is unaware of this.

Hm. It makes me think we should make ptes setup by faultaround old.

Although, it would defeat (to some extend) purpose of faultaround on
architectures without HW accessed bit :-/

Could you check if the patch below changes the situation?
It would require some more work to not mark the pte we've got fault for old.

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a55e5be0894f..1066fabf17c3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -584,7 +584,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 }
 
 void do_set_pte(struct vm_area_struct *vma, unsigned long address,
-		struct page *page, pte_t *pte, bool write, bool anon);
+		struct page *page, pte_t *pte, bool write, bool anon, bool old);
 #endif
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index f2479af09da9..47ba88fd7192 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2189,7 +2189,7 @@ repeat:
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 		addr = address + (page->index - vmf->pgoff) * PAGE_SIZE;
-		do_set_pte(vma, addr, page, pte, false, false);
+		do_set_pte(vma, addr, page, pte, false, false, true);
 		unlock_page(page);
 		goto next;
 unlock:
diff --git a/mm/memory.c b/mm/memory.c
index 93897f23cc11..fa3ac184eafd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2836,7 +2836,7 @@ static int __do_fault(struct vm_area_struct *vma, unsigned long address,
  * vm_ops->map_pages.
  */
 void do_set_pte(struct vm_area_struct *vma, unsigned long address,
-		struct page *page, pte_t *pte, bool write, bool anon)
+		struct page *page, pte_t *pte, bool write, bool anon, bool old)
 {
 	pte_t entry;
 
@@ -2844,6 +2844,8 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	if (old)
+		entry = pte_mkold(entry);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address, false);
@@ -2998,7 +3000,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, false, false);
+	do_set_pte(vma, address, fault_page, pte, false, false, false);
 	unlock_page(fault_page);
 unlock_out:
 	pte_unmap_unlock(pte, ptl);
@@ -3050,7 +3052,7 @@ static int do_cow_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		goto uncharge_out;
 	}
-	do_set_pte(vma, address, new_page, pte, true, true);
+	do_set_pte(vma, address, new_page, pte, true, true, false);
 	mem_cgroup_commit_charge(new_page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(new_page, vma);
 	pte_unmap_unlock(pte, ptl);
@@ -3107,7 +3109,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		put_page(fault_page);
 		return ret;
 	}
-	do_set_pte(vma, address, fault_page, pte, true, false);
+	do_set_pte(vma, address, fault_page, pte, true, false, false);
 	pte_unmap_unlock(pte, ptl);
 
 	if (set_page_dirty(fault_page))
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
