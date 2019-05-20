Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58062C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:49:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF21F21479
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:49:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iNzQ2eWV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF21F21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C2066B0005; Mon, 20 May 2019 11:49:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 873116B0006; Mon, 20 May 2019 11:49:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73BEA6B0007; Mon, 20 May 2019 11:49:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52FD26B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 11:49:26 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id m5so2093919uak.11
        for <linux-mm@kvack.org>; Mon, 20 May 2019 08:49:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=DI/Egqa/t8z7Z3O4/V5tG0j/kPqJakDGU2aHEa8JEWE=;
        b=Ozx8SUYDscdIbZx+FJCooEZI/BYFbHpGse18WFP7xPy/CqqEpbJW2Cs0Cjg7JmyhFl
         5368Wp//xKmCF/vvf5pvvvFXEb0Qh1iEtlfcgDrya9E+ySjHt+dV+QXnA0pOMhd+79NP
         EJqCbhUarTcmM4OGA/hsSgEhT03KXcoitFoYSs+aFLQL3OhRaHtZDX6fMFSHZTwzSrDC
         e37msq6sI/JlzfXYp3a4mAraA+ThqwreO9PB3xeFK5EVjB3rRSNsMi+MCKUrwLWpT6T+
         w2zdLJD09dAmn+0g5qFZzBp/uoO8hS86fSG8eQbPgWJDylQ6AKkF/+mJjRGylvo33sib
         H3pA==
X-Gm-Message-State: APjAAAXZdRj4xoe5bZzAEG9lIx2s6EyeGymP9iHqrxA4PIxA1I4ekQQt
	DXmfnruqSxbIM5BtAqtBCBuAWsK1a++qZKL7KLM/L/Fl1fxCMXQr3MlQTclfot23jcOopZG9kZV
	73wtwcbh7mhRa5kUY0SiWDa64EiBDJ8rI83UHTktOLhlaETt5b4Bkl0MoybwNq39VaQ==
X-Received: by 2002:ab0:806:: with SMTP id a6mr1467092uaf.10.1558367365985;
        Mon, 20 May 2019 08:49:25 -0700 (PDT)
X-Received: by 2002:ab0:806:: with SMTP id a6mr1466947uaf.10.1558367364865;
        Mon, 20 May 2019 08:49:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558367364; cv=none;
        d=google.com; s=arc-20160816;
        b=AgvhqVTWH4mzFhwaLW2/ixjwFtPxzO7QkzvkuZVofVhb091C7WZCO8z4bFkwosqMCd
         370rHnM28lAUusNr/L5EqqjChTqseir/5iy8XGF57G4b9oeU8ikhq+zkn3YYO1vETGUo
         pTAdwaHHX5JzyA8eGFgbo/CcEGdH6VAONVV2mJd/Ic9eyfb2t5I/9Uluq6eOxMa6vPTd
         VEwdzaTUschR8rz8nCGLAN/yqxKm2UB0cWJ0k3tgI9W37dUwltwnqMJZS4ZFUgI6RYQm
         3as0fPWf9v/2dqn/3gmKAlzpgxGyiB/RgV8t/Dlrlyo1YDWsAYW+vn7ayF81QjFGEKO5
         k0SQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=DI/Egqa/t8z7Z3O4/V5tG0j/kPqJakDGU2aHEa8JEWE=;
        b=NzHRwdjfBm4aEA0v1rKa9rd5X9qovY91FY+M6qVommEx2/RHrYrTcxt/LYVe0yECR4
         B2ysbwYzZUy4O6UPSHP+/1DjqDLPkz4E8LrFlLV00Bor62YvECRq5Oh61I4hxEW6IkMb
         R6Lv+ESkSLp/Vgp8oe8Uqq3Ykv0khy6obgQjTBSlkFvvY/A4oXwDIKXSBYYpKPogsw59
         7j4uMx4AIb8ufUPqqSAhCZVdKdYLDyDsjhyaYvYWJjMMt+G3b9PbaUFco0B0JEa3VlFu
         0TW3qnY7Sxz8r0Ntr/dbvlEgDGrdGWf0zKsQx6xNsjsEj/AQSHPNAacG7oUOr5MFax9z
         sbBA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iNzQ2eWV;
       spf=pass (google.com: domain of 3hmzixaukcju3ak3g5dd5a3.1dba7cjm-bb9kz19.dg5@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3hMziXAUKCJU3AK3G5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id z14sor7909587vsp.5.2019.05.20.08.49.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 08:49:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hmzixaukcju3ak3g5dd5a3.1dba7cjm-bb9kz19.dg5@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iNzQ2eWV;
       spf=pass (google.com: domain of 3hmzixaukcju3ak3g5dd5a3.1dba7cjm-bb9kz19.dg5@flex--elver.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3hMziXAUKCJU3AK3G5DD5A3.1DBA7CJM-BB9Kz19.DG5@flex--elver.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=DI/Egqa/t8z7Z3O4/V5tG0j/kPqJakDGU2aHEa8JEWE=;
        b=iNzQ2eWVRVWevfmNDQpdaiQzyG+bILK5M35Ug3SQ+H7pAkL27Yx1pD/Qfd9xg31lQt
         g21vi88LeStBpIG4pBAmCZz8eLfyaPp+UjQN7URx8K/s/XoHyFcgIU2aTAGntWOX4bRI
         4n3KMqZBAq3exQsMdl1B4xhUyf9eZHhRgQj6ABcoJg/w7pfT1XWgYNXq4BpW0Tk2JaFt
         X+SkT0SYabnhJzBlzlug0YfvSYwzplo/oeH3gH1ofZTauz4w/G097IDRakzP0liAvKj4
         wjt3s5fDxMN2KzywndrBU6yI/pNx+6CTlahONqMhaS3ehy1wA5T+BWcqpIPvrvEoA3+V
         k/Jg==
X-Google-Smtp-Source: APXvYqxfdT2bYqgvU5XEvtNzyZ1ehCNT7CCh1Pf0H/EDuo440cRhpEfyey+Nt3dXRZWcXG3zV8ppfKIMLQ==
X-Received: by 2002:a05:6102:c3:: with SMTP id u3mr35250624vsp.0.1558367364526;
 Mon, 20 May 2019 08:49:24 -0700 (PDT)
Date: Mon, 20 May 2019 17:47:52 +0200
Message-Id: <20190520154751.84763-1-elver@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v2] mm/kasan: Print frame description for stack bugs
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

Changes since V1:
- Fix types in printf (%zu -> %lu).
- Prefer 'unsigned long', to ensure offsets/addrs are pointer sized, as
  emitted by ASAN instrumentation.

Change-Id: I4836cde103052991ac8871796a45b4c977c9e2e7
---
 mm/kasan/kasan.h  |   5 ++
 mm/kasan/report.c | 163 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 168 insertions(+)

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
index 03a443579386..36e55956acaf 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -28,6 +28,7 @@
 #include <linux/types.h>
 #include <linux/kasan.h>
 #include <linux/module.h>
+#include <linux/sched/task_stack.h>
 
 #include <asm/sections.h>
 
@@ -181,6 +182,166 @@ static inline bool init_task_stack_addr(const void *addr)
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
+		/* Strip line number, if it exists. */
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
@@ -204,6 +365,8 @@ static void print_address_description(void *addr)
 		pr_err("The buggy address belongs to the page:\n");
 		dump_page(page, "kasan: bad access detected");
 	}
+
+	print_address_stack_frame(addr);
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
-- 
2.21.0.1020.gf2820cf01a-goog

