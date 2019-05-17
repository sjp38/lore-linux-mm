Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8210C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 10:38:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6979A2087B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 10:38:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6979A2087B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCDCD6B0005; Fri, 17 May 2019 06:38:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B81DD6B0006; Fri, 17 May 2019 06:38:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A952A6B0007; Fri, 17 May 2019 06:38:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 722436B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 06:38:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t58so9987607edb.22
        for <linux-mm@kvack.org>; Fri, 17 May 2019 03:38:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=v3xv6kYfm8zEAQdQs8EnggYFUDZyw0OU6rXLckOyZzY=;
        b=Ov+qcC7SXIH2m0V8HWZNkOf5ohuCtogNTlHcq/AXPQ3kbimwXCSJR94URxDOEMCHeq
         PwK9+45Q1xaFW0BFcnP9g7GhiIvkOL0wCu6UD2fd7d3Z/b1hO6jCYZJdMfSgXOXQc6m0
         HmLfcCol7kfE1i03MPIdWq1sZBqJvYoQP+loEHri/xA3njT09lC2vhQZvM81Au/d8jNo
         DiXxaAdyeHuRDWZIOs0wyuGkhx3h5jo8OxkMvRih5OdiATZnJaHg1j954DtJ9w3BdB+l
         mSwKgJoBHUBW7fvPsCR7HgenkY9xWrUQ0zuWV1cb2AVdFamGk7VjG9dZwDqPUxURYZD0
         l5LQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAV/3AYgiPypsuXu5HpGyEwBG+GRuVVRdOBfTlWkszGQQl7h6W6r
	s7x9/DSdZEiu9S3XiXKH1rw3D6mwo9vfnGuK4fqDHoFUiGXUx6CEdI94i2Zd8JgKKazXlIH7aI4
	Yxxd/qobj3M3UuGhZ7610Y+Grq/qDoOHbBt/s4hNX9TdEH4PXtfP0j20jLJPvKx/evQ==
X-Received: by 2002:a50:bae4:: with SMTP id x91mr56935310ede.76.1558089520872;
        Fri, 17 May 2019 03:38:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWyCD6BxX7NqnA8BN7Bs0Vfdc+6p9rs9DuZghpTbcIYsm0IXklK80IVOlcBgTvx+EIL/sv
X-Received: by 2002:a50:bae4:: with SMTP id x91mr56935232ede.76.1558089519858;
        Fri, 17 May 2019 03:38:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558089519; cv=none;
        d=google.com; s=arc-20160816;
        b=wyqaD5+zYyYqHq/XzuVbUT/JAT96crAwHkVkwTwac91UDUBTzlhg+kiGVu31uM7n5Z
         5tv9+OxOAHLroVTjuFBEXDbPS6ZoqZX4bz7L4FP5w5ep/0wpNVUSmhmNUlJfuXaTlx2u
         JOdVdsBxVUE4DAicZ+NLeCM3gqia89NEMop+cboY48gpt8oxYe3tStaf/s4DYjNMDrDD
         6gMvxgpQFWvQVa3fJ/2Zvo+eRADt+jBdsyHZ9QgnUOXqSoWwcvLFrf+UhFjWqeVQS6W/
         1dztyXp7KvYw0xQgmcEfc789pbFI4iFxzMT/Aly5eL7LNSFnIfbn0lnsQRDSPZls/v7s
         XGWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=v3xv6kYfm8zEAQdQs8EnggYFUDZyw0OU6rXLckOyZzY=;
        b=PlTzjhLqSoRC+I4heMj21PiAWsPJ3jo0F5NSe2F0tf9uk2CqOaF0ILWjYfLxDtxtpN
         GUczBXDGZnMwFxPmKZ6zH+2WBcdq89+pRcBAbs9Twytge7gOkZWqHegNIrFFc6fktGtG
         cB9Ny5EV8P5OPCN1fJems4w3PT6YSUaQe8FsFLa99fYsRV7G36+RYT5OHRSbRoBhp9r3
         GIfUbX4utxY9/d6OoNfr8kj/p9bluNr4Qkm/sjTEBpOapbg0/Vm6b1n1o9S8L/NBgrdi
         luIdlGo0YByJBxKJ+CNLbIyynJ2MJKBUOD6fG6eJgzZBuObQnyJ00Wc3p5enML1nPI9+
         Yyfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g38si593932edg.96.2019.05.17.03.38.39
        for <linux-mm@kvack.org>;
        Fri, 17 May 2019 03:38:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6CE1880D;
	Fri, 17 May 2019 03:38:38 -0700 (PDT)
Received: from p8cg001049571a15.arm.com (unknown [10.163.1.137])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 0E5573F575;
	Fri, 17 May 2019 03:38:33 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	dan.j.williams@intel.com,
	jglisse@redhat.com,
	ldufour@linux.vnet.ibm.com
Subject: [PATCH] mm/dev_pfn: Exclude MEMORY_DEVICE_PRIVATE while computing virtual address
Date: Fri, 17 May 2019 16:08:34 +0530
Message-Id: <1558089514-25067-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The presence of struct page does not guarantee linear mapping for the pfn
physical range. Device private memory which is non-coherent is excluded
from linear mapping during devm_memremap_pages() though they will still
have struct page coverage. Just check for device private memory before
giving out virtual address for a given pfn.

Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
All these helper functions are all pfn_t related but could not figure out
another way of determining a private pfn without looking into it's struct
page. pfn_t_to_virt() is not getting used any where in mainline kernel.Is
it used by out of tree drivers ? Should we then drop it completely ?

 include/linux/pfn_t.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 7bb7785..3c202a1 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -68,7 +68,7 @@ static inline phys_addr_t pfn_t_to_phys(pfn_t pfn)
 
 static inline void *pfn_t_to_virt(pfn_t pfn)
 {
-	if (pfn_t_has_page(pfn))
+	if (pfn_t_has_page(pfn) && !is_device_private_page(pfn_t_to_page(pfn)))
 		return __va(pfn_t_to_phys(pfn));
 	return NULL;
 }
-- 
2.7.4

