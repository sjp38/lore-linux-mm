Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14FEBC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:02:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA1542083D
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 11:02:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA1542083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FD2F6B026B; Mon, 15 Jul 2019 07:02:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4B03B6B026E; Mon, 15 Jul 2019 07:02:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C8626B026B; Mon, 15 Jul 2019 07:02:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC646B026C
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 07:02:25 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b14so8723902wrn.8
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:02:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=VDmH1/btnNfyQokX30yDSfOXwgboL6oOf5YsWu008K0=;
        b=PLjzyf5rKMkPSIX+R0BnRNCS0EEE7NmeWHj1yH+/mz+LJw4qXZ8x65adIeslDYq1/r
         ySw9/z7XdMb62ibgyCPGmptyTh5vwZ2ySDHiizo14xwtudvN2lO1tWut0y16nOj/xCKX
         oixvKslA2Q9CG5ejdNXWWMdWHaCMWablMbp35k23Xb6ppwG2BtebM2oeZ2Gj4r6ZLg0v
         1n56xJkY8oTO7csI6WbB/0UgxfA2mZWTSpvBDE0En5DC1Qn2lmWgMFzk77nhBKkZFUt6
         UikfeGbTGwZpugV/FK0t9zy9jEFx0Oupn7vIO9wU9UKdIOHZOGZa97IJ7++KKy3VGMOu
         UhtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAWDOEiZKOiOJKX/ksyLakB4ZUDREJg1ngCtHhAKGdGkvwNoMTiv
	B6zrTg5RBS37V/NWUMIfRLcJag2UE9RbB6dsAlig8mFtNPXQZH5m8Kxo+YQ+jIUTlLH+TR8u4H+
	fROs1TpLMuLyIX3ifQVF5FLQm29evPozvbTJFWYO47OIOGqTqo8RF8d49BK0ygH07Mg==
X-Received: by 2002:a1c:2d58:: with SMTP id t85mr22418742wmt.61.1563188545123;
        Mon, 15 Jul 2019 04:02:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWSV0bYKOltDV7xhLIEabrvsADfQyDS5PvknIw9HHOV55XY11AsXGirPFep0T+3y3IdQHl
X-Received: by 2002:a1c:2d58:: with SMTP id t85mr22418623wmt.61.1563188544005;
        Mon, 15 Jul 2019 04:02:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563188544; cv=none;
        d=google.com; s=arc-20160816;
        b=e5xqvSBPX0zfCskVtBlK9rWJ1S0nAYIzcbaB1e8NmNz12xfzS691i88DrR/AYdB4B+
         tHca/DI+yxjDBg+TZsxc0mIvXhYXNtso8HBU8tIn9Iq1B55mrJSeCIgg4qlT2B26+pc3
         lz2m/FixEG2+WIRl234GLr25jSVUkWzr536bV4lLdQV7S7fCqbLVKppXOX3HnJ6omIqv
         k8p8XvUNuQK/bPeDY2Y1WDRI2mteZAXY7v7l/thZKcp7M0HXUSeuATPoQJH7TDc0ouj7
         VZq5I+NXycquG+W8MgSm5/jFFDMRXNYVsNiUnzms/QNcT49MFgN4MtUxmT2SEvibqREe
         QtbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=VDmH1/btnNfyQokX30yDSfOXwgboL6oOf5YsWu008K0=;
        b=m8/shYsiZCeixCuemYtlz1bMsrxTPytBCNENaMkp+3IM8MB4kQbSLdqlzpUy3FGSBK
         lnbqiB8zVK96QCdiW183PCa2NLBjawbw41sEZi6dz6KRlLR4qDW3rDAXg5aAg47WS5RO
         R4Q46youRYLzRNT+DX3ZJEGFvUpev4V95yRj25dRdsz5m8YNf/Jv65jSwjIOjPN9MK/j
         +xKqhpdoDXMlflpnZPFEvcYBKtGqnEaHfNoWjciItJIn/F0I+9Q7WzLB0ncjCmON4az2
         LbN6xvW89tZ4JkGKbbZ+FPC3e2thJTxbNpZk27CK9H1tDNdjhP0eOvbJ1sV5ll+UYCt+
         aX9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id g9si17255432wrp.347.2019.07.15.04.02.23
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 15 Jul 2019 04:02:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) client-ip=81.169.241.247;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 81.169.241.247 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id 948EB41D; Mon, 15 Jul 2019 13:02:22 +0200 (CEST)
From: Joerg Roedel <joro@8bytes.org>
To: Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Joerg Roedel <jroedel@suse.de>
Subject: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
Date: Mon, 15 Jul 2019 13:02:12 +0200
Message-Id: <20190715110212.18617-4-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190715110212.18617-1-joro@8bytes.org>
References: <20190715110212.18617-1-joro@8bytes.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joerg Roedel <jroedel@suse.de>

On x86-32 with PTI enabled, parts of the kernel page-tables
are not shared between processes. This can cause mappings in
the vmalloc/ioremap area to persist in some page-tables
after the regions is unmapped and released.

When the region is re-used the processes with the old
mappings do not fault in the new mappings but still access
the old ones.

This causes undefined behavior, in reality often data
corruption, kernel oopses and panics and even spontaneous
reboots.

Fix this problem by activly syncing unmaps in the
vmalloc/ioremap area to all page-tables in the system.

References: https://bugzilla.suse.com/show_bug.cgi?id=1118689
Fixes: 7757d607c6b3 ('x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32')
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 mm/vmalloc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 4fa8d84599b0..322b11a374fd 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -132,6 +132,8 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 			continue;
 		vunmap_p4d_range(pgd, addr, next);
 	} while (pgd++, addr = next, addr != end);
+
+	vmalloc_sync_all();
 }
 
 static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-- 
2.17.1

