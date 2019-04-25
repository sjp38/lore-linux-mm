Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_DBL_SPAM autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC594C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:20:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73E09214AE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:20:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73E09214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AAAA6B0005; Thu, 25 Apr 2019 04:20:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 059FF6B0006; Thu, 25 Apr 2019 04:20:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3D346B0007; Thu, 25 Apr 2019 04:20:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4E7D6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:20:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y2so13597168pfn.13
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:20:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=bi/A+lmZHZ7tllRZShRtFW37ZCmGfynRZiY3aTpmTyc=;
        b=PvGmxCTLMCUsGZll/GcOVRAx3YtyYA2m9FqFn4BWHn0gaFjFg5z0KSRqAmyPsIguOw
         XifPM7hI1RvI98rxfTfi87wNj5iaAAAkGMQU94MZ4baROnqnFN/MY/z8DSC/L4v7GRVf
         kIEgMCdg1vXypygW5Fbr2NpBHtdP62qcx1RU74ZFba/P1PvajklOW2ZycTXs8/Nbvk7N
         sBzbDr3ihZKkmelUY5w55grFnDCfLMwjsaXZTJQnzN8ZgVM3W22IVfnNSlnW+aDHRwv+
         6QTA0r08pd7XQyNBd3h4Q+sdz0/lptBRUg3dTCoE3zJQAAeC6Z1AopDu5jMw3U0Y2Bft
         QnTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWqN6vbkEyANOzjjlNHuY39vSjW2DnWMACsHCBC7GXSg4lRvf0R
	lXV/6Uc3pN5xSDigrod9/wZdpcP/qEQmeJ0WxLxuNj9Gvx6RWmGt5RjhoNq/r/IzGnLHgxCZvxE
	krFc9Bsr0I8ilMbE7wQOgeNLgD+e3uBDqq4BLF70BLCicsZONYDAZC7NOQ4cXL57poQ==
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr36836324plk.226.1556180432316;
        Thu, 25 Apr 2019 01:20:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuCtX+KY004VzY9NpUnzYaMWkNlPhgDn02TUlNupISnVBvevsv3NgG17M/qmrpt7HvwHDe
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr36836270plk.226.1556180431481;
        Thu, 25 Apr 2019 01:20:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556180431; cv=none;
        d=google.com; s=arc-20160816;
        b=nqp+VsCVfLkrCByjPYNMDp2uQLfJPUepK13msc0R0aer2Lfipo0EWpe8yomQJtdBUE
         Dg7aUH7gg2rxvRUz3vp0ScepipwbwV8oO8eXeVGC1Sn8c84lOhX5/KQ92mYif2C4iw/I
         /XkUoUTm1j8SJ1YzoUiZqFoVNTLU4X3tHbZdiplRY7ht3wDQANA0/dzECbHccmXhuXr0
         JuozvAArhmZN7enC+h//C/7VnnaqV5sBW8E8JuqoZbCPni2Civ+Hn4p31lvHCBDmI4ta
         t2femjxIQp/4RJFLViFklpf7kj0uOe19aO006u8EokEzlWyLhMVHEzJRjiRJJG8ZaM5M
         Ji5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=bi/A+lmZHZ7tllRZShRtFW37ZCmGfynRZiY3aTpmTyc=;
        b=zwU6g8alxjdptRQjKhrByiJkKgEnyb0J/YcvZ47Z5tkdPVfmrecsyUXuGOTDTRoB3W
         GVKoY4OECH1wMnF4pjoh7EcPvwn4eaeROpHKw3WYUYuqrEDZoyWyaMv4TJVuE3WCuZcy
         TFV9wWoAU0qflgF6Doykh4QqIABK0rs11tgxKYV2gu3YFAtqN9q0mN4GrlOzlgq4SUO3
         YsWIxZMGbs3HaoD2Jlm6kI/9w3XaglKr6m5qmPIqkQTr7/C3qQYXHrMoycEmFUJ1DCKM
         CE0ajiGSlNBbWc+h65KO9lyYURAgfMNz0uCbbvS9Ca1ZWQeQz3PJ/bhXavILVgjE5iNJ
         mB3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x6si21645050pfa.59.2019.04.25.01.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 01:20:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 01:20:31 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,393,1549958400"; 
   d="scan'208";a="167777569"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by fmsmga001.fm.intel.com with ESMTP; 25 Apr 2019 01:20:31 -0700
Received: from fmsmsx112.amr.corp.intel.com (10.18.116.6) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 01:20:30 -0700
Received: from shsmsx151.ccr.corp.intel.com (10.239.6.50) by
 FMSMSX112.amr.corp.intel.com (10.18.116.6) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 01:20:30 -0700
Received: from shsmsx104.ccr.corp.intel.com ([169.254.5.92]) by
 SHSMSX151.ccr.corp.intel.com ([169.254.3.39]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 16:20:28 +0800
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
Thread-Index: AQHU+wg4wWYFBheblUa8IPBSvnCJwqZL5rWAgACUV7D//39ggIAAhyuw//9+rQCAAIghcA==
Date: Thu, 25 Apr 2019 08:20:28 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825785FA5@SHSMSX104.ccr.corp.intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <20190425063807.GK12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F04@SHSMSX104.ccr.corp.intel.com>
 <20190425074841.GN12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F50@SHSMSX104.ccr.corp.intel.com>
 <20190425080936.GP12751@dhcp22.suse.cz>
In-Reply-To: <20190425080936.GP12751@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiZmJmNWYxYjEtMjYxNi00MDJmLWFiOTctYjk3MTU2NWM1ZDVlIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiUDFjWnZrYUdLeUJNTngxWm5sWW1aQlcwSDd6QnhocXpud2dFZGRWajlIb2drSmdTMzBuK2lZUG14QlFnQnBZbyJ9
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
>Sent: Thursday, April 25, 2019 4:10 PM
>To: Du, Fan <fan.du@intel.com>
>Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
>Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
>Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
>ZONELIST_FALLBACK_SAME_TYPE fallback list
>
>On Thu 25-04-19 07:55:58, Du, Fan wrote:
>> >> PMEM is good for frequently read accessed page, e.g. page cache(impli=
cit
>> >> page
>> >> request), or user space data base (explicit page request)
>> >> For now this patch create GFP_SAME_NODE_TYPE for such cases,
>additional
>> >> Implementation will be followed up.
>> >
>> >Then simply configure that NUMA node as movable and you get these
>> >allocations for any movable allocation. I am not really convinced a new
>> >gfp flag is really justified.
>>
>> Case 1: frequently write and/or read accessed page deserved to DRAM
>
>NUMA balancing

Sorry, I mean page cache case here.
Numa balancing works for pages mapped in pagetable style.

>> Case 2: frequently read accessed page deserved to PMEM
>
>memory reclaim to move those pages to a more distant node (e.g. a PMEM).
>
>Btw. none of the above is a static thing you would easily know at the
>allocation time.
>
>Please spare some time reading surrounding discussions - e.g.
>http://lkml.kernel.org/r/1554955019-29472-1-git-send-email-yang.shi@linux.=
a
>libaba.com

Thanks for the point.

>Michal Hocko
>SUSE Labs

