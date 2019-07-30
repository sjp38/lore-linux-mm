Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DE03C41514
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:42:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B9C02089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 17:42:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="AWhIDrfJ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="LwgRiVeH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B9C02089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C65268E0007; Tue, 30 Jul 2019 13:42:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C157F8E0001; Tue, 30 Jul 2019 13:42:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB69E8E0007; Tue, 30 Jul 2019 13:42:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 884DF8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 13:42:21 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d9so55488186qko.8
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:42:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=WNUWEDqQSXqXuy8gib4gfSFcOGazYuAXBqIEmUhA4jY=;
        b=aA6tJeJcc6hQduo5x+qU45fBoUDwrpQ6ThAJ2Y29II2s+HqPo1RBtqwsqU2iWcUReg
         JF8UKGnBqPQzctZZHQvzmD2qY0t1JoKJ39R3WbegUtcGkUNfOSD1jHiOftRxkx79GwEK
         i4nuKip8vm4SacvkbwPauYG2Jlge34UkTSdxyDROCeWwOwFRSxNa7Fj3A+ScX9tTacgY
         a/YyGGS22959SEM/YemxXdidUYh0HY3F1PrWDVuXnYU7bQxi3h75O3Hf4BbKo8OK0OfL
         G6KuqDPs7xm54gE0EGRUKr0T3oQJMokXIwSNO4p+gzO+LG+gCLgAbgPB8nRXgT6OQNnA
         Nx9w==
X-Gm-Message-State: APjAAAVvwjqKZogXVDdsjsRffRoAC4fulW9ms21x7oqzqV8X+XzFHwRX
	f0e3rgF3Jgvvj+S9YU40pKAUIZUe9f0bgv18eiQqe4y+XQpGkljn28krUIiJsNByLsf7jKwBozW
	CbifkQOc0VZgAzNTUBRDDkkxk1Fv1bcLKn1pasJe+uk0BUC21bMowi4FQRFiK7cEe0w==
X-Received: by 2002:a37:4f82:: with SMTP id d124mr71834739qkb.23.1564508541297;
        Tue, 30 Jul 2019 10:42:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6owTtjDwl1d5eL3xpKPfaixTMtjIA280D9j6Mp2ryI3QUyV2KDRJPgaQX7elhxSx7FujF
X-Received: by 2002:a37:4f82:: with SMTP id d124mr71834729qkb.23.1564508540654;
        Tue, 30 Jul 2019 10:42:20 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564508540; cv=pass;
        d=google.com; s=arc-20160816;
        b=uS60j9N16PMXMIMFzoLIjxhZmgMxlwvVGRRs+zc4B6XsOGX4Ah/jgTWCQJBw1Qm70s
         ffLX2GYTW9hDGcf3tuF82zXO3iknG/NFiaOqAk1JnCp3OmDHyhpdew1Tzz4A/QBRwO+q
         AQpQlYKDgarxsnW6zZSjArkPP+YG/wfOk4BpmhbQw4Lxf5UxH5C8kLvJP9fszqGCFJu+
         xkSUW+6s/ZwuKwsi8Nap1Vt8eP+ZTwb/zgBaZVlc0UjozezolkNA905CACLIxgwJs8wd
         hSIU+/d6Hx2zKis85clNbsxaJXiTjefOPJufzN8+Wrcs8qzDJGW3j/beD9hd+rf4HayZ
         4dSw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=WNUWEDqQSXqXuy8gib4gfSFcOGazYuAXBqIEmUhA4jY=;
        b=PDetPRODO+JNNJSHTMhiq6njGBoT/Ytpvy/wNvJa9SM5adHdKzg4bNcjL4wOWC8VzE
         wnqYKMnLG69k8z8WyX2eYvDhZ0CMv7bXM9IpWsgTraeNHhajY2rwuNV6rMoN5mBqOU16
         5qs1F+YU/bgB2SLt6fWvx65lN/qzBpafJhxrU7oOFoVeiIby6JdkTJ6uAmeeedr7RlmS
         7uqVpkteIhQyCAMQUJlUMy+c4Er1Kw0V4PIaoR9206DVzHQinJRZOlHSR4OU+mLP5UGV
         yRFwCA0C5NVvcUktYX22+1orucRxnzyxcSvpLvYbG3bigOTiUA78OTxIQlKkEfdv2FGr
         JzQw==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AWhIDrfJ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=LwgRiVeH;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id w49si39097762qta.277.2019.07.30.10.42.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 10:42:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AWhIDrfJ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=LwgRiVeH;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=31148e3214=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=31148e3214=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6UHcopc016275;
	Tue, 30 Jul 2019 10:42:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=WNUWEDqQSXqXuy8gib4gfSFcOGazYuAXBqIEmUhA4jY=;
 b=AWhIDrfJxEVh1onzr5WkKBjukS9BGdi3DyKudiPCZ/SK7WfEgcCVbfPKU/3JxPrMDbm4
 UBnTs7e7XkL7ucRuPqqnzemgat2/irC3/7l9zxgTLgP1IsRu1EL60Z0XVFB3MbxovbQl
 uDV3dXHgRHJ82z3jE/Rg/aXHfvEXwPwIdP0= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u2pwm0xde-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Tue, 30 Jul 2019 10:42:17 -0700
Received: from ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) by
 ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 30 Jul 2019 10:42:14 -0700
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Tue, 30 Jul 2019 10:42:14 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=Jwo8Tm1KQvJYX9fk5EdoEr1iiP+gOQgXovsMp+juZQyNmjD7FNlFdwGse5I9EW4lptadD3qZOiWW8r+o3X64fJiXdM2OIxARyKmsLJlQnPCEuvdtZdS3aJQtkTME/9FdTEOS/te20b7MtghBzkshIT0gyJ0XDoBLCmvd+NSorgDlog+pUbXYnOKI5Cz7rPwo20kG8kucES01vdr5xvGGcm9hNX6AlLQJSgkNlgffbWoEy28a1uJP1I+MZWeiXAMyFAZ8LWUaeb/sQLpxERfFZUcWjgE0ae/sTid9AyY9FOP84pbnjmRUPU32oWTMZQl/xTP03B4YyeTHt+9LoqGkKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WNUWEDqQSXqXuy8gib4gfSFcOGazYuAXBqIEmUhA4jY=;
 b=gLX2h2JOrc7F2km1Iai+Pg4U09Mgeeqkvr/5YN1PhPKS4aJ85seFfKupnUiiOHb5AknEwdZPGrhEzChfFcyL9+GfFDbpvHl6JJvWAtQSBFLDwT2H1JzDDUymLWGN3Fbjr3gQC7cbGpszU7IpltRCUNGG28xeIW+YBo3v+flw/nhfOVaMk82+1QGHmtPMfjOVOezSk1EYLeMBDwZN43EMZCHJFEGlHIbOUZb4vHQHZRfDirazIkzkjFY7oA3zbCkbdNkQiN2hpp39ytBKOcD/7TND3ZKA8ippuNMWr/gqdbTzmSb9rW4WwfRxaz0HfE2BfQNevU9BS1BbY2sHtb4STw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WNUWEDqQSXqXuy8gib4gfSFcOGazYuAXBqIEmUhA4jY=;
 b=LwgRiVeHrfANp1k4XWPdcRkGQzLqvok7aeFM9H/akI6aqsQSPQlh163zYDhI23TOOHjmXUB6orv9ulWhi+PsyfvA2zsnD83dmcIIPDgaxGvKNr72LPP3krHCQRVG0lmAyD6rDVm3KyBgJZspyB39Wv6gpvN6oFfxUygmzjmxB04=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1903.namprd15.prod.outlook.com (10.174.100.140) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2115.15; Tue, 30 Jul 2019 17:42:13 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::d4fc:70c0:79a5:f41b%2]) with mapi id 15.20.2115.005; Tue, 30 Jul 2019
 17:42:13 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: lkml <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org"
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
Subject: Re: [PATCH v10 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Topic: [PATCH v10 3/4] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Index: AQHVRpbyXlkLbIiwxECjtBJ+XLP3V6bjVaQAgAAZagA=
Date: Tue, 30 Jul 2019 17:42:13 +0000
Message-ID: <1E2B5653-BA85-4A05-9B41-57CF9E48F14A@fb.com>
References: <20190730052305.3672336-1-songliubraving@fb.com>
 <20190730052305.3672336-4-songliubraving@fb.com>
 <20190730161113.GC18501@redhat.com>
In-Reply-To: <20190730161113.GC18501@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:5cb8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 34279050-7834-401d-5ba5-08d71515417c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1903;
x-ms-traffictypediagnostic: MWHPR15MB1903:
x-microsoft-antispam-prvs: <MWHPR15MB19030E106E025F6F0E506530B3DC0@MWHPR15MB1903.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0114FF88F6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(346002)(39860400002)(376002)(396003)(199004)(189003)(52314003)(476003)(14454004)(76116006)(71190400001)(6246003)(53546011)(229853002)(316002)(66476007)(64756008)(66556008)(76176011)(71200400001)(86362001)(99286004)(36756003)(54906003)(478600001)(66446008)(5660300002)(68736007)(53936002)(6506007)(186003)(102836004)(66946007)(6486002)(6512007)(256004)(25786009)(46003)(7736002)(50226002)(2616005)(4326008)(486006)(2906002)(11346002)(6916009)(33656002)(8676002)(57306001)(81156014)(81166006)(6436002)(8936002)(305945005)(6116002)(446003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1903;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: WUcqHqaktuWPo/cXogahuQRYHvqIKCGMf8PKVgti5a1a2gJP9UPUYDX7fCsIhB+CpcqSqhxlFom+8S9E3p9JixNE28PDZCii+GKol9BfqPuvYpBeoeFo6U+SbdVZ5GnKbOSKfjXl/rOZSB0j9uV9D9ZsRBfAQE02a3DTNfV9KxuaCxejTiYM5nDMzdR3ItXpILeksp/zfPJnnpAmKN5HSmT4S1ZabD+98+SIJ+fa8y8fXPA0aaJ8NOwH/uRsnfgL0tXnyMRPhma79k9fWVDEX2AJo+Ndcmn/KzuZPLqKKQ1Can4ybjJ0HDCwBvgwe3EztnfHMuMX534lAGImx/X91Ebg5rPnlCYfUWdwKE0VgVg/g3j4ajfTJrDIGuw3S/yRHLo1/Xm7GgNglksleScxrgnYwYxQG8UTQ5J18f44yWA=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6751533878403B42A328D71EE1165B34@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 34279050-7834-401d-5ba5-08d71515417c
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Jul 2019 17:42:13.1318
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1903
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-30_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=898 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907300185
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 30, 2019, at 9:11 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> I don't understand this code, so I can't review, but.
>=20
> On 07/29, Song Liu wrote:
>>=20
>> This patches introduces a new foll_flag: FOLL_SPLIT_PMD. As the name say=
s
>> FOLL_SPLIT_PMD splits huge pmd for given mm_struct, the underlining huge
>> page stays as-is.
>>=20
>> FOLL_SPLIT_PMD is useful for cases where we need to use regular pages,
>> but would switch back to huge page and huge pmd on. One of such example
>> is uprobe. The following patches use FOLL_SPLIT_PMD in uprobe.
>=20
> So after the next patch we have a single user of FOLL_SPLIT_PMD (uprobes)
> and a single user of FOLL_SPLIT: arch/s390/mm/gmap.c:thp_split_mm().
>=20
> Hmm.

I think this is what we want. :)=20

FOLL_SPLIT is the fallback solution for users who cannot handle THP. With
more THP aware code, there will be fewer users of FOLL_SPLIT.=20

>=20
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
>> +			ret =3D pte_alloc(mm, pmd);
>=20
> I fail to understand why this differs from the is_huge_zero_page() case a=
bove.

split_huge_pmd() handles is_huge_zero_page() differently. In this case, we=
=20
cannot use the pmd_trans_unstable() check.=20

>=20
> Anyway, ret =3D pte_alloc(mm, pmd) can't be correct. If __pte_alloc() fai=
ls pte_alloc()
> will return 1. This will fool the IS_ERR(page) check in __get_user_pages(=
).

Great catch! Let me fix it.

Thanks,
Song


