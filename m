Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD801C43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:39:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57892214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:39:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bKw6yPv6";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="LKkNvN3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57892214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E4B936B0003; Wed, 19 Jun 2019 21:39:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFB908E0002; Wed, 19 Jun 2019 21:39:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC45A8E0001; Wed, 19 Jun 2019 21:39:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB8B36B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 21:39:36 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so1567943qtb.5
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:39:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=um3469+gwmDNhCFIBXksaGe9hNdu/7tjZMxiA/Nhy6Y=;
        b=BzMfAy+Xw1ul5et5VI31SRWvgYO0woZcRqW4AjOQcB1oIyix6uIW+uPHK6EjIwpnK0
         lkPGDSZJR/jSCYTs80PjNkQBxqdqbMI+WTje3kvH9uAm5x4CsM5/in8KukXocVWXIw8f
         Wx5JyIsUZTIYqnxAQWfLSyFRIlu+kOadTYWbuPkjCNj9H8Dtb7v4cFeTQOWs/PUZCxH4
         A3dvGqja9dCwIb7UqWkmkH1TjWjlvbH3WZolnNOTvt9AzBHE3JNyeqVK/Gv5TTU3ru74
         qE0vo1PB9G9CTYY3zVE8P6mQYca1gfFDT8mmV58Ku7u3blLuPRhhCCIHwtHCij2CTImy
         Dk2w==
X-Gm-Message-State: APjAAAXZOHi2GkOgwVbLIYBvpSWDFYlAqKSS77IyEFVV+tVfMS40n3GB
	q+5kbX5kmap86JET3qNFTzVjRQfB/hOoFgEIo3TBIrqPfe8G/sgSSQzfyn+8SwLTZiuyCRiRYBg
	LtaWuxmxvD3yvecimKSxr/mk4HFIbyS3Nsr6gFYj+Z+gZb5/XUkEAtDyOM1pKqcBjYg==
X-Received: by 2002:a37:624c:: with SMTP id w73mr12774719qkb.139.1560994776408;
        Wed, 19 Jun 2019 18:39:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxiDahrFd243tEwRr44HINw1zxAb3blPB2KZGWH4lqajOcfuJB1R+IDOsKU0YtFAxS7IQ6j
X-Received: by 2002:a37:624c:: with SMTP id w73mr12774689qkb.139.1560994775925;
        Wed, 19 Jun 2019 18:39:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560994775; cv=none;
        d=google.com; s=arc-20160816;
        b=fYQU/ik7VmnO2CPY+eImZCUKfkHxewrIMVlTLMxTysm/a1EFzli9NqI/+miDIqjYQH
         sG9fZf96RBvzfQoDHRva0mFVuzfW3b8XXmF1xKu75aAZK7N8sw1TeMvSTMr3GIML+stZ
         E5BcjkHGoH3Bzq/yVs9pZtDlSUGg15n7c4uPpL0nib2A5y6+jMcg+X2QltHhIJ9AWwLf
         lZIJCaNY7d/jNYri1ZPSOYlHf8q0i55z0ZgBBD3gYRbzJffGD2top802rM7d1MLxjRPu
         4+uOQuHjGoqqXVsltNuwg/MIGtpS409dlq6dxnbV5XZkZVbD1v1rGC2XtWfeMKkfxuce
         AGnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=um3469+gwmDNhCFIBXksaGe9hNdu/7tjZMxiA/Nhy6Y=;
        b=khajxC+z0jprcaTOo+FyMtKNKH33KiYGkATPQabx/bmiB2OYQnamWKkR7r4dAUZrnJ
         RnlPFDDLr8wK31vt5eK6Nv1QZ7bEePQxjSwyjxzLfTrO6NRCQyDW+Bfw7s71Gev4H80A
         Y5rsM0DlEHwz/3WBjBmcVpZPZl/7pTUfnM+RRJtwYYYmV8iUUo/JJEpJhTmYGPBavlIq
         pGhV8exy/6rXr4XAQBG9zkT5nnhinqUVlm4T7bmPJRZAiYHoakuevCX2ehsnunPtN2BP
         uJBWLMwT33Y6uZI2NZubsJ+Hfd1/4wpOGT0AcdqKoZDHUNpoCkbeJ85gZdItUiAw4uRE
         c7Lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bKw6yPv6;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=LKkNvN3n;
       spf=pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107484c082=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 34si3791519qtn.246.2019.06.19.18.39.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 18:39:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bKw6yPv6;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=LKkNvN3n;
       spf=pass (google.com: domain of prvs=107484c082=riel@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107484c082=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5K1cm1r015295;
	Wed, 19 Jun 2019 18:39:32 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=um3469+gwmDNhCFIBXksaGe9hNdu/7tjZMxiA/Nhy6Y=;
 b=bKw6yPv6bEWjEqR69wwmfVwNKnuEkU71unJeOHztArKc8rjqRo5Cl0695yRSZwbyxYNW
 1x80QVpjES/YgO+BKxP9HzbE6at2HXbEd5/qKgJMoFqThpEhAO/7xE5AO6yb9fS/gYFc
 4KsE+e5Dnaom9p8m3/HuQLShJ04gTQ26kY8= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t7wrv8hjw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Wed, 19 Jun 2019 18:39:32 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 19 Jun 2019 18:39:31 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Wed, 19 Jun 2019 18:39:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=um3469+gwmDNhCFIBXksaGe9hNdu/7tjZMxiA/Nhy6Y=;
 b=LKkNvN3n6KOIGcfhBuo1/NwdGXcjXnKytfz/xYMVRZbXyy9TBqoe+zIYRQ6sd22hN/E72bpANCdikYyoCtqOOTgYMEUM4w8sZnCdAc6BGwARDa9LxOkFcCsambFXz5/sIV87Y5PTfp23tDzY4hSNqAzRMhH4HNlQqSudhpGcMmI=
Received: from BYAPR15MB3479.namprd15.prod.outlook.com (20.179.60.19) by
 BYAPR15MB3158.namprd15.prod.outlook.com (20.178.207.219) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.15; Thu, 20 Jun 2019 01:39:30 +0000
Received: from BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9]) by BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9%5]) with mapi id 15.20.1987.014; Thu, 20 Jun 2019
 01:39:29 +0000
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
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>
Subject: Re: [PATCH v3 6/6] mm,thp: handle writes to file with THP in
 pagecache
Thread-Topic: [PATCH v3 6/6] mm,thp: handle writes to file with THP in
 pagecache
Thread-Index: AQHVJmfNp6psayhKU0eYRk6mGJngP6ajxSoA
Date: Thu, 20 Jun 2019 01:39:29 +0000
Message-ID: <9ec5787861152deb1c6c6365b593343b3aef18d4.camel@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
	 <20190619062424.3486524-7-songliubraving@fb.com>
In-Reply-To: <20190619062424.3486524-7-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR07CA0074.namprd07.prod.outlook.com (2603:10b6:100::42)
 To BYAPR15MB3479.namprd15.prod.outlook.com (2603:10b6:a03:112::19)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:93c4]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bc999f67-7de7-4692-8d68-08d6f52022f2
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB3158;
x-ms-traffictypediagnostic: BYAPR15MB3158:
x-microsoft-antispam-prvs: <BYAPR15MB3158E9A989F4BC919BBEC5C0A3E40@BYAPR15MB3158.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0074BBE012
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(39860400002)(346002)(396003)(136003)(199004)(189003)(86362001)(66946007)(66476007)(25786009)(53936002)(71190400001)(71200400001)(5660300002)(7736002)(73956011)(14454004)(54906003)(2501003)(4744005)(66446008)(316002)(305945005)(64756008)(66556008)(110136005)(446003)(476003)(6506007)(386003)(46003)(102836004)(4326008)(76176011)(478600001)(118296001)(6116002)(11346002)(36756003)(2616005)(6246003)(2906002)(6512007)(99286004)(256004)(81166006)(186003)(486006)(81156014)(8676002)(229853002)(52116002)(68736007)(6436002)(6486002)(8936002)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3158;H:BYAPR15MB3479.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: UzYDVp+cJDcgKOt7FY6Df8lWZMY0i+CY+k3RsQz39q/2wgMMsLIosFyKec0M9hcMUOHcKuUohp59OuDioHziCIzvyVWZ/x1CnexLCehk4dlp87KQP1Z7Tb/CgXdbyLGvUo590zjI1Nfb0onLDRZcLpO8UGn8e0qwuQw/W1PTL2vJSFUerWDBCUzV4Vmi2QicCKoEvXdStUQwN+WtpMKyMzV29FqerxXrSYhGSckpXGsMskyZJ4Q7ntZOzpjMQvyIZCWF2uyQiJomWrHY/TEp6+2LpyAtnXxtcb5Q3Gk9/NEFd3D7QIPGUFwirD9aWkth1AIJ7uuBkPbYGGbLR2SumDGgnhqpacKgk2WH1kwKNdfID2FmelkDTzVrB/Ru1WXJ/An57FLqPMJkAjaZrjGokcOooqojC48flPmHzIDw3iQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <08C645ED4B8C214396EBFF7A5717C3BB@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: bc999f67-7de7-4692-8d68-08d6f52022f2
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Jun 2019 01:39:29.7621
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: riel@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3158
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=694 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200010
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gVHVlLCAyMDE5LTA2LTE4IGF0IDIzOjI0IC0wNzAwLCBTb25nIExpdSB3cm90ZToNCg0KPiBp
bmRleCA4NTYzMzM5MDQxZjYuLmJhYjhkOWVlZjQ2YyAxMDA2NDQNCj4gLS0tIGEvbW0vdHJ1bmNh
dGUuYw0KPiArKysgYi9tbS90cnVuY2F0ZS5jDQo+IEBAIC03OTAsNyArNzkwLDExIEBAIEVYUE9S
VF9TWU1CT0xfR1BMKGludmFsaWRhdGVfaW5vZGVfcGFnZXMyKTsNCj4gIHZvaWQgdHJ1bmNhdGVf
cGFnZWNhY2hlKHN0cnVjdCBpbm9kZSAqaW5vZGUsIGxvZmZfdCBuZXdzaXplKQ0KPiAgew0KPiAg
CXN0cnVjdCBhZGRyZXNzX3NwYWNlICptYXBwaW5nID0gaW5vZGUtPmlfbWFwcGluZzsNCj4gLQls
b2ZmX3QgaG9sZWJlZ2luID0gcm91bmRfdXAobmV3c2l6ZSwgUEFHRV9TSVpFKTsNCj4gKwlsb2Zm
X3QgaG9sZWJlZ2luOw0KPiArDQo+ICsJLyogaWYgbm9uLXNobWVtIGZpbGUgaGFzIHRocCwgdHJ1
bmNhdGUgdGhlIHdob2xlIGZpbGUgKi8NCj4gKwlpZiAoZmlsZW1hcF9ucl90aHBzKG1hcHBpbmcp
KQ0KPiArCQluZXdzaXplID0gMDsNCj4gIA0KDQpJIGRvbid0IGdldCBpdC4gU29tZXRpbWVzIHRy
dW5jYXRlIGlzIHVzZWQgdG8NCmluY3JlYXNlIHRoZSBzaXplIG9mIGEgZmlsZSwgb3IgdG8gY2hh
bmdlIGl0DQp0byBhIG5vbi16ZXJvIHNpemUuDQoNCldvbid0IGZvcmNpbmcgdGhlIG5ld3NpemUg
dG8gemVybyBicmVhayBhcHBsaWNhdGlvbnMsDQp3aGVuIHRoZSBmaWxlIGlzIHRydW5jYXRlZCB0
byBhIGRpZmZlcmVudCBzaXplIHRoYW4NCnRoZXkgZXhwZWN0Pw0KDQo=

