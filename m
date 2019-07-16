Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37A96C7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:13:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D11142173B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:13:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="dwxBssUS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D11142173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70ACC8E0003; Tue, 16 Jul 2019 18:13:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BA648E0001; Tue, 16 Jul 2019 18:13:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 582C58E0003; Tue, 16 Jul 2019 18:13:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 365878E0001
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 18:13:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f28so19462629qtg.2
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 15:13:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=38srYE1M7YZC4gYGoF2tMYWtN7U5tg+NQa8d0HX4bRg=;
        b=cm26YNLHegubEebwZnmO6tVAS6b+RTOXVIYqW+wn2jsZoDFbvxFA0BKzEio3ODRK42
         Zpy3kPEChqrFaZaLKMcmvbcLh459NChyzPpbRYubu3/zMozZ9tMKveB/VFlBhHWN+AIo
         Ina05c6slLRRok2Fh45JNkZg7r2IGVVJBhwuNv0t+Jlgfa9J0952PSVl7ZUDP0Tki/Wm
         pCVVtJX8f2gUFu8EF9ONcfuBsu+QjQtBcpsZalDW9XO/C5FY2KM6GZ9k13RYVS6Tx0Dq
         tJpTab1xOkM1ZU9XEfTgK2wOJ3jxs7DJhl4SuXADtNcIy3346jCVjtw/8U4sbCyeCN2C
         SNWA==
X-Gm-Message-State: APjAAAU47fT/sw4gqA2AQ+Udy59B5bjrBKyIxLroGKUkEBSjdYilppYE
	PCit4DV9Wlpj2E7zfwMFDY9fNEB75U48rFX7oJigPPTRbAq8T9uCzrkx28TrmbAT5l0wgTVLh1w
	UamTTEQMmQRh6TWGhnNs8GcdLjZPq1xCLhqnRMYA1PNILXpabIyWzbxphXUfs/H2DzA==
X-Received: by 2002:aed:3535:: with SMTP id a50mr25559756qte.237.1563315191966;
        Tue, 16 Jul 2019 15:13:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7nnv2+eZ5Ph8AK8kmnD2UMt8StrtDK4VbdcXHK7zFl6EAWHXQcAwGVxBN+M6B3Rp8FjPv
X-Received: by 2002:aed:3535:: with SMTP id a50mr25559719qte.237.1563315191472;
        Tue, 16 Jul 2019 15:13:11 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563315191; cv=pass;
        d=google.com; s=arc-20160816;
        b=CrUv30+YsDMuhjhMBM2lVTQzOHfK4KTqKLj+gLrcB8mpFyky6MYZqg8hscfDfQVq2f
         8QeUsvHBqeg2ppE5qlD/hmKen5paK3xGxbKHxcXx/RcZNrba4rd/POKJgq9t8DsokaDX
         TKmX0XKU7XGX4GthuYKSADyoJNLWjPBCC+uvUIXA47t8y81Nl3QAmZZxXFJcGOjHgKNH
         /SutdjrpVqd+W/grqTG1eaNLqbPnUDxzJxtHY4DHnnF9Rk/MkN4CviGrxpkqPxKDdGBS
         pBh7rQEwHnVNA+yOrG1CyElMEBZqTYlZOrGGykOVj3SdTgDoFjHi5WWkXmJfwce0RTDL
         DRmQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=38srYE1M7YZC4gYGoF2tMYWtN7U5tg+NQa8d0HX4bRg=;
        b=r/ZvyF0rach7faTn8EnlB8BMH9JbBc7fl7OL3I9QeopJqU47ehEFsfu3ztnG9+UNbt
         KpllD4hs8ADw4IPsKcnEAPorHDyhltTYz9X3j3I79Vbww2x8br2aR8jcIGvOOYZwFoT1
         2nPfAEDrMEEWbHC/mIHI04qHoRza1VNBQteYOAC+eOfCH+LSy4gvxSX6vnAiMtbZaU20
         2uF1NPMERVlT+ZDu5wHZpdm15UAQAiQ06dOtDb7pEz2/Rh8H+qQMUheW7jH0rF7cg1db
         Ue1japnxGZWC+VZ4O0273njaUcBl2ZCQdJoRAym+6A02n3S+cjGr9fFUoymOLtwj2NQj
         d8bg==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=dwxBssUS;
       arc=pass (i=1 spf=pass spfdomain=vmware.com dkim=pass dkdomain=vmware.com dmarc=pass fromdomain=vmware.com);
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.75.43 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-eopbgr750043.outbound.protection.outlook.com. [40.107.75.43])
        by mx.google.com with ESMTPS id t53si14848653qvc.91.2019.07.16.15.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 15:13:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.75.43 as permitted sender) client-ip=40.107.75.43;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=dwxBssUS;
       arc=pass (i=1 spf=pass spfdomain=vmware.com dkim=pass dkdomain=vmware.com dmarc=pass fromdomain=vmware.com);
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.75.43 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=cxIf1nCXSh5+NtfmRMiw0RqbqFOBp2+yL5M47nthoMsWknwPcGI4r0vnCaz8Q8GM3F1LlFIXP8XdDTNe7SISDfRUvJNendv7Gp8Cux0AdOppBMr/pp7tZJB3DTKkZSjFlVUDj7WsnV3izz5DnBYpglPUlbWzgSAfB/Dexpp+Oc72mpa6BFU9C/tWjS319V2S1HAhmDCEYyJcRx3xc8haMNRMSk2URamgMgRS5zXlfjWeOF266VixYYd2j4E4FG+rlIsw/2HtH6yIKdAMo/vC8Ril5yK8l18+JAP9duJ45SJ/Pv0Pw58jugj6kTq3NQlJkz/ExpmWLswcKrire0UQ0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=38srYE1M7YZC4gYGoF2tMYWtN7U5tg+NQa8d0HX4bRg=;
 b=n+blZNcJbijl1IzA+7GQsjQJYVq1l93rz28ZMpICeFsHsNMhXOdiWrkmWyume8zMwgR7VshoTMVo9KvBvQEEnZ7qAwA09Lk+Si5i22IBcgcaMCOZ2/k/o+s1FFUhi2B5zMVXc8vX2zBT0nSoCyxSIxSKmcmskghVRhyw94VobtfExuhhsm0atOhkwYHhHOmWqoQrh7lZ8ThLlX+i6rGHpch5m4FkBRijp5cHew2uZ1Ay9YLVndTT3tSFiaBXj0WVQhgaSoXeOSGIoEIIGwn4iH8GbyOKVC01ZVq7yNZj8Ffr8SiPUiUlMOTkzri8h2/uHUBdGCJoErtPr6+plgrmNg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=vmware.com;dmarc=pass action=none
 header.from=vmware.com;dkim=pass header.d=vmware.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=38srYE1M7YZC4gYGoF2tMYWtN7U5tg+NQa8d0HX4bRg=;
 b=dwxBssUSF/0Gq3ZIYBXOjttJ/9QGyf7xVIctXEfzZiTfQKjGxe6AmMr2NEXeyJQzlAdTCTzr2d5qCVSAh5UtEoap50OCwQXFWb4HIl2pOkTbqXNN9VgU9fRk3dQf7wSzWuc4XEQzEAM5tM7Rvdd3prksTUZXLcS10mV7axwr2UI=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4088.namprd05.prod.outlook.com (52.135.199.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.8; Tue, 16 Jul 2019 22:13:09 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::e00b:cb41:8ed6:b718]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::e00b:cb41:8ed6:b718%2]) with mapi id 15.20.2094.009; Tue, 16 Jul 2019
 22:13:09 +0000
From: Nadav Amit <namit@vmware.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List
	<linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Borislav
 Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Bjorn
 Helgaas <bhelgaas@google.com>, Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] resource: find_next_iomem_res() improvements
Thread-Topic: [PATCH 0/3] resource: find_next_iomem_res() improvements
Thread-Index:
 AQHVIaTGJ7ym4R/nDEy6A26DLGCJOaag/0oAgAC3tYCAAA1/gIAAOaaAgCwCaoCAAAG+gIAAAbUA
Date: Tue, 16 Jul 2019 22:13:09 +0000
Message-ID: <D463DD43-C09F-4B6E-B1BC-7E1CA5C8A9C4@vmware.com>
References: <20190613045903.4922-1-namit@vmware.com>
 <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
 <9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com>
 <CAPcyv4hstt+0teXPtAq2nwFQaNb9TujgetgWPVMOnYH8JwqGeA@mail.gmail.com>
 <19C3DCA0-823E-46CB-A758-D5F82C5FA3C8@vmware.com>
 <20190716150047.3c13945decc052c077e9ee1e@linux-foundation.org>
 <CAPcyv4iqNHBy-_WbH9XBg5hSqxa=qnkc88EW5=g=-5845jNzsg@mail.gmail.com>
In-Reply-To:
 <CAPcyv4iqNHBy-_WbH9XBg5hSqxa=qnkc88EW5=g=-5845jNzsg@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: faafa783-859b-421f-a6a8-08d70a3ac91d
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR05MB4088;
x-ms-traffictypediagnostic: BYAPR05MB4088:
x-microsoft-antispam-prvs:
 <BYAPR05MB4088AFC03F95879D009CF74AD0CE0@BYAPR05MB4088.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0100732B76
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(4636009)(376002)(366004)(396003)(346002)(39860400002)(136003)(189003)(199004)(51444003)(55674003)(51914003)(71190400001)(71200400001)(6512007)(478600001)(53936002)(6486002)(229853002)(6436002)(6116002)(3846002)(6246003)(86362001)(14454004)(305945005)(8936002)(7736002)(102836004)(186003)(2906002)(26005)(6916009)(36756003)(76176011)(53546011)(7416002)(99286004)(66066001)(4326008)(446003)(81166006)(68736007)(66946007)(76116006)(8676002)(66556008)(54906003)(66476007)(486006)(64756008)(66446008)(316002)(33656002)(6506007)(25786009)(2616005)(5660300002)(11346002)(476003)(81156014)(256004);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4088;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 VQi3FjBGfk4dm5f7+V6Td8vzIr8jbVqm8vrWzgH8ImcTQ5BCNYq+AyfQxbIt6NG8P0J4XIeLoAjGIFHysMrhOfc9jNSgazyZmf1eKhM9P+v1EncS+HBGRhfSl3ypDXLurw8sYpE4kpflujSFYrGBtwH11vzuJwum+Ql15TGS77FTuiJomlPzC7jQskYQ7JueCmYnlgyu8SEsRS6yBYxcn3l/LDWKRIhFqpo5v6yYUAlWBxjfj7isHToC57FzXjsnna7R9jmIv+SYibtrQpf9Oz61KJFn8ulV1EhCPdRYOp21UEzGlEbxmXOg+KeMppv4tXiqhiPH5alIFB5ijpXqS41SN3XRkvyLkAVr9G56N/2qTfW/I6V7iqbB4SLM4J3JJj2vW6ggDyh5QE78efILBU8RvnBZTmejIdBJx+XlgvY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <80E0C06F0F995F4A8372296A4CD33191@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: faafa783-859b-421f-a6a8-08d70a3ac91d
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Jul 2019 22:13:09.3439
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4088
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdWwgMTYsIDIwMTksIGF0IDM6MDcgUE0sIERhbiBXaWxsaWFtcyA8ZGFuLmoud2lsbGlh
bXNAaW50ZWwuY29tPiB3cm90ZToNCj4gDQo+IE9uIFR1ZSwgSnVsIDE2LCAyMDE5IGF0IDM6MDEg
UE0gQW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4gd3JvdGU6DQo+PiBP
biBUdWUsIDE4IEp1biAyMDE5IDIxOjU2OjQzICswMDAwIE5hZGF2IEFtaXQgPG5hbWl0QHZtd2Fy
ZS5jb20+IHdyb3RlOg0KPj4gDQo+Pj4+IC4uLmFuZCBpcyBjb25zdGFudCBmb3IgdGhlIGxpZmUg
b2YgdGhlIGRldmljZSBhbmQgYWxsIHN1YnNlcXVlbnQgbWFwcGluZ3MuDQo+Pj4+IA0KPj4+Pj4g
UGVyaGFwcyB5b3Ugd2FudCB0byBjYWNoZSB0aGUgY2FjaGFiaWxpdHktbW9kZSBpbiB2bWEtPnZt
X3BhZ2VfcHJvdCAod2hpY2ggSQ0KPj4+Pj4gc2VlIGJlaW5nIGRvbmUgaW4gcXVpdGUgYSBmZXcg
Y2FzZXMpLCBidXQgSSBkb27igJl0IGtub3cgdGhlIGNvZGUgd2VsbCBlbm91Z2gNCj4+Pj4+IHRv
IGJlIGNlcnRhaW4gdGhhdCBldmVyeSB2bWEgc2hvdWxkIGhhdmUgYSBzaW5nbGUgcHJvdGVjdGlv
biBhbmQgdGhhdCBpdA0KPj4+Pj4gc2hvdWxkIG5vdCBjaGFuZ2UgYWZ0ZXJ3YXJkcy4NCj4+Pj4g
DQo+Pj4+IE5vLCBJJ20gdGhpbmtpbmcgdGhpcyB3b3VsZCBuYXR1cmFsbHkgZml0IGFzIGEgcHJv
cGVydHkgaGFuZ2luZyBvZmYgYQ0KPj4+PiAnc3RydWN0IGRheF9kZXZpY2UnLCBhbmQgdGhlbiBj
cmVhdGUgYSB2ZXJzaW9uIG9mIHZtZl9pbnNlcnRfbWl4ZWQoKQ0KPj4+PiBhbmQgdm1mX2luc2Vy
dF9wZm5fcG1kKCkgdGhhdCBieXBhc3MgdHJhY2tfcGZuX2luc2VydCgpIHRvIGluc2VydCB0aGF0
DQo+Pj4+IHNhdmVkIHZhbHVlLg0KPj4+IA0KPj4+IFRoYW5rcyBmb3IgdGhlIGRldGFpbGVkIGV4
cGxhbmF0aW9uLiBJ4oCZbGwgZ2l2ZSBpdCBhIHRyeSAodGhlIG1vbWVudCBJIGZpbmQNCj4+PiBz
b21lIGZyZWUgdGltZSkuIEkgc3RpbGwgdGhpbmsgdGhhdCBwYXRjaCAyLzMgaXMgYmVuZWZpY2lh
bCwgYnV0IGJhc2VkIG9uDQo+Pj4geW91ciBmZWVkYmFjaywgcGF0Y2ggMy8zIHNob3VsZCBiZSBk
cm9wcGVkLg0KPj4gDQo+PiBJdCBoYXMgYmVlbiBhIHdoaWxlLiAgV2hhdCBzaG91bGQgd2UgZG8g
d2l0aA0KPj4gDQo+PiByZXNvdXJjZS1maXgtbG9ja2luZy1pbi1maW5kX25leHRfaW9tZW1fcmVz
LnBhdGNoDQo+IA0KPiBUaGlzIG9uZSBsb29rcyBvYnZpb3VzbHkgY29ycmVjdCB0byBtZSwgeW91
IGNhbiBhZGQ6DQo+IA0KPiBSZXZpZXdlZC1ieTogRGFuIFdpbGxpYW1zIDxkYW4uai53aWxsaWFt
c0BpbnRlbC5jb20+DQo+IA0KPj4gcmVzb3VyY2UtYXZvaWQtdW5uZWNlc3NhcnktbG9va3Vwcy1p
bi1maW5kX25leHRfaW9tZW1fcmVzLnBhdGNoDQo+IA0KPiBUaGlzIG9uZSBpcyBhIGdvb2QgYnVn
IHJlcG9ydCB0aGF0IHdlIG5lZWQgdG8gZ28gZml4IHBncHJvdCBsb29rdXBzDQo+IGZvciBkYXgs
IGJ1dCBJIGRvbid0IHRoaW5rIHdlIG5lZWQgdG8gaW5jcmVhc2UgdGhlIHRyaWNraW5lc3Mgb2Yg
dGhlDQo+IGNvcmUgcmVzb3VyY2UgbG9va3VwIGNvZGUgaW4gdGhlIG1lYW50aW1lLg0KDQpJIHRo
aW5rIHRoYXQgdHJhdmVyc2luZyBiaWcgcGFydHMgb2YgdGhlIHRyZWUgdGhhdCBhcmUga25vd24g
dG8gYmUNCmlycmVsZXZhbnQgaXMgd2FzdGVmdWwgbm8gbWF0dGVyIHdoYXQsIGFuZCB0aGlzIGNv
ZGUgaXMgdXNlZCBpbiBvdGhlciBjYXNlcy4NCg0KSSBkb27igJl0IHRoaW5rIHRoZSBuZXcgY29k
ZSBpcyBzbyB0cmlja3kgLSBjYW4geW91IHBvaW50IHRvIHRoZSBwYXJ0IG9mIHRoZQ0KY29kZSB0
aGF0IHlvdSBmaW5kIHRyaWNreT8NCg0KDQo=

