Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48463C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:41:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1407D214AE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:41:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1407D214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3B646B0008; Thu, 25 Apr 2019 03:41:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A12316B000A; Thu, 25 Apr 2019 03:41:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92A7D6B000C; Thu, 25 Apr 2019 03:41:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D02E6B0008
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:41:45 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y2so13534185pfn.13
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:41:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=G7gHHEOfNuEraVFjYBmCdx8NSVgzWxsQE56lW7FZBzE=;
        b=YsqfCPc7xPhjCGSAXkZMQPujKUT0dTZ6Arfe3k7VZLVwOzCAVx+0Ft6uL2aDvMlGt0
         c6V0tgFLkTMcWMyaDGExGQl950Bu9GXmGrbesKZ9B2NN7EqVqqmLVq1FZO3SmhcRelOr
         x7gR0i0Dhx5ePdcbnmSQfai4ivFjaz5b8BBiGT4Gw4L/zCFjilnOLHXSxqfx4wkcFbvX
         v0I75sMlDnZBt18lukE3QoafOS7RNYTEYhc54iE6+cYjL/gsTuuu9t6k+Wqv0MHXHsXO
         KIR1agE/tgcEX9WKkp2yaIkxt3oHTE1vPAaDfIUY+WUXFTrgOoZqfZUM+bI87BtWwnQC
         5L/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVP81iJs7ShStizOCl+VmPcc4geWD1uAY8t/Jmxo6qxH9bQmMcb
	3PFQxNf03WIyIH/sZ3UFf45M+neeIQsUC9VGOE4FmqqJP/Tqj4rpId59FwVCbfGlT2a4WzBYKJJ
	ufEaVjq+rwg8JJJfdQRV8q3xAyeKzuKEQiDCahBt3ytqvs2gZb1JscJ9FJMXuKSL8wg==
X-Received: by 2002:a63:ff04:: with SMTP id k4mr21217805pgi.117.1556178104983;
        Thu, 25 Apr 2019 00:41:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwY36oVnr1jlkPw8jhOgsSMcduNZ4Hk6BSrQ2VqL6L/JXFHZVjEXUatMhFmWIDcOQn5Bu/v
X-Received: by 2002:a63:ff04:: with SMTP id k4mr21217751pgi.117.1556178104114;
        Thu, 25 Apr 2019 00:41:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556178104; cv=none;
        d=google.com; s=arc-20160816;
        b=cQ0VaiZmP7u9bz+eTiDmF/mZPH5+o/Jz5KPjV25petQjMVPlqgwvSfEvWfaekm6c5F
         RWHfphSbXQLeCw3k8x4Xxu5VxMA/PVsIDBXjjBjpnoC6R6i1O2nIpEXqj1GPS+l/f66F
         AuiFCiL29kRVZjNshe6ocrp6wepR/4lHqlZtVA8tho95iu3N0TIZnIOYZSv3ovo13WS1
         qncpWbqHz2Tf/wbEiKSec1S/YFxS2rqRMch/0KZ9khh2gY1kWR6ltnpChW/kAM57mylT
         UduR28Q5kdw0AqkSWbrb0vtbK3/XvWTflQ41Hipmmgo0ORPXLzFW92yS3iOIltCyLE7N
         qykw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=G7gHHEOfNuEraVFjYBmCdx8NSVgzWxsQE56lW7FZBzE=;
        b=hZEQ2cdgIarUbvRM5wciYiSBt20jQviDcyNCt/gMmvuXKRNC7/iZgn8kzvXg5avk2u
         o9Ecy3mjoX9OvBfwsVFiUVuXzHNm4ZnOoaX/RpiQu29bOe+lweQbjeyZWSUnIdyuW9wO
         WFOSZg0iFmUtaUdOjxAHT94ESv6uYO1mYuS0hszbVr93KhgGCnlVg+EzTNw6HOn1ylBa
         mmQU6iTl3BxnvYbCDFvSpsyxcVQUMf/fdrvKDXIZRzswvsKr7AGuk80p8BSb777FGzWY
         935NOcAJOgeEqEpXSQ41dT5F8fnHaV738c3cKUxLAUd4PBDVES+qhEHCg4ooY20dh3yi
         GAHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m12si20130152pgc.157.2019.04.25.00.41.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:41:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 00:41:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,393,1549958400"; 
   d="scan'208";a="340645474"
Received: from fmsmsx106.amr.corp.intel.com ([10.18.124.204])
  by fmsmga006.fm.intel.com with ESMTP; 25 Apr 2019 00:41:43 -0700
Received: from fmsmsx157.amr.corp.intel.com (10.18.116.73) by
 FMSMSX106.amr.corp.intel.com (10.18.124.204) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 00:41:43 -0700
Received: from shsmsx107.ccr.corp.intel.com (10.239.4.96) by
 FMSMSX157.amr.corp.intel.com (10.18.116.73) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 00:41:42 -0700
Received: from shsmsx104.ccr.corp.intel.com ([169.254.5.92]) by
 SHSMSX107.ccr.corp.intel.com ([169.254.9.153]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 15:41:41 +0800
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
Thread-Index: AQHU+wguqC0/BskpLkaHU1TotE//DKZL5oWAgACMEvA=
Date: Thu, 25 Apr 2019 07:41:40 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825785EE8@SHSMSX104.ccr.corp.intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <20190425063727.GJ12751@dhcp22.suse.cz>
In-Reply-To: <20190425063727.GJ12751@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiYTAwMTA2OGUtZjhlYy00ZDA5LWE0MWQtZWI5ZTMyOWQ3ZWY3IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiYTdHdVZlWVhvblh5XC9BV0FNcFZEd2RJZElMUEFwbERINElTOVdaK0FTRHBGK01PcWpLZ3hCN3J3SHNaZngxS2cifQ==
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
>Sent: Thursday, April 25, 2019 2:37 PM
>To: Du, Fan <fan.du@intel.com>
>Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
>Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
>Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous
>memory system
>
>On Thu 25-04-19 09:21:30, Fan Du wrote:
>[...]
>> However PMEM has different characteristics from DRAM,
>> the more reasonable or desirable fallback style would be:
>> DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3.
>> When DRAM is exhausted, try PMEM then.
>
>Why and who does care? NUMA is fundamentally about memory nodes with
>different access characteristics so why is PMEM any special?

Michal, thanks for your comments!

The "different" lies in the local or remote access, usually the underlying
memory is the same type, i.e. DRAM.

By "special", PMEM is usually in gigantic capacity than DRAM per dimm,=20
while with different read/write access latency than DRAM. Iow PMEM
sits right under DRAM in the memory tier hierarchy.

This makes PMEM to be far memory, or second class memory.
So we give first class DRAM page to user, fallback to PMEM when
necessary.

The Cloud Service Provider can use DRAM + PMEM in their system,
Leveraging method [1] to keep hot page in DRAM and warm or cold
Page in PMEM, achieve optimal performance and reduce total cost
of ownership at the same time.

[1]:
https://github.com/fengguang/memory-optimizer

>--
>Michal Hocko
>SUSE Labs

