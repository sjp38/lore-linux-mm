Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FF9CC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:45:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AF66217FA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:45:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AF66217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8653C6B000A; Thu, 25 Apr 2019 03:45:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 814536B000C; Thu, 25 Apr 2019 03:45:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 703EB6B000D; Thu, 25 Apr 2019 03:45:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 323C46B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:45:39 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2so13808357pge.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:45:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=VcYJhWkteZol9C+HkBh5q+JX3JaAd0oYNsMjpkx/n2Q=;
        b=rRXdy5ph18ogJWhY8uwJB2OzGuFbcc2W0jKRStdn3fXN/79gQzP/BXFhhB1cuLXm5T
         LaUyV4chCKi4/zhlnJGU8um9o6xTW+/pmwde3nbbAHlWF2/H858AjkCVFGOtqdHflHU2
         kMrPeNTw++6VxoCHrx8olCGAQ/iXtByl1b0Frcy3+IwTyBxVzRhmcy0O04bOjN90+Rm8
         PsS/pq2i9Rv6hMnXNzVI7AlVddanoYq98xT77XfPVBdlkL4nETOCBCuWMl3fSTjl2mhm
         hdSnhTpj4eZ30b8Tgr7nPsqa7yluvIJXp7RXx4ajecS0zQK9rRRMsbHljNYb3n0QZb6g
         0FtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXYby7EpHCZq1jLvvIWYRLGNYNIgG/fPLOEtDYkha+1qwOMNjZ7
	+lDAsCRhl7xjI2tBBj9vinhTNA5RPeTbstEr5wonFNBy0ommtuZfWSg5FGFanUOOJHxd82n3iFL
	tCNYAzXEhdjVkBdy/DZZvZRXsZr3M1g3LE2kH64Rwd7eLEnouvFZMSPiBCJU+qs1fUg==
X-Received: by 2002:aa7:8455:: with SMTP id r21mr6181033pfn.253.1556178338862;
        Thu, 25 Apr 2019 00:45:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyR3h3x06eap7ZqTflcwVdCholdW6Uvlb1c+YqQCKzk62s4BwfH/aR5+HSpYTUj24HkSf2/
X-Received: by 2002:aa7:8455:: with SMTP id r21mr6180960pfn.253.1556178338096;
        Thu, 25 Apr 2019 00:45:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556178338; cv=none;
        d=google.com; s=arc-20160816;
        b=aFDnXHt8dFsTewfs7iwnvKTNxWPzm23AEE+ECwVQa1q6Lzv1v4ejcjxJTLsTg5e5Vx
         fN20OaqY2sGdCIpoTzu3XS/6yHLnmRQxdtswT+8G22RkWnWeNfjodS5Qxz91G+G5fBOd
         4SHlRvCb23JxT4FRbVT7JpnLndya7l6r+KvaKMd9dqjYD4xUqYrBFzvBwliJV0MuJ1Qz
         wPL/V9yYfaqV06zP9r2W4wOapwL0Ho715SUxwabkY/XLFNbhfb0ClE7jiKI6ZtfdBm4o
         U+JSM+M2BfrBSdbfR0EhxvufIsf08fSrUK/eAAVMRGbq4y1tuj07oheJCdnimMXz62AJ
         nqwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=VcYJhWkteZol9C+HkBh5q+JX3JaAd0oYNsMjpkx/n2Q=;
        b=HMYf5yv0D5n4kEmQGmLm19ff880tKHNT33Y+FW+E5Fn0eIk8G994Mp1oXxFug8r8Xl
         He7AACLtcDTpWkZJZlXe8MXwTe6RF0jCjLbQL9FEYF1+HWuT1gnU64yc8SALhBNFvv2T
         g1d5Foi3tWTeAjlcrTJE9GHWjMjgDnHQLf7XbSaZucBSayVCcAbrciS2/OfA4+rWg5II
         y0nb9+smxxpQTROkmvrmcIRQC1r4sn793cHdcE5FpF35Isxhj3O1VxI265yICTemQBZQ
         BJZOG4I8mzUuVGZ040DfQt+LSOAVc1aRzoZb90qiIynzqMmlTIMtFOnzoE5ILXMKRtxj
         qYhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e5si20023032pgb.262.2019.04.25.00.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:45:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 00:45:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,393,1549958400"; 
   d="scan'208";a="138673834"
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by orsmga006.jf.intel.com with ESMTP; 25 Apr 2019 00:45:36 -0700
Received: from fmsmsx153.amr.corp.intel.com (10.18.125.6) by
 FMSMSX103.amr.corp.intel.com (10.18.124.201) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 00:45:36 -0700
Received: from shsmsx152.ccr.corp.intel.com (10.239.6.52) by
 FMSMSX153.amr.corp.intel.com (10.18.125.6) with Microsoft SMTP Server (TLS)
 id 14.3.408.0; Thu, 25 Apr 2019 00:45:36 -0700
Received: from shsmsx104.ccr.corp.intel.com ([169.254.5.92]) by
 SHSMSX152.ccr.corp.intel.com ([169.254.6.42]) with mapi id 14.03.0415.000;
 Thu, 25 Apr 2019 15:45:34 +0800
From: "Du, Fan" <fan.du@intel.com>
To: Xishi Qiu <qiuxishi@linux.alibaba.com>, "Wu, Fengguang"
	<fengguang.wu@intel.com>
CC: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko
	<mhocko@suse.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "Hansen,
 Dave" <dave.hansen@intel.com>, "Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, "Du, Fan" <fan.du@intel.com>
Subject: RE: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Thread-Topic: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Thread-Index: AQHU+wg4wWYFBheblUa8IPBSvnCJwqZMN0AXgABIHtA=
Date: Thu, 25 Apr 2019 07:45:34 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF067884825785F1E@SHSMSX104.ccr.corp.intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <a0728518-a067-4f89-a8ae-3fa279f768f2.xishi.qiuxishi@alibaba-inc.com>
 <2158298b-d4db-671e-6cff-395e9184ecf3@linux.alibaba.com>
In-Reply-To: <2158298b-d4db-671e-6cff-395e9184ecf3@linux.alibaba.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiZmQ4MDEyNDktZjY4Mi00MmVjLWEzZDgtYjBkOTJlMWQ1N2I1IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiaDhqZW9EVHZST0JKSXF6dXJFNXlSUTNsQ09zTWp2TkxWMmlSNXdMUVwvNU9lZ0pjaFArQnlVMUFDUFJlcm85cGsifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.239.127.40]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCj4tLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPkZyb206IG93bmVyLWxpbnV4LW1tQGt2
YWNrLm9yZyBbbWFpbHRvOm93bmVyLWxpbnV4LW1tQGt2YWNrLm9yZ10gT24NCj5CZWhhbGYgT2Yg
WGlzaGkgUWl1DQo+U2VudDogVGh1cnNkYXksIEFwcmlsIDI1LCAyMDE5IDExOjI2IEFNDQo+VG86
IFd1LCBGZW5nZ3VhbmcgPGZlbmdndWFuZy53dUBpbnRlbC5jb20+OyBEdSwgRmFuIDxmYW4uZHVA
aW50ZWwuY29tPg0KPkNjOiBha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnOyBNaWNoYWwgSG9ja28g
PG1ob2Nrb0BzdXNlLmNvbT47DQo+V2lsbGlhbXMsIERhbiBKIDxkYW4uai53aWxsaWFtc0BpbnRl
bC5jb20+OyBIYW5zZW4sIERhdmUNCj48ZGF2ZS5oYW5zZW5AaW50ZWwuY29tPjsgSHVhbmcsIFlp
bmcgPHlpbmcuaHVhbmdAaW50ZWwuY29tPjsNCj5saW51eC1tbUBrdmFjay5vcmc7IExpbnV4IEtl
cm5lbCBNYWlsaW5nIExpc3QgPGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc+DQo+U3ViamVj
dDogUmU6IFtSRkMgUEFUQ0ggNS81XSBtbSwgcGFnZV9hbGxvYzogSW50cm9kdWNlDQo+Wk9ORUxJ
U1RfRkFMTEJBQ0tfU0FNRV9UWVBFIGZhbGxiYWNrIGxpc3QNCj4NCj5IaSBGYW4gRHUsDQo+DQo+
SSB0aGluayB3ZSBzaG91bGQgY2hhbmdlIHRoZSBwcmludCBpbiBtbWluaXRfdmVyaWZ5X3pvbmVs
aXN0IHRvby4NCj4NCj5UaGlzIHBhdGNoIGNoYW5nZXMgdGhlIG9yZGVyIG9mIFpPTkVMSVNUX0ZB
TExCQUNLLCBzbyB0aGUgZGVmYXVsdCBudW1hDQo+cG9saWN5IGNhbg0KPmFsbG9jIERSQU0gZmly
c3QsIHRoZW4gUE1FTSwgcmlnaHQ/DQoNClllcywgeW91IGFyZSByaWdodC4gOikNCg0KPlRoYW5r
cywNCj5YaXNoaSBRaXUNCj4+DQo+T27CoHN5c3RlbcKgd2l0aMKgaGV0ZXJvZ2VuZW91c8KgbWVt
b3J5LMKgcmVhc29uYWJsZcKgZmFsbMKgYmFja8KgbGlzdHPCoHdvDQo+dWzCoGJlOg0KPj4gICAg
IGEuwqBOb8KgZmFsbMKgYmFjayzCoHN0aWNrwqB0b8KgY3VycmVudMKgcnVubmluZ8Kgbm9kZS4N
Cj4+DQo+Yi7CoEZhbGzCoGJhY2vCoHRvwqBvdGhlcsKgbm9kZXPCoG9mwqB0aGXCoHNhbWXCoHR5
cGXCoG9ywqBkaWZmZXJlbnTCoHR5cGUNCj4+ICAgICDCoMKgwqBlLmcuwqBEUkFNwqBub2RlwqAw
wqAtPsKgRFJBTcKgbm9kZcKgMcKgLT7CoFBNRU3CoG5vZGXCoDLCoC0+DQo+UE1FTcKgbm9kZcKg
Mw0KPj4gICAgIGMuwqBGYWxswqBiYWNrwqB0b8Kgb3RoZXLCoG5vZGVzwqBvZsKgdGhlwqBzYW1l
wqB0eXBlwqBvbmx5Lg0KPj4gICAgIMKgwqDCoGUuZy7CoERSQU3CoG5vZGXCoDDCoC0+wqBEUkFN
wqBub2RlwqAxDQo+Pg0KPj4NCj5hLsKgaXPCoGFscmVhZHnCoGluwqBwbGFjZSzCoHByZXZpb3Vz
wqBwYXRjaMKgaW1wbGVtZW50wqBiLsKgcHJvdmlkaW5nwqB3YXnCoHRvDQo+Pg0KPnNhdGlzZnnC
oG1lbW9yecKgcmVxdWVzdMKgYXPCoGJlc3TCoGVmZm9ydMKgYnnCoGRlZmF1bHQuwqBBbmTCoHRo
aXPCoHBhdGNowqBvZg0KPj4NCj53cml0aW5nwqBidWlsZMKgYy7CoHRvwqBmYWxsYmFja8KgdG/C
oHRoZcKgc2FtZcKgbm9kZcKgdHlwZcKgd2hlbsKgdXNlcsKgc3BlY2lmeQ0KPj4gICAgIEdGUF9T
QU1FX05PREVfVFlQRcKgb25seS4NCj4+DQo+PiAgICAgU2lnbmVkLW9mZi1ieTrCoEZhbsKgRHXC
oDxmYW4uZHVAaW50ZWwuY29tPg0KPj4gICAgIC0tLQ0KPj4gICAgIMKgaW5jbHVkZS9saW51eC9n
ZnAuaMKgwqDCoMKgfMKgwqA3wqArKysrKysrDQo+PiAgICAgwqBpbmNsdWRlL2xpbnV4L21tem9u
ZS5owqB8wqDCoDHCoCsNCj4+ICAgICDCoG1tL3BhZ2VfYWxsb2MuY8KgwqDCoMKgwqDCoMKgwqB8
wqAxNcKgKysrKysrKysrKysrKysrDQo+PiAgICAgwqAzwqBmaWxlc8KgY2hhbmdlZCzCoDIzwqBp
bnNlcnRpb25zKCspDQo+Pg0KPj4gICAgIGRpZmbCoC0tZ2l0wqBhL2luY2x1ZGUvbGludXgvZ2Zw
LmjCoGIvaW5jbHVkZS9saW51eC9nZnAuaA0KPj4gICAgIGluZGV4wqBmZGFiN2RlLi5jYTVmZGZj
wqAxMDA2NDQNCj4+ICAgICAtLS3CoGEvaW5jbHVkZS9saW51eC9nZnAuaA0KPj4gICAgICsrK8Kg
Yi9pbmNsdWRlL2xpbnV4L2dmcC5oDQo+PiAgICAgQEDCoC00NCw2wqArNDQsOMKgQEANCj4+ICAg
ICDCoCNlbHNlDQo+PiAgICAgwqAjZGVmaW5lwqBfX19HRlBfTk9MT0NLREVQwqAwDQo+PiAgICAg
wqAjZW5kaWYNCj4+ICAgICArI2RlZmluZcKgX19fR0ZQX1NBTUVfTk9ERV9UWVBFwqAweDEwMDAw
MDB1DQo+PiAgICAgKw0KPj4gICAgIMKgLyrCoElmwqB0aGXCoGFib3ZlwqBhcmXCoG1vZGlmaWVk
LMKgX19HRlBfQklUU19TSElGVMKgbWF5wqBuZWVkwqB1cA0KPmRhdGluZ8KgKi8NCj4+DQo+PiAg
ICAgwqAvKg0KPj4gICAgIEBAwqAtMjE1LDbCoCsyMTcsN8KgQEANCj4+DQo+PiAgICAgwqAvKsKg
RGlzYWJsZcKgbG9ja2RlcMKgZm9ywqBHRlDCoGNvbnRleHTCoHRyYWNraW5nwqAqLw0KPj4gICAg
IMKgI2RlZmluZcKgX19HRlBfTk9MT0NLREVQwqAoKF9fZm9yY2XCoGdmcF90KV9fX0dGUF9OT0xP
Q0tERVApDQo+Pg0KPisjZGVmaW5lwqBfX0dGUF9TQU1FX05PREVfVFlQRcKgKChfX2ZvcmNlwqBn
ZnBfdClfX19HRlBfU0FNRV9OT0RFX1QNCj5ZUEUpDQo+Pg0KPj4gICAgIMKgLyrCoFJvb23CoGZv
csKgTsKgX19HRlBfRk9PwqBiaXRzwqAqLw0KPj4gICAgIMKgI2RlZmluZcKgX19HRlBfQklUU19T
SElGVMKgKDIzwqArwqBJU19FTkFCTEVEKENPTkZJR19MT0NLREVQKSkNCj4+ICAgICBAQMKgLTMw
MSw2wqArMzA0LDjCoEBADQo+PiAgICAgwqDCoMKgwqDCoF9fR0ZQX05PTUVNQUxMT0PCoHzCoF9f
R0ZQX05PV0FSTinCoCbCoH5fX0dGUF9SRUNMQQ0KPklNKQ0KPj4gICAgIMKgI2RlZmluZcKgR0ZQ
X1RSQU5TSFVHRcKgKEdGUF9UUkFOU0hVR0VfTElHSFTCoHzCoF9fR0ZQX0RJUkUNCj5DVF9SRUNM
QUlNKQ0KPj4NCj4+ICAgICArI2RlZmluZcKgR0ZQX1NBTUVfTk9ERV9UWVBFwqAoX19HRlBfU0FN
RV9OT0RFX1RZUEUpDQo+PiAgICAgKw0KPj4gICAgIMKgLyrCoENvbnZlcnTCoEdGUMKgZmxhZ3PC
oHRvwqB0aGVpcsKgY29ycmVzcG9uZGluZ8KgbWlncmF0ZcKgdHlwZcKgKi8NCj4+ICAgICDCoCNk
ZWZpbmXCoEdGUF9NT1ZBQkxFX01BU0vCoChfX0dGUF9SRUNMQUlNQUJMRXxfX0dGUF9NT1ZBDQo+
QkxFKQ0KPj4gICAgIMKgI2RlZmluZcKgR0ZQX01PVkFCTEVfU0hJRlTCoDMNCj4+ICAgICBAQMKg
LTQzOCw2wqArNDQzLDjCoEBAwqBzdGF0aWPCoGlubGluZcKgaW50wqBnZnBfem9uZWxpc3QoZ2Zw
X3TCoGZsYWdzKQ0KPj4gICAgIMKgI2lmZGVmwqBDT05GSUdfTlVNQQ0KPj4gICAgIMKgwqBpZsKg
KHVubGlrZWx5KGZsYWdzwqAmwqBfX0dGUF9USElTTk9ERSkpDQo+PiAgICAgwqDCoMKgcmV0dXJu
wqBaT05FTElTVF9OT0ZBTExCQUNLOw0KPj4gICAgICvCoGlmwqAodW5saWtlbHkoZmxhZ3PCoCbC
oF9fR0ZQX1NBTUVfTk9ERV9UWVBFKSkNCj4+ICAgICArwqDCoHJldHVybsKgWk9ORUxJU1RfRkFM
TEJBQ0tfU0FNRV9UWVBFOw0KPj4gICAgIMKgI2VuZGlmDQo+PiAgICAgwqDCoHJldHVybsKgWk9O
RUxJU1RfRkFMTEJBQ0s7DQo+PiAgICAgwqB9DQo+PiAgICAgZGlmZsKgLS1naXTCoGEvaW5jbHVk
ZS9saW51eC9tbXpvbmUuaMKgYi9pbmNsdWRlL2xpbnV4L21tem9uZS5oDQo+PiAgICAgaW5kZXjC
oDhjMzdlMWMuLjJmODYwM2XCoDEwMDY0NA0KPj4gICAgIC0tLcKgYS9pbmNsdWRlL2xpbnV4L21t
em9uZS5oDQo+PiAgICAgKysrwqBiL2luY2x1ZGUvbGludXgvbW16b25lLmgNCj4+DQo+QEDCoC01
ODMsNsKgKzU4Myw3wqBAQMKgc3RhdGljwqBpbmxpbmXCoGJvb2zCoHpvbmVfaW50ZXJzZWN0cyhz
dHJ1Y3TCoHpvbmUNCj4qem9uZSwNCj4+DQo+PiAgICAgwqBlbnVtwqB7DQo+PiAgICAgwqDCoFpP
TkVMSVNUX0ZBTExCQUNLLMKgLyrCoHpvbmVsaXN0wqB3aXRowqBmYWxsYmFja8KgKi8NCj4+DQo+
K8KgWk9ORUxJU1RfRkFMTEJBQ0tfU0FNRV9UWVBFLMKgLyrCoHpvbmVsaXN0wqB3aXRowqBmYWxs
YmFja8KgdG/CoHRoZcKgc2FtDQo+ZcKgdHlwZcKgbm9kZcKgKi8NCj4+ICAgICDCoCNpZmRlZsKg
Q09ORklHX05VTUENCj4+ICAgICDCoMKgLyoNCj4+ICAgICDCoMKgwqAqwqBUaGXCoE5VTUHCoHpv
bmVsaXN0c8KgYXJlwqBkb3VibGVkwqBiZWNhdXNlwqB3ZcKgbmVlZMKgem9uZWwNCj5pc3RzwqB0
aGF0DQo+PiAgICAgZGlmZsKgLS1naXTCoGEvbW0vcGFnZV9hbGxvYy5jwqBiL21tL3BhZ2VfYWxs
b2MuYw0KPj4gICAgIGluZGV4wqBhNDA4YTkxLi5kZTc5NzkyMcKgMTAwNjQ0DQo+PiAgICAgLS0t
wqBhL21tL3BhZ2VfYWxsb2MuYw0KPj4gICAgICsrK8KgYi9tbS9wYWdlX2FsbG9jLmMNCj4+DQo+
QEDCoC01NDQ4LDbCoCs1NDQ4LDIxwqBAQMKgc3RhdGljwqB2b2lkwqBidWlsZF96b25lbGlzdHNf
aW5fbm9kZV9vcmRlcihwZw0KPl9kYXRhX3TCoCpwZ2RhdCzCoGludMKgKm5vZGVfb3JkZXIsDQo+
PiAgICAgwqDCoH0NCj4+ICAgICDCoMKgem9uZXJlZnMtPnpvbmXCoD3CoE5VTEw7DQo+PiAgICAg
wqDCoHpvbmVyZWZzLT56b25lX2lkeMKgPcKgMDsNCj4+ICAgICArDQo+Pg0KPivCoHpvbmVyZWZz
wqA9wqBwZ2RhdC0+bm9kZV96b25lbGlzdHNbWk9ORUxJU1RfRkFMTEJBQ0tfU0FNRV9UWVBFXS5f
em9uDQo+ZXJlZnM7DQo+PiAgICAgKw0KPj4gICAgICvCoGZvcsKgKGnCoD3CoDA7wqBpwqA8wqBu
cl9ub2RlczvCoGkrKynCoHsNCj4+ICAgICArwqDCoGludMKgbnJfem9uZXM7DQo+PiAgICAgKw0K
Pj4gICAgICvCoMKgcGdfZGF0YV90wqAqbm9kZcKgPcKgTk9ERV9EQVRBKG5vZGVfb3JkZXJbaV0p
Ow0KPj4gICAgICsNCj4+ICAgICArwqDCoGlmwqAoIWlzX25vZGVfc2FtZV90eXBlKG5vZGUtPm5v
ZGVfaWQswqBwZ2RhdC0+bm9kZV9pZCkpDQo+PiAgICAgK8KgwqDCoGNvbnRpbnVlOw0KPj4gICAg
ICvCoMKgbnJfem9uZXPCoD3CoGJ1aWxkX3pvbmVyZWZzX25vZGUobm9kZSzCoHpvbmVyZWZzKTsN
Cj4+ICAgICArwqDCoHpvbmVyZWZzwqArPcKgbnJfem9uZXM7DQo+PiAgICAgK8KgfQ0KPj4gICAg
ICvCoHpvbmVyZWZzLT56b25lwqA9wqBOVUxMOw0KPj4gICAgICvCoHpvbmVyZWZzLT56b25lX2lk
eMKgPcKgMDsNCj4+ICAgICDCoH0NCj4+DQo+PiAgICAgwqAvKg0KPj4gICAgIC0tDQo+PiAgICAg
MS44LjMuMQ0KPj4NCj4+DQoNCg==

