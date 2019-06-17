Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EBCFC31E5C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:14:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB65820863
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:14:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="mDtEP6G1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB65820863
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 452CD6B0005; Mon, 17 Jun 2019 15:14:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 403058E0005; Mon, 17 Jun 2019 15:14:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CA8E8E0001; Mon, 17 Jun 2019 15:14:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B83F6B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:14:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o4so9993607qko.8
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:14:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=8K8T3TIgSicvMlb2LLZx8h0iRKdQzJzV/bH5/7XtmL0=;
        b=O8xLK+Bsbso3lRQDaj+474HcVoIvZG6LqZeIl+t8tCUrqoPxGO6Mj+AnMyW7uXw92R
         IlHmpIjUfAsAUzpZe48rSoBmQLgEo4Gv5eq3ErEH4YwkvV6EaK7eJPOt/rbjOqv5Qfq7
         2r7pJHUGgP5bUNy/FN55yTaGv6OKQLWiOmeTKN2EVzRdTNli+zBeqUpyLiAxSF1RKaM/
         ZsRIFmNW7LFs6JSVJlvmL/j/Rtb6c6Sd7sMdWcK6X50injCK8Q7uHTd0NPoamBcY4Wp0
         8Zg+b5e79HIv7ffcautdLpZkSklTAH4OAPukVBifUdggi0S2m3XX3dImttyDMPCoiKuj
         ZI2w==
X-Gm-Message-State: APjAAAVVA8ccJizjeCwbZW6cA7KpoAqMEFAGvXt4z5o9vhA/DSiorcjd
	A7u/fZUy70mu9q5WX3x5WJKnLL8gcHSSSoJcSlKpSAr6A04LDugxBXndT5EonGBdn2/nKKIgaFc
	KuhkJUJylCsUTh5lx3qYPiTp3692Xf/gwzBACnyW31RT+VhyXiNRTHGKbyyms76YqqA==
X-Received: by 2002:a37:92c6:: with SMTP id u189mr89043079qkd.29.1560798895788;
        Mon, 17 Jun 2019 12:14:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5fHkf9pw9TsVlcpKckOXGj+6Da7+Jn8uccUb+L90S6ebP9yKGckG0NLwt1V0fYgUTHJd6
X-Received: by 2002:a37:92c6:: with SMTP id u189mr89043040qkd.29.1560798895240;
        Mon, 17 Jun 2019 12:14:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560798895; cv=none;
        d=google.com; s=arc-20160816;
        b=0uMp/P6OzKnJV2hTXurZmyrYKSW3h3B1yeOqo568RXXkywi3LUcCtdUItzAbig4A9p
         29lyUtnRgfvwaePdnAyZMOrQqxKp/RfDpb/TkFqkzdikFKxITMWCrwSlwBdZpa/bd1XY
         5y6oT0Fympnm8qGuSI0+sq7KZ0Ef4c1rqWSHNq+CKmMW2kCssF4JeDBNW+/9AcPoHzJQ
         MEAIrZBGf7qvmGOk0vsWbRRt0Me+tyYzXXAXhXhIfOzQVfD4u6wuaAQ8r+6vFsXW26PZ
         9VAjRqhB8HgrECUGPw1iRe9uyYjovfvdHbBAeXlHGhV48eqxru90p5Qo1fQt7dKC+X0S
         g/Xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=8K8T3TIgSicvMlb2LLZx8h0iRKdQzJzV/bH5/7XtmL0=;
        b=VyzOg9op1H+DwX+Yn9QRGuriv3/UKeE68U3W33h6wgGjbWNPdkFSUzli+p2wUTckBE
         5kI4VXt8qFsMRL6PYc/X1wA7eD1l7aQ1ErvMw4omTnYcGpSgEZlSx3Ut3q0pQXN01nVZ
         KTbgg/6c8OwnCGDIMJx4VV3xomb1epzjRvL7i6k5ko71IY0V8kcP46Jm45IfrQEgafsa
         aBNKRxvyp7V+2MNysLpCKdtQzp0QEIKRwbzFmCBq+n9eTZL7iuOIMC/7bG/kSEkL7wrF
         YPWXOc2gHeR1m2CvtU7eprgxFIIUNwZ7+IG1/cmgNDqTLLyAx5q6qjVTPhPFcrZysyc0
         ipdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=mDtEP6G1;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.69.59 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (mail-eopbgr690059.outbound.protection.outlook.com. [40.107.69.59])
        by mx.google.com with ESMTPS id a19si8068517qkb.223.2019.06.17.12.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 12:14:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.69.59 as permitted sender) client-ip=40.107.69.59;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector2 header.b=mDtEP6G1;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.69.59 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector2;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=8K8T3TIgSicvMlb2LLZx8h0iRKdQzJzV/bH5/7XtmL0=;
 b=mDtEP6G1qjO6uAS0twbEcnruaBm3KXxVJ6qoHYrRU5JupaYRyrZnXRCWZTL9ZRcxi+ZVQ8CIXXZWXmxr+fYnlw2fPpYh81i8sOKnv0H0BpJBBYKdIUImcixIPJ/4qhmdq+s2SGecrbpp8bs/DChMtJxvL74AmbEK6bjqzoGX4Yg=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4056.namprd05.prod.outlook.com (52.135.199.33) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.7; Mon, 17 Jun 2019 19:14:53 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::f493:3bba:aabf:dd58%7]) with mapi id 15.20.2008.007; Mon, 17 Jun 2019
 19:14:53 +0000
From: Nadav Amit <namit@vmware.com>
To: Sasha Levin <sashal@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>
CC: Andrew Morton <akpm@linux-foundation.org>, LKML
	<linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, Borislav Petkov
	<bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra
	<peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Dan
 Williams <dan.j.williams@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
	Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/3] resource: Fix locking in find_next_iomem_res()
Thread-Topic: [PATCH 1/3] resource: Fix locking in find_next_iomem_res()
Thread-Index: AQHVJUDxxzjy50ovskyMqR/CoOwaLQ==
Date: Mon, 17 Jun 2019 19:14:53 +0000
Message-ID: <549284C3-6A1C-4434-B716-FF9B0C87EE45@vmware.com>
References: <20190613045903.4922-2-namit@vmware.com>
 <20190615221557.CD1492183F@mail.kernel.org>
In-Reply-To: <20190615221557.CD1492183F@mail.kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.1]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2a2424f7-1b98-4854-f624-08d6f35813cc
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600148)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR05MB4056;
x-ms-traffictypediagnostic: BYAPR05MB4056:
x-microsoft-antispam-prvs:
 <BYAPR05MB4056D54D037296F4558E689AD0EB0@BYAPR05MB4056.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:3513;
x-forefront-prvs: 0071BFA85B
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(39860400002)(366004)(396003)(376002)(136003)(346002)(199004)(189003)(14454004)(71190400001)(6512007)(6116002)(3846002)(81166006)(64756008)(7736002)(6486002)(305945005)(6436002)(71200400001)(81156014)(8936002)(53936002)(229853002)(14444005)(186003)(102836004)(99286004)(76116006)(8676002)(53546011)(256004)(6506007)(76176011)(26005)(73956011)(66946007)(486006)(36756003)(476003)(446003)(5660300002)(33656002)(2616005)(11346002)(316002)(66556008)(68736007)(66066001)(2906002)(7416002)(478600001)(4326008)(86362001)(54906003)(25786009)(6246003)(110136005)(66476007)(66446008);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4056;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 S9IQ6kuBQZ7KMNxRKL/WFB1jmW3UyoU3t8BHsy7uxC3ecxyGbajKTnIDBR+tPU+mMsGFR2unbpB5iBsl85DvvepGEieojsNmUJ5albruLY+33kndDKFB4CaQU3lQNuN8c6C3VxiqP26OeqCh7uaBUOIOmwdhbO+7WK5nA/Y2D7VSVxFAZOgKfAn6O8GSJdFW9XEG5Ph1KYS8UpKFWANWPZD8UKOIWssoE3RXEG4TKRXzKfHClI02Qz6GsnXNEX9La16y0+AmHyLwfg1AuNzDGcSxmTIqdXZ+b7QhV4bURwCRACEh9XpIQOMHdFe1mo0WCtVv2cpeyVo3oORD5qsBnUenQWl5sfg7BQCHfHUyHlPCySMPs5X2Uvm56wACX8GYYD94MlaMV3i11Gf6asCUuoBL/mGW/GzVL4OMbiG44cM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <8E477B3DEBEC0A41904E840C4D6E1CF8@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2a2424f7-1b98-4854-f624-08d6f35813cc
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jun 2019 19:14:53.3285
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: namit@vmware.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4056
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

PiBPbiBKdW4gMTUsIDIwMTksIGF0IDM6MTUgUE0sIFNhc2hhIExldmluIDxzYXNoYWxAa2VybmVs
Lm9yZz4gd3JvdGU6DQo+IA0KPiBIaSwNCj4gDQo+IFtUaGlzIGlzIGFuIGF1dG9tYXRlZCBlbWFp
bF0NCj4gDQo+IFRoaXMgY29tbWl0IGhhcyBiZWVuIHByb2Nlc3NlZCBiZWNhdXNlIGl0IGNvbnRh
aW5zIGEgIkZpeGVzOiIgdGFnLA0KPiBmaXhpbmcgY29tbWl0OiBmZjNjYzk1MmQzZjAgcmVzb3Vy
Y2U6IEFkZCByZW1vdmVfcmVzb3VyY2UgaW50ZXJmYWNlLg0KPiANCj4gVGhlIGJvdCBoYXMgdGVz
dGVkIHRoZSBmb2xsb3dpbmcgdHJlZXM6IHY1LjEuOSwgdjQuMTkuNTAsIHY0LjE0LjEyNSwgdjQu
OS4xODEuDQo+IA0KPiB2NS4xLjk6IEJ1aWxkIE9LIQ0KPiB2NC4xOS41MDogRmFpbGVkIHRvIGFw
cGx5ISBQb3NzaWJsZSBkZXBlbmRlbmNpZXM6DQo+ICAgIDAxMGE5M2JmOTdjNyAoInJlc291cmNl
OiBGaXggZmluZF9uZXh0X2lvbWVtX3JlcygpIGl0ZXJhdGlvbiBpc3N1ZSIpDQo+ICAgIGE5ODk1
OWZkYmRhMSAoInJlc291cmNlOiBJbmNsdWRlIHJlc291cmNlIGVuZCBpbiB3YWxrXyooKSBpbnRl
cmZhY2VzIikNCj4gDQo+IHY0LjE0LjEyNTogRmFpbGVkIHRvIGFwcGx5ISBQb3NzaWJsZSBkZXBl
bmRlbmNpZXM6DQo+ICAgIDAxMGE5M2JmOTdjNyAoInJlc291cmNlOiBGaXggZmluZF9uZXh0X2lv
bWVtX3JlcygpIGl0ZXJhdGlvbiBpc3N1ZSIpDQo+ICAgIDBlNGMxMmI0NWFhOCAoIng4Ni9tbSwg
cmVzb3VyY2U6IFVzZSBQQUdFX0tFUk5FTCBwcm90ZWN0aW9uIGZvciBpb3JlbWFwIG9mIG1lbW9y
eSBwYWdlcyIpDQo+ICAgIDFkMmU3MzNiMTNiNCAoInJlc291cmNlOiBQcm92aWRlIHJlc291cmNl
IHN0cnVjdCBpbiByZXNvdXJjZSB3YWxrIGNhbGxiYWNrIikNCj4gICAgNGFjMmFlZDgzN2NiICgi
cmVzb3VyY2U6IENvbnNvbGlkYXRlIHJlc291cmNlIHdhbGtpbmcgY29kZSIpDQo+ICAgIGE5ODk1
OWZkYmRhMSAoInJlc291cmNlOiBJbmNsdWRlIHJlc291cmNlIGVuZCBpbiB3YWxrXyooKSBpbnRl
cmZhY2VzIikNCj4gDQo+IHY0LjkuMTgxOiBGYWlsZWQgdG8gYXBwbHkhIFBvc3NpYmxlIGRlcGVu
ZGVuY2llczoNCj4gICAgMDEwYTkzYmY5N2M3ICgicmVzb3VyY2U6IEZpeCBmaW5kX25leHRfaW9t
ZW1fcmVzKCkgaXRlcmF0aW9uIGlzc3VlIikNCj4gICAgMGU0YzEyYjQ1YWE4ICgieDg2L21tLCBy
ZXNvdXJjZTogVXNlIFBBR0VfS0VSTkVMIHByb3RlY3Rpb24gZm9yIGlvcmVtYXAgb2YgbWVtb3J5
IHBhZ2VzIikNCj4gICAgMWQyZTczM2IxM2I0ICgicmVzb3VyY2U6IFByb3ZpZGUgcmVzb3VyY2Ug
c3RydWN0IGluIHJlc291cmNlIHdhbGsgY2FsbGJhY2siKQ0KPiAgICA0YWMyYWVkODM3Y2IgKCJy
ZXNvdXJjZTogQ29uc29saWRhdGUgcmVzb3VyY2Ugd2Fsa2luZyBjb2RlIikNCj4gICAgNjBmZTM5
MTBiYjAyICgia2V4ZWNfZmlsZTogQWxsb3cgYXJjaC1zcGVjaWZpYyBtZW1vcnkgd2Fsa2luZyBm
b3Iga2V4ZWNfYWRkX2J1ZmZlciIpDQo+ICAgIGEwNDU4Mjg0ZjA2MiAoInBvd2VycGM6IEFkZCBz
dXBwb3J0IGNvZGUgZm9yIGtleGVjX2ZpbGVfbG9hZCgpIikNCj4gICAgYTk4OTU5ZmRiZGExICgi
cmVzb3VyY2U6IEluY2x1ZGUgcmVzb3VyY2UgZW5kIGluIHdhbGtfKigpIGludGVyZmFjZXMiKQ0K
PiAgICBkYTY2NTg4NTliOWMgKCJwb3dlcnBjOiBDaGFuZ2UgcGxhY2VzIHVzaW5nIENPTkZJR19L
RVhFQyB0byB1c2UgQ09ORklHX0tFWEVDX0NPUkUgaW5zdGVhZC4iKQ0KPiAgICBlYzJiOWJmYWFj
NDQgKCJrZXhlY19maWxlOiBDaGFuZ2Uga2V4ZWNfYWRkX2J1ZmZlciB0byB0YWtlIGtleGVjX2J1
ZiBhcyBhcmd1bWVudC4iKQ0KDQpJcyB0aGVyZSBhIHJlYXNvbiAwMTBhOTNiZjk3YzcgKCJyZXNv
dXJjZTogRml4IGZpbmRfbmV4dF9pb21lbV9yZXMoKQ0KaXRlcmF0aW9uIGlzc3Vl4oCdKSB3YXMg
bm90IGJhY2twb3J0ZWQ/DQoNCkZvciA0LjE5IHRoZSBmb2xsb3dpbmcgcGFzc2VzIGNvbXBpbGF0
aW9uLg0KDQotLSA+OCAtLQ0KDQpGcm9tOiBOYWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPg0K
U3ViamVjdDogW1BBVENIXSByZXNvdXJjZTogRml4IGxvY2tpbmcgaW4gZmluZF9uZXh0X2lvbWVt
X3JlcygpDQoNClNpbmNlIHJlc291cmNlcyBjYW4gYmUgcmVtb3ZlZCwgbG9ja2luZyBzaG91bGQg
ZW5zdXJlIHRoYXQgdGhlIHJlc291cmNlDQppcyBub3QgcmVtb3ZlZCB3aGlsZSBhY2Nlc3Npbmcg
aXQuIEhvd2V2ZXIsIGZpbmRfbmV4dF9pb21lbV9yZXMoKSBkb2VzDQpub3QgaG9sZCB0aGUgbG9j
ayB3aGlsZSBjb3B5aW5nIHRoZSBkYXRhIG9mIHRoZSByZXNvdXJjZS4gS2VlcCBob2xkaW5nDQp0
aGUgbG9jayB3aGlsZSB0aGUgZGF0YSBpcyBjb3BpZWQuDQoNCkZpeGVzOiBmZjNjYzk1MmQzZjAw
ICgicmVzb3VyY2U6IEFkZCByZW1vdmVfcmVzb3VyY2UgaW50ZXJmYWNlIikNCkNjOiBzdGFibGVA
dmdlci5rZXJuZWwub3JnDQpDYzogQm9yaXNsYXYgUGV0a292IDxicEBzdXNlLmRlPg0KQ2M6IFRv
c2hpIEthbmkgPHRvc2hpLmthbmlAaHBlLmNvbT4NCkNjOiBQZXRlciBaaWpsc3RyYSA8cGV0ZXJ6
QGluZnJhZGVhZC5vcmc+DQpDYzogRGF2ZSBIYW5zZW4gPGRhdmUuaGFuc2VuQGxpbnV4LmludGVs
LmNvbT4NCkNjOiBEYW4gV2lsbGlhbXMgPGRhbi5qLndpbGxpYW1zQGludGVsLmNvbT4NCkNjOiBC
am9ybiBIZWxnYWFzIDxiaGVsZ2Fhc0Bnb29nbGUuY29tPg0KQ2M6IEluZ28gTW9sbmFyIDxtaW5n
b0BrZXJuZWwub3JnPg0KU2lnbmVkLW9mZi1ieTogTmFkYXYgQW1pdCA8bmFtaXRAdm13YXJlLmNv
bT4NCi0tLQ0KIGtlcm5lbC9yZXNvdXJjZS5jIHwgMTMgKysrKysrKysrLS0tLQ0KIDEgZmlsZSBj
aGFuZ2VkLCA5IGluc2VydGlvbnMoKyksIDQgZGVsZXRpb25zKC0pDQoNCmRpZmYgLS1naXQgYS9r
ZXJuZWwvcmVzb3VyY2UuYyBiL2tlcm5lbC9yZXNvdXJjZS5jDQppbmRleCAzMGUxYmM2ODUwM2Iu
LjAyMDFmZWFkZTdkNSAxMDA2NDQNCi0tLSBhL2tlcm5lbC9yZXNvdXJjZS5jDQorKysgYi9rZXJu
ZWwvcmVzb3VyY2UuYw0KQEAgLTMzMSw2ICszMzEsNyBAQCBzdGF0aWMgaW50IGZpbmRfbmV4dF9p
b21lbV9yZXMoc3RydWN0IHJlc291cmNlICpyZXMsIHVuc2lnbmVkIGxvbmcgZGVzYywNCiAJcmVz
b3VyY2Vfc2l6ZV90IHN0YXJ0LCBlbmQ7DQogCXN0cnVjdCByZXNvdXJjZSAqcDsNCiAJYm9vbCBz
aWJsaW5nX29ubHkgPSBmYWxzZTsNCisJaW50IHIgPSAwOw0KIA0KIAlCVUdfT04oIXJlcyk7DQog
DQpAQCAtMzU2LDkgKzM1NywxMSBAQCBzdGF0aWMgaW50IGZpbmRfbmV4dF9pb21lbV9yZXMoc3Ry
dWN0IHJlc291cmNlICpyZXMsIHVuc2lnbmVkIGxvbmcgZGVzYywNCiAJCQlicmVhazsNCiAJfQ0K
IA0KLQlyZWFkX3VubG9jaygmcmVzb3VyY2VfbG9jayk7DQotCWlmICghcCkNCi0JCXJldHVybiAt
MTsNCisJaWYgKCFwKSB7DQorCQlyID0gLTE7DQorCQlnb3RvIG91dDsNCisJfQ0KKw0KIAkvKiBj
b3B5IGRhdGEgKi8NCiAJaWYgKHJlcy0+c3RhcnQgPCBwLT5zdGFydCkNCiAJCXJlcy0+c3RhcnQg
PSBwLT5zdGFydDsNCkBAIC0zNjYsNyArMzY5LDkgQEAgc3RhdGljIGludCBmaW5kX25leHRfaW9t
ZW1fcmVzKHN0cnVjdCByZXNvdXJjZSAqcmVzLCB1bnNpZ25lZCBsb25nIGRlc2MsDQogCQlyZXMt
PmVuZCA9IHAtPmVuZDsNCiAJcmVzLT5mbGFncyA9IHAtPmZsYWdzOw0KIAlyZXMtPmRlc2MgPSBw
LT5kZXNjOw0KLQlyZXR1cm4gMDsNCitvdXQ6DQorCXJlYWRfdW5sb2NrKCZyZXNvdXJjZV9sb2Nr
KTsNCisJcmV0dXJuIHI7DQogfQ0KIA0KIHN0YXRpYyBpbnQgX193YWxrX2lvbWVtX3Jlc19kZXNj
KHN0cnVjdCByZXNvdXJjZSAqcmVzLCB1bnNpZ25lZCBsb25nIGRlc2MsDQotLSANCjIuMTcuMQ==

