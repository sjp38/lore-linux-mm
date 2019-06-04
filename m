Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D14A9C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:47:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A5372075B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:47:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LHVOjJU+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A5372075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21B986B0271; Tue,  4 Jun 2019 17:47:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CD5F6B0273; Tue,  4 Jun 2019 17:47:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BD286B0274; Tue,  4 Jun 2019 17:47:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B35776B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 17:47:56 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r5so2360989edd.21
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 14:47:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YAOiP57A01Sn4VN1p2tU0pXmqdLPIiJ4XRB9cBH/L60=;
        b=WvQNzWGtIt1eOj/I4trqV/P1P6iwCwuOVKMgZgvmzvbShnmiYQBO6Z4uMVknJ2Hpus
         +W3R175O+S7dwWbt/BBb7vphYklMUaQgkFP2QBFg4BvqRYCPIwjDCC4Ho70I9MKGnqQM
         J8bJ+KUUyqTSZFhjKE/Kdia1QtTwF0f9l2a5P4Qr4po+JEC5vFeEFXjkJR+5IPtFa9LQ
         oxFMpJwLHvxr0xm42K/DGgYjdseipSHnDPRFPombHCm90L/rt9hADLdbYEcRNRlBCzNA
         pzUAbBTfSPANWrYmareTXgi4Clh2Is0CDSQLaG+L39tl+rszMupZvaymbsY3Q3ZUiNmH
         PPAQ==
X-Gm-Message-State: APjAAAUnsWWXfLnbeMYUJzVSjp5kOSsg4djVj7ZsjjO5ealJWzwJ1ZHM
	ljsbWWyZwXvD3oSv1UN/P1zqRcLivPc7oXBgdMHpbG63pfOIkPRfKRyy+QDP+JXnKb5CZCdfO3K
	OJKzA8MlqZ2pteMPCflsEeCkKJIKWWEP1+pTeo/3D9+5kSFFQGsHzC79bDzAOyqu6MQ==
X-Received: by 2002:a50:ad2c:: with SMTP id y41mr16832413edc.300.1559684876292;
        Tue, 04 Jun 2019 14:47:56 -0700 (PDT)
X-Received: by 2002:a50:ad2c:: with SMTP id y41mr16832352edc.300.1559684875584;
        Tue, 04 Jun 2019 14:47:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559684875; cv=none;
        d=google.com; s=arc-20160816;
        b=QHpHl83066yupR4+/lDKxPkGvrsM/8KN6puBfqnDT0+UZCifNy/LpG6VlAFz+7Iywx
         TWrhIL+3G/N/4aGRqpLqnbfZigfu+s3FNcwSOC2+OAsS0Lyp1RE4M3z5LLJcSFTkUo0d
         fi3Vaw3n6Yq3ylYyQ/Jv8g7URyNvGqjzlU4AZnoL01QD1CDE8rVOOM8hq6HyFtuwRq+x
         DNwiGbxwvP7h7HeKaeyzZbZUiNXuroYdiLo+Uj4UYhEyjS9rK6mBAO5MDZJXLQtwWPGA
         m4A47d30qo0SyeBPbGe+IRW8dtp7EPxB+jqz/29NFVKm+igBN72s0s+neR9/61x7ha0e
         8rmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=YAOiP57A01Sn4VN1p2tU0pXmqdLPIiJ4XRB9cBH/L60=;
        b=CeK5wwKy3LOTqaKwHpoZISlJ7tzFsjObJ0Geu71tsZeyeM0d5rPbxuSrPuDKv+Ycqr
         mMFuHRZwjdiZjcrADQb8sqTuQNraz9SuoPA7F/gZSlu8wOFH+y6rUGEziHm+tXGRe54b
         8zbSbgXJEdhwBSXedcnKVZ07V1SZ4HaH7McIG89smYSCgz2X/HKnoU0/zRfcDIHreSbR
         P/hLgCCxPX4eWcw42ZVAvulG57+CR3WP20ej4xh4/XwykAIcgyxbKvcRjzcE2twBK6mI
         2/6TxeAxOBobEOQ2/2L+b3MVAE9lzx4lepurrjGx6Mef74WMWTBP5+Er+0fJ5CIxCPFJ
         kqmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LHVOjJU+;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b51sor946986ede.8.2019.06.04.14.47.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 14:47:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=LHVOjJU+;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YAOiP57A01Sn4VN1p2tU0pXmqdLPIiJ4XRB9cBH/L60=;
        b=LHVOjJU+PrWUKjw2La9VE1vPKl5KearF9vd1gx+fMOah0NIYnTCpk/hLPywmGuD7Qx
         ubKVoOSXllgIIOtqhu2gVJ3x9B0/bsgZ7dOqAY3y5Ayi0qhLPf1tZQD8IUflfR/bo3b1
         F4TaQlhPSFK4tf44OdTct45QOW1HbhpVKmRS1UPgsRmJ8ykiC6IB1kc0IjzAbHbpYgcW
         XocfR253q6JmXmpbPH+wSLE5nYqYTiHdUq2ypGGmgfgczCsKHTbAbfTkEuh649zZZ9c/
         Obhuc+H39gsisfGYj1xrWFrX2Lyh1bRdUjq62tExuKhoIe4zwnBrI2RwiYnmhdgPNIGz
         bDHA==
X-Google-Smtp-Source: APXvYqwDVoxJj2tIOxzLuK3nYNHPwTJ67OHC1d3ag5SDYh0bPqzR5f57ZgPalm+F2A4DDOJ5mfMHNQ==
X-Received: by 2002:a50:bb24:: with SMTP id y33mr38369134ede.116.1559684875305;
        Tue, 04 Jun 2019 14:47:55 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id n5sm2897404edt.65.2019.06.04.14.47.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 14:47:54 -0700 (PDT)
Date: Tue, 4 Jun 2019 21:47:53 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>, Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v3 08/11] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
Message-ID: <20190604214753.utbdrjtjavgi7yhf@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-9-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-9-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:49PM +0200, David Hildenbrand wrote:
>No longer needed, the callers of arch_add_memory() can handle this
>manually.
>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Oscar Salvador <osalvador@suse.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>

>---
> include/linux/memory_hotplug.h | 8 --------
> mm/memory_hotplug.c            | 9 +++------
> 2 files changed, 3 insertions(+), 14 deletions(-)
>
>diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>index 2d4de313926d..2f1f87e13baa 100644
>--- a/include/linux/memory_hotplug.h
>+++ b/include/linux/memory_hotplug.h
>@@ -128,14 +128,6 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
> extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
> 			   unsigned long nr_pages, struct vmem_altmap *altmap);
> 
>-/*
>- * Do we want sysfs memblock files created. This will allow userspace to online
>- * and offline memory explicitly. Lack of this bit means that the caller has to
>- * call move_pfn_range_to_zone to finish the initialization.
>- */
>-
>-#define MHP_MEMBLOCK_API               (1<<0)
>-
> /* reasonably generic interface to expand the physical pages */
> extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
> 		       struct mhp_restrictions *restrictions);
>diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>index b1fde90bbf19..9a92549ef23b 100644
>--- a/mm/memory_hotplug.c
>+++ b/mm/memory_hotplug.c
>@@ -251,7 +251,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
> #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
> 
> static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
>-		struct vmem_altmap *altmap, bool want_memblock)
>+				   struct vmem_altmap *altmap)
> {
> 	int ret;
> 
>@@ -294,8 +294,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
> 	}
> 
> 	for (i = start_sec; i <= end_sec; i++) {
>-		err = __add_section(nid, section_nr_to_pfn(i), altmap,
>-				restrictions->flags & MHP_MEMBLOCK_API);
>+		err = __add_section(nid, section_nr_to_pfn(i), altmap);
> 
> 		/*
> 		 * EEXIST is finally dealt with by ioresource collision
>@@ -1067,9 +1066,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>  */
> int __ref add_memory_resource(int nid, struct resource *res)
> {
>-	struct mhp_restrictions restrictions = {
>-		.flags = MHP_MEMBLOCK_API,
>-	};
>+	struct mhp_restrictions restrictions = {};
> 	u64 start, size;
> 	bool new_node = false;
> 	int ret;
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me

