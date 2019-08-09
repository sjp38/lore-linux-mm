Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B90A5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86ACA20B7C
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 12:57:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86ACA20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C9106B0005; Fri,  9 Aug 2019 08:57:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 253876B0006; Fri,  9 Aug 2019 08:57:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11B5D6B0008; Fri,  9 Aug 2019 08:57:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEEEB6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 08:57:37 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d203so7440856qke.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 05:57:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=m7rhciziNyGBsOkNiEq9bfaEWC8YEzaIg6J+WM9p4dk=;
        b=FUCQ3gSGIGidalKBnFRMOXTsDY8HB3GWrbiVVvAo590PcaPhNnNpWVqZ3/gckzqAA/
         vWTYoAJzi43dtVcA9Oh/M3K0Xz2W1O53FMop8XQMtjUV5txxasD6f0V34VQXralFDtvF
         UA46StpKHZ6a6yfvvRgrM0s7bGMdGlPoo6ochrYGyOEUoMqERQ2t/sqagUxVZ92BjJGs
         Wh6Aha5o0dcZRE+0Tsoskm0bgqpbbXbfPDjdOqjlbEbV+vDZ2O7JSUYH7tMosRkA7o5r
         9MG4kZUKVYtdTVDzJlzLESyq7axSKk3tC2v0ymCUIVM2bYOcV5zndOEp6nspVgQEGOOl
         Ut4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUJU7jdvJQ/X66kgtxnbs2xewDR71jXwFP7u+r8bi5lCNw+xxVg
	gn7A7vws0+3CpACgCJ1GaFux9BuOcLebe77nbNAwXrSEDpGKQOG+QpIoNNAMxq7NqJK2R0g7ayl
	M9DxCDbsopRHa5b4R+Czt9lu98+7nWWh0OngOeIgo43QfcbetjqQQSdnd3rVkpU5UwQ==
X-Received: by 2002:a0c:c96a:: with SMTP id v39mr17651090qvj.121.1565355457711;
        Fri, 09 Aug 2019 05:57:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzo17CCPSeLWHirLG4J0SEUO7q1Jw10V8oD+5t5Av/auV4+JDVIQYmGjALP/9f0C33VzNF5
X-Received: by 2002:a0c:c96a:: with SMTP id v39mr17651063qvj.121.1565355457245;
        Fri, 09 Aug 2019 05:57:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565355457; cv=none;
        d=google.com; s=arc-20160816;
        b=Ub9l1yci6vat0zm9Zssm0DYYdE4rxWwZgdhcgOtm6/LNQ5NhvdzS77nb/y8x2MR8IC
         Ozi/Qs/FWVuuCMGN1bc5hMbL1XfbIyOaDYdmreoI/ty4DiXiBcFpaGBDxcdZDYQ3YcXg
         LiwBX8s8zPmL100h9ZriYksJ3mOWFkIsn5ilQXzw98iVoFl9Nlk0c4SFl55nSNUweKiA
         b5JVbUW6fgNjxArANsFs/H+MYHLNTAT+vYxEOchTIvth1CbRLbSqeF/iuIjtI58OqUDH
         q+4DWbc2YFrOxm4FW+DS2yaJE/+QIVMmKMGDvzojNZcqjaGrmJACbG1iala570qzqv4o
         q2Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=m7rhciziNyGBsOkNiEq9bfaEWC8YEzaIg6J+WM9p4dk=;
        b=Wzzwp8Gu5pKzQk0FA6GETk7F8mXfCJ5DkELB2zK2X/IO92b/cpbq5ju0YeYmbMXkNk
         oFvWQ04y8UCC3nncJzSQEWtOcApZoWnZ/k16TXFEz6eHV9LzuXLGRpm0+pQM4ofHHYlH
         Xwm0L3wPxIFwfcGadxSy5fKgVIwJojZInHqKt9v1BAM089iqv4bZ8QM8SVAgNJCW7ekk
         psnT9KNE40E76uwmRmE7VIuR/qejHyBkElcF1HOLqJ1796m1drfnZ1lqDNK3oHztWK+v
         VSiqiUeGiMCmPzOq5EURMbvNlxqNuePh44S3GJcooQcAtUS/adJOM5Pk8m6LjM8XnmWo
         HwtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y2si15165001qvf.221.2019.08.09.05.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 05:57:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 68DC46CCD7;
	Fri,  9 Aug 2019 12:57:36 +0000 (UTC)
Received: from t460s.redhat.com (ovpn-117-120.ams2.redhat.com [10.36.117.120])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EC9C36C8FA;
	Fri,  9 Aug 2019 12:57:33 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Borislav Petkov <bp@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Ingo Molnar <mingo@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Nadav Amit <namit@vmware.com>,
	Wei Yang <richardw.yang@linux.intel.com>,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v1 1/4] resource: Use PFN_UP / PFN_DOWN in walk_system_ram_range()
Date: Fri,  9 Aug 2019 14:56:58 +0200
Message-Id: <20190809125701.3316-2-david@redhat.com>
In-Reply-To: <20190809125701.3316-1-david@redhat.com>
References: <20190809125701.3316-1-david@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 09 Aug 2019 12:57:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This makes it clearer that we will never call func() with duplicate PFNs
in case we have multiple sub-page memory resources. All unaligned parts
of PFNs are completely discarded.

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Borislav Petkov <bp@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Nadav Amit <namit@vmware.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>
Cc: Oscar Salvador <osalvador@suse.de>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 kernel/resource.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/resource.c b/kernel/resource.c
index 7ea4306503c5..88ee39fa9103 100644
--- a/kernel/resource.c
+++ b/kernel/resource.c
@@ -487,8 +487,8 @@ int walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
 	while (start < end &&
 	       !find_next_iomem_res(start, end, flags, IORES_DESC_NONE,
 				    false, &res)) {
-		pfn = (res.start + PAGE_SIZE - 1) >> PAGE_SHIFT;
-		end_pfn = (res.end + 1) >> PAGE_SHIFT;
+		pfn = PFN_UP(res.start);
+		end_pfn = PFN_DOWN(res.end + 1);
 		if (end_pfn > pfn)
 			ret = (*func)(pfn, end_pfn - pfn, arg);
 		if (ret)
-- 
2.21.0

