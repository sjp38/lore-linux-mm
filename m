Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A3C3C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:59:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEA772084A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:59:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bO8WY6RX";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Ed7riDJV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEA772084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 561808E0002; Mon, 17 Jun 2019 10:59:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5111E8E0001; Mon, 17 Jun 2019 10:59:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B1D88E0002; Mon, 17 Jun 2019 10:59:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 182EE8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:59:49 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id c3so3440430ybo.9
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:59:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=D1iQ1jUZXB1iiy5jMLu8cNhJA+dQPKTWV16ZfzYeJek=;
        b=J7z57QkVp54NO6zlJVSY5SPjmNkqzFQ2RFq6wBh0wJMU0rhO1dsRTXgi4nVXbECpZ1
         iYojlxkllt71HhGix8R8YqI6QMwlesvZJBMCnE8LUlTKasWRgAAjvl9lyznPWogN6TdU
         gXG3AE3Dz4Fgux2Y5c8/MndrLHcQHyh1wlatvfaOEZ3NYJr4YMkp/gNe+rSxwmKJI252
         FV1jDLt6LIdAKbacT7nA8Yw8p2Rg86kEF4dq7vKwy0PEQSJL9CaZ7ErA+vcUaraWu/WF
         Il4JiaAl5P1ibaWlLFpRYgVlKYb+nJ1DmXerAWkPlPYniGSrX1fii7qGL+m1JtQsNsaf
         h6Aw==
X-Gm-Message-State: APjAAAUTz+xlRusM1ISj4brHP5NTuVnKYKiYO0Q4W6PDnerlbBHhzFy1
	EzP6Tx603u2i0724D+JP9SEDe/shllfOVh1vPkxUW7fLXSfhBjTflvdU0lZGa5zQPakPLbNHxQo
	XSJPGLYJS3e2kVXqI1uh7BN1V5kphmI8OrYfeb5vtK10pmcqoA+KD5TovzIeoiALkIg==
X-Received: by 2002:a05:6902:513:: with SMTP id x19mr55335057ybs.486.1560783588799;
        Mon, 17 Jun 2019 07:59:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzV/URhQGXmQsTeMX4rzyP/V5PRk/oIkyloxUhGF5PDZLD4bE4MXqIWbFMfBadqQRxyzvn8
X-Received: by 2002:a05:6902:513:: with SMTP id x19mr55335028ybs.486.1560783588288;
        Mon, 17 Jun 2019 07:59:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560783588; cv=none;
        d=google.com; s=arc-20160816;
        b=bRH6ylDu/A28RTGvc4mFc9rQfehhi+hgeeyHPq5jHb4aA+P3p8nqlhqX7wZyBMNIya
         bUJysRmPgC72TaDeJc7TxO+PrJuocbceCcejFkCumLoCTkZ07OyPmEDrU9D1jOkjO02L
         M4QoW+4AXosMmq/f18xbrv3jCHZ+9Z1A1eN1OWQaBY/qtI6YBYA28zSabhlDqlN/ONGw
         oTgHGKZcD6koIBVH3NEP6kAYdiTnaw9A7XuOOahg+M1O4tujU2iacdu3rvvPxdqk24tk
         JqKt4laIqnOAnZEAYsYaEFEXtXFTS7YgZC/qbNNZywk6/dQ34e3bzGmC7c+wGWZKFmGQ
         hmxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=D1iQ1jUZXB1iiy5jMLu8cNhJA+dQPKTWV16ZfzYeJek=;
        b=QbbNIFac7a126O/lCJLCcQp60QLviIEP7T50Cc2zmivwtK59KvcIeEq9NxGm1Wix4r
         mvZ40v8cIKJopK6KOl7idhovCB2pmEOa1/20RMBmGhpHWXZShTjfZiOL3Agpvrzcg+Ed
         qzfrLKc2SZquv/MeanzExvVLI+XqctwdYpw/xM4UJaSTSTwh5uXaqLtk8bhYj8dALyVV
         Iy7B29qKbNlv8li2UOnQ1lB0M8P9z+oNfF3zdvS7nmwpYs3rwLSxfG0okl/CfHOBCO5a
         lg3rShddA8S8qwbeb4i0SJbXYeZ5VPaG8l3pmPr3y59v8HZ6LYuqO0hmVb0Tebg8SYlf
         wEyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bO8WY6RX;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Ed7riDJV;
       spf=pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1071eb88b5=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u83si4458954ywf.231.2019.06.17.07.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 07:59:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bO8WY6RX;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=Ed7riDJV;
       spf=pass (google.com: domain of prvs=1071eb88b5=riel@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1071eb88b5=riel@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5HEvgjV025250;
	Mon, 17 Jun 2019 07:59:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=D1iQ1jUZXB1iiy5jMLu8cNhJA+dQPKTWV16ZfzYeJek=;
 b=bO8WY6RX4CA6QqkT8WzilJwLq2Zk1JfmDowYwoIsY9wtW7hx4G0Sk/JEoX214tNOCxRX
 KzhZoc3rjKj0MLuU1SDoRZb6QVoZJK1Uzt85gNDZaz32jCOxl94ue7o4yrB2OP39xmOZ
 AB5cEMtCwaD/BtbasQceMlVsUpm/5XDB70o= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t68j7rufu-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 17 Jun 2019 07:59:47 -0700
Received: from prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 17 Jun 2019 07:59:45 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 17 Jun 2019 07:59:45 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 17 Jun 2019 07:59:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=D1iQ1jUZXB1iiy5jMLu8cNhJA+dQPKTWV16ZfzYeJek=;
 b=Ed7riDJVYlEnoSe6NZVED6bsV7bUG3VCSYYqScFoLUy88X4cCWzCvnRLBUyYpLGneA8Dmmwn/YlJ0VlTV2qSl+T9qQ+8ftixKgfjoODP1IKnh3aoczPhCg6C0TL/5uLtPJRSkZ6ZQ21mQ2E51GwtUBXuNd3H1OYNZkl31GTdBkc=
Received: from BYAPR15MB3479.namprd15.prod.outlook.com (20.179.60.19) by
 BYAPR15MB2998.namprd15.prod.outlook.com (20.178.238.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.10; Mon, 17 Jun 2019 14:59:44 +0000
Received: from BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9]) by BYAPR15MB3479.namprd15.prod.outlook.com
 ([fe80::2569:19ec:512f:fda9%5]) with mapi id 15.20.1987.014; Mon, 17 Jun 2019
 14:59:44 +0000
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
Subject: Re: [PATCH v2 1/3] mm: check compound_head(page)->mapping in
 filemap_fault()
Thread-Topic: [PATCH v2 1/3] mm: check compound_head(page)->mapping in
 filemap_fault()
Thread-Index: AQHVIt4ueeA1dwci/UySuFvmcB0bH6af9M6A
Date: Mon, 17 Jun 2019 14:59:44 +0000
Message-ID: <e42171487882dfaf4182af0def0e31df64e11d93.camel@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
	 <20190614182204.2673660-2-songliubraving@fb.com>
In-Reply-To: <20190614182204.2673660-2-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: QB1PR01CA0018.CANPRD01.PROD.OUTLOOK.COM
 (2603:10b6:c00:2d::31) To BYAPR15MB3479.namprd15.prod.outlook.com
 (2603:10b6:a03:112::19)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:b340]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ba2c4634-bdce-4a06-0c06-08d6f3346e96
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB2998;
x-ms-traffictypediagnostic: BYAPR15MB2998:
x-microsoft-antispam-prvs: <BYAPR15MB299813FEF0280882F337AC17A3EB0@BYAPR15MB2998.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:2089;
x-forefront-prvs: 0071BFA85B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(396003)(39860400002)(346002)(136003)(189003)(199004)(476003)(52116002)(54906003)(305945005)(2501003)(316002)(76176011)(386003)(6506007)(102836004)(14454004)(118296001)(110136005)(7736002)(86362001)(81156014)(8676002)(81166006)(2906002)(5660300002)(478600001)(6246003)(36756003)(186003)(6512007)(46003)(8936002)(66446008)(64756008)(66556008)(11346002)(446003)(66476007)(68736007)(4326008)(99286004)(4744005)(6486002)(6436002)(6116002)(71190400001)(71200400001)(53936002)(229853002)(66946007)(486006)(73956011)(25786009)(2616005)(256004);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2998;H:BYAPR15MB3479.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 6/9vyIiUpLFqkCQrErXeOZKzxzLlrQtlE5EWnML1TBRGKW+k6JibsdO/B+oBWKeptBsQATlgrv2VvVBCidX5SPCDwp+Y7xHp3llf/8gsoN/OSvoH/rQ024IymdQ8Ja5fUctxEeDz2ekAKOqM71eT4mb2uUCqMn4gzOHI2PhZ9/czoqPJRJHwjUeuYxF9PKr23g97XdkB22dNKT40ADEpuqLW5dUORVIY5uiNTwKhHH7LB7k51v2XLlsqQxAMBha2Vlu8ZBKHffNBKG41Nz2TylRMvYsiSQg1gDSQ3CKCxaUamur7YF/QnZIIRsWWzjbrEcSqvK1PqIz1vgRmejs2t03Frr53UWYuIfvLCYlGPNrohdAQ4oKEH1ygnz3qZJ+vQOQWW5c0BOU1s9XFq6039hBg5sXRCOLsQR/Zo5mR5FM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <AD9ED7AD04ADD445BDBACF88B05C3E72@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: ba2c4634-bdce-4a06-0c06-08d6f3346e96
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Jun 2019 14:59:44.3957
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: riel@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2998
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-17_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=773 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906170135
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

T24gRnJpLCAyMDE5LTA2LTE0IGF0IDExOjIyIC0wNzAwLCBTb25nIExpdSB3cm90ZToNCj4gQ3Vy
cmVudGx5LCBmaWxlbWFwX2ZhdWx0KCkgYXZvaWRzIHRyYWNlIGNvbmRpdGlvbiB3aXRoIHRydW5j
YXRlIGJ5DQo+IGNoZWNraW5nIHBhZ2UtPm1hcHBpbmcgPT0gbWFwcGluZy4gVGhpcyBkb2VzIG5v
dCB3b3JrIGZvciBjb21wb3VuZA0KPiBwYWdlcy4gVGhpcyBwYXRjaCBsZXQgaXQgY2hlY2sgY29t
cG91bmRfaGVhZChwYWdlKS0+bWFwcGluZyBpbnN0ZWFkLg0KPiANCj4gU2lnbmVkLW9mZi1ieTog
U29uZyBMaXUgPHNvbmdsaXVicmF2aW5nQGZiLmNvbT4NCg0KQWNrZWQtYnk6IFJpayB2YW4gUmll
bCA8cmllbEBzdXJyaWVsLmNvbT4NCg0K

