Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48042C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC6982063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vfItA5WB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC6982063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91C296B02BD; Fri, 15 Mar 2019 15:52:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87B076B02BE; Fri, 15 Mar 2019 15:52:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F6096B02BF; Fri, 15 Mar 2019 15:52:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4719C6B02BD
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:23 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id l11so13014339ywl.18
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=UI7aEl8s0mFedqqMgOc8iwA/qQRORzYcgfY9MOX1Q3Q=;
        b=A8bR0rHdJWEj5fwNaoE4YOojeRkLgF+HKHh3D/HsTPPLWXT5vuPMI819FPoGqpMdnq
         tqspJ+hhHmb6DkYIsSq/B5cy8dOSD0IckR9G7El8EyrpP5XN2SvVvrC5KPmN6SWX+OK1
         2FfDvv5XTcwJRXG+026/B7AuosrKcoVhGXb7w3bVSWbxOrT8h/brugtRcCQKil9YVl1W
         8+vIlOyurF63chjC8dfFGcI69JD7nASDUWcwBhTh5OhoL51AnAqCOhsfIE6UyE+MGbfj
         5AE4OVQ8ZDzUj7AgCLPlAMQyqR+G6kQok4XSQzImNy3uTtkaWhmBvoR7GlDKlY5cdUG3
         7fig==
X-Gm-Message-State: APjAAAVEZLCmbFxcFcqLVdIKXlQKIZC5tk9KQerOG/xjRmIxbhiN3zPO
	3AHCf17AogdTiDOv2EtC79If1jzl14xeOKGWBSeW8GVk3n8t4IAHc3sQKr9dec1RT0dgWr1sBpz
	+dbD//JEkp15u0UqHO93w6YmdTO43WKmYuSWgxW6J2HFey9vvaIOZ4rfiCInokzQiAA==
X-Received: by 2002:a81:7206:: with SMTP id n6mr3803722ywc.75.1552679543056;
        Fri, 15 Mar 2019 12:52:23 -0700 (PDT)
X-Received: by 2002:a81:7206:: with SMTP id n6mr3803677ywc.75.1552679542150;
        Fri, 15 Mar 2019 12:52:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679542; cv=none;
        d=google.com; s=arc-20160816;
        b=Ztbj5jmKstGMcpHOPHwks7FKqMJWA/stEL1l/zKO7der5EwPB0VxZb6mzT+YsTVeuy
         1jQ8q//MVsX+yrlHL5xZ0KzA+r+3TTZFuw7GCch1sGGiX4YkEWZI5DYsAcGCLkSXdPoc
         i/kY7lfz89W/r/AiNajf++tXIE+EVIgIgTvjPbV9snwiszIK459JEzbsBDXDF3PP9YiQ
         UNs9dwp4JvC6K0zhW+cPjrmNtAvTZbQwNJ/GM+dP5li3f5tZECzOEHexe7qhDIbZhtDs
         kkaeDSN2jSAJ5vojCC1usd1ndq7ZNvKucfh6LtdqYKverOKukDOMIyQzD3gMuz0yukkO
         ZJhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=UI7aEl8s0mFedqqMgOc8iwA/qQRORzYcgfY9MOX1Q3Q=;
        b=MWeN1RZxx/tfjI1wvIm5dxfs0YPHv8BLm4dZa1ttM/ARC2qPiKpYbc1azTWJ9PjEMR
         qI0NVQQzaU9cCX+6M46YZJASYE3s8QfhF1pkAzv6tJXWcSSHaBpV8fT0BRJZ+OPz/yo4
         K8tEdwjfUaME6qW/0xtyq1Fcqilp1bEtbA7HHCNPUf8mRLhyLHapKeBkEf/Pdm502nWO
         fGAxVCD34HzBKLgoY1EYRgzsJrp/6oXQc/7oS+fqyFvIUMdn0KtZBXvlyvrA+MQR6cIG
         lcVLI4lzSZMD/6MZB6MLF9RhRCnshYnCt3My2l7QXK0K5x2w04vwI8oK9qHj2Rn/zjQB
         fkQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vfItA5WB;
       spf=pass (google.com: domain of 3dqkmxaokcjqyb1f2m8bj94cc492.0ca96bil-aa8jy08.cf4@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3dQKMXAoKCJQyB1F2M8BJ94CC492.0CA96BIL-AA8Jy08.CF4@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l128sor1758679ybb.112.2019.03.15.12.52.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3dqkmxaokcjqyb1f2m8bj94cc492.0ca96bil-aa8jy08.cf4@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vfItA5WB;
       spf=pass (google.com: domain of 3dqkmxaokcjqyb1f2m8bj94cc492.0ca96bil-aa8jy08.cf4@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3dQKMXAoKCJQyB1F2M8BJ94CC492.0CA96BIL-AA8Jy08.CF4@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=UI7aEl8s0mFedqqMgOc8iwA/qQRORzYcgfY9MOX1Q3Q=;
        b=vfItA5WBR9mxsOR5v/mXd6WRiw4qlJltvNcK03CJ3M5tD9oVwrnLXYPI73iFuFVvAy
         bStP8xOii4yXjBbLTiAyKSB+txWVCS5HbLg7oCB6RFMjQ5I07jr4SiImmyWLTfMKN0Vo
         z36zX4CJInXJMuVWsluFJtX4mg9tVYzK2laFJNn9axSKJXusl77n+y3QdI2KYR44uRZK
         TdwpdeFyx3tJBo/3IPC6BPg3PY4+1i133Q8TRIUuSaS8J+5QIn7rjJkfF42EQR9AUQXB
         a+dyvkdV6VlmT38t3+1yugNVaOElo8rNqqI8UQ90j7irslaNCh2z5PcCU9Uzw8Cc9GWC
         No2Q==
X-Google-Smtp-Source: APXvYqxeRzK18KUJ10+PDA+W93JZa2qDw/GudrGBEMPcLUXJuZN92dXCZ+z04uJTKknTff4jbLvWVF1Z13ZfBUn3
X-Received: by 2002:a5b:44e:: with SMTP id s14mr2709444ybp.100.1552679541907;
 Fri, 15 Mar 2019 12:52:21 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:36 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <0e1bd7fbde338061ea54234b3b1bd5ab6102381e.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 12/14] bpf, arm64: untag user pointers in stack_map_get_build_id_offset
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

stack_map_get_build_id_offset() uses provided user pointers for vma
lookups, which can only by done with untagged pointers.

Untag the user pointer in this function for doing the lookup and
calculating the offset, but save as is into the bpf_stack_build_id
struct.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/bpf/stackmap.c |  6 ++++--
 p                     | 45 -------------------------------------------
 2 files changed, 4 insertions(+), 47 deletions(-)
 delete mode 100644 p

diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 950ab2f28922..bb89341d3faf 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -320,7 +320,9 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
 	}
 
 	for (i = 0; i < trace_nr; i++) {
-		vma = find_vma(current->mm, ips[i]);
+		u64 untagged_ip = untagged_addr(ips[i]);
+
+		vma = find_vma(current->mm, untagged_ip);
 		if (!vma || stack_map_get_build_id(vma, id_offs[i].build_id)) {
 			/* per entry fall back to ips */
 			id_offs[i].status = BPF_STACK_BUILD_ID_IP;
@@ -328,7 +330,7 @@ static void stack_map_get_build_id_offset(struct bpf_stack_build_id *id_offs,
 			memset(id_offs[i].build_id, 0, BPF_BUILD_ID_SIZE);
 			continue;
 		}
-		id_offs[i].offset = (vma->vm_pgoff << PAGE_SHIFT) + ips[i]
+		id_offs[i].offset = (vma->vm_pgoff << PAGE_SHIFT) + untagged_ip
 			- vma->vm_start;
 		id_offs[i].status = BPF_STACK_BUILD_ID_VALID;
 	}
diff --git a/p b/p
deleted file mode 100644
index 9d6fa5386e55..000000000000
--- a/p
+++ /dev/null
@@ -1,45 +0,0 @@
-commit 1fa6fadf644859e8a6a8ecce258444b49be8c7ee
-Author: Andrey Konovalov <andreyknvl@google.com>
-Date:   Mon Mar 4 17:20:32 2019 +0100
-
-    kasan: fix coccinelle warnings in kasan_p*_table
-    
-    kasan_p4d_table, kasan_pmd_table and kasan_pud_table are declared as
-    returning bool, but return 0 instead of false, which produces a coccinelle
-    warning. Fix it.
-    
-    Fixes: 0207df4fa1a8 ("kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN")
-    Reported-by: kbuild test robot <lkp@intel.com>
-    Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
-
-diff --git a/mm/kasan/init.c b/mm/kasan/init.c
-index 45a1b5e38e1e..fcaa1ca03175 100644
---- a/mm/kasan/init.c
-+++ b/mm/kasan/init.c
-@@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
- #else
- static inline bool kasan_p4d_table(pgd_t pgd)
- {
--	return 0;
-+	return false;
- }
- #endif
- #if CONFIG_PGTABLE_LEVELS > 3
-@@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
- #else
- static inline bool kasan_pud_table(p4d_t p4d)
- {
--	return 0;
-+	return false;
- }
- #endif
- #if CONFIG_PGTABLE_LEVELS > 2
-@@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
- #else
- static inline bool kasan_pmd_table(pud_t pud)
- {
--	return 0;
-+	return false;
- }
- #endif
- pte_t kasan_early_shadow_pte[PTRS_PER_PTE] __page_aligned_bss;
-- 
2.21.0.360.g471c308f928-goog

