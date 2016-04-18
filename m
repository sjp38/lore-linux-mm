Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 406D26B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 12:05:05 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d19so118924054lfb.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 09:05:05 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id g128si27369733wmf.119.2016.04.18.09.05.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 09:05:03 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id n3so131997187wmn.0
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 09:05:03 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH resend 0/3] mm: allow arch to override lowmem_page_address
Date: Mon, 18 Apr 2016 18:04:54 +0200
Message-Id: <1460995497-24312-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, lftan@altera.com, jonas@southpole.se
Cc: will.deacon@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

These patches allow the arch to define the page_to_virt() conversion that
is used in lowmem_page_address(). This is desirable for arm64, where this
conversion is trivial when CONFIG_SPARSEMEM_VMEMMAP is enabled, while
breaking it up into __va(PFN_PHYS(page_to_pfn(page))), as is done currently
in lowmem_page_address(), will force the use of a virt-to-phys() conversion
and back again, which always involves a memory access on arm64, since the
start of physical memory is not a compile time constant.

I have split off these patches from my series 'arm64: optimize virt_to_page
and page_address' which I sent out 3 weeks ago, and resending them in the
hope that they can be picked up (with Will's ack on #3) to be merged via
the mm tree.

I have cc'ed the nios2 and openrisc maintainers on previous versions, and
cc'ing them again now. I have dropped both of the arch specific mailing
lists, since one is defunct and the other is subscriber only.

Andrew, is this something you would be pulling to pick up (assuming that you
agree with the contents)? Thanks.

Ard Biesheuvel (3):
  nios2: use correct void* return type for page_to_virt()
  openrisc: drop wrongly typed definition of page_to_virt()
  mm: replace open coded page to virt conversion with page_to_virt()

 arch/nios2/include/asm/io.h      | 1 -
 arch/nios2/include/asm/page.h    | 2 +-
 arch/nios2/include/asm/pgtable.h | 2 +-
 arch/openrisc/include/asm/page.h | 2 --
 include/linux/mm.h               | 6 +++++-
 5 files changed, 7 insertions(+), 6 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
