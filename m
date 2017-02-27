Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 76B7A6B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:51:34 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 6so3149141pfd.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:51:34 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id t10si15521615pgn.358.2017.02.27.08.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 08:51:33 -0800 (PST)
Subject: [PATCH] fs, dax: fix build warning for !CONFIG_FS_DAX_PMD case for
 dax_iomap_pmd_fault
From: Dave Jiang <dave.jiang@intel.com>
Date: Mon, 27 Feb 2017 09:51:32 -0700
Message-ID: <148821429251.38263.11870148981890888722.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sfr@canb.auug.org.au, dave.hansen@linux.intel.com, mawilcox@microsoft.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, vbabka@suse.cz, jack@suse.com, dan.j.williams@intel.com, torvalds@linux-foundation.org, ross.zwisler@linux.intel.com, kirill.shutemov@linux.intel.com

Stephen reported:
With just Linus' tree, today's linux-next build (powerpc ppc64_defconfig)
produced this warning:

fs/dax.c: In function 'dax_iomap_fault':
fs/dax.c:1462:35: warning: passing argument 2 of 'dax_iomap_pmd_fault' discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
   return dax_iomap_pmd_fault(vmf, ops);
                                   ^
fs/dax.c:1439:12: note: expected 'struct iomap_ops *' but argument is of type 'const struct iomap_ops *'
 static int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops)
            ^

Introduced by

  commit a2d581675d48 ("mm,fs,dax: change ->pmd_fault to ->huge_fault")

which missed fixing up the !CONFIG_FS_DAX_PMD case.


Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---
 fs/dax.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 5ae8b71..7436c98 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1436,7 +1436,8 @@ static int dax_iomap_pmd_fault(struct vm_fault *vmf,
 	return result;
 }
 #else
-static int dax_iomap_pmd_fault(struct vm_fault *vmf, struct iomap_ops *ops)
+static int dax_iomap_pmd_fault(struct vm_fault *vmf,
+			       const struct iomap_ops *ops)
 {
 	return VM_FAULT_FALLBACK;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
