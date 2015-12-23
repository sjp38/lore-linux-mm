Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id A702182F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 19:54:50 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id jw2so69193922igc.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 16:54:50 -0800 (PST)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id w6si36908062igz.60.2015.12.22.16.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 16:54:50 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 0/2] Change PAT to support mremap use-cases
Date: Tue, 22 Dec 2015 17:54:22 -0700
Message-Id: <1450832064-10093-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de
Cc: stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch-set fixes two issues found in PAT when mremap() is used on
a VM_PFNMAP range.

Patch 1/2 fixes an issue for mremap() with MREMAP_FIXED, which moves
a pfnmap from old vma to new vma.  untrack_pfn_moved() is added to
clear VM_PAT from old vma.

Patch 2/2 fixes an issue for mremap() with a shrinking map size.
The free_memtype() path is changed to support this mremap case in
addition to the regular munmap case. 

Note, using mremap() with an expanded map size is not a valid case
since VM_DONTEXPAND is set along with VM_PFNMAP.

v2:
 - Add an explicit call in the mremap code which clears the PAT flag.
   (Thomas Gleixner)
 - Add comment to explain how memtype_rb_match() is used for shrinking
   case. (Thomas Gleixner)

---
Toshi Kani (2):
 1/2 x86/mm/pat: Add untrack_pfn_moved for mremap
 2/2 x86/mm/pat: Change free_memtype() to support shrinking case

---
 arch/x86/mm/pat.c             | 12 +++++++++-
 arch/x86/mm/pat_rbtree.c      | 52 +++++++++++++++++++++++++++++++++++--------
 include/asm-generic/pgtable.h | 10 ++++++++-
 mm/mremap.c                   |  4 ++++
 4 files changed, 67 insertions(+), 11 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
