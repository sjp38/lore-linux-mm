Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C90EDC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E1772084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E1772084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 733AB6B026D; Fri, 26 Apr 2019 03:31:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 222B56B0270; Fri, 26 Apr 2019 03:31:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E13E36B0272; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D5FD6B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f7so1491715pgi.20
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=WkjX1OCtVjmmi3iE32HdXzI4HYBsQAWEqrRzLHows7E=;
        b=aAVmHcaL4FnJpCIukB/pmajJfo9YuB9C2awtEcLJQiRx96l7TFmmr8+MV86wiEK7Uh
         hA0IcKsx8u6F0VRocAJjKEo7wNz8A6jWk2lbEo7M5kZ74cGoy8tS9QvD8bZ0DT/Mo95a
         odIAKTgBhnk1KGjrGozw7Pg9sKc2DYxd9ZTMl9VUBHsIdUrLW6WpkCXkZ0GkIlW74Fx6
         3/HkrK9Vg0e1VPTihnRmjyKO9i/zivhN8Rwpm7DWc2sNRJqGxNKc1dpJVsLP681S7Pdl
         0/XyXMLs1Ze79cJZjhqTND847m+t17dcQ0QDh6hP8xj7najtRx1oos7d+cfHKu/TB8MT
         AURw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAXXrOF4Cx11O5daqtXPBDXAy7CQlyVbUw/Ij8DJi9XLTx+U9oeU
	NuFYcDV8+CxrylU0ao7p+eieYHCfos3EFNJHRPB8blj4ZLpn14pnIhZQk+vC22EuQEdcJLqTP0K
	7a0PgU7pAX47idNtpYfBNPDsEeyQqsErVKhb3YYFa+Tbw4F8oI8RhYEwiY89ObOh8mg==
X-Received: by 2002:a17:902:e485:: with SMTP id cj5mr18289706plb.280.1556263910238;
        Fri, 26 Apr 2019 00:31:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpVmEQl/UKcLGs+2eEo+5yHAua6cLZgh6mruoKJvgssQz5wIeP+GlQcuNN35pkBrE6I2EU
X-Received: by 2002:a17:902:e485:: with SMTP id cj5mr18289636plb.280.1556263909272;
        Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263909; cv=none;
        d=google.com; s=arc-20160816;
        b=ncakRD0gU7Wd6YFbSw810rwpJsAVmQTioFX6aKBv7cmIOxPcgss2mI5UbEREslsOMs
         J2NC874dVHEluouYKGEFSyNXzocl8LJDLqmPu4sVHj1NB35ViniRzJikjMQDuNms4i/2
         v5Kh7BahGwaTyp5fOPZ+fHHkkuTpsLWsjbgPSww08j87qiUhEzTBMw9RHqJtShKG6VyA
         bCMMgbwXX3vAmT9GY9DR0JoI5YVAHJshLkFzMISXQ2o05b8MMMwVcDSXAcaDITaWq+oS
         9fuDyH+xRO1K0SyohzyrowAm6OSJMRpFqLuIbx+AigAEIRgz+C5RWGN2QRr27tBEm0WV
         Wi6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=WkjX1OCtVjmmi3iE32HdXzI4HYBsQAWEqrRzLHows7E=;
        b=Lj1hj2UfMz5T45865ZwDRb2zNb71aLzmzhSBsySgEKeTtfDNPl88auy1/EvAkb3gaK
         SjVU6GyDpukoVXdSrxXztaO2fqnUEjc0VAKXs0EerimjJmzivUidwkbmqTnVScOXEEIv
         XdSZQrP09Nf1a+R++eyKK6E6o92fi3EEi8Mlc45YmtyyS1SKLaEXVr7MIh6dwrn/ef+C
         Ej/wSxL5OGl2s8fvizMS56Wre1Si+Iqb4m55HyPeyRiotn3KLVrRmLLfx7fHe56rCM0Z
         /pA2BTzEZrm7EDAgdjEb2ZLeONmZeoDpAwILZzXv850iyOSlv+/CX5niG3lEAaAX8dXS
         LYew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:45 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 2130D41225;
	Fri, 26 Apr 2019 00:31:46 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
CC: <linux-kernel@vger.kernel.org>, <x86@kernel.org>, <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, <linux_dti@icloud.com>,
	<linux-integrity@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<akpm@linux-foundation.org>, <kernel-hardening@lists.openwall.com>,
	<linux-mm@kvack.org>, <will.deacon@arm.com>, <ard.biesheuvel@linaro.org>,
	<kristen@linux.intel.com>, <deneen.t.dock@intel.com>, Rick Edgecombe
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>, Masami Hiramatsu
	<mhiramat@kernel.org>
Subject: [PATCH v5 21/23] x86/alternative: Comment about module removal races
Date: Thu, 25 Apr 2019 17:11:41 -0700
Message-ID: <20190426001143.4983-22-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a comment to clarify that users of text_poke() must ensure that
no races with module removal take place.

Cc: Masami Hiramatsu <mhiramat@kernel.org>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/alternative.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 18f959975ea0..7b9b49dfc05a 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -810,6 +810,11 @@ static void *__text_poke(void *addr, const void *opcode, size_t len)
  * It means the size must be writable atomically and the address must be aligned
  * in a way that permits an atomic write. It also makes sure we fit on a single
  * page.
+ *
+ * Note that the caller must ensure that if the modified code is part of a
+ * module, the module would not be removed during poking. This can be achieved
+ * by registering a module notifier, and ordering module removal and patching
+ * trough a mutex.
  */
 void *text_poke(void *addr, const void *opcode, size_t len)
 {
-- 
2.17.1

