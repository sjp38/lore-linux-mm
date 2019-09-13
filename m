Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E839C4CEC9
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 19:23:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A68BA206A5
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 19:23:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="jIMOWvLB";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="C6RMp3X6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A68BA206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 006416B0005; Fri, 13 Sep 2019 15:23:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF9DA6B0006; Fri, 13 Sep 2019 15:23:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBF6C6B0007; Fri, 13 Sep 2019 15:23:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0086.hostedemail.com [216.40.44.86])
	by kanga.kvack.org (Postfix) with ESMTP id B47826B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 15:23:21 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5B511181AC9B4
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 19:23:21 +0000 (UTC)
X-FDA: 75930871002.21.point98_576eb54c2c130
X-HE-Tag: point98_576eb54c2c130
X-Filterd-Recvd-Size: 11850
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 19:23:20 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x8DJKZE7003976;
	Fri, 13 Sep 2019 12:23:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=zO2IDzlmhH58pTDChT04xvVfUEzaWNnY9P08lqUvDzk=;
 b=jIMOWvLBjw6yCwnBQs8X+qiYomZ2UtSpvL1+qbjiNyhhKd2rVONiJeZDDesfcptKSKrI
 B/qIrsuNUF/gK+LTZ3sNFq2UNba4FJ7uNTCTRe8jHrA2xlkNxlB7d3MFhnTvUI+EPUHL
 KLCZt3lvnnR+uffz6PaymUFfk/do8ei7ysQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2v0ev4rqgn-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 13 Sep 2019 12:23:17 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 13 Sep 2019 12:23:15 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 13 Sep 2019 12:23:14 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=RZtbWbmuYE88Myi9/AghO8ZZJuOcRFPPTfCLAb5yv7OPIiCok1RmArB1jKKYQ4X8qj6ytx22DKIHWG8OVgcUcX8PbwcFTeS/pGlkswssxGKtruIpSjYRxdBLVH4uodeIOXLmppziGoGOitgO7XK1tllqP1JN76MlewEDcZZkfg50LbP5FZ1pDyOp7XhPr31Pex9jcoRD6RsHsGqQFPtFXp4NyX0jUO6E8n8dlwmFYxYuGGh035ERu7ITrl9lCo18toeuuJLaI6TQUDQZ6Mjzs/igunrhAntqL5TOUk2g5jwFXsulJtZ5QZVoaA/uu1slAcT3Caq2GoV6JCorMB4V1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=zO2IDzlmhH58pTDChT04xvVfUEzaWNnY9P08lqUvDzk=;
 b=ao+wgnJyu3Vt4Nx8HgxhnrXF01xLzzO0HvrJRmt4TO+LeGEIQH078iadH2d20Y8ixqGSyaqP873ZixAimJpSDb6UsqPEDSIB872q5xfBx+m+4mDdJecd4y0T6ODzgDHC/1eUGXw7HGBSreCISQR8sqQj7XAD+VY4IWiKNoKdc1rGBZUdPebGXOK8MNT/N+/8h9NCM6BNObBUtvv309GaK3Tn3K4G+1H2fz+EhcVjfv9hI76VC6+iUaMuJPSZM185aDn9RGTZi2VeEZS9KipsQkzLEo+y102fMiF2PLau/D3J3+/XVF1xxWeBojeQ7oLaD9HAZTXgQK2JDNac4rpZ7w==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=zO2IDzlmhH58pTDChT04xvVfUEzaWNnY9P08lqUvDzk=;
 b=C6RMp3X6m3gFbQhMdZ8xOdNg7HTWcyfBvKd5K+/w4rCxfyb2pZGg3e50A8qHJ0OnA0EJejry4alwHS9wZVWnvLF1MrFWWBenZDaO4BMVKbuPtyLXT7+43VfkRuYsIkT9RcGzDaNMlgaXC+3J5IBdJVa8dXTiHFX3WpK9PeqjoNo=
Received: from BYAPR15MB3432.namprd15.prod.outlook.com (20.179.59.152) by
 BYAPR15MB3461.namprd15.prod.outlook.com (20.179.59.225) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.15; Fri, 13 Sep 2019 19:23:13 +0000
Received: from BYAPR15MB3432.namprd15.prod.outlook.com
 ([fe80::1097:b86e:429:bdf0]) by BYAPR15MB3432.namprd15.prod.outlook.com
 ([fe80::1097:b86e:429:bdf0%7]) with mapi id 15.20.2263.016; Fri, 13 Sep 2019
 19:23:13 +0000
From: Lucian Grijincu <lucian@fb.com>
To: Souptick Joarder <jrdr.linux@gmail.com>
CC: Linux-MM <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Michal Hocko <mhocko@kernel.org>,
        "Andrew
 Morton" <akpm@linux-foundation.org>,
        Rik van Riel <riel@fb.com>, "Roman
 Gushchin" <guro@fb.com>
Subject: Re: [PATCH] mm: memory: fix /proc/meminfo reporting for MLOCK_ONFAULT
Thread-Topic: [PATCH] mm: memory: fix /proc/meminfo reporting for
 MLOCK_ONFAULT
Thread-Index: AQHVacBoQK8XnWvylESFsx+V2BgP2KcpdjQAgAASUYA=
Date: Fri, 13 Sep 2019 19:23:13 +0000
Message-ID: <5F4F6302-98DD-4309-9B11-3DE280E0C484@fb.com>
References: <20190912231820.590276-1-lucian@fb.com>
 <CAFqt6zaVAuvoHveT9YeU5GWjWPZBeTXWnRjmHEazxZSUctT7+Q@mail.gmail.com>
In-Reply-To: <CAFqt6zaVAuvoHveT9YeU5GWjWPZBeTXWnRjmHEazxZSUctT7+Q@mail.gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/10.1d.0.190908
x-originating-ip: [2620:10d:c090:200::2:e14a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 72d85eea-886d-4825-a719-08d7387fd27c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600166)(711020)(4605104)(1401327)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB3461;
x-ms-traffictypediagnostic: BYAPR15MB3461:
x-ms-exchange-purlcount: 2
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <BYAPR15MB3461F920F767B9A4BDBD1633ADB30@BYAPR15MB3461.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 0159AC2B97
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(136003)(39860400002)(376002)(366004)(396003)(189003)(199004)(25786009)(66476007)(14454004)(102836004)(86362001)(476003)(478600001)(7736002)(4326008)(53546011)(6246003)(305945005)(6506007)(2616005)(229853002)(76176011)(486006)(81166006)(8676002)(8936002)(46003)(81156014)(2906002)(54906003)(58126008)(186003)(6306002)(53936002)(6512007)(64756008)(66556008)(33656002)(6916009)(66946007)(66446008)(76116006)(6116002)(14444005)(966005)(316002)(256004)(36756003)(91956017)(11346002)(99286004)(71200400001)(71190400001)(6486002)(446003)(5660300002)(6436002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3461;H:BYAPR15MB3432.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: /JTVNpGy4JsrHHAmbuFh7sjWRbcJ7omxPh4dHGuTnkjC2/M5E5T7frZGbsC0X5aAdOAZ+uo4cRoHfaz4cq3HGLMUR1k02KY6I7Khz5PwYX03rjcJNm93gDVUOZelxVkOMrPJWHyHz9+plC6fUeTTgsVzqDotEUbRBH7I8QGM5z1lH7UX8pMDoPGGn6Px4MZuRmvhBn/hfYqZvICFRnjiopJl69FDYYK2OA1Zohr0lvf+e9eenBi1laSygNuoVnKFrlMycK15dZqK5biCSvHR5jjh+uEWtjc3UR9U9wGMfRKbNe9Fp4uW2323MsTBt0rZ68OYx9HnfnXZ/6Zf/3xqan92sHxpKrDNRyeMpyImxVInzMMwEmtXfinOw8z+g6vtuY9BojMlBr9XgnA6AAXl2ByBgQR9pWe5b9EsiZXK5Bk=
Content-Type: text/plain; charset="utf-8"
Content-ID: <47F3A5C817C81948A592561CB60DDBA0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 72d85eea-886d-4825-a719-08d7387fd27c
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Sep 2019 19:23:13.7102
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: ass7+jPpr32fYTxYlQFIicp0lJrJWbmKhm1k96sRXGIQUrFscJ1/Q0G9mFNNp0GG
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3461
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-13_09:2019-09-11,2019-09-13 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 spamscore=0 mlxscore=0
 lowpriorityscore=0 adultscore=0 mlxlogscore=999 impostorscore=0
 suspectscore=0 clxscore=1011 priorityscore=1501 bulkscore=0 phishscore=0
 malwarescore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1908290000 definitions=main-1909130197
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gOS8xMy8xOSwgMDQ6MTgsICJTb3VwdGljayBKb2FyZGVyIiA8anJkci5saW51eEBnbWFpbC5j
b20+IHdyb3RlOg0KDQogICAgT24gRnJpLCBTZXAgMTMsIDIwMTkgYXQgNDo0OSBBTSBMdWNpYW4g
QWRyaWFuIEdyaWppbmN1IDxsdWNpYW5AZmIuY29tPiB3cm90ZToNCiAgICA+DQogICAgPiBBcyBw
YWdlcyBhcmUgZmF1bHRlZCBpbiBNTE9DS19PTkZBVUxUIGNvcnJlY3RseSB1cGRhdGVzDQogICAg
PiAvcHJvYy9zZWxmL3NtYXBzLCBidXQgZG9lc24ndCB1cGRhdGUgL3Byb2MvbWVtaW5mbydzIE1s
b2NrZWQgZmllbGQuDQogICAgPg0KICAgID4gLSBCZWZvcmUgdGhpcyAvcHJvYy9tZW1pbmZvIGZp
ZWxkcyBkaWRuJ3QgY2hhbmdlIGFzIHBhZ2VzIHdlcmUgZmF1bHRlZCBpbjoNCiAgICA+IGRpZmYg
LS1naXQgYS9tbS9tZW1vcnkuYyBiL21tL21lbW9yeS5jDQogICAgPiBpbmRleCBlMGMyMzJmZTgx
ZDkuLjdlOGRjM2VkNGU4OSAxMDA2NDQNCiAgICA+IC0tLSBhL21tL21lbW9yeS5jDQogICAgPiAr
KysgYi9tbS9tZW1vcnkuYw0KICAgID4gQEAgLTMzMTEsNiArMzMxMSw5IEBAIHZtX2ZhdWx0X3Qg
YWxsb2Nfc2V0X3B0ZShzdHJ1Y3Qgdm1fZmF1bHQgKnZtZiwgc3RydWN0IG1lbV9jZ3JvdXAgKm1l
bWNnLA0KICAgID4gICAgICAgICB9IGVsc2Ugew0KICAgID4gICAgICAgICAgICAgICAgIGluY19t
bV9jb3VudGVyX2Zhc3Qodm1hLT52bV9tbSwgbW1fY291bnRlcl9maWxlKHBhZ2UpKTsNCiAgICA+
ICAgICAgICAgICAgICAgICBwYWdlX2FkZF9maWxlX3JtYXAocGFnZSwgZmFsc2UpOw0KICAgID4g
KyAgICAgICAgICAgICAgIGlmICgodm1hLT52bV9mbGFncyAmIChWTV9MT0NLRUQgfCBWTV9TUEVD
SUFMKSkgPT0gVk1fTE9DS0VEICYmDQogICAgPiArICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICFQYWdlVHJhbnNDb21wb3VuZChwYWdlKSkNCiAgICANCiAgICBEbyB3ZSBuZWVkIHRvIGNo
ZWNrIGFnYWluc3QgVk1fU1BFQ0lBTCA/DQogICAgDQpJIHRoaW5rIHlvdSdyZSByaWdodC4gbWxv
Y2svbWxvY2syIGFscmVhZHkgY2hlY2tzIGFuZCBkb2Vzbid0IHNldCBWTV9MT0NLRUQgaWYgVk1f
U1BFQ0lBTCBpcyBzZXQ6IGh0dHBzOi8vZ2l0aHViLmNvbS90b3J2YWxkcy9saW51eC9ibG9iL3Y1
LjIvbW0vbWxvY2suYyNMNTE5LUw1MzMNCg0KLyoNCiAqIG1sb2NrX2ZpeHVwICAtIGhhbmRsZSBt
bG9ja1thbGxdL211bmxvY2tbYWxsXSByZXF1ZXN0cy4NCiAqDQogKiBGaWx0ZXJzIG91dCAic3Bl
Y2lhbCIgdm1hcyAtLSBWTV9MT0NLRUQgbmV2ZXIgZ2V0cyBzZXQgZm9yIHRoZXNlLCBhbmQNCiAq
IG11bmxvY2sgaXMgYSBuby1vcC4gIEhvd2V2ZXIsIGZvciBzb21lIHNwZWNpYWwgdm1hcywgd2Ug
Z28gYWhlYWQgYW5kDQogKiBwb3B1bGF0ZSB0aGUgcHRlcy4NCiAqDQogKiBGb3Igdm1hcyB0aGF0
IHBhc3MgdGhlIGZpbHRlcnMsIG1lcmdlL3NwbGl0IGFzIGFwcHJvcHJpYXRlLg0KICovDQpzdGF0
aWMgaW50IG1sb2NrX2ZpeHVwKHN0cnVjdCB2bV9hcmVhX3N0cnVjdCAqdm1hLCBzdHJ1Y3Qgdm1f
YXJlYV9zdHJ1Y3QgKipwcmV2LA0KCXVuc2lnbmVkIGxvbmcgc3RhcnQsIHVuc2lnbmVkIGxvbmcg
ZW5kLCB2bV9mbGFnc190IG5ld2ZsYWdzKQ0Kew0KCXN0cnVjdCBtbV9zdHJ1Y3QgKm1tID0gdm1h
LT52bV9tbTsNCglwZ29mZl90IHBnb2ZmOw0KCWludCBucl9wYWdlczsNCglpbnQgcmV0ID0gMDsN
CglpbnQgbG9jayA9ICEhKG5ld2ZsYWdzICYgVk1fTE9DS0VEKTsNCgl2bV9mbGFnc190IG9sZF9m
bGFncyA9IHZtYS0+dm1fZmxhZ3M7DQoNCglpZiAobmV3ZmxhZ3MgPT0gdm1hLT52bV9mbGFncyB8
fCAodm1hLT52bV9mbGFncyAmIFZNX1NQRUNJQUwpIHx8DQoJICAgIGlzX3ZtX2h1Z2V0bGJfcGFn
ZSh2bWEpIHx8IHZtYSA9PSBnZXRfZ2F0ZV92bWEoY3VycmVudC0+bW0pIHx8DQoJICAgIHZtYV9p
c19kYXgodm1hKSkNCgkJLyogZG9uJ3Qgc2V0IFZNX0xPQ0tFRCBvciBWTV9MT0NLT05GQVVMVCBh
bmQgZG9uJ3QgY291bnQgKi8NCgkJZ290byBvdXQ7DQoNCg0KSSBnb3QgdGhyb3duIG9mZiBieSB0
aGlzIGNoZWNrIGh0dHBzOi8vZ2l0aHViLmNvbS90b3J2YWxkcy9saW51eC9ibG9iL3Y1LjIvbW0v
c3dhcC5jI0w0NTQtTDQ2OQ0KDQoNCnZvaWQgbHJ1X2NhY2hlX2FkZF9hY3RpdmVfb3JfdW5ldmlj
dGFibGUoc3RydWN0IHBhZ2UgKnBhZ2UsDQoJCQkJCSBzdHJ1Y3Qgdm1fYXJlYV9zdHJ1Y3QgKnZt
YSkNCnsNCglWTV9CVUdfT05fUEFHRShQYWdlTFJVKHBhZ2UpLCBwYWdlKTsNCg0KCWlmIChsaWtl
bHkoKHZtYS0+dm1fZmxhZ3MgJiAoVk1fTE9DS0VEIHwgVk1fU1BFQ0lBTCkpICE9IFZNX0xPQ0tF
RCkpDQoJCVNldFBhZ2VBY3RpdmUocGFnZSk7DQoJZWxzZSBpZiAoIVRlc3RTZXRQYWdlTWxvY2tl
ZChwYWdlKSkgew0KCQkvKg0KCQkgKiBXZSB1c2UgdGhlIGlycS11bnNhZmUgX19tb2Rfem9uZV9w
YWdlX3N0YXQgYmVjYXVzZSB0aGlzDQoJCSAqIGNvdW50ZXIgaXMgbm90IG1vZGlmaWVkIGZyb20g
aW50ZXJydXB0IGNvbnRleHQsIGFuZCB0aGUgcHRlDQoJCSAqIGxvY2sgaXMgaGVsZChzcGlubG9j
ayksIHdoaWNoIGltcGxpZXMgcHJlZW1wdGlvbiBkaXNhYmxlZC4NCgkJICovDQoJCV9fbW9kX3pv
bmVfcGFnZV9zdGF0ZShwYWdlX3pvbmUocGFnZSksIE5SX01MT0NLLA0KCQkJCSAgICBocGFnZV9u
cl9wYWdlcyhwYWdlKSk7DQoJCWNvdW50X3ZtX2V2ZW50KFVORVZJQ1RBQkxFX1BHTUxPQ0tFRCk7
DQoNCkknbGwgcmVtb3ZlIFZNX1NQRUNJQUwgYW5kIHJlLXN1Ym1pdC4NCg0KLS0NCkx1Y2lhbg0K
DQoNCg==

