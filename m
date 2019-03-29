Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D975C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:29:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37C7D20645
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:29:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37C7D20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B427E6B000C; Fri, 29 Mar 2019 04:29:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF1CC6B000D; Fri, 29 Mar 2019 04:29:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A08B96B000E; Fri, 29 Mar 2019 04:29:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 810726B000C
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:29:23 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id q21so1506726qtf.10
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:29:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=NXb6LMCQKbdcGcovwqkyVGGdxwVtRhurGDKScuKkz2k=;
        b=UOjvqTff5dgch9HDZMp6PmGW9KXy+UE524eJJaA6cuhATO/O2iaB6CKfneu2zdMtQM
         XVTL2xcjUoQxYnlbxMeSfpuy7W5nMjV90n/YglWqJ481EP0J5GzHhH+MnwVF9tVEnxhp
         /Nh5g1aVzP3bA9U3ErLQ42xeYPnIkNqOXDuhtNgv2RD4Cb379PdwNBdYvgA9MEItInET
         cpzynOKHKthXhgcQ7gN9GNdsTPKAzsLvAZeIfHm6SIdZmD0eBjGu+rICw4WmCnTsW+h9
         Cq+SNMkws2AORCN3/I+MUscMDylSUMtbI4f4MdkX/40OQa+bxTDywF0WuXhSM55UEfbl
         FDcQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX6odJAeAKlS/u1+o0wyXG6grZ6yGm248mHU4zJ7yMa71uJ7e2p
	YhmrkPgL0sr/SgI7GEPjq/bQqgwHsT1DHhetqAggxD5pd89SfN3KIvUR2m3JUJL+Sgv7A4grklT
	DjCGefc5q0g395TH06YzkBLzJGoVHq83tMWuNhH0F+IzpEMUGw806qwxwmlI0eP7r7A==
X-Received: by 2002:a05:620a:16aa:: with SMTP id s10mr29977202qkj.305.1553848163273;
        Fri, 29 Mar 2019 01:29:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxN9qrIkQkFTT6M6piFh8WfTWCZgtb550BGjLeKld/cOFXVBI7sJs8d7Ct3FJDpPjodm+Lv
X-Received: by 2002:a05:620a:16aa:: with SMTP id s10mr29977154qkj.305.1553848162204;
        Fri, 29 Mar 2019 01:29:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553848162; cv=none;
        d=google.com; s=arc-20160816;
        b=lABOqL8dPKn5sO60zTxPpndzKIQXw7NPyos9w+qeW/YBCUrvZJFdL38VQAX35jpmMn
         3sjOGqRYgqEU9F1wcuSUNHHtUZOh0idTfYvBwYPTU01mLVvS6rK6u9RZiIATEwurtS2A
         71MyNhAxlSe0PNCN9YrBlIwKGipw/ILBTIW3C4eQpktj4lCWLvVbqwqxMM2z7KQcocPp
         8Jdqr8HiynJMIsnuKejCFefngvzi28jOTmqqtOaftLguuSkMlkDLN9Xau8fpDWYpq13j
         qxgaKlZ0QHRnm/FpwvQ5BlIK91hb6UggkImxaF6Xc2GNRfVvFeAJT1hbA6wc1xidHqnn
         5KfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=NXb6LMCQKbdcGcovwqkyVGGdxwVtRhurGDKScuKkz2k=;
        b=XEvGdmfAczPHs7MIaGpyQu2ScdFeh2oSA+ZWFJvMjsnOyYm8FWZG0O/RClfcdQ2JcA
         PQIGMHG35zo9oWTZMqtwxijiKrBPbWazazhE7E8quwnlhyWSHPz3g1nfDQPMuTS6oxOE
         3CynBMic/Pt/k8SFGG1OZsXOGeh8fx72Lh2ZVxGcftN3PmbZf038ey4VtE71XHCvcT44
         DavUkHwNBfTyQfXqSEpAVjuFJSt0eml/VrHxgtBro2RwXUFsVmIWNTlKJtMPvivzEdBf
         /rAGuAoHYth/GV0Ubl5Th9QDxE46m+PnnnfuRj3kl0xl2W4/haOpEnp9A5fX9Nn84AJl
         wcPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g3si183225qkc.91.2019.03.29.01.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 01:29:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 389203082E57;
	Fri, 29 Mar 2019 08:29:21 +0000 (UTC)
Received: from MiWiFi-R3L-srv.redhat.com (ovpn-12-24.pek2.redhat.com [10.72.12.24])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 86BBF379A;
	Fri, 29 Mar 2019 08:29:17 +0000 (UTC)
From: Baoquan He <bhe@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	rafael@kernel.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	osalvador@suse.de,
	rppt@linux.ibm.com,
	willy@infradead.org,
	fanc.fnst@cn.fujitsu.com,
	Baoquan He <bhe@redhat.com>
Subject: [PATCH v3 1/2] mm/sparse: Clean up the obsolete code comment
Date: Fri, 29 Mar 2019 16:29:14 +0800
Message-Id: <20190329082915.19763-1-bhe@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 29 Mar 2019 08:29:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The code comment above sparse_add_one_section() is obsolete and
incorrect, clean it up and write new one.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
v2->v3:
  Normalize the code comment to use '/**' at 1st line of doc
  above function.
v1-v2:
  Add comments to explain what the returned value means for
  each error code.
 mm/sparse.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 69904aa6165b..363f9d31b511 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -684,10 +684,19 @@ static void free_map_bootmem(struct page *memmap)
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
-/*
- * returns the number of sections whose mem_maps were properly
- * set.  If this is <=0, then that means that the passed-in
- * map was not consumed and must be freed.
+/**
+ * sparse_add_one_section - add a memory section
+ * @nid: The node to add section on
+ * @start_pfn: start pfn of the memory range
+ * @altmap: device page map
+ *
+ * This is only intended for hotplug.
+ *
+ * Returns:
+ *   0 on success.
+ *   Other error code on failure:
+ *     - -EEXIST - section has been present.
+ *     - -ENOMEM - out of memory.
  */
 int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 				     struct vmem_altmap *altmap)
-- 
2.17.2

