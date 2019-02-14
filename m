Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67B3EC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15F0C222A4
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:42:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15F0C222A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F2778E0003; Thu, 14 Feb 2019 05:42:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A11B8E0004; Thu, 14 Feb 2019 05:42:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61BE18E0003; Thu, 14 Feb 2019 05:42:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0306F8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:42:46 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m25so2286389edp.22
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:42:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=unNMsV12tL80oKyx5Trd2XJzSyu0F4NB8jKTV2bBJy8=;
        b=N73pLRYjASceJBIOfNHL8H3fJ/A1ErbFpPtP0jRmf6pCnF+KD1kQ3m4ljXGNEoBlUk
         3k1kfmohvHs7LEHyXbiLhSj45vmLchCsylhCSzKYEF1JsrLpminLUV760vk1nsHxTM7k
         XcWIxFE+nPbOpteTRWBAN3EOXvUjMIUMRAFbMYCK8cC/skfCCiJY6zizJN+D5QQEBwR9
         Lt7VoHDPRxTKNRO8a1SuhKDQdk8nlJK4x9PFfIzlmIbfXv49z5o/xYnWdtZ5wiBEXFXd
         IfapyoC7KmV9/WHN+k4EWmlIuMTMeSYVzHksNUhuEYW3LTHCpKOrK7C8NnH8+RGME0Be
         7eXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: AHQUAuY1auprsojYBeJYWlD66O3ffIFj3D2tKxtzBiKX2ou8cqGPjwDl
	D6NMnfhUs4htMdm3yEQSry57jvFxrxwnHM4OSezSZg0st+K9gigP9rNynkmfIjoIFKgBnP/xLGE
	uza2Z/o9+T17VkdDw6fCJyMD8K78pH7FRxjkgdjfWwAuEucdTQpAQU7TmBLp3rCkvWA==
X-Received: by 2002:a50:e007:: with SMTP id e7mr2623776edl.10.1550140965480;
        Thu, 14 Feb 2019 02:42:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibfekn9tdUl0T2UxEaUlzzDrh/dUDi9CvWtSjqd1K3n49Siq4dO+db4Ut9Z4SBnsKRz5L5U
X-Received: by 2002:a50:e007:: with SMTP id e7mr2623721edl.10.1550140964329;
        Thu, 14 Feb 2019 02:42:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550140964; cv=none;
        d=google.com; s=arc-20160816;
        b=abCGjrucCTpT0YU402feT+OHy+gcwiBOOFa68gi8nQWb6izM5GulZUI1l/cIg8AV3m
         sVsLbPapBsCC8JAQnhCwQVhDhaVOwrjI42zsG3g3kS6jqb4jaCCkfCwhVS7zQ7wPniS7
         yXipaF94SB0CoIZHiFpU14E2dGA3VroLxCBiqFqRAV7nIWG2YTo8oBfg4cHu8Bskd4WX
         0T/Y271ulAP8uLGapRA7CDSV1dF2Azd+6XAogt8ON0yXRCi796lIAFXQdqxmIXKWuknV
         cV3PuqQnj+/Po5csDlzeWzeyBKiu8w+mKRwrNCfjBThnksBnG/B5G/k1T03G1DvZY+rI
         fT7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=unNMsV12tL80oKyx5Trd2XJzSyu0F4NB8jKTV2bBJy8=;
        b=WCc3rtYVDKbWe3V7JoiQKPCQ8TkLn4MjokRPlNEQJ9XQtVT9rTCYQI+UL9btXCAQlH
         uqsyI9lhRjw1DXzaneplN1uvKFaOW40ISHcJK4JsCgO7D+aGr/GTMzjk28f3o0c2WI1Y
         98gJZy0s2uv9eo/OigT6ARQuPJZwNlndFdwEeRd5k5RlWngmmEdFjV3Soc2XFjJ+zWJl
         Ut5z44/oIVUklUB/jajr5acao9kz9bRzJdTStA3q+YqTlHqN813NelbAlHGgI9Fe/zh3
         vBv79KWC31P8AX2gyFZoAv+kqQN5DKMpZZWxI00FMc2APRs2/+/xKDk96p+Ng+kDILxR
         B49w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l19si287800edr.195.2019.02.14.02.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:42:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E7FA7B0BA;
	Thu, 14 Feb 2019 10:42:43 +0000 (UTC)
From: Juergen Gross <jgross@suse.com>
To: linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	x86@kernel.org,
	linux-mm@kvack.org
Cc: boris.ostrovsky@oracle.com,
	sstabellini@kernel.org,
	hpa@zytor.com,
	tglx@linutronix.de,
	mingo@redhat.com,
	bp@alien8.de,
	Juergen Gross <jgross@suse.com>
Subject: [PATCH v3 1/2] x86: respect memory size limiting via mem= parameter
Date: Thu, 14 Feb 2019 11:42:39 +0100
Message-Id: <20190214104240.24428-2-jgross@suse.com>
X-Mailer: git-send-email 2.16.4
In-Reply-To: <20190214104240.24428-1-jgross@suse.com>
References: <20190214104240.24428-1-jgross@suse.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When limiting memory size via kernel parameter "mem=" this should be
respected even in case of memory made accessible via a PCI card.

Today this kind of memory won't be made usable in initial memory
setup as the memory won't be visible in E820 map, but it might be
added when adding PCI devices due to corresponding ACPI table entries.

Not respecting "mem=" can be corrected by adding a global max_mem_size
variable set by parse_memopt() which will result in rejecting adding
memory areas resulting in a memory size above the allowed limit.

Signed-off-by: Juergen Gross <jgross@suse.com>
Acked-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/e820.c         | 5 +++++
 include/linux/memory_hotplug.h | 2 ++
 mm/memory_hotplug.c            | 6 ++++++
 3 files changed, 13 insertions(+)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index 50895c2f937d..e67513e2cbbb 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -14,6 +14,7 @@
 #include <linux/acpi.h>
 #include <linux/firmware-map.h>
 #include <linux/sort.h>
+#include <linux/memory_hotplug.h>
 
 #include <asm/e820/api.h>
 #include <asm/setup.h>
@@ -881,6 +882,10 @@ static int __init parse_memopt(char *p)
 
 	e820__range_remove(mem_size, ULLONG_MAX - mem_size, E820_TYPE_RAM, 1);
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+	max_mem_size = mem_size;
+#endif
+
 	return 0;
 }
 early_param("mem", parse_memopt);
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 368267c1b71b..cfd12078172a 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -100,6 +100,8 @@ extern void __online_page_free(struct page *page);
 
 extern int try_online_node(int nid);
 
+extern u64 max_mem_size;
+
 extern bool memhp_auto_online;
 /* If movable_node boot option specified */
 extern bool movable_node_enabled;
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 124e794867c5..519f9db063ff 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -96,10 +96,16 @@ void mem_hotplug_done(void)
 	cpus_read_unlock();
 }
 
+u64 max_mem_size = U64_MAX;
+
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
 	struct resource *res, *conflict;
+
+	if (start + size > max_mem_size)
+		return ERR_PTR(-E2BIG);
+
 	res = kzalloc(sizeof(struct resource), GFP_KERNEL);
 	if (!res)
 		return ERR_PTR(-ENOMEM);
-- 
2.16.4

