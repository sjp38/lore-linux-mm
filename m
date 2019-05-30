Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74007C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BDEE2630C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BDEE2630C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E19FC6B0287; Thu, 30 May 2019 19:13:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA36E6B0288; Thu, 30 May 2019 19:13:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C92E66B0289; Thu, 30 May 2019 19:13:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 942456B0287
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:48 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 91so4904510pla.7
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=YMgYp1mW1UbkaCFwuYGS6OZUOqXORkNmF9ijUZyqrbk=;
        b=g6KhcwJUHjWot7I/EmF0TgQ+7tDzvffQWqeXdvpL7gXda5nT+CDVxj3Cmr0nRGtrZY
         idr27LYpf38C7cez7RuxvBU+ikZVE2FWkJr5foF076rAjdrreFKnonJAZMO5A1r/M0sX
         9pHKB4AtSrZHhX4lWPXJSqfbXp0z4ZxFis6aWM4auFo7rXeQIJrOlYuoFrhRYxqxJms1
         U4cfOYVgT9dXPTUg1QJpfpUGILklB2kyc+vPqW/pTouM90hZqHD8Yf/BgbRAnfYyhUkp
         nx4fWoIpiAo7gPN7dRUzqG8QkboK2khpWK6h3ntYrukzb7omq0MV4kLVk97QSDI0+5my
         vcbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVBAk/o0rCMUAtpn786RRMKP0HA/PAPyXO6mjii1VpS8hH2wLA5
	noIva+TXTx8+ItY5mDXiuJMY7vOxkAqEeSSGNUksQzAFTNfrP93W8l4QUunu5P8RC/mgFAaKKg7
	L/ugtE9f64QJa74HUWiY19Cu9I67wrXgjq8VhxA9wKnb1MKZz45ukw1Fc7iUe2WugVQ==
X-Received: by 2002:a62:e803:: with SMTP id c3mr6064418pfi.58.1559258028228;
        Thu, 30 May 2019 16:13:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBO7kgcD3GjgWc48q1Of/7xSQ8BR4wONPS5FeTAGyK/Nof22G0LOrptVxBJV3ineLpBc4L
X-Received: by 2002:a62:e803:: with SMTP id c3mr6064367pfi.58.1559258027592;
        Thu, 30 May 2019 16:13:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258027; cv=none;
        d=google.com; s=arc-20160816;
        b=M7P9jiQWG07NJ305m1d3Q0NuYlpTjpYu/o++4lvCtCmLZVCgQvmaLFPdOsAfu83xl0
         UxZ1xou79xXuiMPBZctFpaq/5RPNMe1ykMTYHUkMCIrsl1pZd0FhsXJqFA/2D9NskPk2
         GXLPFxy442anZcNvMDopps231izGemMHgvWNwdReZDMAbuos1NH0U4YDRC26+HULWjdq
         cSSdtYxKoNc2mDXYd9EEnQPzU9kuviJ0CnxXDUZeNw4/ps9rZL1CrWXYVMy54mXlyyHi
         wIBr8zdRwk5zem/LLfhXYTOswEssCSmcMjVRjB5PSQ5OcEyRqGOArawxqWi1Gs5wAHYU
         6ITg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=YMgYp1mW1UbkaCFwuYGS6OZUOqXORkNmF9ijUZyqrbk=;
        b=vgKM1dEIJ4PDNkWkhiSQqbnqrKgUgtzxYqRbLjkcDwA1Nc+VzEHUNcIXenHjhXUcT0
         Yug06gCbA9fV2icoNk9UsJ/feJNO60rC8x+JcMB+ZrCMgL+t2U7miqoLTvIqtgykK7v2
         mdC7tuWRw3wLs9dzyEQn6j7cDpJ/WP892+oxv8TddxqtzcMIGItKCdaI4MAULb+XOw4m
         eVwev+fCpa7JNw64ZJj+VFW35927e2AFvWRdfnXLU3+qgalzN3h92/QDtFhRiDV/Tvz9
         q5UUGtTbg/9sdsAe1GU5nrPUWRYK+nW19PEWYfyxgi38AbZUK2Q7UqlbDMDbjxgofUOQ
         2UDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u7si4646865pfb.223.2019.05.30.16.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:46 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga003.jf.intel.com with ESMTP; 30 May 2019 16:13:46 -0700
Subject: [PATCH v2 7/8] acpi/hmat: Register HMAT at device_initcall level
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
 Keith Busch <keith.busch@intel.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>, vishal.l.verma@intel.com,
 ard.biesheuvel@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 x86@kernel.org, linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 15:59:58 -0700
Message-ID: <155925719885.3775979.7601024961163509938.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In preparation for registering device-dax instances for accessing EFI
specific-purpose memory, arrange for the HMAT registration to occur
later in the init process. Critically HMAT initialization needs to occur
after e820__reserve_resources_late() which is the point at which the
iomem resource tree is populated with "Application Reserved"
(IORES_DESC_APPLICATION_RESERVED). e820__reserve_resources_late()
happens at subsys_initcall time.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/acpi/hmat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/acpi/hmat.c b/drivers/acpi/hmat.c
index 2c220cb7b620..1d329c4af3bf 100644
--- a/drivers/acpi/hmat.c
+++ b/drivers/acpi/hmat.c
@@ -671,4 +671,4 @@ static __init int hmat_init(void)
 	acpi_put_table(tbl);
 	return 0;
 }
-subsys_initcall(hmat_init);
+device_initcall(hmat_init);

