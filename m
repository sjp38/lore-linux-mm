Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6876B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 20:27:51 -0500 (EST)
Received: by mail-qk0-f173.google.com with SMTP id s68so321705qkh.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 17:27:51 -0800 (PST)
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com. [209.85.192.53])
        by mx.google.com with ESMTPS id o40si522374qge.54.2016.03.07.17.27.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 17:27:50 -0800 (PST)
Received: by mail-qg0-f53.google.com with SMTP id w104so747119qge.1
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 17:27:50 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: mmotm broken on arm with ebc495cfcea9 (mm: cleanup *pte_alloc*
 interfaces)
Message-ID: <56DE2A92.5010806@redhat.com>
Date: Mon, 7 Mar 2016 17:27:46 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Russell King <linux@arm.linux.org.uk>
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

Hi,

I just tried the master of mmotm and ran into compilation issues on arm:

   CC      arch/arm/mm/mmu.o
arch/arm/mm/mmu.c:737:37: error: macro "pte_alloc" passed 4 arguments, but takes just 3
      void *(*alloc)(unsigned long sz))
                                      ^
arch/arm/mm/mmu.c:738:1: error: expected a??=a??, a??,a??, a??;a??, a??asma?? or a??__attribute__a?? before a??{a?? token
  {
  ^
arch/arm/mm/mmu.c: In function a??early_pte_alloca??:
arch/arm/mm/mmu.c:750:47: error: macro "pte_alloc" passed 4 arguments, but takes just 3
   return pte_alloc(pmd, addr, prot, early_alloc);
                                                ^
arch/arm/mm/mmu.c:750:9: error: a??pte_alloca?? undeclared (first use in this function)
   return pte_alloc(pmd, addr, prot, early_alloc);
          ^
arch/arm/mm/mmu.c:750:9: note: each undeclared identifier is reported only once for each function it appears in
arch/arm/mm/mmu.c: In function a??alloc_init_ptea??:
arch/arm/mm/mmu.c:759:56: error: macro "pte_alloc" passed 4 arguments, but takes just 3
   pte_t *pte = pte_alloc(pmd, addr, type->prot_l1, alloc);
                                                         ^
arch/arm/mm/mmu.c:759:15: error: a??pte_alloca?? undeclared (first use in this function)
   pte_t *pte = pte_alloc(pmd, addr, type->prot_l1, alloc);
                ^
arch/arm/mm/mmu.c: In function a??early_pte_alloca??:
arch/arm/mm/mmu.c:751:1: warning: control reaches end of non-void function [-Wreturn-type]
  }
  ^


It looks like this is caused by ebc495cfcea9 (mm: cleanup *pte_alloc* interfaces)
which added

#define pte_alloc(mm, pmd, address)                     \
         (unlikely(pmd_none(*(pmd))) && __pte_alloc(mm, pmd, address))


and conflicts with arch/arm/mm/mmu.c which is using pte_alloc as a function name.

Is this a known issue? If not, Russell would you take a patch to rename the pte_alloc
functions in arm?

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
