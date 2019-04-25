Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B02D3C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:18:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6975D218B0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 09:18:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6975D218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 055EB6B0005; Thu, 25 Apr 2019 05:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 006B86B0006; Thu, 25 Apr 2019 05:18:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5E306B0007; Thu, 25 Apr 2019 05:18:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD8A66B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:18:08 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j18so13678753pfi.20
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 02:18:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=hrqBoE1YwE3mWKEoyTaF/RUYLJzLU8tBFqETEAgrjtA=;
        b=IkjSrfsabKrL7yAbBSHooQXJC7g6C5AyvjUu64SP+75LwFPjQqRVRqTcu+HdgWWF/G
         iSi38N66ryHenGjpGuYU7z74D/emSwQPpPObXr62O90GqumloaIblfGDFjAXaNQ4+VpH
         5W7P/n7LKy5BnBC1suA9I7/MzAsyMYPc/QZzmAdhMf5SRCTYMwlRTx75bgXwss8fTk0p
         1G+UHSJuC4EePdTr0m1KapqRkilKdW2Hvnn/c8V0bJbFv0pr2eocHSVu2npLhdGJ96dR
         P1D7ktUBz22x/qiPa2o/2HRK5V5pJacwuJgDfmakgi/3m2HKoeDaJucFRJSWYIOlykxR
         TG4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXr7A+9NT79HtHePUyOzwwpFSTudfobopqW33qk5y4jfGgh8l09
	LQuv2oQ1QN8ZhsluPzqhBGA08FK8U1g1WyUHvd54t7QMIVei898HOj47d35ivtMvWFXK+Nw2YHh
	GajwIX3q5e3DyDgyUfABQ3HMGnEgggco5DA84LPeT2zfPk0M+5aQkdHySp6Do7Dttiw==
X-Received: by 2002:a63:ff05:: with SMTP id k5mr23417372pgi.342.1556183888088;
        Thu, 25 Apr 2019 02:18:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweGDdsNiXN2oPIaOI0QZF2apQFBq7Jr3oTo3sfgQA2Onw2/GImICLch+fcfnoXxlkhU+Sl
X-Received: by 2002:a63:ff05:: with SMTP id k5mr23417312pgi.342.1556183887272;
        Thu, 25 Apr 2019 02:18:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556183887; cv=none;
        d=google.com; s=arc-20160816;
        b=seeOCR2jobihm+nB3K+4Qt93Ijg8np3NI3vSRWhSezHNrBBeqBtx7FWOjTi88yfZC2
         BYG9iJCxgEUyABXRlVHfEJrSKtwC75esb1ErzuNTdAtuVRGvtwPn/DYYHRX0toncJbsi
         AufYNxGrjxLjIHiZzo8S6509bDAeDwpEiziFSs/ia0sj4nmXVE90CyYOkMx3LPygzH86
         B93foaWNnddLfCzVfxJqoa7AZwf2xtULpddIspEPXK3Q7qEjq0ZvTm/wY3W8V/cqnsgI
         qI9eZX2Es1ySfsE3WVBYYKbvLfrzOM2qoHfLlbOGB4zLv5thP1+GXaoiUHkHP8fxhOOc
         dF5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=hrqBoE1YwE3mWKEoyTaF/RUYLJzLU8tBFqETEAgrjtA=;
        b=Vyhj994fABozbMHABsgxRy1xCHbFCY1T9n8SSzMk8FajzbGAWscCKiLMotvct45t9k
         7O7ydEGinOZ2pBAbtMgqcFH8Mc3dChqg/0E1mTcf8N3QJy18Kw91XKqqSQBslwFir0Cg
         vP1knv+3xSCMLg1LhCKSZqYlOYVDR8oy2KoVclLdlpfN1KdW5CKYpCCVHklniYSVNDCL
         pahqcFEig/mbHfRmojIvLVyXEitpAovqkhN+BzhRINJPjznDVLdNX81PJKuW2bRZBKYk
         wpkQXNLi9OW45DGFOq4xqlK1uyBze1JoNt4EbkXZ0ZYh8i+PNANWvXqU574075QZXqAU
         jJkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h3si3607378pgg.83.2019.04.25.02.18.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 02:18:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 02:18:06 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,393,1549958400"; 
   d="scan'208";a="167792309"
Received: from fmsmsx107.amr.corp.intel.com ([10.18.124.205])
  by fmsmga001.fm.intel.com with ESMTP; 25 Apr 2019 02:18:06 -0700
Received: from fmsmsx162.amr.corp.intel.com (10.18.125.71) by
 fmsmsx107.amr.corp.intel.com (10.18.124.205) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 02:18:06 -0700
Received: from shsmsx152.ccr.corp.intel.com (10.239.6.52) by
 fmsmsx162.amr.corp.intel.com (10.18.125.71) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 02:18:05 -0700
Received: from shsmsx104.ccr.corp.intel.com ([169.254.5.92]) by
 SHSMSX152.ccr.corp.intel.com ([169.254.6.42]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 17:18:04 +0800
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
Thread-Index: AQHU+wg4wWYFBheblUa8IPBSvnCJwqZL5rWAgACUV7D//39ggIAAhyuw//9+rQCAAIghcP//gTcAABHkxSA=
Date: Thu, 25 Apr 2019 09:18:03 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825786020@SHSMSX104.ccr.corp.intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <20190425063807.GK12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F04@SHSMSX104.ccr.corp.intel.com>
 <20190425074841.GN12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F50@SHSMSX104.ccr.corp.intel.com>
 <20190425080936.GP12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785FA5@SHSMSX104.ccr.corp.intel.com>
 <20190425084302.GQ12751@dhcp22.suse.cz>
In-Reply-To: <20190425084302.GQ12751@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiODQwNThjYmYtYmNiNi00Y2IxLTllY2QtZmFlNWEzYWU0OWM5IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiMDM5V281XC94Zm1Yc2dwc1lqZnJCTDhmckFrZFBId2Rpc0t6TTJva1hJOTJJMk9acWZNRVZ1NHBrZ2JURWJMVVMifQ==
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
>From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
>Behalf Of Michal Hocko
>Sent: Thursday, April 25, 2019 4:43 PM
>To: Du, Fan <fan.du@intel.com>
>Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
>Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
>Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
>ZONELIST_FALLBACK_SAME_TYPE fallback list
>
>On Thu 25-04-19 08:20:28, Du, Fan wrote:
>>
>>
>> >-----Original Message-----
>> >From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On
>> >Behalf Of Michal Hocko
>> >Sent: Thursday, April 25, 2019 4:10 PM
>> >To: Du, Fan <fan.du@intel.com>
>> >Cc: akpm@linux-foundation.org; Wu, Fengguang
><fengguang.wu@intel.com>;
>> >Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
>> ><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
>> ><ying.huang@intel.com>; linux-mm@kvack.org;
>linux-kernel@vger.kernel.org
>> >Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
>> >ZONELIST_FALLBACK_SAME_TYPE fallback list
>> >
>> >On Thu 25-04-19 07:55:58, Du, Fan wrote:
>> >> >> PMEM is good for frequently read accessed page, e.g. page
>cache(implicit
>> >> >> page
>> >> >> request), or user space data base (explicit page request)
>> >> >> For now this patch create GFP_SAME_NODE_TYPE for such cases,
>> >additional
>> >> >> Implementation will be followed up.
>> >> >
>> >> >Then simply configure that NUMA node as movable and you get these
>> >> >allocations for any movable allocation. I am not really convinced a =
new
>> >> >gfp flag is really justified.
>> >>
>> >> Case 1: frequently write and/or read accessed page deserved to DRAM
>> >
>> >NUMA balancing
>>
>> Sorry, I mean page cache case here.
>> Numa balancing works for pages mapped in pagetable style.
>
>I would still expect that a remote PMEM node access latency is
>smaller/comparable to the real storage so a promoting part is not that
>important for the unmapped pagecache. Maybe I am wrong here but that
>really begs for some experiments before we start adding special casing.

I understand your concern :), please refer to following summary from 3rd pa=
rty.
https://arxiv.org/pdf/1903.05714.pdf


>--
>Michal Hocko
>SUSE Labs

