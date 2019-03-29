Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22C31C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DFF702075E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DFF702075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 853A46B026C; Fri, 29 Mar 2019 11:40:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DA016B026D; Fri, 29 Mar 2019 11:40:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A2236B026E; Fri, 29 Mar 2019 11:40:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 311F26B026C
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:40:20 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 132so1863728pgc.18
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:40:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=BGW5opGcfChg9t4SQtyg6XKafZpTItiwM+WiiS4PyGc=;
        b=erA+x0liE8JNlMJEQ1e70Tdydd4nt8j6RPFSy2wCQgdrll7EuHGk0LyLCoaQG2Ke8n
         I508I3zaxwfZd5ltiMZB4EA92DtfDhPFvRfXdYDPhItZbyRa6T+9Q0U8gSQFNeQYVUby
         lnrnrn3xwq5IfBkSs8QySJk5xljnH/wmE5gysjg8THtuSwZRcJArBX1AK6GRLd5w5bvn
         OeoEM6IbQpNCyz0re9nAcuibZiLhqk1bSF+RC6G5G4UpmiJEhN85UYjwNki/IvhAnkBP
         7DrV0wF8WhvjnvyheJXsn7ged9AphWsRSZg2NF4DX+xTJiI/U3aUIh7eqGADE07lRjHX
         sdMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWN4KN+NnK4kGegJ45YtX46LQPov81gu1NPxQJoxN1a5CgDOtes
	OFNW21qQdq+R2K5aKhTF9oQhRGakO+NWWFXguuCa7eHnKwfuRNXETnP9yuNIUcRMAp7MXGXQ7td
	UhoVtlcMgR0D9maqAYRFWIiuW8XndiyGaokYoFSLylmyG0gd51CpnGhHkjVCUCozQGA==
X-Received: by 2002:a62:29c5:: with SMTP id p188mr46566593pfp.203.1553874019861;
        Fri, 29 Mar 2019 08:40:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ7Vj+GhSe7doVWE7quJHMKPcpDcyieQJMChsITRkNhK7WFdBwJAMpW0H7AxVVEUYPXD8h
X-Received: by 2002:a62:29c5:: with SMTP id p188mr46566530pfp.203.1553874019097;
        Fri, 29 Mar 2019 08:40:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553874019; cv=none;
        d=google.com; s=arc-20160816;
        b=Z52BYTYAxCgQ49CbWIMRM8aT8TSP1sZ5OB561uyUMoxVb4JCm0yHIl6WXTDGYukBoh
         Qm7+znt1mjN0jSBXSvm6Z9KZGlwXohp63+HEKeST0O8TpoCa/UvnrB9zyXML5WFaZT1e
         wSTEoLGoBw6b7T4yD62l0aE4ebrBvU2zMk+tYOiswKXMCzKL2Iwp9enw5YgJBb+09h9y
         w9TfVu1K3/z0PJ8dRL1jv7oXju18OHadmKpIYbE5AnhP+RCpIGuzA1AcUKtpId9UShuz
         bNI5hPzMdCmYsPqNDtZtNRXrjywnyOtx0Q8HAcyIxvKacF2pG9vA3c2n7SNygRmI1edm
         5ang==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=BGW5opGcfChg9t4SQtyg6XKafZpTItiwM+WiiS4PyGc=;
        b=VyB6nLKWRa/8KXDlxu0sTCu5jQaSsJ9oPAzL3mQmdI+C5jZlaQnjZD4W75iW75Vy7P
         VWjeFrQOZyygOxoNJd1UeqZgHsj4EpH2TLnonWEzM6FbLYQIQf1gBzc45bz3fWo66fAn
         EOU19AVhi/6JcBw7rljto4Xq8XEgzOuAfdyjb2C4knLBER4WQ4XLI32zcJKOOgaE95ls
         Sb6sAARW3WsmtTiz2fAtYDk/wIhMWeMzqA8Qe024swYORHO1+FMaoN5dAWPczgDdMifT
         Scc6ExYZi11+19/4IS4hapnlSOb6yGbUbYGXGKC4TywfRREA6lM4g/w+lADHL+0qV67q
         U7QA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g3si913456plq.400.2019.03.29.08.40.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 08:40:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Mar 2019 08:40:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,284,1549958400"; 
   d="scan'208";a="138515813"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 29 Mar 2019 08:40:18 -0700
Subject: [PATCH 3/6] pci/p2pdma: Fix the gen_pool_add_virt() failure path
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Ira Weiny <ira.weiny@intel.com>,
 Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>,
 linux-mm@kvack.org, linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Date: Fri, 29 Mar 2019 08:27:39 -0700
Message-ID: <155387325926.2443841.6674640070856872301.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155387324370.2443841.574715745262628837.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pci_p2pdma_add_resource() implementation immediately frees the pgmap
if gen_pool_add_virt() fails. However, that means that when @dev
triggers a devres release devm_memremap_pages_release() will crash
trying to access the freed @pgmap.

Use the new devm_memunmap_pages() to manually free the mapping in the
error path.

Fixes: 52916982af48 ("PCI/P2PDMA: Support peer-to-peer memory")
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/pci/p2pdma.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
index c52298d76e64..595a534bd749 100644
--- a/drivers/pci/p2pdma.c
+++ b/drivers/pci/p2pdma.c
@@ -208,13 +208,15 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
 			pci_bus_address(pdev, bar) + offset,
 			resource_size(&pgmap->res), dev_to_node(&pdev->dev));
 	if (error)
-		goto pgmap_free;
+		goto pages_free;
 
 	pci_info(pdev, "added peer-to-peer DMA memory %pR\n",
 		 &pgmap->res);
 
 	return 0;
 
+pages_free:
+	devm_memunmap_pages(&pdev->dev, pgmap);
 pgmap_free:
 	devm_kfree(&pdev->dev, pgmap);
 	return error;

