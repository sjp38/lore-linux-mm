Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4CB0C41517
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 00:00:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9FD921897
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 00:00:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9FD921897
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E0D96B0008; Tue, 23 Jul 2019 20:00:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5910B6B000A; Tue, 23 Jul 2019 20:00:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45A6D8E0002; Tue, 23 Jul 2019 20:00:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 107236B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 20:00:00 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so27284076pfv.18
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 17:00:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=PdfiAx8eJdLLndyXPWuqCFruDsSZdhaMQS+bKr9Tf4I=;
        b=B0SbK4D0cGhYpYGvKfUeLyDPmzo+77mf2gKFkmvZ3T8x9h77NUogPJZslKA/wv2Kal
         Pfx4cj0pPHTTlV85rBXApgp+VcSwW7VyyQiN8QIspXg1THHZQW95STGOQTOG8+1QpMgi
         pttFDbO01WAUe0icYu0K/g66U5RJNSxLlIGP+ga6+LV+uHHOsIvGgIEeinO2/tj9WkNS
         mYx9yDCxtTmtCiwzZcP53n8wODZ5VEARJ6752tfXMHXLxCITNJyFM1VtWcLkvA398BUn
         RpC8XITZEtW7DDsIF7DTBMD2xeTSyD36s9z2tsGc7YzXX3OKGWkLyiZ5WmQeWZ4IZDR1
         S8iA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of kai.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kai.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWzAiBCe4lf0XDTxcEPc5o3VVLUbp6s1XwgAdq7lMohdCgI3pRK
	mg6N9FjxIvtVHlHiANY6D28sSw8vIopeimHSfT3j3ZnTMbmqjgX871dLtZAT/1b+acmADxJJYyc
	/dIDWCnaAO+ODQsfxYrPPLy8+I8+Wh66w1F+ZwEF6sq6LIYS9HDmjOrUKn9rBx2dMyg==
X-Received: by 2002:a63:2744:: with SMTP id n65mr65609911pgn.277.1563926399513;
        Tue, 23 Jul 2019 16:59:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4FMDq2jkMgrZSZ3eCJG/8z6P/XI0l65eH+3X2CbsFRliWtfcOXAFxvSRDYDMGXVJ2WG78
X-Received: by 2002:a63:2744:: with SMTP id n65mr65609875pgn.277.1563926398784;
        Tue, 23 Jul 2019 16:59:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563926398; cv=none;
        d=google.com; s=arc-20160816;
        b=CRD/yFcSwNv/WdoKbcmEh3H2MyvXFFC5UDOtI11VZBo5PPsEiFGtw+EqN92QGiEuzv
         oRMkn17qB6HsNWyKoTXmHqmoAlMulrHxULAaATN4WUVc4ZU6C5YSyNCHMh6K4qkn4Z1Y
         PSursrysclvdUESeeIuYVXcwqL92Lcy6eLHCjewBQpkRU5ngbZnmNPVbOxgC7+W7DHh+
         JHG6u36SQl9DVF264QCbdR5O33XjpwHhq5DQ7c76uTdlqYinBCImNv9oC53SelCSUquH
         ji99O2GB+fZ0jOPLb0sXwPqwr/151MDkv6h91FPvRDslSgr2Pwq55cuzsuSx5O4jrhMO
         68EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=PdfiAx8eJdLLndyXPWuqCFruDsSZdhaMQS+bKr9Tf4I=;
        b=vzUOpM7onCpzrZZhlPp3f7NOXlbqRP7S4T2sQ7u+4d0/9Sj9Q5TI+OMd+3uu8VgjaI
         TXFajembIGetJTSDs2Pte6QydxYw+rZW0K6SH7jsrlOZR9mNtBWKpPH8k7AgF1ZE1VhP
         HAEVozOzfONeayLuEYT5EcZY6Smw88DhRix7PxylXDm71iIIyznL8WwAlkYoxmfAwjWQ
         W765S5+N5Dds3uDYnhpr4NdoMfeQAb9DcZP2B5qpUZ8K3mbL/oVdvsq+qXfEgAOfb24u
         6tnHt9aL7IE9K/cX6Mv8R8tY36y0b+rinx830DHRYjt6O0a5I5TzLOwSjhLgRXk4V0kY
         7CCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of kai.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kai.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x3si10778322plv.26.2019.07.23.16.59.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 16:59:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of kai.huang@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of kai.huang@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=kai.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jul 2019 16:59:58 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,300,1559545200"; 
   d="scan'208";a="369081710"
Received: from pgsmsx104.gar.corp.intel.com ([10.221.44.91])
  by fmsmga006.fm.intel.com with ESMTP; 23 Jul 2019 16:59:55 -0700
Received: from pgsmsx112.gar.corp.intel.com ([169.254.3.46]) by
 PGSMSX104.gar.corp.intel.com ([169.254.3.64]) with mapi id 14.03.0439.000;
 Wed, 24 Jul 2019 07:59:54 +0800
From: "Huang, Kai" <kai.huang@intel.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "songliubraving@fb.com"
	<songliubraving@fb.com>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>
CC: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>, "hdanton@sina.com"
	<hdanton@sina.com>, "kernel-team@fb.com" <kernel-team@fb.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>
Subject: Re: [PATCH v9 5/6] mm,thp: add read-only THP support for
 (non-shmem) FS
Thread-Topic: [PATCH v9 5/6] mm,thp: add read-only THP support for
 (non-shmem) FS
Thread-Index: AQHVKurXe0zlPpLJvUiiyeP9CKzbqKbYiXyA
Date: Tue, 23 Jul 2019 23:59:54 +0000
Message-ID: <1563926391.8456.1.camel@intel.com>
References: <20190625001246.685563-1-songliubraving@fb.com>
	 <20190625001246.685563-6-songliubraving@fb.com>
In-Reply-To: <20190625001246.685563-6-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.254.182.119]
Content-Type: text/plain; charset="utf-8"
Content-ID: <90FB8C841C327D44B3083EA689DE73AE@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gTW9uLCAyMDE5LTA2LTI0IGF0IDE3OjEyIC0wNzAwLCBTb25nIExpdSB3cm90ZToNCj4gVGhp
cyBwYXRjaCBpcyAoaG9wZWZ1bGx5KSB0aGUgZmlyc3Qgc3RlcCB0byBlbmFibGUgVEhQIGZvciBu
b24tc2htZW0NCj4gZmlsZXN5c3RlbXMuDQo+IA0KPiBUaGlzIHBhdGNoIGVuYWJsZXMgYW4gYXBw
bGljYXRpb24gdG8gcHV0IHBhcnQgb2YgaXRzIHRleHQgc2VjdGlvbnMgdG8gVEhQDQo+IHZpYSBt
YWR2aXNlLCBmb3IgZXhhbXBsZToNCj4gDQo+ICAgICBtYWR2aXNlKCh2b2lkICopMHg2MDAwMDAs
IDB4MjAwMDAwLCBNQURWX0hVR0VQQUdFKTsNCj4gDQo+IFdlIHRyaWVkIHRvIHJldXNlIHRoZSBs
b2dpYyBmb3IgVEhQIG9uIHRtcGZzLg0KPiANCj4gQ3VycmVudGx5LCB3cml0ZSBpcyBub3Qgc3Vw
cG9ydGVkIGZvciBub24tc2htZW0gVEhQLiBraHVnZXBhZ2VkIHdpbGwgb25seQ0KPiBwcm9jZXNz
IHZtYSB3aXRoIFZNX0RFTllXUklURS4gc3lzX21tYXAoKSBpZ25vcmVzIFZNX0RFTllXUklURSBy
ZXF1ZXN0cw0KPiAoc2VlIGtzeXNfbW1hcF9wZ29mZikuIFRoZSBvbmx5IHdheSB0byBjcmVhdGUg
dm1hIHdpdGggVk1fREVOWVdSSVRFIGlzDQo+IGV4ZWN2ZSgpLiBUaGlzIHJlcXVpcmVtZW50IGxp
bWl0cyBub24tc2htZW0gVEhQIHRvIHRleHQgc2VjdGlvbnMuDQo+IA0KPiBUaGUgbmV4dCBwYXRj
aCB3aWxsIGhhbmRsZSB3cml0ZXMsIHdoaWNoIHdvdWxkIG9ubHkgaGFwcGVuIHdoZW4gdGhlIGFs
bA0KPiB0aGUgdm1hcyB3aXRoIFZNX0RFTllXUklURSBhcmUgdW5tYXBwZWQuDQo+IA0KPiBBbiBF
WFBFUklNRU5UQUwgY29uZmlnLCBSRUFEX09OTFlfVEhQX0ZPUl9GUywgaXMgYWRkZWQgdG8gZ2F0
ZSB0aGlzDQo+IGZlYXR1cmUuDQo+IA0KPiBBY2tlZC1ieTogUmlrIHZhbiBSaWVsIDxyaWVsQHN1
cnJpZWwuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBTb25nIExpdSA8c29uZ2xpdWJyYXZpbmdAZmIu
Y29tPg0KPiAtLS0NCj4gIG1tL0tjb25maWcgICAgICB8IDExICsrKysrKw0KPiAgbW0vZmlsZW1h
cC5jICAgIHwgIDQgKy0tDQo+ICBtbS9raHVnZXBhZ2VkLmMgfCA5NCArKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKy0tLS0tLS0tDQo+ICBtbS9ybWFwLmMgICAgICAgfCAx
MiArKysrLS0tDQo+ICA0IGZpbGVzIGNoYW5nZWQsIDEwMCBpbnNlcnRpb25zKCspLCAyMSBkZWxl
dGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9tbS9LY29uZmlnIGIvbW0vS2NvbmZpZw0KPiBp
bmRleCBmMGM3NmJhNDc2OTUuLjBhOGZkNTg5NDA2ZCAxMDA2NDQNCj4gLS0tIGEvbW0vS2NvbmZp
Zw0KPiArKysgYi9tbS9LY29uZmlnDQo+IEBAIC03NjIsNiArNzYyLDE3IEBAIGNvbmZpZyBHVVBf
QkVOQ0hNQVJLDQo+ICANCj4gIAkgIFNlZSB0b29scy90ZXN0aW5nL3NlbGZ0ZXN0cy92bS9ndXBf
YmVuY2htYXJrLmMNCj4gIA0KPiArY29uZmlnIFJFQURfT05MWV9USFBfRk9SX0ZTDQo+ICsJYm9v
bCAiUmVhZC1vbmx5IFRIUCBmb3IgZmlsZXN5c3RlbXMgKEVYUEVSSU1FTlRBTCkiDQo+ICsJZGVw
ZW5kcyBvbiBUUkFOU1BBUkVOVF9IVUdFX1BBR0VDQUNIRSAmJiBTSE1FTQ0KDQpIaSwNCg0KTWF5
YmUgYSBzdHVwaWQgcXVlc3Rpb24gc2luY2UgSSBhbSBuZXcsIGJ1dCB3aHkgZG9lcyBpdCBkZXBl
bmQgb24gU0hNRU0/DQoNClRoYW5rcywNCi1LYWk=

