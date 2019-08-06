Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C797C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:10:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19B5620679
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:10:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19B5620679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9B206B0005; Tue,  6 Aug 2019 12:10:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4B5C6B0006; Tue,  6 Aug 2019 12:10:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 939E96B0007; Tue,  6 Aug 2019 12:10:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF6B6B0005
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:10:20 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g126so8675912pgc.22
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:10:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:dlp-product
         :dlp-version:dlp-reaction:content-transfer-encoding:mime-version;
        bh=DdthXg71XlAezKeUdxV5F3J2QQWnWjL1ZgTlWhH0Bvg=;
        b=aTAzY5WCJF//bEerGB4omqvk4LhVNtVIzLX9umqGweY1X8Cz1fdHSiXs5ejgy4hh2K
         qQpYRDmHURiotuaAmUV+gk0LouKtuA8Fr+vDzrBnhVKvkQLXlpgoxFltVRAcvkQhhy2t
         m7x5d31k+yl1MTJ6P/XoV9N7q+f/6s3Y3fzH9YfNu/+GPbNTfBBCftlfx7Jg6YDT1ERp
         GBVxT42m0YR13btCzxMIVeODpBTvbT/3ZqXMxnnO+Y5LpkRYXZibifBYgrnjOc8T6jrW
         c1qqMi5G09q3V5ZJ8e02EHfgqCxp+yMpjOueFsMI3egJp2bZDvKQeICZMJX6G/nPGUsq
         2Wag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV+RddcJmiL0iiZAnL3VkePgj6qCvjIK+TTch1NXQ0H1o5BtixZ
	MEBsHxWV8XkHmZwGM/lZr9Lwf7MMpL6ssaeVzvU6RY2tYsC42mGNCzS3INMd3pmEhcZZaTsf4+7
	c5aGE5eAyWHqBA4EMVPnkV9mOhYrT7tj0JWiqZgdlLWKs9+8yAyvuhmZIDNS5nGEYOA==
X-Received: by 2002:a63:101b:: with SMTP id f27mr3560369pgl.291.1565107819943;
        Tue, 06 Aug 2019 09:10:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxinDf/0oHkZgIB+8Zb8/jRjnwtVEtBF5w7bo5OhUberKeLMxgIdJR6J06x7Qlx22kNfM2a
X-Received: by 2002:a63:101b:: with SMTP id f27mr3560311pgl.291.1565107818991;
        Tue, 06 Aug 2019 09:10:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565107818; cv=none;
        d=google.com; s=arc-20160816;
        b=eBDHdfj6S4GTFD6l1z1pvK5vOBt2z6+UQ0ednwLbPeSEItsEYdfY0f+mfoWXNrUk0o
         5ix1SavkA8bYUpIExebe9ew6aKqiXV2YLSVoIXk/rXBErh5mtz9sRwzVrKlxROoTnRlK
         8aozVoe1llFZ6FSNbg1p8evGTh5jAT04KUVsXPYw97Jr9U7iC3CUy2nQSV/9ErduMtlh
         YU8KBPjWXBiJSvs0Gqegk1H43R3ylAdZyScGLsrCaUGiYoVnHLKrgHcxy7QQ9REDlBi3
         9HlTqSY9VWefUCMOiozPqCVZiEofOPb6IBnMYZRVh+x9ZhFYnMpvD66H+Ue8eXZyqX4z
         d2NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:dlp-reaction:dlp-version
         :dlp-product:content-language:accept-language:in-reply-to:references
         :message-id:date:thread-index:thread-topic:subject:cc:to:from;
        bh=DdthXg71XlAezKeUdxV5F3J2QQWnWjL1ZgTlWhH0Bvg=;
        b=o1sDuEWj5WW83+yCrT22K4c5P3RKgP/xXmlFw/sQGY7DzCiVMl/8I7RoQDRf6DLDBi
         MFZRDortnGt/a8phCmiPts1PpmcR+MokIofAhm1w91Cuk95F3AsgZbT10bFXG/VAOQcE
         rucxmO5DvL4Mxtcplf5XKP5q7rMDefCnYNRFV+E/cTgqDfOlfAGuP+B2oHnuMLSb1Zf6
         bhOfEro/8VyN8hObSIsbqFoPv6o+LPtZETL7LISih513cdjQOvc3rU/B1NuB3Oikf6CJ
         3Z/pZ30RE/S26tc9ByU0vnUtDFsfi7QIaMcZ4kfCxEINeZ57wlGri5usUYAJAxAg7pdn
         VLCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f17si50684514pgh.552.2019.08.06.09.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 09:10:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 09:10:17 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="198355562"
Received: from orsmsx101.amr.corp.intel.com ([10.22.225.128])
  by fmsmga004.fm.intel.com with ESMTP; 06 Aug 2019 09:10:16 -0700
Received: from orsmsx114.amr.corp.intel.com ([169.254.8.96]) by
 ORSMSX101.amr.corp.intel.com ([169.254.8.157]) with mapi id 14.03.0439.000;
 Tue, 6 Aug 2019 09:10:16 -0700
From: "Prakhya, Sai Praneeth" <sai.praneeth.prakhya@intel.com>
To: Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: "Hansen, Dave" <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>, Andrew Morton
	<akpm@linux-foundation.org>, Anshuman Khandual <anshuman.khandual@arm.com>
Subject: RE: [PATCH V2] fork: Improve error message for corrupted page tables
Thread-Topic: [PATCH V2] fork: Improve error message for corrupted page
 tables
Thread-Index: AQHVTARBoUI2WxhjVEayaDrB3An0D6buNXYAgAAUpHA=
Date: Tue, 6 Aug 2019 16:10:16 +0000
Message-ID: <FFF73D592F13FD46B8700F0A279B802F4FA16EF9@ORSMSX114.amr.corp.intel.com>
References: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
 <5ba88460-cf01-3d53-6d13-45e650b4eacd@suse.cz>
In-Reply-To: <5ba88460-cf01-3d53-6d13-45e650b4eacd@suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-titus-metadata-40: eyJDYXRlZ29yeUxhYmVscyI6IiIsIk1ldGFkYXRhIjp7Im5zIjoiaHR0cDpcL1wvd3d3LnRpdHVzLmNvbVwvbnNcL0ludGVsMyIsImlkIjoiYjY0MjgyNjMtNzcwZC00Yzk1LWE0NzEtNDY0NWU5ZTcxYzg2IiwicHJvcHMiOlt7Im4iOiJDVFBDbGFzc2lmaWNhdGlvbiIsInZhbHMiOlt7InZhbHVlIjoiQ1RQX05UIn1dfV19LCJTdWJqZWN0TGFiZWxzIjpbXSwiVE1DVmVyc2lvbiI6IjE3LjEwLjE4MDQuNDkiLCJUcnVzdGVkTGFiZWxIYXNoIjoiaUJ5clZZdENIcktBbmpycTA5TER2Vlk2QVJPZlVEUElwXC93MzZIOVwvTG5Tb1VcL3l4MEw3XC9YUXVVUzlvcDhUbVwvIn0=
x-ctpclassification: CTP_NT
dlp-product: dlpe-windows
dlp-version: 11.0.600.7
dlp-reaction: request-justification,no-action
x-originating-ip: [10.22.254.138]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiA+IFdpdGggcGF0Y2g6DQo+ID4gLS0tLS0tLS0tLS0NCj4gPiBbICAgNjkuODE1NDUzXSBtbS9w
Z3RhYmxlLWdlbmVyaWMuYzoyOTogYmFkIHA0ZA0KPiAwMDAwMDAwMDg0NjUzNjQyKDgwMDAwMDAy
NWNhMzc0NjcpDQo+ID4gWyAgIDY5LjgxNTg3Ml0gQlVHOiBCYWQgcnNzLWNvdW50ZXIgc3RhdGUg
bW06MDAwMDAwMDAwMTRhNmMwMw0KPiB0eXBlOk1NX0ZJTEVQQUdFUyB2YWw6Mg0KPiA+IFsgICA2
OS44MTU5NjJdIEJVRzogQmFkIHJzcy1jb3VudGVyIHN0YXRlIG1tOjAwMDAwMDAwMDE0YTZjMDMN
Cj4gdHlwZTpNTV9BTk9OUEFHRVMgdmFsOjUNCj4gPiBbICAgNjkuODE2MDUwXSBCVUc6IG5vbi16
ZXJvIHBndGFibGVzX2J5dGVzIG9uIGZyZWVpbmcgbW06IDIwNDgwDQo+ID4NCj4gPiBBbHNvLCBj
aGFuZ2UgcHJpbnQgZnVuY3Rpb24gKGZyb20gcHJpbnRrKEtFUk5fQUxFUlQsIC4uKSB0bw0KPiA+
IHByX2FsZXJ0KCkpIHNvIHRoYXQgaXQgbWF0Y2hlcyB0aGUgb3RoZXIgcHJpbnQgc3RhdGVtZW50
Lg0KPiA+DQo+ID4gQ2M6IEluZ28gTW9sbmFyIDxtaW5nb0BrZXJuZWwub3JnPg0KPiA+IENjOiBW
bGFzdGltaWwgQmFia2EgPHZiYWJrYUBzdXNlLmN6Pg0KPiA+IENjOiBQZXRlciBaaWpsc3RyYSA8
cGV0ZXJ6QGluZnJhZGVhZC5vcmc+DQo+ID4gQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgt
Zm91bmRhdGlvbi5vcmc+DQo+ID4gQ2M6IEFuc2h1bWFuIEtoYW5kdWFsIDxhbnNodW1hbi5raGFu
ZHVhbEBhcm0uY29tPg0KPiA+IEFja2VkLWJ5OiBEYXZlIEhhbnNlbiA8ZGF2ZS5oYW5zZW5AaW50
ZWwuY29tPg0KPiA+IFN1Z2dlc3RlZC1ieTogRGF2ZSBIYW5zZW4gPGRhdmUuaGFuc2VuQGludGVs
LmNvbT4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBTYWkgUHJhbmVldGggUHJha2h5YSA8c2FpLnByYW5l
ZXRoLnByYWtoeWFAaW50ZWwuY29tPg0KPiANCj4gQWNrZWQtYnk6IFZsYXN0aW1pbCBCYWJrYSA8
dmJhYmthQHN1c2UuY3o+DQo+IA0KPiBJIHdvdWxkIGFsc28gYWRkIHNvbWV0aGluZyBsaWtlIHRo
aXMgdG8gcmVkdWNlIHJpc2sgb2YgYnJlYWtpbmcgaXQgaW4gdGhlDQo+IGZ1dHVyZToNCg0KU3Vy
ZSEgU291bmRzIGdvb2QgdG8gbWUuIFdpbGwgYWRkIGl0IHRvIFYzLg0KDQpSZWdhcmRzLA0KU2Fp
DQo=

