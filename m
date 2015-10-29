Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1EB82F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 16:12:34 -0400 (EDT)
Received: by pasz6 with SMTP id z6so49971238pas.2
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 13:12:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id yw10si4839560pac.86.2015.10.29.13.12.30
        for <linux-mm@kvack.org>;
        Thu, 29 Oct 2015 13:12:30 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [RFC 02/11] mm: add pmd_mkclean()
Date: Thu, 29 Oct 2015 14:12:06 -0600
Message-Id: <1446149535-16200-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1446149535-16200-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "J. Bruce Fields" <bfields@fieldses.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.com>, Jeff Layton <jlayton@poochiereds.net>, Matthew Wilcox <willy@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, x86@kernel.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>

Currently PMD pages can be dirtied via pmd_mkdirty(), but cannot be
cleaned.  For DAX mmap dirty page tracking we need to be able to clean PMD
pages when we flush them to media so that we get a new write fault the next
time the are written to.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 arch/x86/include/asm/pgtable.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 867da5b..c548e4c 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -277,6 +277,11 @@ static inline pmd_t pmd_mkdirty(pmd_t pmd)
 	return pmd_set_flags(pmd, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
 }
 
+static inline pmd_t pmd_mkclean(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_DIRTY | _PAGE_SOFT_DIRTY);
+}
+
 static inline pmd_t pmd_mkhuge(pmd_t pmd)
 {
 	return pmd_set_flags(pmd, _PAGE_PSE);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
