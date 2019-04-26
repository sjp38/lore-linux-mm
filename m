Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B6E3C43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 511AA208C2
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:44:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fTkRQ/Y6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 511AA208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C8FE6B0279; Sat, 27 Apr 2019 02:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 726076B027A; Sat, 27 Apr 2019 02:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 581926B027B; Sat, 27 Apr 2019 02:43:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 194356B0279
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:40 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u2so3488250pgi.10
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=TdxUBqKvjD04gvlVW2fqTrr9rgpG7ttN99ifXgy4wJ0=;
        b=sUqBBWn2auYRVKdhvXMd4oCVm8tD4AA920v/2LpbNARfyEPKYUyDtdoSttd2kGggO5
         4b3/B+Bgf8+v6s4tN+C1/Jkcpw9lkKNKzQOBENgTr4pzXJjduEg0/4IAqrs0xLEzGpJM
         MpqbbvG65OIZ/2/NecDiA86eQ1lvvf1QKr3lbet0XRQA3iEGFqe19Wobz8VnmWAHCf4+
         gEuxnhjvq7Y1OJV7DVbyLo/eHNpZEO5YwGnFixaj/0HaAv6CQSo160Kmmmhz4nY0WnDR
         uSLI3GmsVA5E851W/AEdR2gOnnxOihn5P77Oym0Tvj21pgws0X1xc7kNFqTEvBBt0TwJ
         wK9A==
X-Gm-Message-State: APjAAAW6XeJ+NOPrdb8PzPc4eZc3xOBHK63S+odwuhcqawWp87Fupqmn
	MbjN3b3apTn9PwClxnFEE96xTwNbMwNQgoWAeNK/EtgvioLxSlzlOZGgNQbXPDvnF2WMUM3i49E
	8gCjBDm4KTtcaOtG3LnNQ/W+gAMz0tDF1HezPYQNnJckI+AYhRdsWnIw9kYu8XO/Gxw==
X-Received: by 2002:a62:fb0a:: with SMTP id x10mr17643831pfm.179.1556347419780;
        Fri, 26 Apr 2019 23:43:39 -0700 (PDT)
X-Received: by 2002:a62:fb0a:: with SMTP id x10mr17643787pfm.179.1556347418778;
        Fri, 26 Apr 2019 23:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347418; cv=none;
        d=google.com; s=arc-20160816;
        b=akuT8apVCEsz6sM6iqxfM0x1aBJMnvjpk2gEqUq3B25YgWGy3dvv7jfipBQbBN680O
         kr5mcWREyx0+n2vbvDGXi0JIkh1xMGPTTV+Ub46gZ3tfe/OfHAy3xfGR1/HMcmDgUq+h
         Dp6OOgoD1ZpD8FLhfg6tLJxyY8a8Wme5O7SYW0HeeaLO07/T6VieRXRpdRgXaOI3RljA
         VXlpLvCGQnxpD86fTFKkAlrcMAjrFshZX9zcBpv2zrMcFupsYCB6GnrYB5zP86ER5OTp
         ZUpdnjCzi3TgFbC7gXSGdH8JTC/8U3b3foy6nSo0009tsivlLX7s+357bDhNPAoNsrpL
         7M7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=TdxUBqKvjD04gvlVW2fqTrr9rgpG7ttN99ifXgy4wJ0=;
        b=Td4PmaCxQhau0PAdygVojgj5LmN8TW3m+EK4Mfa30y3++uB/M8mfyg6zjsX+yI6rMz
         jh/34I/74+G58nkk3k5gNrEF+VlFmtUHtmPnn2s0rXCuHzR84FemRDtNEgmyrJ+agjJY
         iY9a5LS8oxamueTrOVuA7X6hHvQOUQpAi8Q+6x4e2md0QdIuSa2U3XRS0sFbbmE+/Erq
         25NMERT4jQxV+gBfn7+2m99QIno/ggHtzDat4HOhBst3ENiOJ4V0MqFcFu5loIq3rRN1
         2j7hDoiioVtwicu5t7wb31eJqBeeZInrFtOVnYYIzYHneYphkpaXYav0RS4YssxFVC0N
         s/JA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="fTkRQ/Y6";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m32sor26803551pld.7.2019.04.26.23.43.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="fTkRQ/Y6";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=TdxUBqKvjD04gvlVW2fqTrr9rgpG7ttN99ifXgy4wJ0=;
        b=fTkRQ/Y6ekEQNK89awlPXt7h4NxMjoecNBAMoo9ta42p80ijXkGhM1UL/BQmQFyWo6
         LJfDPrdOvXO5UvSlwALV9jzgVbZ3dPkOetjmwgngrd6Xv4mjhDuVn4pVdt7q+ACp200R
         xHDNjHe63z2eq8GDtYLwE09uCfrsylk7ZaSgnWZyDkP/bBrVBZQ5DR2PNo0INMO0nJJB
         A8319czkJRDzqjy/YpDHiQ5QMkoO+Q0Ds/GWZq+ooXRPBqH7Yybl6d/xzosC6sOQZDv0
         Hev5YYonTqwLdIPLk/p3TqQ3UvgcH8BaYIQHch4ej87FxDr5lyTtZXPQ+va/opGvDk71
         04vw==
X-Google-Smtp-Source: APXvYqwkqefi+5wlFbKz/qeJ/65fu9i/qlczB3LZREQFaY/+lFjrw+S/8uXGcd/aBtDXpy5vBsJ5Xg==
X-Received: by 2002:a17:902:b715:: with SMTP id d21mr50699394pls.103.1556347418251;
        Fri, 26 Apr 2019 23:43:38 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:37 -0700 (PDT)
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
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>
Subject: [PATCH v6 24/24] bpf: Fail bpf_probe_write_user() while mm is switched
Date: Fri, 26 Apr 2019 16:23:03 -0700
Message-Id: <20190426232303.28381-25-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

When using a temporary mm, bpf_probe_write_user() should not be able to
write to user memory, since user memory addresses may be used to map
kernel memory.  Detect these cases and fail bpf_probe_write_user() in
such cases.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Reported-by: Jann Horn <jannh@google.com>
Suggested-by: Jann Horn <jannh@google.com>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 kernel/trace/bpf_trace.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index d64c00afceb5..94b0e37d90ef 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -14,6 +14,8 @@
 #include <linux/syscalls.h>
 #include <linux/error-injection.h>
 
+#include <asm/tlb.h>
+
 #include "trace_probe.h"
 #include "trace.h"
 
@@ -163,6 +165,10 @@ BPF_CALL_3(bpf_probe_write_user, void *, unsafe_ptr, const void *, src,
 	 * access_ok() should prevent writing to non-user memory, but in
 	 * some situations (nommu, temporary switch, etc) access_ok() does
 	 * not provide enough validation, hence the check on KERNEL_DS.
+	 *
+	 * nmi_uaccess_okay() ensures the probe is not run in an interim
+	 * state, when the task or mm are switched. This is specifically
+	 * required to prevent the use of temporary mm.
 	 */
 
 	if (unlikely(in_interrupt() ||
@@ -170,6 +176,8 @@ BPF_CALL_3(bpf_probe_write_user, void *, unsafe_ptr, const void *, src,
 		return -EPERM;
 	if (unlikely(uaccess_kernel()))
 		return -EPERM;
+	if (unlikely(!nmi_uaccess_okay()))
+		return -EPERM;
 	if (!access_ok(unsafe_ptr, size))
 		return -EPERM;
 
-- 
2.17.1

