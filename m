Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61876C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:22:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03BA421874
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 13:22:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="RUwBe3MV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03BA421874
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A48EE6B0005; Thu, 21 Mar 2019 09:22:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F7AF6B0007; Thu, 21 Mar 2019 09:22:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 897B56B0008; Thu, 21 Mar 2019 09:22:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 696EE6B0005
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 09:22:38 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id k5so5099125ioh.13
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 06:22:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=evBEIq9R7Zyav+BEQnsIq594pdJQbHyzsBjcA5BVIVM=;
        b=FlYyrk3zsq0oYLglxMzWTI0Wp0Gkst0RASF+B1QAMI1kTZhlswnmegSy62WC8/ZaNV
         06Trnw2i4AgvzofHkcWBx/bw6BiUwnAfNfNCJ7M2wIBMpkd5/cIwencDJX2f16z53hgY
         kjOfTAFT4lADaKiK5zh2ERz8RGgSq3ooI3g46Bl63HUSsWdrnPXnR10aP+u2aS2CFIz9
         c8Pv9E2KcGrHIJ39tP4MdOC0POBth4ZBQiAcAv7vZM7h3fjizWhGG4xtQCgZbZzb54UZ
         5OBA/D07M/A5Dpqy0c51vDap9mvBV7FIgEaGnCv7L287oQtXrMM5rFZet1HUkvE7eoDy
         Sfyg==
X-Gm-Message-State: APjAAAWoTwupni7nQO+wmWHr4WDc6yT3rg1LLbmU1oI4iNZsyPlZV5Fg
	vIiMHWB5Ltu8eeTAul35VcAFxBhot2IBNyZ1+S5RPv8kaD6d12QAO1g5LSiJooYn2leDrOEnkHi
	K8kjchyWPKOn80cpKgLZtEdNkXpxHudj3BzJmaw7hjnFmSs9CHYVY7VW9esWZu91hSQ==
X-Received: by 2002:a5d:9159:: with SMTP id y25mr2699334ioq.146.1553174558171;
        Thu, 21 Mar 2019 06:22:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaFmqEYZoXz6NfIMmyqhHPrQT7BllmiqMWpBOZRExXUrziiGOtSbIPwBfP1Z4WccZtLJ0A
X-Received: by 2002:a5d:9159:: with SMTP id y25mr2699252ioq.146.1553174557143;
        Thu, 21 Mar 2019 06:22:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553174557; cv=none;
        d=google.com; s=arc-20160816;
        b=JZpx72Xka8TeloHnFPyxVOpPgfQChJiNPyPvt4UByjWA2KUrQGvKDn9M9bHxirKmht
         NxlQMW5wwiDJPe8TpnYFrmcjTyON/D5mXGKsJN5p7Z0qVE2LCf5KRzbJv/b0dxvmqXy9
         Jx2W7/IIlEDfQ88lu4XX0iY3E9YKpaPdkQy99bOF/RPYqpUjoKhB084V8hQrFOsCjM47
         BBLXGFQqL5Pg5Is/vFYzARLf1e4x2q8D6UuMjm2AAajQYrD/Wj8Dzj+AjO98TrjRR7Do
         3ChTUF5GwR/dGrTehf1iZeBomexWi2lNAuTSPMjqajsbm+GHxIiX/tAqtuprLDEJvjfh
         d0HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=evBEIq9R7Zyav+BEQnsIq594pdJQbHyzsBjcA5BVIVM=;
        b=doZ4w2v7beLpoT8LQeA5feT+qR97Dqofq5H1uDObye1itiP3YxZpF9qZKw5rtAilz0
         flUE0bFxp6HD5cz7RNwh/fgahEDuYQRt3+0OIxya0W7odMg4s3R46aoW+tOgpRNDo03x
         ExeNb3n/fZIn7mmreoumo0ijpbnmG7eyoOZixbnBF9oT6XGcs6QxOVlCHvI1UwTIXLvN
         9s19X7LLTikfA8jXQ+cyEqwn5cfpDD0DHb9RB73pn7Rm2tLcZAyF4sOAWz113RoKBsde
         /3SydN0S9fHDkYKE+2nY1b5P++x1UoTIZtd1O3ggHQg2tCcC9Zr3nRivQgbEDVOIOGpu
         SI1g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=RUwBe3MV;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.76.54 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760054.outbound.protection.outlook.com. [40.107.76.54])
        by mx.google.com with ESMTPS id x5si2363883iof.64.2019.03.21.06.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 21 Mar 2019 06:22:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.76.54 as permitted sender) client-ip=40.107.76.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=RUwBe3MV;
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.76.54 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=evBEIq9R7Zyav+BEQnsIq594pdJQbHyzsBjcA5BVIVM=;
 b=RUwBe3MVyEk8YrgBQkdtOcdZfy1U9Gr3+zULuL/M1p7Cpu4ZV3TpI8jhocKJnPCSZuHU0TCR2ksu1uRkMrD4N2Wq/TnGr6he23ABWYG2N+lu0gy+InuiLCgZ7HKZSV0pfBJOuzfimD/HNelBB+5S2hSCSHdK6MlN2w8gH3qvfXU=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6095.namprd05.prod.outlook.com (20.178.243.30) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.15; Thu, 21 Mar 2019 13:22:29 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%6]) with mapi id 15.20.1750.010; Thu, 21 Mar 2019
 13:22:29 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>
CC: Thomas Hellstrom <thellstrom@vmware.com>, Andrew Morton
	<akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Will
 Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Rik van
 Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko
	<mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Souptick Joarder
	<jrdr.linux@gmail.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: [RFC PATCH RESEND 1/3] mm: Allow the [page|pfn]_mkwrite callbacks to
 drop the mmap_sem
Thread-Topic: [RFC PATCH RESEND 1/3] mm: Allow the [page|pfn]_mkwrite
 callbacks to drop the mmap_sem
Thread-Index: AQHU3+kixa6QVuIp90qsvOxWc92GAQ==
Date: Thu, 21 Mar 2019 13:22:29 +0000
Message-ID: <20190321132140.114878-2-thellstrom@vmware.com>
References: <20190321132140.114878-1-thellstrom@vmware.com>
In-Reply-To: <20190321132140.114878-1-thellstrom@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: BYAPR01CA0039.prod.exchangelabs.com (2603:10b6:a03:94::16)
 To MN2PR05MB6141.namprd05.prod.outlook.com (2603:10b6:208:c7::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.19.0.rc1
x-originating-ip: [208.91.2.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f8833622-1aa9-4e42-cce7-08d6ae004434
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:MN2PR05MB6095;
x-ms-traffictypediagnostic: MN2PR05MB6095:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB6095AD52C6A1E1FD895BE89DA1420@MN2PR05MB6095.namprd05.prod.outlook.com>
x-forefront-prvs: 0983EAD6B2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(136003)(366004)(376002)(346002)(396003)(189003)(199004)(186003)(66574012)(86362001)(1076003)(71200400001)(68736007)(66066001)(71190400001)(26005)(476003)(11346002)(2616005)(6506007)(386003)(97736004)(486006)(256004)(110136005)(25786009)(7416002)(54906003)(14444005)(446003)(102836004)(305945005)(76176011)(316002)(6436002)(7736002)(2906002)(36756003)(52116002)(6486002)(14454004)(6636002)(3846002)(6116002)(105586002)(6512007)(106356001)(50226002)(5660300002)(53936002)(99286004)(8676002)(8936002)(4326008)(81156014)(2501003)(81166006)(478600001);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6095;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 hQ4P8jjvw7j9PnvCLnLqF/GNKKgk7ETWks3+0uciBAf1mPomnGmHbw7v9jFigYR9ioF3fURfupWC8oH0dst3H1CkE5iukc1CxJVGUNooDfjPemidP1ysWVubhMHYYiYrl7vkdU0kXWf61qv7m2kWgTsInJX3935wMScSiBRKOQnM6TE1Kr8DjOUuJGKupuiefNYfdQQSbCZ/WOU6DgHUnMQe5aU4WYyEBCxs6f/3e09nE4n+4qSROtu66rG21uI/2hycZtfEwMHBxiTT+nKHf0zIwAZv10CI433yczyCkpogKAa91j4xl4Rl3cvDhTGfzLSOcKKnJqNE+5SmSg5rNPB906pmt0HnHP/1IraL6muJfLbXunbaBdkppsNE9GHIreBs5m/MdrkjOBSsvVUiZNaytemNjBzUCpzSl2QLA60=
Content-Type: text/plain; charset="utf-8"
Content-ID: <14C50C164779244686F1CE797E991428@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f8833622-1aa9-4e42-cce7-08d6ae004434
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Mar 2019 13:22:29.4293
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6095
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

RHJpdmVyIGZhdWx0IGNhbGxiYWNrcyBhcmUgYWxsb3dlZCB0byBkcm9wIHRoZSBtbWFwX3NlbSB3
aGVuIGV4cGVjdGluZw0KbG9uZyBoYXJkd2FyZSB3YWl0cyB0byBhdm9pZCBibG9ja2luZyBvdGhl
ciBtbSB1c2Vycy4gQWxsb3cgdGhlIG1rd3JpdGUNCmNhbGxiYWNrcyB0byBkbyB0aGUgc2FtZSBi
eSByZXR1cm5pbmcgZWFybHkgb24gVk1fRkFVTFRfUkVUUlkuDQoNCkluIHBhcnRpY3VsYXIgd2Ug
d2FudCB0byBiZSBhYmxlIHRvIGRyb3AgdGhlIG1tYXBfc2VtIHdoZW4gd2FpdGluZyBmb3INCmEg
cmVzZXJ2YXRpb24gb2JqZWN0IGxvY2sgb24gYSBHUFUgYnVmZmVyIG9iamVjdC4gVGhlc2UgbG9j
a3MgbWF5IGJlDQpoZWxkIHdoaWxlIHdhaXRpbmcgZm9yIHRoZSBHUFUuDQoNCkNjOiBBbmRyZXcg
TW9ydG9uIDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KQ2M6IE1hdHRoZXcgV2lsY294IDx3
aWxseUBpbmZyYWRlYWQub3JnPg0KQ2M6IFdpbGwgRGVhY29uIDx3aWxsLmRlYWNvbkBhcm0uY29t
Pg0KQ2M6IFBldGVyIFppamxzdHJhIDxwZXRlcnpAaW5mcmFkZWFkLm9yZz4NCkNjOiBSaWsgdmFu
IFJpZWwgPHJpZWxAc3VycmllbC5jb20+DQpDYzogTWluY2hhbiBLaW0gPG1pbmNoYW5Aa2VybmVs
Lm9yZz4NCkNjOiBNaWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNvbT4NCkNjOiBIdWFuZyBZaW5n
IDx5aW5nLmh1YW5nQGludGVsLmNvbT4NCkNjOiBTb3VwdGljayBKb2FyZGVyIDxqcmRyLmxpbnV4
QGdtYWlsLmNvbT4NCkNjOiAiSsOpcsO0bWUgR2xpc3NlIiA8amdsaXNzZUByZWRoYXQuY29tPg0K
Q2M6IGxpbnV4LW1tQGt2YWNrLm9yZw0KQ2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcN
Cg0KU2lnbmVkLW9mZi1ieTogVGhvbWFzIEhlbGxzdHJvbSA8dGhlbGxzdHJvbUB2bXdhcmUuY29t
Pg0KLS0tDQogbW0vbWVtb3J5LmMgfCAxMCArKysrKystLS0tDQogMSBmaWxlIGNoYW5nZWQsIDYg
aW5zZXJ0aW9ucygrKSwgNCBkZWxldGlvbnMoLSkNCg0KZGlmZiAtLWdpdCBhL21tL21lbW9yeS5j
IGIvbW0vbWVtb3J5LmMNCmluZGV4IGE1MjY2M2MwNjEyZC4uZGNkODAzMTNjZjEwIDEwMDY0NA0K
LS0tIGEvbW0vbWVtb3J5LmMNCisrKyBiL21tL21lbW9yeS5jDQpAQCAtMjE0NCw3ICsyMTQ0LDcg
QEAgc3RhdGljIHZtX2ZhdWx0X3QgZG9fcGFnZV9ta3dyaXRlKHN0cnVjdCB2bV9mYXVsdCAqdm1m
KQ0KIAlyZXQgPSB2bWYtPnZtYS0+dm1fb3BzLT5wYWdlX21rd3JpdGUodm1mKTsNCiAJLyogUmVz
dG9yZSBvcmlnaW5hbCBmbGFncyBzbyB0aGF0IGNhbGxlciBpcyBub3Qgc3VycHJpc2VkICovDQog
CXZtZi0+ZmxhZ3MgPSBvbGRfZmxhZ3M7DQotCWlmICh1bmxpa2VseShyZXQgJiAoVk1fRkFVTFRf
RVJST1IgfCBWTV9GQVVMVF9OT1BBR0UpKSkNCisJaWYgKHVubGlrZWx5KHJldCAmIChWTV9GQVVM
VF9FUlJPUiB8IFZNX0ZBVUxUX1JFVFJZIHwgVk1fRkFVTFRfTk9QQUdFKSkpDQogCQlyZXR1cm4g
cmV0Ow0KIAlpZiAodW5saWtlbHkoIShyZXQgJiBWTV9GQVVMVF9MT0NLRUQpKSkgew0KIAkJbG9j
a19wYWdlKHBhZ2UpOw0KQEAgLTI0MTksNyArMjQxOSw3IEBAIHN0YXRpYyB2bV9mYXVsdF90IHdw
X3Bmbl9zaGFyZWQoc3RydWN0IHZtX2ZhdWx0ICp2bWYpDQogCQlwdGVfdW5tYXBfdW5sb2NrKHZt
Zi0+cHRlLCB2bWYtPnB0bCk7DQogCQl2bWYtPmZsYWdzIHw9IEZBVUxUX0ZMQUdfTUtXUklURTsN
CiAJCXJldCA9IHZtYS0+dm1fb3BzLT5wZm5fbWt3cml0ZSh2bWYpOw0KLQkJaWYgKHJldCAmIChW
TV9GQVVMVF9FUlJPUiB8IFZNX0ZBVUxUX05PUEFHRSkpDQorCQlpZiAocmV0ICYgKFZNX0ZBVUxU
X0VSUk9SIHwgVk1fRkFVTFRfUkVUUlkgfCBWTV9GQVVMVF9OT1BBR0UpKQ0KIAkJCXJldHVybiBy
ZXQ7DQogCQlyZXR1cm4gZmluaXNoX21rd3JpdGVfZmF1bHQodm1mKTsNCiAJfQ0KQEAgLTI0NDAs
NyArMjQ0MCw4IEBAIHN0YXRpYyB2bV9mYXVsdF90IHdwX3BhZ2Vfc2hhcmVkKHN0cnVjdCB2bV9m
YXVsdCAqdm1mKQ0KIAkJcHRlX3VubWFwX3VubG9jayh2bWYtPnB0ZSwgdm1mLT5wdGwpOw0KIAkJ
dG1wID0gZG9fcGFnZV9ta3dyaXRlKHZtZik7DQogCQlpZiAodW5saWtlbHkoIXRtcCB8fCAodG1w
ICYNCi0JCQkJICAgICAgKFZNX0ZBVUxUX0VSUk9SIHwgVk1fRkFVTFRfTk9QQUdFKSkpKSB7DQor
CQkJCSAgICAgIChWTV9GQVVMVF9FUlJPUiB8IFZNX0ZBVUxUX1JFVFJZIHwNCisJCQkJICAgICAg
IFZNX0ZBVUxUX05PUEFHRSkpKSkgew0KIAkJCXB1dF9wYWdlKHZtZi0+cGFnZSk7DQogCQkJcmV0
dXJuIHRtcDsNCiAJCX0NCkBAIC0zNDcyLDcgKzM0NzMsOCBAQCBzdGF0aWMgdm1fZmF1bHRfdCBk
b19zaGFyZWRfZmF1bHQoc3RydWN0IHZtX2ZhdWx0ICp2bWYpDQogCQl1bmxvY2tfcGFnZSh2bWYt
PnBhZ2UpOw0KIAkJdG1wID0gZG9fcGFnZV9ta3dyaXRlKHZtZik7DQogCQlpZiAodW5saWtlbHko
IXRtcCB8fA0KLQkJCQkodG1wICYgKFZNX0ZBVUxUX0VSUk9SIHwgVk1fRkFVTFRfTk9QQUdFKSkp
KSB7DQorCQkJCSh0bXAgJiAoVk1fRkFVTFRfRVJST1IgfCBWTV9GQVVMVF9SRVRSWSB8DQorCQkJ
CQlWTV9GQVVMVF9OT1BBR0UpKSkpIHsNCiAJCQlwdXRfcGFnZSh2bWYtPnBhZ2UpOw0KIAkJCXJl
dHVybiB0bXA7DQogCQl9DQotLSANCjIuMTkuMC5yYzENCg0K

