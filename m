Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96F49C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 664EF2084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 664EF2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C47A08E000B; Mon, 25 Feb 2019 14:02:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B814B8E0004; Mon, 25 Feb 2019 14:02:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A45DB8E000B; Mon, 25 Feb 2019 14:02:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6401C8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:02:40 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 11so7662658pgd.19
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:02:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=m3exMRICffW7oyoKK4pXkv1gy7VWxQjl4Jnx4soXu74=;
        b=HI8839LIM9Ag5sPAdTGlGmcFmvo4UAiL6jX+FX/Blqx0tLwshdBnAId+/vOU9Xf6f/
         iG4vO+JaJoKn2CnpOckwWE2aJYgYOfJps5aWSeth5o9dw2LmeZpZmJdFw7ZZPRRs7PuO
         2IbdXTDHBZOIPdWqHreuAVLw+aWMGcTficx+pAuQq6W1lrkOf33uVgJAY4KVj1Z5E5yq
         QrN31UzFhzxWV10N6YGOiXrgBIa2O9F8+XMarZlCzx8Dg6YxOr2okIILOKcFUqa3Ar6p
         Jd7/sICk26/6Eh3LKGgIWMJHCxnV0Pze46hC+NSNmARQYNiu7+JNKDC4IkJGVGRTje4i
         2Gmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuY4sDANRhgaCm6y2wpw3SaScGLcLZoPPZrlPeRBLpmgBJM/WSVl
	UXJ9pNJ93C2hm739N5vUwaJkVybIDERnoPLKdT5zc0v08rMrHCcLV/qFoJqtcWeUq6Z6WyLeaUC
	RI3p3SoJJO2klgjV+bDZFq8rlJQkswI1qBzsUbcwnK/k5Lgf7SBnbL5lS+P0O+yWtXQ==
X-Received: by 2002:aa7:9090:: with SMTP id i16mr21369999pfa.85.1551121359990;
        Mon, 25 Feb 2019 11:02:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaOQdMXno2Q3WhuYcgry5g8mfJNBRUhys/Wkw5YQPs4NvAn5Rcl+olvBPZnioChgwsk4yG3
X-Received: by 2002:aa7:9090:: with SMTP id i16mr21369922pfa.85.1551121358946;
        Mon, 25 Feb 2019 11:02:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551121358; cv=none;
        d=google.com; s=arc-20160816;
        b=w1GCLdjXOih4kHpIIhr1uEap81vx53cXebrKcj8V+GdfHa2teM37TxQRHF+QdvJai+
         0BnMO68UzsLD7ZkP8VNsaWe2920MlQGG/Fuqqq8KE3BY0Wu4M/miND6vJ/2h24QViGa+
         9ndUiCHoJa8rXmhiV4J79nnbOvYUW88g8tINlPMungrs1QaB7eIFt+cAmoQb+a1MwgEo
         7LWNIxtzIp4zR3kXRHBbdsqWHRGBu2qsL80OH7krc4VcEhPS0yKIYfsc/csUokIllThw
         Qe2eFSoznBqKszsUiayF4A6g0ZK1+5DfpYB8Ug//jRs4YDc0yEd8EcTkzuXi5QfPCi6h
         0xIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=m3exMRICffW7oyoKK4pXkv1gy7VWxQjl4Jnx4soXu74=;
        b=Uqhy5GlmrFlYaQyiQDsrUTyc9AoyZRhhrL8Vaq7n/+SeCpfBJmckBsjeCWiVLhKw78
         9R9OWUtBfWRbUiouXKYurqX9QYL2KK8pl63pXvMEwLvMNu6DyHauTbeKdM+blIhbKlON
         IRlKVMVsm9oexPnew76vjgV0UjYgVGYy2+M8AqtiAWZLU0aIhhdwxPG/xrzrcWvSin2+
         zcGcZT/3FKvMh+LhHcQWvBotf8NxZEDwm7aaegXwkdbfim83BgcGYuQ8KlYMa782un1/
         8CdWYnDEfUcxdCDMy4BBXZJy2KoFDvJxE1GtojD9NVtq8a1TA5u74CieoyYkRJGqb24f
         y4/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id i3si9605563pgq.282.2019.02.25.11.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 11:02:38 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 11:02:38 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,412,1544515200"; 
   d="scan'208";a="323272306"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by fmsmga005.fm.intel.com with ESMTP; 25 Feb 2019 11:02:37 -0800
Subject: [PATCH 2/5] mm/resource: move HMM pr_debug() deeper into resource code
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,jglisse@redhat.com,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,keith.busch@intel.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 25 Feb 2019 10:57:33 -0800
References: <20190225185727.BCBD768C@viggo.jf.intel.com>
In-Reply-To: <20190225185727.BCBD768C@viggo.jf.intel.com>
Message-Id: <20190225185733.FB5686EB@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


From: Dave Hansen <dave.hansen@linux.intel.com>

HMM consumes physical address space for its own use, even
though nothing is mapped or accessible there.  It uses a
special resource description (IORES_DESC_DEVICE_PRIVATE_MEMORY)
to uniquely identify these areas.

When HMM consumes address space, it makes a best guess about
what to consume.  However, it is possible that a future memory
or device hotplug can collide with the reserved area.  In the
case of these conflicts, there is an error message in
register_memory_resource().

Later patches in this series move register_memory_resource()
from using request_resource_conflict() to __request_region().
Unfortunately, __request_region() does not return the conflict
like the previous function did, which makes it impossible to
check for IORES_DESC_DEVICE_PRIVATE_MEMORY in a conflicting
resource.

Instead of warning in register_memory_resource(), move the
check into the core resource code itself (__request_region())
where the conflicting resource _is_ available.  This has the
added bonus of producing a warning in case of HMM conflicts
with devices *or* RAM address space, as opposed to the RAM-
only warnings that were there previously.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: linux-nvdimm@lists.01.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: Huang Ying <ying.huang@intel.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Keith Busch <keith.busch@intel.com>
---

 b/kernel/resource.c   |    9 +++++++++
 b/mm/memory_hotplug.c |    5 -----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff -puN kernel/resource.c~move-request_region-check kernel/resource.c
--- a/kernel/resource.c~move-request_region-check	2019-02-25 10:56:48.581908031 -0800
+++ b/kernel/resource.c	2019-02-25 10:56:48.588908031 -0800
@@ -1132,6 +1132,15 @@ struct resource * __request_region(struc
 		conflict = __request_resource(parent, res);
 		if (!conflict)
 			break;
+		/*
+		 * mm/hmm.c reserves physical addresses which then
+		 * become unavailable to other users.  Conflicts are
+		 * not expected.  Warn to aid debugging if encountered.
+		 */
+		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
+			pr_warn("Unaddressable device %s %pR conflicts with %pR",
+				conflict->name, conflict, res);
+		}
 		if (conflict != parent) {
 			if (!(conflict->flags & IORESOURCE_BUSY)) {
 				parent = conflict;
diff -puN mm/memory_hotplug.c~move-request_region-check mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~move-request_region-check	2019-02-25 10:56:48.583908031 -0800
+++ b/mm/memory_hotplug.c	2019-02-25 10:56:48.588908031 -0800
@@ -111,11 +111,6 @@ static struct resource *register_memory_
 	res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 	conflict =  request_resource_conflict(&iomem_resource, res);
 	if (conflict) {
-		if (conflict->desc == IORES_DESC_DEVICE_PRIVATE_MEMORY) {
-			pr_debug("Device unaddressable memory block "
-				 "memory hotplug at %#010llx !\n",
-				 (unsigned long long)start);
-		}
 		pr_debug("System RAM resource %pR cannot be added\n", res);
 		kfree(res);
 		return ERR_PTR(-EEXIST);
_

