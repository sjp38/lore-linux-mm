Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8A46C32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DDA9214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="PQMMzYAt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DDA9214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D8E18E000C; Wed, 31 Jul 2019 11:08:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2380F8E000D; Wed, 31 Jul 2019 11:08:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08F688E000C; Wed, 31 Jul 2019 11:08:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A425B8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:22 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id n25so16094583wmc.7
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QvM6TLsHLaIUsQxiIrLtgZTAl4nwA/abKY84Ix9c1AI=;
        b=Bfj+gy1MFN7Bh7dJv/txdplTsGiEBnyWHkpSWoavHvktTe6qe9Ll8TMzE3+nq+RFjc
         1d7H2ccNgzgrcMcmLvGf2djTr7ItAHau9PRJ7j/4GeBQWHxvHrU89119ACewu9h2e9Z3
         UKL/xUjNj9vMZcDqDC680t/zc6Crev53DTSOYwGYBaEhL+DSS6Oh62xzT7O5gV9Y+die
         frnz44XzTbLa/PdI1AR5nIiNs49L67MyalES59Iur+PeqDLn+qYvtkLbyIwjIgbFs/uk
         rGch6rpayGFpz0DYcsUCOc6LTnMC5xZntbgWISYzKf2WSFooVdgYabjmEtcix7hPT00n
         Sshg==
X-Gm-Message-State: APjAAAUtmnCudp1D9x2X/eLtTYom+f5BK9BVE7mkvTrP6stJCvcWB9zv
	AkOOCihs7uqonPh78KXffjEz7AClO5//J9C1hmm4s1uQBt2m7fkUwJMnpiZh7oKS/AQPx8f3+8G
	0BYQyn7IuBbYmWZXfrcRgcxlrBjarAmpKMzIEiWt9zrwBPbPZopx0n/eivujy2QI=
X-Received: by 2002:a1c:b189:: with SMTP id a131mr115302225wmf.7.1564585702208;
        Wed, 31 Jul 2019 08:08:22 -0700 (PDT)
X-Received: by 2002:a1c:b189:: with SMTP id a131mr115302059wmf.7.1564585699681;
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585699; cv=none;
        d=google.com; s=arc-20160816;
        b=YUshKbin8P9TslZ5Tqiwc9GqQ3GQ2dw8FaUvK2MEAVhG7ziIPIwn5s5RMFBHWPX2VI
         mMOcEV66n9UX8U4w8viWKnTdJW08AWROznGDavvFGWWNkOz0YgcBuyrxnsYCAAgtx/g0
         y5mxw8TYh97/Q8bnp15YYUAIHG5LBFcmqzuNnK/dCa+i0TNVGRJzqpdg9X0DbIe7HpBe
         uB/2VHfcTT+UzPD+VfNQSuh+tnLrOgwhzR6VyGVWZAaXJW4g8iAbmLfdV6O3KzZKmLdE
         XuaAdNc+ib91aecloSP4l83SoR/IkYcs2WqweJRXq6VhQ0ZOlU+YSlkYtSIfRaXK6Er5
         dfGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QvM6TLsHLaIUsQxiIrLtgZTAl4nwA/abKY84Ix9c1AI=;
        b=ezOIuS3tJOoGMjVL3HlHstnT4ppu5tJCa07mq4FnzVLvMLuXUAybaeRivrEbkmeJRB
         WBXZbi1y5+jTWS/ryrgpG76w55H0piBn+LGDiEjPHEiIrqH0SRlReQautGC1L7lsi+3P
         GmdFo3h9ytOma5vondVObhwCn5QAiuuxbqVIMj5UxXncykE4E6B7gauN4Ef/bTPEhrU4
         92UiNQ+UT3DhzC+sjWlft4m6J1UVERWSzvmPjnBc/NMV0jH5+uGJNIvMrnmMOutHhhkQ
         8y7S2PwqjDz1NjW1v6u7DvvePY1yrzaAy80Y2GH5AmI7Ss/HpgMk3HMjznBXT5kbtOnp
         mjKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PQMMzYAt;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6sor52114476edc.24.2019.07.31.08.08.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=PQMMzYAt;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QvM6TLsHLaIUsQxiIrLtgZTAl4nwA/abKY84Ix9c1AI=;
        b=PQMMzYAtdHNIXrG1QMzmJkDEaLAkNcffdKITKNKyMHWPazgNFp8a/KgMG6jpyOPy6L
         z1/tpsyUip94xQ6akPtE8MoQmmIrADbPePw9ZUJIhjeGaokm0qqY+eEe5uAHTxdaDFOl
         uTxZlQ2SlbbEr+TXSFQKh3v/lXXZgYGil15BJYjAEoy1ygXMXRc7taLkzxUFswX6evY7
         kDJdbo1gZxmJV0MtpSm9FnWdgOp9x//J+1DDAJcBl4SLlPClFdePa4j2HyjR2ElgASHb
         gjubDLRAPzaX0drp9tMCjDRDUkP7/F4q4ORRnXyI3hNiWitoyht+3ai6WwR4M8j+AqBZ
         0UOA==
X-Google-Smtp-Source: APXvYqxfIQGkRhrMQl5o3NEbLiMVXnwZsc3hm4rHg9K6Idq9C1pqBjRFAwNsZKfTGo4tqfavOiaY7g==
X-Received: by 2002:a50:9107:: with SMTP id e7mr108538225eda.280.1564585699281;
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id f21sm16902175edj.36.2019.07.31.08.08.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id EA80E101316; Wed, 31 Jul 2019 18:08:15 +0300 (+03)
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
Subject: [PATCHv2 01/59] mm: Do no merge VMAs with different encryption KeyIDs
Date: Wed, 31 Jul 2019 18:07:15 +0300
Message-Id: <20190731150813.26289-2-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
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
index ccbdbd62f0d8..3b845a6a44d0 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -911,7 +911,7 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 				 new_flags, vma->anon_vma,
 				 vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 NULL_VM_UFFD_CTX);
+				 NULL_VM_UFFD_CTX, vma_keyid(vma));
 		if (prev)
 			vma = prev;
 		else
@@ -1461,7 +1461,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		prev = vma_merge(mm, prev, start, vma_end, new_flags,
 				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 ((struct vm_userfaultfd_ctx){ ctx }));
+				 ((struct vm_userfaultfd_ctx){ ctx }),
+				 vma_keyid(vma));
 		if (prev) {
 			vma = prev;
 			goto next;
@@ -1623,7 +1624,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
 		prev = vma_merge(mm, prev, start, vma_end, new_flags,
 				 vma->anon_vma, vma->vm_file, vma->vm_pgoff,
 				 vma_policy(vma),
-				 NULL_VM_UFFD_CTX);
+				 NULL_VM_UFFD_CTX, vma_keyid(vma));
 		if (prev) {
 			vma = prev;
 			goto next;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..5bfd3dd121c1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1637,6 +1637,13 @@ int clear_page_dirty_for_io(struct page *page);
 
 int get_cmdline(struct task_struct *task, char *buffer, int buflen);
 
+#ifndef vma_keyid
+static inline int vma_keyid(struct vm_area_struct *vma)
+{
+	return 0;
+}
+#endif
+
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len,
@@ -2301,7 +2308,7 @@ static inline int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
-	struct mempolicy *, struct vm_userfaultfd_ctx);
+	struct mempolicy *, struct vm_userfaultfd_ctx, int keyid);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int __split_vma(struct mm_struct *, struct vm_area_struct *,
 	unsigned long addr, int new_below);
diff --git a/mm/madvise.c b/mm/madvise.c
index 968df3aa069f..00216780a630 100644
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
index f48693f75b37..14ee933b1ff7 100644
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
index a90099da4fb4..3d0a31bf214c 100644
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
index 7e8c3e8ae75f..715438a1fb93 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1008,7 +1008,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
 				struct file *file, unsigned long vm_flags,
-				struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
+				struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
+				int keyid)
 {
 	/*
 	 * VM_SOFTDIRTY should not prevent from VMA merging, if we
@@ -1022,6 +1023,8 @@ static inline int is_mergeable_vma(struct vm_area_struct *vma,
 		return 0;
 	if (vma->vm_file != file)
 		return 0;
+	if (vma_keyid(vma) != keyid)
+		return 0;
 	if (vma->vm_ops && vma->vm_ops->close)
 		return 0;
 	if (!is_mergeable_vm_userfaultfd_ctx(vma, vm_userfaultfd_ctx))
@@ -1058,9 +1061,10 @@ static int
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
@@ -1079,9 +1083,10 @@ static int
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
@@ -1136,7 +1141,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			unsigned long end, unsigned long vm_flags,
 			struct anon_vma *anon_vma, struct file *file,
 			pgoff_t pgoff, struct mempolicy *policy,
-			struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
+			struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
+			int keyid)
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
@@ -1169,7 +1175,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			mpol_equal(vma_policy(prev), policy) &&
 			can_vma_merge_after(prev, vm_flags,
 					    anon_vma, file, pgoff,
-					    vm_userfaultfd_ctx)) {
+					    vm_userfaultfd_ctx, keyid)) {
 		/*
 		 * OK, it can.  Can we now merge in the successor as well?
 		 */
@@ -1178,7 +1184,8 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 				can_vma_merge_before(next, vm_flags,
 						     anon_vma, file,
 						     pgoff+pglen,
-						     vm_userfaultfd_ctx) &&
+						     vm_userfaultfd_ctx,
+						     keyid) &&
 				is_mergeable_anon_vma(prev->anon_vma,
 						      next->anon_vma, NULL)) {
 							/* cases 1, 6 */
@@ -1201,7 +1208,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			mpol_equal(policy, vma_policy(next)) &&
 			can_vma_merge_before(next, vm_flags,
 					     anon_vma, file, pgoff+pglen,
-					     vm_userfaultfd_ctx)) {
+					     vm_userfaultfd_ctx, keyid)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
 			err = __vma_adjust(prev, prev->vm_start,
 					 addr, prev->vm_pgoff, NULL, next);
@@ -1746,7 +1753,7 @@ unsigned long mmap_region(struct file *file, unsigned long addr,
 	 * Can we just expand an old mapping?
 	 */
 	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
-			NULL, file, pgoff, NULL, NULL_VM_UFFD_CTX);
+			NULL, file, pgoff, NULL, NULL_VM_UFFD_CTX, 0);
 	if (vma)
 		goto out;
 
@@ -3025,7 +3032,7 @@ static int do_brk_flags(unsigned long addr, unsigned long len, unsigned long fla
 
 	/* Can we just expand an old private anonymous mapping? */
 	vma = vma_merge(mm, prev, addr, addr + len, flags,
-			NULL, NULL, pgoff, NULL, NULL_VM_UFFD_CTX);
+			NULL, NULL, pgoff, NULL, NULL_VM_UFFD_CTX, 0);
 	if (vma)
 		goto out;
 
@@ -3223,7 +3230,7 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		return NULL;	/* should never get here */
 	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
 			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			    vma->vm_userfaultfd_ctx);
+			    vma->vm_userfaultfd_ctx, vma_keyid(vma));
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
diff --git a/mm/mprotect.c b/mm/mprotect.c
index bf38dfbbb4b4..82d7b194a918 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -400,7 +400,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	pgoff = vma->vm_pgoff + ((start - vma->vm_start) >> PAGE_SHIFT);
 	*pprev = vma_merge(mm, *pprev, start, end, newflags,
 			   vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			   vma->vm_userfaultfd_ctx);
+			   vma->vm_userfaultfd_ctx, vma_keyid(vma));
 	if (*pprev) {
 		vma = *pprev;
 		VM_WARN_ON((vma->vm_flags ^ newflags) & ~VM_SOFTDIRTY);
-- 
2.21.0

