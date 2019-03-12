Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D8A6C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DC19213A2
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 22:16:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="KQLanF/4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DC19213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 817658E0007; Tue, 12 Mar 2019 18:16:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 772AC8E0003; Tue, 12 Mar 2019 18:16:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F0AC8E0007; Tue, 12 Mar 2019 18:16:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED0358E0003
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:16:12 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id h65so1591176wrh.16
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:16:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:in-reply-to:references
         :from:subject:to:cc:date;
        bh=WruMu/BwAMo8I9a3LF55jCSVvG/Tocg3gOnV17/tBYE=;
        b=sVpAELHcLqDu9tOoSwT9uTgu2y2XWqvfafrSBm7lnOCi1yXmt6KUcxGEQz3UnJF9df
         cuGH/SozQ6YvUibgxF2I/Cr3PhHXcvBzB4L7CFye9oqlHyBA9nINo0FU6xfWgY4Z+atU
         uXIMJnXdQD6eYTbwCVBtZW5Vn2QrZ0/6c3hpkGGWzwdxaf33GavjJkuZ9Ygyr1eem+Wm
         3HGOQud7xa3k5UD3CAtEZRkU7MQu0XAIolxNyIc4SY0YDN9QxBJFAnSmrdJboDxx+U0+
         re5FYPrG0bimtBzaPobintiPxZkjZMvOGth6Up7pQuKJhZRFG4fAxSlklOiVl0UckflC
         P8VA==
X-Gm-Message-State: APjAAAXhgZag/Za4eFBRLzQaYgDJpzOo1DdcpfK21fIo4pXV6GKKBxtF
	68PPaMmrF0l/c4EicIwioczK+mVO8YzuuvGugElpZJ2KLpID2PT6XVDFRfOEljxF353QW1Ei6vP
	oUEEMAcdtsMozkrzdlcNZNWXTf60q95ukWJTHfS9DxBaw2/JIypvk0JJ8wIRixC4THQ==
X-Received: by 2002:a7b:c08b:: with SMTP id r11mr10059wmh.133.1552428972200;
        Tue, 12 Mar 2019 15:16:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOQjn/mnmCqzgRa4NQ8J72FmOun0p1xDsIah4PT7On+JBidTpQEHSYIwunQvfmpWvzk9OB
X-Received: by 2002:a7b:c08b:: with SMTP id r11mr10029wmh.133.1552428970892;
        Tue, 12 Mar 2019 15:16:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552428970; cv=none;
        d=google.com; s=arc-20160816;
        b=RQHGub80wPmUiTc/EmdbadeQGnj3kciKnZXZnfycHMFcFtPorLy1kMX2J1N/33oLmZ
         mKSKUwpLuqkAmApQrGSo1HpePPYYZ8nuS2zewiRoFTgPlPMvcDKMRqnVjL3PIgfpDBMD
         iBEVU4fA6Fxz4umOGw3e1PROUG4EOia/iQpcggi8yb65/Ab/brUAhhYv+nfIw8Xw2uSX
         aQJ2SnUfRPnPQq3XkDO+1gZaZ9Gh79EiDSXWSz7mj6aBK6poj0NwLFqufGulw3xPXEz7
         uoa0EqWlRDmuxO1aAZni4BkDIFvAief5ABhrFWg2ltaDzxGKFxWZljtdqFJEC936EOSl
         JLQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=date:cc:to:subject:from:references:in-reply-to:message-id
         :dkim-signature;
        bh=WruMu/BwAMo8I9a3LF55jCSVvG/Tocg3gOnV17/tBYE=;
        b=LR1+pYaxr9RjWG7PHmHNNp3PrFugT/+9o9xZuNbfoaD2idt1XqrfwPv2/Fn2PEhRU4
         DuTDrbHXjs5rJEqXDaaw3fjXvZ2Inb1Fag0DSmkIzOn0nFxdVrCYOjbDbUQ3WNB4QYNg
         kEfhodCwOHqeExPt+KoT+buyNayee9a2EEyNHMfkk9R04bOftmF+m0mYd7jIaV8CD4Nw
         IcZAagyUGMZSG90NxwPWU9bHTj22EHr0AKP9d9NLhg82s/WH0yH0tGuxc5gbKLivUh6s
         sGTmb2EPt1fRJ9WV6B1bHKq3S1xYBJul96z++DCM95SH0CX2WEwA3kylKtBWbTW5lDEp
         REHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="KQLanF/4";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id d9si6261011wrn.274.2019.03.12.15.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 15:16:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b="KQLanF/4";
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44Jq7G0syJzB09ZJ;
	Tue, 12 Mar 2019 23:16:10 +0100 (CET)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=KQLanF/4; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id qEKF0zGnhklk; Tue, 12 Mar 2019 23:16:10 +0100 (CET)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44Jq7F6XsPzB09ZG;
	Tue, 12 Mar 2019 23:16:09 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1552428969; bh=WruMu/BwAMo8I9a3LF55jCSVvG/Tocg3gOnV17/tBYE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=KQLanF/4dftXRqC6GCD0M0L1NDv7Tk3uwmOLHYfcMbzeC+NVftLENFHGm877fbTEE
	 IqUJ0eJji/7Ty9h8hcq5o7AKByQwIgnGz7GlXQDYuo0WJNsnh7JvHOi3x3QBcfrO/f
	 4Tu4y32RrhY61drJqkgYuM6v7mtP3CrHTGS+Yi7M=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 1F0638B8B1;
	Tue, 12 Mar 2019 23:16:10 +0100 (CET)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id jEDvnohJtjOg; Tue, 12 Mar 2019 23:16:10 +0100 (CET)
Received: from po16846vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id E58B48B8A7;
	Tue, 12 Mar 2019 23:16:09 +0100 (CET)
Received: by po16846vm.idsi0.si.c-s.fr (Postfix, from userid 0)
	id B3CFA6FA15; Tue, 12 Mar 2019 22:16:09 +0000 (UTC)
Message-Id: <09fc2bc930197987745b937b3817b2563b0a42ab.1552428161.git.christophe.leroy@c-s.fr>
In-Reply-To: <cover.1552428161.git.christophe.leroy@c-s.fr>
References: <cover.1552428161.git.christophe.leroy@c-s.fr>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v10 04/18] powerpc: remove CONFIG_CMDLINE #ifdef mess
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Nicholas Piggin <npiggin@gmail.com>, Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Daniel Axtens <dja@axtens.net>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, kasan-dev@googlegroups.com, linux-mm@kvack.org
Date: Tue, 12 Mar 2019 22:16:09 +0000 (UTC)
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
index b5dce13a6132..facaa6ba0d2a 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -833,9 +833,9 @@ config CMDLINE_BOOL
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

