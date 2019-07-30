Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A62DC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:40:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FACB20693
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 18:40:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="RLGTbz1o";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Ep3U/KS3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FACB20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A1DA8E0003; Tue, 30 Jul 2019 14:40:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9799D8E0001; Tue, 30 Jul 2019 14:40:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F33B8E0003; Tue, 30 Jul 2019 14:40:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0AD8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 14:40:01 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id u5so32283465wrp.10
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:40:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=AUwSPm4smgaC06dcO2BrmAUXjLSZek9Pxdr2qqWzQb8=;
        b=qCAXJHUFAV442hIMAjcssOLUNg5SYasOKLwQ92tHo+H4QQmlYXxaON+olKy1u4yMv+
         C8J6BDMBCyO1ktERoIm7T3E9mzg3TSnqrkk4wuBH5FVdbYxZgIJ6y2DsY9u6lJXBWdLr
         L/ny3UbgS6jYvbBn0rdybjC7e8DIcDPqeTlrbseJOGPx0lL6PlqOwC6oHizE1mxHnhT0
         pmYu3iMUpdWbveIB3gwge5exMmqELdplsFPYf0Vv5NuimYvmCl28URqmL0dZ6Twi2e4q
         TwBiNybWm3EtN7BGmawgecI0pscaTWGJZX4JCb+y/A40dibn8eWhIVbyJWTKlv6wYDoJ
         Syew==
X-Gm-Message-State: APjAAAVP9rRfvWTE+AaQub/FXL+ayHFLhzpZXV8AplS34MRvxfevAZGu
	S8l1hkMp7XuPU0rImIbED2aV4XW3ve3yFTxMXT9ZDrC6wrXtlQeJRxBrIyxKkwoi/BUk/qVwjN+
	pZyCD8YbWXxRaFf30lrV8J4rR6zK9dyyyBw8PMIxUldeZl/A5QO1/Fvn2X7KuQoT+5w==
X-Received: by 2002:a1c:9e4d:: with SMTP id h74mr111417823wme.9.1564512000603;
        Tue, 30 Jul 2019 11:40:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3nAZXK0ZkLbfQoEkNrDxyL9eI4eq3wznzoYTRsY77LzovRmJpHGA8uW//bpmK6tudKFIo
X-Received: by 2002:a1c:9e4d:: with SMTP id h74mr111417794wme.9.1564511999748;
        Tue, 30 Jul 2019 11:39:59 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564511999; cv=pass;
        d=google.com; s=arc-20160816;
        b=EAVsHQxtP2R92GWmHUQImgyvXA/zwa7fk23UtNZhPBxa5hgUtmcjdJd/QH4hFAAS5/
         F4ycAYxilj9LE5DP7JFBRQFSyE+CYbtFFRUhtDFj1wFRyZ5EPsDqYkaprA4xsVQ0wARk
         O0NPW+pJl2G/mfLbhL9LVsIM4kZFzeUdrcWqwmnVWZwTNlyqX6UzFoUmdFU9uJ4QIHqk
         xd+IpHkeOZVchMFzJBpphe9ISuN+pWvBWwmiijRqwYqyFNDhs9sjZ3eI7ddy4yePfMnw
         p95y3SJTdst8152f6QDJQhmA+Rh9csz/tTtljZUfKz0EyU/1pZfkQHj6wg8DrxPmLkbQ
         Cgzw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=AUwSPm4smgaC06dcO2BrmAUXjLSZek9Pxdr2qqWzQb8=;
        b=a4rxp+CWKFpywEwZH6qvY9/anDXs4Sqpw5Pdc1uc3khXEqQjCCcML2k/NGkQi+wRa6
         70eBLW/1BgatTYX071guQLzLyJcy1WP7vQ83j5sW7irhB60ekmCSwgCJ4LiknrWQ9HKV
         RY/LTpBfdX96YnOWKBD/s+h3bSuBa6CzurRX8j3qw2rKVhZ0uHSd2C8A8zihB57bkHGb
         6ztohSpVrTrkhxIiAQfPu+NTQRTXGHCwbZ/tafzuBoNDnHfZCoRWWe+H5BEs58yqJ2dn
         qvIjvavgjw5xIz5AdAQRADmkO+QkuFjS77TLvxU+kcY9+uMVYuy3rXGVRj50XOIYRCit
         7PHw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RLGTbz1o;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b="Ep3U/KS3";
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v4si32527956wmc.134.2019.07.30.11.39.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 11:39:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RLGTbz1o;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b="Ep3U/KS3";
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x6UINe7F018323;
	Tue, 30 Jul 2019 11:39:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=AUwSPm4smgaC06dcO2BrmAUXjLSZek9Pxdr2qqWzQb8=;
 b=RLGTbz1ottombFFiW1QrJ8odFtboKg60gAiDI1HkU2dvdeAp86dzNAjjD8pDrkKW/tZG
 TidiA8hVOULw1h0L10wTtZlEXguH5VRfR0zGnKvOw2xN9vX6BOer2sLO9EZBwVba9kdp
 OeJ4QN0Nz2R5ldsgsta9grgxJ5BLy0NCHto= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0089730.ppops.net with ESMTP id 2u2p4b1ape-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 30 Jul 2019 11:39:57 -0700
Received: from ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) by
 ash-exhub204.TheFacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 30 Jul 2019 11:39:55 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 30 Jul 2019 11:39:55 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Ju8VsZs+Iw+j0/UmYIvv4JUldv6GPJoHMfMFf7tqbhonJMd0kSVNry3HCHWyMTEGsQPFdhGJ9le1UEbJ8zx70gMCcOjXreq7DhJAts3e6w+1fgf/DK6IjENvIJj/ze1aZTXnHK702T+b5hxkIa+aKPmL7OyhJWhUp7zhCrcaCnIVIsMWHIe06ov8dn6u3Af5eZa+6kF6jbhi/fvb53wcVoAEs06rUaHdt8fBP1/fs/nKiFP7cPjRfAvDN70YJN0iOXP06v4giHY38SHIHkf7kKE7JavpRPOqwH5lvp2u6gYM+pLopC5kCzL0fEHbFnuYvB1lPLFtWpFhQs3A5DHlqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AUwSPm4smgaC06dcO2BrmAUXjLSZek9Pxdr2qqWzQb8=;
 b=JqFJe/KZJsqpFae2za80+gCVZBV1jazX1m/2PKJWdKjAYG/N0RBFr6xxj5QymzCcB4NTDO615gud+fY+P3vQ0nD9DvpHMlfVSJlgO5H95CdV6KPw7Ock87+FBkcxJvrwHna5hO6UNf0m7Irppx/FMJtIDEmIt9Y7HweyzMlfhK/U+k0GjNXEIr6SuKT8UxG9NhE71RhzYD4yJo/UmxtW0NSqsgZknHQ4CdV32mltHWkzRoRZa/uN7QV/+LfIv9I6Z8QQd7orjLE1ulfz3yeQYfP5z92EsA5L8ktcGk5IFWRs3eCxTnOoE/cUrQM2ZMiPuOuSFjjVE+ZpZRklo/xQHQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AUwSPm4smgaC06dcO2BrmAUXjLSZek9Pxdr2qqWzQb8=;
 b=Ep3U/KS30jSXOTfYySxc7RUKFtytwfNi2VA+0fgrYYGazNfGJNmGZSHREwaNSdWTk4654YR4QTT2+rNeVhoF4kf2gGrAlHFVo5oyZQTPbMM8+tS0Q+NLT5MfKh0nfXFPffgCHQN3cXONWZ9rdWiOfB72KxSXtvOIGEkzRFQprUs=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1167.namprd15.prod.outlook.com (10.175.3.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Tue, 30 Jul 2019 18:39:54 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 18:39:54 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "oleg@redhat.com" <oleg@redhat.com>, Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Topic: [PATCH 1/2] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Index: AQHVRdCXaB8qUzCo40K8bOFQNuNjzqbjQxwAgAAplQCAABQIgA==
Date: Tue, 30 Jul 2019 18:39:54 +0000
Message-ID: <48DAF4DE-AB27-487A-B9B2-E733FA30A7B1@fb.com>
References: <20190729054335.3241150-1-songliubraving@fb.com>
 <20190729054335.3241150-2-songliubraving@fb.com>
 <20190730145922.m5omqqf7rmilp6yy@box>
 <452746EE-186C-43D8-B15C-9921E587BA3A@fb.com>
In-Reply-To: <452746EE-186C-43D8-B15C-9921E587BA3A@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:5cb8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d08c1f08-cca6-4bdc-eec7-08d7151d5063
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1167;
x-ms-traffictypediagnostic: MWHPR15MB1167:
x-microsoft-antispam-prvs: <MWHPR15MB1167F0C17DE588DA0652E1DAB3DC0@MWHPR15MB1167.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(366004)(376002)(396003)(346002)(136003)(199004)(189003)(102836004)(476003)(33656002)(6916009)(76116006)(2616005)(66446008)(486006)(229853002)(86362001)(11346002)(50226002)(66556008)(64756008)(446003)(66476007)(256004)(71200400001)(4326008)(6246003)(25786009)(81156014)(66946007)(8676002)(68736007)(8936002)(71190400001)(46003)(81166006)(7736002)(5660300002)(99286004)(2906002)(6506007)(186003)(478600001)(14444005)(316002)(76176011)(6436002)(14454004)(36756003)(57306001)(53936002)(6486002)(53546011)(6116002)(305945005)(54906003)(6512007);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1167;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: hHsOqAID5UGAS+4qcrjJEN8IOBtIZYLa1GD3lrZI0Wn5zMbX+HcOrr9Ve6z57Eq9vO/0v57nOeSRWTqy86fkAjeGHnlyAC9fZgGxxluXBJZW+mRQVRWUrLbA2j/9qe7Ndc6rBPrwlpoJeiiMJiwP/LnNI9CwGmPlcQu2rGMFs1AlViIbmurQtEYu7TixjnL+9sO0I8D8kKExINpo7pds0byT193CB2fi2Jr+/B+BAoGQj5ZcBiUrK3Pr3/cfy7c4F8Xy+dHlD7RgcFPxLtfyjGM/ta86INWmjde8fDr5gmIpGIAQQWbRRT5XeaN0H9SN8ibCmbpTp0dEwXpvJqA/zboRg+Dyv4m+DtNnlPZ8DTcD+5FbQWDt+yuGh8u7LPvJ9TY83Qmo3n5vyS4cFWwz/EmioYK7F9ZzLPmnVbmYTJQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <48545CF677458D478E69088DFEE8881D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: d08c1f08-cca6-4bdc-eec7-08d7151d5063
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 18:39:54.1584
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1167
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=943 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300191
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 30, 2019, at 10:28 AM, Song Liu <songliubraving@fb.com> wrote:
>=20
>=20
>=20
>> On Jul 30, 2019, at 7:59 AM, Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
>>=20
>> On Sun, Jul 28, 2019 at 10:43:34PM -0700, Song Liu wrote:
>>> khugepaged needs exclusive mmap_sem to access page table. When it fails
>>> to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
>>> is already a THP, khugepaged will not handle this pmd again.
>>>=20
>>> This patch enables the khugepaged to retry collapse the page table.
>>>=20
>>> struct mm_slot (in khugepaged.c) is extended with an array, containing
>>> addresses of pte-mapped THPs. We use array here for simplicity. We can
>>> easily replace it with more advanced data structures when needed. This
>>> array is protected by khugepaged_mm_lock.
>>>=20
>>> In khugepaged_scan_mm_slot(), if the mm contains pte-mapped THP, we try
>>> to collapse the page table.
>>>=20
>>> Since collapse may happen at an later time, some pages may already faul=
t
>>> in. collapse_pte_mapped_thp() is added to properly handle these pages.
>>> collapse_pte_mapped_thp() also double checks whether all ptes in this p=
md
>>> are mapping to the same THP. This is necessary because some subpage of
>>> the THP may be replaced, for example by uprobe. In such cases, it is no=
t
>>> possible to collapse the pmd.
>>>=20
>>> Signed-off-by: Song Liu <songliubraving@fb.com>
>>> ---
>>> include/linux/khugepaged.h |  15 ++++
>>> mm/khugepaged.c            | 136 +++++++++++++++++++++++++++++++++++++
>>> 2 files changed, 151 insertions(+)
>>>=20
>>> diff --git a/include/linux/khugepaged.h b/include/linux/khugepaged.h
>>> index 082d1d2a5216..2d700830fe0e 100644
>>> --- a/include/linux/khugepaged.h
>>> +++ b/include/linux/khugepaged.h
>>> @@ -15,6 +15,16 @@ extern int __khugepaged_enter(struct mm_struct *mm);
>>> extern void __khugepaged_exit(struct mm_struct *mm);
>>> extern int khugepaged_enter_vma_merge(struct vm_area_struct *vma,
>>> 				      unsigned long vm_flags);
>>> +#ifdef CONFIG_SHMEM
>>> +extern int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
>>> +					 unsigned long addr);
>>> +#else
>>> +static inline int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
>>> +						unsigned long addr)
>>> +{
>>> +	return 0;
>>> +}
>>> +#endif
>>>=20
>>> #define khugepaged_enabled()					       \
>>> 	(transparent_hugepage_flags &				       \
>>> @@ -73,6 +83,11 @@ static inline int khugepaged_enter_vma_merge(struct =
vm_area_struct *vma,
>>> {
>>> 	return 0;
>>> }
>>> +static inline int khugepaged_add_pte_mapped_thp(struct mm_struct *mm,
>>> +						unsigned long addr)
>>> +{
>>> +	return 0;
>>> +}
>>> #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>>>=20
>>> #endif /* _LINUX_KHUGEPAGED_H */
>>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>>> index eaaa21b23215..247c25aeb096 100644
>>> --- a/mm/khugepaged.c
>>> +++ b/mm/khugepaged.c
>>> @@ -76,6 +76,7 @@ static __read_mostly DEFINE_HASHTABLE(mm_slots_hash, =
MM_SLOTS_HASH_BITS);
>>>=20
>>> static struct kmem_cache *mm_slot_cache __read_mostly;
>>>=20
>>> +#define MAX_PTE_MAPPED_THP 8
>>=20
>> Is MAX_PTE_MAPPED_THP value random or do you have any justification for
>> it?
>=20
> In our use cases, we only have small number (< 10) of huge pages for the
> text section, so 8 should be enough to cover the worse case.=20
>=20
> If this is not sufficient, we can make it a list.=20
>=20
>>=20
>> Please add empty line after it.
>>=20
>>> /**
>>> * struct mm_slot - hash lookup from mm to mm_slot
>>> * @hash: hash collision list
>>> @@ -86,6 +87,10 @@ struct mm_slot {
>>> 	struct hlist_node hash;
>>> 	struct list_head mm_node;
>>> 	struct mm_struct *mm;
>>> +
>>> +	/* pte-mapped THP in this mm */
>>> +	int nr_pte_mapped_thp;
>>> +	unsigned long pte_mapped_thp[MAX_PTE_MAPPED_THP];
>>> };
>>>=20
>>> /**
>>> @@ -1281,11 +1286,141 @@ static void retract_page_tables(struct address=
_space *mapping, pgoff_t pgoff)
>>> 			up_write(&vma->vm_mm->mmap_sem);
>>> 			mm_dec_nr_ptes(vma->vm_mm);
>>> 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
>>> +		} else if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
>>> +			/* need down_read for khugepaged_test_exit() */
>>> +			khugepaged_add_pte_mapped_thp(vma->vm_mm, addr);
>>> +			up_read(&vma->vm_mm->mmap_sem);
>>> 		}
>>> 	}
>>> 	i_mmap_unlock_write(mapping);
>>> }
>>>=20
>>> +/*
>>> + * Notify khugepaged that given addr of the mm is pte-mapped THP. Then
>>> + * khugepaged should try to collapse the page table.
>>> + */
>>> +int khugepaged_add_pte_mapped_thp(struct mm_struct *mm, unsigned long =
addr)
>>=20
>> What is contract about addr alignment? Do we expect it PAGE_SIZE aligned
>> or PMD_SIZE aligned? Do we want to enforce it?
>=20
> It is PMD_SIZE aligned. Let me add VM_BUG_ON() for it.=20
>=20
>>=20
>>> +{
>>> +	struct mm_slot *mm_slot;
>>> +	int ret =3D 0;
>>> +
>>> +	/* hold mmap_sem for khugepaged_test_exit() */
>>> +	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
>>> +
>>> +	if (unlikely(khugepaged_test_exit(mm)))
>>> +		return 0;
>>> +
>>> +	if (!test_bit(MMF_VM_HUGEPAGE, &mm->flags) &&
>>> +	    !test_bit(MMF_DISABLE_THP, &mm->flags)) {
>>> +		ret =3D __khugepaged_enter(mm);
>>> +		if (ret)
>>> +			return ret;
>>> +	}
>>=20
>> Any reason not to call khugepaged_enter() here?
>=20
> No specific reasons... Let me try it.=20

Actually, khugepaged_enter() takes vma and vm_flags; while here we only =20
have the mm. I guess we should just use __khugepaged_enter(). Once we=20
remove all checks on vm_flags, khugepaged_enter() is about the same as=20
the logic above.=20

Thanks,
Song

[...]=

