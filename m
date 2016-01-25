Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE966B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:25:23 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id uo6so85454814pac.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:25:23 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id z62si34858832pfi.21.2016.01.25.09.25.22
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 09:25:22 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 1/3] x86: Honour passed pgprot in track_pfn_insert() and track_pfn_remap()
Date: Mon, 25 Jan 2016 12:25:15 -0500
Message-Id: <1453742717-10326-2-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1453742717-10326-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Matthew Wilcox <willy@linux.intel.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Matthew Wilcox <willy@linux.intel.com>

track_pfn_insert() overwrites the pgprot that is passed in with a value
based on the VMA's page_prot.  This is a problem for people trying to
do clever things with the new vm_insert_pfn_prot() as it will simply
overwrite the passed protection flags.  If we use the current value of
the pgprot as the base, then it will behave as people are expecting.

Also fix track_pfn_remap() in the same way.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 arch/x86/mm/pat.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index f4ae536..04e2e71 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -943,7 +943,7 @@ int track_pfn_remap(struct vm_area_struct *vma, pgprot_t *prot,
 			return -EINVAL;
 	}
 
-	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
+	*prot = __pgprot((pgprot_val(*prot) & (~_PAGE_CACHE_MASK)) |
 			 cachemode2protval(pcm));
 
 	return 0;
@@ -959,7 +959,7 @@ int track_pfn_insert(struct vm_area_struct *vma, pgprot_t *prot,
 
 	/* Set prot based on lookup */
 	pcm = lookup_memtype(pfn_t_to_phys(pfn));
-	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
+	*prot = __pgprot((pgprot_val(*prot) & (~_PAGE_CACHE_MASK)) |
 			 cachemode2protval(pcm));
 
 	return 0;
-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
