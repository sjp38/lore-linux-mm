Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28E24C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:56:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E723D214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E723D214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30FB38E000A; Mon, 11 Mar 2019 16:55:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C0848E0009; Mon, 11 Mar 2019 16:55:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D5968E000A; Mon, 11 Mar 2019 16:55:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D59D18E0009
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e5so381513pfi.23
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sInMTJKcI1v7nqarBetCoPUBJHg4EyIpQ43tSquwp+w=;
        b=le/vvPgUpAZPxlwUagv0MaM+gBNPn3kyZnz4Kfv9Pk8ZFVJ1GHcjIMthIvNPhWNC4a
         GSN+MSEFHGOc5B1Au7ARmq61vn8rGras9P7WLoEX5DZTLy6wnIl5J1m4oLVEComrT5Eg
         lXCDL7wmfr7ieWAt++OpEd7cwhiqH2/sWKPEAj1meCiwruVmWi/z7El6xL87BrbinD70
         sBCameXsFgj3qYvA3ooS5JG1wFmZhBUsfz4YG7AySReONxHWMW0jBUQHx/9wfucm6XYp
         gim5tAiy80oUhsueb8bs14PtJHqOvuJgtAZuv3bLY856v9MhRd/V/E1kBBY4PR1H9xH0
         jYbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXZo2hxmn2XJq3LKrRqSX6lWIHXRIWuwruIzJm9n4wy/OwdG3dY
	GyQKR2HMUGP7fM2s/hkHEKg2BW6Lklt9c76qlSuintNcGd4Dg7ApkSlNwFMeefygNiK1gBW5N8z
	tIfU7euxM7qV0HO8uCIcAIWs1ad6urdD5HkldKlKP6un1TnrfmFHMBNIYxGHRXVnjYA==
X-Received: by 2002:a63:7c07:: with SMTP id x7mr32107730pgc.284.1552337745573;
        Mon, 11 Mar 2019 13:55:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD81I9Soc0UF8IVveBxCGMzOfRm1TaQYY/sDOQFveIdVUhnHuOdpiqijRVLJN+VqVUJQr0
X-Received: by 2002:a63:7c07:: with SMTP id x7mr32107670pgc.284.1552337744290;
        Mon, 11 Mar 2019 13:55:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337744; cv=none;
        d=google.com; s=arc-20160816;
        b=x6kAoiVbbSHXaDuypRUhsPsUSc8XzabrutH8JR7F2vnwlNC8wY+/shhF/O3P+qEl8y
         rdkbENYsGCPB7AELBzX55s70S9iiv2wNFw7rw8Cwu/boOMupuZLCzTJgs2TSLWexdGed
         AUZjcWoThfhULGne12xOgIYsNVtbjADuGGbJBH++8lAhrYKixDKExoxGe5fDi7Dsu55i
         x7XJuMMfkLUXbqWjNyTYFSsHbtQQ5giyTKuznP7FO3/j9IXyD0otzeGZlSGtg7x72YRY
         OhzVk7xe+L9/zps5HXgzhIzN6/tCIMDDGfe41/eqzKmsW3xMWKKtVDmpYdNviqv5vLpe
         x4ew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sInMTJKcI1v7nqarBetCoPUBJHg4EyIpQ43tSquwp+w=;
        b=fGei76/Oho+nw0pzImSTDplOU/gKLNG5erBGw6l0YP5smlaDAFJgkRwOBJvztQMC/i
         VV0ezu0VsKPrIT8rF6SH0iD2OpYc6ccN1wAltLp7D1hmpeJmke/nT4/9ALw9wU1Bx8Fw
         QpYXpq1o8atm48XLcVUUn8NTa1FTZQTAPHXvRFj/UoA4mlnDXYnp/dLqhOnHexhAtYvG
         FGeVPVnavwiJ4J1pmLqUU0WGxsXsJxUedc2AiiBwlEjcCssTHcCLcjN9mMxRVaNxewM6
         HYFEbg6kHY7SX0oo1Xcy9JDV4aoDQsjcj6CZKRhxfv3UmZJgC52jKTPh7FTtodM/WyXA
         ycdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:55:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="139910196"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Mar 2019 13:55:43 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv8 09/10] acpi/hmat: Register memory side cache attributes
Date: Mon, 11 Mar 2019 14:56:05 -0600
Message-Id: <20190311205606.11228-10-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Register memory side cache attributes with the memory's node if HMAT
provides the side cache iniformation table.

Acked-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 drivers/acpi/hmat/hmat.c | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index 7a3a2b50cadd..b7824a0309f7 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -314,6 +314,7 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
 				   const unsigned long end)
 {
 	struct acpi_hmat_cache *cache = (void *)header;
+	struct node_cache_attrs cache_attrs;
 	u32 attrs;
 
 	if (cache->header.length < sizeof(*cache)) {
@@ -327,6 +328,37 @@ static __init int hmat_parse_cache(union acpi_subtable_headers *header,
 		cache->memory_PD, cache->cache_size, attrs,
 		cache->number_of_SMBIOShandles);
 
+	cache_attrs.size = cache->cache_size;
+	cache_attrs.level = (attrs & ACPI_HMAT_CACHE_LEVEL) >> 4;
+	cache_attrs.line_size = (attrs & ACPI_HMAT_CACHE_LINE_SIZE) >> 16;
+
+	switch ((attrs & ACPI_HMAT_CACHE_ASSOCIATIVITY) >> 8) {
+	case ACPI_HMAT_CA_DIRECT_MAPPED:
+		cache_attrs.indexing = NODE_CACHE_DIRECT_MAP;
+		break;
+	case ACPI_HMAT_CA_COMPLEX_CACHE_INDEXING:
+		cache_attrs.indexing = NODE_CACHE_INDEXED;
+		break;
+	case ACPI_HMAT_CA_NONE:
+	default:
+		cache_attrs.indexing = NODE_CACHE_OTHER;
+		break;
+	}
+
+	switch ((attrs & ACPI_HMAT_WRITE_POLICY) >> 12) {
+	case ACPI_HMAT_CP_WB:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_BACK;
+		break;
+	case ACPI_HMAT_CP_WT:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_THROUGH;
+		break;
+	case ACPI_HMAT_CP_NONE:
+	default:
+		cache_attrs.write_policy = NODE_CACHE_WRITE_OTHER;
+		break;
+	}
+
+	node_add_cache(pxm_to_node(cache->memory_PD), &cache_attrs);
 	return 0;
 }
 
-- 
2.14.4

