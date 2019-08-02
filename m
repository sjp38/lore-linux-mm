Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BCA0C32754
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 13:20:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 415F1218B6
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 13:20:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VRj6f7fn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 415F1218B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2DB76B0003; Fri,  2 Aug 2019 09:20:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CDD606B0005; Fri,  2 Aug 2019 09:20:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF4546B0006; Fri,  2 Aug 2019 09:20:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB8F6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 09:20:56 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i3so41642984plb.8
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 06:20:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=zqYGUtZzdq1s4YiD8Iq65ycr6HLaEbeAMUnSqIktROk=;
        b=GKbNn23t4NV2/aBhbqWbYJe/W/3L2aLPv8OTBLp9rDqxf4+Cl+4RqD6P8ZgY19fMOn
         z9bR5BK27hrNulpveq/PR2IMYWD0loiIG2Yhm6SGqb/LRtIMLkMUitv36ALhyRdi8wRQ
         ryV6dw4i1dECNn3Tkzd4kgI9sbXvjOaF9x1SwUW6uzPfkMWke0/oZ4Ta2u9yLHXbhwab
         NmEKssLNXi5jfUu1P4PRHAwIncctknSoO+HnVr35cPmNtgnCjBS9cJSJ88aM/w69NLlP
         sc7GC+txrTT/ddWGV73IsuPDrYVBVc6SQNfDSDVAoH6/q3W0SJhn9HCW33tEDexqx44W
         ySyg==
X-Gm-Message-State: APjAAAWRre3xpdWSqVrlFwbMmegehkr3o6ZgHHDpFvgEIhDW4Vu2/zsA
	+scw5EjbeijuMdKhB6csHmBRIYXXyThnAYDZpAQ/+CwuAlSMi8BZbkaSNZTpAPGmzr0vvXJFYDK
	NL8aFRTXfM+cIyOUQoiSIP8Fwj9K69uXbQD6reGPPKOBIBe6tYA25Rg1DM9EwKbWZIQ==
X-Received: by 2002:a17:902:e40f:: with SMTP id ci15mr131862693plb.103.1564752056120;
        Fri, 02 Aug 2019 06:20:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxec+u2FMj1XTDDPXjwpCN8Q8Aa9YEMfGMsrmr3sajjUR9IeTaGFOO/yPA2JgT+/eO6Mvp/
X-Received: by 2002:a17:902:e40f:: with SMTP id ci15mr131862639plb.103.1564752055310;
        Fri, 02 Aug 2019 06:20:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564752055; cv=none;
        d=google.com; s=arc-20160816;
        b=GWpV0Q+Pbxw2UlEry2x0xIEGDRvVDnNeykiJmPBoVCbA3CayMxW7L7J+z2I3++CCnt
         Gq+CZQW10joY8HYSH7pcrapzzwrlEo1j+Lr8yoWWBWjNnjv5zBX1ZbjAk48TfwYuj7mP
         J+eSS2gLg+U1KvxZjx8JO8YCEgqQL0Us6I3eZ3Vz2f+c2GwuUuNHs+NyJ3Mq9dGXwNAl
         X/qxd0Ygx7w1w4W4TsOPfKQyYrHq+Mgg1DSSGK067JjZI0lVrabwdLr/2D/q44qJjBHQ
         tHuIrQ73gLF5pfysIAfDUy8f8J3yDHkigbA1O93B0J7t9VKWMr9urqS/mYR0HWCSoA0a
         7+qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=zqYGUtZzdq1s4YiD8Iq65ycr6HLaEbeAMUnSqIktROk=;
        b=oW57PDJCwbS2gm+Dy4CgtaFGS9H8+OSLOEo0h4Zs1i2r82YZ7YHY1ta2eTHwuOlCOO
         bxQTcS3Z1aW+rbDUz7J7eWAWFvHNRkHPVIcFIa01n8r3sHDY00X2vTjoFhoZsLSicGdn
         6Eqlzm0/uNlop0r1fyeB1Qb6XT3HSHjpWxBPO4gbH+4EWoVifkiyXqmHlCIF2A6LHWBG
         qf6Ar7Oa5LhLYuJnbVctWg8WBf0EB7fHYl5zhArshVEOokvuAGH8als3GQNhOrQpW9lU
         j1cbMy/vZDckItGZyjDvuhyQVe2Hc5o0j0hcWz2vJfRWpUfz3HUEozOGYU+IgzI9wGF9
         2MYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VRj6f7fn;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v41si38986592pgn.481.2019.08.02.06.20.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 06:20:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VRj6f7fn;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 342A421882;
	Fri,  2 Aug 2019 13:20:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564752054;
	bh=8LckdS0aV16gjDTP4ua5q1u/mMnZe6SiPr68l2IsRrk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=VRj6f7fndJTYUvq/TPjQNzXAvVfDB7ZxW986FZHbpmQLm9SgQRL8zmstpnoNuWGqL
	 CGWsmqgXJh9lFKlz1kwqUa5y6Tij20Jc5RKkKOqg5+sU6P6jql56b2REA/pbLxtH8L
	 o8jPkE/j7Dg4KAHUaQP/u2CyHXxX+/9sz2XMnSsA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Joerg Roedel <jroedel@suse.de>,
	Thomas Gleixner <tglx@linutronix.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.2 36/76] mm/vmalloc: Sync unmappings in __purge_vmap_area_lazy()
Date: Fri,  2 Aug 2019 09:19:10 -0400
Message-Id: <20190802131951.11600-36-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190802131951.11600-1-sashal@kernel.org>
References: <20190802131951.11600-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Joerg Roedel <jroedel@suse.de>

[ Upstream commit 3f8fd02b1bf1d7ba964485a56f2f4b53ae88c167 ]

On x86-32 with PTI enabled, parts of the kernel page-tables are not shared
between processes. This can cause mappings in the vmalloc/ioremap area to
persist in some page-tables after the region is unmapped and released.

When the region is re-used the processes with the old mappings do not fault
in the new mappings but still access the old ones.

This causes undefined behavior, in reality often data corruption, kernel
oopses and panics and even spontaneous reboots.

Fix this problem by activly syncing unmaps in the vmalloc/ioremap area to
all page-tables in the system before the regions can be re-used.

References: https://bugzilla.suse.com/show_bug.cgi?id=1118689
Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
Signed-off-by: Joerg Roedel <jroedel@suse.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Dave Hansen <dave.hansen@linux.intel.com>
Link: https://lkml.kernel.org/r/20190719184652.11391-4-joro@8bytes.org
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/vmalloc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0f76cca32a1ce..080d30408ce30 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1213,6 +1213,12 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	if (unlikely(valist == NULL))
 		return false;
 
+	/*
+	 * First make sure the mappings are removed from all page-tables
+	 * before they are freed.
+	 */
+	vmalloc_sync_all();
+
 	/*
 	 * TODO: to calculate a flush range without looping.
 	 * The list can be up to lazy_max_pages() elements.
@@ -3001,6 +3007,9 @@ EXPORT_SYMBOL(remap_vmalloc_range);
 /*
  * Implement a stub for vmalloc_sync_all() if the architecture chose not to
  * have one.
+ *
+ * The purpose of this function is to make sure the vmalloc area
+ * mappings are identical in all page-tables in the system.
  */
 void __weak vmalloc_sync_all(void)
 {
-- 
2.20.1

