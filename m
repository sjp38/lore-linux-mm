Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05B23C32754
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:00:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 995C42173C
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 21:00:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="rkY63cCL";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="DtmIAD85"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 995C42173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 403926B0006; Wed,  7 Aug 2019 17:00:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DA036B0007; Wed,  7 Aug 2019 17:00:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27AD46B0008; Wed,  7 Aug 2019 17:00:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id F3E186B0006
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 17:00:24 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id w5so57265768otg.0
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 14:00:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=FVEBqFCXL6J5Qcz9g2gmVhbzz55Sd3XZHOqZS/GTCTU=;
        b=ACqDka3MH+nYUYQjFz5um0KRLMNjkXmOlDQczTa3Bn5kN/taLupELGJr3/9R2fBmcj
         wBhizjeLUho1s5PxxPHZoC/0pqEOk8cvxOVYecItx0VRVBtYpVg68syBZAfE3O2JGjJ6
         AJjNv8den0KqjZZ3rnA2D8mfO+z2R9clUPAGb4nU3WvtmvtzW+6q2MSXnjb5D7GrguAF
         Lo+c8V15VLVVBslplWjq7GVPkUxEFduoCro7AV9vCSOz3MBynu8fdTAv1oqwWJN5qf9I
         gd7nkeRqXmjIWsVNIN3xrohvbWvepIDAOKlSOHzq7+5HGljDSKYpC9RJXQa4TkFUSh3Q
         n3Lg==
X-Gm-Message-State: APjAAAWk5Y0RleSkwPLKz0L4O2gZLyxhKcrrhl3eF7tbPktciAJpI2Yf
	JKUL6/584YNc1eBOH5i/fk3Tp/nK8YU4FBy6D23tHiV8XcEHmylIhCMlnpXYXsRkOwsZg/KYhCd
	0d7qDIHujZ6ilyaNQzAv8SX40reGUM9FPg1gdh0Hd6O3EGZicrQ6YyvaFcBVQTif9mA==
X-Received: by 2002:a5e:8913:: with SMTP id k19mr10637638ioj.155.1565211624543;
        Wed, 07 Aug 2019 14:00:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxU3qaEyfAg7uIDjPhXkvhti37xK6aH3+NMZSyv9od/DqNRFOsS0Jjp0PFacQj8UOKgcJnQ
X-Received: by 2002:a5e:8913:: with SMTP id k19mr10637588ioj.155.1565211623887;
        Wed, 07 Aug 2019 14:00:23 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565211623; cv=pass;
        d=google.com; s=arc-20160816;
        b=IKDvFqsLVWsM8WwEEsKnT/1AE03GvHzpxa2Tk+/onbvmtc2LozwZJlc169afTvBn3f
         44MUS/RDBGzYHUkjepPUO/uQ+iF19lqxD7EqU/rmgdzpHDDrkhxrS7S2To+W67wHboB2
         GrhqgVcsNWO6LuZ9Az5yIcAuLTCoaIPNRmfds/RCexnV9PjX5Moo+uCHDwRcLxrbity5
         mZLRYbdMX28w8GN1m0oI8ar2vp617ov7aFJXZ0n96tnQbHGPnfUOgzW0WDPs+FprrMLT
         j1RNOyDuaszMOGfYkvrTWryvjNh1iGdkM3AN2h58kQ5ym/rmkAmAv/GwxOXU9sDCJWXo
         YAzQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=FVEBqFCXL6J5Qcz9g2gmVhbzz55Sd3XZHOqZS/GTCTU=;
        b=a+O74kCimnuCKW4zRp+ddI8uJwCtRpeUUonM1NjNgQ59iegeIH7amzviOWFfWULIzt
         fez5lrJhs2WhMD/BKrkdOdswUbBSdKEuMnY/Q7t9a6BguBiIgBxGoPWLRi8b4DI0LZMk
         OrL4StT1p4+cEYQJqHFIe3PUFhwlEw7qmqOuiGABYtIQ5RRCZO/+9Ay9fpMQ/G72ylrJ
         i9PrYuhxqM9W3WFvxNYHEoOJmSOcPNZ0KFGhYGRbj8UbujKaRRwouQ2E4TeBVjio+1pE
         1JexgXVUEXndJh2crRdA0ogLcmHP0pXk0ZVtO2VRojcpenojbub4BBZXpxfclVCq+e9l
         9B/w==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rkY63cCL;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=DtmIAD85;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h11si31342640ior.160.2019.08.07.14.00.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 14:00:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=rkY63cCL;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=DtmIAD85;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31225916b7=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31225916b7=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x77KvngX032365;
	Wed, 7 Aug 2019 14:00:07 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=FVEBqFCXL6J5Qcz9g2gmVhbzz55Sd3XZHOqZS/GTCTU=;
 b=rkY63cCLsBw7f5Onc6GR+/VxTb6t99P4zVnAxkkpbgrCsC6xre2369bjvlLBP1G8ud2T
 ku70sC+NKCpvx81IM22eNm1ocRWVrqtxhXimN2kKk4mXtlZcN0x8nv0jaHiPgnjOdKGS
 jo0CMxwo++/AUEDGcfwH4OJlwfmhlgVlPNI= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u829r101p-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 07 Aug 2019 14:00:07 -0700
Received: from prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 7 Aug 2019 14:00:06 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx08.TheFacebook.com (2620:10d:c081:6::22) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 7 Aug 2019 14:00:06 -0700
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 7 Aug 2019 14:00:06 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=mQSKsVQ+q8DJGvnr1QGWnoR4PehsJuOziMuCYJjo410wm6XJyH1iOAWzu62kIkqhCv41Q5RVZqx/EUUETeWflRlZ5pPc4oGwuGf6WU7ykZnKx7KSdjArDPewNSg2SKdzT7WRgFj8fYJDyKR515+BjYGT+Nt7e3G2ROLIe5JPiBozrsOJsgNJYN/S4MQsUJuj4adQ176jtUZJuyt7AZLBGeMxYE9fpzyMJgVV2cxWITl6zWn7GxAWd/5wZ5p+w5uKL1O+4zBOM1tVQA/Acvbr//ezgl2EUGoPQuF3Q4aY1EsGLKsk9SLalu7EOj8Lhp3haWyWX0XNc3cbVmFcDhU3wQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FVEBqFCXL6J5Qcz9g2gmVhbzz55Sd3XZHOqZS/GTCTU=;
 b=QviLqFYpAcdPHhtxXMpGZuG/iCS8qBLpsOebjLzatXvMguZMnXN+iVjPkNp27VtSmnK5Jz+fy/T/6JmO7U1MyP2NX19HwLhVs5Liu0TeigP+hOZzx8Nff7KEtMpG7pNSGLY2kHe+zYEthH6RdMs9VuvKOGDalNVdbOyjJOCdDjAmf49HzM6bI9LCXxg33euuAeHZRP1cu07JEU1NK0/GFe8qkiZNhLjv/lX84OAG7XncXbtn5Z96N9hY7tsG3MR8H4dvxBwr5+SWexW3htDY6rD/OSoBS+OvMwsE2l0ejk+AOma0Nxhj6U8D2OGzx2ZyTSd4HzvRViALCXUjsODJUw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=FVEBqFCXL6J5Qcz9g2gmVhbzz55Sd3XZHOqZS/GTCTU=;
 b=DtmIAD85tSgcD+1vmTo3LxgJeks5usKo5JUpp3oIY02q+/L55rn2fSpka/k1fKP+UUsOosJ5txTwLVA/TMYKmLwQoc3Mm59Ad0utd+NQL/EAJQVQDWUSh2YnppiL0I1RC8pagBQ7uDsS4Ju6im8AMnlfveoyjbrLKQ6namfBZIQ=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1214.namprd15.prod.outlook.com (10.175.2.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.14; Wed, 7 Aug 2019 21:00:05 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d%9]) with mapi id 15.20.2136.018; Wed, 7 Aug 2019
 21:00:05 +0000
From: Song Liu <songliubraving@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Randy Dunlap <rdunlap@infradead.org>,
        Stephen Rothwell
	<sfr@canb.auug.org.au>,
        Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM
	<linux-mm@kvack.org>
Subject: Re: linux-next: Tree for Aug 7 (mm/khugepaged.c)
Thread-Topic: linux-next: Tree for Aug 7 (mm/khugepaged.c)
Thread-Index: AQHVTTJXJMBKk+9UcEyVbeuM3CTH0abv6HuAgAA1cYCAAA3aAA==
Date: Wed, 7 Aug 2019 21:00:04 +0000
Message-ID: <BB7412DE-A88E-41A4-9796-5ECEADE31571@fb.com>
References: <20190807183606.372ca1a4@canb.auug.org.au>
 <c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
 <DCC6982B-17EF-4143-8CE8-9D0EC28FA06B@fb.com>
 <20190807131029.f7f191aaeeb88cc435c6306f@linux-foundation.org>
In-Reply-To: <20190807131029.f7f191aaeeb88cc435c6306f@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:1a00]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4f6e5c6a-0ec0-423a-951a-08d71b7a38fe
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1214;
x-ms-traffictypediagnostic: MWHPR15MB1214:
x-ms-exchange-purlcount: 3
x-microsoft-antispam-prvs: <MWHPR15MB1214B7EF9EFF05406873865EB3D40@MWHPR15MB1214.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5797;
x-forefront-prvs: 01221E3973
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(396003)(136003)(346002)(39860400002)(51914003)(53754006)(199004)(189003)(25786009)(50226002)(6512007)(8936002)(11346002)(6506007)(14454004)(6306002)(478600001)(33656002)(6486002)(446003)(53936002)(71190400001)(81166006)(71200400001)(6246003)(81156014)(4326008)(966005)(76176011)(102836004)(2906002)(53546011)(6436002)(86362001)(5660300002)(6916009)(229853002)(99286004)(7736002)(76116006)(305945005)(486006)(64756008)(57306001)(66556008)(476003)(6116002)(66946007)(66476007)(256004)(66446008)(36756003)(54906003)(316002)(46003)(186003)(2616005)(8676002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1214;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: WeWT4P2n60WCP05TRgl1LF6AiU0kxTBDpiNeGmMDEZjY6OBf6Fj6azIv63YdPt0dNkjZpVn4yMsGaGKoqMKebm/aTUyUbef1etHJb2v4F2qEKDj7c04UnRp9SjoZEexAJd8tLwzvZtAtuCdobBDSZSf8etOyDrRj34EQBne0Bu6X/CkOT7ScwwycSAsaTybXD2f4Zwc4drbidhvVsO8oYdonjgnehQGlabI8eZuvDypWfBkrumbgjGbIpUlbj1vyLPKOMlD4Gp3dcCk5OJYKoRVJ1iHxDWqVIdu/M+eDE3fk2majYttADidWFDTa4WW3yeYDsMUowqHuimIllGfQvRVoNOZG+uaNxbagnBMsCSDJUW99OIR46AbMH4xYRajsSn1lU8L6AHhNc4DwKwmne0iwW/BUZTJ4S1oo0ePiZE4=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="utf-8"
Content-ID: <F6C6AD2191BC524F86262198ADB0C98A@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 4f6e5c6a-0ec0-423a-951a-08d71b7a38fe
X-MS-Exchange-CrossTenant-originalarrivaltime: 07 Aug 2019 21:00:05.0083
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1214
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-07_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908070182
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

SGkgQW5kcmV3LA0KDQo+IE9uIEF1ZyA3LCAyMDE5LCBhdCAxOjEwIFBNLCBBbmRyZXcgTW9ydG9u
IDxha3BtQGxpbnV4LWZvdW5kYXRpb24ub3JnPiB3cm90ZToNCj4gDQo+IE9uIFdlZCwgNyBBdWcg
MjAxOSAxNjo1OToxNCArMDAwMCBTb25nIExpdSA8c29uZ2xpdWJyYXZpbmdAZmIuY29tPiB3cm90
ZToNCj4gDQo+PiBIaSBSYW5keSwNCj4+IA0KPj4+IE9uIEF1ZyA3LCAyMDE5LCBhdCA4OjExIEFN
LCBSYW5keSBEdW5sYXAgPHJkdW5sYXBAaW5mcmFkZWFkLm9yZz4gd3JvdGU6DQo+Pj4gDQo+Pj4g
T24gOC83LzE5IDE6MzYgQU0sIFN0ZXBoZW4gUm90aHdlbGwgd3JvdGU6DQo+Pj4+IEhpIGFsbCwN
Cj4+Pj4gDQo+Pj4+IENoYW5nZXMgc2luY2UgMjAxOTA4MDY6DQo+Pj4+IA0KPj4+IA0KPj4+IG9u
IGkzODY6DQo+Pj4gDQo+Pj4gd2hlbiBDT05GSUdfU0hNRU0gaXMgbm90IHNldC9lbmFibGVkOg0K
Pj4+IA0KPj4+IC4uL21tL2todWdlcGFnZWQuYzogSW4gZnVuY3Rpb24g4oCYa2h1Z2VwYWdlZF9z
Y2FuX21tX3Nsb3TigJk6DQo+Pj4gLi4vbW0va2h1Z2VwYWdlZC5jOjE4NzQ6MjogZXJyb3I6IGlt
cGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uIOKAmGtodWdlcGFnZWRfY29sbGFwc2VfcHRl
X21hcHBlZF90aHBz4oCZOyBkaWQgeW91IG1lYW4g4oCYY29sbGFwc2VfcHRlX21hcHBlZF90aHDi
gJk/IFstV2Vycm9yPWltcGxpY2l0LWZ1bmN0aW9uLWRlY2xhcmF0aW9uXQ0KPj4+IGtodWdlcGFn
ZWRfY29sbGFwc2VfcHRlX21hcHBlZF90aHBzKG1tX3Nsb3QpOw0KPj4+IF5+fn5+fn5+fn5+fn5+
fn5+fn5+fn5+fn5+fn5+fn5+fn5+DQo+PiANCj4+IFRoYW5rcyBmb3IgdGhlIHJlcG9ydC4gDQo+
PiANCj4+IFNoYWxsIEkgcmVzZW5kIHRoZSBwYXRjaCwgb3Igc2hhbGwgSSBzZW5kIGZpeCBvbiB0
b3Agb2YgY3VycmVudCBwYXRjaD8NCj4gDQo+IEVpdGhlciBpcyBPSy4gIElmIHRoZSBkaWZmZXJl
bmNlIGlzIHNtYWxsIEkgd2lsbCB0dXJuIGl0IGludG8gYW4NCj4gaW5jcmVtZW50YWwgcGF0Y2gg
c28gdGhhdCBJIChhbmQgb3RoZXJzKSBjYW4gc2VlIHdoYXQgY2hhbmdlZC4NCg0KUGxlYXNlIGZp
bmQgdGhlIHBhdGNoIHRvIGZpeCB0aGlzIGF0IHRoZSBlbmQgb2YgdGhpcyBlbWFpbC4gSXQgYXBw
bGllcyANCnJpZ2h0IG9uIHRvcCBvZiAia2h1Z2VwYWdlZDogZW5hYmxlIGNvbGxhcHNlIHBtZCBm
b3IgcHRlLW1hcHBlZCBUSFAiLiANCkl0IG1heSBjb25mbGljdCBhIGxpdHRsZSB3aXRoIHRoZSAi
RW5hYmxlIFRIUCBmb3IgdGV4dCBzZWN0aW9uIG9mIA0Kbm9uLXNobWVtIGZpbGVzIiBzZXQsIHdo
aWNoIHJlbmFtZXMgZnVuY3Rpb24ga2h1Z2VwYWdlZF9zY2FuX3NobWVtKCkuIA0KDQpBbHNvLCBJ
IGZvdW5kIHYzIG9mIHRoZSBzZXQgaW4gbGludXgtbmV4dC4gVGhlIGxhdGVzdCBpcyB2NDoNCg0K
aHR0cHM6Ly9sa21sLm9yZy9sa21sLzIwMTkvOC8yLzE1ODcNCmh0dHBzOi8vbGttbC5vcmcvbGtt
bC8yMDE5LzgvMi8xNTg4DQpodHRwczovL2xrbWwub3JnL2xrbWwvMjAxOS84LzIvMTU4OQ0KDQpU
aGFua3MsDQpTb25nDQoNCj09PT09PT09IDg8ID09PT09PT09PT09DQoNCkZyb20gMjY3MTVjOTIz
ZjZjZDI4M2EyOTUwY2ZkMGE3Y2NhNDgzYTNlYjQwNiBNb24gU2VwIDE3IDAwOjAwOjAwIDIwMDEN
CkZyb206IFNvbmcgTGl1IDxzb25nbGl1YnJhdmluZ0BmYi5jb20+DQpEYXRlOiBXZWQsIDcgQXVn
IDIwMTkgMTA6MjE6MzAgLTA3MDANClN1YmplY3Q6IFtQQVRDSF0ga2h1Z2VwYWdlZDogZml4IGJ1
aWxkIHdpdGhvdXQgQ09ORklHX1NITUVNDQoNCldpdGhvdXQgQ09ORklHX1NITUVNLCB3ZSBuZWVk
IGR1bW15IGtodWdlcGFnZWRfY29sbGFwc2VfcHRlX21hcHBlZF90aHBzLg0KDQpTaWduZWQtb2Zm
LWJ5OiBTb25nIExpdSA8c29uZ2xpdWJyYXZpbmdAZmIuY29tPg0KLS0tDQogbW0va2h1Z2VwYWdl
ZC5jIHwgNSArKysrKw0KIDEgZmlsZSBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKykNCg0KZGlmZiAt
LWdpdCBhL21tL2todWdlcGFnZWQuYyBiL21tL2todWdlcGFnZWQuYw0KaW5kZXggYmEzNmZmNWMx
ZDgyLi4wODYzMjMxMTJjMDcgMTAwNjQ0DQotLS0gYS9tbS9raHVnZXBhZ2VkLmMNCisrKyBiL21t
L2todWdlcGFnZWQuYw0KQEAgLTE3NjQsNiArMTc2NCwxMSBAQCBzdGF0aWMgdm9pZCBraHVnZXBh
Z2VkX3NjYW5fc2htZW0oc3RydWN0IG1tX3N0cnVjdCAqbW0sDQogew0KICAgICAgICBCVUlMRF9C
VUcoKTsNCiB9DQorDQorc3RhdGljIGludCBraHVnZXBhZ2VkX2NvbGxhcHNlX3B0ZV9tYXBwZWRf
dGhwcyhzdHJ1Y3QgbW1fc2xvdCAqbW1fc2xvdCkNCit7DQorICAgICAgIHJldHVybiAwOw0KK30N
CiAjZW5kaWYNCg0KIHN0YXRpYyB1bnNpZ25lZCBpbnQga2h1Z2VwYWdlZF9zY2FuX21tX3Nsb3Qo
dW5zaWduZWQgaW50IHBhZ2VzLA0KLS0NCjIuMTcuMQ0KDQo=

