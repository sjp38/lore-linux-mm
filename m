Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 366DBC31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:07:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC09720B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC09720B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92DB96B0266; Wed, 19 Jun 2019 02:06:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9047D8E0005; Wed, 19 Jun 2019 02:06:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F3908E0003; Wed, 19 Jun 2019 02:06:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4377B6B0266
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id e7so9232591plt.13
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:06:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=OS6R7QuDwLu8nlVNMCTkBEkzBtl/n8KHFbc4UGW5JJU=;
        b=FRWDxJSlBYQ6asdexJ91SZFbkXbxb7YP8Q5ILgHA+D1TwwVgHEltnMkwUz99xpSxsU
         Hnf0ZenAGzOuAp7K+8rZBmcjR3HTbDeLiTmOif0KGnfLa2y/04lUgYGvQIqku1Vbq18M
         7oJphjeWnP+4NRUgAMYacs9WLoDQqFCbgkL92jS3PiUL+yCZQEaQtMhGmoPGQ6aflqvw
         6TB3mId16txagYZY9V2D5eQMkD0bJ7/Dz5XvIkow2g64Pmx5kwhI6cg3chHIOwbNIYYF
         zs0dONgfJvQHt95XpnYLSo/zQt8TUUmO8R46UEZBJTf94Qm98yFuJTh2HW6U7afiWL1J
         YoOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV3bStH+iBoFCF9Ls+86iuRUpH3k7WqXAQzLu9Wm+fifuCfqvhn
	wBINU890E8DMNyjovodVxCFy5An2INKJAXpQBxdvv2U3nkv315fx3Z0Khalih1Ig5ezDVg4+MHe
	aakFl5CqL43K1LxftyK7NRZR1awDmLtWGodWJy1FC2ci4pX7H25A3EWBKoxTVyoNEFw==
X-Received: by 2002:a63:c302:: with SMTP id c2mr5801302pgd.300.1560924418866;
        Tue, 18 Jun 2019 23:06:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysWob2GzTyPmBDirH6WsNn4GKf8qa9Gme2Cu+EbH0I0y7UOV14HXFFA60cGF0SyCcVlnRv
X-Received: by 2002:a63:c302:: with SMTP id c2mr5801261pgd.300.1560924418008;
        Tue, 18 Jun 2019 23:06:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924418; cv=none;
        d=google.com; s=arc-20160816;
        b=COztxxgTVq1q87EAU6fy+j6aQ3XXleh2bziuFwTnblkMjq4vdqmJNtbUiTjaYx+8+S
         90NPpI7fS3n628kZaFvWve0Uahwcv6RWPxRWYsHDoEM8oYs7nAit4dwPFf+fAbynlKOz
         fchvWi0zKc1KUZ4UJDh/2aD7uO/zylmzRuo53CdMo/e1WV8vFDEBpq6R3VrSEDTqnebd
         Pwh7id4/Oc58IVBUrE7/Dkc7hEp4+cYRG1kgHD9WnjR8NK2d2z8NI6lTDmnrHR4O+rRE
         2Cn0nBfJrbUsmAyLE9KZmcSDzBQHWtUrH4efO/ibkmDMYjOAJSW0TBzm/0QFcf+25ZUe
         caSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=OS6R7QuDwLu8nlVNMCTkBEkzBtl/n8KHFbc4UGW5JJU=;
        b=BWrJLSmaarFTZzPcKNbsuRDHY2aTOZyqHZ+bKJFMZ6v+NVR7YN1v7VS+Cl4OlYo2ON
         HQKuyPcvpDW6zfiE4t0oLz9+NaEb+vW+WGlLMyQy/lhr1BHVoTHk/WLPRxjDNqN2JKeM
         ngdCCnGPlP1kV0LsEd2VQX6ruLyaF+idLUvqdZrDtDQVc3FogfKG263QuB6L8HjF6ySP
         DW1MNQ6SjNsvSfPMvE/N32yNTgYTDtt9BoXBcfjFU88UaeS5h6FmTA3dYp1FqncELYxD
         8YGjaX9KQzwqQj+aLJ8ik6T6xa52+kZAb3+h55lPwKXhIjit0PTMxX9bC1zV0vtEUO5z
         Mxvg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d191si2136202pgc.460.2019.06.18.23.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:06:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:57 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="150512526"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga007-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:57 -0700
Subject: [PATCH v10 12/13] libnvdimm/pfn: Fix fsdax-mode namespace
 info-block zero-fields
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:52:40 -0700
Message-ID: <156092356065.979959.6681003754765958296.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Note The cc: stable is about spreading this new policy to as many
kernels as possible not fixing an issue in those kernels. It is not
until the change titled "libnvdimm/pfn: Stop padding pmem namespaces to
section alignment" where this improper initialization becomes a problem.
So if someone decides to backport "libnvdimm/pfn: Stop padding pmem
namespaces to section alignment" (which is not tagged for stable), make
sure this pre-requisite is flagged.

Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
Cc: <stable@vger.kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/dax_devs.c |    2 +-
 drivers/nvdimm/pfn.h      |    1 +
 drivers/nvdimm/pfn_devs.c |   18 +++++++++++++++---
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/nvdimm/dax_devs.c b/drivers/nvdimm/dax_devs.c
index 49fc18ee0565..6d22b0f83b3b 100644
--- a/drivers/nvdimm/dax_devs.c
+++ b/drivers/nvdimm/dax_devs.c
@@ -118,7 +118,7 @@ int nd_dax_probe(struct device *dev, struct nd_namespace_common *ndns)
 	nvdimm_bus_unlock(&ndns->dev);
 	if (!dax_dev)
 		return -ENOMEM;
-	pfn_sb = devm_kzalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
+	pfn_sb = devm_kmalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
 	nd_pfn->pfn_sb = pfn_sb;
 	rc = nd_pfn_validate(nd_pfn, DAX_SIG);
 	dev_dbg(dev, "dax: %s\n", rc == 0 ? dev_name(dax_dev) : "<none>");
diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index f58b849e455b..dfb2bcda8f5a 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -28,6 +28,7 @@ struct nd_pfn_sb {
 	__le32 end_trunc;
 	/* minor-version-2 record the base alignment of the mapping */
 	__le32 align;
+	/* minor-version-3 guarantee the padding and flags are zero */
 	u8 padding[4000];
 	__le64 checksum;
 };
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 0f81fc56bbfd..4977424693b0 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -412,6 +412,15 @@ static int nd_pfn_clear_memmap_errors(struct nd_pfn *nd_pfn)
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
@@ -557,7 +566,7 @@ int nd_pfn_probe(struct device *dev, struct nd_namespace_common *ndns)
 	nvdimm_bus_unlock(&ndns->dev);
 	if (!pfn_dev)
 		return -ENOMEM;
-	pfn_sb = devm_kzalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
+	pfn_sb = devm_kmalloc(dev, sizeof(*pfn_sb), GFP_KERNEL);
 	nd_pfn = to_nd_pfn(pfn_dev);
 	nd_pfn->pfn_sb = pfn_sb;
 	rc = nd_pfn_validate(nd_pfn, PFN_SIG);
@@ -694,7 +703,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	u64 checksum;
 	int rc;
 
-	pfn_sb = devm_kzalloc(&nd_pfn->dev, sizeof(*pfn_sb), GFP_KERNEL);
+	pfn_sb = devm_kmalloc(&nd_pfn->dev, sizeof(*pfn_sb), GFP_KERNEL);
 	if (!pfn_sb)
 		return -ENOMEM;
 
@@ -703,11 +712,14 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
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
@@ -760,7 +772,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->uuid, nd_pfn->uuid, 16);
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
-	pfn_sb->version_minor = cpu_to_le16(2);
+	pfn_sb->version_minor = cpu_to_le16(3);
 	pfn_sb->start_pad = cpu_to_le32(start_pad);
 	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);

