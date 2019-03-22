Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 089F6C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:11:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B973F21900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:11:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B973F21900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7126D6B0266; Fri, 22 Mar 2019 13:11:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E9736B0269; Fri, 22 Mar 2019 13:11:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B4876B026A; Fri, 22 Mar 2019 13:11:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21A8E6B0266
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:11:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v16so2895302pfn.11
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:11:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=Vg0Whlt5nWKS2UY2aDlAxifF3nfmLxQ9zBg1NLRGZtg=;
        b=i4DRHiHra+dyMhHCX3UBCId3nDT1qYIshrCGsksoGAj7LuOphUL1kiV4rbHa5+3zfb
         DvteW1oDE7lr4/u/sumM70W80ROG9uBHHh5IieSAIOpIQIVNmiS9cObtg6dAuxU0IG0R
         KVKuPIL8yo0lgyme4aTKZkcg5xsE3dfXHAiI39YPawObhKwa62hj/lGdVwGbLSXBTzZg
         WEJf6jxzZpzvCbX61axo0f9kAomW4x6zV3XP47J6Vit/CfjjaE75HmBH2rEw0dQFEGCj
         9c8Znnf7q7UlO9G1w3wp6vp49Wiva63+0ThkpQxr6XgaRGh+VNHAJKm1bWUnuPBEv0Yu
         bOxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVgQr5A81wBquNKbXwNkbCiltPIdbGGnQRiGOBIL8IS4wD1FBL5
	TSJJlHvGo0DBRxPBTE+DcQLHElGhKlEcQZNmuk6auMOE5v0DI2w0Tg1sewL6JEoRL5G9kEzK5dr
	gDkLboBZ8dldvGmJyPLndooIUP+IaOJX0IMQOnmtSSRZGjYKKAiiHQTvhcs1eFU5KTA==
X-Received: by 2002:a65:538b:: with SMTP id x11mr9748734pgq.35.1553274683746;
        Fri, 22 Mar 2019 10:11:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqynki6iw4NUIo98w1WzY+mIwrRwvXffd0DOj47ZFLmtwD6+09+7/8sZOjop6phUD6srxHUK
X-Received: by 2002:a65:538b:: with SMTP id x11mr9748632pgq.35.1553274682410;
        Fri, 22 Mar 2019 10:11:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553274682; cv=none;
        d=google.com; s=arc-20160816;
        b=vRnqIlNs3/vn5P1Pxia4v5aAMu5Ac2d/cQQ9CMg4nbv23o6pNT/uJhdntoekO+P5WN
         apVXAWoOXq/ba6r53tSwkc2wW8yytGMlKzvT1DLx/AMdRbxYKZsVz5IvafoNa29k8FBj
         uAGCMrBRvyJHPPXfanzLimNFPzwSObnVIUfKNMAiHCZICdihwNlic2xqPLf5kdc6AAWk
         3TMLNh0Hwy/c0bnVXQMkJLRdpy0ofJ0C4rcK6yGMYdxWERvUFj/nfmXnzjaRyORWF6Xj
         l2PCsPdF6sEuamwQW/jO++oh0agNt6NkY//EGSbTePRTkD35fOx4i7X6b8dh2uxOJhjM
         NURQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=Vg0Whlt5nWKS2UY2aDlAxifF3nfmLxQ9zBg1NLRGZtg=;
        b=0WckX+M2dMmbssvIuIYy64YaSZPbghfdTOAy5tIF3HlPHigTsBCFrLSe/yVZoJbTGJ
         cNGTMDFdpCduS8XDsmffVmAAbDjkeK7/hhOrMjsXf24uUiKLB08DH/kZq4mIcjuIAp7l
         LjYlBh3pGx5cvYuQq9S+nu25TrdhfexgXjikEXnFELZLNSRQ0RcITRhVCYhjDyJQxXox
         bxEm+CY4EBNDHSoiFDCz+vTsRk7B9Im5DKz9GP6bqQnmQ0niqi4RUJryrDriE6BMDnW4
         IwJRHFsqd89kecHk+0E20aHGcHASga7jIwwReO5QL//4Iq2JWXfAwDeZjErlNtS0negD
         mGzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t26si7072004pgu.504.2019.03.22.10.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 10:11:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 10:11:21 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="154240491"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga002.fm.intel.com with ESMTP; 22 Mar 2019 10:11:20 -0700
Subject: [PATCH v5 09/10] libnvdimm/pfn: Fix fsdax-mode namespace info-block
 zero-fields
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Date: Fri, 22 Mar 2019 09:58:41 -0700
Message-ID: <155327392164.225273.1248065676074470935.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

At namespace creation time there is the potential for the "expected to
be zero" fields of a 'pfn' info-block to be filled with indeterminate
data. While the kernel buffer is zeroed on allocation it is immediately
overwritten by nd_pfn_validate() filling it with the current contents of
the on-media info-block location. For fields like, 'flags' and the
'padding' it potentially means that future implementations can not rely
on those fields being zero.

In preparation to stop using the 'start_pad' and 'end_trunc' fields for
section alignment, arrange for fields that are not explicitly
initialized to be guaranteed zero. Bump the minor version to indicate it
is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
corruption is expected to benign since all other critical fields are
explicitly initialized.

Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
Cc: <stable@vger.kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/dax_devs.c |    2 +-
 drivers/nvdimm/pfn.h      |    1 +
 drivers/nvdimm/pfn_devs.c |   18 +++++++++++++++---
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/nvdimm/dax_devs.c b/drivers/nvdimm/dax_devs.c
index 0453f49dc708..326f02ffca81 100644
--- a/drivers/nvdimm/dax_devs.c
+++ b/drivers/nvdimm/dax_devs.c
@@ -126,7 +126,7 @@ int nd_dax_probe(struct device *dev, struct nd_namespace_common *ndns)
 	nvdimm_bus_unlock(&ndns->dev);
 	if (!dax_dev)
 		return -ENOMEM;
-	pfn_sb = devm_kzalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
+	pfn_sb = devm_kmalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
 	nd_pfn->pfn_sb = pfn_sb;
 	rc = nd_pfn_validate(nd_pfn, DAX_SIG);
 	dev_dbg(dev, "dax: %s\n", rc == 0 ? dev_name(dax_dev) : "<none>");
diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index dde9853453d3..e901e3a3b04c 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -36,6 +36,7 @@ struct nd_pfn_sb {
 	__le32 end_trunc;
 	/* minor-version-2 record the base alignment of the mapping */
 	__le32 align;
+	/* minor-version-3 guarantee the padding and flags are zero */
 	u8 padding[4000];
 	__le64 checksum;
 };
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index d271bd731af7..f0e918186504 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -420,6 +420,15 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn *nd_pfn)
 	return 0;
 }
 
+/**
+ * nd_pfn_validate - read and validate info-block
+ * @nd_pfn: fsdax namespace runtime state / properties
+ * @sig: 'devdax' or 'fsdax' signature
+ *
+ * Upon return the info-block buffer contents (->pfn_sb) are
+ * indeterminate when validation fails, and a coherent info-block
+ * otherwise.
+ */
 int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 {
 	u64 checksum, offset;
@@ -565,7 +574,7 @@ int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns)
 	nvdimm_bus_unlock(&ndns->dev);
 	if (!pfn_dev)
 		return -ENOMEM;
-	pfn_sb = devm_kzalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
+	pfn_sb = devm_kmalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
 	nd_pfn = to_nd_pfn(pfn_dev);
 	nd_pfn->pfn_sb = pfn_sb;
 	rc = nd_pfn_validate(nd_pfn, PFN_SIG);
@@ -702,7 +711,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	u64 checksum;
 	int rc;
 
-	pfn_sb = devm_kzalloc(&nd_pfn->dev, sizeof(*pfn_sb), GFP_KERNEL);
+	pfn_sb = devm_kmalloc(&nd_pfn->dev, sizeof(*pfn_sb), GFP_KERNEL);
 	if (!pfn_sb)
 		return -ENOMEM;
 
@@ -711,11 +720,14 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 		sig = DAX_SIG;
 	else
 		sig = PFN_SIG;
+
 	rc = nd_pfn_validate(nd_pfn, sig);
 	if (rc != -ENODEV)
 		return rc;
 
 	/* no info block, do init */;
+	memset(pfn_sb, 0, sizeof(*pfn_sb));
+
 	nd_region = to_nd_region(nd_pfn->dev.parent);
 	if (nd_region->ro) {
 		dev_info(&nd_pfn->dev,
@@ -768,7 +780,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->uuid, nd_pfn->uuid, 16);
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
-	pfn_sb->version_minor = cpu_to_le16(2);
+	pfn_sb->version_minor = cpu_to_le16(3);
 	pfn_sb->start_pad = cpu_to_le32(start_pad);
 	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);

