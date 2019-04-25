Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48FFAC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:05:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F25B217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:05:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F25B217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B9736B0005; Thu, 25 Apr 2019 04:05:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76A536B0006; Thu, 25 Apr 2019 04:05:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 656CD6B0007; Thu, 25 Apr 2019 04:05:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9806B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:05:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2so13841116pge.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:05:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=IXDD4yGDXPNkBlxG8ErFca22EuijYJuS/nkJ3gL9njM=;
        b=eVWwGJG8IJ/rQylTGzOx/bg9pe/95RxM1ZMgglz7OD0D0q+1jj7VLLhZB7QDwHEnya
         lq9SUFOID9Wxb9Q3cMp7xYM6TgSCglGmpUUvaf2HoPF7AFGt8JPxanhtW30jNa/a3dNz
         VOHNx2S8kvlZKpkK0gAGPYizlAeeePbOqN7d665mNXKJTIk7HRHrHUM0zr03T4hHvRhf
         RidsxTYRXhra8A3gTVf4m8LYqz9otl/4zgPjW/MZLBWPAo92Ec3oByDgwkCwHdcLa14o
         +HjyG9h4dW7JIeKWvrZGnViNpMZPFz1f67QTYzWiWHws2bvSsktnMcu9QRhQgI2meZ4S
         K7lw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWPcugGTOoWxfKNUT/evQVwOrH1hUEwwpZs2w1PdKvoHXdYV04J
	FNE62+XUoeTFPGVDJGNguaujnHBJOI23lvwVKVFxNcLGGJ7q9ZQa8MntYhG6SKGS/duvslfU6Rn
	3yfEMYr577RfVBTILOihSVkt1VhQiyzHjQklugSDYHkTrh+3KZ6GcNhOlnBI2te3akA==
X-Received: by 2002:a63:2b41:: with SMTP id r62mr35735632pgr.403.1556179543739;
        Thu, 25 Apr 2019 01:05:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPzsbB/iLf0JkIw2J+l7zGuGG+6TQ3VUFsnOePQ2GTQIeGq+0rH6irj5udFOuW1m0G0Fsy
X-Received: by 2002:a63:2b41:: with SMTP id r62mr35735568pgr.403.1556179542985;
        Thu, 25 Apr 2019 01:05:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556179542; cv=none;
        d=google.com; s=arc-20160816;
        b=Zw62ovlqwBEokoAK8ZXX1yJYOABRhKhJBONIiePvQyp8mK1gaVuRBKo47fH2eLlIMd
         v7Q/tdiAQnXvwa0QBUkwV1VmMKqnoUuL6jMNep7LBI1Wzx4oG0n9/LhwO0VUbX/Kxdg+
         B+gchNhp9Fzd+jYDiWdoMZyAU9AkuRVgqOe43jY441F9c/4aUoA3yDXLYed8SpmO/Rk/
         hag7Rp+D2VjlW+Vuptvkg4Pl1THA/Q5EO9fEaSqU0W7TRch+WG8eZFMKSijt0sHUFOtl
         CVyzbQMiaw+K96q7Rr7WdNcWlyha4mUcERucgydEbJ2t53ItFeGPtF8tDrOD7y1u/IGl
         jTNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=IXDD4yGDXPNkBlxG8ErFca22EuijYJuS/nkJ3gL9njM=;
        b=O9ieRGtSTEHSGavHKpl6jMxdSArs/iuNnZubSd5JTOymKnVHGM9dFYzjLoVxG1fSOB
         nPSRhuxB0DdilBy92VEhKVwHjlls8NcAsJHpHRIZI/W36ZCnWj8GoJ77Z8Lcu9dBE/3a
         yku7utd6Ed9ALU86bd63W/KIDMopU9R5xhWchfCio1HPoN1c4SOT49+6XPjD2XLhAaze
         BQL7uxv5Ple+eSdhjj0L1Wyeubp0V9OX4q+zKO/eDzd70PrX0y+6pQvVP+8ggQdWw/kC
         /q4G7UNHY60EABaKoq4neVV5/AF9ToPKAblvhEf1vq1etmmHtiVLEH3/IlN1pAbso7rx
         nThA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v25si21335254pfe.22.2019.04.25.01.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 01:05:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 01:05:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,393,1549958400"; 
   d="scan'208";a="145575472"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by orsmga003.jf.intel.com with ESMTP; 25 Apr 2019 01:05:42 -0700
Received: from fmsmsx115.amr.corp.intel.com (10.18.116.19) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 01:05:41 -0700
Received: from shsmsx103.ccr.corp.intel.com (10.239.4.69) by
 fmsmsx115.amr.corp.intel.com (10.18.116.19) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 01:05:41 -0700
Received: from shsmsx104.ccr.corp.intel.com ([169.254.5.92]) by
 SHSMSX103.ccr.corp.intel.com ([169.254.4.93]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 16:05:39 +0800
From: "Du, Fan" <fan.du@intel.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang"
	<fengguang.wu@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>,
	"Hansen, Dave" <dave.hansen@intel.com>, "xishi.qiuxishi@alibaba-inc.com"
	<xishi.qiuxishi@alibaba-inc.com>, "Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "Du, Fan" <fan.du@intel.com>
Subject: RE: [RFC PATCH 0/5] New fallback workflow for heterogeneous memory
 system
Thread-Topic: [RFC PATCH 0/5] New fallback workflow for heterogeneous memory
 system
Thread-Index: AQHU+wguqC0/BskpLkaHU1TotE//DKZL5oWAgACMEvD//4lJgIAAhy/Q
Date: Thu, 25 Apr 2019 08:05:38 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825785F6E@SHSMSX104.ccr.corp.intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <20190425063727.GJ12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785EE8@SHSMSX104.ccr.corp.intel.com>
 <20190425075353.GO12751@dhcp22.suse.cz>
In-Reply-To: <20190425075353.GO12751@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiYjQzYjI5MDEtYzA0OC00YjFhLWExZWQtNjI0ZDFlYWYwMGU5IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiOGxlSk84SDgyWVM3akFtZ2ozbkpSdXh2SlhoaEh1ZmJpaE13cjJCa1wvWlZzNFwvd1NTZlJqRXZlVFdaMTEzS0lGIn0=
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
>Sent: Thursday, April 25, 2019 3:54 PM
>To: Du, Fan <fan.du@intel.com>
>Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
>Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
>Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous
>memory system
>
>On Thu 25-04-19 07:41:40, Du, Fan wrote:
>>
>>
>> >-----Original Message-----
>> >From: Michal Hocko [mailto:mhocko@kernel.org]
>> >Sent: Thursday, April 25, 2019 2:37 PM
>> >To: Du, Fan <fan.du@intel.com>
>> >Cc: akpm@linux-foundation.org; Wu, Fengguang
><fengguang.wu@intel.com>;
>> >Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
>> ><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
>> ><ying.huang@intel.com>; linux-mm@kvack.org;
>linux-kernel@vger.kernel.org
>> >Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous
>> >memory system
>> >
>> >On Thu 25-04-19 09:21:30, Fan Du wrote:
>> >[...]
>> >> However PMEM has different characteristics from DRAM,
>> >> the more reasonable or desirable fallback style would be:
>> >> DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3.
>> >> When DRAM is exhausted, try PMEM then.
>> >
>> >Why and who does care? NUMA is fundamentally about memory nodes
>with
>> >different access characteristics so why is PMEM any special?
>>
>> Michal, thanks for your comments!
>>
>> The "different" lies in the local or remote access, usually the underlyi=
ng
>> memory is the same type, i.e. DRAM.
>>
>> By "special", PMEM is usually in gigantic capacity than DRAM per dimm,
>> while with different read/write access latency than DRAM.
>
>You are describing a NUMA in general here. Yes access to different NUMA
>nodes has a different read/write latency. But that doesn't make PMEM
>really special from a regular DRAM.=20

Not the numa distance b/w cpu and PMEM node make PMEM different than
DRAM. The difference lies in the physical layer. The access latency charact=
eristics
comes from media level.

>There are few other people trying to
>work with PMEM as NUMA nodes and these kind of arguments are repeating
>again and again. So far I haven't really heard much beyond hand waving.
>Please go and read through those discussion so that we do not have to go
>throug the same set of arguments again.
>
>I absolutely do see and understand people want to find a way to use
>their shiny NVIDIMs but please step back and try to think in more
>general terms than PMEM is special and we have to treat it that way.
>We currently have ways to use it as DAX device and a NUMA node then
>focus on how to improve our NUMA handling so that we can get maximum
>out
>of the HW rather than make a PMEM NUMA node a special snow flake.
>
>Thank you.
>
>--
>Michal Hocko
>SUSE Labs

