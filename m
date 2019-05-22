Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C62EC18E7D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:02:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 045502070D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:02:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mwa0/Ji2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 045502070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FAFE6B0003; Wed, 22 May 2019 06:02:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AC476B0006; Wed, 22 May 2019 06:02:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 799816B0007; Wed, 22 May 2019 06:02:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB556B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:02:01 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n65so1759249qke.12
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:02:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=YHDO2phcBlcC8egLCS1LoSqogxMYR/g87S2UaCiOpn4=;
        b=sNyo3JCDkEdioYEOUM3+T4RoClGjASSpWxwbkTI3MnQ9ckVnu4c1UwzOMFtsKoaBNr
         vnys2xSbJ0Tf5W3GBJibp6DPAyeoZcpnKyBcMUIyWwyIHOWFMbjksmrR28MeA7xSVMtg
         HqSqNalJwaghwNlSDAFUGYZ/4koL8nZv9EDT745F277001tElVApacFEgqF42CjP6r+n
         aprQORwK8K3ABcQoQKDMqSDvJDGK5LOhrJAqmduNXHmXDbV+Rkd0YVVWyEIq+i5VfRQZ
         wOajU4QsBE38qJhbhQWyAklPqKRf6D8ypViBj3UNV70EYCc8mvSd4xRqgT0/BmFkjhi5
         vCOA==
X-Gm-Message-State: APjAAAVeboQM0iAieJyc89OJyyfr0cCWEiVXMtCH+O4CmxtQ3LthdWkr
	JTxv1eaDuQQlSLa2YNTu4CTEc8H1cvqJ0CzA953hGmc5Z86ORqfBPSNIXZ6SnuB0bNwvvzfAoRR
	h97WBBJCJr4F3z7FY6S+klUCQmmJFhTBqXa1QzrE2qE4vQiHYU8XN6zXPU+zhdrvBGA==
X-Received: by 2002:a0c:d0fc:: with SMTP id b57mr48398918qvh.70.1558519320957;
        Wed, 22 May 2019 03:02:00 -0700 (PDT)
X-Received: by 2002:a0c:d0fc:: with SMTP id b57mr48398826qvh.70.1558519319889;
        Wed, 22 May 2019 03:01:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558519319; cv=none;
        d=google.com; s=arc-20160816;
        b=OCE5QO0LzKroIG6Trq9qI3uT0l+csg0eg1/FSz+4Zk2G9Irk7pwbUp0Q43rDQdPOTY
         KSYVMMr/sbNn0VPSpyKs7WER9Kudyr/SO47pMDv2tgC60L4c/djHD6fnLGnWqGMoTXag
         ju/ZSadUwAlV/jy0/CcPEBQwR0GuXTTdOFLfTP2hUVyScNz1D0VF+siOjPVYqnXrYU3s
         tj45ER8Kh5C7hFwDXusApRChbNArstI4V1L37oCbqrdsmuKBXjHcvNKg4/Ug0nWMTgaA
         E7LAT9G8SjPgHRFJRV9HVJKCp42HGwCYIN4IVRu8H5bPiSd4mZ+d+36oUG4wBOGIcspE
         e3KA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=YHDO2phcBlcC8egLCS1LoSqogxMYR/g87S2UaCiOpn4=;
        b=CY1FlBghOeSvxCzrKKPZBNHhwpJ8YknOpdaZye4Op5ZUAhkzOejaa+K0DdRQXrWXA0
         fFfvcRRbMLneIGZ9S7DZRfeKbyX5cWK9siTPb9ojTE/oKgVlbfdhBtIHEHK1YA0zvF8V
         yvs/1TvG8bWcWwNkJqvWwY8GB+ugJ0FxFbLB5fmFvFBtHWwg7TnkOGY+CkqHODxSScUM
         aPJyRTtRNxOMPglM6NyObbH95tZN0y5jprqfJBdjYyq8OVGCrz/NoFNXNMPRA3jr9ary
         ggBIda9EUGWGoRG8r8BoytLtXaM1ccFegyPvC9NFoujancxQAGuljDIG2sGI9orJeBKH
         ECWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="mwa0/Ji2";
       spf=pass (google.com: domain of 3fx7lxaukcnq4bl4h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Fx7lXAUKCNQ4BL4H6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id o72sor1201854qke.61.2019.05.22.03.01.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 03:01:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3fx7lxaukcnq4bl4h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="mwa0/Ji2";
       spf=pass (google.com: domain of 3fx7lxaukcnq4bl4h6ee6b4.2ecb8dkn-ccal02a.eh6@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Fx7lXAUKCNQ4BL4H6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=YHDO2phcBlcC8egLCS1LoSqogxMYR/g87S2UaCiOpn4=;
        b=mwa0/Ji2fwq1sL7J2eSSr4vCq9PNV3hbM11Qg1tdKLGQ5d7+nG9aVi4Fat+xUhdPTe
         KY7ytt6yyj8b6NQOtQNVNpbL7t5GFXr43RK9T4LDARNewa5CgXHUcwdRsMEapBDkilU2
         nCDcjWwPutBaBP9ZW1Ucu7OHU2UTN6f4oDjElZLJwyQs2zdDMlLzgt+bbl93IfPWTK3H
         DvmpPrgIm2KGNJeacgV2alsgCg2w8lFOfOycBx3okBz31SbMZNbebe5tVcSvOpAXgfD0
         x9/g/QZHgoQxxB3LOcFKBwgp78ELoWNPKqD3MdxdLEKAcQMix6hXScjcJlCc8tekGVBn
         6RaA==
X-Google-Smtp-Source: APXvYqx/VaQ5jlC/Ooy3ieBuu8+ppktY0rK3DL633eMh4j8i6rRO3/+v8ktj4Xm073TLE+hG9+z/3PdezQ==
X-Received: by 2002:a37:4cc9:: with SMTP id z192mr59997831qka.198.1558519319575;
 Wed, 22 May 2019 03:01:59 -0700 (PDT)
Date: Wed, 22 May 2019 12:00:50 +0200
Message-Id: <20190522100048.146841-1-elver@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v3] mm/kasan: Print frame description for stack bugs
From: Marco Elver <elver@google.com>
To: aryabinin@virtuozzo.com, dvyukov@google.com, glider@google.com, 
	andreyknvl@google.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	kasan-dev@googlegroups.com, Marco Elver <elver@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This adds support for printing stack frame description on invalid stack
accesses. The frame description is embedded by the compiler, which is
parsed and then pretty-printed.

Currently, we can only print the stack frame info for accesses to the
task's own stack, but not accesses to other tasks' stacks.

Example of what it looks like:

[   17.924050] page dumped because: kasan: bad access detected
[   17.924908]
[   17.925153] addr ffff8880673ef98a is located in stack of task insmod/2008 at offset 106 in frame:
[   17.926542]  kasan_stack_oob+0x0/0xf5 [test_kasan]
[   17.927932]
[   17.928206] this frame has 2 objects:
[   17.928783]  [32, 36) 'i'
[   17.928784]  [96, 106) 'stack_array'
[   17.929216]
[   17.930031] Memory state around the buggy address:

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=198435
Signed-off-by: Marco Elver <elver@google.com>
---

Changes since v2:
- Comment about why line number is stripped.
- Add BUILD_BUG_ON(CONFIG_STACK_GROWSUP).

Changes since v1:
- Fix types in printf (%zu -> %lu).
- Prefer 'unsigned long', to ensure offset/points are pointer sized, as
  emitted by ASAN instrumentation.

Change-Id: I4836cde103052991ac8871796a45b4c977c9e2e7
---
 mm/kasan/kasan.h  |   5 ++
 mm/kasan/report.c | 165 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 170 insertions(+)

diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 3ce956efa0cb..1979db4763e2 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -43,6 +43,11 @@
 
 #define KASAN_ALLOCA_REDZONE_SIZE	32
 
+/*
+ * Stack frame marker (compiler ABI).
+ */
+#define KASAN_CURRENT_STACK_FRAME_MAGIC 0x41B58AB3
+
 /* Don't break randconfig/all*config builds */
 #ifndef KASAN_ABI_VERSION
 #define KASAN_ABI_VERSION 1
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 03a443579386..0e5f965f1882 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -28,6 +28,7 @@
 #include <linux/types.h>
 #include <linux/kasan.h>
 #include <linux/module.h>
+#include <linux/sched/task_stack.h>
 
 #include <asm/sections.h>
 
@@ -181,6 +182,168 @@ static inline bool init_task_stack_addr(const void *addr)
 			sizeof(init_thread_union.stack));
 }
 
+static bool __must_check tokenize_frame_descr(const char **frame_descr,
+					      char *token, size_t max_tok_len,
+					      unsigned long *value)
+{
+	const char *sep = strchr(*frame_descr, ' ');
+
+	if (sep == NULL)
+		sep = *frame_descr + strlen(*frame_descr);
+
+	if (token != NULL) {
+		const size_t tok_len = sep - *frame_descr;
+
+		if (tok_len + 1 > max_tok_len) {
+			pr_err("KASAN internal error: frame description too long: %s\n",
+			       *frame_descr);
+			return false;
+		}
+
+		/* Copy token (+ 1 byte for '\0'). */
+		strlcpy(token, *frame_descr, tok_len + 1);
+	}
+
+	/* Advance frame_descr past separator. */
+	*frame_descr = sep + 1;
+
+	if (value != NULL && kstrtoul(token, 10, value)) {
+		pr_err("KASAN internal error: not a valid number: %s\n", token);
+		return false;
+	}
+
+	return true;
+}
+
+static void print_decoded_frame_descr(const char *frame_descr)
+{
+	/*
+	 * We need to parse the following string:
+	 *    "n alloc_1 alloc_2 ... alloc_n"
+	 * where alloc_i looks like
+	 *    "offset size len name"
+	 * or "offset size len name:line".
+	 */
+
+	char token[64];
+	unsigned long num_objects;
+
+	if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
+				  &num_objects))
+		return;
+
+	pr_err("\n");
+	pr_err("this frame has %lu %s:\n", num_objects,
+	       num_objects == 1 ? "object" : "objects");
+
+	while (num_objects--) {
+		unsigned long offset;
+		unsigned long size;
+
+		/* access offset */
+		if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
+					  &offset))
+			return;
+		/* access size */
+		if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
+					  &size))
+			return;
+		/* name length (unused) */
+		if (!tokenize_frame_descr(&frame_descr, NULL, 0, NULL))
+			return;
+		/* object name */
+		if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
+					  NULL))
+			return;
+
+		/* Strip line number; without filename it's not very helpful. */
+		strreplace(token, ':', '\0');
+
+		/* Finally, print object information. */
+		pr_err(" [%lu, %lu) '%s'", offset, offset + size, token);
+	}
+}
+
+static bool __must_check get_address_stack_frame_info(const void *addr,
+						      unsigned long *offset,
+						      const char **frame_descr,
+						      const void **frame_pc)
+{
+	unsigned long aligned_addr;
+	unsigned long mem_ptr;
+	const u8 *shadow_bottom;
+	const u8 *shadow_ptr;
+	const unsigned long *frame;
+
+	BUILD_BUG_ON(IS_ENABLED(CONFIG_STACK_GROWSUP));
+
+	/*
+	 * NOTE: We currently only support printing frame information for
+	 * accesses to the task's own stack.
+	 */
+	if (!object_is_on_stack(addr))
+		return false;
+
+	aligned_addr = round_down((unsigned long)addr, sizeof(long));
+	mem_ptr = round_down(aligned_addr, KASAN_SHADOW_SCALE_SIZE);
+	shadow_ptr = kasan_mem_to_shadow((void *)aligned_addr);
+	shadow_bottom = kasan_mem_to_shadow(end_of_stack(current));
+
+	while (shadow_ptr >= shadow_bottom && *shadow_ptr != KASAN_STACK_LEFT) {
+		shadow_ptr--;
+		mem_ptr -= KASAN_SHADOW_SCALE_SIZE;
+	}
+
+	while (shadow_ptr >= shadow_bottom && *shadow_ptr == KASAN_STACK_LEFT) {
+		shadow_ptr--;
+		mem_ptr -= KASAN_SHADOW_SCALE_SIZE;
+	}
+
+	if (shadow_ptr < shadow_bottom)
+		return false;
+
+	frame = (const unsigned long *)(mem_ptr + KASAN_SHADOW_SCALE_SIZE);
+	if (frame[0] != KASAN_CURRENT_STACK_FRAME_MAGIC) {
+		pr_err("KASAN internal error: frame info validation failed; invalid marker: %lu\n",
+		       frame[0]);
+		return false;
+	}
+
+	*offset = (unsigned long)addr - (unsigned long)frame;
+	*frame_descr = (const char *)frame[1];
+	*frame_pc = (void *)frame[2];
+
+	return true;
+}
+
+static void print_address_stack_frame(const void *addr)
+{
+	unsigned long offset;
+	const char *frame_descr;
+	const void *frame_pc;
+
+	if (IS_ENABLED(CONFIG_KASAN_SW_TAGS))
+		return;
+
+	if (!get_address_stack_frame_info(addr, &offset, &frame_descr,
+					  &frame_pc))
+		return;
+
+	/*
+	 * get_address_stack_frame_info only returns true if the given addr is
+	 * on the current task's stack.
+	 */
+	pr_err("\n");
+	pr_err("addr %px is located in stack of task %s/%d at offset %lu in frame:\n",
+	       addr, current->comm, task_pid_nr(current), offset);
+	pr_err(" %pS\n", frame_pc);
+
+	if (!frame_descr)
+		return;
+
+	print_decoded_frame_descr(frame_descr);
+}
+
 static void print_address_description(void *addr)
 {
 	struct page *page = addr_to_page(addr);
@@ -204,6 +367,8 @@ static void print_address_description(void *addr)
 		pr_err("The buggy address belongs to the page:\n");
 		dump_page(page, "kasan: bad access detected");
 	}
+
+	print_address_stack_frame(addr);
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
-- 
2.21.0.1020.gf2820cf01a-goog

