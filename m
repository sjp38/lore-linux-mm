Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28071C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:35:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBA6E22ADA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:35:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBA6E22ADA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D9636B0006; Wed, 24 Jul 2019 09:35:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 689666B0008; Wed, 24 Jul 2019 09:35:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 553708E0002; Wed, 24 Jul 2019 09:35:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05D436B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:35:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so30225314eds.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 06:35:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=xFsg8Chi/f+ez1Gkp/vBNLY2ss6oymnctRdzIFLBHc4=;
        b=P2BQGEVKLgquPpO5znfufsCDt9SMj/uTM5nWqx5na2dikpk1uBl/xX455oeicz0bf6
         lcNJZMc+q48UKYBpy9Tkzv2CJQGmzUktnuZMr6HmnALiYlR0aYL07g1Kg58lgNVjNqTg
         4kivT5B1FZb3SjcFCmJQQEYoysmKfdNXi7KK2dnbs1RNb2fB2HpGEh1FHyAlVKLhVkro
         2VERgrmsbUL3X91sBbFy7560g3yq0tvOrrJEXNMNXUw/pfsrj3DKQq5CogAen2CSKNyO
         ep+Q4c6RColKfiUFVdjy4zDXMgUYp5AvIpiVvYCP2UsylRtaAya5SM7HosbTILVXM8+W
         5E8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAWDP/iLeDhPuTDNnnSww8j8nawFmkqVvJMhK8Y9YrhHE9mbx+YA
	+1rc8aEu6ViTLvca9xGTN547z4FOuH/O1n0oOH6giCVHRofMt9Jhrs4Gy/Z9mNdxZtzT6pmwXI5
	Ukq+MoetClZzreMVaHaCjpU+4ru+3t9RFSeraRsgvh2LvHU5CTz031wfdSnaNRBn+cA==
X-Received: by 2002:a17:907:2091:: with SMTP id pv17mr62802308ejb.152.1563975314539;
        Wed, 24 Jul 2019 06:35:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQMg2ZSQjvnZPdYKYpXN4bZq/U/iYROPbdWgNyMK0ur4uPmQc1Bto8fwo8I4upwomzwOvY
X-Received: by 2002:a17:907:2091:: with SMTP id pv17mr62802220ejb.152.1563975313453;
        Wed, 24 Jul 2019 06:35:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563975313; cv=none;
        d=google.com; s=arc-20160816;
        b=ioGeCzrrn1FHGT9NcEa4TaUhnX1S/80wNsiurBIvHMUkvG4og7JBBBm8MTqOTa0X2r
         OCEEa0emX5mLOzZ2NDAZ1azFt2eGEo0vQeJbthtj0KIrucnW6sN6Esy0S3kqCOGGhYz4
         VjzbPX/yTGv2WJ4GHQtaHg7a8uDxnJS3TPOY1bsyYC61rcxl4rT94vKVnHi2/ZOsRBcQ
         2DWFtdczqb74Rod5M37JCkr47ZDTISO4ndhIbmLmVpkczstwJBShA3BBLMRxbFKT/lK/
         i50Hm5189X8p7I4HQHcpJyYg0JS9t6HCeerHN62wTC9KoeOzr/sNnt1Zv38knu57NLWg
         ga+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=xFsg8Chi/f+ez1Gkp/vBNLY2ss6oymnctRdzIFLBHc4=;
        b=k8MUBInToc4B62UxX17YGxtXbAgmj30rITnXwkutfdI1SGlDezwe64i8rMCx6PrBeg
         zuxiR1LFu41nRYp+MdO8suFTSVBbQl8BJ36DeFDwid37qpGNuyMKKVxDYFPYD25iz1No
         H3txz3b1OWFqiE6dj/Yv+IFnSdGPv5GcfBaUNIRvL53jmGInRKdGAznHdOVLfYOx1lyP
         BwBpvVzak6HioKyf7UrtMedPksuAfwCDn6W8Vhpq7luPfxaAzowObBgQ8KSbcn2GoLF8
         mRatad7g3TzwfETIfYb9G3dkNxj2vXEbG+hl8NwlUjdBMYyRN7BqQ68oVLNMOXzIPQOB
         C11g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si8370968ejk.288.2019.07.24.06.35.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 06:35:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ED2FBAE0C;
	Wed, 24 Jul 2019 13:35:12 +0000 (UTC)
Subject: Re: [PATCH] mm/compaction: introduce a helper
 compact_zone_counters_init()
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Yafang Shao <laoar.shao@gmail.com>, linux-mm@kvack.org,
 Mel Gorman <mgorman@techsingularity.net>,
 Yafang Shao <shaoyafang@didiglobal.com>
References: <1563869295-25748-1-git-send-email-laoar.shao@gmail.com>
 <20190723081218.GD4552@dhcp22.suse.cz>
 <20190723144007.9660c3c98068caeba2109ded@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <1fb6f7da-f776-9e42-22f8-bbb79b030b98@suse.cz>
Date: Wed, 24 Jul 2019 15:35:12 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723144007.9660c3c98068caeba2109ded@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 11:40 PM, Andrew Morton wrote:
> On Tue, 23 Jul 2019 10:12:18 +0200 Michal Hocko <mhocko@suse.com> wrote:
> 
>> On Tue 23-07-19 04:08:15, Yafang Shao wrote:
>>> This is the follow-up of the
>>> commit "mm/compaction.c: clear total_{migrate,free}_scanned before scanning a new zone".
>>>
>>> These counters are used to track activities during compacting a zone,
>>> and they will be set to zero before compacting a new zone in all compact
>>> paths. Move all these common settings into compact_zone() for better
>>> management. A new helper compact_zone_counters_init() is introduced for
>>> this purpose.
>>
>> The helper seems excessive a bit because we have a single call site but
>> other than that this is an improvement to the current fragile and
>> duplicated code.
>>
>> I would just get rid of the helper and squash it to your previous patch
>> which Andrew already took to the mm tree.

I have squashed everything locally, and for the result:

Reviewed-by: Vlastimil Babka <vbabka@suse.cz>

Also, why not squash some more?

----8<----
diff --git a/mm/compaction.c b/mm/compaction.c
index dcbe95fa8e28..cfe1457352f9 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -2083,6 +2083,8 @@ compact_zone(struct compact_control *cc, struct capture_control *capc)
 	cc->total_free_scanned = 0;
 	cc->nr_migratepages = 0;
 	cc->nr_freepages = 0;
+	INIT_LIST_HEAD(&cc->freepages);
+	INIT_LIST_HEAD(&cc->migratepages);
 
 	cc->migratetype = gfpflags_to_migratetype(cc->gfp_mask);
 	ret = compaction_suitable(cc->zone, cc->order, cc->alloc_flags,
@@ -2307,8 +2309,6 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 
 	if (capture)
 		current->capture_control = &capc;
-	INIT_LIST_HEAD(&cc.freepages);
-	INIT_LIST_HEAD(&cc.migratepages);
 
 	ret = compact_zone(&cc, &capc);
 
@@ -2424,8 +2424,6 @@ static void compact_node(int nid)
 			continue;
 
 		cc.zone = zone;
-		INIT_LIST_HEAD(&cc.freepages);
-		INIT_LIST_HEAD(&cc.migratepages);
 
 		compact_zone(&cc, NULL);
 
@@ -2551,8 +2549,6 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 			continue;
 
 		cc.zone = zone;
-		INIT_LIST_HEAD(&cc.freepages);
-		INIT_LIST_HEAD(&cc.migratepages);
 
 		if (kthread_should_stop())
 			return;

