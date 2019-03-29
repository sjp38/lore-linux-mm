Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A2C6C10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 160E6218FC
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:40:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 160E6218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D9E86B0269; Fri, 29 Mar 2019 11:40:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 960466B026A; Fri, 29 Mar 2019 11:40:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 828CB6B026B; Fri, 29 Mar 2019 11:40:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9BE6B0269
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:40:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id e5so1931145plb.9
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:40:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=OrXAwKmXL7Fav/fo5UPjMYEgsfO33kHnrLyMGw9gRbo=;
        b=pNEqDLa+8nM+LFMGS4iCAifJdU9dTa8rmA7nZOH0Y3lG4hgHnwRz/6kZgiYjYtvjih
         T8uGN9jwsIrFjBdGgwaKXUll+QPIH1TDwK/NBcw8ret/L7yQPdOoEe0AqdQYHgJQeNno
         582eJbl3ulOFSDzWQoP26sWq5I/YFFDxBFDIR3vnmo3eklXCgj8GWpd4fq4jsgOGRV+p
         k1n32Kk29cb8j0mcTb+2iL0jmvHsWv0pkREAAoPwt2PDw+kFamnGRQcCqRVlT1WYT9N5
         RRMjQywHcWS5VzFrVDPR+w1AKmVtgvWaIFS76yXInx/xlsPAZcDwUaYrTh7/vLcS/Puv
         eRnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQ4FG8SzVdmXUBScPZsMY8Dvcjtg+IeHY+JfYy4tjFQUXLhwwh
	gFQAZV9LxknVVYeUpLuXLsVQ0XBYKpk8xYkCCKmZ/0uIFPnej2L/9SywsrNhBCGrhGqTmxkQirf
	/4XIsbyvNup2OyPbXrl8sXKsOMw5VajquYNDLxOp2mOpq5Z65aokjPllArFLEFJwR4A==
X-Received: by 2002:a17:902:8c8b:: with SMTP id t11mr48539238plo.148.1553874010904;
        Fri, 29 Mar 2019 08:40:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwtPzbEVnKfARpT/d/pOSuWxEClwR1sFULldMFLDU0oX0Wgy0EOuiJGTSLZdlh/vj65b0Nz
X-Received: by 2002:a17:902:8c8b:: with SMTP id t11mr48539176plo.148.1553874010189;
        Fri, 29 Mar 2019 08:40:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553874010; cv=none;
        d=google.com; s=arc-20160816;
        b=XhecvNuy5QxumKjRBNdCv0UUOek7Wt5dS7W4uVcXyPCvgKzIzV9wXjyPdGFJ/FCKJs
         jBDTV6HrTmHXgeXexEPRPJndKxM4fNW/HzP3QQrRAMUWikcKAaIeh2CZZHK5zrj4rfvr
         D0W7pet6lCaf7kS0x7181a4mpdpRM5OFNExHjb8mZH4Cla41dok1TGyAwB3CMls/WEwN
         xrcq/w8ypVxOJAk8amZZEd4GgcDu8p/tkALF1u3gc1B/ee7fCWjz3lfqNLlrS1YztARl
         J7vF9cyHmZPCuSwBRBQsSTOHnk4sRkh/KugMsqHMe7T1SZ6WeNTK3P/phvUUWs2Vkxr5
         of8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=OrXAwKmXL7Fav/fo5UPjMYEgsfO33kHnrLyMGw9gRbo=;
        b=CWGLXxoIc5leCslxe3tS4d8TozmIs3o3pX55Zyy6F9V9ton7hFqabgf2nlnjeR5p+g
         FChW9QGy8zkS35j82H2kuzdUYYtE7Ewabza5Me6llBe0ytvvbe+PtsdV3FB50NwQ9Vmg
         OOPJH7CUfr+pohzf4Ui7mAAmA4zDxigAGhtHT1ix30j+BzfD67BpHRXJNfq/UZyBwzZT
         OFjb5TBmPm/Qye9TfFOBpbYYgX9/0FCeGe081/bzjPPIpNlS+/b4G33nAp7LqWsqHit0
         BYHITTnJu8htpIn8W2JHu5WHOCU1Sssrlw0gcZPW5qVDcJi87HGKYGM1FRSrB2TfTBEs
         9wQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id f2si2160945pgv.441.2019.03.29.08.40.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 08:40:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Mar 2019 08:40:08 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,284,1549958400"; 
   d="scan'208";a="126977111"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga007.jf.intel.com with ESMTP; 29 Mar 2019 08:40:08 -0700
Subject: [PATCH 1/6] drivers/base/devres: Introduce devm_release_action()
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Logan Gunthorpe <logang@deltatee.com>, Ira Weiny <ira.weiny@intel.com>,
 Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, linux-mm@kvack.org,
 linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
Date: Fri, 29 Mar 2019 08:27:29 -0700
Message-ID: <155387324904.2443841.8406657131473708859.stgit@dwillia2-desk3.amr.corp.intel.com>
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

The devm_add_action() facility allows a resource allocation routine to
add custom devm semantics. One such user is devm_memremap_pages().

There is now a need to manually trigger devm_memremap_pages_release().
Introduce devm_release_action() so the release action can be triggered
via a new devm_memunmap_pages() api in a follow-on change.

Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>
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
index b425a7ee04ce..02a3e45de9af 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -715,6 +715,7 @@ void __iomem *devm_of_iomap(struct device *dev,
 /* allows to add/remove a custom action to devres stack */
 int devm_add_action(struct device *dev, void (*action)(void *), void *data);
 void devm_remove_action(struct device *dev, void (*action)(void *), void *data);
+void devm_release_action(struct device *dev, void (*action)(void *), void *data);
 
 static inline int devm_add_action_or_reset(struct device *dev,
 					   void (*action)(void *), void *data)

