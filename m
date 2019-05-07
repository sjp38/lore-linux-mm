Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F622C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:09:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 660E720C01
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 00:09:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 660E720C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 058FF6B0006; Tue,  7 May 2019 20:09:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 008FE6B0008; Tue,  7 May 2019 20:09:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3BB06B000A; Tue,  7 May 2019 20:09:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEB946B0006
	for <linux-mm@kvack.org>; Tue,  7 May 2019 20:09:53 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f1so3243368pfb.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 17:09:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=QPUnx65moTf9orYAxQfca8uCnxz2On+XPnlOyTMkP5g=;
        b=QEMg49i3xcWwFKsSl09MymEr0BcK1oN1w1i/dBEULfmzk2QS8vLcUQ/qp90fbFzCpJ
         nwH0JfktcOzzz5w8ZOpioRcy/0QJNdXtekrMczvKV+8D0kdwDMbW/1sZo52MCFWK9vqL
         LYQxmH/MvvoTXt/yy5pX3ji1qq0+2Zj3gXjeQLriZLVLI559BYRKH1dqYZogJ35QBaMT
         z/u6H/T2Eucb06X5vnP7VF/JDZlkyxvZce/X4bz3Rm7jAzZ0NIKW8IzAwstnqVWh7vy8
         2GOA9zqNcVC2cqB9Stkqcxl+556BC/Rw+XavABXMC4w9c9JZffRDq1VCEG2vsApWTT5q
         QUUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV8HFio8pN/ZvCXW3VlvWwbZnxj+xfcPIOhtNU08b4uOvljfBI4
	5udCO3jzFxvkIet7qj3vGZsojtwWSD5xD+vTIuRrX8Uhyu4mWHdvaoweDDcd8u0RkArtHrPZhsQ
	aMgwPvCODv3GrHu2HloFaWWyDCYDM9DWmT+/ayBnGN/Z64Jou5cinq9jTUcpo5kDZnw==
X-Received: by 2002:a63:754b:: with SMTP id f11mr4138275pgn.32.1557274193359;
        Tue, 07 May 2019 17:09:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYPsfFvC5Z/JP9x2hEpNKjuhnHhhda5NLijjVhbvfCkaD1ye2ZK0kObp8uUONvtXvQniS1
X-Received: by 2002:a63:754b:: with SMTP id f11mr4138208pgn.32.1557274192527;
        Tue, 07 May 2019 17:09:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557274192; cv=none;
        d=google.com; s=arc-20160816;
        b=RsiJSpVaFoMU13ddlmwa/8BItmDoJhTsZxvf7MpbdLAPdQ7fw1QDZnW2OuZsVpISz+
         rlPibrFNiqMnGXeezGnR/JKWhjRPVG2lw491wflCPRwKMb6pBeqQuk5USF+ExBWCYedE
         JN03lbF99UTZwwGuvU469vM103AJ74TuBWLaVRPh/jwH/A0bEabV/aqut1gkWQ09kwsQ
         Xk5ZmI3uB8MsGo0bnhZCioEFkxFGz4IB2AYE3mfnIUo3HcZhRh667P8xD3gUWS9xmYYx
         rk+0cz2Acj3QhOn8stDamZxNvjv/Z/TdUbCzAbv1VDPGUyZ5Knjqu0g7w6KG5RbPtST2
         QJWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=QPUnx65moTf9orYAxQfca8uCnxz2On+XPnlOyTMkP5g=;
        b=Dyv5M1cWKiSKKNujd2WaNpxgPe0q6nOlVFaBtMoQGGAylJJVWClis8Ky9TI+QcDPPI
         jcWSOs+YMgjbXLnjrn5PSoP58XjwifyUCQwB0vaFTLtqz8AVZOZJ4ULZMVvHGQvE5GZr
         oIE2+JfhVEl1LAm3tNJVodcnmrLTULqu8E4hGdug8BlHIb0sG/H/e47ZDXNBzqtMo4su
         k0RrWdFZJDwZ4N+KlCLnw7VDwNGbp1b+n+hPvMPmGVxr7C8o9KOEkoRCbhtP9LXLKZgB
         T+wDgzd3Jve6NegEE/bLZxDUF7djVhDzvx/sBZnDFq8J2vJcK2H+Fbr4msgS/KXq8wBe
         oPjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 144si11128746pgh.524.2019.05.07.17.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 17:09:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 May 2019 17:09:52 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga001.fm.intel.com with ESMTP; 07 May 2019 17:09:51 -0700
Subject: [PATCH v2 1/6] drivers/base/devres: Introduce devm_release_action()
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Christoph Hellwig <hch@lst.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, Ira Weiny <ira.weiny@intel.com>,
 linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org
Date: Tue, 07 May 2019 16:56:05 -0700
Message-ID: <155727336530.292046.2926860263201336366.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The devm_add_action() facility allows a resource allocation routine to
add custom devm semantics. One such user is devm_memremap_pages().

There is now a need to manually trigger devm_memremap_pages_release().
Introduce devm_release_action() so the release action can be triggered
via a new devm_memunmap_pages() api in a follow-on change.

Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/base/devres.c  |   24 +++++++++++++++++++++++-
 include/linux/device.h |    1 +
 2 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/base/devres.c b/drivers/base/devres.c
index e038e2b3b7ea..0bbb328bd17f 100644
--- a/drivers/base/devres.c
+++ b/drivers/base/devres.c
@@ -755,10 +755,32 @@ void devm_remove_action(struct device *dev, void (*action)(void *), void *data)
 
 	WARN_ON(devres_destroy(dev, devm_action_release, devm_action_match,
 			       &devres));
-
 }
 EXPORT_SYMBOL_GPL(devm_remove_action);
 
+/**
+ * devm_release_action() - release previously added custom action
+ * @dev: Device that owns the action
+ * @action: Function implementing the action
+ * @data: Pointer to data passed to @action implementation
+ *
+ * Releases and removes instance of @action previously added by
+ * devm_add_action().  Both action and data should match one of the
+ * existing entries.
+ */
+void devm_release_action(struct device *dev, void (*action)(void *), void *data)
+{
+	struct action_devres devres = {
+		.data = data,
+		.action = action,
+	};
+
+	WARN_ON(devres_release(dev, devm_action_release, devm_action_match,
+			       &devres));
+
+}
+EXPORT_SYMBOL_GPL(devm_release_action);
+
 /*
  * Managed kmalloc/kfree
  */
diff --git a/include/linux/device.h b/include/linux/device.h
index 4e6987e11f68..6d7fd5370f3d 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -713,6 +713,7 @@ void __iomem *devm_of_iomap(struct device *dev,
 /* allows to add/remove a custom action to devres stack */
 int devm_add_action(struct device *dev, void (*action)(void *), void *data);
 void devm_remove_action(struct device *dev, void (*action)(void *), void *data);
+void devm_release_action(struct device *dev, void (*action)(void *), void *data);
 
 static inline int devm_add_action_or_reset(struct device *dev,
 					   void (*action)(void *), void *data)

