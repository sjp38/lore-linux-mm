Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 383D8C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF5F0206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:23:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="FbWCjBYO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF5F0206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 171FC6B0006; Fri, 26 Apr 2019 12:23:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12A2B6B000A; Fri, 26 Apr 2019 12:23:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F061E6B000C; Fri, 26 Apr 2019 12:23:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id A59796B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:23:29 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id f11so3509777wmc.8
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:23:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=QWHSqdkI9Y4fpXhoDPnLYy0SQ5zi1ORLMCcZL/nU9e4=;
        b=qu33fga4VJAI8JI1UHWkksGe9QKk+wH5pBkZmcmej1z+Q5zzDBToJBcVDE8dqvQtzE
         pkA3ZcKHi2EgWkT0WmByBnHE6UMbOMTmZ0B5zMTZkg4nCl34MGNHiTzG0/kLHn0Wzd7r
         Bd9BFly7IiOLpf4JgsyzZ28gHlw5oFzfA/YZHUZ+HH2l5KNPaHGfX/HSHVlHEcRP7gaT
         Od4U3S3hG1KHuvy3OcMImpensliHsqcHBXpTPhuAsbeQ1JfOB16c3SBtWxqhL583P1U+
         aQw4uaB8/VwuMkPSoOt0Jvwp6xYOWcna6wwjnBsjDEv+517l3Ks0VWllFftHum34ujK6
         xTvA==
X-Gm-Message-State: APjAAAViwpnyi+OcYZUSx7l1Zm+6T3VeMBbdKXvMV4ES6uxsABIcJXkC
	s5T95gxuxQw7j5hq1pT5nwHvos6d6tTs1T1enhP38HXfLTjwC37FgRxlHrXq4SLDeAjVz9ivYGa
	9kXGlYD6u8uLCt+gGiLQH1m9MpjyjPI+R/ZVJq2mkPSc5M0Y4SU8jldwwQFXXfzqAbw==
X-Received: by 2002:a1c:be08:: with SMTP id o8mr3452366wmf.76.1556295809104;
        Fri, 26 Apr 2019 09:23:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymGcMHwmjp051Ck/qRXaXrjv46JwZWRlFZlBFneLtwibN/2o90afj/3J4q5Sxw/Pjif+gf
X-Received: by 2002:a1c:be08:: with SMTP id o8mr3452312wmf.76.1556295808193;
        Fri, 26 Apr 2019 09:23:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556295808; cv=none;
        d=google.com; s=arc-20160816;
        b=tefjY36JGCwEPddGmQHxNMEKJk0XIrmVTAkg6Kseozg3erFZfXhhMx/ayugpKTvCl8
         BrZ83xfIRqg7GOzLsC9ytsjLux8Ny62bqt+EJL61VjnO/tUwLwGy0PDaH2d4C2S8hctr
         M8Tb0ISwmuG3+wZk/g84nPMtNB2znSLj5ZrHyAXMeECiKLoDk+FQafKJiFKMO63oT0CP
         ayeDhhQDCJc+lVye9e4/NUq2hT3/xrrOkWVRW8wiOW8wQ/UgGWWSN+ZiHGBJ5oE43B8o
         lI8z2pTcPR/bKdVDRU5H51mgrBvGWmz6KKNOs2Tnadx7J4VBo423dIzlesgg9lBuHz3p
         G99Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=QWHSqdkI9Y4fpXhoDPnLYy0SQ5zi1ORLMCcZL/nU9e4=;
        b=nLbxubIKAOcgEvk+u3lPZUDhtuhoqtceet3XdTPpS55yS+8xOKbVkOxf4HptK/JjRi
         io9P7UMcZmvK5Kb8xwi3xIK/NAf9Y6o8mD1FYDDlH6cFCPh9zjQCrcAC4IFNVffhbyBo
         xxDJbuQ3ogRtPrCOkiQkyn8ZTO90PqhsiORmJuJvMhnwSaaO3dLEykCpPRsSM2l93E78
         NMz+ZB3wPRcYHkdIX5tbm94iDn6wroPlbO5jHx8zrtg9pwgG7PMH6+BkFrKumzCi6KPP
         G3rBw2WDOOOfFDlsa0cFdBolA5HQy3RtOG+EvMXdNu/hvItyW2ZYMlPI+G3EWZPfa3k1
         c1qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=FbWCjBYO;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id i13si10478450wrr.63.2019.04.26.09.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 09:23:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=FbWCjBYO;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44rK9T7388z9v0yn;
	Fri, 26 Apr 2019 18:23:25 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=FbWCjBYO; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id mcJUeQuy6hbo; Fri, 26 Apr 2019 18:23:25 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44rK9T60vLz9v0yk;
	Fri, 26 Apr 2019 18:23:25 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556295805; bh=QWHSqdkI9Y4fpXhoDPnLYy0SQ5zi1ORLMCcZL/nU9e4=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=FbWCjBYO6plAbzMD1/iUSWAUlPaclNyB+AAZRsOzUhbdAYwIQkpZvyjJnyxiim5/Z
	 EJgEgIrweW1QErrAKQ8HgfEc4oWrtLnwoC4hJ2OaP7pfWy7u1mZtB/sj4+sypsu+dF
	 Lwb5MdBuJvLlMtSmxD6DLlL3aYXDK5AFYgxTaZN8=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 78B5C8B950;
	Fri, 26 Apr 2019 18:23:27 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id Tw1tsHevBqia; Fri, 26 Apr 2019 18:23:27 +0200 (CEST)
Received: from po16846vm.idsi0.si.c-s.fr (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 5952C8B82F;
	Fri, 26 Apr 2019 18:23:27 +0200 (CEST)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id 4E0F2666FE; Fri, 26 Apr 2019 16:23:27 +0000 (UTC)
Message-Id: <75bf07ee77958ab06aba66a157b0c725a24af527.1556295460.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1556295459.git.christophe.leroy@c-s.fr>
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v11 03/13] powerpc: remove CONFIG_CMDLINE #ifdef mess
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Fri, 26 Apr 2019 16:23:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch makes CONFIG_CMDLINE defined at all time. It avoids
having to enclose related code inside #ifdef CONFIG_CMDLINE

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 arch/powerpc/Kconfig            | 6 +++---
 arch/powerpc/kernel/prom_init.c | 9 +++------
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 2d0be82c3061..a7c80f2b08b5 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -832,9 +832,9 @@ config CMDLINE_BOOL
 	bool "Default bootloader kernel arguments"
 
 config CMDLINE
-	string "Initial kernel command string"
-	depends on CMDLINE_BOOL
-	default "console=ttyS0,9600 console=tty0 root=/dev/sda2"
+	string "Initial kernel command string" if CMDLINE_BOOL
+	default "console=ttyS0,9600 console=tty0 root=/dev/sda2" if CMDLINE_BOOL
+	default ""
 	help
 	  On some platforms, there is currently no way for the boot loader to
 	  pass arguments to the kernel. For these platforms, you can supply
diff --git a/arch/powerpc/kernel/prom_init.c b/arch/powerpc/kernel/prom_init.c
index f33ff4163a51..ecf083c46bdb 100644
--- a/arch/powerpc/kernel/prom_init.c
+++ b/arch/powerpc/kernel/prom_init.c
@@ -631,17 +631,14 @@ static void __init early_cmdline_parse(void)
 	const char *opt;
 
 	char *p;
-	int l __maybe_unused = 0;
+	int l = 0;
 
 	prom_cmd_line[0] = 0;
 	p = prom_cmd_line;
 	if ((long)prom.chosen > 0)
 		l = prom_getprop(prom.chosen, "bootargs", p, COMMAND_LINE_SIZE-1);
-#ifdef CONFIG_CMDLINE
-	if (l <= 0 || p[0] == '\0') /* dbl check */
-		strlcpy(prom_cmd_line,
-			CONFIG_CMDLINE, sizeof(prom_cmd_line));
-#endif /* CONFIG_CMDLINE */
+	if (IS_ENABLED(CONFIG_CMDLINE_BOOL) && (l <= 0 || p[0] == '\0')) /* dbl check */
+		strlcpy(prom_cmd_line, CONFIG_CMDLINE, sizeof(prom_cmd_line));
 	prom_printf("command line: %s\n", prom_cmd_line);
 
 #ifdef CONFIG_PPC64
-- 
2.13.3

