Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46408C282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:04:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB21E20869
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 16:04:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="hz/XNTXv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB21E20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 726486B000D; Fri, 12 Apr 2019 12:04:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6AE816B0010; Fri, 12 Apr 2019 12:04:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52C206B026A; Fri, 12 Apr 2019 12:04:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E1B76B000D
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:04:21 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id d193so1136913ybh.13
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 09:04:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=RnalLb37tdOT68e+z6j3AK56+aLKTY24jeQrFgWRkh4=;
        b=p6LDBm/oIG5/PzEMGnigPu0AwKcW8Ama586WyrYJHt7NjUM1jczuyDsUl05obRmF6F
         Xrp4kv05NKmGZhkxKv76yVfgYPeza+09vKUBgGIY+K1OwYWJl6x/VJb+IYW/j1/n1biL
         xUNQ/Kg7Mec8H42/Dh6z8n5ytnAHz1gs4TD8hMf6ldJoWq5s9SBafdprVT6gHOvLu0dP
         BiePRBKTNjO+alWuKcO3q3RIKshkbntyWW8Zsni12WC7QEywkvPTxVdrt6DpNBReFSaR
         bPOktXkKTLUo+AK7U3VaRjlE0e+R+n32twTBP5DS5aj5ysKNHK1SP5t3HeHKtqyS936R
         ot9A==
X-Gm-Message-State: APjAAAWLm+wWrZqaWrDr22Qa7HzbFx3TnSpCnOTgAsFmxx4U5YHUO+u7
	G5GFOLovb83Eorfud9N36x1pWYnHh2yt3D7DQYD+NgQ/PfJW2O5GXE+WSynXmpDGHWU1pL3dcq4
	fD0eFJtsSK88dSzNTacLVAFeUa9m9GSCF0QtMrJZha4UkOf9ED85GJKX0lURNRTt2SA==
X-Received: by 2002:a81:4fcb:: with SMTP id d194mr46641885ywb.171.1555085060859;
        Fri, 12 Apr 2019 09:04:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsnh4OdPJ3Ke09CT6b5L+lR2CVvifmACyBWAsm0p2EEOTbIo1eRKt0KRerlzTdcXQBmcOu
X-Received: by 2002:a81:4fcb:: with SMTP id d194mr46641813ywb.171.1555085060103;
        Fri, 12 Apr 2019 09:04:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555085060; cv=none;
        d=google.com; s=arc-20160816;
        b=sjrA0XgGJ8ON0kTzfrh490lr10n4UYpcVF2IP83jmKxgR7GlHgp9gzYpytHVhaXLdS
         yg0L+8FBlJ41DENLIOyzrBRBgZgUNFsPvMQ9Udz0QO4h4rt8tFj1vhbFG1ykamA9jpoS
         v8rlEpUEt/+erydwKOMpbG4aHIyrSpZF343DK1UEptlgVNkJqe/lRzxcB8AqX2eC8+t3
         FBY2T80eK8Z6mQBtHuq+fQhq5EJu8gdgQMGk/OfV0i43zg1BHqSFzizwTrYZWBF53z6Y
         lZj42gbyBiRzGb+M1GnQlJmFqpmkSP9C/feJv0OL2NCyWPulIdS9xYnDQaPXne02lySa
         JIAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=RnalLb37tdOT68e+z6j3AK56+aLKTY24jeQrFgWRkh4=;
        b=XvxEI9SF9jmrHx6+K8Vp8HgB7T84MwVWHSdMQIrU1rYD6cZMZkbb0DvdelWEIeBcR2
         j8NNbo0GYFswQ61q7FZM6s35qsL/sGGr5GU1wrT8zB/CDO/yN6dIfo9oAHoZm8Ty+SrD
         MM2V0/1UsAVdHOVHpFJhyuCVuI83dUv6MDprHuG81THnIBneJdl7xWAOnP3IN8zQL/j/
         84lTTOqIs7uwZ6VAcbpQIzL66xHpZcwsZm8Y7MsJsCcEGM3J4LjKvff0g0vNxErqRxGJ
         9tmqSQqJTCy4A6z5hAGhRgswc/UhSb490fIHvdVknJqtQSFIKe4zJBMpmSA1Nq7xvsFJ
         Nw9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b="hz/XNTXv";
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.72 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800072.outbound.protection.outlook.com. [40.107.80.72])
        by mx.google.com with ESMTPS id 126si26257606ywp.465.2019.04.12.09.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 12 Apr 2019 09:04:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.72 as permitted sender) client-ip=40.107.80.72;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b="hz/XNTXv";
       spf=pass (google.com: domain of thellstrom@vmware.com designates 40.107.80.72 as permitted sender) smtp.mailfrom=thellstrom@vmware.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RnalLb37tdOT68e+z6j3AK56+aLKTY24jeQrFgWRkh4=;
 b=hz/XNTXv2Mz6ivglj2+apTuLe+XDDBBclwzmHnvuefg5lMSWSVjlc13uq490Tx++otEPwpPtBROcCWsxHrxoMtF0cFQBqDdPMB5x4wobsx4yq848EULhOQ9C2+ajrx8QtNMvAKiMGCdfdpafLNh+vhALjh5W1BnrAVyed6btBQk=
Received: from MN2PR05MB6141.namprd05.prod.outlook.com (20.178.241.217) by
 MN2PR05MB6030.namprd05.prod.outlook.com (20.178.241.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Fri, 12 Apr 2019 16:04:16 +0000
Received: from MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad]) by MN2PR05MB6141.namprd05.prod.outlook.com
 ([fe80::91e:292d:e304:78ad%7]) with mapi id 15.20.1792.009; Fri, 12 Apr 2019
 16:04:16 +0000
From: Thomas Hellstrom <thellstrom@vmware.com>
To: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
CC: Thomas Hellstrom <thellstrom@vmware.com>, Andrew Morton
	<akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Will
 Deacon <will.deacon@arm.com>, Peter Zijlstra <peterz@infradead.org>, Rik van
 Riel <riel@surriel.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko
	<mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Souptick Joarder
	<jrdr.linux@gmail.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop the
 mmap_sem
Thread-Topic: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop
 the mmap_sem
Thread-Index: AQHU8UlgUqBNZlsCAEaA+wc3NiIS7Q==
Date: Fri, 12 Apr 2019 16:04:15 +0000
Message-ID: <20190412160338.64994-2-thellstrom@vmware.com>
References: <20190412160338.64994-1-thellstrom@vmware.com>
In-Reply-To: <20190412160338.64994-1-thellstrom@vmware.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: VE1PR03CA0023.eurprd03.prod.outlook.com
 (2603:10a6:802:a0::35) To MN2PR05MB6141.namprd05.prod.outlook.com
 (2603:10b6:208:c7::25)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=thellstrom@vmware.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-mailer: git-send-email 2.20.1
x-originating-ip: [155.4.205.35]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 10f9a846-1d8b-4495-f803-08d6bf6082ec
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:MN2PR05MB6030;
x-ms-traffictypediagnostic: MN2PR05MB6030:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <MN2PR05MB60307D97E97292DBFDF3B690A1280@MN2PR05MB6030.namprd05.prod.outlook.com>
x-forefront-prvs: 0005B05917
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(366004)(346002)(376002)(39860400002)(396003)(199004)(189003)(110136005)(25786009)(476003)(2616005)(71190400001)(6512007)(2906002)(186003)(486006)(316002)(54906003)(68736007)(1076003)(6486002)(6436002)(446003)(478600001)(3846002)(71200400001)(6116002)(11346002)(66574012)(99286004)(256004)(14444005)(14454004)(2501003)(8676002)(66066001)(7736002)(4326008)(6506007)(81166006)(36756003)(81156014)(386003)(97736004)(102836004)(50226002)(106356001)(52116002)(5660300002)(53936002)(8936002)(7416002)(305945005)(76176011)(26005)(86362001)(105586002);DIR:OUT;SFP:1101;SCL:1;SRVR:MN2PR05MB6030;H:MN2PR05MB6141.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 sWkyFCpQHafy3Wcw2aH9xrkAISUryjWv/yjF9No2JxMuwgTKhzm5tTypuA8/dDl2souKvun/0Rtx9zYY6YMpUbschdES/dmx1oIrTnRJJ35umFk2p1LIpJhXVNXDftd5uuI/ERYu8ZTZ2cDX0oepv1R6oiabE41cuMJat0HTb1HWq8dqJ/NmJPDV+7IYc+iYJ5gkfquGxR/RWXCkCnQQsSZsVPjE8M8T97tqIAIAJK2C8df3/YPRPAFTexsxQ2VXYW7hk4i82IfTSXFehlLeFswVhpJaF42ENV7nZr9uF5HJ0F2wzSlA3uqdiMLgrpOwyd8Lwa3RTXjYz0fLbvaM7URP2PmAelcs51l84YxmkOf65dpPH0pKVXZlLDx13j+USjg/vR7DCgQOKJNxzNZ4J0CaZR8umzvhL44LveIyeY4=
Content-Type: text/plain; charset="utf-8"
Content-ID: <97BDAE19231BEF48BCE613AF38370D78@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 10f9a846-1d8b-4495-f803-08d6bf6082ec
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Apr 2019 16:04:15.9011
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MN2PR05MB6030
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
IGIvbW0vbWVtb3J5LmMNCmluZGV4IGUxMWNhOWRkODIzZi4uYTk1YjRhM2IxYWUyIDEwMDY0NA0K
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
dXJuIHRtcDsNCiAJCX0NCkBAIC0zNDk0LDcgKzM0OTUsOCBAQCBzdGF0aWMgdm1fZmF1bHRfdCBk
b19zaGFyZWRfZmF1bHQoc3RydWN0IHZtX2ZhdWx0ICp2bWYpDQogCQl1bmxvY2tfcGFnZSh2bWYt
PnBhZ2UpOw0KIAkJdG1wID0gZG9fcGFnZV9ta3dyaXRlKHZtZik7DQogCQlpZiAodW5saWtlbHko
IXRtcCB8fA0KLQkJCQkodG1wICYgKFZNX0ZBVUxUX0VSUk9SIHwgVk1fRkFVTFRfTk9QQUdFKSkp
KSB7DQorCQkJCSh0bXAgJiAoVk1fRkFVTFRfRVJST1IgfCBWTV9GQVVMVF9SRVRSWSB8DQorCQkJ
CQlWTV9GQVVMVF9OT1BBR0UpKSkpIHsNCiAJCQlwdXRfcGFnZSh2bWYtPnBhZ2UpOw0KIAkJCXJl
dHVybiB0bXA7DQogCQl9DQotLSANCjIuMjAuMQ0KDQo=

