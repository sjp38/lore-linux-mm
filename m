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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0541C4321A
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B32F208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 06:43:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JlRIHgbr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B32F208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C0936B0266; Sat, 27 Apr 2019 02:43:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1EDF6B0269; Sat, 27 Apr 2019 02:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCA876B026A; Sat, 27 Apr 2019 02:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90D316B0266
	for <linux-mm@kvack.org>; Sat, 27 Apr 2019 02:43:18 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x9so3264968pln.0
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 23:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=3mFI7V2IpbwOhuCcp+g9CO2dE2meFXsvyyAeb18NWyo=;
        b=HzkdLnvf/drcKvzh+rublwBArOc4U6uhMsNOYCjiAKme2ONCaFUVGphjmajMVsiKZf
         xYo2a7lUj++qoFyyZmwRKvlEV2tM2ACNfcqIfOQQ8sN7CTe9w8N8KP+z2AY3+HPLRx7l
         x19Vu1Xe5EANbtrVZrCotOCuhI90gpjL4yQfnzzW9fvH3VuTMowW/T02gwAREQ6HfcuY
         oGrz1DnbgOCexWpAxy2XKLNP/QSOHUMdiP/CgiUsIT4KuoAAhCvbC+v75tPYJ4vYQLZ+
         Q3ZpbaHU3Z0AxxyOyVXUzLH7U/9UkBbOicXFg066hc9Kzk4N+WhSnLJcPnGPk017m9ib
         rG0Q==
X-Gm-Message-State: APjAAAWCnJ/JQNTmC7Sj17xU8bKBY6JmToTPf4ms9JsuPdzV+/RFJhwM
	JJkZLT9AFiSN81zjxY+rBPJzX4IrSTTwh3oIbUwK0Xtty85qGxZm5hae3bJN5zoGICwjtPa527Z
	IBe0QgnkVRIJlR3PuvDeoW2K9yn+YmRypTW961lWcqUTRhIRIH83QYSxur5z09dDfXw==
X-Received: by 2002:a63:8e4b:: with SMTP id k72mr4659946pge.428.1556347398278;
        Fri, 26 Apr 2019 23:43:18 -0700 (PDT)
X-Received: by 2002:a63:8e4b:: with SMTP id k72mr4659902pge.428.1556347397318;
        Fri, 26 Apr 2019 23:43:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556347397; cv=none;
        d=google.com; s=arc-20160816;
        b=F9t8ZXxqXwBV5LOfJk/tPreS6QWkNeIaRSN3kNIs43qiwyPo7NWbS4au3VCWJhygXV
         etq4mJnKPShE5QFvCfATnzPMZ7Mg7/Y/RW55c11AWegsDc+EKVpvES2qpznRYySjfhci
         xSHfItVhqNVtNJZlFW48AkggropsHtVScvp8E4ZOjzvsQYOpZe1l8hh/M8JfeXPRPk/V
         9KftNNL8A69CTlJXeN+BmCOFzD9ut7n5LYw3aCKBXZpBSmZz3Ix1obVbvrgPQ4f2Z4/Y
         wVZS5GETf9LytGMdLecK0Er/Hzz9bhYCqDN/bEfn4SyfIQCg0RXWsPuLDdyLYCYTmo7V
         BE5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=3mFI7V2IpbwOhuCcp+g9CO2dE2meFXsvyyAeb18NWyo=;
        b=LBbDbUOWffF+8ioon5rkettulVH0oLvH/GFr8r+xiC6g+f1CAckL+GH6EHM8++aIzn
         NePPrvKKtxM6Gpe2z7B8unWeTui2ThQ8j49c9VmhlTmbjzKlL7xFRsSJS71eWs8exC0p
         Mev1rVoWPL7FRoEw3K7Qxd2htuBOl/QZPfKuLHrhz1UL5CEKlHR21GoWSbJnQg7uAURn
         z2EDVDZvXq3BGsreeLeViqe5Rm81viuEJtRmo30f0nvhQF/G+heBx5Vfnn/tDMY2m2Kx
         DgyJn2dz0Zxmz+UqS/KrjYg//4bd/VxziXbGqopE+W3vA06H8oXQt7EmbWpJfw9P49vp
         IpUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JlRIHgbr;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w10sor26281580plz.54.2019.04.26.23.43.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 23:43:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=JlRIHgbr;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=3mFI7V2IpbwOhuCcp+g9CO2dE2meFXsvyyAeb18NWyo=;
        b=JlRIHgbr6HB0GM/dfrBCsDnNLxTkOKzTB7qYCbAx4tDSjiPWdWErWZcgNMKz3646h4
         C8cKj9bZkmi6cPWikKj5uJAC7SrSg/qfrmI03cXhBRcOJHEMan3BYUSQ1ScXOsNa4u3Z
         IDQ4DfzWzmEsKN3rKTGM5uTvN695pUVNWWV4a8LMMvLzAhr7fWiHf2k7ZmkakgE11lMg
         wbrOSfmIb0CTjB/azGiS0/j+OjbriGytqXhtU6Bd27x2yAPLaWXYIt792EgmySvUAGOQ
         9VF/satnq8MCbRYyAQp+FRH27QsFCLaAp8PdnQobxJM8asT3n363jT4JX9FD5F/9ebkE
         0Uqg==
X-Google-Smtp-Source: APXvYqx2WhBZnJIn8mqH1b7ixt4GF/6k4yp110M4lMdf7eXq6Mz7eqmVNfTsfdPSyk5JMfubTGyIEQ==
X-Received: by 2002:a17:902:2927:: with SMTP id g36mr48053244plb.6.1556347396829;
        Fri, 26 Apr 2019 23:43:16 -0700 (PDT)
Received: from sc2-haas01-esx0118.eng.vmware.com ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id j22sm36460145pfn.129.2019.04.26.23.43.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 23:43:16 -0700 (PDT)
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
Subject: [PATCH v6 09/24] x86/kgdb: Avoid redundant comparison of patched code
Date: Fri, 26 Apr 2019 16:22:48 -0700
Message-Id: <20190426232303.28381-10-nadav.amit@gmail.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426232303.28381-1-nadav.amit@gmail.com>
References: <20190426232303.28381-1-nadav.amit@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

text_poke() already ensures that the written value is the correct one
and fails if that is not the case. There is no need for an additional
comparison. Remove it.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/kgdb.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/arch/x86/kernel/kgdb.c b/arch/x86/kernel/kgdb.c
index 2b203ee5b879..13b13311b792 100644
--- a/arch/x86/kernel/kgdb.c
+++ b/arch/x86/kernel/kgdb.c
@@ -747,7 +747,6 @@ void kgdb_arch_set_pc(struct pt_regs *regs, unsigned long ip)
 int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 {
 	int err;
-	char opc[BREAK_INSTR_SIZE];
 
 	bpt->type = BP_BREAKPOINT;
 	err = probe_kernel_read(bpt->saved_instr, (char *)bpt->bpt_addr,
@@ -766,11 +765,6 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 		return -EBUSY;
 	text_poke_kgdb((void *)bpt->bpt_addr, arch_kgdb_ops.gdb_bpt_instr,
 		       BREAK_INSTR_SIZE);
-	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
-	if (err)
-		return err;
-	if (memcmp(opc, arch_kgdb_ops.gdb_bpt_instr, BREAK_INSTR_SIZE))
-		return -EINVAL;
 	bpt->type = BP_POKE_BREAKPOINT;
 
 	return err;
@@ -778,9 +772,6 @@ int kgdb_arch_set_breakpoint(struct kgdb_bkpt *bpt)
 
 int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 {
-	int err;
-	char opc[BREAK_INSTR_SIZE];
-
 	if (bpt->type != BP_POKE_BREAKPOINT)
 		goto knl_write;
 	/*
@@ -791,10 +782,7 @@ int kgdb_arch_remove_breakpoint(struct kgdb_bkpt *bpt)
 		goto knl_write;
 	text_poke_kgdb((void *)bpt->bpt_addr, bpt->saved_instr,
 		       BREAK_INSTR_SIZE);
-	err = probe_kernel_read(opc, (char *)bpt->bpt_addr, BREAK_INSTR_SIZE);
-	if (err || memcmp(opc, bpt->saved_instr, BREAK_INSTR_SIZE))
-		goto knl_write;
-	return err;
+	return 0;
 
 knl_write:
 	return probe_kernel_write((char *)bpt->bpt_addr,
-- 
2.17.1

