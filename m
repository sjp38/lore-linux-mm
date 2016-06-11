Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB8F06B0005
	for <linux-mm@kvack.org>; Sat, 11 Jun 2016 16:13:00 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id lp2so43392382igb.3
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 13:13:00 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a63si18456246ioj.94.2016.06.11.13.12.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jun 2016 13:13:00 -0700 (PDT)
Date: Sat, 11 Jun 2016 23:12:50 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: postpone page table allocation until we have page to map
Message-ID: <20160611201249.GA24708@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org

Hello Kirill A. Shutemov,

The patch 78d5e6079a91: "mm: postpone page table allocation until we
have page to map" from Jun 9, 2016, leads to the following static
checker warning:

	mm/memory.c:3175 do_fault_around()
	warn: if statement not indented

mm/memory.c
  3167          /* check if the page fault is solved */
  3168          fe->pte -= (fe->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
  3169          if (!pte_none(*fe->pte)) {
  3170                  /*
  3171                   * Faultaround produce old pte, but the pte we've
  3172                   * handler fault for should be young.
  3173                   */
  3174                  pte_t entry = pte_mkyoung(*fe->pte);
  3175                  if (ptep_set_access_flags(fe->vma, fe->address, fe->pte,
  3176                                          entry, 0))

What's going on here?  Should the next line be indented?

  3177                  update_mmu_cache(fe->vma, fe->address, fe->pte);
  3178                  ret = VM_FAULT_NOPAGE;
  3179          }
  3180          pte_unmap_unlock(fe->pte, fe->ptl);
  3181  out:
  3182          fe->address = address;
  3183          fe->pte = NULL;
  3184          return ret;
  3185  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
