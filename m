Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6FFCC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:40:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 592B320651
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:40:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WdVKecpy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 592B320651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39CA16B000D; Wed, 17 Apr 2019 15:40:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D0616B000E; Wed, 17 Apr 2019 15:40:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 126C36B0010; Wed, 17 Apr 2019 15:40:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDE1B6B000D
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:40:09 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s26so16840576pfm.18
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:40:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z6vdUIHF/782qrNIQKa8Llo9bmW1C1O8TsdSUUoVzig=;
        b=csOeR4YOVhGrJeWi9Fwzi1kL9bC81n3m9HkDD6EuQxAI8itmDW8JTQSeZAfJYeiBdF
         rc9IpBGqBsmTZ2BcRsyApGFpXRCzdo5wg4Pizcoh1WY0UZ7XIJKI/4Y3WUjdZbjDZfER
         ou6XfmXgNh4U9nYghc70UCCFWy5wOVWEOuPxGrqR/0yj9FUYDoSWEwDGCiEwoN4hIXNM
         I9B5HnFCnVyyitzsMGotCgimSeTO1UQikXNHRpsMyIGs2vFOD7Os1drOnHf4W0cs5/FA
         LetzBAXC+kztBD4akffTR3EpWU5w+XDguej2s7PxNeQTchw0ta3uA/+jTPUX82jHq0hv
         Ni0w==
X-Gm-Message-State: APjAAAXClaq2U4Ubz86viMRYpDJ5Re/qKcVbMb4LPcCvtoYNEoDShudW
	izns+e5i6ZGhMo+21rNUKMYw30lpyQHPVghaDe2k+Je5MF+WNANS4vqL5QK+JYtKPqeG6Pjia/w
	MaOu3NU27Pxf9Ueuk9MOYzJgFj/01cMqPTQ1HDZHDrDtzMQkbYxmC108XMXP2KYidZQ==
X-Received: by 2002:a65:424a:: with SMTP id d10mr6848838pgq.335.1555530009443;
        Wed, 17 Apr 2019 12:40:09 -0700 (PDT)
X-Received: by 2002:a65:424a:: with SMTP id d10mr6848737pgq.335.1555530007940;
        Wed, 17 Apr 2019 12:40:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555530007; cv=none;
        d=google.com; s=arc-20160816;
        b=dhQ88C0Fn0zcvA2KhAe/iC0di0GMajM/FPjV1YquTdWNTV5SxchoPwnfA5Z+dUOzN2
         DBoGbsWrFTT5Q+szUfB10FC1G7Vm473qcJ7n1qkhhcj2tKIIjELY3joN+Il031oDBskk
         o2pwbQgNra1ia3pQ98MQVA3XORBYS0uUw/K9bICvGTpp4gjuij3ajNauRsnz0M64Jm9C
         MW7C2NZ5pSn63jwO0HRAioM332YuwSjWJV0efD+uTEmPPKyTo6dwlftgCAyLj0MAoajv
         MoV1O1tMX2hKxJ3Q1o45UavyyBmkDBJijhtjzVcavrCFz/cVlKS4fuDzzCbJNGun7nvf
         +1dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Z6vdUIHF/782qrNIQKa8Llo9bmW1C1O8TsdSUUoVzig=;
        b=uvXtX2hUDQ9yzJsMX6HP18rwYb+NfbLbZ+S5Zic2XeRQAF9P6sIqO4s883YdN8n3/m
         ur3LqDRNuRuJqyd/l8MFvPyxNcWv0WnG2TgFtErYSkQp0xStuW6KbWrKEONzxtm7yb5i
         pY4oWxDTyySvJqCiof0z+T58Uh2h3IMkhxHeO51P9EwrAiruXqH6Y0G23sdjn1nEFHi8
         0JcYeAFueShl2DK6ycLr5VIUvB+tkBkSAgB5ntXcwJgR97+Z5y2a1A3enuTMbCtb7Vrd
         k6VqXVqHIvQ81RYT4rUnYrESn5xK7N5HuhL6gq+Txk0SyAF9wzQA8cxRUC/CCMf+akDM
         GKig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WdVKecpy;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c18sor45635570pgp.80.2019.04.17.12.40.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 12:40:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WdVKecpy;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Z6vdUIHF/782qrNIQKa8Llo9bmW1C1O8TsdSUUoVzig=;
        b=WdVKecpyO7Ie1YhwT+DDiMfEArYhv+c23FZBR1ZZd70ocStP2bilaAhEzgH5PB9/BZ
         BlxxWzlzgpwuCydbw3UXI+z94mGqUByiK9tAfPc02hsJBZcPTcK7cPG4+X0AhFn6+e2r
         DA5cg6CM6DRt327kyOmtCOdnfveVipyJLp7vB3JrA7xw/gUM9taWoakmImaC4qGk2Qjo
         0MiZBuD093wMngItT6yJB2nGGPBLlyZOCDKvJ/69x3rkl1oMbgZiLXh8qw6wZ/XsumCH
         poCkHC9w4e8MhbhFLcaqIgtxKAV3py9WvcY06aiZR3taH5f6P2S5y25tlfXRiPx7JQZm
         jbqA==
X-Google-Smtp-Source: APXvYqwP8MOTe4Mt0elbbcBNPfAEaBQpvL1f/NDOkCWHcYAqgtbAdomBe640ASx6Nz7a5r3YK6Mv2A==
X-Received: by 2002:a63:4847:: with SMTP id x7mr85274293pgk.233.1555530007663;
        Wed, 17 Apr 2019 12:40:07 -0700 (PDT)
Received: from tower.thefacebook.com ([2620:10d:c090:200::3:856])
        by smtp.gmail.com with ESMTPSA id v9sm8625949pgf.73.2019.04.17.12.40.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 12:40:06 -0700 (PDT)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kernel-team@fb.com,
	Matthew Wilcox <willy@infradead.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH v4 1/2] mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
Date: Wed, 17 Apr 2019 12:40:01 -0700
Message-Id: <20190417194002.12369-2-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190417194002.12369-1-guro@fb.com>
References: <20190417194002.12369-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

__vunmap() calls find_vm_area() twice without an obvious reason:
first directly to get the area pointer, second indirectly by calling
remove_vm_area(), which is again searching for the area.

To remove this redundancy, let's split remove_vm_area() into
__remove_vm_area(struct vmap_area *), which performs the actual area
removal, and remove_vm_area(const void *addr) wrapper, which can
be used everywhere, where it has been used before.

On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
of 4-pages vmalloc blocks.

Perf report before:
  22.64%  cat      [kernel.vmlinux]  [k] free_pcppages_bulk
  10.30%  cat      [kernel.vmlinux]  [k] __vunmap
   9.80%  cat      [kernel.vmlinux]  [k] find_vmap_area
   8.11%  cat      [kernel.vmlinux]  [k] vunmap_page_range
   4.20%  cat      [kernel.vmlinux]  [k] __slab_free
   3.56%  cat      [kernel.vmlinux]  [k] __list_del_entry_valid
   3.46%  cat      [kernel.vmlinux]  [k] smp_call_function_many
   3.33%  cat      [kernel.vmlinux]  [k] kfree
   3.32%  cat      [kernel.vmlinux]  [k] free_unref_page

Perf report after:
  23.01%  cat      [kernel.kallsyms]  [k] free_pcppages_bulk
   9.46%  cat      [kernel.kallsyms]  [k] __vunmap
   9.15%  cat      [kernel.kallsyms]  [k] vunmap_page_range
   6.17%  cat      [kernel.kallsyms]  [k] __slab_free
   5.61%  cat      [kernel.kallsyms]  [k] kfree
   4.86%  cat      [kernel.kallsyms]  [k] bad_range
   4.67%  cat      [kernel.kallsyms]  [k] free_unref_page_commit
   4.24%  cat      [kernel.kallsyms]  [k] __list_del_entry_valid
   3.68%  cat      [kernel.kallsyms]  [k] free_unref_page
   3.65%  cat      [kernel.kallsyms]  [k] __list_add_valid
   3.19%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
   3.10%  cat      [kernel.kallsyms]  [k] find_vmap_area
   3.05%  cat      [kernel.kallsyms]  [k] rcu_cblist_dequeue

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/vmalloc.c | 47 +++++++++++++++++++++++++++--------------------
 1 file changed, 27 insertions(+), 20 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 92b784d8088c..8ad8e8464e55 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2068,6 +2068,24 @@ struct vm_struct *find_vm_area(const void *addr)
 	return NULL;
 }
 
+static struct vm_struct *__remove_vm_area(struct vmap_area *va)
+{
+	struct vm_struct *vm = va->vm;
+
+	might_sleep();
+
+	spin_lock(&vmap_area_lock);
+	va->vm = NULL;
+	va->flags &= ~VM_VM_AREA;
+	va->flags |= VM_LAZY_FREE;
+	spin_unlock(&vmap_area_lock);
+
+	kasan_free_shadow(vm);
+	free_unmap_vmap_area(va);
+
+	return vm;
+}
+
 /**
  * remove_vm_area - find and remove a continuous kernel virtual area
  * @addr:	    base address
@@ -2080,31 +2098,20 @@ struct vm_struct *find_vm_area(const void *addr)
  */
 struct vm_struct *remove_vm_area(const void *addr)
 {
+	struct vm_struct *vm = NULL;
 	struct vmap_area *va;
 
-	might_sleep();
-
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
-		struct vm_struct *vm = va->vm;
-
-		spin_lock(&vmap_area_lock);
-		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
-		va->flags |= VM_LAZY_FREE;
-		spin_unlock(&vmap_area_lock);
-
-		kasan_free_shadow(vm);
-		free_unmap_vmap_area(va);
+	if (va && va->flags & VM_VM_AREA)
+		vm = __remove_vm_area(va);
 
-		return vm;
-	}
-	return NULL;
+	return vm;
 }
 
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
+	struct vmap_area *va;
 
 	if (!addr)
 		return;
@@ -2113,17 +2120,18 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			addr))
 		return;
 
-	area = find_vm_area(addr);
-	if (unlikely(!area)) {
+	va = find_vmap_area((unsigned long)addr);
+	if (unlikely(!va || !(va->flags & VM_VM_AREA))) {
 		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
 				addr);
 		return;
 	}
 
+	area = va->vm;
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	__remove_vm_area(va);
 	if (deallocate_pages) {
 		int i;
 
@@ -2138,7 +2146,6 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	}
 
 	kfree(area);
-	return;
 }
 
 static inline void __vfree_deferred(const void *addr)
-- 
2.20.1

