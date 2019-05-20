Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BDECC04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:46:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21CEA2173E
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 23:46:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21CEA2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE03E6B0003; Mon, 20 May 2019 19:46:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A6A086B0005; Mon, 20 May 2019 19:46:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E3C86B0006; Mon, 20 May 2019 19:46:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 54F066B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 19:46:23 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g11so10120908plb.3
        for <linux-mm@kvack.org>; Mon, 20 May 2019 16:46:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:user-agent:content-id
         :content-transfer-encoding:mime-version;
        bh=xUaJlsiU4QJz1VeUabVN8J1wfCr8DqHqyzzWJlTTEiA=;
        b=WkcVSm9wCbL2DUUHmz9iHs/VqpOh2B0K37E9G3F7jQvxpI3SejzCeSwTB+3LgoMhnq
         Vy/I3FUMRCaPjIvm4NrV7XLzA7s2lxhZLneRipIyKGdv4VQdOZcTgA4jpa/ZDVSu5rJx
         z2gb5gJOQ7RB+WPpTSvpLUaCkrYc07ikGS7qyzlic4C66p4r7m5ftrSdwaTq2zbGctur
         SaNw13XY2sQaQZTeFELxeXlwFFuMfh0MsdRIkzWkJY9EBywPyL97HsISK4xllzSWH5z/
         4uzURN4xRszg7scealBOKlH/62jhIpXcdfRCcPYnq6hYolWFEBysdgAPyHVg8q8SVdWb
         f6mA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUXt4tjomdOVlWnMD3xzMozF8c0u+7FmfnNB64KMXPJMtJv4O1m
	2bQ72fPrAEBu+c0lq7884bc9bd3yuQdJSOV8iqu4fxH3xPgUyf01o+L6VaMatMLRRiX0gvoe1Ee
	spOnSBY287HGnWOYvI8TepeYBkvQxhxGGVefaaG19MIDFt8Qr8SYkpFhHuXh+2ySDjA==
X-Received: by 2002:a17:902:8508:: with SMTP id bj8mr35963421plb.79.1558395983018;
        Mon, 20 May 2019 16:46:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxa8/isvjG+L7kpjyCrVI0Ma76znCvhM0RQYhNJJyZm0yiqPX40chq6+32Hi3OXfMb8I8Yo
X-Received: by 2002:a17:902:8508:: with SMTP id bj8mr35963372plb.79.1558395982429;
        Mon, 20 May 2019 16:46:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558395982; cv=none;
        d=google.com; s=arc-20160816;
        b=zKaYXr/vLOwTR906kO7GT1jpN5XNAvTeMtHYsQEmlW/B5Xq888NbQvkkbdidacAFdh
         DkDXepUljJgYyGT5DJcE21V8PX+uBg79QhOMCq2lE9PQgpYuc+yrErAhENQBxkKe13W6
         0fOmesL7l29OwOldzhzkvxerLF/2BGLvAYl270LkAYnBFvVmGBesP1vMjw31vSIbbjj8
         J6Z08m2D8HSvdHP9G+OEzaUoFazTmAj7UCwH9AH49yETGvDEn1CyazeXxzKiZlM+FFmt
         VYaW3keoIOVTDYO1Y5PfqF4unva8WS5Gzjvy6dReqy1VVfBbe5oEJmJ50A5c0VVIOxc4
         z19A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:user-agent
         :content-language:accept-language:in-reply-to:references:message-id
         :date:thread-index:thread-topic:subject:cc:to:from;
        bh=xUaJlsiU4QJz1VeUabVN8J1wfCr8DqHqyzzWJlTTEiA=;
        b=U+Qu9KmJrn0Sz6D8tedbbkyblMHQTaxgVjyXac1Bdru86HsIoFrSmv3++q7+brVWGG
         zelwRCmdYOhlReL+6PyAoU5XcBO2m7E79MwpXYmcDQCPcvISBAPZIjt3kIULVFndgqXK
         aPYR7jPxZ45U+XxczRpM4Z04Lan4DonZXKSszd7WGSijvs+pTv285UYixuOIHgy2reR9
         cVZmqgbQHC0xNcs60FexJDg04Osfw0GtHTRCXJ2O79cUN+3htLUMY9iMMEIVNtVzy7Lh
         qRqkAsJ90f6afnOT7PON7TeEtuOH1QISbSb2HWqUGo5trAxV3sEqCeYYD8Mgbm83piXT
         g20w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x4si1190592plv.130.2019.05.20.16.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 16:46:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 May 2019 16:46:22 -0700
X-ExtLoop1: 1
Received: from orsmsx108.amr.corp.intel.com ([10.22.240.6])
  by orsmga007.jf.intel.com with ESMTP; 20 May 2019 16:46:22 -0700
Received: from orsmsx155.amr.corp.intel.com (10.22.240.21) by
 ORSMSX108.amr.corp.intel.com (10.22.240.6) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Mon, 20 May 2019 16:46:21 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.79]) by
 ORSMSX155.amr.corp.intel.com ([169.254.7.142]) with mapi id 14.03.0415.000;
 Mon, 20 May 2019 16:46:21 -0700
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
	"luto@amacapital.net" <luto@amacapital.net>
CC: "davem@davemloft.net" <davem@davemloft.net>, "namit@vmware.com"
	<namit@vmware.com>, "Hansen, Dave" <dave.hansen@intel.com>
Subject: Re: [PATCH v2 0/2] Fix issues with vmalloc flush flag
Thread-Topic: [PATCH v2 0/2] Fix issues with vmalloc flush flag
Thread-Index: AQHVD2U2cXoGKMM3a0GhDqndH7zde6Z1IwAA
Date: Mon, 20 May 2019 23:46:21 +0000
Message-ID: <d92aa15b453b2a53bcd0bbaa8f35e8151eaae17b.camel@intel.com>
References: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
In-Reply-To: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
user-agent: Evolution 3.30.1 (3.30.1-1.fc29) 
x-originating-ip: [10.254.114.95]
Content-Type: text/plain; charset="utf-8"
Content-ID: <4C4DD1DA9B51AB45870C0B33D125E8DB@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA1LTIwIGF0IDE2OjM4IC0wNzAwLCBSaWNrIEVkZ2Vjb21iZSB3cm90ZToN
Cj4gVGhlc2UgdHdvIHBhdGNoZXMgYWRkcmVzcyBpc3N1ZXMgd2l0aCB0aGUgcmVjZW50bHkgYWRk
ZWQNCj4gVk1fRkxVU0hfUkVTRVRfUEVSTVMgdm1hbGxvYyBmbGFnLiBJdCBpcyBub3cgc3BsaXQg
aW50byB0d28gcGF0Y2hlcywNCj4gd2hpY2gNCj4gbWFkZSBzZW5zZSB0byBtZSwgYnV0IGNhbiBz
cGxpdCBpdCBmdXJ0aGVyIGlmIGRlc2lyZWQuDQo+IA0KT29wcywgdGhpcyB3YXMgc3VwcG9zZWQg
dG8gc2F5IFBBVENIIHYzLiBMZXQgbWUga25vdyBpZiBJIHNob3VsZA0KcmVzZW5kLg0K

