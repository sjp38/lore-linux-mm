Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5DA3C282E3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:43:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52874217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:43:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52874217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF9AF6B0007; Thu, 25 Apr 2019 03:43:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7F346B0008; Thu, 25 Apr 2019 03:43:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D20136B000A; Thu, 25 Apr 2019 03:43:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9361B6B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:43:13 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f7so13506967pfd.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:43:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=fgq22fcJ/15byH1kiRgUUck07wEqwKVi0HR/QN0sel4=;
        b=Sb1p57WNMLvzVhMCabNIBlSwKGeM/dFtytY006WyTpgQ1ULs5pGdt2eGL5gujvVBN+
         G4QOGkeum5Djq6JTibphLjoUJGRcDs8R3QLb0+Ja/VXDuMK2eyJoLw8wv/G/zRUSTz+p
         WrCV0dxYSd0ugpiqWbnl9A0xw22BFlk+nfzUrKgP2Nev5LRbPQULC2CqD/XSvm5plSJn
         YzrgMHlrVn4/LVNoFoZpoPrPE6n5O+DxyqPwan08Dt8B/yKnXtjUK+KmfqhxRLFz0lto
         jGkobq3lPmDJFEkQ11VQk1ERBoodm71+q01td4wzfajS6XZ2+rksdO3Qy4+vtsSv45/h
         fIlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUkJRLsDyw1qnqiYPU2TEgyRv73xqEGR1bM1HfCsF7qYys6XalZ
	IauhI3bmcKzNySE82Nd96zshUNaCXNSNnjDRO/R3PxAbHysKy5BvyZE0i1xfw02c8RLHODpjBMm
	12SL3gA9jvT7Bv775By8QQqfzRbkVkKlNaKmdVCkzfwnIwQVeiogM71SGWiYf4LZWxQ==
X-Received: by 2002:a63:82c6:: with SMTP id w189mr15277758pgd.444.1556178193198;
        Thu, 25 Apr 2019 00:43:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEyUPqR5PPrQ/oYYsoBMtZP6fZROvPb+RFS+LSU+ZdDLK1X3lSzbgHC3YMVHqi2vszevpw
X-Received: by 2002:a63:82c6:: with SMTP id w189mr15277714pgd.444.1556178192416;
        Thu, 25 Apr 2019 00:43:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556178192; cv=none;
        d=google.com; s=arc-20160816;
        b=zzm4kgVLekeOrUBv3tH2hoplETxsSMTibOijc1d00d+1voolpiQsZSSvEzgj99DRKP
         50pbIc3wJyXMvId2tTCIRnBTUXWnttaeVUzSOBlVgsVME90tNS/3Mcz6qhw8lrqGCzrm
         hynonmekAdJ7GId/WnlPHVIESwGlrvG9PFfCTAQK8tyLVNfYU993XJ83c6J7N4nin9Kl
         Emr8uOpjocrZOafVMf6t0h+8W1Iq7X3RJ0K9nntTDJfhiVbD2QHPyPa8uLgD90M9DdN+
         j+NQ4mxwqR/HHJ50kRtf8FtVe9D+XTkmg4M/Rzy3N6Pn46lIpokqe5iZF1eMWdNcAikp
         oFpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=fgq22fcJ/15byH1kiRgUUck07wEqwKVi0HR/QN0sel4=;
        b=QQDJSZIQgQpTj3BvdgsMtbng1qo8LfCiMBD8K7a6w0ZlVd2GEeohGmLVIMhK/QYF5Y
         NktJbYhVxVgqH3/65h+biAAjuAmteRYS2XL+0iRmRRXVQjZl0W0wChypbhYHL8fLU8Ii
         qiZC7DcrsmGEl8bAcshGlQVvCg6I3c55eA5Eo0R5TRrD3JXwEUgCMuLf729kFiOgr5Xp
         nP5zHfLeCJsvOKYse4ZTkzKpwca0ic7pvF56NcCuo78zONSttD6fwPbQ8WF1K1U0SB7X
         UlDV9J1bxnA39JDebFv88Ih9yMAhpKNzMhs3DSSH+i3y0wCXXEKit+1Igljmo8LFPwOz
         tr+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 31si22266234plk.42.2019.04.25.00.43.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:43:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 00:43:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,393,1549958400"; 
   d="scan'208";a="340645772"
Received: from fmsmsx106.amr.corp.intel.com ([10.18.124.204])
  by fmsmga006.fm.intel.com with ESMTP; 25 Apr 2019 00:43:11 -0700
Received: from fmsmsx119.amr.corp.intel.com (10.18.124.207) by
 FMSMSX106.amr.corp.intel.com (10.18.124.204) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 00:43:11 -0700
Received: from shsmsx103.ccr.corp.intel.com (10.239.4.69) by
 FMSMSX119.amr.corp.intel.com (10.18.124.207) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 00:43:11 -0700
Received: from shsmsx104.ccr.corp.intel.com ([169.254.5.92]) by
 SHSMSX103.ccr.corp.intel.com ([169.254.4.93]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 15:43:09 +0800
From: "Du, Fan" <fan.du@intel.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang"
	<fengguang.wu@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>,
	"Hansen, Dave" <dave.hansen@intel.com>, "xishi.qiuxishi@alibaba-inc.com"
	<xishi.qiuxishi@alibaba-inc.com>, "Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "Du, Fan" <fan.du@intel.com>
Subject: RE: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Thread-Topic: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Thread-Index: AQHU+wg4wWYFBheblUa8IPBSvnCJwqZL5rWAgACUV7A=
Date: Thu, 25 Apr 2019 07:43:09 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825785F04@SHSMSX104.ccr.corp.intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <20190425063807.GK12751@dhcp22.suse.cz>
In-Reply-To: <20190425063807.GK12751@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiZjYxZGQ3ZDctMzlmZC00NGU1LTk5NWQtZDc4MTZiNDJhMzNmIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoidkEyUDU5b1k3SDJFY2N0RkNxRWMrUFVTRkZQQWRLZ0cwa0d5eWl5VUZWdzF1WkRRXC9UT1hDQXVEdGdPd011RXUifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.239.127.40]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



>-----Original Message-----
>From: Michal Hocko [mailto:mhocko@kernel.org]
>Sent: Thursday, April 25, 2019 2:38 PM
>To: Du, Fan <fan.du@intel.com>
>Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
>Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
>Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
>ZONELIST_FALLBACK_SAME_TYPE fallback list
>
>On Thu 25-04-19 09:21:35, Fan Du wrote:
>> On system with heterogeneous memory, reasonable fall back lists woul be:
>> a. No fall back, stick to current running node.
>> b. Fall back to other nodes of the same type or different type
>>    e.g. DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3
>> c. Fall back to other nodes of the same type only.
>>    e.g. DRAM node 0 -> DRAM node 1
>>
>> a. is already in place, previous patch implement b. providing way to
>> satisfy memory request as best effort by default. And this patch of
>> writing build c. to fallback to the same node type when user specify
>> GFP_SAME_NODE_TYPE only.
>
>So an immediate question which should be answered by this changelog. Who
>is going to use the new gfp flag? Why cannot all allocations without an
>explicit numa policy fallback to all existing nodes?

PMEM is good for frequently read accessed page, e.g. page cache(implicit pa=
ge
request), or user space data base (explicit page request)

For now this patch create GFP_SAME_NODE_TYPE for such cases, additional
Implementation will be followed up.

For example:
a. Open file
b. Populate pagecache with PMEM page if user set O_RDONLY
c. Migrate frequently read accessed page to PMEM from DRAM,
  for cases w/o O_RDONLY.


>> Signed-off-by: Fan Du <fan.du@intel.com>
>> ---
>>  include/linux/gfp.h    |  7 +++++++
>>  include/linux/mmzone.h |  1 +
>>  mm/page_alloc.c        | 15 +++++++++++++++
>>  3 files changed, 23 insertions(+)
>>
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index fdab7de..ca5fdfc 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -44,6 +44,8 @@
>>  #else
>>  #define ___GFP_NOLOCKDEP	0
>>  #endif
>> +#define ___GFP_SAME_NODE_TYPE	0x1000000u
>> +
>>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>>
>>  /*
>> @@ -215,6 +217,7 @@
>>
>>  /* Disable lockdep for GFP context tracking */
>>  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
>> +#define __GFP_SAME_NODE_TYPE ((__force
>gfp_t)___GFP_SAME_NODE_TYPE)
>>
>>  /* Room for N __GFP_FOO bits */
>>  #define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
>> @@ -301,6 +304,8 @@
>>  			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
>>  #define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT |
>__GFP_DIRECT_RECLAIM)
>>
>> +#define GFP_SAME_NODE_TYPE (__GFP_SAME_NODE_TYPE)
>> +
>>  /* Convert GFP flags to their corresponding migrate type */
>>  #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
>>  #define GFP_MOVABLE_SHIFT 3
>> @@ -438,6 +443,8 @@ static inline int gfp_zonelist(gfp_t flags)
>>  #ifdef CONFIG_NUMA
>>  	if (unlikely(flags & __GFP_THISNODE))
>>  		return ZONELIST_NOFALLBACK;
>> +	if (unlikely(flags & __GFP_SAME_NODE_TYPE))
>> +		return ZONELIST_FALLBACK_SAME_TYPE;
>>  #endif
>>  	return ZONELIST_FALLBACK;
>>  }
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 8c37e1c..2f8603e 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -583,6 +583,7 @@ static inline bool zone_intersects(struct zone *zone=
,
>>
>>  enum {
>>  	ZONELIST_FALLBACK,	/* zonelist with fallback */
>> +	ZONELIST_FALLBACK_SAME_TYPE,	/* zonelist with fallback to the
>same type node */
>>  #ifdef CONFIG_NUMA
>>  	/*
>>  	 * The NUMA zonelists are doubled because we need zonelists that
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a408a91..de797921 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5448,6 +5448,21 @@ static void
>build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
>>  	}
>>  	zonerefs->zone =3D NULL;
>>  	zonerefs->zone_idx =3D 0;
>> +
>> +	zonerefs =3D
>pgdat->node_zonelists[ZONELIST_FALLBACK_SAME_TYPE]._zonerefs;
>> +
>> +	for (i =3D 0; i < nr_nodes; i++) {
>> +		int nr_zones;
>> +
>> +		pg_data_t *node =3D NODE_DATA(node_order[i]);
>> +
>> +		if (!is_node_same_type(node->node_id, pgdat->node_id))
>> +			continue;
>> +		nr_zones =3D build_zonerefs_node(node, zonerefs);
>> +		zonerefs +=3D nr_zones;
>> +	}
>> +	zonerefs->zone =3D NULL;
>> +	zonerefs->zone_idx =3D 0;
>>  }
>>
>>  /*
>> --
>> 1.8.3.1
>>
>
>--
>Michal Hocko
>SUSE Labs

