Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91BE8C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:19:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B436B2077C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:19:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B436B2077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E98176B0003; Thu, 25 Apr 2019 15:19:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E484C6B0005; Thu, 25 Apr 2019 15:19:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D367B6B000A; Thu, 25 Apr 2019 15:19:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBBA6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:19:17 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a17so365972plm.5
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:19:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=fy87ulryHMdmydci7ol/E7XLf7+K9X8Z79SvdCHMjQ0=;
        b=c0YMe9oh0ZNdd9i7zb2binC4yg1tRvpeayXWs4/z6WDph8JUxX+pjPgsFt91M47l1H
         DMvaXbU2Fcs2cm/g5aeqmhmuwtaVGls2aYDIdYpopeeLZMe1X+YJeRu1NVGKLw1zs7nY
         XgxUnvDAbXL3NG/OJTGQ+KSyr6ywhsPBKR2jpYAcT25GVPpQJTuyYe2nA4fcIp9RmOwC
         P5Q3Jb9fTCE1hXv7/BDaWgmQHhnrjq+x6OkktTLp/oZitVwI1PdqWIxqNDqLucf2A18O
         oVSjU63IUUH2zEdGaE3hm78zeXPkhHnZWFPmLqGEqv6fiPipXYdtkoyGP5onuxd4KXsG
         KpOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUooWRx6bENOuFvjdSt6OwJ1wTpEI3b7plQFlTtzKvijCru0oOs
	t12lqrAEiwY8q7kAWgp/oz4VD4+BF24mimTuwy5+GhHM354Bknal3qpGpw3G1JaQrmWV56+fqhO
	a91M4ANXSSxmmJm9WjpL1t0jipZacoTcutSMV3XIVGbqUCWH/sjHzm9bIMqksnLUtuw==
X-Received: by 2002:a17:902:e709:: with SMTP id co9mr23805971plb.86.1556219957316;
        Thu, 25 Apr 2019 12:19:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA78EfT10RLa5TKkWzxeBVyQVjOncbpJQNdp3eF4VZhxYDwhakOT7WFH1lfHuxvaDvYA+3
X-Received: by 2002:a17:902:e709:: with SMTP id co9mr23805909plb.86.1556219956562;
        Thu, 25 Apr 2019 12:19:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556219956; cv=none;
        d=google.com; s=arc-20160816;
        b=TwUdQ45Xb9KuAW+98WcKBIdQj/UTSPFNPc4ecYRHT+ZxKi1akROKDwxoktbnQJ6CXw
         ciiUxo2V9d9YBFHk1BIZQoQKl0LyX/BOkwFxhYSjGCyxxnhZyMe3xe4uJEw6j9LtEBz+
         ep/Bz6qXkUQwDdBJgl8XGBAKwbquxM1SP1Ew4zT0z2O3Qq2FzNToz0YiWRY4GByitKy5
         b9pvmzBCne7Q40aloli8j5MJmicbOrZmc4u1SdlyfYtFdjVnH3W3FYNtCChjZROACyij
         0wWn3XqGgn++rKisdg4pmkmiBPHzv+FG8ffeAG/uKpCXoPS+81PVX0A5fU6dGB9cNWQR
         ePkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=fy87ulryHMdmydci7ol/E7XLf7+K9X8Z79SvdCHMjQ0=;
        b=WIbTYNWBeHJ1AIU8IPy2sjfPsIY7AIFbk9c5+MotQMPRSEQ9qbeyUY9z3VZ3FcS/jE
         O+LwWb/njeJcSw3ABqbETPVqzlmyi13nXLvoNHtvbhaLDYguoxxJ3YC7aR/VFFTHIJTd
         DEdw2lvtfXpzoUe8F2RtXZ3rmj8tf2NXNG3eS82Jj14jUQeC1ScOg4moMDqFlSyTyUez
         p5YGFyTgrxh0S3/TZ0QQGtInhbYpcF0wyyGTfRZRJV9KqvN9SAAH0+Cg0ssy70PZZ3PR
         9oEwrdQQd2nj3t444YEycZJ6IsL0eL6gf4U6MBn8qOpsqiFN5+P9ix16XbhkRhcPp9X9
         X5Vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b74si23250700pfj.121.2019.04.25.12.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 12:19:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 12:19:15 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,394,1549958400"; 
   d="scan'208";a="226718970"
Received: from orsmsx101.amr.corp.intel.com ([10.22.225.128])
  by orsmga001.jf.intel.com with ESMTP; 25 Apr 2019 12:19:15 -0700
Received: from orsmsx112.amr.corp.intel.com ([169.254.3.109]) by
 ORSMSX101.amr.corp.intel.com ([169.254.8.212]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 12:19:15 -0700
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
Subject: Re: [PATCH v4 19/23] x86/ftrace: Use vmalloc special flag
Thread-Topic: [PATCH v4 19/23] x86/ftrace: Use vmalloc special flag
Thread-Index: AQHU+T1q49bvmRxIpk2PRaAn55zB0aZNrBqAgAAONIA=
Date: Thu, 25 Apr 2019 19:19:14 +0000
Message-ID: <e07ed452377e9c48fc50c08fc80b6893d2b26ead.camel@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
	 <20190422185805.1169-20-rick.p.edgecombe@intel.com>
	 <20190425142803.4f2e354a@gandalf.local.home>
In-Reply-To: <20190425142803.4f2e354a@gandalf.local.home>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.54.75.11]
Content-Type: text/plain; charset="utf-8"
Content-ID: <B35D9A494A9B654C884ED7C35585F23C@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTA0LTI1IGF0IDE0OjI4IC0wNDAwLCBTdGV2ZW4gUm9zdGVkdCB3cm90ZToN
Cj4gT24gTW9uLCAyMiBBcHIgMjAxOSAxMTo1ODowMSAtMDcwMA0KPiBSaWNrIEVkZ2Vjb21iZSA8
cmljay5wLmVkZ2Vjb21iZUBpbnRlbC5jb20+IHdyb3RlOg0KPiANCj4gPiBVc2UgbmV3IGZsYWcg
Vk1fRkxVU0hfUkVTRVRfUEVSTVMgZm9yIGhhbmRsaW5nIGZyZWVpbmcgb2Ygc3BlY2lhbA0KPiA+
IHBlcm1pc3Npb25lZCBtZW1vcnkgaW4gdm1hbGxvYyBhbmQgcmVtb3ZlIHBsYWNlcyB3aGVyZSBt
ZW1vcnkgd2FzIHNldCBOWA0KPiA+IGFuZCBSVyBiZWZvcmUgZnJlZWluZyB3aGljaCBpcyBubyBs
b25nZXIgbmVlZGVkLg0KPiA+IA0KPiA+IENjOiBTdGV2ZW4gUm9zdGVkdCA8cm9zdGVkdEBnb29k
bWlzLm9yZz4NCj4gPiBBY2tlZC1ieTogU3RldmVuIFJvc3RlZHQgKFZNd2FyZSkgPHJvc3RlZHRA
Z29vZG1pcy5vcmc+DQo+ID4gU2lnbmVkLW9mZi1ieTogUmljayBFZGdlY29tYmUgPHJpY2sucC5l
ZGdlY29tYmVAaW50ZWwuY29tPg0KPiANCj4gVGVzdGVkLWJ5OiBTdGV2ZW4gUm9zdGVkdCAoVk13
YXJlKSA8cm9zdGVkdEBnb29kbWlzLm9yZz4NCj4gQWNrZWQtYnk6IFN0ZXZlbiBSb3N0ZWR0IChW
TXdhcmUpIDxyb3N0ZWR0QGdvZG9taXMub3JnPg0KPiANCj4gLS0gU3RldmUNCg0KVGhhbmtzIQ0K
DQpSaWNrDQo=

