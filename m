Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90D7FC04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:12:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 342B72087B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 13:12:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QISLHjwa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 342B72087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE56F6B000A; Fri, 17 May 2019 09:12:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A96296B000C; Fri, 17 May 2019 09:12:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 983706B0010; Fri, 17 May 2019 09:12:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 65E8F6B000A
	for <linux-mm@kvack.org>; Fri, 17 May 2019 09:12:39 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id z1so3294136oth.8
        for <linux-mm@kvack.org>; Fri, 17 May 2019 06:12:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=FJs+O5o+cz5HCB5KlHNqWYoyNOZwk4659YdHbrsYlV8=;
        b=J6gCLuR0+hquLGOCfaOBcp1d9TZlOzI6wIbDXpvM2K70IntGqXiL2FV34g9hWYxJOq
         b93alomSAr78Qhgz5C6G9Uu3E3MyzU0koOWhKmFsPHdnYoYNLSA9Fn0YXeGp/R8ZRABI
         Sugy0A1taFxMJj5ADbsLYYN+vTrUtL1x1aJc0tdDSowTS9sWh/Sn60JfIhmBem7f7Seh
         HqjrPK2y7P8yMbTjFI9ddzr+M1mi2s68D3or/MNRwRW4Y7moC39+0czbmIkN9hOX/Y0f
         QptWCek3D5WLlPxkRnojrxtHzY+gqtTU4/sP2+XMhzQY0CvYZ5/jyl+OBqcdp0MnysNb
         LN1Q==
X-Gm-Message-State: APjAAAU+MCCfmCdtkPImaCUDKn8RyjFWxLLzPpFr2CkmZOT3LAaVsIuO
	L3LezoJJHDLApq1aZzDSuju7zfPrriowcmlnRjEYOYdYtrbZtBDnCN6Zyvlzi86NKKPkHIAAD9I
	80HNBnXE9R5NTmdO6Jvnh7lFdYwPFDYnlfgkvctcHr+MFwF9knaGwr2sO/Q5o50WAlQ==
X-Received: by 2002:aca:fd45:: with SMTP id b66mr14676497oii.157.1558098758849;
        Fri, 17 May 2019 06:12:38 -0700 (PDT)
X-Received: by 2002:aca:fd45:: with SMTP id b66mr14676447oii.157.1558098757885;
        Fri, 17 May 2019 06:12:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558098757; cv=none;
        d=google.com; s=arc-20160816;
        b=nkRCiJ1en/TODyMbrJ4Xo0SXLNR0NQmxJM5M4879UTSvA9D1Ytio3Mw32POdO3p1pf
         YHqWMQ2DmBSv6n9rxgpWLHjKdmnUXZ+mO+kQbWbMGCfq+0UOlry+p8pOWnnfVnESQ74L
         15jRM9MPIYyr+O7gxsm0mGLkWXF2flL1Mw8bVG1VIgRoRgrgzYcPxxSunzOPlMzKW5f3
         BWB+ozUrDZernn9yG7JSR9yveN2/31WmygVL1rN8BB1jhPdUqFbXahlX61N7rcatYDTN
         qrF2OWtSac1e4D54YyTpJ3giWxor1p8i3bpUsUFD6MD/CHJJ5X8uaAZ4ysw0OEtGmVL9
         pYwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=FJs+O5o+cz5HCB5KlHNqWYoyNOZwk4659YdHbrsYlV8=;
        b=RkswWBkPzVAmsn4FhCXbFN6wN7A6sS/KL/W58DSgWa1f8tZ58rEmS3Lb1gqJAQiufR
         1c0mgFmnVJNwizUv6RiG5hYiDEG/Xx+qFEvyPYKa3/DTel+GYRSB9yL65H8j1JqhmDQz
         xveazFsgeHYwhnazHKF46oW/rd+itO3SfhOmsS9GeaWEQinxfWkElz4WAWonweouAzVC
         lJWFSOtS0p2X6zzfJhYE+P6HbCL0RDUKx1ReezZ71GSVlQ2s0HMBbuasY0hd+/bfwsUd
         Mz1rfb70x3tiw1uEaxy620CUPKObT6/FwbU15kvCjofw8+IKPUbErFOauHfmVovkR202
         mCNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QISLHjwa;
       spf=pass (google.com: domain of 3rbpexaukcbqy5fyb08805y.w86527eh-664fuw4.8b0@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3RbPeXAUKCBQy5FyB08805y.w86527EH-664Fuw4.8B0@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 4sor4297673ots.99.2019.05.17.06.12.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 06:12:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3rbpexaukcbqy5fyb08805y.w86527eh-664fuw4.8b0@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=QISLHjwa;
       spf=pass (google.com: domain of 3rbpexaukcbqy5fyb08805y.w86527eh-664fuw4.8b0@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3RbPeXAUKCBQy5FyB08805y.w86527EH-664Fuw4.8B0@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=FJs+O5o+cz5HCB5KlHNqWYoyNOZwk4659YdHbrsYlV8=;
        b=QISLHjwatyyS68LYxu91gfHOGzQZkApgwV9mJCFI2+RWppkrWl5mmmoYiRBI29wN1I
         uyOsslA27pzcBpqGEwQ6sWUys8fIjXCVlf29bhf3n+LidYegLvtgPa2YvKFvOwaT72I9
         Hq840HxLmkBAUD61Jlm6ud0G+pc9jJi/oNgB74UhaXMiyrcxNIlenwLyGKBC3JFjWYY2
         joOK7FiIbMpz4pd+YfikGAnZMNyopEgOVy0D9mFONqOaiFKWsLbbRR93udxpZzczyMXX
         uPh4kunT6noNrJYvnRdozUC0MUS1xDN3RQo86J2HGbtZ3vncn8AtsSc3/ABUf5UbEAZL
         4o7Q==
X-Google-Smtp-Source: APXvYqxmOCq/WWsSZJAMIRC2Pm/Zl7/sWdlJ9DsC/yZBgEQ30AhwQnCY8jEe8fPbKfuPtPxzZLyGdrUOaQ==
X-Received: by 2002:a9d:400d:: with SMTP id m13mr14229666ote.100.1558098757436;
 Fri, 17 May 2019 06:12:37 -0700 (PDT)
Date: Fri, 17 May 2019 15:10:46 +0200
Message-Id: <20190517131046.164100-1-elver@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH] mm/kasan: Print frame description for stack bugs
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
Change-Id: I4836cde103052991ac8871796a45b4c977c9e2e7
---
 mm/kasan/kasan.h  |   5 ++
 mm/kasan/report.c | 160 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 165 insertions(+)

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
index 03a443579386..c6ad8462c0dc 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -28,6 +28,7 @@
 #include <linux/types.h>
 #include <linux/kasan.h>
 #include <linux/module.h>
+#include <linux/sched/task_stack.h>
 
 #include <asm/sections.h>
 
@@ -181,6 +182,163 @@ static inline bool init_task_stack_addr(const void *addr)
 			sizeof(init_thread_union.stack));
 }
 
+static bool __must_check tokenize_frame_descr(const char **frame_descr,
+					      char *token, size_t max_tok_len,
+					      unsigned long *value)
+{
+	const char *sep = strchr(*frame_descr, ' ');
+	const ptrdiff_t tok_len = sep - *frame_descr;
+
+	if (sep == NULL)
+		sep = *frame_descr + strlen(*frame_descr);
+
+	if (token != NULL) {
+		if (tok_len + 1 > max_tok_len) {
+			pr_err("KASAN internal error: frame description too long: %s\n",
+			       *frame_descr);
+			return false;
+		}
+		/* Copy token (+ 1 byte for '\0'). */
+		strlcpy(token, *frame_descr, tok_len + 1);
+	}
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
+	pr_err("this frame has %zu %s:\n", num_objects,
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
+		/* Strip line number, if it exists. */
+		strreplace(token, ':', '\0');
+
+		/* Finally, print object information. */
+		pr_err(" [%zu, %zu) '%s'", offset, offset + size, token);
+	}
+}
+
+static bool __must_check get_address_stack_frame_info(const void *addr,
+						      size_t *offset,
+						      const char **frame_descr,
+						      const void **frame_pc)
+{
+	size_t aligned_addr;
+	size_t mem_ptr;
+	const u8 *shadow_bottom;
+	const u8 *shadow_ptr;
+	const size_t *frame;
+
+	/*
+	 * NOTE: We currently only support printing frame information for
+	 * accesses to the task's own stack.
+	 */
+	if (!object_is_on_stack(addr))
+		return false;
+
+	aligned_addr = round_down((size_t)addr, sizeof(long));
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
+	frame = (const size_t *)(mem_ptr + KASAN_SHADOW_SCALE_SIZE);
+	if (frame[0] != KASAN_CURRENT_STACK_FRAME_MAGIC) {
+		pr_err("KASAN internal error: frame info validation failed; invalid marker: %zu\n",
+		       frame[0]);
+		return false;
+	}
+
+	*offset = (size_t)addr - (size_t)frame;
+	*frame_descr = (const char *)frame[1];
+	*frame_pc = (void *)frame[2];
+
+	return true;
+}
+
+static void print_address_stack_frame(const void *addr)
+{
+	size_t offset;
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
+	pr_err("addr %px is located in stack of task %s/%d at offset %zu in frame:\n",
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
@@ -204,6 +362,8 @@ static void print_address_description(void *addr)
 		pr_err("The buggy address belongs to the page:\n");
 		dump_page(page, "kasan: bad access detected");
 	}
+
+	print_address_stack_frame(addr);
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
-- 
2.21.0.1020.gf2820cf01a-goog

