Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BF96C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBC342084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:33:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBC342084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71E1D6B028E; Fri, 26 Apr 2019 03:33:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A33F6B028F; Fri, 26 Apr 2019 03:33:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 546C36B0290; Fri, 26 Apr 2019 03:33:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 138EE6B028E
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:33:51 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s19so1455964plp.6
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:33:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=/dQyv1Uey2RUfadDTtULdd0YvB0m8yojiZj6sZU6y84=;
        b=J7L32BQ9CODFxE5CNXUT9jvgawizkQTbf/U0qcRk/XUQsZH+taUBHPgIYoudFzOXW8
         Or4puIEvzJuSey6kEOPl944NJyaHcjJQYyquyPGfqA9cq6tCoKPjwqIvyBkbpTAi77Kx
         NKtKKxIZO+af3nFvA16/PITMLExmJGouMYzZOPpENn4Q29eA0xjcesEZrQiZxKILZPH6
         6LmX4+omQoTLslO0ufSY1NsVWM3SFUCNhy47o/kUFKHDyNR0hLNpZSN6EEltCfHYwXtk
         ZParJBj8RXooeVSFuOtlrFddIAs38VvMErvnkc9crvIU/TwIhooGuVgHG2DSscfzd1Vw
         eoCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVmqx9h/aT6DXExjnzn1oB9w1BikGmOSzGwjAAgpq2+TcCwgPbJ
	bPoUzEd/7ItbUDEqGNAlErDOPGAOZhbrUKbsqjI6ayNvxO9MRxdaPD/Uw1j6nIDkMPGuDDyHvG3
	2LhuLt0SJH9MwcC+u/YboIbR1k5YAUAyvrT9pIbFWcgxHWxE0k7mtJuol6DMzyCnKDQ==
X-Received: by 2002:aa7:9f49:: with SMTP id h9mr20191985pfr.173.1556264030747;
        Fri, 26 Apr 2019 00:33:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBh4afjxHQXL1ygESEfnhx5TzwyAbxhbgQuaYE28noD0rCnWjO1VeB2q+9ITSoQ/2TxXZg
X-Received: by 2002:aa7:9f49:: with SMTP id h9mr20183121pfr.173.1556263907157;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263907; cv=none;
        d=google.com; s=arc-20160816;
        b=pJXQVspMVXqWiELxk/FL7J5YpqkrolCbZpCBQcI3On6lFue9L2TxqMw+nIxkWy37dh
         ChU52bpQq8J3jW6q6l4g0nLZxsbcPzS0t2reqCxCp/UmY060nBjqE9B3C2Bry3JpTUJZ
         t8hOfOcF4F6dxhvd+19cTj18uAtUnbukwKCLOgvWxomEoW2LE9Et2IMn1CpzLSHhsadc
         zcOt5aZhp/79YaSQ2uI7aaFmagb8Tw/nNZtCLvm3jQuxTYX6L+2nPmdWb8Voy0QFk443
         ZWzI3Fov8tVLei3XoC0ix5FFi0js7f2ymozmILvgiUZVWMHfZ4xaYNgd3RWfilo/NAPw
         9Ujw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=/dQyv1Uey2RUfadDTtULdd0YvB0m8yojiZj6sZU6y84=;
        b=AiWPWp5w3Nl1CuapYsuFAg2Tp5wmNmE5Ilzv+lyzCL3Dyn/YwM4Gr2G9S8Nn0y680G
         yTMQN2FIZ8mctVpL/FQtle6gNI71e7QQOGPhWkkAkmhoLC72m73HW0894Uxtka0xMZW4
         vmXTRSywgbrQjQuYnXcm/4601mGfuCXtey5KJ4K597Q2m1yYjtqt+NMGBC0/vfPBpY7E
         koIS3JDxFxIweT90vmnuR10ScBuRr8Ma/gps61J0wDAcfE68LAojPLUoZtI8ir1Kr5IC
         AlHYq+y1O/TNjVy4GnVvx3d6c4EU682ap4WJehWIf1JqCAyAfQDwifEEgVn81dwhlEH2
         2iCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id f9si22844507pgq.347.2019.04.26.00.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:44 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id AA61841299;
	Fri, 26 Apr 2019 00:31:45 -0700 (PDT)
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
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 09/23] x86/ftrace: Set trampoline pages as executable
Date: Thu, 25 Apr 2019 17:11:29 -0700
Message-ID: <20190426001143.4983-10-namit@vmware.com>
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

