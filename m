Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B088AC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:33:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B949206BA
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:33:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="eWN2uOwt";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="onYFGFx/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B949206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05B6B8E0002; Thu, 20 Jun 2019 13:33:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00CC08E0001; Thu, 20 Jun 2019 13:33:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E15468E0002; Thu, 20 Jun 2019 13:33:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id C208C8E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:33:31 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id k79so2058810ybk.19
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:33:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=9JrVJbdBfSF0MhohJVF60W/ryo3IXTB4Ol2A9ONoUaQ=;
        b=HihBMjo+5aI5lhdh63oq4Bl2VNCUCq1wdqL179N0KV/j/CXVvN8tSCv4TuYAr1RZFB
         gQ7EKZVepfe95ScObXpik48DHCpI2ThmPeJ0mrkX+T1QuFTZtTXRSF3EPSMl4PShKteH
         qBrUQQZC68siBFDfJ89AgBPFRZI0iDUmFHvJJ7a7ZgKww0gvXzZnyap7HrmC/xXsbm5E
         3OMa9MGZylQHfBloZPCTy6KfmE0xz7dRjhZ2uGNAL2YmffRfD+ib3VwOF2hUJTOgCL8b
         WHGUM2pgseE0tGiVomkAdIlB4b1l+Rei6gye31A1/XHqF4fHWaie4u13T4lGsf7gtSMm
         BF7g==
X-Gm-Message-State: APjAAAUny9o3vzQUHT29byEvmwBbMpp6heSaN2yLsndF9X3DRMPbEJx/
	75oq+CayuVWMwXK/uzcgnFZ29AGEujrl5M96ZdnSgbziRs4rWsLo5AG1jrQ5Efj5wZStgmBFdsH
	mrMWueSEd9Kb32AE4p5Jku6W3D1kib1HM5FKpsybKCundwA0q58PfZ2rWqpv0lcQvvA==
X-Received: by 2002:a25:76d1:: with SMTP id r200mr68197449ybc.260.1561052011532;
        Thu, 20 Jun 2019 10:33:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzY8IcVR7NgRxDd0QNKUSmVBazQotp3gNBMxXA7kdhQ2fs+1UXb6BwVP0LogKx1lGv6GFxj
X-Received: by 2002:a25:76d1:: with SMTP id r200mr68197420ybc.260.1561052011033;
        Thu, 20 Jun 2019 10:33:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561052011; cv=none;
        d=google.com; s=arc-20160816;
        b=sAoPw1YKEemIkAfBnRhp87UfjcfqttFJrOAhy9hFfX+XYlIEkLjNjrCWHyi/4UBU0G
         oVXX0wRMtDaKmO8adGDR3lfza8snZ0YmzxXOtgngsP7cTViSI3m7YuUhkJNS2HNuEmi7
         ewt8m/J4gVyBfs9uU3Io48UO2QlzuYv7x3AgBpNOFZqc8e4m0WkfXsu1RiBFareUGTWY
         d9DcXIUdVGiF13Zc2b1VYQYFXy/QSt1UgZ5+tVtMVq+eE18587LIaAeVBGkXdB8DIDXN
         eaZlalsAnYJvuRoMlLcC9W5Lzckzcufb69rY18B3GohN1sY3i22bpkYEfs4HzFu0EQk7
         8hQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=9JrVJbdBfSF0MhohJVF60W/ryo3IXTB4Ol2A9ONoUaQ=;
        b=o9OvysUwN4S6nFI4XllgeE8pig53ahenJpJbO7Iaq9yqea7dckCGcAGnlFcnNrhxuC
         NvZLa2J2mfWJ068ctM7prNjTz9+HYe035BCyym9Emro95XucTScor/jGTm6NxMZ+9HKi
         RCQq7Gd3NIaQzYUIvoQinGZ525hmx0epc0c7CcafAkOdc1OxZlxKHgN+N2SVpKbPr8+n
         ZXZizDMYO4+JLzvaVJaEUNDI+6HYl2UPEqOqUGJdDtigyu4KyG8eYhYXOLU1k/6IuvNA
         SjqliA4KuF3yqm5/hATxH2v/VfaBpW2rMhiH5CQv+Zxv5opC+TFumuz4OOd5zIA/fgJo
         ZOaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=eWN2uOwt;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="onYFGFx/";
       spf=pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107484c082=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k187si31267yba.306.2019.06.20.10.33.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:33:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=eWN2uOwt;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b="onYFGFx/";
       spf=pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107484c082=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KHKJdF001684;
	Thu, 20 Jun 2019 10:33:29 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=9JrVJbdBfSF0MhohJVF60W/ryo3IXTB4Ol2A9ONoUaQ=;
 b=eWN2uOwtmbGhWQuYPGeSGgfyZjqRc4PagrJuvUHPrKdOG/G5PtH5uwIov4CWN93N8DPc
 Inilz5WJOL8MUD+ru3aK2b4P8Na0z1cX4CfehW07AvCB9OjeGhOAgkC8qCF0UVHGC4UO
 e1ZVh888AfLMcLB1mG0HOrLkzRm7vSmAUWU= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t7ur9kpdr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 20 Jun 2019 10:33:29 -0700
Received: from prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 20 Jun 2019 10:33:28 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 20 Jun 2019 10:33:28 -0700
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 20 Jun 2019 10:33:28 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9JrVJbdBfSF0MhohJVF60W/ryo3IXTB4Ol2A9ONoUaQ=;
 b=onYFGFx/7QVExFlIXIoPqqq21GDz6DZzvMi8jkQ4JoZzS9Gap9kg3hL8gh+GRpscuR9MtbXFZqoNjPZGxY2Uevx73X+e5KcY58K0/V+usQPWVgDqS+A9kY9qEGkWJTCRCGXI8o4pTDaU36v7DGtRbe8AHlAjJM0eiea0Q8pSOrY=
Received: from BYAPR15MB3479.namprd15.prod.outlook.com (20.179.60.19) by
 BYAPR15MB2407.namprd15.prod.outlook.com (52.135.198.145) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.15; Thu, 20 Jun 2019 17:33:26 +0000
Received: from BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9]) by BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9%5]) with mapi id 15.20.1987.014; Thu, 20 Jun 2019
 17:33:26 +0000
From: Rik van Riel <riel@fb.com>
To: Song Liu <songliubraving@fb.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
CC: "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "Kernel
 Team" <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>
Subject: Re: [PATCH v4 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Topic: [PATCH v4 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Index: AQHVJ43LQE1pNmPhcUCBRrcpB6GfjqakzWUA
Date: Thu, 20 Jun 2019 17:33:25 +0000
Message-ID: <b9db545fdb5058831e48504ea4e4e0bcaaf36ff3.camel@fb.com>
References: <20190620172752.3300742-1-songliubraving@fb.com>
	 <20190620172752.3300742-6-songliubraving@fb.com>
In-Reply-To: <20190620172752.3300742-6-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1701CA0004.namprd17.prod.outlook.com
 (2603:10b6:301:14::14) To BYAPR15MB3479.namprd15.prod.outlook.com
 (2603:10b6:a03:112::19)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:f51]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b8eefe25-41ed-4e81-5540-08d6f5a5666f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB2407;
x-ms-traffictypediagnostic: BYAPR15MB2407:
x-microsoft-antispam-prvs: <BYAPR15MB2407D484950AD78D3C1F7C80A3E40@BYAPR15MB2407.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0074BBE012
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(39860400002)(136003)(366004)(376002)(189003)(199004)(229853002)(118296001)(5660300002)(4326008)(68736007)(102836004)(4744005)(2906002)(71190400001)(11346002)(486006)(46003)(110136005)(73956011)(36756003)(2201001)(478600001)(66446008)(71200400001)(99286004)(186003)(6486002)(8676002)(66556008)(54906003)(66946007)(2501003)(66476007)(6512007)(316002)(81166006)(6436002)(64756008)(6506007)(86362001)(446003)(81156014)(76176011)(25786009)(52116002)(476003)(256004)(6116002)(2616005)(6246003)(8936002)(14454004)(7736002)(53936002)(305945005)(386003)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2407;H:BYAPR15MB3479.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: /+JabLX0YE+oHbwXeCcgcSqMrYosKOPj8L6QXcH0cnqIEmpbObaq1097E7kQ6xze+LkRUnq76e7UQHO1nG1AoNgyhXG/trhnf57C4AwfRU/cGYNzk/5on2KAOHh5XLAolasq556g7f/yQCOB01eNKGgUeQJI9O1+cUAtVTDeg6IyKC+FIEFCq5ulJSZp0vef3+t6n+1HzKojebkfU6HSCLuxGziLO6smyy8ysIXQERCcLF6t0ZHI0gzXelnMFZRXSRldPpe7d/t/BUuovbScvx6HUACzVIf3boLtx9sEC0H7eEGaUym0xzSH//ZvVTMGDPphVa/Fhltzxh0qcNItgGmy4JSahxwuhLofEeWrBd3xbFOPK7SoJKXy0bXNTdt9WpEMhgOHusKQmvv4jlg20d8bl92iK2G95ni25GmGgck=
Content-Type: text/plain; charset="utf-8"
Content-ID: <F260CBB187980D40AF5582D9C124341D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b8eefe25-41ed-4e81-5540-08d6f5a5666f
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Jun 2019 17:33:26.0013
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: riel@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2407
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200124
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVGh1LCAyMDE5LTA2LTIwIGF0IDEwOjI3IC0wNzAwLCBTb25nIExpdSB3cm90ZToNCj4gVGhp
cyBwYXRjaCBpcyAoaG9wZWZ1bGx5KSB0aGUgZmlyc3Qgc3RlcCB0byBlbmFibGUgVEhQIGZvciBu
b24tc2htZW0NCj4gZmlsZXN5c3RlbXMuDQo+IA0KPiBUaGlzIHBhdGNoIGVuYWJsZXMgYW4gYXBw
bGljYXRpb24gdG8gcHV0IHBhcnQgb2YgaXRzIHRleHQgc2VjdGlvbnMgdG8NCj4gVEhQDQo+IHZp
YSBtYWR2aXNlLCBmb3IgZXhhbXBsZToNCj4gDQo+ICAgICBtYWR2aXNlKCh2b2lkICopMHg2MDAw
MDAsIDB4MjAwMDAwLCBNQURWX0hVR0VQQUdFKTsNCj4gDQo+IFdlIHRyaWVkIHRvIHJldXNlIHRo
ZSBsb2dpYyBmb3IgVEhQIG9uIHRtcGZzLg0KPiANCj4gQ3VycmVudGx5LCB3cml0ZSBpcyBub3Qg
c3VwcG9ydGVkIGZvciBub24tc2htZW0gVEhQLiBraHVnZXBhZ2VkIHdpbGwNCj4gb25seQ0KPiBw
cm9jZXNzIHZtYSB3aXRoIFZNX0RFTllXUklURS4gVGhlIG5leHQgcGF0Y2ggd2lsbCBoYW5kbGUg
d3JpdGVzLA0KPiB3aGljaA0KPiB3b3VsZCBvbmx5IGhhcHBlbiB3aGVuIHRoZSB2bWEgd2l0aCBW
TV9ERU5ZV1JJVEUgaXMgdW5tYXBwZWQuDQo+IA0KPiBBbiBFWFBFUklNRU5UQUwgY29uZmlnLCBS
RUFEX09OTFlfVEhQX0ZPUl9GUywgaXMgYWRkZWQgdG8gZ2F0ZSB0aGlzDQo+IGZlYXR1cmUuDQo+
IA0KPiBTaWduZWQtb2ZmLWJ5OiBTb25nIExpdSA8c29uZ2xpdWJyYXZpbmdAZmIuY29tPg0KDQpB
Y2tlZC1ieTogUmlrIHZhbiBSaWVsIDxyaWVsQHN1cnJpZWwuY29tPg0KDQooSSBzdXBwb3NlIEkg
c2hvdWxkIGhhdmUgc2VudCB0aGlzIG91dCBsYXN0IG5pZ2h0LA0Kd2hpbGUgSSB3YXMgcG9zdGlu
ZyBxdWVzdGlvbnMgYWJvdXQgcGF0Y2ggNikNCg0K

