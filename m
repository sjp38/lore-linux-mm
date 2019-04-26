Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD50C4321B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB37A208CA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 07:32:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB37A208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 956EF6B0270; Fri, 26 Apr 2019 03:31:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 637CB6B0274; Fri, 26 Apr 2019 03:31:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D6B06B026D; Fri, 26 Apr 2019 03:31:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E43BF6B0007
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 03:31:50 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d10so1438209plo.12
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:31:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=64HAp1aiSsnJ+6SwHGBfPAaWomfs1X7LEUQ04wa1/ZY=;
        b=qLMtvlIF8QiRmEHMUS97VypPqUP2v444LE+I5rwEkUVy1+vw1Hp2F2sLMBsxkO9F7v
         0KnJ+2BpAZwTWYudT7m3XTx3Mgu//O7VvNFh+gUexi5bek/jU80qlkVoF/Odr6R8alam
         EDZ9hJZRY7AAYbKjK/u75RiCA0in7OZRI9njl9ZRtlP/pQvA6F9cJ/bKGxgW6k5yp6cp
         pvaQsv2RAlkwM771nm5MzNbgaEihP5mTMoz1xXQq1ut+wuLoyBC3vNZulSpY/ZOtWKNM
         NRjm9i8nHOFlaSzphTX9QpHjxgnIyT5jtMSb4WKAH3OCKE6lEN92S6GwmdZaRzJUhphZ
         EDFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of namit@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=namit@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAWHlIzXZ+c3CTmne0010LsbLVIo61F2ZoE5C6HS40bCxHfuY+zD
	ZHSdmxPeBx5KEYH1HoI/9Ywgjc5zsiFDCUg/TR0s8eQ8EziybFDQGhBF0KhvI+eJ6VXfODTzfNp
	zr7hkaR6Q6oZyv1lWeI4drIvi1cA2sZUHvnORj8mceAMcIkfUFiF2AHdsWDaQMU4myw==
X-Received: by 2002:a62:5795:: with SMTP id i21mr16806404pfj.194.1556263910592;
        Fri, 26 Apr 2019 00:31:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWH0t2lD8SJ7EkhKEPHEGLzJJYN3l7Q7NVVVBogB6TDePfI3NsPkmf6t95aH5LQdx8Bmwz
X-Received: by 2002:a62:5795:: with SMTP id i21mr16806318pfj.194.1556263909468;
        Fri, 26 Apr 2019 00:31:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556263909; cv=none;
        d=google.com; s=arc-20160816;
        b=ui3b8z+dFWiGS78CYJ2vM6gyUuQMi8XwRLYQTDqFALe2GwTWHKACF9IfbKMJQjSHM9
         n0gn5CB/XerE4A3CRUWB15rsOYYMIxoUjTP3nB7arV48FVRzKnpN9SKv99AEwFqxzcmm
         6wEMd9U/zcUB2/p3jDsV8D0CiLTPnMpJAPJJ7U22dIFsPzOEYEVKTxCBh570KRMK8uFI
         002GUzPqZims0j9XUGKcWVwXvDn5F1FpTKljJJCA0Qq2hLSxCrSVTj0j16tlx7zlKNSi
         DPEUhPfDg2aqcrltZOIUy2EJj+nYov95e/L/H+isuFN4rHnkcu675a+i42cbeVnK+vHJ
         4QZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=64HAp1aiSsnJ+6SwHGBfPAaWomfs1X7LEUQ04wa1/ZY=;
        b=Ab8BruFXUGNliAQZmJyqotoBe8ha4jOrYZIZxQqVODzN/qVSIOfABSwKtKGMHHrbjB
         oX60sAuCY6ba9zwTjx0va+oWG/D6GoFyIicq09oydri7rbD8zV0OoKl1fhHQWAjttTgI
         XfiD1Z4OejZQMGn0ggFEd5ogsi4aUZG+mIZ3Jdp9OPv+bb5UA18RMahF44baUhnfxpO0
         dNawx5/ZFfNIK3+XnpDoURkl253iovBwBTZ97dWyR9f56Pkwi4LGEIZt1Hk+4rY9KPqz
         PaADorcJjQyeMnn0ohZuBRll6KLVIR1Q7gSt46eL/fOCFZiTgaWypdaQNd/R1HEsmKfU
         u5Og==
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
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 32C2B4129A;
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
	<rick.p.edgecombe@intel.com>, Nadav Amit <namit@vmware.com>, Daniel Borkmann
	<daniel@iogearbox.net>, Alexei Starovoitov <ast@kernel.org>
Subject: [PATCH v5 23/23] bpf: Fail bpf_probe_write_user() while mm is switched
Date: Thu, 25 Apr 2019 17:11:43 -0700
Message-ID: <20190426001143.4983-24-namit@vmware.com>
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

