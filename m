Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A6E8C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DCDF2084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DCDF2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21F636B0271; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF7B16B026C; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA23E6B026D; Fri, 26 Apr 2019 03:31:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E624E6B026B
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id s26so1646146pfm.18
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=RIE66crRSFais2XMEreovT7cuc4aWzwk2c6XjFrsy1k=;
        b=sO3PEOEu0zMwHfobvo/GIOgY/Kfk2z+Gp/Lfh3htVxppUgAFLdUbN9d3homGNR55Yo
         m+qar2aZJMPtyMgRwS+h+3zQMC/r9PppdpIGW4+Km/eRoG7LecnfkyAD06/k/4lG9FRS
         g+1wmZYWGQgMW91VLC1h3XBbHkaZLi4YGoIvcbj+FkKPybB8Ofy+bZnpW0uWUe0Qhu53
         p8Qi4amuQzmGP9CViUnPOGZBFNZC+lbBX2XqWnDd5zy7vjUo1D8R4L/qEi0O1mvLtlaE
         z1nZLIMIIlC1i+KjzLcZv8gbR+5UqUEOB/V8mbGjP+4ADVu2VESOd+G+nHfEEl1djtI3
         mX9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVEctG1BSO00Hrm4yq7QPVgqJGkYN1Z6SGmPgeHlK4Gv8jkGCbE
	lHR97GDbWKZbOMQy5l5DUHHV4D7XlMxPo38Bk17tNesIY5eP+Mz4VU7On+b5IrqycSXVoQK2Po+
	HcBeEUnKl/LU147OAmhKCICb8mRHQX8pgZ0y/pp9L/OwP7zB53ZTmrva0rfHVEscDAg==
X-Received: by 2002:a63:f448:: with SMTP id p8mr42207797pgk.50.1556263908581;
        Fri, 26 Apr 2019 00:31:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzu3cjqKi8CgTRqqdft5ubUUxrPPTBrYsfd49GmA87QBn6VwaEMmwqMG5P28PH8Be5k02dN
X-Received: by 2002:a63:f448:: with SMTP id p8mr42207710pgk.50.1556263907273;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263907; cv=none;
        d=google.com; s=arc-20160816;
        b=b7MMLCn1I8omPuvRsqzkP/x6g9OXst7Z28rdl+ghF4+ONBhPVl6Kys9w5tXTjjAzDP
         5SRkbSiwM2/GIPjAo5pYm5/Hj4nwE3x4XW7uwZyANgcOCv3s84sqesRgbveEDm0lRztr
         IqdzjbRl0BqeMlE5VUP83siR2wTjlJGHNHGJgCZJtgSu1+tFk/nIyeAkXpFKFp/aowrz
         TBH9UrD0Brfs7HWrrEMQy0KJCrP4nNIMHEcdoLLKUm7tzdpMdx28ibpJk2MPW6nXAwqm
         y8y9Sa3skXNw0K0gsFieGXyZ0sbI40YtgJgqBGSIFlzvla+nMdgpigLv+HAmK/JSIskO
         ZPtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=RIE66crRSFais2XMEreovT7cuc4aWzwk2c6XjFrsy1k=;
        b=WMuWdgzpFtSZg+UDbkmfLIreLp1Yg+M+BZ/uGB2kbnN9rR+t/z+bbLSwXCIfYYFj5F
         msMBzYnAFm0TSDCATsueOToIamV4bFGUlcVNCEj2EdRr/mI7wxbCTtY1Tc3zLsge4VPx
         Sx+v0R0RBvzL2VBdpkk2af49Jf6dpBM/p51DipXXpOXuNI8YFjzrLBpyFyi6A90Ptznq
         ldjQbPYwO067cldw7B1gdmf/X5sJUzm1VUZZ/39uhjZ/l47DiOXhKzP29n1cZAyQGrkR
         ohOyjFi73DWcYK5CCDln3/uqUGlX0OulSW7cULn4ZdUfr3ssA2sCjjVP/UkTCYPwfKIR
         sb8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id v82si25417769pfa.42.2019.04.26.00.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 26 Apr 2019 00:31:40 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 1086741299;
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
	<rick.p.edgecombe@intel.com>
Subject: [PATCH v5 19/23] x86/ftrace: Use vmalloc special flag
Date: Thu, 25 Apr 2019 17:11:39 -0700
Message-ID: <20190426001143.4983-20-namit@vmware.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190426001143.4983-1-namit@vmware.com>
References: <20190426001143.4983-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: namit@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Rick Edgecombe <rick.p.edgecombe@intel.com>

Use new flag VM_FLUSH_RESET_PERMS for handling freeing of special
permissioned memory in vmalloc and remove places where memory was set NX
and RW before freeing which is no longer needed.

Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Tested-by: Steven Rostedt (VMware) <rostedt@goodmis.org>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index 53ba1aa3a01f..0caf8122d680 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -678,12 +678,8 @@ static inline void *alloc_tramp(unsigned long size)
 {
 	return module_alloc(size);
 }
-static inline void tramp_free(void *tramp, int size)
+static inline void tramp_free(void *tramp)
 {
-	int npages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-
-	set_memory_nx((unsigned long)tramp, npages);
-	set_memory_rw((unsigned long)tramp, npages);
 	module_memfree(tramp);
 }
 #else
@@ -692,7 +688,7 @@ static inline void *alloc_tramp(unsigned long size)
 {
 	return NULL;
 }
-static inline void tramp_free(void *tramp, int size) { }
+static inline void tramp_free(void *tramp) { }
 #endif
 
 /* Defined as markers to the end of the ftrace default trampolines */
@@ -808,6 +804,8 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	/* ALLOC_TRAMP flags lets us know we created it */
 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
 
+	set_vm_flush_reset_perms(trampoline);
+
 	/*
 	 * Module allocation needs to be completed by making the page
 	 * executable. The page is still writable, which is a security hazard,
@@ -816,7 +814,7 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	set_memory_x((unsigned long)trampoline, npages);
 	return (unsigned long)trampoline;
 fail:
-	tramp_free(trampoline, *tramp_size);
+	tramp_free(trampoline);
 	return 0;
 }
 
@@ -947,7 +945,7 @@ void arch_ftrace_trampoline_free(struct ftrace_ops *ops)
 	if (!ops || !(ops->flags & FTRACE_OPS_FL_ALLOC_TRAMP))
 		return;
 
-	tramp_free((void *)ops->trampoline, ops->trampoline_size);
+	tramp_free((void *)ops->trampoline);
 	ops->trampoline = 0;
 }
 
-- 
2.17.1

