Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 222AFC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 13:01:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6728D2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 13:01:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="OSTefwRu";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="F5FSMmBl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6728D2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB0926B0003; Thu, 20 Jun 2019 09:01:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B60E58E0002; Thu, 20 Jun 2019 09:01:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A29BF8E0001; Thu, 20 Jun 2019 09:01:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8300A6B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 09:01:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z5so3434867qth.15
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:01:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Jnhr3IqmWUQ6nRxmQFOq302F8DUd89Wr2Ra0bUkUvRo=;
        b=c+2twpRxQMLg/YIO+1m22jjELgq3P8jH8jMsqC6HXtsqNaNz1S9V9av2qnT8Gn4MJy
         40CmlH+SHqW3fCUygafL1qlDlvuIROPgZIL3oGLZ5VCOgNwMzjiO0J9DGTeFYJNzDRKv
         q+DVaRWvAEvlWDivuHSu6DNv5HpwgHjdlX5NKaSnyiYKvzuiVQZjibp1d4DvYJqdPcZs
         NcQY72zNHg8SEzc+FxSxQ0Xq50bLkG/WYahoKMM3wepySBnHjBNd8qDjAAfiOr7fx8UL
         cInSQlIqKuEdnIeGUHKtvpHH5h342zvfywyKuP/mXi48SEBTielA3jb8Dxle1MNLJlNP
         zYoA==
X-Gm-Message-State: APjAAAXA1X1UuGE0e+pprPyShXiFPjuqX3XC0ap+uLcTELeC04+KlWnm
	L4xg6hafTiGQ4cfn7Cdyd5qXAq5LAsyuds78j3pWrSH19cCs/hOHWNIZKsuHAv1Q16AX/mns/p2
	ngbJXFOTVjhMh9vR2rZuGp8TJUgXPqk5Ka/nVy+c+MsYvTqSCpPovPgjeRh9B6y8CbQ==
X-Received: by 2002:ac8:30a7:: with SMTP id v36mr89289614qta.119.1561035665230;
        Thu, 20 Jun 2019 06:01:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJmzlYhcK+AxMSa2fpEFfSd9KPJxrkgjd7JwowaSOuZOHrDXvprfva8n9NJkBGO4QiEkAK
X-Received: by 2002:ac8:30a7:: with SMTP id v36mr89289446qta.119.1561035663778;
        Thu, 20 Jun 2019 06:01:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561035663; cv=none;
        d=google.com; s=arc-20160816;
        b=BH5Xmqs6Q3m+WKSPl1Y/tbeNpsvS57XJbFqQxNlC0FG17EqD+QtU8uj5fxl4aJso37
         bfBsrcgz7SsRw3X7U3urEE/AL9sXnuSQhQOw4YiNybG+uSJCwiMxrE0h/NynMwa7NIuu
         9fFEsFe21RF/07DmL0Bf6QdZdARVDkhlJQMRGD5Rx0VK+13WxncXbhb8iDJMURlwmpwg
         h+3J62BAFMzh8VZo+5uOgG5jKcoxvDFrz/jMhlxyXoP1XgCAsh31Lm6YYjHfqkkfuTqu
         2c4EUydQUEKdQIXscBiMRyHuqHJmGtuZWwsJ2lmitUWqFbDWSRUZ7CzceNV6reGd+BQV
         gQFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Jnhr3IqmWUQ6nRxmQFOq302F8DUd89Wr2Ra0bUkUvRo=;
        b=plEFcC/2BhTWcqiCFvMylQUEOP9MPyoI3KNYiH+ZJW6G98YOTxJzlgldsN/+gnbGu7
         K6RW+9YxeOWu9y+MsSMxRU9Aw7ODaQviiyDpcF+ssjawriMP62UIssXhstDKNfVeQtCh
         AElLQlEnrYNjv96BipPX3GsytnAVicb2C2/MxjmrXKwFWYiStL42I/PF9w5hkFv0p+o/
         tlL5Z8HekC0KtDwNPNxPjVl4BbHXBwwMQhzk55NRlBGAcDM/tyP6/ay5R93/4JZrzFnb
         Tg4At7H8DOQlhsfHab+27Uo8LnkfHO6hcRQjiptID9pKsen+IPQz1M5NLL6JHRKnugg3
         FBzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=OSTefwRu;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=F5FSMmBl;
       spf=pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107484c082=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id s188si14704037qkb.41.2019.06.20.06.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 06:01:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=OSTefwRu;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=F5FSMmBl;
       spf=pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107484c082=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KCulAA018192;
	Thu, 20 Jun 2019 06:01:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Jnhr3IqmWUQ6nRxmQFOq302F8DUd89Wr2Ra0bUkUvRo=;
 b=OSTefwRuW5DCDAg1g0UCctZ9eoHUanA+t5Ls3vEqdMsH2HZy2PuLj6FZqFCQyyL9F4Bb
 M1QPIQ6iwBTyUN9605m2J6g2zsuv8Ef6AF121DFFyehFgqtKufbJr1sti8wDofxULaEI
 jw8oRKhAin5SSiLIdD6G1cKybK1k8V9evDM= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2t8aj980nk-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 20 Jun 2019 06:01:00 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 20 Jun 2019 06:00:38 -0700
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 20 Jun 2019 06:00:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Jnhr3IqmWUQ6nRxmQFOq302F8DUd89Wr2Ra0bUkUvRo=;
 b=F5FSMmBl4/1gaxKpEL9BYeQB0zkSZGGPAGwqCQvbb3GJrMhI8ygVsCRwhTHJ8Ptlr5vI120IQdnJiNGm8Oi6UeGzFRCvDq26HEe1vXNcEBf37kmuhfAi9uHkxK7w7NX5TP+j9pNQMhVbgnifY+cXG4dKFyC4yDRFrCuoSr8OmRc=
Received: from BYAPR15MB3479.namprd15.prod.outlook.com (20.179.60.19) by
 BYAPR15MB3464.namprd15.prod.outlook.com (20.179.60.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 20 Jun 2019 13:00:36 +0000
Received: from BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9]) by BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9%5]) with mapi id 15.20.1987.014; Thu, 20 Jun 2019
 13:00:36 +0000
From: Rik van Riel <riel@fb.com>
To: Song Liu <songliubraving@fb.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 6/6] mm,thp: handle writes to file with THP in
 pagecache
Thread-Topic: [PATCH v3 6/6] mm,thp: handle writes to file with THP in
 pagecache
Thread-Index: AQHVJmfNp6psayhKU0eYRk6mGJngP6ajghwAgABLrgCAALWtAA==
Date: Thu, 20 Jun 2019 13:00:36 +0000
Message-ID: <559305a9825adc7e49aabf52ddec3b40d054fa62.camel@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
	 <20190619062424.3486524-7-songliubraving@fb.com>
	 <9ec5787861152deb1c6c6365b593343b3aef18d4.camel@fb.com>
	 <B051CE4A-063B-4464-8193-93C9F1D0A0A7@fb.com>
In-Reply-To: <B051CE4A-063B-4464-8193-93C9F1D0A0A7@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR21CA0052.namprd21.prod.outlook.com
 (2603:10b6:300:db::14) To BYAPR15MB3479.namprd15.prod.outlook.com
 (2603:10b6:a03:112::19)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:f51]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5fde67a0-a2e3-4852-d7f3-08d6f57f4974
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB3464;
x-ms-traffictypediagnostic: BYAPR15MB3464:
x-microsoft-antispam-prvs: <BYAPR15MB3464B34C3DCD9595E8EE797EA3E40@BYAPR15MB3464.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0074BBE012
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(366004)(346002)(396003)(39860400002)(189003)(54094003)(199004)(4326008)(8936002)(71190400001)(36756003)(478600001)(256004)(186003)(81156014)(229853002)(81166006)(14454004)(8676002)(71200400001)(6116002)(7736002)(305945005)(118296001)(6862004)(53936002)(68736007)(99286004)(2906002)(6636002)(66476007)(64756008)(6486002)(6506007)(386003)(73956011)(66946007)(6512007)(66446008)(66556008)(6246003)(25786009)(37006003)(316002)(102836004)(6436002)(53546011)(46003)(52116002)(486006)(76176011)(2616005)(54906003)(446003)(476003)(11346002)(86362001)(5660300002)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3464;H:BYAPR15MB3479.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: UtjY8nB+8WzEHry6qsW/waultJk+wFUiiB1SSGIcPK2yzVZ0K5hK3hu/QoI5eXxRgk9KLfrdriN2iRHrHwaW8ehT6QeSx7qSUF7iplK+2QXKC3pYJ4BmpNp/bRzPRHcrbJpGV7RN1hNXDio3VXRmrQlD1BpQlnk/Tz8JaVypGviIkNJPGhX0dCAxxxLXwD4IH88YSHqxZj0G6igdpwBinfj4FkLz/dtMmINxBjUfYqCd9AV9HhTG2/yn9OpEF9x2W0yp3paPbi0E8RVZpOqEmFM3umbEYSGphdBUUtq8aHmwKMky7U/xnDCdZke+kzedN3m9URLlaJMbJX1+6AezXSgYlAi917b67Ou7hC0FWInjkNpMMSsUmMup87pHt9oS0iUnNE2Ewr5+Qv7JMGB/jZ/b2UoEjvYJzC3HAfqcy5g=
Content-Type: text/plain; charset="utf-8"
Content-ID: <A330EF64F1089E449E47BC6AD76D4607@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 5fde67a0-a2e3-4852-d7f3-08d6f57f4974
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Jun 2019 13:00:36.5097
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: riel@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3464
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=441 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200096
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gV2VkLCAyMDE5LTA2LTE5IGF0IDIyOjEwIC0wNDAwLCBTb25nIExpdSB3cm90ZToNCj4gPiBP
biBKdW4gMTksIDIwMTksIGF0IDY6MzkgUE0sIFJpayB2YW4gUmllbCA8cmllbEBmYi5jb20+IHdy
b3RlOg0KPiA+IA0KPiA+IE9uIFR1ZSwgMjAxOS0wNi0xOCBhdCAyMzoyNCAtMDcwMCwgU29uZyBM
aXUgd3JvdGU6DQo+ID4gDQo+ID4gPiBpbmRleCA4NTYzMzM5MDQxZjYuLmJhYjhkOWVlZjQ2YyAx
MDA2NDQNCj4gPiA+IC0tLSBhL21tL3RydW5jYXRlLmMNCj4gPiA+ICsrKyBiL21tL3RydW5jYXRl
LmMNCj4gPiA+IEBAIC03OTAsNyArNzkwLDExIEBAIEVYUE9SVF9TWU1CT0xfR1BMKGludmFsaWRh
dGVfaW5vZGVfcGFnZXMyKTsNCj4gPiA+IHZvaWQgdHJ1bmNhdGVfcGFnZWNhY2hlKHN0cnVjdCBp
bm9kZSAqaW5vZGUsIGxvZmZfdCBuZXdzaXplKQ0KPiA+ID4gew0KPiA+ID4gCXN0cnVjdCBhZGRy
ZXNzX3NwYWNlICptYXBwaW5nID0gaW5vZGUtPmlfbWFwcGluZzsNCj4gPiA+IC0JbG9mZl90IGhv
bGViZWdpbiA9IHJvdW5kX3VwKG5ld3NpemUsIFBBR0VfU0laRSk7DQo+ID4gPiArCWxvZmZfdCBo
b2xlYmVnaW47DQo+ID4gPiArDQo+ID4gPiArCS8qIGlmIG5vbi1zaG1lbSBmaWxlIGhhcyB0aHAs
IHRydW5jYXRlIHRoZSB3aG9sZSBmaWxlICovDQo+ID4gPiArCWlmIChmaWxlbWFwX25yX3RocHMo
bWFwcGluZykpDQo+ID4gPiArCQluZXdzaXplID0gMDsNCj4gPiA+IA0KPiA+IA0KPiA+IEkgZG9u
J3QgZ2V0IGl0LiBTb21ldGltZXMgdHJ1bmNhdGUgaXMgdXNlZCB0bw0KPiA+IGluY3JlYXNlIHRo
ZSBzaXplIG9mIGEgZmlsZSwgb3IgdG8gY2hhbmdlIGl0DQo+ID4gdG8gYSBub24temVybyBzaXpl
Lg0KPiA+IA0KPiA+IFdvbid0IGZvcmNpbmcgdGhlIG5ld3NpemUgdG8gemVybyBicmVhayBhcHBs
aWNhdGlvbnMsDQo+ID4gd2hlbiB0aGUgZmlsZSBpcyB0cnVuY2F0ZWQgdG8gYSBkaWZmZXJlbnQg
c2l6ZSB0aGFuDQo+ID4gdGhleSBleHBlY3Q/DQo+IA0KPiBUaGlzIGlzIG5vdCB0cnVuY2F0ZSB0
aGUgZmlsZS4gSXQgb25seSBkcm9wcyBwYWdlIGNhY2hlLiANCj4gdHJ1bmNhdGVfc2V0c2l6ZSgp
IHdpbGwgc3RpbGwgc2V0IGNvcnJlY3Qgc2l6ZS4gSSBkb24ndCANCj4gdGhpbmsgdGhpcyBicmVh
a3MgYW55dGhpbmcuIA0KDQpBaGhoLCBpbmRlZWQuIEdvb2QgcG9pbnQuDQoNCkkgd29uZGVyIGlm
IHRoZSBkcm9wcGluZyBvZiB0aGUgcGFnZSBjYWNoZSBjb3VsZCBiZQ0KZG9uZSBhdXRvbWF0aWNh
bGx5IGZyb20gb3BlbigpLCBpZiBpdCBkZXRlcm1pbmVzIHRoYXQNCnRoZXJlIGFyZSBubyBtb3Jl
IHJlYWRvbmx5IFRIUCB1c2VycyBvZiB0aGUgZmlsZSwgYW5kDQp0aGUgbmV3IG9wZW5lciB3YW50
cyB0byB3cml0ZSB0byB0aGUgZmlsZT8NCg0KVGhhdCBtYWdpYyBjb3VsZCBiZSBpbiBhIGhlbHBl
ciBmdW5jdGlvbiwgc28gaXQgd291bGQNCmJlIGp1c3QgYSBvbmUgbGluZSBjaGFuZ2UgaW4gdGhl
IHNhbWUgc3BvdCB3aGVyZSBpdA0KY3VycmVudGx5IGRlbmllcyB0aGUgcGVybWlzc2lvbiA6KQ0K
DQo+IFdlIGNhbiBwcm9iYWJseSBtYWtlIGl0IHNtYXJ0ZXIgYW5kIG9ubHkgZHJvcCB0aGUgY2xl
YW4NCj4gaHVnZSBwYWdlcyAoZGlydHkgcGFnZSBzaG91bGQgbm90IGV4aXN0KS4gDQoNCg0K

