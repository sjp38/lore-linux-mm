Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54724C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 05:55:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E178420879
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 05:55:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E178420879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A9096B0003; Tue, 14 May 2019 01:55:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8317D6B0005; Tue, 14 May 2019 01:55:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AA676B0007; Tue, 14 May 2019 01:55:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 124E56B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 01:55:29 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d22so10837587pgg.2
        for <linux-mm@kvack.org>; Mon, 13 May 2019 22:55:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=0Vd5itc0PyVU69m5Uh4FmbBwOyLCeRGFUEkx8hLx39o=;
        b=YFsQE8GUiGP0IamtGvjfPrhtH+jYjU1RJx5k1bD+skNJ/IeqvEN3dRFY5hybEGNnXb
         WbxUW/ClkUe4AWlvkIDXqhpVCGj2aHRRTvuMRNNUU1iFfKflU3WG9oYvMKhKay7IzHya
         VdFlJPfL3ZZSr+Ns3Cnj+oqOCR6p7IQPPX8VvrMLOGBNoYZ57oTNSDZnPpYS29LW4BU8
         lbDFdRaWE3CWocvyutRsmWqswCGWEXojxEiSzfguoNq0hP7ImzQqKGA4qQlrFTnQ7SDu
         IJ40zg9elb6474U4EJON38PLRDTEgsvbdRD49tdwW0us5tIzb8yVwnMWCSSPzs+pJxx7
         UPmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXY1Wh30qasU4YIZFbk9mmK8kDqtmvkLIhcazXQR2sukjeoBoI3
	qphcAHj0NW63cEEbXWo0N7yq/wgUayTdPE/JBtDy0AJXxTlSDqdIIt09Z+XpQ31fsDtAlhsb/Kr
	1hUp51o/NEar9u76VoK2zm82soMlHLfKpR5Kq5GhUBAKVRhsRYDepyimU+2XRUWuo0g==
X-Received: by 2002:a63:778b:: with SMTP id s133mr35972244pgc.198.1557813328408;
        Mon, 13 May 2019 22:55:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWYRpe+L3mZqg4nrvd8Q5d1g/PXUmiXDknWAo66nuKPs6nZE2dX0PiNqXsV1B98C6BPIyQ
X-Received: by 2002:a63:778b:: with SMTP id s133mr35972174pgc.198.1557813326823;
        Mon, 13 May 2019 22:55:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557813326; cv=none;
        d=google.com; s=arc-20160816;
        b=k6PNfdf0VTU00XhlFtiYI9UXaRDHKBEyLS6mvqH53llwEOGOvPrZKNKxSep1XbTDwC
         7+2lcaSYZTI3m7kwFH77nSuZAP3pA+BKC7y+7KmAsQoFBoMcB0gwaOm9HwDqZ+caBJvx
         ThxiO5rvBbUA416YivmRxY99edz8lUNNhi7bJSwGBjCPrSz2C5mqyb+U6sORYxpMzHuD
         e4zQ5C2o8MnnArwkqaXnr8i5TCcDVFPmwe+PKssXfxS/6A7LoidViyff8oNT1DptRu5t
         UK66UX91G0APxj36DHVb+nQMDodVEzYrSJhzARSOe/KQ0op0ztzlFllXcDosnJXJu+kc
         IPKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date;
        bh=0Vd5itc0PyVU69m5Uh4FmbBwOyLCeRGFUEkx8hLx39o=;
        b=wvmUAhCJJRzoYOer8jc/vzZjbQmPNGUbZgem8+jGryc2fpODPOCz3of6uEy6ovGjL2
         oaTEZgKvTiJstnHHPRFMDN3AC2is65+mid3BNHSbsMdwlwW4UhPrILA26QMA02aSshf3
         ffg+IpdZ6S/7Rd8QvbBJxN4P/VGX1KiLIMfFItJeWkneL1qwXUWZE98YczuJkynfjO8m
         XJLvnttz8FLrs7EVBEBxmkQ2HQZ3FdCUAo8/Mdz+nF7mbo67x2tMeCHOKv54uXb6Fl3j
         XHVV/J77Mj2bd6doCnoy1odSHJjQPlcGeXZ3Gi+wzalctGvEoD8Ahijn7Xggv8i8vTIB
         D7+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v1si18806361plp.26.2019.05.13.22.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 22:55:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 May 2019 22:55:11 -0700
X-ExtLoop1: 1
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga006.fm.intel.com with ESMTP; 13 May 2019 22:55:09 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hQQP6-0007Cm-RJ; Tue, 14 May 2019 13:55:08 +0800
Date: Tue, 14 May 2019 13:54:14 +0800
From: kbuild test robot <lkp@intel.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [rgushchin:kmem_reparent.4 170/380] mm/mprotect.c:152:16: error:
 'mm' undeclared
Message-ID: <201905141304.Vh2XjwB3%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

tree:   https://github.com/rgushchin/linux.git kmem_reparent.4
head:   595d92aaebb6a603b2820ce7188b6db971693d85
commit: c7b45943bdf12b5ccfcd016538c62aa7edd604d5 [170/380] mm/mprotect.c: fix compilation warning because of unused 'mm' varaible
config: i386-randconfig-l0-05140835 (attached as .config)
compiler: gcc-5 (Debian 5.5.0-3) 5.4.1 20171010
reproduce:
        git checkout c7b45943bdf12b5ccfcd016538c62aa7edd604d5
        # save the attached .config to linux build tree
        make ARCH=i386 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>

Note: the rgushchin/kmem_reparent.4 HEAD 595d92aaebb6a603b2820ce7188b6db971693d85 builds fine.
      It only hurts bisectibility.

All errors (new ones prefixed by >>):

   In file included from include/linux/mm.h:99:0,
                    from mm/mprotect.c:12:
   mm/mprotect.c: In function 'change_pte_range':
   mm/mprotect.c:138:19: error: 'struct vm_area_struct' has no member named 'mm'
        set_pte_at(vma->mm, addr, pte, newpte);
                      ^
   arch/x86/include/asm/pgtable.h:64:59: note: in definition of macro 'set_pte_at'
    #define set_pte_at(mm, addr, ptep, pte) native_set_pte_at(mm, addr, ptep, pte)
                                                              ^
>> mm/mprotect.c:152:16: error: 'mm' undeclared (first use in this function)
        set_pte_at(mm, addr, pte, newpte);
                   ^
   arch/x86/include/asm/pgtable.h:64:59: note: in definition of macro 'set_pte_at'
    #define set_pte_at(mm, addr, ptep, pte) native_set_pte_at(mm, addr, ptep, pte)
                                                              ^
   mm/mprotect.c:152:16: note: each undeclared identifier is reported only once for each function it appears in
        set_pte_at(mm, addr, pte, newpte);
                   ^
   arch/x86/include/asm/pgtable.h:64:59: note: in definition of macro 'set_pte_at'
    #define set_pte_at(mm, addr, ptep, pte) native_set_pte_at(mm, addr, ptep, pte)
                                                              ^

vim +/mm +152 mm/mprotect.c

^1da177e4 Linus Torvalds     2005-04-16  @12  #include <linux/mm.h>
^1da177e4 Linus Torvalds     2005-04-16   13  #include <linux/hugetlb.h>
^1da177e4 Linus Torvalds     2005-04-16   14  #include <linux/shm.h>
^1da177e4 Linus Torvalds     2005-04-16   15  #include <linux/mman.h>
^1da177e4 Linus Torvalds     2005-04-16   16  #include <linux/fs.h>
^1da177e4 Linus Torvalds     2005-04-16   17  #include <linux/highmem.h>
^1da177e4 Linus Torvalds     2005-04-16   18  #include <linux/security.h>
^1da177e4 Linus Torvalds     2005-04-16   19  #include <linux/mempolicy.h>
^1da177e4 Linus Torvalds     2005-04-16   20  #include <linux/personality.h>
^1da177e4 Linus Torvalds     2005-04-16   21  #include <linux/syscalls.h>
0697212a4 Christoph Lameter  2006-06-23   22  #include <linux/swap.h>
0697212a4 Christoph Lameter  2006-06-23   23  #include <linux/swapops.h>
cddb8a5c1 Andrea Arcangeli   2008-07-28   24  #include <linux/mmu_notifier.h>
64cdd548f KOSAKI Motohiro    2009-01-06   25  #include <linux/migrate.h>
cdd6c482c Ingo Molnar        2009-09-21   26  #include <linux/perf_event.h>
e8c24d3a2 Dave Hansen        2016-07-29   27  #include <linux/pkeys.h>
64a9a34e2 Mel Gorman         2014-01-21   28  #include <linux/ksm.h>
7c0f6ba68 Linus Torvalds     2016-12-24   29  #include <linux/uaccess.h>
09a913a7a Mel Gorman         2018-04-10   30  #include <linux/mm_inline.h>
^1da177e4 Linus Torvalds     2005-04-16   31  #include <asm/pgtable.h>
^1da177e4 Linus Torvalds     2005-04-16   32  #include <asm/cacheflush.h>
e8c24d3a2 Dave Hansen        2016-07-29   33  #include <asm/mmu_context.h>
^1da177e4 Linus Torvalds     2005-04-16   34  #include <asm/tlbflush.h>
^1da177e4 Linus Torvalds     2005-04-16   35  
36f881883 Kirill A. Shutemov 2015-06-24   36  #include "internal.h"
36f881883 Kirill A. Shutemov 2015-06-24   37  
4b10e7d56 Mel Gorman         2012-10-25   38  static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
c1e6098b2 Peter Zijlstra     2006-09-25   39  		unsigned long addr, unsigned long end, pgprot_t newprot,
0f19c1792 Mel Gorman         2013-10-07   40  		int dirty_accountable, int prot_numa)
^1da177e4 Linus Torvalds     2005-04-16   41  {
0697212a4 Christoph Lameter  2006-06-23   42  	pte_t *pte, oldpte;
705e87c0c Hugh Dickins       2005-10-29   43  	spinlock_t *ptl;
7da4d641c Peter Zijlstra     2012-11-19   44  	unsigned long pages = 0;
3e3215876 Andi Kleen         2016-12-12   45  	int target_node = NUMA_NO_NODE;
^1da177e4 Linus Torvalds     2005-04-16   46  
175ad4f1e Andrea Arcangeli   2017-02-22   47  	/*
175ad4f1e Andrea Arcangeli   2017-02-22   48  	 * Can be called with only the mmap_sem for reading by
175ad4f1e Andrea Arcangeli   2017-02-22   49  	 * prot_numa so we must check the pmd isn't constantly
175ad4f1e Andrea Arcangeli   2017-02-22   50  	 * changing from under us from pmd_none to pmd_trans_huge
175ad4f1e Andrea Arcangeli   2017-02-22   51  	 * and/or the other way around.
175ad4f1e Andrea Arcangeli   2017-02-22   52  	 */
175ad4f1e Andrea Arcangeli   2017-02-22   53  	if (pmd_trans_unstable(pmd))
175ad4f1e Andrea Arcangeli   2017-02-22   54  		return 0;
175ad4f1e Andrea Arcangeli   2017-02-22   55  
175ad4f1e Andrea Arcangeli   2017-02-22   56  	/*
175ad4f1e Andrea Arcangeli   2017-02-22   57  	 * The pmd points to a regular pte so the pmd can't change
175ad4f1e Andrea Arcangeli   2017-02-22   58  	 * from under us even if the mmap_sem is only hold for
175ad4f1e Andrea Arcangeli   2017-02-22   59  	 * reading.
175ad4f1e Andrea Arcangeli   2017-02-22   60  	 */
175ad4f1e Andrea Arcangeli   2017-02-22   61  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
1ad9f620c Mel Gorman         2014-04-07   62  
3e3215876 Andi Kleen         2016-12-12   63  	/* Get target node for single threaded private VMAs */
3e3215876 Andi Kleen         2016-12-12   64  	if (prot_numa && !(vma->vm_flags & VM_SHARED) &&
3e3215876 Andi Kleen         2016-12-12   65  	    atomic_read(&vma->vm_mm->mm_users) == 1)
3e3215876 Andi Kleen         2016-12-12   66  		target_node = numa_node_id();
3e3215876 Andi Kleen         2016-12-12   67  
3ea277194 Mel Gorman         2017-08-02   68  	flush_tlb_batched_pending(vma->vm_mm);
6606c3e0d Zachary Amsden     2006-09-30   69  	arch_enter_lazy_mmu_mode();
^1da177e4 Linus Torvalds     2005-04-16   70  	do {
0697212a4 Christoph Lameter  2006-06-23   71  		oldpte = *pte;
0697212a4 Christoph Lameter  2006-06-23   72  		if (pte_present(oldpte)) {
^1da177e4 Linus Torvalds     2005-04-16   73  			pte_t ptent;
b191f9b10 Mel Gorman         2015-03-25   74  			bool preserve_write = prot_numa && pte_write(oldpte);
^1da177e4 Linus Torvalds     2005-04-16   75  
e944fd67b Mel Gorman         2015-02-12   76  			/*
e944fd67b Mel Gorman         2015-02-12   77  			 * Avoid trapping faults against the zero or KSM
e944fd67b Mel Gorman         2015-02-12   78  			 * pages. See similar comment in change_huge_pmd.
e944fd67b Mel Gorman         2015-02-12   79  			 */
e944fd67b Mel Gorman         2015-02-12   80  			if (prot_numa) {
e944fd67b Mel Gorman         2015-02-12   81  				struct page *page;
e944fd67b Mel Gorman         2015-02-12   82  
e944fd67b Mel Gorman         2015-02-12   83  				page = vm_normal_page(vma, addr, oldpte);
e944fd67b Mel Gorman         2015-02-12   84  				if (!page || PageKsm(page))
e944fd67b Mel Gorman         2015-02-12   85  					continue;
10c1045f2 Mel Gorman         2015-02-12   86  
859d4adc3 Henry Willard      2018-01-31   87  				/* Also skip shared copy-on-write pages */
859d4adc3 Henry Willard      2018-01-31   88  				if (is_cow_mapping(vma->vm_flags) &&
859d4adc3 Henry Willard      2018-01-31   89  				    page_mapcount(page) != 1)
859d4adc3 Henry Willard      2018-01-31   90  					continue;
859d4adc3 Henry Willard      2018-01-31   91  
09a913a7a Mel Gorman         2018-04-10   92  				/*
09a913a7a Mel Gorman         2018-04-10   93  				 * While migration can move some dirty pages,
09a913a7a Mel Gorman         2018-04-10   94  				 * it cannot move them all from MIGRATE_ASYNC
09a913a7a Mel Gorman         2018-04-10   95  				 * context.
09a913a7a Mel Gorman         2018-04-10   96  				 */
09a913a7a Mel Gorman         2018-04-10   97  				if (page_is_file_cache(page) && PageDirty(page))
09a913a7a Mel Gorman         2018-04-10   98  					continue;
09a913a7a Mel Gorman         2018-04-10   99  
10c1045f2 Mel Gorman         2015-02-12  100  				/* Avoid TLB flush if possible */
10c1045f2 Mel Gorman         2015-02-12  101  				if (pte_protnone(oldpte))
10c1045f2 Mel Gorman         2015-02-12  102  					continue;
3e3215876 Andi Kleen         2016-12-12  103  
3e3215876 Andi Kleen         2016-12-12  104  				/*
3e3215876 Andi Kleen         2016-12-12  105  				 * Don't mess with PTEs if page is already on the node
3e3215876 Andi Kleen         2016-12-12  106  				 * a single-threaded process is running on.
3e3215876 Andi Kleen         2016-12-12  107  				 */
3e3215876 Andi Kleen         2016-12-12  108  				if (target_node == page_to_nid(page))
3e3215876 Andi Kleen         2016-12-12  109  					continue;
e944fd67b Mel Gorman         2015-02-12  110  			}
e944fd67b Mel Gorman         2015-02-12  111  
04a864530 Aneesh Kumar K.V   2019-03-05  112  			oldpte = ptep_modify_prot_start(vma, addr, pte);
04a864530 Aneesh Kumar K.V   2019-03-05  113  			ptent = pte_modify(oldpte, newprot);
b191f9b10 Mel Gorman         2015-03-25  114  			if (preserve_write)
288bc5494 Aneesh Kumar K.V   2017-02-24  115  				ptent = pte_mk_savedwrite(ptent);
8a0516ed8 Mel Gorman         2015-02-12  116  
8a0516ed8 Mel Gorman         2015-02-12  117  			/* Avoid taking write faults for known dirty pages */
64e455079 Peter Feiner       2014-10-13  118  			if (dirty_accountable && pte_dirty(ptent) &&
64e455079 Peter Feiner       2014-10-13  119  					(pte_soft_dirty(ptent) ||
8a0516ed8 Mel Gorman         2015-02-12  120  					 !(vma->vm_flags & VM_SOFTDIRTY))) {
9d85d5863 Aneesh Kumar K.V   2014-02-12  121  				ptent = pte_mkwrite(ptent);
4b10e7d56 Mel Gorman         2012-10-25  122  			}
04a864530 Aneesh Kumar K.V   2019-03-05  123  			ptep_modify_prot_commit(vma, addr, pte, oldpte, ptent);
7da4d641c Peter Zijlstra     2012-11-19  124  			pages++;
0661a3361 Kirill A. Shutemov 2015-02-10  125  		} else if (IS_ENABLED(CONFIG_MIGRATION)) {
0697212a4 Christoph Lameter  2006-06-23  126  			swp_entry_t entry = pte_to_swp_entry(oldpte);
0697212a4 Christoph Lameter  2006-06-23  127  
0697212a4 Christoph Lameter  2006-06-23  128  			if (is_write_migration_entry(entry)) {
c3d16e165 Cyrill Gorcunov    2013-10-16  129  				pte_t newpte;
0697212a4 Christoph Lameter  2006-06-23  130  				/*
0697212a4 Christoph Lameter  2006-06-23  131  				 * A protection check is difficult so
0697212a4 Christoph Lameter  2006-06-23  132  				 * just be safe and disable write
0697212a4 Christoph Lameter  2006-06-23  133  				 */
0697212a4 Christoph Lameter  2006-06-23  134  				make_migration_entry_read(&entry);
c3d16e165 Cyrill Gorcunov    2013-10-16  135  				newpte = swp_entry_to_pte(entry);
c3d16e165 Cyrill Gorcunov    2013-10-16  136  				if (pte_swp_soft_dirty(oldpte))
c3d16e165 Cyrill Gorcunov    2013-10-16  137  					newpte = pte_swp_mksoft_dirty(newpte);
c7b45943b Mike Rapoport      2019-05-12  138  				set_pte_at(vma->mm, addr, pte, newpte);
e920e14ca Mel Gorman         2013-10-07  139  
7da4d641c Peter Zijlstra     2012-11-19  140  				pages++;
^1da177e4 Linus Torvalds     2005-04-16  141  			}
5042db43c Jérôme Glisse      2017-09-08  142  
5042db43c Jérôme Glisse      2017-09-08  143  			if (is_write_device_private_entry(entry)) {
5042db43c Jérôme Glisse      2017-09-08  144  				pte_t newpte;
5042db43c Jérôme Glisse      2017-09-08  145  
5042db43c Jérôme Glisse      2017-09-08  146  				/*
5042db43c Jérôme Glisse      2017-09-08  147  				 * We do not preserve soft-dirtiness. See
5042db43c Jérôme Glisse      2017-09-08  148  				 * copy_one_pte() for explanation.
5042db43c Jérôme Glisse      2017-09-08  149  				 */
5042db43c Jérôme Glisse      2017-09-08  150  				make_device_private_entry_read(&entry);
5042db43c Jérôme Glisse      2017-09-08  151  				newpte = swp_entry_to_pte(entry);
5042db43c Jérôme Glisse      2017-09-08 @152  				set_pte_at(mm, addr, pte, newpte);
5042db43c Jérôme Glisse      2017-09-08  153  
5042db43c Jérôme Glisse      2017-09-08  154  				pages++;
5042db43c Jérôme Glisse      2017-09-08  155  			}
e920e14ca Mel Gorman         2013-10-07  156  		}
^1da177e4 Linus Torvalds     2005-04-16  157  	} while (pte++, addr += PAGE_SIZE, addr != end);
6606c3e0d Zachary Amsden     2006-09-30  158  	arch_leave_lazy_mmu_mode();
705e87c0c Hugh Dickins       2005-10-29  159  	pte_unmap_unlock(pte - 1, ptl);
7da4d641c Peter Zijlstra     2012-11-19  160  
7da4d641c Peter Zijlstra     2012-11-19  161  	return pages;
^1da177e4 Linus Torvalds     2005-04-16  162  }
^1da177e4 Linus Torvalds     2005-04-16  163  

:::::: The code at line 152 was first introduced by commit
:::::: 5042db43cc26f51eed51c56192e2c2317e44315f mm/ZONE_DEVICE: new type of ZONE_DEVICE for unaddressable memory

:::::: TO: Jérôme Glisse <jglisse@redhat.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--17pEHd4RhPHOinZp
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
H1kiMUc5twEA

--17pEHd4RhPHOinZp--

