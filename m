Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21F0EC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEB9320663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEB9320663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7AEDB6B026A; Wed, 17 Apr 2019 14:53:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7891E6B026B; Wed, 17 Apr 2019 14:53:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6756F6B026C; Wed, 17 Apr 2019 14:53:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 305766B026A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id l13so15201890pgp.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:53:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=LKvk91HhP9ezsuBTNBJqcLkpO+1Sux7+j9Ueu/2PT+g=;
        b=nUo9UiHaslRPzOR0kDdO+gY4qrxo5dcZu7LOWbsd6XtoFV3sNqZUIYFpCjz/XJHYUp
         cDESuK8UAW4H4lIHiNbJ9GwXhw+E2Ygy8IITIPutAKj8auS5p1BV9xhCsDL0oJ+JK5F7
         M5Y9Sw7GBUupnxDGR5Iw1IIOB4Gykc4GIqtlFQb/nGlIvXXXxjm8F6nmLthLvvrTO+ji
         fEyfc7OhrPj4vx0nIRba7Sx8/iJcXWfmw1Cj74CnYs7ygxisgUhvMwHrzEYUmjWVpxmM
         wQ5wJMGW19CSF84Xfc6JveAWFb+eIKuQwddjJqfwx4ULM0e/UKTdBJ7uZp6Ag0tXBed4
         S5Qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWSWoOaBnRdzEZ0YAceqjUQcyeH2FCw3S7ZZjrznsrU7WefcoRz
	7QQfLp9tKiz0aK5OPWwa9elsN38YX5BgKapmK+g6i/7oNEN94P46tov+sgvoYCI7nAyNbM7wSgt
	ZJWwI500xWRsE9p9Ghvbs9mjWYkkW7SE0sYBps4lk4n6zpjZfytXdRGUOiACAei0GSg==
X-Received: by 2002:a17:902:e709:: with SMTP id co9mr91886573plb.86.1555527220851;
        Wed, 17 Apr 2019 11:53:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJdZI34+1k08LPQgevX6HEzfndhVxUHBi5ov+UZWxGyeHH/gjVVIxfLldDC+FF8tjTyL45
X-Received: by 2002:a17:902:e709:: with SMTP id co9mr91886496plb.86.1555527219674;
        Wed, 17 Apr 2019 11:53:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527219; cv=none;
        d=google.com; s=arc-20160816;
        b=qF3wYxcXnXphq4RGeDdT5OaWEVtyN3Ge6ms4NNJzN8O3deuCOv50xVkNuX8LsxciGx
         RECyZXdGeqU0y4zIX7swpoBYT+cHNrwZvpmX7Ek7MEu/Gvx0reTpFZtzj3k4LdM7liQn
         uuGMEvUWARRe8w//Ss16SIDyBOey06qkjDWOudfPuRRSmIMFyR381ZZUr4UUVdyXHu54
         ecCb3vVv8XdNVTuxBdWge5IxY5oWel5vBTJclQfgCUcE6ZRo0bWBUvLGZ+YbaUqswATh
         D3qr25ltF9Yq6cbjuE4Oxj6s2Th3lkWPN9Mle6ufm7TnbjA4IjE9T0HnKDMy53jbKEjk
         cIig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=LKvk91HhP9ezsuBTNBJqcLkpO+1Sux7+j9Ueu/2PT+g=;
        b=z2mA4+HeWzKR1/l9uo8Fk1FYDvGBs9r853WM99obxdrjmFX9ztIp9r215M7HqduuZ4
         OcGvL519EToWR4oT7T+nrUsqv7Gb73KyuvrpzvQKk5+b9gSxTn8Hs1EGxQ5f+/9O3/uq
         d5LLll/VmjhdMeJGP520nKfYP9ZmgrWJigwg7zqAsr6MGZca+/eIZZT4iKh2RMT4dZxK
         40JUfvFPq+qX8zmtxFrze9zu0AOx2izJS/rJa6Ja3ORhlRz3PRx9lYT+a/uZbz/GkBMU
         /ZkCs/YdhVxecwoA43vCNrFR7HBrxvBbvfgNQ0OlnEXM/fivhrswE19Sdfm5sKaoa30T
         Bzfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d23si50791866pls.151.2019.04.17.11.53.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:53:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:53:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="338528135"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga005.fm.intel.com with ESMTP; 17 Apr 2019 11:53:38 -0700
Subject: [PATCH v6 11/12] libnvdimm/pfn: Fix fsdax-mode namespace info-block
 zero-fields
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org, mhocko@suse.com, david@redhat.com
Date: Wed, 17 Apr 2019 11:39:52 -0700
Message-ID: <155552639290.2015392.17304211251966796338.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
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

