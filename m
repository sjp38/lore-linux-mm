Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C1A6C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C743920818
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C743920818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D9958E00CC; Thu, 21 Feb 2019 18:51:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00D7B8E00B5; Thu, 21 Feb 2019 18:51:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E66E58E00CC; Thu, 21 Feb 2019 18:51:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F29B8E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:51:02 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id r9so334898pfb.13
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:51:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hQkTPFjoHK3661xQlHVp+31XY04uuglTGuhGFhn0F6E=;
        b=mR6TEWM2MVJXRRDczJqHDvFIhbGXFJ3l7l1kjC5cJTtR0GmxqhbOMilTKTRLwtLdyz
         BLpWsQ+5apSXej1VtU9fmgxnEYXLQp0FkYFK4RTZFnij63oHidE4z58ARKYH4rej6bbh
         k+acyq3nyVqXU29xsH3LrrqOdAhjeR4f8gRfo8FAUMl2956XxK9UVCwzcA4wcAolwzRx
         tn7ZppuuCYMaqHo2s/Mn914L7tq5bIL4yzJBbwAn9dc1pM3oa4mjjlvXtfsg3Qif1jUC
         ckrQgbzPqFELRLrg8VUUyhyYXC5TUzt1MJnClIZIavaJF3AqCSDbgJ4w/l3GQ2mlKxaD
         yV8Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZns1GfzuS/N5wVbNWbqf9SXBg1RjPbFdQzZrXYfzyGhajUfQCZ
	a2EMHdwfi1XAfLMNvp4XZgjpe7Qsd8/AJmOYS6FwpWQN2IPLIROwwfh4H8Ja0YrOD6cGNIl+Oll
	AOl4Cuc3cfg5/iBkKYFAr0qAn19ubbEAsz6l5JhZHAoTI4eQXIYtmENY2E3BGAPM+Iw==
X-Received: by 2002:a63:5b1f:: with SMTP id p31mr1107463pgb.56.1550793062309;
        Thu, 21 Feb 2019 15:51:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbsQu4L3cnlUlXL60gc/3X48ZYGQfx5SOQnlm4DR41RHTOIC3RswgNfDZ/t9DiRBB5IvH8J
X-Received: by 2002:a63:5b1f:: with SMTP id p31mr1107407pgb.56.1550793061190;
        Thu, 21 Feb 2019 15:51:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793061; cv=none;
        d=google.com; s=arc-20160816;
        b=h8K/h1cQ3wDqh2meH5Fg3G65y1WiUmCXmWDCCW3SrTGrIhhAVzaSc1iqzubgMJBjVq
         J5PnilR0Xk4OdaS6k6deZr+jUFt3XUk5rB35eyV8dr5N/c1TmuMKEe8ILgBNVIiEEkQZ
         UTxhM9D4+mysTxO9L9iYesLVXKlEudRVLptOGETcBqchS+kdil5CZ6Lgd/0obvLNKgJ8
         ExG8qHc0Mamap/MoXNmjFjSsBtbWQXQJSMke4m4RugcRER7WMYjkcXKFH32V+vs0e/YR
         As/yMNUFvAl3cRfdrKhL2rYSlNwEPXyEIqsmXWn/VsnneytdUxLwnvnPVw7W0+ANotlm
         Bi3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hQkTPFjoHK3661xQlHVp+31XY04uuglTGuhGFhn0F6E=;
        b=WbnsL/gUPcS0zFReJDo//9ffiw+Uxz4OX0kJnRybnbze9WR0RdNq8d53zPy5TnurB/
         Rq31OuLjatRRutyJjHOJc5JpTxpxEEYmZlasF1VvH093g/A4GBbtiuYCgjOw2iw8X/BC
         K5XURfo8Kwi3gPPBrBJVI623FI6bwkEIr5XXliuv+HSd2EskIf6e6h/Rp/wkZk2ii+05
         M58/evWxZv/puL6D+NpDhriS58N5uNkTBEMZ1XV1oEvHkIuEVmWZtXptry75r1mEr9u5
         JPqKYJ80S8MNuspvyg2h2SU2TjGQVjGZCc1bBLVJwuGRYKO8DsPOIqrO+IyAZjdb8hmV
         wo1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c4si238494pfn.83.2019.02.21.15.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:51:01 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:51:00 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="322394844"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by fmsmga005.fm.intel.com with ESMTP; 21 Feb 2019 15:50:59 -0800
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Borislav Petkov <bp@alien8.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
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
	Nadav Amit <namit@vmware.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 08/20] x86/ftrace: Set trampoline pages as executable
Date: Thu, 21 Feb 2019 15:44:39 -0800
Message-Id: <20190221234451.17632-9-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
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
index 8257a59704ae..13c8249b197f 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -742,6 +742,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	unsigned long end_offset;
 	unsigned long op_offset;
 	unsigned long offset;
+	unsigned long npages;
 	unsigned long size;
 	unsigned long retq;
 	unsigned long *ptr;
@@ -774,6 +775,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 		return 0;
 
 	*tramp_size = size + RET_SIZE + sizeof(void *);
+	npages = DIV_ROUND_UP(*tramp_size, PAGE_SIZE);
 
 	/* Copy ftrace_caller onto the trampoline memory */
 	ret = probe_kernel_read(trampoline, (void *)start_offset, size);
@@ -818,6 +820,12 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
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

