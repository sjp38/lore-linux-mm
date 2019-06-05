Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8469C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96AD220717
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:13:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96AD220717
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 488636B026E; Wed,  5 Jun 2019 18:13:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 439446B026F; Wed,  5 Jun 2019 18:13:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3282F6B027A; Wed,  5 Jun 2019 18:13:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F10866B026E
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:13:17 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a13so98957pgw.19
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:13:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=LKvk91HhP9ezsuBTNBJqcLkpO+1Sux7+j9Ueu/2PT+g=;
        b=bXFsx2GRZJdYcBWW8GnN92biCo4ZSNd9e6INpaamO6QUbhYFVKze/A4wIVtrU1ZHlq
         rUI7rqRjcMZ1Z2YoB83Ekx6P3ar2trgQidJmzrJXelOSHRB3650UlBycW3XWxP3oE+Br
         7FyXlMSQrv0pH8FidcAPOFEmRkXZWVOW9p63j/53bjXwtgwjpJLzahrv+9hdSlDVGZ5q
         BXXAhBxlzfioJM5BZXaHcVTz4SnYNbEkK7UVFSsl8/HNrp7PWknoGtzJdEBrtsznlRIz
         C90n9wfVtGxxB68nZSESSXxy6JhB6F+zc37W+eu9Uxml50DiKY4DwmMUVJuvMU6l+US0
         Ab/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWIo1E5l1T0O8udwD2PedwhrY9mCTSEY7nO2JpwtQBQXznAbyRC
	CgtTImqshi57bFg4BCyq1o/NcBfIiK+i6Vf12OUGsp9QPQhEmSwBskRO1gxLSWBEdIGhx+F/lUf
	jde4CctkM1zoNYV29LYNf9+XbtUS9Yq+dc8iV8knyzrRWyjNz3OPYMkvt2r6kdgjzsg==
X-Received: by 2002:aa7:83d4:: with SMTP id j20mr50912403pfn.90.1559772797466;
        Wed, 05 Jun 2019 15:13:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqylDL+Le/zO/mDWoAEo5olviI84hVHoAXlFSQ9Pq1HsZFoWqkRsznTkZQXAhEzbNoJs2uCi
X-Received: by 2002:aa7:83d4:: with SMTP id j20mr50912224pfn.90.1559772795964;
        Wed, 05 Jun 2019 15:13:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772795; cv=none;
        d=google.com; s=arc-20160816;
        b=gGryb6oyPBxAdBKeX1wAN+bNMHYcViH8nwjqC/g4Nyna1Z+5/ms5XebxWd9QqoVDp3
         nhcYGwUaGbwRkjW2lyY8YIsDXE6XvpXVMbhy45bjY/BWd3+1+yZ71shj2vH6AFc4sR6V
         xf6nC43t/ouTy8Fo8e1RuJ/RtOI4AQq0uaUeb85Uri5k0iFxLGvgCs++GhN0cv/kyzhH
         6JMNpbcouFogXl49rk3ngQmI6UnliDZueo2REyIOZoV+wSDmJZoBHs+T7yvA5VkOb+/S
         nHVcpaARV7ho1p3HCXraZO4WXEu/LFaY1qLr4lPEkwlt+PoxQyj4Nvmh1uYFOxcp8s9Q
         6AiA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=LKvk91HhP9ezsuBTNBJqcLkpO+1Sux7+j9Ueu/2PT+g=;
        b=xyvlTPTr0bXwUPnUa75jb5dzI2QjN/3xgb9uXyCenRFZJTbkPB1CJYEzx+SjO9RE9d
         gkmYIexvOD+GbEvJ1rdP9MxWN5zFjtapgBoCo7bC9mXSTv9meAQeAUB3r7RATyfZaSQZ
         B4pslN5q9XKWFcn+ER4Yt2+4uyiirdCJNRJijVZ3DIE9fIomLaAagIhrr8RcW7Q3ewAZ
         jloq0I1mIjni1QCWtRyE3cYARi68MPZbD8cHQrESGdswyArRkge8oVNY+CvmASRSpHqk
         snvBy/dYTjVd+X8zFfyewBtd68A5CJZAKvVNQcjRjS0Nffvu+5mjFljSKgMihYRLgYU3
         c/ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id v4si33263997pfn.197.2019.06.05.15.13.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:13:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:13:15 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga005.fm.intel.com with ESMTP; 05 Jun 2019 15:13:15 -0700
Subject: [PATCH v9 11/12] libnvdimm/pfn: Fix fsdax-mode namespace info-block
 zero-fields
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org, osalvador@suse.de, mhocko@suse.com
Date: Wed, 05 Jun 2019 14:58:58 -0700
Message-ID: <155977193862.2443951.10284714500308539570.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
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

