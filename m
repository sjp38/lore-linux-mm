Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63D4DC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 09:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 16EE8229F3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 09:21:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="I/UxKSGA";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="eNStBQ+4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 16EE8229F3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A32B66B0007; Wed, 24 Jul 2019 05:21:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E2AF6B0008; Wed, 24 Jul 2019 05:21:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8853F8E0002; Wed, 24 Jul 2019 05:21:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 669C56B0007
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 05:21:00 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id j81so38662426qke.23
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:21:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=XjUynfvLqRKGlPGZRnq4tlPD8nqqBsJS81jk29J/KYY=;
        b=nDBv501YFAM6O0ZAnxwnXkww52siK5Hkf6Lv+Zja7tbT1C89Q2xWYFzEJGh6Fmg0p2
         MM3Lp5HDoz6MVrFq1NF2J/y1bNtMC7X8Opwt7a/8DKIUFuuI2IhR+EFSwY+bDk/DrWzn
         FHZVr37PGjHINOPiQLHPH6VfuT78eKCqrveS/w6YRP/CC5XY8HvbUYC+r4FXCRUsAFHM
         beS3lacYCev/3JLHa06lv1K9hzvKczrXWdLtOBTDkXM555dMGrdO/5S4ehIdpyekb1O/
         fBCLBUKOzDUGdlpExtZL9TqYxPkL8e/mUFpqe2SbzfIu965R6dDINL5jnWrMwxZHr0Dg
         Cduw==
X-Gm-Message-State: APjAAAV+8ySC4sWI1Gy4+9LPYvNMRmoMLcXETN9WBLXsYjCqwgff6Pof
	Ye4ONpb94tpfgC8e5n/dZg5ggahRKUPZbuTwpPu8rDgcQKvs9xPp/ln6rGXM/1HV87ETgdaK951
	/0x+xZVJeFyleZuRSSlI+VTEyhQfeuHTk89fhqpQ2u+gY2t2i1oQvgBPmARHDRsjLVw==
X-Received: by 2002:ac8:3fb3:: with SMTP id d48mr56294779qtk.290.1563960060182;
        Wed, 24 Jul 2019 02:21:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzAnarFZ6xHA9Dt2x3SBFnNby/es5i7NQQxv4FyuG5NoiuIDrx1OaOufDtFvpDpCK4XbJ/t
X-Received: by 2002:ac8:3fb3:: with SMTP id d48mr56294751qtk.290.1563960059661;
        Wed, 24 Jul 2019 02:20:59 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1563960059; cv=pass;
        d=google.com; s=arc-20160816;
        b=Qq9uicI4fBlecmDBuH9648BiN4qMlhK4afscdNm9JxCfVoEqmBZE29V2qSLllgHsKQ
         FSVu7gcT6fKX45ikKIi9YLUNArei5WYQeM0cgJvu1eGhRrWYlH0MOWTYoIzCLTVlVwFI
         xJdQ6d7LnPpvjMYJp6yG5wGSIP4KpBPlZQhOBjFWNOkHjlEa41XmZikWlpmi4yRxS2s4
         /43arudYfIirz3LB0gBGeFHD/5hgp7EXsAx8njSpGxyUWgKpwSjOcHe2P/6FCLIJGKy3
         1YwbdkbCk6Fq6IzKZEYNFZfAEEXznIOcuD8uD9UK0wQMjeVY5RPEcHiig6kAnATH0aMx
         gLGw==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=XjUynfvLqRKGlPGZRnq4tlPD8nqqBsJS81jk29J/KYY=;
        b=R5AsdSeEHJ6ReCgTmMXCUBiSbRxqtOniDB9jdbOs1qwI0AayMvoZ+EF7KGM8sl68KK
         5WPaoFmi6q9HPg5njsgApIUZ8EOwHv5leKR5F2ZzaOoxWT7tzmy+BisjN72R/iPc3Jg2
         iXkdyHoDnPoOn4NL5Vgqa2x7nT3ammaan7pAhMkw7e2F2BIqKdcTRh1voA3DCPPZ2VEy
         i58eCwoHoiexm3lDLR/3VzPIN8n2UFT/h67Vg/fAHJz4I+S4rNYEeHOus1kJg5NQo/Tp
         dZNJe06FCIcawyEwMXWCTIssRDDUicWV2qw05qONSZnx/AjPRmMgDxKJwmzkkE4sX2o2
         ltTA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="I/UxKSGA";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=eNStBQ+4;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g23si26220619qkm.90.2019.07.24.02.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 02:20:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="I/UxKSGA";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=eNStBQ+4;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21083052e4=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=21083052e4=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6O9Cj6p002019;
	Wed, 24 Jul 2019 02:20:25 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=XjUynfvLqRKGlPGZRnq4tlPD8nqqBsJS81jk29J/KYY=;
 b=I/UxKSGAIAZnJ9ujckodaiwl3pThDJSfmqv7lEcD4U1Fz38jEXezRiiWj18w207zIAQu
 bKMPivb6xThMGkGxjleq0HLtVkGP6TO22MUVNVM+sl7sfh9aDm2sWxzL2VanirADWugU
 ZOUzo0MMAdRimPDZYK+dVpEeCBlrAAFObL0= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2txk79088d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 24 Jul 2019 02:20:25 -0700
Received: from prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 24 Jul 2019 02:20:24 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 24 Jul 2019 02:20:24 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 24 Jul 2019 02:20:24 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=k29gN6Yub4HOH7DxSoVNIGaCJ1UXI1OwqgSBFPOfI1S5iVq2Fky3GJ6E66qR1j1JAMKhkE45SfW/l4wkYOgEtv+BMyGsCKFubvzz8OQC4Z5bhvzefsFvk/5V6lpbKA/unwO3zZbtgS9kev4dlKFv5z4AcPSJgVyRY/KWt+n1Yzoa1KjWw76pTiRoLjKc7bb/Bt9c4RIJSobgmRLmPYdoSfR1h6RK40XbHgdTBuj8om4+yCpbFcjw0opCQMDvbjSEyrol0RX24Jn1sYYF6TsFVinWqdYBdO0smAZUqWF2TZahjfVFsKWs0zE7i+jq8AJGhn3UsvOTSx0HeV0nEEH6NQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=XjUynfvLqRKGlPGZRnq4tlPD8nqqBsJS81jk29J/KYY=;
 b=MPFvbOuU0ziy06CSJP99N7O32u80NOh57y1s9MsKUY0kLzsk9R876aWCjCd/oag/3qOfS652db5B5OQFuNQaD5U4CuY1m0XoXwmXsZ+4dhnTE7urDK5BYKtnSmGxeRp6FLfD75Wdn5MMM1gIGnQOG+dB9w3JgxUb6qdK8e+3ofLgcyOYgnfpXg82zZMhub09Slwb/tuV5fRCAEAgdI0UVZXXchdTpD5KwfeCiOZfHSM1FHvWy+Ix9z/gMSM0y++pWMmP3etmm3l7rIHV2hcS4gOqJ6Zb661FGFeAKC4NFTTo/sEEXyxT+r5N2dy4blKN6Gk5D24ifZIosvWtwM2KAw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=XjUynfvLqRKGlPGZRnq4tlPD8nqqBsJS81jk29J/KYY=;
 b=eNStBQ+4mE1Rq+rnMVx7yLTaq5Pwki7ThXkJZGe41T8gWhS8gYKF684wa91dVxtUK3aEYbVzG/0t3xXSRDDxFaaUVz4mOpAGVVPdmZ5AZqiv1s73hxTmIBm101lyyFb5tmUTHNNePzDHX6+2RAxRuk8EsNttAea0jv7b0QIugbY=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1437.namprd15.prod.outlook.com (10.173.234.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.16; Wed, 24 Jul 2019 09:20:23 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7%7]) with mapi id 15.20.2094.013; Wed, 24 Jul 2019
 09:20:23 +0000
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
        "peterz@infradead.org"
	<peterz@infradead.org>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "Kernel
 Team" <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>
Subject: Re: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Thread-Topic: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Thread-Index: AQHVQfsnepoAlMhPK0qmuIU0gpphb6bZeoCAgAACwICAAADTAA==
Date: Wed, 24 Jul 2019 09:20:22 +0000
Message-ID: <58E13FCB-FE49-454F-995F-832870D314F1@fb.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
 <20190724090734.GB21599@redhat.com> <20190724091725.GC21599@redhat.com>
In-Reply-To: <20190724091725.GC21599@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:87bf]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9695b7be-769c-4abf-3145-08d7101827fb
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1437;
x-ms-traffictypediagnostic: MWHPR15MB1437:
x-microsoft-antispam-prvs: <MWHPR15MB14378F5797F4E3E512548C70B3C60@MWHPR15MB1437.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 0108A997B2
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(366004)(39860400002)(136003)(376002)(199004)(189003)(486006)(71190400001)(256004)(76116006)(66946007)(66556008)(99286004)(64756008)(33656002)(316002)(66446008)(54906003)(6116002)(8936002)(50226002)(4744005)(66476007)(71200400001)(2906002)(81166006)(81156014)(6486002)(102836004)(478600001)(6436002)(14454004)(57306001)(7736002)(6512007)(8676002)(186003)(25786009)(6246003)(53936002)(2616005)(36756003)(305945005)(46003)(476003)(11346002)(5660300002)(446003)(6916009)(76176011)(4326008)(53546011)(229853002)(6506007)(68736007)(86362001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1437;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: v9S400ccPQ6nIaOyZCi/F0oOHhIv58PFuBj9bvL4H7Vrpkit9s0NFI/e3TMYxb4M+FFhswuewXjx2OOFHlBUTWVjay4/FXfMbKuqoh6bVcmW1Nybxqtpbp3iVQhCNqF0N2G7xGPfDjUTsPYtapIvK+hesOtQFRlIAFxz1YN1hJRm1b15BRnC8y27ZzkKcCFnBZupdv2oYSYGUcwZ03TPWl+rtQoetrf2MPf/DISbzgXXt9mDyWsDzYc2VPaDiN6bm82G3BPz6mjrT3wDTfN+xP8s6nwa1hrQpOnndZ3bkWReKkmeAQlKG5DLZp2B9UNni84gnONsFeimoyxzdXn2KRS+quchhhgads6RaNfLhAPilIlE2TX/hWMADiLcoNnUMH9z8opE48XYeVVccdRzEOQ076P1vZYmnc+VGISYO/I=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4AC5CABC203ED5468A8A27501B4B6F6F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 9695b7be-769c-4abf-3145-08d7101827fb
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jul 2019 09:20:22.8454
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1437
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-24_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=682 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907240103
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 24, 2019, at 2:17 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 07/24, Oleg Nesterov wrote:
>>=20
>> On 07/24, Song Liu wrote:
>>>=20
>>> This patch allows uprobe to use original page when possible (all uprobe=
s
>>> on the page are already removed).
>>=20
>> and only if the original page is already in the page cache and uptodate,
>> right?
>>=20
>> another reason why I think unmap makes more sense... but I won't argue.
>=20
> but somehow I forgot we need to read the original page anyway to check
> pages_identical(), so unmap is not really better, please forget.
>=20

Yeah, I was trying to explain this. :)

Thanks for your feedbacks.=20
Song

