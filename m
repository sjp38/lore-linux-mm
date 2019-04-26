Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DF40C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:33:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3CFC2084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:33:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3CFC2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D2B36B0289; Fri, 26 Apr 2019 03:33:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 804DB6B028B; Fri, 26 Apr 2019 03:33:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E47C6B028C; Fri, 26 Apr 2019 03:33:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 101466B028B
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:33:24 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id gn10so1422313plb.23
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:33:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=PQm9c3rdPLBXTcMKjbO2GS15ACOI1ILM5Qbwtu4lFBw=;
        b=Su0K+KneqvAgN0zSEc5aJQgpZhcjaHd6XKwH+acGKr5cbIxWb7gWdYSEnxt2QgifLS
         9QLG+15v4SaBx7TLGl36lm9r6+xY1Zpa1/BEopp6pzXlVrkkRxfV86zyz08cgsZsV0AM
         CuLL/rrjNNBnUkM6bz01nvuzQELUTIZ+LCyB+u83bZixxVoK+OsPj7LS0WG3yuAszq8f
         NGHjpOQQ2OUwudXjw/p6K9Nzwgms1e1auyDowrEaSYjOkqFX35SRHis3u+tiyhWT/TcM
         3lj9HCyQq8iji31OancL+aHZmrNqViwi2MEBjxkEJyF/oSH/cGICkbegrtftDoRaZRWc
         vyLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWHse0WMEHh22ZAsgn+nYh0F4T55dAJ/wxVDumnH5hBKJIrIwed
	Do0ucFFAn8lAN4x5OyJdP+f78oOA10E3TbMg0IfKWycL6UYaCzSRxPCsbacMx9XMyJqWZx5Kx9j
	aYIgUI6gUiN+Fq+P7l7xJ3OUtSyqFqM8p6UTts3WIuH/wIBFxMc34RkjbNSlPJv8Q4Q==
X-Received: by 2002:a63:fa46:: with SMTP id g6mr42574663pgk.382.1556264003706;
        Fri, 26 Apr 2019 00:33:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCB2ybfwR+m/jXvenxIHEBHDizQSKWN6uHx6/IBhJBeZTQQ9VuMecMMBDD//sO9rjPH5Db
X-Received: by 2002:a63:fa46:: with SMTP id g6mr42567682pgk.382.1556263907475;
        Fri, 26 Apr 2019 00:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263907; cv=none;
        d=google.com; s=arc-20160816;
        b=PxwtttOIZDgbVfPxiwNCMfVH1MifF4TW/Pcfi0qy7HgorUCcp1rnUSteSiklJ9REqR
         i9UQcFeI4XiHvmAzh6I9v8tLcgPiMMhXxtEllXsdKdlTx4mQHbXX8Pm30rbnB/7Fu365
         cibnlmh1U3I0vT/HvIDIZ+Y/lF3/WwJlAXBmyhtAbiJUgCr66uKbV0JESTNX7vlUUCDD
         ePIbdYNoH4BG9yxr6NFsWeltqbz7qmQJzyez60AlDrYwd1zTtT7/2jgdUeSDvEcIlL+c
         Rx1InGJ4PxvjRSpbgmr+z9S6NORHTGzrqbMEvi/CjCNY6U6AwT1XbERZHRQcNFk2gIvM
         lHmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=PQm9c3rdPLBXTcMKjbO2GS15ACOI1ILM5Qbwtu4lFBw=;
        b=o7hVE8cZZofekeDKLJhpQbkXOAINWrEarl9JoN5wEqSRSbho3Z4cPoMmurq08ptH/i
         o5djp4FcdGsQFVXYBdz2mzm3o/P+hnH/TeYEd1gkXKa9maL0KESeTArpwAHUiOH5248G
         A/WFcZsPtfBuqeSb3y74zwnqPXkuZprXP0Ii/nCs9nkF+5yJzR2FAey9lkz7ht+rAyr6
         BHb8aMZvRo+HlM2ds5RKP9GS8gh86YhM25/YICqoWqeagJHznof2qgzXyxfkQ3iq8PZU
         z0f21tVyrLred5+YuiEJQFeIiv80+ebArgG9TFL7UiW9tKWifUXNb/yt69WR6IDGHh8C
         x/UA==
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
 15.0.1156.6; Fri, 26 Apr 2019 00:31:41 -0700
Received: from sc2-haas01-esx0118.eng.vmware.com (sc2-haas01-esx0118.eng.vmware.com [10.172.44.118])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 296F2412A3;
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
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>
Subject: [PATCH v5 22/23] mm/tlb: Provide default nmi_uaccess_okay()
Date: Thu, 25 Apr 2019 17:11:42 -0700
Message-ID: <20190426001143.4983-23-namit@vmware.com>
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

x86 has an nmi_uaccess_okay(), but other architectures do not.
Arch-independent code might need to know whether access to user
addresses is ok in an NMI context or in other code whose execution
context is unknown.  Specifically, this function is needed for
bpf_probe_write_user().

Add a default implementation of nmi_uaccess_okay() for architectures
that do not have such a function.

Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/tlbflush.h | 2 ++
 include/asm-generic/tlb.h       | 9 +++++++++
 2 files changed, 11 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 90926e8dd1f8..dee375831962 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -274,6 +274,8 @@ static inline bool nmi_uaccess_okay(void)
 	return true;
 }
 
+#define nmi_uaccess_okay nmi_uaccess_okay
+
 /* Initialize cr4 shadow for this CPU. */
 static inline void cr4_init_shadow(void)
 {
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index b9edc7608d90..480e5b2a5748 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -21,6 +21,15 @@
 #include <asm/tlbflush.h>
 #include <asm/cacheflush.h>
 
+/*
+ * Blindly accessing user memory from NMI context can be dangerous
+ * if we're in the middle of switching the current user task or switching
+ * the loaded mm.
+ */
+#ifndef nmi_uaccess_okay
+# define nmi_uaccess_okay() true
+#endif
+
 #ifdef CONFIG_MMU
 
 /*
-- 
2.17.1

