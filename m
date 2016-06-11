Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CEEA76B0005
	for <linux-mm@kvack.org>; Sat, 11 Jun 2016 19:47:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 4so12682464wmz.1
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 16:47:58 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id l6si21994738wjc.51.2016.06.11.16.47.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jun 2016 16:47:57 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id m124so6606086wme.3
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 16:47:57 -0700 (PDT)
Date: Sun, 12 Jun 2016 02:47:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: postpone page table allocation until we have page to map
Message-ID: <20160611234755.GB25148@node.shutemov.name>
References: <20160611201249.GA24708@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160611201249.GA24708@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On Sat, Jun 11, 2016 at 11:12:50PM +0300, Dan Carpenter wrote:
> Hello Kirill A. Shutemov,
> 
> The patch 78d5e6079a91: "mm: postpone page table allocation until we
> have page to map" from Jun 9, 2016, leads to the following static
> checker warning:
> 
> 	mm/memory.c:3175 do_fault_around()
> 	warn: if statement not indented
> 
> mm/memory.c
>   3167          /* check if the page fault is solved */
>   3168          fe->pte -= (fe->address >> PAGE_SHIFT) - (address >> PAGE_SHIFT);
>   3169          if (!pte_none(*fe->pte)) {
>   3170                  /*
>   3171                   * Faultaround produce old pte, but the pte we've
>   3172                   * handler fault for should be young.
>   3173                   */
>   3174                  pte_t entry = pte_mkyoung(*fe->pte);
>   3175                  if (ptep_set_access_flags(fe->vma, fe->address, fe->pte,
>   3176                                          entry, 0))
> 
> What's going on here?  Should the next line be indented?

Yes, it should. The checker is right, I screwed it on conflict solving.
Thanks for spotting this.

Fixup is below.

>   3177                  update_mmu_cache(fe->vma, fe->address, fe->pte);
>   3178                  ret = VM_FAULT_NOPAGE;
>   3179          }
>   3180          pte_unmap_unlock(fe->pte, fe->ptl);
>   3181  out:
>   3182          fe->address = address;
>   3183          fe->pte = NULL;
>   3184          return ret;
>   3185  }

diff --git a/mm/memory.c b/mm/memory.c
index 8e80e8ffc6ee..02cd5d9f0571 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3174,7 +3174,7 @@ static int do_fault_around(struct fault_env *fe, pgoff_t start_pgoff)
 		pte_t entry = pte_mkyoung(*fe->pte);
 		if (ptep_set_access_flags(fe->vma, fe->address, fe->pte,
 					entry, 0))
-		update_mmu_cache(fe->vma, fe->address, fe->pte);
+			update_mmu_cache(fe->vma, fe->address, fe->pte);
 		ret = VM_FAULT_NOPAGE;
 	}
 	pte_unmap_unlock(fe->pte, fe->ptl);
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
