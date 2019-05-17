Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18DD1C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:54:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C40382133D
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:54:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="MAG7Kwt5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C40382133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 739D16B0005; Fri, 17 May 2019 17:54:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C4E56B0006; Fri, 17 May 2019 17:54:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53D6C6B0008; Fri, 17 May 2019 17:54:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEDA6B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 17:54:44 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w184so6958059qka.15
        for <linux-mm@kvack.org>; Fri, 17 May 2019 14:54:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=qCg59FDZEI7vFMLxdjNevVM1V4NtcKPGHCKQp1V+IWHx7i+O/1FDLvzHtdrDRK1iNJ
         jE0Y9CLFCPwAzklxdet4Jn8RFf3tsMtlSP5QfuPhwWvz3+qCNvaLyKHEkYsHNqJk3OcM
         3Y+PgK45zsIGrrrXYMM/oZSsD9dAbNj43kbhkj+KXqWXS69itpGRz1GeQuDjxMw5ZVzj
         JjjtNu8cw4RCqAP3KqBTHjj81lnwHq/aQXbtcB3ym2F+PkiJIMew3wV/NXMG4bZqBhen
         7xQc0lQgxXZFMV5x9HEszHN7EM2cZMhnsOz5JtlGyPm190Ky48JWnuKlb0DCCow1VRcb
         ro3g==
X-Gm-Message-State: APjAAAXzzRugsLJKHTofkZTQju3KOt20ajnYTRTKMgOXEMa0Owzeld9e
	VRJSAPsy+9UrtYj77qpN4gCIuIuRSy89Hx470h10Jqw5MLMYJQRAXgDcdamLk+2rDK11B65RGqu
	8bPYHmmvnvSaw0lWy5dfoEtASD0cLdN9K2GEJWTobJOAjqlnZm3RGEgtXegJFdxEV7g==
X-Received: by 2002:a37:f50f:: with SMTP id l15mr19292490qkk.343.1558130083790;
        Fri, 17 May 2019 14:54:43 -0700 (PDT)
X-Received: by 2002:a37:f50f:: with SMTP id l15mr19292460qkk.343.1558130083216;
        Fri, 17 May 2019 14:54:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558130083; cv=none;
        d=google.com; s=arc-20160816;
        b=Nal4RdTHuBpsWQ8/ZQM+rKVORnKWojNDHDYjTweaSo3LZEjMQ3YVw44QzSf33k2cq2
         pMx6oVjBbyQB6eX1JCs0MLrJ49+/35T0+JPN9hMZ75hO3993t08mK+BkxsnGurgb3DRm
         Ww318Pyw1XTe+wuE464zhdZeKShL8JBvfzesorFeB70ydihg/giH5Ui8VbvXxT1NjtRu
         FdPRwSljSYrJ7FQTWc/t/o5lGMFjGwSzSLUcBYfN73E0jFoqSNHWIFMoUAL+VaCryZAu
         hP8VdXrGn7Z7WM6af6zS+8c4qx4FJEhhf7LLItK6V6KVJquUlDXyxPBtw2t8m/BjnwnF
         FU1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=sZik8ol8fs3TSWSCSEu1wyYNsukkj3XsAOHuR7dVClq+yZ4GPRtjaCNB5TrNzmxAht
         qlSF9fPL6rNWWoLWxn9M5LU6XI9w36oyjCmJNGHnRfZCm4LB6DNQDEy51zoYnbMiX7s7
         2e3y3nGQ8IQRhZz8sryYcQzN0/CCda2+plCBedzhSLBF/XDmBllXiBk9NXvgW0ZP8yrX
         J3SWPK5XgfARS8xqBYBrK3Coa9MlThTfaoGMtZjAjC6BaR0wEnVbIAaJ9A3P8TKn2FH2
         1saKO88eHYk1yJpfFGmxFRdGeuqfWPyrFER7fN+U5S9q9o/mJpA5nzId30pDf5i1eEax
         G05w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=MAG7Kwt5;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n13sor13230680qtk.35.2019.05.17.14.54.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 14:54:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=MAG7Kwt5;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=154pK5P8ksWbhOO3IYrUyqpSsi0GfqRRa2gpHRslqUk=;
        b=MAG7Kwt56YLXgGpHlSwF6peeLCFWoe9w9yw1/4MNfZedRugiM5L9tJph4Z0qIqbysQ
         MQa00cOfj0ilwkOa8A4nZtTqACZDP70GVXMoFcppyNW6lFn1r8367ZG5q+tQtiGSR5mv
         QW2I+pdoS9IGt4WkV3+HceuXhZGG1MyYkpAD57R+twSBkhOqG+AEgv14CPl/X5joRCH/
         4Fu0gWVewSN9wTffe2BpgeBjoHryPvlUQAiajnV/yBfZ8fLU4J6TKSjKSAJu+0zFO3CM
         DYCy9YBFL8fXrbOMGGU+IeIiyzKMEGD2okiZG3r35R7oCY0l5vm2B9D5QUI1zTTygD27
         nSLg==
X-Google-Smtp-Source: APXvYqzgOTJEZbvtrTHUCsU4W9MY9QwY+/vt23cg4Q1By0cu8+zJHQ1zc5/kIujRbiw57m5j08mTsQ==
X-Received: by 2002:aed:35c4:: with SMTP id d4mr50747244qte.311.1558130082975;
        Fri, 17 May 2019 14:54:42 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id n36sm6599813qtk.9.2019.05.17.14.54.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 14:54:42 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org,
	akpm@linux-foundation.org,
	mhocko@suse.com,
	dave.hansen@linux.intel.com,
	dan.j.williams@intel.com,
	keith.busch@intel.com,
	vishal.l.verma@intel.com,
	dave.jiang@intel.com,
	zwisler@kernel.org,
	thomas.lendacky@amd.com,
	ying.huang@intel.com,
	fengguang.wu@intel.com,
	bp@suse.de,
	bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com,
	tiwai@suse.de,
	jglisse@redhat.com,
	david@redhat.com
Subject: [v6 1/3] device-dax: fix memory and resource leak if hotplug fails
Date: Fri, 17 May 2019 17:54:36 -0400
Message-Id: <20190517215438.6487-2-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190517215438.6487-1-pasha.tatashin@soleen.com>
References: <20190517215438.6487-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When add_memory() function fails, the resource and the memory should be
freed.

Fixes: c221c0b0308f ("device-dax: "Hotplug" persistent memory for use like normal RAM")

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Dave Hansen <dave.hansen@intel.com>
---
 drivers/dax/kmem.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index a02318c6d28a..4c0131857133 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -66,8 +66,11 @@ int dev_dax_kmem_probe(struct device *dev)
 	new_res->name = dev_name(dev);
 
 	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
-	if (rc)
+	if (rc) {
+		release_resource(new_res);
+		kfree(new_res);
 		return rc;
+	}
 
 	return 0;
 }
-- 
2.21.0

