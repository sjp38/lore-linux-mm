Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDEA5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DD732063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:52:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="erlzrsrP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DD732063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D6256B02B9; Fri, 15 Mar 2019 15:52:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4835E6B02BA; Fri, 15 Mar 2019 15:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39A476B02BB; Fri, 15 Mar 2019 15:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 145E86B02B9
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:52:17 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id q192so8572895itb.9
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:52:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=xQk3LhthwaCSqxwCcTkNdlxSKZFnDFG1SS+E3EAFA9Q=;
        b=nNm7DSI/Y1A1I0zIXzaHqy02WacQnrY3euh3hFMQ4ptvcrkDE52MybZaOhddPFDxD0
         b8qV2LoJm3dYnkFGLW1Iqc76BUTEdZGBS9fK/97GWCHV1LgrOpw/h/D5W2HYl/lNjveF
         NSrFwNP/kXp6MP0lzpVDjq7XmtmOybQK9+WnjNz7PpypArnTQNeGOmSkrsd+cLvDXRtt
         pL7gwineYAdbcvlyXnStOV+oUdUm/+2WWeILk6ZrounivdGbAYaztOPBuA2ztZdIpTRJ
         zE2tTCbzCPYPUpF/GQvYx4/Dzshg4zL43FtCtet9FP4f8YcpH1Dwwmm7luzIWs7NyOJ6
         Tszw==
X-Gm-Message-State: APjAAAXKwpyG7ilc8zVfNPuhcsFbzwIcL9Gxa1Vio/fwRHn4+bcrF7wQ
	/Xo3dsUxyqxGxUmMNQ+advzCAX381ZEFs0NOUUK6Nsv6c0XQYNhoCVEEFBd4BYyBv5sw5BkYrxy
	m/A8ygqR81H7Os8xOnjZWHJqn2ZHR6uOAVGMydE/9Loa8HhKD6LANEHOdoR54Jf1FEw==
X-Received: by 2002:a6b:e305:: with SMTP id u5mr3499512ioc.262.1552679536829;
        Fri, 15 Mar 2019 12:52:16 -0700 (PDT)
X-Received: by 2002:a6b:e305:: with SMTP id u5mr3499476ioc.262.1552679536011;
        Fri, 15 Mar 2019 12:52:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679536; cv=none;
        d=google.com; s=arc-20160816;
        b=box9ee1g0O9MhJuOt2n21W1iBqBmE7RkfDSMfWQpatzP7lz2W8w24t5fYfTuv80VaU
         dXJIGhxN+mBAwFxmu2Jx/ZENbajhBF1XImr/tQEu9Ns59sWdXW09eZrntn0Ueo8M0kNx
         4MIYr7zD3rjpeR93m/YnB08LU1cmRYbXk3Kv5hhmHeB7RwESDFRnok0vwh1/JIa+6raH
         4sq18nEhm8kEKR8SxOoLZXmBs/5TkTMX91vxYDzL0qDq/OyK44+4JqkLQHSFAFpIIdRN
         uwjKvIWVvMmAodVTAIAhx+APttIRiSe/OswedfvYIw2iWouG4z/fjkIQBW2nVlAKG8i6
         hbKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=xQk3LhthwaCSqxwCcTkNdlxSKZFnDFG1SS+E3EAFA9Q=;
        b=G4o1K4ryzozXaRQU8aw1O4+htmSUhOZZ3iDg4gC8VZwqSg9Rst1/bnOEGHh3Srji7S
         mAA3F8yhnFxBNBfzjMpU8NjHr0b5DVb9r3C72tV4NvNxL0fRLN6626hjxOBe2Hv1q5LS
         aDDSxTXzLFxEzOK2SzIFZboFPV6qthDkTNwWGuVsOn13m9uNKi/NnG5HyzWs9qoxeoDq
         GWwPJLwVF0TPMxY7h08uY/yQzUqJwG9NwJgx9sIfJWlAX3wJI6EnS+jOqUmXGcU/Ro84
         OTu6Q4DcXJlS1cWU9qV2Pyl+vKseqbXHwbRgxlQcOo+R2DjQaY9Gd+vFObobUrokzUmE
         fDig==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=erlzrsrP;
       spf=pass (google.com: domain of 3bwkmxaokci4s5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3bwKMXAoKCI4s5v9wG25D3y66y3w.u64305CF-442Dsu2.69y@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id d66sor5106930itd.18.2019.03.15.12.52.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:52:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3bwkmxaokci4s5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=erlzrsrP;
       spf=pass (google.com: domain of 3bwkmxaokci4s5v9wg25d3y66y3w.u64305cf-442dsu2.69y@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3bwKMXAoKCI4s5v9wG25D3y66y3w.u64305CF-442Dsu2.69y@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=xQk3LhthwaCSqxwCcTkNdlxSKZFnDFG1SS+E3EAFA9Q=;
        b=erlzrsrP8VxBF8HsFBwQbTIFhbizEW/LsVQAb4sB9lxRiyqjhT4uCp2723IUY/w0as
         JDSkvwBZ2J/k/0Gr8MvYLy9+lPaE5Mbr5BxZqaj+B32fmuQao+20kq6UQFBqlr7iQum4
         OAinUJ/2Tst5Nnic/IJVxsAPWJiUr5ue6Sg3ulcVoob/1X/OiS7RpGt905f6Qew6MgNY
         JEYORaq1c6WpaRg5DMZPoFljR7vI3/R+mQc61CKtUt4qxBTghm37TZV9KMnlkevHn6ql
         TPeg6qjkBgZQMlJkzr6XuOqDJLnou/KO5tmMMN3Tj/QArlELFQfSt7I9wSsT8s02fKRi
         2vzA==
X-Google-Smtp-Source: APXvYqz+GmruJTwbh+y6ScEKk8ZO6w3sULpD4k9iq4Qem8c0s9TmhOALFGnTHkcM6tlN06h5Rlqmfno2APVO8t8L
X-Received: by 2002:a24:2b45:: with SMTP id h66mr677136ita.28.1552679535681;
 Fri, 15 Mar 2019 12:52:15 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:34 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <355e7c0dadaa2bb79d22e0b7aac7e4efc1114d49.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 10/14] tracing, arm64: untag user pointers in seq_print_user_ip
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

seq_print_user_ip() uses provided user pointers for vma lookups, which
can only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 kernel/trace/trace_output.c |  5 +++--
 p                           | 45 +++++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+), 2 deletions(-)
 create mode 100644 p

diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 54373d93e251..6376bee93c84 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -370,6 +370,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 {
 	struct file *file = NULL;
 	unsigned long vmstart = 0;
+	unsigned long untagged_ip = untagged_addr(ip);
 	int ret = 1;
 
 	if (s->full)
@@ -379,7 +380,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 		const struct vm_area_struct *vma;
 
 		down_read(&mm->mmap_sem);
-		vma = find_vma(mm, ip);
+		vma = find_vma(mm, untagged_ip);
 		if (vma) {
 			file = vma->vm_file;
 			vmstart = vma->vm_start;
@@ -388,7 +389,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
 			ret = trace_seq_path(s, &file->f_path);
 			if (ret)
 				trace_seq_printf(s, "[+0x%lx]",
-						 ip - vmstart);
+						 untagged_ip - vmstart);
 		}
 		up_read(&mm->mmap_sem);
 	}
diff --git a/p b/p
new file mode 100644
index 000000000000..9d6fa5386e55
--- /dev/null
+++ b/p
@@ -0,0 +1,45 @@
+commit 1fa6fadf644859e8a6a8ecce258444b49be8c7ee
+Author: Andrey Konovalov <andreyknvl@google.com>
+Date:   Mon Mar 4 17:20:32 2019 +0100
+
+    kasan: fix coccinelle warnings in kasan_p*_table
+    
+    kasan_p4d_table, kasan_pmd_table and kasan_pud_table are declared as
+    returning bool, but return 0 instead of false, which produces a coccinelle
+    warning. Fix it.
+    
+    Fixes: 0207df4fa1a8 ("kernel/memremap, kasan: make ZONE_DEVICE with work with KASAN")
+    Reported-by: kbuild test robot <lkp@intel.com>
+    Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
+
+diff --git a/mm/kasan/init.c b/mm/kasan/init.c
+index 45a1b5e38e1e..fcaa1ca03175 100644
+--- a/mm/kasan/init.c
++++ b/mm/kasan/init.c
+@@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
+ #else
+ static inline bool kasan_p4d_table(pgd_t pgd)
+ {
+-	return 0;
++	return false;
+ }
+ #endif
+ #if CONFIG_PGTABLE_LEVELS > 3
+@@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
+ #else
+ static inline bool kasan_pud_table(p4d_t p4d)
+ {
+-	return 0;
++	return false;
+ }
+ #endif
+ #if CONFIG_PGTABLE_LEVELS > 2
+@@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
+ #else
+ static inline bool kasan_pmd_table(pud_t pud)
+ {
+-	return 0;
++	return false;
+ }
+ #endif
+ pte_t kasan_early_shadow_pte[PTRS_PER_PTE] __page_aligned_bss;
-- 
2.21.0.360.g471c308f928-goog

