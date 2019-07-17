Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A5C0C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:15:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33D9921743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 07:15:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33D9921743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=8bytes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF0058E0005; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA1846B000A; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A55898E0006; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 387598E0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 03:14:54 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so17452636edb.1
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:14:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Lnw+NdhmEcJZRPrRGQsYyVpoRNapOiKu9LqdRSkFBI0=;
        b=fnDkG5mSWuHeWj2fDWNf40vScxED8e8sG9Tzq87z5tnhxNalnjqhhHxFTiNghEI20Z
         DnmiY7QyQ8fSZ5FBgl6kCZzAX7qbkCmnqzPyUWAaPGvdmUSoqdJor2mMt7/OhZMXzSC6
         VlIhfO7QG/4hPAB9cNE8k0eetbEtqt97b92I2G/AzJ2WbPB8OUjPi+GHoLtBDJzgl1fH
         Enc+ZouT2M2ifNW41ZK5SnEB93bNZA+5KT4ilLLSYAynzxJ9GIwsjJOkXtqP9ryCyDqr
         a9JXTPnMGgVQWIpxHP/2+SpOM0UEl0VmwYr20cZVs1k9nvpSRnvdwtSJbTVyqHL9NO1v
         FthQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
X-Gm-Message-State: APjAAAVXJlRrDly70rVGjslKhovtUE0xAbtYe9cvxvefUq/pQz2FwmHA
	l0xsrB8KlUIDIOS5L9ubsDRfoGsMay9XWqJ/KURVTXt674vgF20Vv07i6ZHGpBY3OsDFnsmQHlE
	z+sQyK5iAL57TbpxVDvb8UEWf4Cmw0XfOPCf/gI4CQ1UOJH+ZrTT9IsENTe4WV36VbQ==
X-Received: by 2002:a17:906:7d56:: with SMTP id l22mr29862311ejp.236.1563347693819;
        Wed, 17 Jul 2019 00:14:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy0Ssci0zReR8LYV2RiwzIJGexaVj/LZXNYxk16RecqMf8dZKl9WzWO2daYs/fYB2USG+uz
X-Received: by 2002:a17:906:7d56:: with SMTP id l22mr29862269ejp.236.1563347693072;
        Wed, 17 Jul 2019 00:14:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563347693; cv=none;
        d=google.com; s=arc-20160816;
        b=RHcpJVoZbGo9fx4kW2BQjPobY5rLXo80N8vkfMlFNW4B0ddK3Qh60BRauIi6rc9amp
         O/uYuJ4GjrMvWLfy2h3ylEBk6RmpWfUsbyDDUcecrtkirNWtFfU1/JMjZUlex+Sz4Byu
         sQFXPFsGbLQuykDFb0WrsleX8xtE/ITKPmpE7cmoj5DRmX80zeqAjBSJkZDH+TXNhsQa
         F2f6Yep6tCxbgJtikLt0t4IzgmUFcJdgwnyYcrcL+vq3sQQt85eKHBBZWL2nJQYwqKkP
         tB7ladafCmMgaARImGBJHth2btJ2JANzmu+/giVQLNn93xRmZmBX+XVd3muSy1OhtzDm
         D0OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Lnw+NdhmEcJZRPrRGQsYyVpoRNapOiKu9LqdRSkFBI0=;
        b=aPBiYu04j87y7DktWKAo/EfQrtvKuz/YcKchFnUtbb6THvd/YdxgyRjPVOnvpFr0cD
         kvqs4yy6OgdpvKRWpj4ZbRc9BXoTrRPVNhpdG2ye1z5NQYhkJ/KMb691MGQPMnnfJVt7
         CSEUM4IbuMO9IJiiQk/DOn6Sx4mqiJ4ZiE/KzqeDJ3ZLp6uEGTlCKavb9cUbTzvjgojS
         K4Zx8gcqqml2KnObgrWioLq5/U1coxXXJrQeqPYRkWXaa2/lkiTAr+0jmYGKU7o7vTKo
         Cz1E36ttfdUYAMeivUPucCY1sLYbhfzXAoVPYqw+wfipW5x0UHaPJ1BWSg/mcRASLjk3
         NPNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id ec4si5417667ejb.37.2019.07.17.00.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 17 Jul 2019 00:14:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) client-ip=2a01:238:4383:600:38bc:a715:4b6d:a889;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joro@8bytes.org designates 2a01:238:4383:600:38bc:a715:4b6d:a889 as permitted sender) smtp.mailfrom=joro@8bytes.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=8bytes.org
Received: by theia.8bytes.org (Postfix, from userid 1000)
	id 2231D476; Wed, 17 Jul 2019 09:14:52 +0200 (CEST)
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
Date: Wed, 17 Jul 2019 09:14:39 +0200
Message-Id: <20190717071439.14261-4-joro@8bytes.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190717071439.14261-1-joro@8bytes.org>
References: <20190717071439.14261-1-joro@8bytes.org>
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
Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
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

