Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBADDC49ED7
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 21:35:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C6CE20644
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 21:35:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ffpNPm2T";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="VfQZztyE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C6CE20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C9B66B0003; Mon, 16 Sep 2019 17:35:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A0D06B0006; Mon, 16 Sep 2019 17:35:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 067866B0007; Mon, 16 Sep 2019 17:35:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0243.hostedemail.com [216.40.44.243])
	by kanga.kvack.org (Postfix) with ESMTP id D8C9F6B0003
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 17:35:00 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 930075002
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 21:35:00 +0000 (UTC)
X-FDA: 75942089160.26.coat36_65c88bdf73346
X-HE-Tag: coat36_65c88bdf73346
X-Filterd-Recvd-Size: 10517
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 21:34:59 +0000 (UTC)
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x8GLSCfr022445;
	Mon, 16 Sep 2019 14:34:54 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=r9mQlR6Fst5BvEGlE+nyyNP/QfOQ3LfP8YoEVC1c768=;
 b=ffpNPm2TtGp7I9aRKtMYI3m4t0I5imebqWg/YvnPIjlils46iEg8S1PynoOebKNXHSqd
 SSdXOGh+zWVZ8P/jSCjgq1TMG6eZdwp5iMTWDXfuKaJN4g+cIin/f8dbscVyUbaE8UUZ
 pj6JWQechNbas6oy4SIrIiHgHO2iGcQIRmI= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2v2hs5g690-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 16 Sep 2019 14:34:53 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 16 Sep 2019 14:34:52 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 16 Sep 2019 14:34:52 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=mAN/P9TF0byLwt0cbxuyxF+3jeXKag7w4AoABY7jrNLSaQIFUyyTLDbFkS/9FhCFxL8tQx2Fy6Bopm2wfnDPXIYA575QDPL/3eljaKTGsWbFN0eFO7jWRpIHuLm0kyeuu9ENA3YrNhxynQhYYXYXmHlgHDkmHCotP71QKfnbwxZsiw7lly3TIrrb16DJ0CUPwh++IEdUxFegevqbTnXihlbMyE1yM0mMJKpK4AQSgzmGIyFW7OaOTe3PE/eB3gn49PDedGYwqnNuh7YYSNCckax77vRnVtiM7gfToqVh51NzeNitzWxPgHEMXvgUt/HUSGSAdyvuf7y9H0275x9SVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=r9mQlR6Fst5BvEGlE+nyyNP/QfOQ3LfP8YoEVC1c768=;
 b=n4KIM94GxKMU6b1fAETzh3Vcvio9O+9OaMtzN9cFpePCqkyB4YJFLDUdgEJO0NjGBgc2ppo5L1PM2mXPjvEElBuaGdFGMzsHuhO06S9+pAfdZeJbCzHhiz7MWdMy5G60SEqyLCGS+nqGOzNLJsF60cDH4A/R7SSFjG03VXgb0SCF26OjFAuy9fsYt7eIQ+9jTOK8WHWhEA34G6EOswXrRLkyLQbt0GZx8+48Hp16Hro/XH5fbb6JGAzTpUfwzNWBw9rL2k4X8Hu5P+ZUJ/iK82+E0I5WxwzNx/0lQxaQavaWpUuX0yR57kkBj2ApBJ3fL4mbkGhpYWEvlXZn6RjKSA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=r9mQlR6Fst5BvEGlE+nyyNP/QfOQ3LfP8YoEVC1c768=;
 b=VfQZztyEcFx/i0eSp5z+px1zIGC3zjUhhImXsZYfubmABI4qu7oZMkEZoark+MDHu66qm6b6LBYeD8cFY5slrhksg7LB+EBKi/ODreGBU21IRzSEM5Wk7oIHUebyXIhgelpiVS+TUeIwQOsjkuTWpJCeFLPw0BA3qPfbGPEtxg0=
Received: from BYAPR15MB3432.namprd15.prod.outlook.com (20.179.59.152) by
 BYAPR15MB3175.namprd15.prod.outlook.com (20.179.56.219) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2263.17; Mon, 16 Sep 2019 21:34:51 +0000
Received: from BYAPR15MB3432.namprd15.prod.outlook.com
 ([fe80::1097:b86e:429:bdf0]) by BYAPR15MB3432.namprd15.prod.outlook.com
 ([fe80::1097:b86e:429:bdf0%7]) with mapi id 15.20.2263.023; Mon, 16 Sep 2019
 21:34:51 +0000
From: Lucian Grijincu <lucian@fb.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Souptick Joarder
	<jrdr.linux@gmail.com>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@fb.com>,
        Roman Gushchin <guro@fb.com>, Hugh Dickins
	<hughd@google.com>
Subject: Re: [PATCH v3] mm: memory: fix /proc/meminfo reporting for
 MLOCK_ONFAULT
Thread-Topic: [PATCH v3] mm: memory: fix /proc/meminfo reporting for
 MLOCK_ONFAULT
Thread-Index: AQHVanfPge6XWMZkPE2ugM026yAHq6cuMMIAgAAyGAA=
Date: Mon, 16 Sep 2019 21:34:50 +0000
Message-ID: <01045F3D-B141-42E8-86C9-FA17B0E5EEE2@fb.com>
References: <20190913211119.416168-1-lucian@fb.com>
 <20190916113532.GE10231@dhcp22.suse.cz>
In-Reply-To: <20190916113532.GE10231@dhcp22.suse.cz>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Microsoft-MacOutlook/10.1d.0.190908
x-originating-ip: [2620:10d:c090:200::a343]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 85be11c4-92d2-4926-3912-08d73aedb4ef
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600167)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB3175;
x-ms-traffictypediagnostic: BYAPR15MB3175:
x-ms-exchange-purlcount: 2
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <BYAPR15MB317513E36BA0C81187CB1CFEAD8C0@BYAPR15MB3175.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0162ACCC24
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(376002)(346002)(136003)(39860400002)(51914003)(189003)(199004)(66476007)(36756003)(66556008)(14454004)(11346002)(2616005)(33656002)(486006)(102836004)(476003)(966005)(99286004)(186003)(71200400001)(71190400001)(46003)(446003)(478600001)(2906002)(86362001)(5660300002)(25786009)(256004)(76176011)(4326008)(14444005)(6116002)(6436002)(6506007)(58126008)(53936002)(316002)(53546011)(6486002)(6246003)(229853002)(7736002)(6512007)(305945005)(6916009)(6306002)(8676002)(81156014)(81166006)(8936002)(76116006)(91956017)(66946007)(64756008)(66446008)(54906003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3175;H:BYAPR15MB3432.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: cI8SoUZk2jCH7HkyYLEgj5mSasPHh2zhHTze1O2639hxcco+M9TbB84Ha9roHeCwEZdX0oKwTDBgdVOzCPWJqbXfVDVjTNgPx3OpBdoC/4+kXouFXFkI5USSprFkh3LYmUawt9tS419bSI+bol6g1vMSRwCYI+ahPNq5Et0FaoHpHvay9k3XOzRvzxMCjbLjRVF/3vqVeFwp/BfoRV3FeLwKemOpLbS+cyR6hARbq3616+uuI/VBiXnv9vfgk/P1snvngwHuDWUcOpbAmtD8NtPawt5QfocB8hDapoiJV0+C9sfTn58PNA5TjmXCFVAaKuzBuWGgTHtjZ93GxHqNv6ULFiWjyb0edBL2I6xsmuhdx9BD4kL2Vb+zsrN5F8brDOMJIC0MYFD7914EIL69sV/KXGIvj7pBL7AajhqhEYc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <7EE9B7EF5A94B9448F05839D97BADBF3@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 85be11c4-92d2-4926-3912-08d73aedb4ef
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Sep 2019 21:34:51.1472
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: jc6ALbz9uZyZC72bjeltIhAZq0tz21ep5XmeF3u6Qci2z7Cog/pR1kbgiZq7zE9k
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3175
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-16_08:2019-09-11,2019-09-16 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 adultscore=0
 suspectscore=0 bulkscore=0 phishscore=0 mlxlogscore=999 clxscore=1011
 malwarescore=0 lowpriorityscore=0 spamscore=0 mlxscore=0
 priorityscore=1501 impostorscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.12.0-1908290000 definitions=main-1909160206
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

DQoNCu+7vz4gT24gOS8xNi8xOSwgMDQ6MzUsICJNaWNoYWwgSG9ja28iIDxtaG9ja29Aa2VybmVs
Lm9yZz4gd3JvdGU6DQo+ICAgICA+IGRpZmYgLS1naXQgYS9tbS9tZW1vcnkuYyBiL21tL21lbW9y
eS5jDQo+ICAgICA+IGluZGV4IGUwYzIzMmZlODFkOS4uNTVkYTI0ZjMzYmM0IDEwMDY0NA0KPiAg
ICAgPiAtLS0gYS9tbS9tZW1vcnkuYw0KPiAgICAgPiArKysgYi9tbS9tZW1vcnkuYw0KPiAgICAg
PiBAQCAtMzMxMSw2ICszMzExLDggQEAgdm1fZmF1bHRfdCBhbGxvY19zZXRfcHRlKHN0cnVjdCB2
bV9mYXVsdCAqdm1mLCBzdHJ1Y3QgbWVtX2Nncm91cCAqbWVtY2csDQo+ICAgICA+ICAJfSBlbHNl
IHsNCj4gICAgID4gIAkJaW5jX21tX2NvdW50ZXJfZmFzdCh2bWEtPnZtX21tLCBtbV9jb3VudGVy
X2ZpbGUocGFnZSkpOw0KPiAgICAgPiAgCQlwYWdlX2FkZF9maWxlX3JtYXAocGFnZSwgZmFsc2Up
Ow0KPiAgICAgPiArCQlpZiAodm1hLT52bV9mbGFncyAmIFZNX0xPQ0tFRCAmJiAhUGFnZVRyYW5z
Q29tcG91bmQocGFnZSkpDQo+ICAgICA+ICsJCQltbG9ja192bWFfcGFnZShwYWdlKTsNCj4gICAg
ID4gIAl9DQo+ICAgICA+ICAJc2V0X3B0ZV9hdCh2bWEtPnZtX21tLCB2bWYtPmFkZHJlc3MsIHZt
Zi0+cHRlLCBlbnRyeSk7DQogICAgDQo+ICAgICBJIGR1bm5vLiBIYW5kbGluZyBpdCBoZXJlIGlu
IGFsbG9jX3NldF9wdGUgc291bmRzIGEgYml0IHdlaXJkIHRvIG1lLg0KPiAgICAgQWx0b3VnaCB3
ZSBhbHJlYWR5IGRvIG1sb2NrIGZvciBDb1cgcGFnZXMgdGhlcmUsIEkgdGhvdWdodCB0aGlzIHdh
cyBtb3JlDQo+ICAgICBvZiBhbiBleGNlcHRpb24uDQo+ICAgICBJcyB0aGVyZSBhbnkgcmVhbCBy
ZWFzb24gd2h5IHRoaXMgY2Fubm90IGJlIGRvbmUgaW4gdGhlIHN0YW5kYXJkICNQRg0KPiAgICAg
cGF0aD8gZmluaXNoX2ZhdWx0IGZvciBleGFtcGxlPw0KDQphbGxvY19zZXRfcHRlIGlzIGNhbGxl
ZCBmcm9tIGZpbmlzaF9mYXVsdCBodHRwczovL2dpdGh1Yi5jb20vdG9ydmFsZHMvbGludXgvYmxv
Yi92NS4yL21tL21lbW9yeS5jI0wzNDAwDQoNCiAgIHZtX2ZhdWx0X3QgZmluaXNoX2ZhdWx0KHN0
cnVjdCB2bV9mYXVsdCAqdm1mKQ0KICAgICAuLi4NCglpZiAoIXJldCkNCgkJcmV0ID0gYWxsb2Nf
c2V0X3B0ZSh2bWYsIHZtZi0+bWVtY2csIHBhZ2UpOw0KDQphbmQgaW5zaWRlIGFsbG9jX3NldF9w
dGUgb25lIG9mIHRoZSBicmFuY2hlcyBvZiB0aGUgaWYtY2xhdXNlIGFscmVhZHkgaGFuZGxlZCBt
bG9ja2VkIHBhZ2VzOg0KaHR0cHM6Ly9naXRodWIuY29tL3RvcnZhbGRzL2xpbnV4L2Jsb2IvdjUu
Mi9tbS9tZW1vcnkuYyNMMzM0OC1MMzM1Ng0KDQpJIGFkZGVkIGl0IHRvIHRoZSBlbHNlLWJyYW5j
aCBhcyB0aGF0IHNlZW1lZCBsaWtlIHRoZSBsZWFzdCBpbnRydXNpdmUgY2hhbmdlLCBidXQgSSB3
aWxsIG1vdmUgdGhpcyB0byBmaW5pc2hfZmF1bHQsIHByb2JhYmx5IGxpa2UgdGhpcyAoYWZ0ZXIg
SSdtIGRvbmUgdGVzdGluZyk6DQoNCiAgIHZtX2ZhdWx0X3QgZmluaXNoX2ZhdWx0KHN0cnVjdCB2
bV9mYXVsdCAqdm1mKQ0KICAgIC4uLg0KICAgICAgICBpZiAoIXJldCkNCiAgICAgICAgICAgICAg
ICByZXQgPSBhbGxvY19zZXRfcHRlKHZtZiwgdm1mLT5tZW1jZywgcGFnZSk7DQorICAgICAgIGlm
ICghcmV0ICYmICh2bWYtPnZtYS0+dm1fZmxhZ3MgJiBWTV9MT0NLRUQpICYmICFQYWdlVHJhbnND
b21wb3VuZChwYWdlKSkNCisgICAgICAgICAgICAgICAgICAgICAgIG1sb2NrX3ZtYV9wYWdlKHBh
Z2UpOw0KDQpUaGFua3MgZm9yIHRoZSByZXZpZXcgYW5kIHN1Z2dlc3Rpb25zIQ0KDQotLQ0KTHVj
aWFuDQoNCg==

