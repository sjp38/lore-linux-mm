Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 096EEC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:16:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85EE32184E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:16:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="duOv6OwG";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="cMrhUWOx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85EE32184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6E676B0005; Thu,  8 Aug 2019 13:16:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF8A46B0006; Thu,  8 Aug 2019 13:16:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 972EF6B0007; Thu,  8 Aug 2019 13:16:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 722B56B0005
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 13:16:20 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id b31so3611052ybj.20
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 10:16:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=npjuTu9EeYs/V1MnUYjt03JIoqevCKhTl75ZI42hdyM=;
        b=rJ19RcRI6b8k+ARWoDvYgPPeHgfUFETRgGsAOlwbXCZiAxHlEsAKzjeDKjzTkMlmEP
         nQ0jn9YKU9r5k9qJu28lRladzhke+wqmTad9+b3HbNsd7vryLktZIR+2q051YVO4+a2i
         Q4xSYzXIXDvNC0IKY4cMKJPbH1CLxbqmMdcUDb4WqSI5alJCh0h1xk5EnzM+IQIpDgXx
         bw/7dfupAA76UnfI7we9GT4q236y51zc1XUgXAzyiWNSOGUQJ5kuSlbgsqzqjGCjimAJ
         bUz7bMH5pi9Qol+9xl12YqulZNsZ4ZBNAeqKC6QgR0e2td+1A6tidOdHWoGsAYD0og75
         SSlA==
X-Gm-Message-State: APjAAAV5+Sx8KhZbrlvup+TcZy9Aa1SWEIITT1gUrJG7KVazFsgxVJEy
	/yqJ8pWHxwF6kMuWRMtHvrDmbs2ONVreP1iLahOi1vMH0iTdZiBrwOFkNJNRBxC6IIHI/Dh/uNg
	cVLPRm6BlpNJEwKGWjY1kzJo6GEuZO2ZZnVFeKIvMMoShD0a5GNSoBycHYqwFNRKQag==
X-Received: by 2002:a25:6f43:: with SMTP id k64mr10804299ybc.251.1565284580202;
        Thu, 08 Aug 2019 10:16:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ8I5s/sQKuZ0oAJGShfpH9lm8uQBeJ/o3QlYFgu/INGu0NOu2/AQySS7ndmCLAW2O2RaW
X-Received: by 2002:a25:6f43:: with SMTP id k64mr10804253ybc.251.1565284579576;
        Thu, 08 Aug 2019 10:16:19 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565284579; cv=pass;
        d=google.com; s=arc-20160816;
        b=PvwxbIqNKquHscssvC+aOtwOyBzrIc6j5dJZUOYtW7KsFsabtstZmyu5CpihNqfTvY
         VoWdA0gCw2ZT4U+GrmhKzBkS7e1fxhY/UmV0aU1ljKn1J0D0fv854RjztrNrnnC8gqak
         QQYATGqAp0D0fM2KBKr+BKP46cqQz4W4ngjBEanL+eHycJGzejVfsuwEhkP5GKqbOm4p
         Y8VuRVn4NOEEpDlC+Kfa4oQ7//NLftajtVvIqi/e5G3c5SHQLWFucBVFrQZ5ejTQDxWq
         qr/IcWkLJe6QqfKycGFnhEQ2YAyVa5FAyVevZVm6EFJDohtWzYX+CO5LyPLyQ8X3Fnsq
         jTMg==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=npjuTu9EeYs/V1MnUYjt03JIoqevCKhTl75ZI42hdyM=;
        b=c5jdRQpgNLKohqpQ8qzJXZci3GXbEwN3XCB6iuIbxmcah6D4sA00dr+/A/4NkXQjtb
         uO3F3X0lyLh4gwASpe2+x9GNh/8Lke772vDZOC5G2WJvwboHtuzGvYVl3bAOE1MhjpV7
         mLQVgL1OIEKlPbs7AnINXcY0FGxBatE8D50v1VP8Bj8Lp5q2rsqU/w4M2ons0BbEWH+d
         ydsisnGVPex35vZmKiVecBojMLyf1uDm9ptlCits1XaGxvDozeAd3G5eJGYRUjAcfLSM
         CRg5/Q3MA0xZLqplMj3YG0egrmA/U7NIkK4Kw3DnUyax+8wCHxMbqfXLmwUKNX2BbB5B
         pdOQ==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=duOv6OwG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=cMrhUWOx;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3123566c1d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3123566c1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s138si1600133ybs.482.2019.08.08.10.16.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 10:16:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3123566c1d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=duOv6OwG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=cMrhUWOx;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3123566c1d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3123566c1d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x78H2bIO022520;
	Thu, 8 Aug 2019 10:16:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=npjuTu9EeYs/V1MnUYjt03JIoqevCKhTl75ZI42hdyM=;
 b=duOv6OwGLj8GDqMqMrzftuHzz6ZIM/JL7pC0tSVeDXfwBvG2rXhM1n3/V1+9ipRlNZ8H
 j4uDqcQrP5WOX0pAHrnF0O6twVDtSg6KhYztG1yOB/K7uiMyOxCyr+t+nIGihNd3fg4J
 qUGZELfRVuNeFrXZel1HnhPJRGPwzXykWEk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u8qpk832v-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 08 Aug 2019 10:16:17 -0700
Received: from prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 8 Aug 2019 10:16:10 -0700
Received: from prn-hub06.TheFacebook.com (2620:10d:c081:35::130) by
 prn-mbx03.TheFacebook.com (2620:10d:c081:6::17) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 8 Aug 2019 10:16:09 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.30) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 8 Aug 2019 10:16:09 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=eLMBrqgnvxT5C/KAqXrQ9nYZ6dRxV+jYTp+5OO1F/QAeVrnvnyCoqGNd++lmYY+QJtawb7IGjuNZGirbRLTrwYCmwtKScsiL6kjweeBCZJhmeVdNFW/jPDXCz3J3EKXfG2hg6BSHj4lwlSK/YuHnhBhIEHQ2s5ZOqX3HL0TjeplV8NWBj6ckTaauHFWfHwUfLbqP5ywcrlP4tOGPunXIDEYpmk6i5ZMCW0fvi6PE23XJPHDjRc7N6z2Oy/uH+OimC5sSYxQMvDFv5krgFjFYGQDCn5epc6bkW9rQ7VxcjoC0PGQW8ZMyE14RzY3EU8lhnSTiPVJc126Q8wkAZVIukw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=npjuTu9EeYs/V1MnUYjt03JIoqevCKhTl75ZI42hdyM=;
 b=heO/DrF6CFzZ+uTYuuAi8wVZYcjkTFsqajp3sNSZd4qJy0qnXbq2YYeaV5S528oZPPvDUknyJS71r16UKjilfayEazRe0xIZPMsjLZKDmj3iuLg0h1wpmKFlFdf8aSPcFyFf1LUN+JRV8IKCzwCIo3abXwlP7GmYIEdX5Ft/3eH31Ix3DUmx1fkrzc6rGSbrgtnB3Eb5Yh8fgohV5NyFV22iIXCcS0pQM1EUoDh8saaUKeehKemBChhePFX2WWu8U65ttKpDgUf2cuOeDruZQbn1ePQ1OY7SVCU1NjSG/S5p9uT1pLO/VIEErcTolqOmbTh5Cp7ceLok0yNEgFMaJg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=npjuTu9EeYs/V1MnUYjt03JIoqevCKhTl75ZI42hdyM=;
 b=cMrhUWOxeo4Esr1M4hcV5fiHCAVkstDAAhZtci/ayPcN0BfCrvmz8qYrqBI0w/xDrONyXjY9y+SYL8aiXe5xJMJTu+JwA+QPSCHu/wNIX36pAfUSg3ZOmxyczkxZNRRYCY+8JSCKi0sC6JGchfrfkthJy6t8/bFJF5GFTQgnD28=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1376.namprd15.prod.outlook.com (10.173.232.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.18; Thu, 8 Aug 2019 17:16:08 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d%9]) with mapi id 15.20.2157.015; Thu, 8 Aug 2019
 17:16:08 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM
	<linux-mm@kvack.org>,
        "akpm@linux-foundation.org"
	<akpm@linux-foundation.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>,
        "william.kucharski@oracle.com" <william.kucharski@oracle.com>,
        "srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 3/6] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Topic: [PATCH v12 3/6] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Index: AQHVTXk1mNBIE/jl/kWGntKwDXuhGKbxdEOAgAAKuIA=
Date: Thu, 8 Aug 2019 17:16:08 +0000
Message-ID: <48316E06-10B2-439C-AD10-3EC8C86C259C@fb.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-4-songliubraving@fb.com>
 <20190808163745.GC7934@redhat.com>
In-Reply-To: <20190808163745.GC7934@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3099]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b5e3fcc2-70df-48ea-c555-08d71c241a5c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1376;
x-ms-traffictypediagnostic: MWHPR15MB1376:
x-ms-exchange-transport-forked: True
x-microsoft-antispam-prvs: <MWHPR15MB1376D097BE38B182B26A9A89B3D70@MWHPR15MB1376.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 012349AD1C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(396003)(366004)(136003)(39860400002)(199004)(189003)(4326008)(6116002)(86362001)(478600001)(8936002)(57306001)(50226002)(256004)(71200400001)(71190400001)(99286004)(6512007)(14454004)(316002)(25786009)(6436002)(6486002)(33656002)(7736002)(6506007)(53546011)(102836004)(76176011)(8676002)(6246003)(2906002)(305945005)(53936002)(229853002)(54906003)(64756008)(66476007)(5660300002)(76116006)(66446008)(66556008)(36756003)(446003)(6916009)(486006)(81166006)(66946007)(11346002)(2616005)(476003)(81156014)(186003)(46003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1376;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: raRe+bqwaambHJJS8rh+ihbSu1RzF5qckBqGDlaEXmVqeUc9OTbMj2e/t4AMBUDLeJpSKoErAvZA+z5rt7WlAQ+Qqr91yAL/7dXKW2bkWdNOhMUKrijEST2TqvF+UKRKxXR12P7vPrMTAPvzG+iYiM5B9zF2uU6siVCnqiukRn/JTrDBz5LnvMvCpRYXMQnJJrpWzpHKDbUy3sxi7L5VonPBE6CqU1p68yzW9PR8h/4CW6xDAbbbrbAbAW0wFRa156J0CA/QLdFftMLH+iZWcY3Gs7DElPX/u9HDDAcSU6LHqIxt4GkiYuDz9hCnk5Y+yb0fM6T8+if08ng8lSHoN02K78nJVqFjcxNsRoMy1004C78gZ6x2c3m7z0mh/UejnoRIlEIMPT8iRzUkvdT75zU12aiaaaSz+G9MRp+0gSM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <FEE4CC21C3D5284787AF110DEEDE7D12@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b5e3fcc2-70df-48ea-c555-08d71c241a5c
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Aug 2019 17:16:08.0563
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: lQWtUvIXPiJDMJozyL77Mq5vJnG5XrjzgXg3gCovQfXmBHlSOLFdEjEiqAzEh9bawOsCYL6/StzGD7hyXco5rg==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1376
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-08_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=959 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908080154
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 8, 2019, at 9:37 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 08/07, Song Liu wrote:
>>=20
>> @@ -399,7 +399,7 @@ static struct page *follow_pmd_mask(struct vm_area_s=
truct *vma,
>> 		spin_unlock(ptl);
>> 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
>> 	}
>> -	if (flags & FOLL_SPLIT) {
>> +	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
>> 		int ret;
>> 		page =3D pmd_page(*pmd);
>> 		if (is_huge_zero_page(page)) {
>> @@ -408,7 +408,7 @@ static struct page *follow_pmd_mask(struct vm_area_s=
truct *vma,
>> 			split_huge_pmd(vma, pmd, address);
>> 			if (pmd_trans_unstable(pmd))
>> 				ret =3D -EBUSY;
>> -		} else {
>> +		} else if (flags & FOLL_SPLIT) {
>> 			if (unlikely(!try_get_page(page))) {
>> 				spin_unlock(ptl);
>> 				return ERR_PTR(-ENOMEM);
>> @@ -420,6 +420,10 @@ static struct page *follow_pmd_mask(struct vm_area_=
struct *vma,
>> 			put_page(page);
>> 			if (pmd_none(*pmd))
>> 				return no_page_table(vma, flags);
>> +		} else {  /* flags & FOLL_SPLIT_PMD */
>> +			spin_unlock(ptl);
>> +			split_huge_pmd(vma, pmd, address);
>> +			ret =3D pte_alloc(mm, pmd) ? -ENOMEM : 0;
>> 		}
>=20
> Can't resist, let me repeat that I do not like this patch because imo
> it complicates this code for no reason.

Personally, I don't think this is more complicated than your version.=20
This patch is safe as it doesn't change any code for is_huge_zero_page()=20
case.=20

Also, if some code calls follow_pmd_mask() with flags contains both=20
FOLL_SPLIT and FOLL_SPLIT_PMD, we should honor FOLL_SPLIT and split the
huge page. Of course, there is no code that sets both flags.

Does this resolve your concern here?

Thanks,
Song

