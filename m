Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90EC8C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:45:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 365DE20857
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:45:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 365DE20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 915A06B0007; Tue, 26 Mar 2019 09:45:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C5F76B0008; Tue, 26 Mar 2019 09:45:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DDD56B000A; Tue, 26 Mar 2019 09:45:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60C906B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:45:32 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l26so13474198qtk.18
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 06:45:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xAx2yDEtrFdkNgzALGBSgbCvCmQObFKSDuoPEA3CCWk=;
        b=YJuSX81Wsk0CxtQ4Y0MlWbllOMXJtCGV+zvzlz4WIdGKdVRGwk5rTb7xj8HepJehet
         ELc/vDVq30KCxs0DMK9Hna52QDpPe2/T0drPXvh2vClAMLGZbJ3TVMkvJurkZQPGn/8p
         TC8M1EUHvKCgdhemYjhk/x7kAaCTVoAAos3yriw3CeUIOzOO8ufnraWhRHiWkzyvD8OY
         Xe7dNyoKFN+FKRugefgTaOGJ9t8DU6r66tIMk8ypgKU8ruG6njTtb/mdKk2728KjAQIR
         CFgV1rehet4YsiQgFv+RHYlstg/Kt5ACsX0Pvt6OFYhqkWfFiZpWfm0mnntUQXYH7VYZ
         Ojsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV2KgKkjHSm7UCmaW+Rc31AxY/+CbCrCLxEUpwMsB3VIIuvqtsi
	p2G2+LSzRKiqztCoxj93vR20yJY+gZCQ9N9No7k7KzXtU2i742i6kMeZo9x/9MoEURtbe4DacsC
	QvsZ6QdIOm61crpJamnxrOBh748N6mNA4w+ipao0+cev3Ejd2MLbbblEoPS8uxwrjlw==
X-Received: by 2002:a0c:9a02:: with SMTP id p2mr26402538qvd.189.1553607932132;
        Tue, 26 Mar 2019 06:45:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzRyz0U8S3y34oDDNTVz2k6L2S3E+43ZLzUtGvHn+tRbMbcM4f/IgSAKx6AOJRxG0lhHsx
X-Received: by 2002:a0c:9a02:: with SMTP id p2mr26402489qvd.189.1553607931604;
        Tue, 26 Mar 2019 06:45:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553607931; cv=none;
        d=google.com; s=arc-20160816;
        b=uFTbL8w2DJsZBrnYTMP7cmljuAQWnZ8dXZrX1+SGLiC6Pr5zI91YBWIvRVzQXO5zlf
         T0JP0vHHBdFPIE9I8wll9Sa5iSGzimwMJZXWhLkInWf4ojELd6qqFusrgL1AoVwcUWfz
         JQv/y4FxKHci6pYhI4bL8Nu+31/CN5z8fTuwVZ8oBUGSmcD5RSs6//MWvXSB7zK9fewY
         ZtP4aI0GaKtkUKRsxv3Umeh3Skm5lmM5lCbp/oCTowFAfQrxH9cKVn11vQ1KfYzBmJTC
         C9lVBcqB1HFwmWnOePmgc6yjmGxThbkvW2C0jwXzgY0+TLNLios8/e3PDP2+t9jkBCX6
         Ef/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xAx2yDEtrFdkNgzALGBSgbCvCmQObFKSDuoPEA3CCWk=;
        b=tmhVCB5bcO+oFi2IAny0y9DFEVlftTR6ApNcdjxcaLmTIF4ZCTdTcf/B7zZkuvDSIx
         RArhBLvmXIMfcDyXUEmKe6R8ooWizXPSKjpx/Y6v8STGB4uzRQJz2UVvQfyHDQM3is8T
         bRPgyRG9rZsCfiuRNzC3m3x1ZdsA+tfvwjaw+J+8gr1ZU8yPuXJiP8/PeeNlL3XQmQPL
         lQVfX+QtKXoTFQm4I6sQTdOfQgBvUmJxUZqUlq0b5oXyeREEe/RJ5Qm3FwVfQ+NrB4DT
         rhWHWkxFclKP58tO4nyenyplc0uOWE1k29Ysef347HtPZWJ55Mb9hjvRfeNthRy86hcS
         hS4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 30si857885qte.385.2019.03.26.06.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 06:45:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A17A48AE4F;
	Tue, 26 Mar 2019 13:45:28 +0000 (UTC)
Received: from localhost (ovpn-12-21.pek2.redhat.com [10.72.12.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D2EFD5E7DC;
	Tue, 26 Mar 2019 13:45:25 +0000 (UTC)
Date: Tue, 26 Mar 2019 21:45:22 +0800
From: Baoquan He <bhe@redhat.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, rppt@linux.ibm.com, osalvador@suse.de,
	willy@infradead.org, william.kucharski@oracle.com
Subject: Re: [PATCH v2 2/4] mm/sparse: Optimize sparse_add_one_section()
Message-ID: <20190326134522.GB21943@MiWiFi-R3L-srv>
References: <20190326090227.3059-1-bhe@redhat.com>
 <20190326090227.3059-3-bhe@redhat.com>
 <20190326092936.GK28406@dhcp22.suse.cz>
 <20190326100817.GV3659@MiWiFi-R3L-srv>
 <20190326101710.GN28406@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326101710.GN28406@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 26 Mar 2019 13:45:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/26/19 at 11:17am, Michal Hocko wrote:
> On Tue 26-03-19 18:08:17, Baoquan He wrote:
> > On 03/26/19 at 10:29am, Michal Hocko wrote:
> > > On Tue 26-03-19 17:02:25, Baoquan He wrote:
> > > > Reorder the allocation of usemap and memmap since usemap allocation
> > > > is much simpler and easier. Otherwise hard work is done to make
> > > > memmap ready, then have to rollback just because of usemap allocation
> > > > failure.
> > > 
> > > Is this really worth it? I can see that !VMEMMAP is doing memmap size
> > > allocation which would be 2MB aka costly allocation but we do not do
> > > __GFP_RETRY_MAYFAIL so the allocator backs off early.
> > 
> > In !VMEMMAP case, it truly does simple allocation directly. surely
> > usemap which size is 32 is smaller. So it doesn't matter that much who's
> > ahead or who's behind. However, this benefit a little in VMEMMAP case.
> 
> How does it help there? The failure should be even much less probable
> there because we simply fall back to a small 4kB pages and those
> essentially never fail.

OK, I am fine to drop it. Or only put the section existence checking
earlier to avoid unnecessary usemap/memmap allocation?


From 7594b86ebf5d6fcc8146eca8fc5625f1961a15b1 Mon Sep 17 00:00:00 2001
From: Baoquan He <bhe@redhat.com>
Date: Tue, 26 Mar 2019 18:48:39 +0800
Subject: [PATCH] mm/sparse: Check section's existence earlier in
 sparse_add_one_section()

No need to allocate usemap and memmap if section has been present.
And can clean up the handling on failure.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 mm/sparse.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 363f9d31b511..f564b531e0f7 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -714,7 +714,13 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	ret = sparse_index_init(section_nr, nid);
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
-	ret = 0;
+
+	ms = __pfn_to_section(start_pfn);
+	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
+		ret = -EEXIST;
+		goto out;
+	}
+
 	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
 	if (!memmap)
 		return -ENOMEM;
@@ -724,12 +730,6 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 		return -ENOMEM;
 	}
 
-	ms = __pfn_to_section(start_pfn);
-	if (ms->section_mem_map & SECTION_MARKED_PRESENT) {
-		ret = -EEXIST;
-		goto out;
-	}
-
 	/*
 	 * Poison uninitialized struct pages in order to catch invalid flags
 	 * combinations.
@@ -739,12 +739,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	section_mark_present(ms);
 	sparse_init_one_section(ms, section_nr, memmap, usemap);
 
-out:
-	if (ret < 0) {
-		kfree(usemap);
-		__kfree_section_memmap(memmap, altmap);
-	}
-	return ret;
+	return 0;
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
-- 
2.17.2

