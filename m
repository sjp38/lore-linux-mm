Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E23EC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:10:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B2122085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:10:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B2122085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D99046B026D; Thu,  2 May 2019 02:10:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D7A5A6B026E; Thu,  2 May 2019 02:10:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5FEA6B026F; Thu,  2 May 2019 02:10:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE856B026D
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:10:09 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a90so730434plc.7
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:10:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=LKvk91HhP9ezsuBTNBJqcLkpO+1Sux7+j9Ueu/2PT+g=;
        b=cpgjNDoSceRpJwjf0+vhbUAS54yyJuoVUoyJeqa/lbcgThHGdGIyXCkLHu2Uyaywkj
         D7GAnxBJxMYcC7gHhn08DpIHcBrRdu+9/2Q2XSJ8g0S1Q2fGqpGZxNJCzbRoW9luysPH
         ybRUorTPo/5BvaZXyeGgG/JvkOui8/2BuO/0cu+q+eG4YhqxRATti4CoaNS7Zaxuxwwp
         yuTMjkHIgU7Jc6ksvMLKAJbolQO8CmO0y0o6jbafAvlrQ9psIKOYUMD+iYhXZLhqmm32
         /ER+5zJKhafk1C8nbkb6xYBqSbsmodkX96dGLy7X/vk7WoqiJVyWB6yNQ8RraBzoe/8l
         Qpdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVz8UPBobS1K0hI01Ob/HpTcynbXfmG0jGCVQVgR/5ocTZWw5Mc
	9A4gcOB3MpeHkER1dgyxGQ2Lja+NxjaYzamgEFBN+N4ncRoun7AjP8NnbLbQlznfl8J4GcZAtqW
	d3ozDpf3eiAEKraDLpgIn7Rbin8iQWIa6KN01ukqGpVXnp0Ny7kq2FiXQcaHHXRRa7w==
X-Received: by 2002:a17:902:8604:: with SMTP id f4mr1781706plo.245.1556777409227;
        Wed, 01 May 2019 23:10:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpaUj30K0rNz5Tx70BBJrZ1ea0t9r6UYLnBHe/GniyHWTrQOTpGtcK4fIS/kOuzfJ03VkZ
X-Received: by 2002:a17:902:8604:: with SMTP id f4mr1781624plo.245.1556777408296;
        Wed, 01 May 2019 23:10:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777408; cv=none;
        d=google.com; s=arc-20160816;
        b=RJtWJFkee8UZe7UNSP/QXbDFRsLRiBIHcBsXAZnhKOQ4h29NlbpQn3TcSRd5tut15s
         RT5PXqDlNM4Dh+kiSQhFhqzH3bxfkL/UEm0IvDXuBeRm9kGhtbktr0TtPrtb7VBFmQw3
         t4WnRPSfTks2VwuL3vIzTKF4cxIXRtwCm4cTg9X/8ExiKTRyPl6zI2X8Ur5jlYM1SEDe
         nu/L6R8C28Ffr1gbv5fI8Y5xlsKZhQ1SpDQ5/76wGn9vopGfDw6zvR3w/2tdVmFDtdKZ
         DKjkDHa/tbN5WgV9cB0+WK/cwoj3dEL8bCYhoxcbh6lUDU+G4sO+IsuGmNKVFJCEfX5q
         5Ehg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=LKvk91HhP9ezsuBTNBJqcLkpO+1Sux7+j9Ueu/2PT+g=;
        b=apjtCyiJ+VCEvb4szj7OzLZu4RFqYJPu2xb5TkTzGT2ZtPmN53A8st1MoaEswqNR7Z
         2c2Pk8CZJglRMwi1J3w7122FGJhuzunh71DlrZo0lyzDo7d8fPQquDW1+IvH0qA/udVB
         qJ/RMfgJEwMYtwz76tIOEIwjUl+e2T4tyK/PgEiH5TTeVc33oAEKxnlireMdJftB2ZCk
         HgoI79w2Rg/zljBqd7Mnzp9h/i0VaMNimfnoRRBsO/UksTNuXA+AFl5FBXGKayWkoYrE
         7VYv69ISphsuqE66yicAcFd4vvHFSfqCk6NpXX3jDch3q9WoZEve8MPaxCm88W3IOFNH
         doBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b5si7932355pfa.261.2019.05.01.23.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:10:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:10:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="145342058"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga008.fm.intel.com with ESMTP; 01 May 2019 23:10:07 -0700
Subject: [PATCH v7 11/12] libnvdimm/pfn: Fix fsdax-mode namespace info-block
 zero-fields
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, osalvador@suse.de, mhocko@suse.com
Date: Wed, 01 May 2019 22:56:21 -0700
Message-ID: <155677658129.2336373.14466297657474148349.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index 01f40672507f..a2406253eb70 100644
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

