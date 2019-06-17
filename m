Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A6D0C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:42:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C40A42084A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:42:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="g2XTwmM+";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="SlbND4CK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C40A42084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58EF58E0004; Mon, 17 Jun 2019 11:42:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5197F8E0001; Mon, 17 Jun 2019 11:42:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36B418E0004; Mon, 17 Jun 2019 11:42:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9CC8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:42:17 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id w127so12508508ywe.6
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:42:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=cm97Gen0Peolk7PbK7fZk/pE/Z5g0ga5gF4LkfIAffY=;
        b=SxNAtaM2Ik4beG2MVGGdMwba6vTs1X8Sa/mEIa1YGD4u4pjz6pUnzkYSohAwtHKVNI
         zph1JHxSb2H/GjxrOPAFPori65OQPm3j7wSXiBvgz9w96GiXUaFOmxf0ApSp6wL9J1QG
         XwTlZ0RXtOyHCLRq08CkJT7iSdlDFqJotUXO34hnxKI7Pl9DZwxCDmLruo31MLn8zgwh
         7rJ2uAqTEtIJ19h8AKFnLnEAt/D0n7Kv9Mmfj0f/g/ddVBYbTIAzebN7SIf2+kiiNGno
         n7SLyKrnMB+Q4l1+sjuz8E1AXXf2khrpVva678gG04kqcA85/nm3SxS0J+jKRbqTv88k
         iS+Q==
X-Gm-Message-State: APjAAAUvsSYwfnSk0Zlvu/n6XXucgSv4I9HB0Vnqpy6PLeQI5UMasbaS
	93aHIlBqpHGIt83d4xeb+QoKyTvOdy67Jv+F3eAhwq3uejuNr108T6iPA1Vj66DuSlB4hCgMAjM
	A9rWZ3iiY+ZDBk6OYUoMZjoXuHjUjGhriFZeyVyWvz0UxFCz70CVGzjHdGwtrLKJ1Kw==
X-Received: by 2002:a25:6b4b:: with SMTP id o11mr16794084ybm.91.1560786136841;
        Mon, 17 Jun 2019 08:42:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwe+sY5zG/gKzaVF4LAYvAKZ2FRxcvm7vlI7vWAtu90qinHu1l+BJLse77oNsq79ZQ1yawR
X-Received: by 2002:a25:6b4b:: with SMTP id o11mr16794044ybm.91.1560786136209;
        Mon, 17 Jun 2019 08:42:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560786136; cv=none;
        d=google.com; s=arc-20160816;
        b=cRPJqJET2h39VDQXcPiymKAUEBQWTZ8OispYjQ7pNrd+BGUzZtRctwxeM6ubnRVQiu
         7S+7hG154iSDyvD+tV82scEu6uwjQnc3EikOx1CWGVjqE9NREKNPdczFMAdiqDseQhUQ
         1LvhhmAa/2/Mk8M58EUH+6ycg/zQ6dpMwENnyRlPn8vi8yFt62N6/Px0dSgls/8O8PCZ
         dZZVEa4NgBtuoiO+n32RScwGKqu+lTpzSKBk0Wp7pInJyemEB7uQxtTzP5xGBa93bsqH
         AZM6eMJSn2KZw8ZdT9ipo3e3XsOUddNZhFLkb2WjLHI0ccJfgybux1fTDUOhrXT4nFvl
         9XlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=cm97Gen0Peolk7PbK7fZk/pE/Z5g0ga5gF4LkfIAffY=;
        b=NRtDX+snmuH6hKIFbZsj36NIh9xxYyDfoqAAOkm7vs33zFkxhdt0idgy7QVoqOXLrW
         4OvtSZguMDor9XVH95S1bo6x1O559A+mT2vlKWDrZWh8imkgLzbVF93WEZfN4O6zjGmx
         QUsZV+frYgVy0NivzMR3EQKv/BJrPGK4nRxQKmq2dbDnj1JqU+2hmAXUzLviOI6R5pRR
         LdmdgkfyZT9wnW0jgxEajD6M3AxlTpR+TvhAs0ZFA6yQcQ21Do7AmNUzUw5WOxg9UQAz
         ICf2hDM+VxnHskqkdubfymrqiAKghLQ0CfrBeED2D+yZJeVKSln3TJfi35741NRA8Okf
         hSUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=g2XTwmM+;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=SlbND4CK;
       spf=pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1071eb88b5=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d65si4115382ybf.295.2019.06.17.08.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:42:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=g2XTwmM+;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=SlbND4CK;
       spf=pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1071eb88b5=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5HFYHFH005678;
	Mon, 17 Jun 2019 08:42:15 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=cm97Gen0Peolk7PbK7fZk/pE/Z5g0ga5gF4LkfIAffY=;
 b=g2XTwmM+1O2zICFm5KBIzRq1dlMRagj2wSN3NakWslpeuECS4CP7fjvpA1yv7yhXxFPT
 wm0rLCBkNo0LdpRpZ/OOTUpEiSfWTJ9k3hOH9kYzRTj15jSt+gAPCiYdEMSmmoChqojN
 CLaBARw9h1E+bqbu+1w1iNgFLCA0wG8ABIs= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t4x6dwnaa-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 17 Jun 2019 08:42:15 -0700
Received: from ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) by
 ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 17 Jun 2019 08:42:14 -0700
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 17 Jun 2019 08:42:14 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cm97Gen0Peolk7PbK7fZk/pE/Z5g0ga5gF4LkfIAffY=;
 b=SlbND4CK6nxz+kjyokqc4Yqjs3pWd42fO8UGouZj/57q13pg45s18YmN3BRt/zFCM6FYeuOlE2hwoCF3AKdT+yyCzRQl9GFTSxc5qfoZrGPcaccbsoc+xt6+zYVoWNr8npVjAlAKvUhfWN9fqzf7t5AYfybI3RleD+o7to2undc=
Received: from BYAPR15MB3479.namprd15.prod.outlook.com (20.179.60.19) by
 BYAPR15MB3304.namprd15.prod.outlook.com (20.179.58.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.13; Mon, 17 Jun 2019 15:42:13 +0000
Received: from BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9]) by BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9%5]) with mapi id 15.20.1987.014; Mon, 17 Jun 2019
 15:42:13 +0000
From: Rik van Riel <riel@fb.com>
To: Song Liu <songliubraving@fb.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>
CC: "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "Kernel
 Team" <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>,
        "chad.mynhier@oracle.com"
	<chad.mynhier@oracle.com>,
        "mike.kravetz@oracle.com"
	<mike.kravetz@oracle.com>
Subject: Re: [PATCH v2 3/3] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Topic: [PATCH v2 3/3] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Index: AQHVIt4n/b6ANYNXokW8VvvE1O4HGKagALOA
Date: Mon, 17 Jun 2019 15:42:13 +0000
Message-ID: <e4b7a74c400a8b337af0f019d770c96ba6a23675.camel@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
	 <20190614182204.2673660-4-songliubraving@fb.com>
In-Reply-To: <20190614182204.2673660-4-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR2201CA0027.namprd22.prod.outlook.com
 (2603:10b6:301:28::40) To BYAPR15MB3479.namprd15.prod.outlook.com
 (2603:10b6:a03:112::19)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:b340]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0af9ccdb-1f25-4e99-0282-08d6f33a5dd1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB3304;
x-ms-traffictypediagnostic: BYAPR15MB3304:
x-microsoft-antispam-prvs: <BYAPR15MB330499A0640788125E201E24A3EB0@BYAPR15MB3304.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0071BFA85B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(39860400002)(346002)(376002)(396003)(136003)(189003)(199004)(7736002)(102836004)(316002)(110136005)(6512007)(54906003)(52116002)(186003)(6506007)(53936002)(386003)(6486002)(76176011)(14444005)(71190400001)(256004)(36756003)(71200400001)(99286004)(86362001)(8676002)(476003)(46003)(446003)(5660300002)(11346002)(478600001)(2501003)(6246003)(25786009)(6436002)(8936002)(66556008)(81156014)(66446008)(64756008)(66476007)(73956011)(81166006)(66946007)(229853002)(14454004)(6116002)(2616005)(486006)(118296001)(68736007)(2906002)(4326008)(305945005)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3304;H:BYAPR15MB3479.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: xRc3kEBwaDggIDgu5tULsF2s2UdZ7YP+7lI8ijVD7tQPUSexbcHXCqFX8avTF9uSzTCNoPsRdXOC3EqFHVIUEwuq8FcCdsGL+R3TtSY1hte9E5BJ/dgVHhfMBXq6zwBUJ1GcCGMfWMlxI8/j7Xah4ywxpTJwk3GL/Gk+GW0kHXsiNXA5eq2TYFEonB2F4PoWlpsIs4jCV+D882lyWtmK5WwETleqP0xvOAwvbhw4D2rwGhhqkMRieeM7vgpOoN6dNelaO7u71a/jz31kZjvBDbJD43w163YJYogrja0ogOVvO5HenPCcGOor5tPHlAKC8SZ3q7huPJ2Vu1RuT+9ygB4zAxjysXws1OhC8LTYhjCFo3aIVBxckRqbbOVjzlTM8cSMag85D+RbGYBzuo+sL7RsbI9tSMwrfmVxwxXz24s=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2C548F79C9D32A4192305DEB1CA556C5@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0af9ccdb-1f25-4e99-0282-08d6f33a5dd1
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jun 2019 15:42:13.1882
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: riel@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3304
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=995 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170139
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTA2LTE0IGF0IDExOjIyIC0wNzAwLCBTb25nIExpdSB3cm90ZToNCj4gDQo+
ICsjaWZkZWYgQ09ORklHX1JFQURfT05MWV9USFBfRk9SX0ZTDQo+ICsJaWYgKHNobWVtX2ZpbGUo
dm1hLT52bV9maWxlKSB8fA0KPiArCSAgICAodm1hLT52bV9maWxlICYmICh2bV9mbGFncyAmIFZN
X0RFTllXUklURSkpKSB7DQo+ICsjZWxzZQ0KPiAgCWlmIChzaG1lbV9maWxlKHZtYS0+dm1fZmls
ZSkpIHsNCj4gKyNlbmRpZg0KPiAgCQlpZiAoIUlTX0VOQUJMRUQoQ09ORklHX1RSQU5TUEFSRU5U
X0hVR0VfUEFHRUNBQ0hFKSkNCj4gIAkJCXJldHVybiBmYWxzZTsNCg0KRnV0dXJlIGNsZWFudXAg
aWRlYTogY291bGQgaXQgYmUgbmljZSB0byBoaWRlIHRoZQ0KYWJvdmUgYmVoaW5kIGEgInZtYV9j
YW5faGF2ZV9maWxlX3RocCIgZnVuY3Rpb24gb3INCnNpbWlsYXI/DQoNClRoYXQgaW5saW5lIGZ1
bmN0aW9uIGNvdWxkIGFsc28gaGF2ZSBhIGNvbW1lbnQgZXhwbGFpbmluZw0Kd2h5IHRoZSBjaGVj
ayBpcyB0aGUgd2F5IGl0IGlzLg0KDQpPVE9ILCBJIGd1ZXNzIHRoaXMgc2VyaWVzIGlzIGp1c3Qg
dGhlIGZpcnN0IHN0ZXAgdG93YXJkcw0KbW9yZSBjb21wbGV0ZSBmdW5jdGlvbmFsaXR5LCBhbmQg
dGhpbmdzIGFyZSBsaWtlbHkgdG8gY2hhbmdlDQphZ2FpbiBzb29uKGlzaCkuDQoNCj4gQEAgLTE2
MjgsMTQgKzE2OTIsMTQgQEAgc3RhdGljIHZvaWQga2h1Z2VwYWdlZF9zY2FuX3NobWVtKHN0cnVj
dA0KPiBtbV9zdHJ1Y3QgKm1tLA0KPiAgCQkJcmVzdWx0ID0gU0NBTl9FWENFRURfTk9ORV9QVEU7
DQo+ICAJCX0gZWxzZSB7DQo+ICAJCQlub2RlID0ga2h1Z2VwYWdlZF9maW5kX3RhcmdldF9ub2Rl
KCk7DQo+IC0JCQljb2xsYXBzZV9zaG1lbShtbSwgbWFwcGluZywgc3RhcnQsIGhwYWdlLA0KPiBu
b2RlKTsNCj4gKwkJCWNvbGxhcHNlX2ZpbGUodm1hLCBtYXBwaW5nLCBzdGFydCwgaHBhZ2UsDQo+
IG5vZGUpOw0KPiAgCQl9DQo+ICAJfQ0KDQpJZiBmb3Igc29tZSByZWFzb24geW91IGVuZCB1cCBw
b3N0aW5nIGEgdjMgb2YgdGhpcw0Kc2VyaWVzLCB0aGUgcy9fc2htZW0vX2ZpbGUvIHJlbmFtaW5n
IGNvdWxkIGJlIGJyb2tlbg0Kb3V0IGludG8gaXRzIG93biBwYXRjaC4NCg0KQWxsIHRoZSBjb2Rl
IGxvb2tzIGdvb2QgdGhvdWdoLg0KDQpBY2tlZC1ieTogUmlrIHZhbiBSaWVsIDxyaWVsQHN1cnJp
ZWwuY29tPg0KDQo=

