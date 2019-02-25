Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3431AC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F13932084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 19:02:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F13932084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73A158E000A; Mon, 25 Feb 2019 14:02:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6EB3B8E0004; Mon, 25 Feb 2019 14:02:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 600F88E000A; Mon, 25 Feb 2019 14:02:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1DF8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 14:02:38 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 202so7690145pgb.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 11:02:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :from:date:references:in-reply-to:message-id;
        bh=ddSVWhx5TfNJ/WvyKgYL4bUsHx/Z5PTEAP9KHJe7W9s=;
        b=UpjbCyWDSzu8OnlQwFMskhfy4pdazgBfRl41vAlnPajgjbXpyNaR8V91DnWKg1wLpi
         w9tpMQ22GYrRy/Vt7t3m+mkNuah666BXTDzbEvbU7op7wvVbAxGguAVsucUAsMBCqVZx
         bMZVEx/Wyc8GGHTT2fP0+DQjsHKCCQLil3atbI2XzHfoCPK3gf3r1x1Vz55Ke9A96OuZ
         +diI8QjaXflb6ReiPICVj+21NJ94YQYCYwR1iiyDmDD2Ur3tEtL3YSY4fmoJP+pgU8Sq
         KCCCXvUxiFBYZYbXd+aubxkS0hyFBtZAPx7FMxXOu8rvzNs8WJIAUgwtqBkeuGIioL3m
         kERA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZtOq5vWaELb5RMlqXgO5m/L6ydnRR7npDwc780yFxp7iJSMJmA
	Wtbu0PObiG2Ro+Q7mNdgO4ZVWcs49sNnCYcmOw4qz8l7hVamtPT1MOt/z/IUH2mzMoJJnD11I+k
	lcNkaoFLdoNbFAuTU3YNa4PO/9PIVWTBJllFW3f/Fto6XK5lwe4evOe36p0CsaE0LZA==
X-Received: by 2002:a17:902:2de4:: with SMTP id p91mr22113808plb.215.1551121357658;
        Mon, 25 Feb 2019 11:02:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZYz8WkdgrfD0KTiG/bJ0iqAX5KwLiwb772yRYdhdr0VK27EwYyVPRcvgKYCY90RC/9J/r5
X-Received: by 2002:a17:902:2de4:: with SMTP id p91mr22113714plb.215.1551121356405;
        Mon, 25 Feb 2019 11:02:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551121356; cv=none;
        d=google.com; s=arc-20160816;
        b=IOkd9xVb0FhDogKWTMlq/ydpXqmER2DhUvivfbF8mBqPNGu+bGg/TwVrWYPrLKtAY4
         6BrYzlhg0uqd/JmgIyzgUIWZH9scmfU2RgKsask7hhqDv37/PRzLhw/StC0WvQE3wdQk
         0PfFV3aItKL3qFFcUqj3KNZjhyDZEHXVT58LV/ZY2NkHQOe7aZag/e7+Eisn1x7pZczO
         QnM5xNdWwkzK8lMF6TegE3xzWA8EVYbHT+bLCCH+PgWcpmXuugqF2PBY9TEMDcDeHQKF
         JGrQxtee9pJUCAVsYPCnHYmXu+qBWjBWcS1eFMWDese/61jgn0PcGWIv8gV6Mkgc8R82
         G5hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:references:date:from:cc:to:subject;
        bh=ddSVWhx5TfNJ/WvyKgYL4bUsHx/Z5PTEAP9KHJe7W9s=;
        b=hd/PrKuwEGjE9J8zVE5O9ksGBIDpCsGR3U5nxza52CarbMS3XR1EfC5lAno5kdMsfv
         Dnq0CK8zPmeYl2YjT2jRPZINv1us31dCadH/9+d4T+WD4cowmAO/lgTDRImPXUTt6mED
         hYEPEYfwnYi5Fo/13Wub8CXEZOeW2Yyms8YnP3W6UpuTjdCVG3P9Il4AuH0/UxzPQuno
         W3rPJMe2xEdIrBupQF7OPsDBvp0rp6604aPMTC/ry1+NJyaiZ8bcIWGYTYfLnJ0kE4f5
         96w2W2euMc4ca25GXrV3iHkxeDV/VdReABrmh1QTBDyxmohtKiJfEJTDkdx5AeRurXk8
         c0yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j66si10521427pfc.251.2019.02.25.11.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 11:02:36 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of dave.hansen@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 11:02:35 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,412,1544515200"; 
   d="scan'208";a="149861256"
Received: from viggo.jf.intel.com (HELO localhost.localdomain) ([10.54.77.144])
  by fmsmga001.fm.intel.com with ESMTP; 25 Feb 2019 11:02:34 -0800
Subject: [PATCH 1/5] mm/resource: return real error codes from walk failures
To: linux-kernel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,bhelgaas@google.com,mpe@ellerman.id.au,dan.j.williams@intel.com,dave.jiang@intel.com,zwisler@kernel.org,vishal.l.verma@intel.com,thomas.lendacky@amd.com,akpm@linux-foundation.org,mhocko@suse.com,linux-nvdimm@lists.01.org,linux-mm@kvack.org,ying.huang@intel.com,fengguang.wu@intel.com,bp@suse.de,baiyaowei@cmss.chinamobile.com,tiwai@suse.de,jglisse@redhat.com,benh@kernel.crashing.org,paulus@samba.org,linuxppc-dev@lists.ozlabs.org,keith.busch@intel.com
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Mon, 25 Feb 2019 10:57:30 -0800
References: <20190225185727.BCBD768C@viggo.jf.intel.com>
In-Reply-To: <20190225185727.BCBD768C@viggo.jf.intel.com>
Message-Id: <20190225185730.D8AA7812@viggo.jf.intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


From: Dave Hansen <dave.hansen@linux.intel.com>

walk_system_ram_range() can return an error code either becuase
*it* failed, or because the 'func' that it calls returned an
error.  The memory hotplug does the following:

	ret = walk_system_ram_range(..., func);
        if (ret)
		return ret;

and 'ret' makes it out to userspace, eventually.  The problem
s, walk_system_ram_range() failues that result from *it* failing
(as opposed to 'func') return -1.  That leads to a very odd
-EPERM (-1) return code out to userspace.

Make walk_system_ram_range() return -EINVAL for internal
failures to keep userspace less confused.

This return code is compatible with all the callers that I
audited.

This changes both the generic mm/ and powerpc-specific
implementations to have the same return value.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reviewed-by: Bjorn Helgaas <bhelgaas@google.com>
Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
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
Cc: Borislav Petkov <bp@suse.de>
Cc: Yaowei Bai <baiyaowei@cmss.chinamobile.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Jerome Glisse <jglisse@redhat.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Keith Busch <keith.busch@intel.com>
---

 b/arch/powerpc/mm/mem.c |    2 +-
 b/kernel/resource.c     |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff -puN arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1 arch/powerpc/mm/mem.c
--- a/arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1	2019-02-25 10:56:47.452908034 -0800
+++ b/arch/powerpc/mm/mem.c	2019-02-25 10:56:47.458908034 -0800
@@ -189,7 +189,7 @@ walk_system_ram_range(unsigned long star
 	struct memblock_region *reg;
 	unsigned long end_pfn = start_pfn + nr_pages;
 	unsigned long tstart, tend;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	for_each_memblock(memory, reg) {
 		tstart = max(start_pfn, memblock_region_memory_base_pfn(reg));
diff -puN kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1 kernel/resource.c
--- a/kernel/resource.c~memory-hotplug-walk_system_ram_range-returns-neg-1	2019-02-25 10:56:47.454908034 -0800
+++ b/kernel/resource.c	2019-02-25 10:56:47.459908034 -0800
@@ -382,7 +382,7 @@ static int __walk_iomem_res_desc(resourc
 				 int (*func)(struct resource *, void *))
 {
 	struct resource res;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	while (start < end &&
 	       !find_next_iomem_res(start, end, flags, desc, first_lvl, &res)) {
@@ -462,7 +462,7 @@ int walk_system_ram_range(unsigned long
 	unsigned long flags;
 	struct resource res;
 	unsigned long pfn, end_pfn;
-	int ret = -1;
+	int ret = -EINVAL;
 
 	start = (u64) start_pfn << PAGE_SHIFT;
 	end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
_

