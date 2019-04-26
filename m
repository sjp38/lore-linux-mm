Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3AE1C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57EDB2087C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RYKIYvXm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57EDB2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF5176B0006; Sat, 27 Apr 2019 02:43:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E78AD6B0008; Sat, 27 Apr 2019 02:43:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFA036B000A; Sat, 27 Apr 2019 02:43:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 942EF6B0006
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:07 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g1so3591398pfo.2
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Y4ax2hOd4Buhijx/oNSuXPhWpslJbmlh2LJYha9eHFk=;
        b=N5q14PX9BktHF4nZedzHHUz3/RKa2zmtAW5o6Et1n1Q41ERhGU6oEM8NzfJBo4++dG
         imdMQZgpj37d5CJeoZQJqnZsLnqVpchJYuma06StwVtHoTPOIBeYYM0XQlaMn2VDTwCw
         VFjbC4NJxAWJzl0gkq0Ed+QriFgVy0lJDe4le1O6trvfK53aSIy8L+mdE91SfbCeh6Ai
         xOv+Fx85NIcD4Zse7lTH816lk44j3XzLGuvgez7E2HRF1nX26g6/aDnqjCcOn3CRXrpp
         D3rFFwszlcomIFqwC1QzTuDcfyoDUi+kqtAeCl9FQ2NuQlzbsDsFsXPCSvFBZYK1EyXd
         uK2g==
X-Gm-Message-State: APjAAAX1riSoE+YbJcfNTJ1wRY/u2zG6yNHIZEnr3HAqM/Yhcp3Qz49N
	LJaj+wzb0HA0EDHgKmFWaXXQzdMvAZJFgnjsGCipELir42GLhIr0VhN84PtFsg7ytauGq+KES9p
	U6Pwiv+kdhauMrfe7tszPUJRnL8dG2WHapvdJZUp+VAmpC7G3KbYi9GPfJrqbbCFjww==
X-Received: by 2002:a65:6658:: with SMTP id z24mr489349pgv.323.1556347387229;
        Fri, 26 Apr 2019 23:43:07 -0700 (PDT)
X-Received: by 2002:a65:6658:: with SMTP id z24mr489293pgv.323.1556347386188;
        Fri, 26 Apr 2019 23:43:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347386; cv=none;
        d=google.com; s=arc-20160816;
        b=UdnzW8bZxdeNv03V4Yr4/6QA8yTvSihYkd+SXXA1GpK/auJPs6dzrGP66DAiC+Odm6
         9KtD+1c7vn3hNLGI4xUi2ES5ljdyp5tBNSfb0En6lxp3KemONqypZ7QCW5OdYeCfTqOc
         gEgV+vjaf9eTD5Pw4I/Lbgs97NokqvWQ03TE8b+3KIJpKA9QuHhZEDdJtarJho/ygnaD
         juulEsRHXZGc9oDImuUO7c8/aP34VQ+DLhBU3ZQmKTumn4svCP9U0/MfrdbUthWswDJ2
         hb+jF84PkfJNdXpBbQzYGg1rIHBFaZFALV73c3h9c1ekqbcBeyH/3v0mlk8WnMHUghCQ
         rkVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Y4ax2hOd4Buhijx/oNSuXPhWpslJbmlh2LJYha9eHFk=;
        b=c3IArCYnsGDmhGBQVgOnl+FdDYifyI3DTZ/KPGaDRe75dmZt0sQ85A6ts5wqXRQ3wd
         mFFkgpx/RmnyPOpWOwftSEvjd4bNMPViiR7KyeZV+QwMTfUVY57evss/sZGvs1ojdMYZ
         CscID4v2EzhX+fAQuEKzHCCgtIoqyuu16yXuM6hR9OYV8UbCsp0fYsv8i7s6FvHF1AN6
         fhQkzD9LDOwrQgZPeyICtvVk+1nKFyh3p4qfiV87Ept27WR52ny0nMQw/wNPuJVl5VnL
         rlhAOqKnSfj3Lxn0sVTZLNEH6YGQ2zNX6cFGruUiNMtfslZ/bCOyxdkKe4px+K+Aircv
         4C/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RYKIYvXm;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r19sor1216747pgg.34.2019.04.26.23.43.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RYKIYvXm;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=Y4ax2hOd4Buhijx/oNSuXPhWpslJbmlh2LJYha9eHFk=;
        b=RYKIYvXmL5tJ4u/bU0iLk60YO+Ox59zCcKmrYcUn0L0mc7KUA8ZtJ2R4XNYjQk2a8B
         DcQM399thIjNSjXHuZQ6k7afM/SMh1l1QYkf2D0hRQ+1xwvUSHZnrIJ4UJtkR2NL1yLe
         l1RYwwd0hroNUCsKi5IV5ZZNm8YzK8J7h42F1sPN4gG9Y1ehTjsd+VC718e5LdQep+gS
         k/OhJCSCkHRbcX+8zk8NtqDpMNtIV6Cqdz0zcbSsIjK/yzdPAJzadIJkFTsIuXX0ujKs
         CagOndVrfBrJnKlvTuPVqrDmZeIo9JxoUR6B70xI9bSBAuYLVmprrE1fKIlJc4O0C9hS
         uf2w==
X-Google-Smtp-Source: APXvYqzYil+3Ftso1TWpSV8095HGNQL/URTfcLD+HpGX4LAA48WZkM07V5HZ0EJt2GuXBL8qYa+EnA==
X-Received: by 2002:a63:b0b:: with SMTP id 11mr12676888pgl.445.1556347385725;
        Fri, 26 Apr 2019 23:43:05 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:05 -0700 (PDT)
From: nadav.amit@gmail.com
To: Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Rick Edgecombe <rick.p.edgecombe@intel.com>,
	Nadav Amit <namit@vmware.com>,
	Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Masami Hiramatsu <mhiramat@kernel.org>
Subject: [PATCH v6 02/24] x86/jump_label: Use text_poke_early() during early init
Date: Fri, 26 Apr 2019 16:22:41 -0700
Message-Id: <20190426232303.28381-3-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

There is no apparent reason not to use text_poke_early() during
early-init, since no patching of code that might be on the stack is done
and only a single core is running.

This is required for the next patches that would set a temporary mm for
text poking, and this mm is only initialized after some static-keys are
enabled/disabled.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/jump_label.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/jump_label.c b/arch/x86/kernel/jump_label.c
index f99bd26bd3f1..e7d8c636b228 100644
--- a/arch/x86/kernel/jump_label.c
+++ b/arch/x86/kernel/jump_label.c
@@ -50,7 +50,12 @@ static void __ref __jump_label_transform(struct jump_entry *entry,
 	jmp.offset = jump_entry_target(entry) -
 		     (jump_entry_code(entry) + JUMP_LABEL_NOP_SIZE);
 
-	if (early_boot_irqs_disabled)
+	/*
+	 * As long as only a single processor is running and the code is still
+	 * not marked as RO, text_poke_early() can be used; Checking that
+	 * system_state is SYSTEM_BOOTING guarantees it.
+	 */
+	if (system_state == SYSTEM_BOOTING)
 		poker = text_poke_early;
 
 	if (type == JUMP_LABEL_JMP) {
-- 
2.17.1

