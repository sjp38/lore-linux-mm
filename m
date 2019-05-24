Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BCBEC282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 20:08:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F7142133D
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 20:08:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F7142133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D4726B0008; Fri, 24 May 2019 16:08:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85ED06B000A; Fri, 24 May 2019 16:08:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D8086B000C; Fri, 24 May 2019 16:08:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32CB76B0008
	for <linux-mm@kvack.org>; Fri, 24 May 2019 16:08:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id k22so7729166pfg.18
        for <linux-mm@kvack.org>; Fri, 24 May 2019 13:08:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=Y7mQaRfoF7ixlk7NLLzSYIdcLw3Cr3TrbfyB6qGloDk=;
        b=S+Ws8KEmSQQcFbB00koEPTAb38NWV5a3RKlFdLnkoNZh8oyu55TZF74rvso0IkCMRD
         OUZvS9dXxiQBc38+2H/cTjZrMvgynJooc7we3tjPp2G/fgGllQMgwjo58v2qANXHMKEG
         0urVd+aPfL4cTDBSDpzE2AblkI+Cj69F7dQdSkerbKAG1YFYyErwb5w0KAf4SyjVZJZ/
         Ggto4Ke1Hjiw1gASKjq65+yTXDpzZyRcwnTT93plb9HhGqNGRBZtcmeBU92RAnHtsihs
         32Pusfg5biSrXvmwypIqntf2EbMEmhyKkvvfmLlXFmNTeRmYqFTcTc+OcDT8Yx/SoijL
         3Daw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWzBfeezz4/SvXvD7PhMbXhYeth7YI+RWbI8+kOyBYpgozA+PcY
	ivTXJ7P3THJage1AK114viV0TgtR0JmrOlLOz4DAyhSu0FJrw87Aj+o0BW+58U/izZ2jWofp23f
	ijT5W2vZnoOkItggjS5LlQ5YFIP0qec4IdpWdvEf7yaLbpuRaRa8RM+uDjsqv1sB86Q==
X-Received: by 2002:aa7:90d3:: with SMTP id k19mr113084139pfk.1.1558728526739;
        Fri, 24 May 2019 13:08:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKoND6viRMfXMEQcd5f4vb/DqIXlLLZwQoe+Dt6gl0uY65Zp//iokST2bj9JgW9Eo0uENn
X-Received: by 2002:aa7:90d3:: with SMTP id k19mr113084065pfk.1.1558728526010;
        Fri, 24 May 2019 13:08:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558728526; cv=none;
        d=google.com; s=arc-20160816;
        b=WdUKLGoPBnNx0dZVEZ83xkSCQQ/9TPtKcgnU43h2hbU8UH/mWTBrCrGizXx6JepQpO
         bcvm5rqAj0Y2Byy6BcxRH0pmGQ4b7djPexssEtbLzEn585xl2+CBz88HNSGfP7wNp4st
         yxmHZCKkKk+e5pcoqKkHxqpZ9JWiqW1R420jC0vpnySfUIGqs1mRjV+gaq+dQIsQGUl3
         I3mlt9hP0KCb5DluuNV4fOBGN2OKgFxToW9A/uPwAHbY7Dw0soM89AhCLlIvjZVR62LO
         tYJNMmV5uZdk4nddLL7wjiVGgXZ8zhW5fZrrtwDkMoGwNxwxw0Edsk4K3UPs6Cfhwgwy
         4VPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=Y7mQaRfoF7ixlk7NLLzSYIdcLw3Cr3TrbfyB6qGloDk=;
        b=fF1tyHsfw9PSNEWvLWmU/fA20QZUQfZjEYrosTJCcwcIuamh3FIH4MWkWyrGu8DOL4
         Lp3tsRHqNTgQFSHFGN+n/Pw9wD+NZB5oosP3m5h8S7rhwn2BsYIZaj1UpgbFcYM+Rt6+
         4sE/NAj6gEGvyh5vc8vj6L9b+S/xLk5ya0066k+zkki3jkbJXSxmjX24H8UlSnkAnrR3
         7cHniMVb0SgXZlWmOA1Gnv56/BpsthP8y9QHCcDkNKkBnk5H5McfVQFslLwNEDZ80SLk
         Gqxy8ti1YHBJXLUo+UaVeGELFuPr9emWpeXElmd3lo6VAkaZWRYFl9vp5c9+egBEsbIi
         p9Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x13si1860846pgi.165.2019.05.24.13.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 13:08:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 May 2019 13:08:45 -0700
X-ExtLoop1: 1
Received: from fmsmsx105.amr.corp.intel.com ([10.18.124.203])
  by fmsmga006.fm.intel.com with ESMTP; 24 May 2019 13:08:44 -0700
Received: from fmsmsx112.amr.corp.intel.com (10.18.116.6) by
 FMSMSX105.amr.corp.intel.com (10.18.124.203) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Fri, 24 May 2019 13:08:44 -0700
Received: from crsmsx104.amr.corp.intel.com (172.18.63.32) by
 FMSMSX112.amr.corp.intel.com (10.18.116.6) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Fri, 24 May 2019 13:08:44 -0700
Received: from crsmsx101.amr.corp.intel.com ([169.254.1.116]) by
 CRSMSX104.amr.corp.intel.com ([169.254.6.192]) with mapi id 14.03.0415.000;
 Fri, 24 May 2019 14:08:42 -0600
From: "Weiny, Ira" <ira.weiny@intel.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka
	<vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox
	<willy@infradead.org>, Linux MM <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>
Subject: RE: [PATCH RFC] mm/swap: make release_pages() and put_pages() match
Thread-Topic: [PATCH RFC] mm/swap: make release_pages() and put_pages() match
Thread-Index: AQHVEmeV6lwaEiR3+E6UJvvneFDW0qZ7EgQA//+iDIA=
Date: Fri, 24 May 2019 20:08:42 +0000
Message-ID: <2807E5FD2F6FDA4886F6618EAC48510E79D3ACC3@CRSMSX101.amr.corp.intel.com>
References: <20190524193415.9733-1-ira.weiny@intel.com>
 <CALvZod6skK6NxeRXjKS64+1jpF9NwbLp7DhpWueB0F6Tj4MNUw@mail.gmail.com>
In-Reply-To: <CALvZod6skK6NxeRXjKS64+1jpF9NwbLp7DhpWueB0F6Tj4MNUw@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiMDJlYzY3Y2ItYjdlMC00NDc0LThlN2EtNDZmODQxOTFlNTUyIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiWGhaUUYxZ29XQW9TaXRNU2VBVHFcL0tkRWJrdDN3OFlUcFJyNFNKRmJmYWVubmZvVkdDTzFDRWU3VmtFcDc3b3kifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [172.18.205.10]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiANCj4gT24gRnJpLCBNYXkgMjQsIDIwMTkgYXQgMTI6MzMgUE0gPGlyYS53ZWlueUBpbnRlbC5j
b20+IHdyb3RlOg0KPiA+DQo+ID4gRnJvbTogSXJhIFdlaW55IDxpcmEud2VpbnlAaW50ZWwuY29t
Pg0KPiA+DQo+ID4gUkZDIEkgaGF2ZSBubyBpZGVhIGlmIHRoaXMgaXMgY29ycmVjdCBvciBub3Qu
ICBCdXQgbG9va2luZyBhdA0KPiA+IHJlbGVhc2VfcGFnZXMoKSBJIHNlZSBhIGNhbGwgdG8gYm90
aCBfX0NsZWFyUGFnZUFjdGl2ZSgpIGFuZA0KPiA+IF9fQ2xlYXJQYWdlV2FpdGVycygpIHdoaWxl
IGluIF9fcGFnZV9jYWNoZV9yZWxlYXNlKCkgSSBkbyBub3QuDQo+ID4NCj4gPiBJcyB0aGlzIGEg
YnVnIHdoaWNoIG5lZWRzIHRvIGJlIGZpeGVkPyAgRGlkIEkgbWlzcyBjbGVhcmluZyBhY3RpdmUN
Cj4gPiBzb21ld2hlcmUgZWxzZSBpbiB0aGUgY2FsbCBjaGFpbiBvZiBwdXRfcGFnZT8NCj4gPg0K
PiA+IFRoaXMgd2FzIGZvdW5kIHZpYSBjb2RlIGluc3BlY3Rpb24gd2hpbGUgZGV0ZXJtaW5pbmcg
aWYNCj4gPiByZWxlYXNlX3BhZ2VzKCkgYW5kIHRoZSBuZXcgcHV0X3VzZXJfcGFnZXMoKSBjb3Vs
ZCBiZSBpbnRlcmNoYW5nZWFibGUuDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBJcmEgV2Vpbnkg
PGlyYS53ZWlueUBpbnRlbC5jb20+DQo+ID4gLS0tDQo+ID4gIG1tL3N3YXAuYyB8IDEgKw0KPiA+
ICAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKykNCj4gPg0KPiA+IGRpZmYgLS1naXQgYS9t
bS9zd2FwLmMgYi9tbS9zd2FwLmMNCj4gPiBpbmRleCAzYTc1NzIyZTY4YTkuLjlkMDQzMmJhZGRi
MCAxMDA2NDQNCj4gPiAtLS0gYS9tbS9zd2FwLmMNCj4gPiArKysgYi9tbS9zd2FwLmMNCj4gPiBA
QCAtNjksNiArNjksNyBAQCBzdGF0aWMgdm9pZCBfX3BhZ2VfY2FjaGVfcmVsZWFzZShzdHJ1Y3Qg
cGFnZSAqcGFnZSkNCj4gPiAgICAgICAgICAgICAgICAgZGVsX3BhZ2VfZnJvbV9scnVfbGlzdChw
YWdlLCBscnV2ZWMsDQo+ID4gcGFnZV9vZmZfbHJ1KHBhZ2UpKTsNCj4gDQo+IHNlZSBwYWdlX29m
Zl9scnUocGFnZSkgYWJvdmUgd2hpY2ggY2xlYXIgYWN0aXZlIGJpdC4NCg0KVGhhbmtzLCAgU29y
cnkgZm9yIHRoZSBub2lzZSwNCklyYQ0KDQoNCj4gDQo+ID4gICAgICAgICAgICAgICAgIHNwaW5f
dW5sb2NrX2lycXJlc3RvcmUoJnBnZGF0LT5scnVfbG9jaywgZmxhZ3MpOw0KPiA+ICAgICAgICAg
fQ0KPiA+ICsgICAgICAgX19DbGVhclBhZ2VBY3RpdmUocGFnZSk7DQo+ID4gICAgICAgICBfX0Ns
ZWFyUGFnZVdhaXRlcnMocGFnZSk7DQo+ID4gICAgICAgICBtZW1fY2dyb3VwX3VuY2hhcmdlKHBh
Z2UpOw0KPiA+ICB9DQo+ID4gLS0NCj4gPiAyLjIwLjENCj4gPg0K

