Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54AE1C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:55:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BB3C207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:55:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BB3C207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 958AE8E00DE; Thu, 21 Feb 2019 19:55:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DEEB8E00D4; Thu, 21 Feb 2019 19:55:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 759688E00DE; Thu, 21 Feb 2019 19:55:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31BA18E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:55:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p9so483244pfn.9
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:55:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=O8vuQfGlo1O3KNQALbnDTvWERg9PCDRDAgDZfuG9XdA=;
        b=oQCPjJc08rSDfpTSZfJ99d4Cl0ZB6DQkeSV0dJcUeb++Dmb7FD/ZARNoaZF7NsRD8H
         t00Loqs1oVdPOqonr7JO3WZ2ixEUZmsW7L3pv3nlT6Gdzfb3CRwTyxeh1jxZeW2UFM1I
         WSLZw7fmXAgx2Uk2n7n8liHmFrDvg+dtooWltUHPj93pfHOClXho1W/f0yqcQebqKXbQ
         pEt+w5Cqwn811d+sPFbTvJBxqAzO3dflL3nvJ8i9YzSjF3C3JofMFdCJERFwewq9dNKk
         FD5fnfDSTLYbqFLLoeTfYky8MG2dwvCTpFc0rQ1J5uNnMrEAGjD46qpWBFgAHYnPSALk
         anvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZnxqq9FUNOU/PEAWzbQFHv//ogR6wCb05v6Ire3LxfN6u9ArHG
	dHxydCg1kVNtch/ZwupHexr8VIe8yGqpxyULR2L9eWqVBYGfKQgU4Z31rpdmGDA/koWcG+CPvdT
	G4PIQ6x9xr1sGGcW39VxzwUUQGBQsiNLDDFYhHvZ3brCC7Pf2SeHXKm0/V1QsIgpwPg==
X-Received: by 2002:a63:f453:: with SMTP id p19mr1258319pgk.232.1550796951891;
        Thu, 21 Feb 2019 16:55:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVoELSwcWW3mpTNazlY/fgXv1rnuz3uIVLZEKV9jRGfyx+wBaL/AtGLRdX0zHxUNogXi67
X-Received: by 2002:a63:f453:: with SMTP id p19mr1258279pgk.232.1550796951135;
        Thu, 21 Feb 2019 16:55:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550796951; cv=none;
        d=google.com; s=arc-20160816;
        b=xDkEy7AtDAOJfrrLQsn6DwtHezZTBI8AX+FXBw13J5cytO93214pOR7rT3USgEsy2i
         KtDwKyTKDKXyUL5T50yaqxGSPeJSM86k6FHGYqCYVzvTX002qRT5xL3rG+T/9NdnjFxF
         Z/y7sGBnfq22ijRcwwVPeL806JXibq50vtGET0V9Yyr86bIrtV3etF/+Zt+OfjvF7mK8
         mZbAhpXDKH6Nrg34jkMV3N0yrEnC7GzsW/Up1UCFPnb8MZMK5jFI2+TVfCVIQyOx2u9Q
         66NBHbU5YQKBMKJLud5RrNr+IfCUwcDvxPxN2q2W9XjNbr2nBAAeQsbGnDmTjtlppY5D
         KntQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=O8vuQfGlo1O3KNQALbnDTvWERg9PCDRDAgDZfuG9XdA=;
        b=XZKj9l1du6SMnjnK81Po66sYjP5bRE9p9lvv8rvkRu2tHXo3QPtIilCct4+bnxFXQN
         qQJjYfNsCYxV+HnInOJU+9zFBQiv34sbtm0d50FiaZkmJ9jpM/kmsyBxwAJx8H8dBx8d
         Q/18Hc7sGK/L4V0+oQw2RCCXPmSX+1/Iz/DMtZKYaeGPHLMMS3zQQsfvhfEJ2Vak03Cy
         NUhsfddvR+ORzZOe9284Dl8SDOrkU9aQ0L+7/CI7fYeIG6qB0mJH78WSbeSn1kWIjzAw
         TDpGmoVTBFRLyJWPjlOIehjdf4ifhMyWLsEGkezpFty/+oNfSddunduBMqPPWx6KFGej
         LJAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z17si4882pgf.267.2019.02.21.16.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 16:55:51 -0800 (PST)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 16:55:50 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="135401743"
Received: from orsmsx102.amr.corp.intel.com ([10.22.225.129])
  by FMSMGA003.fm.intel.com with ESMTP; 21 Feb 2019 16:55:50 -0800
Received: from orsmsx115.amr.corp.intel.com (10.22.240.11) by
 ORSMSX102.amr.corp.intel.com (10.22.225.129) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 21 Feb 2019 16:55:49 -0800
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.70]) by
 ORSMSX115.amr.corp.intel.com ([169.254.4.136]) with mapi id 14.03.0415.000;
 Thu, 21 Feb 2019 16:55:49 -0800
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
To: "rostedt@goodmis.org" <rostedt@goodmis.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "tglx@linutronix.de"
	<tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nadav.amit@gmail.com" <nadav.amit@gmail.com>, "dave.hansen@linux.intel.com"
	<dave.hansen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>,
	"linux-security-module@vger.kernel.org"
	<linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com"
	<hpa@zytor.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>, "linux_dti@icloud.com"
	<linux_dti@icloud.com>, "luto@kernel.org" <luto@kernel.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>, "bp@alien8.de" <bp@alien8.de>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v3 18/20] x86/ftrace: Use vmalloc special flag
Thread-Topic: [PATCH v3 18/20] x86/ftrace: Use vmalloc special flag
Thread-Index: AQHUykBbJ0x53lHatE6GL2AlMLdzQ6XreugAgAAJbQA=
Date: Fri, 22 Feb 2019 00:55:49 +0000
Message-ID: <3cd659eb8c7d43cf46bebc6562c1c26bb6c51b51.camel@intel.com>
References: <20190221234451.17632-1-rick.p.edgecombe@intel.com>
	 <20190221234451.17632-19-rick.p.edgecombe@intel.com>
	 <20190221192210.3e038fc3@gandalf.local.home>
In-Reply-To: <20190221192210.3e038fc3@gandalf.local.home>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.54.75.11]
Content-Type: text/plain; charset="utf-8"
Content-ID: <5A4A8CD00D4DF448B0BFB3995685F0A4@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTAyLTIxIGF0IDE5OjIyIC0wNTAwLCBTdGV2ZW4gUm9zdGVkdCB3cm90ZToN
Cj4gT24gVGh1LCAyMSBGZWIgMjAxOSAxNTo0NDo0OSAtMDgwMA0KPiBSaWNrIEVkZ2Vjb21iZSA8
cmljay5wLmVkZ2Vjb21iZUBpbnRlbC5jb20+IHdyb3RlOg0KPiANCj4gPiBVc2UgbmV3IGZsYWcg
Vk1fRkxVU0hfUkVTRVRfUEVSTVMgZm9yIGhhbmRsaW5nIGZyZWVpbmcgb2Ygc3BlY2lhbA0KPiA+
IHBlcm1pc3Npb25lZCBtZW1vcnkgaW4gdm1hbGxvYyBhbmQgcmVtb3ZlIHBsYWNlcyB3aGVyZSBt
ZW1vcnkgd2FzIHNldCBOWA0KPiA+IGFuZCBSVyBiZWZvcmUgZnJlZWluZyB3aGljaCBpcyBubyBs
b25nZXIgbmVlZGVkLg0KPiA+IA0KPiA+IENjOiBTdGV2ZW4gUm9zdGVkdCA8cm9zdGVkdEBnb29k
bWlzLm9yZz4NCj4gPiBBY2tlZC1ieTogU3RldmVuIFJvc3RlZHQgKFZNd2FyZSkgPHJvc3RlZHRA
Z29vZG1pcy5vcmc+DQo+ID4gU2lnbmVkLW9mZi1ieTogUmljayBFZGdlY29tYmUgPHJpY2sucC5l
ZGdlY29tYmVAaW50ZWwuY29tPg0KPiA+IC0tLQ0KPiA+ICBhcmNoL3g4Ni9rZXJuZWwvZnRyYWNl
LmMgfCA2ICsrLS0tLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCA0IGRl
bGV0aW9ucygtKQ0KPiA+IA0KPiA+IGRpZmYgLS1naXQgYS9hcmNoL3g4Ni9rZXJuZWwvZnRyYWNl
LmMgYi9hcmNoL3g4Ni9rZXJuZWwvZnRyYWNlLmMNCj4gPiBpbmRleCAxM2M4MjQ5YjE5N2YuLjkz
ZWZlMzk1NTMzMyAxMDA2NDQNCj4gPiAtLS0gYS9hcmNoL3g4Ni9rZXJuZWwvZnRyYWNlLmMNCj4g
PiArKysgYi9hcmNoL3g4Ni9rZXJuZWwvZnRyYWNlLmMNCj4gPiBAQCAtNjkyLDEwICs2OTIsNiBA
QCBzdGF0aWMgaW5saW5lIHZvaWQgKmFsbG9jX3RyYW1wKHVuc2lnbmVkIGxvbmcgc2l6ZSkNCj4g
PiAgfQ0KPiA+ICBzdGF0aWMgaW5saW5lIHZvaWQgdHJhbXBfZnJlZSh2b2lkICp0cmFtcCwgaW50
IHNpemUpDQo+IA0KPiBBcyBzaXplIGlzIG5vIGxvbmdlciB1c2VkIHdpdGhpbiB0aGUgZnVuY3Rp
b24sIGNhbiB5b3UgcmVtb3ZlIHRoYXQgdG9vLg0KPiANCj4gVGhhbmtzLA0KPiANCj4gLS0gU3Rl
dmUNCj4gDQpHb29kIHBvaW50LCBJJ2xsIHJlbW92ZSBpdC4NCg0KVGhhbmtzLA0KDQpSaWNrDQoN
CltzbmlwXQ0K

