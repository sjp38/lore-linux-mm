Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C954C04AAE
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5A10205ED
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:44:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5A10205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9A976B0007; Wed,  8 May 2019 10:44:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A798F6B0008; Wed,  8 May 2019 10:44:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939826B000A; Wed,  8 May 2019 10:44:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 594B26B0007
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:36 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x5so11673308pll.2
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NOzhRrERcrdj97QkCJT7reDTgPAcG4ER6LSBgl/1sEU=;
        b=V/NDqEFz3aATqzW2ysSDi6Y+PwnDQkW2kBLh3yVeWlqP5aU4ol5rgc7RoPwYmwsd+l
         BN667vSpuZJeENEme15qo5lqsoN+FTloqKjg46fmBByxDWZtq0SrGN0x1pztKWVtJ0uc
         37zSfVcYVuBgqdPTECr8iwhR/JJgq+qGFUgoB80fKbkmrQXA4g3cbIQpqOBc1DhtqBjG
         ESh0qWhTMQ6T49QyKPyhV8cQRUq5RHvsyBlSdZHZfpghqwDE68BnkFueIrSpKHE0tWYo
         6d48CHpi5O5ybQC5Q1DImJtpOQxwGo8nDGciWgtCeBjzfZmEnPjQ7DeV/NnBqz0ikw1M
         u4/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXoTLK5ohW1frlZkfw7DGwkFbUiCwnNdvXvOJiVZrAkJ7BnzVXJ
	kwEBghMvtPzyDP7L/Nm+oUTcBR5MRPTiEtWQzQURcqvF2WC7Qasz9rGh7mx2kW+DhlQcYdC0gcY
	hkASNKmivZqOCOSKOu8e5S+xcTAHODTvzqyhEUXAIuL3+Uhj8dt3Nqho38ujB7RBoxg==
X-Received: by 2002:a63:6988:: with SMTP id e130mr47892103pgc.150.1557326676004;
        Wed, 08 May 2019 07:44:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwI+Th2v7kyGoKfwaE0vKfJnIDoWepjLYR8eNcJ6HXe5BUStdlU0rOLuTzrN+TJSAFzcCsP
X-Received: by 2002:a63:6988:: with SMTP id e130mr47891984pgc.150.1557326674881;
        Wed, 08 May 2019 07:44:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326674; cv=none;
        d=google.com; s=arc-20160816;
        b=xU1WVV4yTTJhMH2l9Kjo1HWxtFI59hMHQ38qYYwQzQJlWTlqP6zoyB6PbuVL1XjatH
         pfpcz8oqnrUabDvJvpEFFdBDtyGMaFPsty7vBMsIJflCWtoc8vGtp3mzOYQMhXztH1x6
         OIRDFW9zNIKxZswMs9C3PTPryg20ninN/3iDAicSPe0CwrKbQxpPsHTbz1YTrKDa4PaP
         faHpZyiYLulB2aqWt1DXElHckRyyT2P9uG59CSBr/cSVycFmKyE6VcfZgt6AIpEabJ48
         BKv+BfowqPpKVPVMR2McdWKVtwqhG5GBu3u8ctKrbJzt3dSHAt6btEF/WpnMwA/h+0+u
         xr5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NOzhRrERcrdj97QkCJT7reDTgPAcG4ER6LSBgl/1sEU=;
        b=gT4u6vgHKc6UVJgt7/q6Pay06RKHHbPnhaQpbgyHXgX5OkkCswZ6kpP3CJ0wiJ679u
         oKNQs3vSnc9bN00yJb+F4EFFVavRsoT2WBeO6uJw/rcdoj39GGWGRF8LHfHqUDP7QPYD
         T9AzAl/SuvkL9qlycUxT2f8MOvLAfo/aVuptnYMS0qRGXNPyTg+FaulqN5Ou1IqbYzfx
         viBmRyyfNDu4uVxdk+0gVaoR1Jp/cg/PNI2t0m548AUM/oSbCOrLVI6CraWodCtonJ/8
         41qxRcNgN3GC5CRmsnqjEB07SQEe2jxkf5VV126KoO4wQI512E0Td3QDhxJ28sLtNkPs
         eqrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n6si22562220pgq.486.2019.05.08.07.44.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga103.jf.intel.com with ESMTP; 08 May 2019 07:44:33 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga008.fm.intel.com with ESMTP; 08 May 2019 07:44:29 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 88ED5146; Wed,  8 May 2019 17:44:28 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 01/62] mm: Do no merge VMAs with different encryption KeyIDs
Date: Wed,  8 May 2019 17:43:21 +0300
Message-Id: <20190508144422.13171-2-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

VMAs with different KeyID do not mix together. Only VMAs with the same
KeyID are compatible.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/userfaultfd.c   |  7 ++++---
 include/linux/mm.h |  9 ++++++++-
 mm/madvise.c       |  2 +-
 mm/mempolicy.c     |  3 ++-
 mm/mlock.c         |  2 +-
 mm/mmap.c          | 31 +++++++++++++++++++------------
 mm/mprotect.c      |  2 +-
 7 files changed, 36 insertions(+), 20 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f5de1e726356..6032aecda4ed 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -901,7 +901,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 				 new_flags, vma->anon_vma,
 				 vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 NULL_VM_UFFD_CTX);
+				 NULL_VM_UFFD_CTX, vma_keyid(vma));
 		if (prev)
 			vma = prev;
 		else
@@ -1451,7 +1451,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		prev = vma_merge(mm, prev, start, vma_end, new_flags,
 				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 ((struct vm_userfaultfd_ctx){ ctx }));
+				 ((struct vm_userfaultfd_ctx){ ctx }),
+				 vma_keyid(vma));
 		if (prev) {
 			vma = prev;
 			goto next;
@@ -1613,7 +1614,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		prev = vma_merge(mm, prev, start, vma_end, new_flags,
 				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 NULL_VM_UFFD_CTX);
+				 NULL_VM_UFFD_CTX, vma_keyid(vma));
 		if (prev) {
 			vma = prev;
 			goto next;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..13c40c43ce00 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1599,6 +1599,13 @@ static inline bool vma_is_anonymous(struct vm_area_struct *vma)
 	return !vma->vm_ops;
 }
 
+#ifndef vma_keyid
+static inline int vma_keyid(struct vm_area_struct *vma)
+{
+	return 0;
+}
+#endif
+
 #ifdef CONFIG_SHMEM
 /*
  * The vma_is_shmem is not inline because it is used only by slow
@@ -2275,7 +2282,7 @@ static inline int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
-	struct mempolicy *, struct vm_userfaultfd_ctx);
+	struct mempolicy *, struct vm_userfaultfd_ctx, int keyid);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int __split_vma(struct mm_struct *, struct vm_area_struct *,
 	unsigned long addr, int new_below);
diff --git a/mm/madvise.c b/mm/madvise.c
index 21a7881a2db4..e9925a512b15 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -138,7 +138,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, new_flags, vma->anon_vma,
 			  vma->vm_file, pgoff, vma_policy(vma),
-			  vma->vm_userfaultfd_ctx);
+			  vma->vm_userfaultfd_ctx, vma_keyid(vma));
 	if (*prev) {
 		vma = *prev;
 		goto success;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 2219e747df49..14b18449c623 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -731,7 +731,8 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 			((vmstart - vma->vm_start) >> PAGE_SHIFT);
 		prev = vma_merge(mm, prev, vmstart, vmend, vma->vm_flags,
 				 vma->anon_vma, vma->vm_file, pgoff,
-				 new_pol, vma->vm_userfaultfd_ctx);
+				 new_pol, vma->vm_userfaultfd_ctx,
+				 vma_keyid(vma));
 		if (prev) {
 			vma = prev;
 			next = vma->vm_next;
diff --git a/mm/mlock.c b/mm/mlock.c
index 080f3b36415b..d44cb0c9e9ca 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -535,7 +535,7 @@ static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*prev = vma_merge(mm, *prev, start, end, newflags, vma->anon_vma,
 			  vma->vm_file, pgoff, vma_policy(vma),
-			  vma->vm_userfaultfd_ctx);
+			  vma->vm_userfaultfd_ctx, vma_keyid(vma));
 	if (*prev) {
 		vma = *prev;
 		goto success;
diff --git a/mm/mmap.c b/mm/mmap.c
index bd7b9f293b39..de0bdf4d8f90 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1007,7 +1007,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
 				struct file *file, unsigned long vm_flags,
-				struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
+				struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
+				int keyid)
 {
 	/*
 	 * VM_SOFTDIRTY should not prevent from VMA merging, if we
@@ -1021,6 +1022,8 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 		return 0;
 	if (vma->vm_file != file)
 		return 0;
+	if (vma_keyid(vma) != keyid)
+		return 0;
 	if (vma->vm_ops && vma->vm_ops->close)
 		return 0;
 	if (!is_mergeable_vm_userfaultfd_ctx(vma, vm_userfaultfd_ctx))
@@ -1057,9 +1060,10 @@ static int
 can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
 		     struct anon_vma *anon_vma, struct file *file,
 		     pgoff_t vm_pgoff,
-		     struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
+		     struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
+		     int keyid)
 {
-	if (is_mergeable_vma(vma, file, vm_flags, vm_userfaultfd_ctx) &&
+	if (is_mergeable_vma(vma, file, vm_flags, vm_userfaultfd_ctx, keyid) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		if (vma->vm_pgoff == vm_pgoff)
 			return 1;
@@ -1078,9 +1082,10 @@ static int
 can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
 		    struct anon_vma *anon_vma, struct file *file,
 		    pgoff_t vm_pgoff,
-		    struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
+		    struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
+		    int keyid)
 {
-	if (is_mergeable_vma(vma, file, vm_flags, vm_userfaultfd_ctx) &&
+	if (is_mergeable_vma(vma, file, vm_flags, vm_userfaultfd_ctx, keyid) &&
 	    is_mergeable_anon_vma(anon_vma, vma->anon_vma, vma)) {
 		pgoff_t vm_pglen;
 		vm_pglen = vma_pages(vma);
@@ -1135,7 +1140,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			unsigned long end, unsigned long vm_flags,
 			struct anon_vma *anon_vma, struct file *file,
 			pgoff_t pgoff, struct mempolicy *policy,
-			struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
+			struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
+			int keyid)
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
@@ -1168,7 +1174,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			mpol_equal(vma_policy(prev), policy) &&
 			can_vma_merge_after(prev, vm_flags,
 					    anon_vma, file, pgoff,
-					    vm_userfaultfd_ctx)) {
+					    vm_userfaultfd_ctx, keyid)) {
 		/*
 		 * OK, it can.  Can we now merge in the successor as well?
 		 */
@@ -1177,7 +1183,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 				can_vma_merge_before(next, vm_flags,
 						     anon_vma, file,
 						     pgoff+pglen,
-						     vm_userfaultfd_ctx) &&
+						     vm_userfaultfd_ctx,
+						     keyid) &&
 				is_mergeable_anon_vma(prev->anon_vma,
 						      next->anon_vma, NULL)) {
 							/* cases 1, 6 */
@@ -1200,7 +1207,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			mpol_equal(policy, vma_policy(next)) &&
 			can_vma_merge_before(next, vm_flags,
 					     anon_vma, file, pgoff+pglen,
-					     vm_userfaultfd_ctx)) {
+					     vm_userfaultfd_ctx, keyid)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
 			err = __vma_adjust(prev, prev->vm_start,
 					 addr, prev->vm_pgoff, NULL, next);
@@ -1745,7 +1752,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	 * Can we just expand an old mapping?
 	 */
 	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
-			NULL, file, pgoff, NULL, NULL_VM_UFFD_CTX);
+			NULL, file, pgoff, NULL, NULL_VM_UFFD_CTX, 0);
 	if (vma)
 		goto out;
 
@@ -3023,7 +3030,7 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
 
 	/* Can we just expand an old private anonymous mapping? */
 	vma = vma_merge(mm, prev, addr, addr + len, flags,
-			NULL, NULL, pgoff, NULL, NULL_VM_UFFD_CTX);
+			NULL, NULL, pgoff, NULL, NULL_VM_UFFD_CTX, 0);
 	if (vma)
 		goto out;
 
@@ -3221,7 +3228,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		return NULL;	/* should never get here */
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
 			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			    vma->vm_userfaultfd_ctx);
+			    vma->vm_userfaultfd_ctx, vma_keyid(vma));
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 028c724dcb1a..e768cd656a48 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -399,7 +399,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*pprev = vma_merge(mm, *pprev, start, end, newflags,
 			   vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			   vma->vm_userfaultfd_ctx);
+			   vma->vm_userfaultfd_ctx, vma_keyid(vma));
 	if (*pprev) {
 		vma = *pprev;
 		VM_WARN_ON((vma->vm_flags ^ newflags) & ~VM_SOFTDIRTY);
-- 
2.20.1

