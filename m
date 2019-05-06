Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34C46C04AAD
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5CBA20830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:54:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5CBA20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 957CA6B026C; Mon,  6 May 2019 19:54:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 906146B026D; Mon,  6 May 2019 19:54:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81D386B026E; Mon,  6 May 2019 19:54:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4744C6B026C
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:54:13 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g89so3418298plb.3
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:54:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=LKvk91HhP9ezsuBTNBJqcLkpO+1Sux7+j9Ueu/2PT+g=;
        b=RvVT+FSeWZNuz94mEyL16/o2ZQvwWpDIb3fHcvyowpNZDxU3nogMxxaQirb9F4mKMV
         6omTm5h4RjnCND/QmSe7AIqw73FuP9xnlb3+eLBRMUfK0zMj1hPk5gMlaXo2Ulc6l7UH
         Q1mP/RFmclYLMv9ZjVgnqDBK0qPVaZ9I2yHBWfAC+UaYt7oCBrPtqbhhM2mSRQDCne6Y
         mYQxN8wA5EOZqDaNWO+OXUzLM5k/KMh8pKqoYgC3ljTw96xLrNDUU30OwXetHNY0tQvo
         Iqc85qVIUfiO1ucRbb8/Sphy6+CZbBMzP2dXaT8FGyo1IyxQhPVWK79Wix+t+tRvzMR3
         7olQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX93qYgjKOvmiSW+ams6do/6/e45lLDwWt8xA8XvAJT6olSxsCK
	/28lHqjxfMkNCKput2HTiE4M5MF3seDfggMMy1xgde0bqMUBIn4oodl1JkPK84qgf5RY3VQwuLc
	wmFuvZ5YDcFfOIInaW1SZnEWwNdTFz96VzSS9RuMXpQ0+DFEcq0G5pBfyKuXcv1Hvrg==
X-Received: by 2002:a63:5516:: with SMTP id j22mr33901288pgb.370.1557186852927;
        Mon, 06 May 2019 16:54:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1EYJoW/p/3z65+0GiJnfQU/0tVpkJxYFXI5HyZwLf2FsYET7AlkoOIBoTAGq7yMroOhV4
X-Received: by 2002:a63:5516:: with SMTP id j22mr33901229pgb.370.1557186852023;
        Mon, 06 May 2019 16:54:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186852; cv=none;
        d=google.com; s=arc-20160816;
        b=THZaBz4iK9O8JjksR+fDyF3/JW7dMBvmWiKArH8BSIKtTDaebGrHcFVRo91ZDUm/kn
         kPVWjdz4KJ1VnoGjwywCfL4jQYtLLO5LhqopnAb1HSppTMsWDo8fKZrGgB2lt3nIVowX
         SoNE9f8rpLOHJwinl1OnMYThM4Uk6BN8GQ3F/qeCA4ksToGSmfOeU0nl/VtRn183MFJG
         II7kG4WvXffSVYvINrXaBpFUuUg2UrJcFdiW3amGPycx5wZvAAT+kbG/ZtfJZ3c0Xfu1
         toeTfvu0ss56u2Tu+yYhnwK441uJpvPNtIj5cisbGQEHHVYvaI8Z3SixNnADtuNhYl82
         a4bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=LKvk91HhP9ezsuBTNBJqcLkpO+1Sux7+j9Ueu/2PT+g=;
        b=rZ+3Js+N1uIL9gJq7jwEwpxzOALYy4NxV15wYij2gYsD/1bKF0csDXtUhRfXyCCgIn
         WANSCl2XIngLkf2cqSZgs0ERfdROaX16e6aSTt+BTFiTbI14upwqaqmWu7yle5aoFbEZ
         aQauG5fQbRLC7rElSDRAXbr6u9hYz3eXjQGsg/QeSvWAjg0TBRRcyRllz/Zc4Idd0kw5
         9CEYmQWqasGXkCe4+DopQYWUjxOTkS5/0COZvMTxGxb/pmJagr5jnvh8nP9GJvHsDV9r
         TiY0dSPozhSHQ6YQDx3woasGNbdU4O/Iz9x3liAu1zfi9UaV8elJVUYDFDZ6/seF7Ba0
         19KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a23si4805149plm.385.2019.05.06.16.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:54:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:54:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,439,1549958400"; 
   d="scan'208";a="149329913"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 06 May 2019 16:54:11 -0700
Subject: [PATCH v8 11/12] libnvdimm/pfn: Fix fsdax-mode namespace info-block
 zero-fields
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, linux-nvdimm@lists.01.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, osalvador@suse.de, mhocko@suse.com
Date: Mon, 06 May 2019 16:40:24 -0700
Message-ID: <155718602469.130019.1073417828141766553.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
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

