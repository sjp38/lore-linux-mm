Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEFD3C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CF3B2084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CF3B2084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D6D86B0007; Wed, 15 May 2019 11:11:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EDC086B0008; Wed, 15 May 2019 11:11:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA6026B000A; Wed, 15 May 2019 11:11:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 713016B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:11:38 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id g15so456816ljk.8
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:11:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Yfs8d2jF/T6jQEdvza+WxJDpKG02YKvUPUgE54J0ka4=;
        b=Ba9E2vlnUA0hp4F37xSb4WgCg3GuH3/tkmPd9V3dKvI611Y4W95dkZg2WGb5UnhKk5
         tj+UluJ97woJnSzwoG/gqb89s3gnuGnsv91bhzcCskmOOP18bfuM/EgFVCs3tS/Nszii
         UvWWaDkHygaRV7MSCzVwK8kKF8+Lh1zOVpNVvSVaKUuHyhD3dtLjmQslBmmt+6TNJjet
         mqo6Evj5Jr/3SMwLh9WDutKWR9t1QnuNa+AmlDqsh1KhiSI7nat3UlORiq/I2Xhz2of0
         ASGBKq+tKHDDZW51BnG3NQD8r+wFnAP+AN/wMtDm1fC5DhR+BhPtwLM+P338xzhwokDQ
         W0Og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVtssmNt9b8GTeA4zTVJHvm0E4bDo6/OnfuNumYLWvqPWDd38j5
	I/7GFlgvKpOytVBhNaNA0UqNBAhAqwX9AGTebe1sSFpcJ++pC67437pezOjyeCxFjGsQNon5ceP
	7T8s75sDElRtv2w+adWcNnF6yMwqqeqaYktQ3fQcsC/9xo+OccHlosTSj9Y3PxwJtcA==
X-Received: by 2002:ac2:494b:: with SMTP id o11mr20746442lfi.9.1557933097902;
        Wed, 15 May 2019 08:11:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwdua4s3zHu61XDOPN5UoP7fllaNk2EFmVwPRreuBo3UOL5XqQLhvJqkKwEt7pbE1hYC95L
X-Received: by 2002:ac2:494b:: with SMTP id o11mr20746388lfi.9.1557933096596;
        Wed, 15 May 2019 08:11:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933096; cv=none;
        d=google.com; s=arc-20160816;
        b=N/WVBgSGfeDSblXyFv4JGmpwqd8xLozQUaKijqlHf0+kB/x7jDXrJKsOLVl5kh/9PZ
         dPzn0AhazJAHlxzCorl1N70uDluXjuoAIailAjnGjpJbj34jHj+4h25TAj//3PpZhZLP
         XfDi0oRF0dDmPRo/UL+AZUFpEmSiwbWU8h4/B8AvflQHlKC94NOS21as0tgdiOh7WNFq
         jyJwDNB57EZuW5qePlstIbpuHeUm2rScJCWrTG2kFrm5cPqc/XfnO8p/8aStHT0UX/xG
         Z+xwlq5Jjt9XtFcLcC36Jiv7Mqqlwrax1A8BGGg32J7mni78EMdKybf/evunFlGpIRw4
         8AKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=Yfs8d2jF/T6jQEdvza+WxJDpKG02YKvUPUgE54J0ka4=;
        b=LijyBCiCA1CZW5SHf0CM06SBcwm5B9TuzK9kfU0dk9NSLTX/VZwvOpLESJ4o6fE2AW
         vcyVMScjg66h1ZbYxhX2lzUfSAGRaDg1LWTPOeZZN82rMTav2efC7pwVze4krgnKriGl
         ByfGdMhlENm6s8X6+gOtZZxeriNP5rdbc41WZF6YUGbaWlIijd/nKlprY41m+OcBfx8E
         GNre6OL+4XTSpG/NxrvNPIVSOK0uK/HlYgp7lgzzvRLNWConyCc7fbwAr16712oMff+i
         38cTt5kud6BJSl8ITV4JY1o/+K1f3CY3HTXNNBovxTTBxkUbC2wYaV3LD7A09vT71Cg0
         T72w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id r10si1794042lfi.8.2019.05.15.08.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:11:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQvZ2-0001XF-8q; Wed, 15 May 2019 18:11:28 +0300
Subject: [PATCH RFC 2/5] mm: Extend copy_vma()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
 ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
 vbabka@suse.cz, cl@linux.com, riel@surriel.com, keescook@chromium.org,
 hannes@cmpxchg.org, npiggin@gmail.com, mathieu.desnoyers@efficios.com,
 shakeelb@google.com, guro@fb.com, aarcange@redhat.com, hughd@google.com,
 jglisse@redhat.com, mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Wed, 15 May 2019 18:11:27 +0300
Message-ID: <155793308777.13922.13297821989540731131.stgit@localhost.localdomain>
In-Reply-To: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This prepares the function to copy a vma between
two processes. Two new arguments are introduced.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/mm.h |    4 ++--
 mm/mmap.c          |   33 ++++++++++++++++++++++++---------
 mm/mremap.c        |    4 ++--
 3 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..afe07e4a76f8 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2329,8 +2329,8 @@ extern void __vma_link_rb(struct mm_struct *, struct vm_area_struct *,
 	struct rb_node **, struct rb_node *);
 extern void unlink_file_vma(struct vm_area_struct *);
 extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
-	unsigned long addr, unsigned long len, pgoff_t pgoff,
-	bool *need_rmap_locks);
+	struct mm_struct *, unsigned long addr, unsigned long len,
+	pgoff_t pgoff, bool *need_rmap_locks, bool clear_flags_ctx);
 extern void exit_mmap(struct mm_struct *);
 
 static inline int check_data_rlimit(unsigned long rlim,
diff --git a/mm/mmap.c b/mm/mmap.c
index 9cf52bdb22a8..46266f6825ae 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3194,19 +3194,21 @@ int insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vma)
 }
 
 /*
- * Copy the vma structure to a new location in the same mm,
- * prior to moving page table entries, to effect an mremap move.
+ * Copy the vma structure to new location in the same vma
+ * prior to moving page table entries, to effect an mremap move;
  */
 struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
-	unsigned long addr, unsigned long len, pgoff_t pgoff,
-	bool *need_rmap_locks)
+				struct mm_struct *mm, unsigned long addr,
+				unsigned long len, pgoff_t pgoff,
+				bool *need_rmap_locks, bool clear_flags_ctx)
 {
 	struct vm_area_struct *vma = *vmap;
 	unsigned long vma_start = vma->vm_start;
-	struct mm_struct *mm = vma->vm_mm;
+	struct vm_userfaultfd_ctx uctx;
 	struct vm_area_struct *new_vma, *prev;
 	struct rb_node **rb_link, *rb_parent;
 	bool faulted_in_anon_vma = true;
+	unsigned long flags;
 
 	/*
 	 * If anonymous vma has not yet been faulted, update new pgoff
@@ -3219,15 +3221,25 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
 		return NULL;	/* should never get here */
-	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
-			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			    vma->vm_userfaultfd_ctx);
+
+	uctx = vma->vm_userfaultfd_ctx;
+	flags = vma->vm_flags;
+	if (clear_flags_ctx) {
+		uctx = NULL_VM_UFFD_CTX;
+		flags &= ~(VM_UFFD_MISSING | VM_UFFD_WP | VM_MERGEABLE |
+			   VM_LOCKED | VM_LOCKONFAULT | VM_WIPEONFORK |
+			   VM_DONTCOPY);
+	}
+
+	new_vma = vma_merge(mm, prev, addr, addr + len, flags, vma->anon_vma,
+			    vma->vm_file, pgoff, vma_policy(vma), uctx);
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
 		 */
 		if (unlikely(vma_start >= new_vma->vm_start &&
-			     vma_start < new_vma->vm_end)) {
+			     vma_start < new_vma->vm_end) &&
+			     vma->vm_mm == mm) {
 			/*
 			 * The only way we can get a vma_merge with
 			 * self during an mremap is if the vma hasn't
@@ -3248,6 +3260,9 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		new_vma = vm_area_dup(vma);
 		if (!new_vma)
 			goto out;
+		new_vma->vm_mm = mm;
+		new_vma->vm_flags = flags;
+		new_vma->vm_userfaultfd_ctx = uctx;
 		new_vma->vm_start = addr;
 		new_vma->vm_end = addr + len;
 		new_vma->vm_pgoff = pgoff;
diff --git a/mm/mremap.c b/mm/mremap.c
index 37b5b2ad91be..9a96cfc28675 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -352,8 +352,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		return err;
 
 	new_pgoff = vma->vm_pgoff + ((old_addr - vma->vm_start) >> PAGE_SHIFT);
-	new_vma = copy_vma(&vma, new_addr, new_len, new_pgoff,
-			   &need_rmap_locks);
+	new_vma = copy_vma(&vma, mm, new_addr, new_len, new_pgoff,
+			   &need_rmap_locks, false);
 	if (!new_vma)
 		return -ENOMEM;
 

