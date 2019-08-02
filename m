Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49C6CC32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 06:52:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 082442086A
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 06:52:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 082442086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94C976B0003; Fri,  2 Aug 2019 02:52:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FC0A6B0005; Fri,  2 Aug 2019 02:52:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EBE06B0006; Fri,  2 Aug 2019 02:52:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 44F1F6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 02:52:13 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id e95so41082924plb.9
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 23:52:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=a8n8TK7ZbNzHz/JQgi50vPSbInbioYYXQG4XpTwbReA=;
        b=ffVBvS1x2jnKQtaHZFP84lSyECP7YQbp+EdhGpYragAkEND2gXpiQThsPUKjjuXvX1
         FsZ4CckQ1adIAKvTyn4WBD2C38x+DiQ+McctlAwKqXYnpaIVC0OpcmX42vn7fD/ARTR5
         ulI7M1s5QFIoQTiPU3SCVBaLxRb35UP4E7A9Y33GwrYYJvCMuJVLfHwJxpJLg1NGAwvy
         KxgqAGyfZLZZDAgeAebOy9+efzZVlslypxS5O1PL5QecIHPhGsZPD60tEQBFlL9Fv6+V
         xzuEuKORwEVzYEhEfpFkUHbmQH5Jce0GZ7YaKy4foKA9inqABz63N7vYPHtKZ8C/aVn8
         VcMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVglMNSS4oKLoynteaBWfd09DhuiR/w34DNZawIZF7QdNJl3RH+
	Fkh22C1CURt6uBJXOcJoTzY3oQsgJ3+D5USPQDchyNF7smCb+VrNC8iGUsmtSOQEeKZ4wVLCEjW
	C8H0/26U8XDvFy6wBUpT4LcGyIbqdTfX7abEbySDtNW1XwhmM7wWPFYkYIheCOVd4cQ==
X-Received: by 2002:a17:902:29e6:: with SMTP id h93mr70629853plb.297.1564728732923;
        Thu, 01 Aug 2019 23:52:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPY3xKO9FJpgzqqFSydvduiu31B0cykqFFdAvS/Ynd4FY3Fu2SVY0Uyic0MB6xkOauf16n
X-Received: by 2002:a17:902:29e6:: with SMTP id h93mr70629819plb.297.1564728732196;
        Thu, 01 Aug 2019 23:52:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564728732; cv=none;
        d=google.com; s=arc-20160816;
        b=cS0luOFTvzhV25etidUpH6oS8BjcMjoNRiANYzoO6pv9IfCKSJbil+Q3bauM9K2zEE
         fIEHymkmSekCOZZMgfdZCnyVPuHyg2BQFsvLI1AjbTw3c9WE2SUwDG5CzXRh0XAyBPRc
         pjWZNO4c1C1Ze9ZQgqjvatCLsUiOJ+fIAD6dhAK9ov71swT9YtD1w+c0ZP28eHEqiCOh
         zk3j7P/69hqN1jQRrFnTNkCEWoegodzVrgtTNsPztS5C6xXOTpdGtNUcl5x/VgmH+Y3P
         cMtAZpcJi6mHFFzTM+rA0UYVuJ/089m4vT0yINi8V8Vq2oY5AE+0EiZoBQp0nmQQXQ+d
         4pvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=a8n8TK7ZbNzHz/JQgi50vPSbInbioYYXQG4XpTwbReA=;
        b=JHkVIm3tbUBu1dH5AVzLQ472C+iFnmU054GtnBW7aWcU6x0bx11QiDx4sQVBkmh8v4
         KDyiIrvp5uB8arVbmL+SKp6zmb/sc4D2OTJBXmr3AQblLTEpqfESl8l+fyikMj5sFuxz
         U26GltAOJVWp+PwT36vb1j6zFsPR22TFYqAQKbZ1SE9HoaOCQrHHxkFipmBkRj4tCDz/
         uzK67KwFd9hhBVqEn2FjvU5LeioLH5AbSg2JMXEgU/ERnWUnGggenvTsGum7VXtrrqGX
         SFpBaZxQkk99jsEQPSYACetg5MBsTXuAdDw+iYc3G6Nf8SzvKO4KH8IJhYBmjCXjFrVg
         nOEg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 33si37902359pla.44.2019.08.01.23.52.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 23:52:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 Aug 2019 23:52:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,337,1559545200"; 
   d="scan'208";a="372871607"
Received: from orsmsx106.amr.corp.intel.com ([10.22.225.133])
  by fmsmga006.fm.intel.com with ESMTP; 01 Aug 2019 23:52:11 -0700
Received: from orsmsx114.amr.corp.intel.com ([169.254.8.96]) by
 ORSMSX106.amr.corp.intel.com ([169.254.1.52]) with mapi id 14.03.0439.000;
 Thu, 1 Aug 2019 23:52:11 -0700
From: "Prakhya, Sai Praneeth" <sai.praneeth.prakhya@intel.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
CC: "Hansen, Dave" <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>, Andrew Morton
	<akpm@linux-foundation.org>
Subject: RE: [PATCH] fork: Improve error message for corrupted page tables
Thread-Topic: [PATCH] fork: Improve error message for corrupted page tables
Thread-Index: AQHVRyU2Tlnukuaks0aiZwfZ/9aV0qbmQJYAgAEtK5A=
Date: Fri, 2 Aug 2019 06:52:10 +0000
Message-ID: <FFF73D592F13FD46B8700F0A279B802F4F9D62D6@ORSMSX114.amr.corp.intel.com>
References: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
 <56ad91b8-1ea0-6736-5bc5-eea0ced01054@arm.com>
In-Reply-To: <56ad91b8-1ea0-6736-5bc5-eea0ced01054@arm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiNjE3Yzk5NjMtZDc4OC00ODc3LWI4OGEtOWEyMWE1MzM4ZmUxIiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiRXVaNFc2KzJWZ0h5dk11WXE1K3NzaVdldmNMeGd5RXlzenJXZXJOM2x3cE1Ncmg3SnJ0Y0VoN1wvWUpWek0wV0gifQ==
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: no-action
x-originating-ip: [10.22.254.138]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiA+DQo+ID4gQ2M6IEluZ28gTW9sbmFyIDxtaW5nb0BrZXJuZWwub3JnPg0KPiA+IENjOiBQZXRl
ciBaaWpsc3RyYSA8cGV0ZXJ6QGluZnJhZGVhZC5vcmc+DQo+ID4gQ2M6IEFuZHJldyBNb3J0b24g
PGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc+DQo+ID4gU3VnZ2VzdGVkLWJ5L0Fja2VkLWJ5OiBE
YXZlIEhhbnNlbiA8ZGF2ZS5oYW5zZW5AaW50ZWwuY29tPg0KPiANCj4gVGhvdWdoIEkgYW0gbm90
IHN1cmUsIHNob3VsZCB0aGUgYWJvdmUgYmUgdHdvIHNlcGFyYXRlIGxpbmVzIGluc3RlYWQgPw0K
DQpTdXJlISBXaWxsIHNwbGl0IHRoZW0gaW4gVjIuDQoNCj4gDQo+ID4gU2lnbmVkLW9mZi1ieTog
U2FpIFByYW5lZXRoIFByYWtoeWEgPHNhaS5wcmFuZWV0aC5wcmFraHlhQGludGVsLmNvbT4NCj4g
PiAtLS0NCj4gPiAgaW5jbHVkZS9saW51eC9tbV90eXBlc190YXNrLmggfCA3ICsrKysrKysNCj4g
PiAga2VybmVsL2ZvcmsuYyAgICAgICAgICAgICAgICAgfCA0ICsrLS0NCj4gPiAgMiBmaWxlcyBj
aGFuZ2VkLCA5IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pDQo+ID4NCj4gPiBkaWZmIC0t
Z2l0IGEvaW5jbHVkZS9saW51eC9tbV90eXBlc190YXNrLmgNCj4gPiBiL2luY2x1ZGUvbGludXgv
bW1fdHlwZXNfdGFzay5oIGluZGV4IGQ3MDE2ZGNiMjQ1ZS4uODgxZjRlYTNhMWI1DQo+ID4gMTAw
NjQ0DQo+ID4gLS0tIGEvaW5jbHVkZS9saW51eC9tbV90eXBlc190YXNrLmgNCj4gPiArKysgYi9p
bmNsdWRlL2xpbnV4L21tX3R5cGVzX3Rhc2suaA0KPiA+IEBAIC00NCw2ICs0NCwxMyBAQCBlbnVt
IHsNCj4gPiAgCU5SX01NX0NPVU5URVJTDQo+ID4gIH07DQo+ID4NCj4gPiArc3RhdGljIGNvbnN0
IGNoYXIgKiBjb25zdCByZXNpZGVudF9wYWdlX3R5cGVzW05SX01NX0NPVU5URVJTXSA9IHsNCj4g
PiArCSJNTV9GSUxFUEFHRVMiLA0KPiA+ICsJIk1NX0FOT05QQUdFUyIsDQo+ID4gKwkiTU1fU1dB
UEVOVFMiLA0KPiA+ICsJIk1NX1NITUVNUEFHRVMiLA0KPiA+ICt9Ow0KPiANCj4gU2hvdWxkIGlu
ZGV4IHRoZW0gdG8gbWF0Y2ggcmVzcGVjdGl2ZSB0eXBvIG1hY3Jvcy4NCj4gDQo+IAlbTU1fRklM
RVBBR0VTXSA9ICJNTV9GSUxFUEFHRVMiLA0KPiAJW01NX0FOT05QQUdFU10gPSAiTU1fQU5PTlBB
R0VTIiwNCj4gCVtNTV9TV0FQRU5UU10gPSAiTU1fU1dBUEVOVFMiLA0KPiAJW01NX1NITUVNUEFH
RVNdID0gIk1NX1NITUVNUEFHRVMiLA0KDQpTdXJlISBXaWxsIGNoYW5nZSBpdC4NCg0KPiA+ICsN
Cj4gPiAgI2lmIFVTRV9TUExJVF9QVEVfUFRMT0NLUyAmJiBkZWZpbmVkKENPTkZJR19NTVUpICAj
ZGVmaW5lDQo+ID4gU1BMSVRfUlNTX0NPVU5USU5HDQo+ID4gIC8qIHBlci10aHJlYWQgY2FjaGVk
IGluZm9ybWF0aW9uLCAqLw0KPiA+IGRpZmYgLS1naXQgYS9rZXJuZWwvZm9yay5jIGIva2VybmVs
L2ZvcmsuYyBpbmRleA0KPiA+IDI4NTJkMGU3NmVhMy4uNmFlZjU4NDJkNGUwIDEwMDY0NA0KPiA+
IC0tLSBhL2tlcm5lbC9mb3JrLmMNCj4gPiArKysgYi9rZXJuZWwvZm9yay5jDQo+ID4gQEAgLTY0
OSw4ICs2NDksOCBAQCBzdGF0aWMgdm9pZCBjaGVja19tbShzdHJ1Y3QgbW1fc3RydWN0ICptbSkN
Cj4gPiAgCQlsb25nIHggPSBhdG9taWNfbG9uZ19yZWFkKCZtbS0+cnNzX3N0YXQuY291bnRbaV0p
Ow0KPiA+DQo+ID4gIAkJaWYgKHVubGlrZWx5KHgpKQ0KPiA+IC0JCQlwcmludGsoS0VSTl9BTEVS
VCAiQlVHOiBCYWQgcnNzLWNvdW50ZXIgc3RhdGUgIg0KPiA+IC0JCQkJCSAgIm1tOiVwIGlkeDol
ZCB2YWw6JWxkXG4iLCBtbSwgaSwgeCk7DQo+ID4gKwkJCXByX2FsZXJ0KCJCVUc6IEJhZCByc3Mt
Y291bnRlciBzdGF0ZSBtbTolcCB0eXBlOiVzDQo+IHZhbDolbGRcbiIsDQo+ID4gKwkJCQkgbW0s
IHJlc2lkZW50X3BhZ2VfdHlwZXNbaV0sIHgpOw0KPiBJdCBjaGFuZ2VzIHRoZSBwcmludCBmdW5j
dGlvbiBhcyB3ZWxsLCB0aG91Z2ggdmVyeSBtaW5vciBjaGFuZ2UgYnV0IHBlcmhhcHMNCj4gbWVu
dGlvbiB0aGF0IGluIHRoZSBjb21taXQgbWVzc2FnZSA/DQoNClN1cmUhIFdpbGwgbWVudGlvbiBp
dCBpbiBWMi4NCkkgaGF2ZSBjaGFuZ2VkIHByaW50aygpIHRvIHByX2FsZXJ0KCkgYmVjYXVzZSB0
aGUgb3RoZXIgbWVzc2FnZSBpbiBjaGVja19tbSgpIHVzZXMgcHJfYWxlcnQoKS4NCg0KUmVnYXJk
cywNClNhaQ0K

