Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DATE_IN_PAST_06_12,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37FD0C43218
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8422208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LWiWMfB1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8422208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B21826B0269; Sat, 27 Apr 2019 02:43:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8F516B026A; Sat, 27 Apr 2019 02:43:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79C4D6B026B; Sat, 27 Apr 2019 02:43:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 411916B0269
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:21 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g11so1496916plt.23
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=CLKl6NZzJuOK2yM4IgvyVy0XzBWA5gDBiZYSHfLNQ00=;
        b=JnmOGbdL3+J3Qesk+Y6hrJ7kweaJUGVcmzcHlfKVJc8WNs3uOc9FbPKvX7YNOITkwv
         Qi27FVEZ/YoDXAOqrMnXEYZiIQkr6jsam4ncPQMiPantPippyyk8iz0DSvg5h1FBUB5I
         R3WO+seNraaKOEMLPucCYmv4I+THwj4flaLyK4jpOA1bKmns7OQ0abt1R62gD6ECp0FO
         K4E1zS0V/no6AqMhgjlHJAgP/VM8ZLm7qn1Zntu3lE/H1aNF4BduLNu4Pm9jQaZ62zcw
         GF7g2rd35eKYQazjRZyvodNZxXPp7O2gGu9qox1CQC+HNCZYOE8guyaWwsHhF4mLA4BN
         GN6w==
X-Gm-Message-State: APjAAAXM3LCdeMdyxQvjMUT6cd04Kgnxf71knCc2AAZRFEjOwynmseSs
	VxXDhER9vVbd5f+ynJfLvE7ubDnGy/D9dbCkxtSyUpRMlc+0/6VuBsE27VyM/dVX2OldsJIUhRK
	mY+FdxPc3+a8RRv71sB481lggmlNCH3+Vb/adKFqIvGFE/4+D2LgGgDhLsjg8geyttA==
X-Received: by 2002:a62:5885:: with SMTP id m127mr17170993pfb.33.1556347400951;
        Fri, 26 Apr 2019 23:43:20 -0700 (PDT)
X-Received: by 2002:a62:5885:: with SMTP id m127mr17170945pfb.33.1556347399835;
        Fri, 26 Apr 2019 23:43:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347399; cv=none;
        d=google.com; s=arc-20160816;
        b=JDcfSYt+6l4FenuIYUYIJdGl2b4LTAcu8w+S89zS83LGpzqS/G7Sdlo8H9WMyAvNVc
         bfPrEmCteuP9Gre9FXwEC2l842GSwZW4Bo1b3/EzGday57N47Y20k2WG4CwQ7N3J8Su9
         ALOwYbV5QOGxhM4O7i4OOL+LHjofPDBhWHDfkR35vCuBwzk1zwJRXLrpZaSVjaCYlQBJ
         bIbMkm3MLACiURnbV/OYKyjk8BetYRqlBZnsYE/0KhX/Cbu0Xr0LgIAWG9+cuo0nEfaT
         qhyym7ckK4XQVfxdrI3TFqHBxxdfH3EkAVDpqJsHapy1S31lCjZCeRs358VYBvHBzMux
         3PjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=CLKl6NZzJuOK2yM4IgvyVy0XzBWA5gDBiZYSHfLNQ00=;
        b=P3JtT3xiyYui5F/rOPDBlsv8QcHh7KdtKvViuFRiwSzVIVnycF95xocAJW8RqkvU9Z
         QD3iOLWNEy7smAKaSMfB/tXEVrtwFGVnUi0Ay43oHAxXl/9mnDeCsMxfTIVRKFlwjLOc
         FHHAfwj3M6Ct3kIlxEBv0DJsmiXEvoEVxIgJkVrzUjVxNA1oieWXytjxEx+AEwWsvFvO
         0HQGxCUGqRdpUMt8L+XBJ/Wqz7BOFOy5J0YF43WDFKXVoZhSvUqGI5aryp2DZkE2ewys
         F/xzfIB7CRef9G6uFWKwRvsHXBZhgqDqXmHiG5dzgDos29y+3BZHL6T1xTrTe1xYoxTH
         rCtA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LWiWMfB1;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c14sor30826845pfc.71.2019.04.26.23.43.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LWiWMfB1;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=CLKl6NZzJuOK2yM4IgvyVy0XzBWA5gDBiZYSHfLNQ00=;
        b=LWiWMfB1NCPlUWHzx7KNU9QCQPe3RdgA8qCNPze1WHQjmMq2EnzDsMlPceyPd+MHEm
         QMnqsza7hwGkI6ZFGgTOeRjeOEfXCrRJYup1t+tZNnEBvqMdc01pTHEj2bJKvz7BRo7K
         E/q3JXY24fjwRSyZU/Tw4XNKZ1nfyh4euDeX0+jZD8/F9QgFlj4BNpu6QQplyXiEhS74
         PVZ8Bi1kj7P4bpKFaIDD7kzaPwPpjBstpFpZumGDsgFZsa4oA3jDKygoO8TIjMEYq1h+
         8j/kDmbTP0+sW4oBzq9jDl4H2CBcWV2hkh9XtxTKhVDjbhF8cy7tl1t7BO8Iros2slYv
         iP/w==
X-Google-Smtp-Source: APXvYqx8IDeCvv7F4Tl+g2zi6Qtjw6+CBIajqUbAMvc7uvXy5z6A8pYUXx0y0vJXO744BzKTEFFO2g==
X-Received: by 2002:aa7:91d6:: with SMTP id z22mr42068121pfa.242.1556347399283;
        Fri, 26 Apr 2019 23:43:19 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:18 -0700 (PDT)
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
	Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 10/24] x86/ftrace: Set trampoline pages as executable
Date: Fri, 26 Apr 2019 16:22:49 -0700
Message-Id: <20190426232303.28381-11-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

Since alloc_module() will not set the pages as executable soon, set
ftrace trampoline pages as executable after they are allocated.

For the time being, do not change ftrace to use the text_poke()
interface. As a result, ftrace still breaks W^X.

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index ef49517f6bb2..53ba1aa3a01f 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -730,6 +730,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	unsigned long end_offset;
 	unsigned long op_offset;
 	unsigned long offset;
+	unsigned long npages;
 	unsigned long size;
 	unsigned long retq;
 	unsigned long *ptr;
@@ -762,6 +763,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 		return 0;
 
 	*tramp_size = size + RET_SIZE + sizeof(void *);
+	npages = DIV_ROUND_UP(*tramp_size, PAGE_SIZE);
 
 	/* Copy ftrace_caller onto the trampoline memory */
 	ret = probe_kernel_read(trampoline, (void *)start_offset, size);
@@ -806,6 +808,12 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	/* ALLOC_TRAMP flags lets us know we created it */
 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
 
+	/*
+	 * Module allocation needs to be completed by making the page
+	 * executable. The page is still writable, which is a security hazard,
+	 * but anyhow ftrace breaks W^X completely.
+	 */
+	set_memory_x((unsigned long)trampoline, npages);
 	return (unsigned long)trampoline;
 fail:
 	tramp_free(trampoline, *tramp_size);
-- 
2.17.1

