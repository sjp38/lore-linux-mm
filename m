Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=BIGNUM_EMAILS,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1417EC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:24:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99448208C3
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 14:24:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="UOS5voge";
	dkim=temperror (0-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="JV6D+Vc4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99448208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 237616B0003; Fri,  9 Aug 2019 10:24:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E89E6B0006; Fri,  9 Aug 2019 10:24:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 089FE6B0007; Fri,  9 Aug 2019 10:24:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD9B06B0003
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 10:24:35 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id h203so71398935ywb.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 07:24:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=xQkzKSldVEt9z62NgCeWme1X6P/bNwm6cWi84v0yRUU=;
        b=FAR3+jOhmTs3rqan1ZPJueGdNSzm19JMwtlRxxagyrewY1uDtZrA4uEe5myl1q4zaK
         x7cog3qWkJDrjk2vxAewAZd0wf2J+PDEI6btNTTioSUkxlfKrTusIqDqekQ5MriiLBXf
         8Dbr3LS7yO5s/BvVjGUgbJ5QZ6zRXzBlP/rJJkIVy0770nz7LhrfDFZmFyxS+AdjYXvG
         uPHgiarp/Y6mjXXlfIV/6R3T7YrLMYgdMJ4qqg5Euq06GTDkP+JQZRsIFiDmomDAWcbr
         tkQhKWI/UfM1vZZqPtqEZ6CpshzsBANkUb5EDyEDXHA3ddIg9EdIfGU6jMHxUeNdMib4
         6e6Q==
X-Gm-Message-State: APjAAAWpYO+8NuvKx6nFnPi8aYKIlurEXLvmMusNFjLevyh37B1t2/Aq
	hBic+gL6NWMWEyRN6dIepSoRtlXXoLzIcgVPrvL91/AHayPZdr1zO5+4PXUeDFjHatc56nXDS70
	/zrKttIOdaLByyxz9gCwyRlGzBWp6PBDPDZtvutDpFradFt70V0ffYIFWGeAS74l+4g==
X-Received: by 2002:a25:b78c:: with SMTP id n12mr14691588ybh.373.1565360675643;
        Fri, 09 Aug 2019 07:24:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC44hhjxRwLQNvXx0A8cuVtPz4SH65xeUmtLAIVDVmgJOtBgacQ12iwCHPDnfUySlHhfd6
X-Received: by 2002:a25:b78c:: with SMTP id n12mr14691558ybh.373.1565360675111;
        Fri, 09 Aug 2019 07:24:35 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1565360675; cv=pass;
        d=google.com; s=arc-20160816;
        b=hIwwCb4f8ISd5VGWKtQAggqVM4DGbku8D+zp2tVMAF0Au+go1KcoAwLHO/GExbwLVU
         Nn2QXXxo+pirwjlZDL7dTkfBspyZibSY1CWta7gPT3f6CZb7d3ioGIM/bMWdIq5fpwJs
         HNsbW2ezbntdZNSNvKVkIdXpHPlIYe36QNOlaxfPbfG/+QRB6SYxeyr2EN1GawDp4Gk/
         p/y2a8if4Kc1y8gPEg5tdBgUvN8VKJkFCee6pLbJTZ91Wgz4aL2nOl4nWYgc3E320M5H
         nipq5FeZ2Oe0GcCBhabJrVZ4kz7ZAgRh+2HIkROqQPkdtFCFu32ClSiJz0EMthMpLqQj
         VbiQ==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=xQkzKSldVEt9z62NgCeWme1X6P/bNwm6cWi84v0yRUU=;
        b=hknPoji1Z+Hs19E9UK0ohZGKm0Jya+rSiRzKRFoMM365uVaUA+vL/OvE7Ln7l8ZwMO
         WvrXQiJdU1rwvq6yWAtOqNGtrOaLDYWKleqxu8EvgVlzyr8y+TPxlIYUNkT8fnQby7Ii
         1aP+VyjC4uqw5nom1j11AgbXugaIdD695ss7Zov7FbRRehNwExd0Rys9qe8qgotgSc5y
         G7C3S+70/4K3KEbSWoGSeHUkIoIjA3Ke0j3F8WR3lLIRDNdLzyMtWuHxShsv45Bus8Pu
         CH1+nDN8S1+Bekojs3pBof5RpzW1xxxh8evniFIqvQ2tumefODHNZXSY7ISzM7/7svhJ
         0t9g==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UOS5voge;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=JV6D+Vc4;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3124312b6f=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3124312b6f=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i66si6556129ybi.158.2019.08.09.07.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 07:24:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3124312b6f=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UOS5voge;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=JV6D+Vc4;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=3124312b6f=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3124312b6f=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x79EJhUo016971;
	Fri, 9 Aug 2019 07:24:33 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=xQkzKSldVEt9z62NgCeWme1X6P/bNwm6cWi84v0yRUU=;
 b=UOS5vogexw1/i4t6IyO7Jkqa8UuUQHn1BiloqsmapzhmsCJqNzRrh0y7PyRCnc/kAuUO
 C7T76Dj93J4s37pbn/mUjyFbg5VTa9BZ6+WRF6kHqYmtgwYUQBeLdXh78ueBZFuqvQBv
 r0LbQCTVEe3rYwT9BxT91s2Bp/bwfVoqHyo= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u99a3rbwh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 09 Aug 2019 07:24:33 -0700
Received: from ash-exhub102.TheFacebook.com (2620:10d:c0a8:82::f) by
 ash-exhub203.TheFacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 9 Aug 2019 07:24:32 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.172) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 9 Aug 2019 07:24:32 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=YleI2C/np7OadB/VzZ7LUIqn8RlemtjCtwGjMvINUSpMQKYcLv3lR0Umw29QoGBTaTyWT7ohViWu2wOax5GtCuJ0X91D1xfQ2AyrcMuOEITLZ1tgigEvm5BK8qho35hLwT0U3vOhu31DiuYek3ADLL+4mrDoLUdy59e29XivOTR0dLHh+94/6VxtFYyWi5U1jkGh+P8DhF7B+mvv5QujQGuc3pjTq9QHg7AUOQzlGm/pIEvEjh9OXsAY6MNE+1ayYf5IBUKIhHWzQKgJB9xHpjs9K3QDv+sEF1JQ29rG3khcFkRJ2XM7OTBCcLL/sawmi3J5/KP8qVnfi5I2sT2/RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xQkzKSldVEt9z62NgCeWme1X6P/bNwm6cWi84v0yRUU=;
 b=YDfjs+GaVkpVss8IQvr+TWR/Ju5esdOdA2r/v0bMdB9ETt12EbqgVKtnnqbg/Y6Bzrndm0quU0jB1EooK7FDejO0A+ibnM7cPBFNlK6pyp1alt838g4voy/NgUbEIC3Zjqb6JwAZrA72XxgtEJQ4dmIGwm3rq9CXaNC0H43Gk9Ojt3FXpn0rgVYt2FuNSFERWA5AvlQdFoBxLMKnNizmYTsDvbSNQetTuqjPipnXGatyNWwZKPbnQHrnKYtFibKFDmYiFghuMmWfbH6M8/mLMiyIg/pq2XOsOWg3qVXu7GJBil8WM3M4os5zTl8dAA005+3A0GgKo2ffH8wXcJC0gw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=fb.com; dmarc=pass action=none header.from=fb.com; dkim=pass
 header.d=fb.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xQkzKSldVEt9z62NgCeWme1X6P/bNwm6cWi84v0yRUU=;
 b=JV6D+Vc4y/Bi868NNWZcmtrdDazZ9tEy7DqUZDczTiIFyPH7ZzIgb0p8UfMFokPFw0WfeNBmcrLv3tAy0Q4OA2fpJDdeWXqk+wkqfKCTaQsnE2Zvty/ADJngAHyE/XyoaolRkdiCngJ8nGASH4eaVsoI0TPFkP+pWjhP0eTsTTg=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1503.namprd15.prod.outlook.com (10.173.234.135) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2157.20; Fri, 9 Aug 2019 14:24:30 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::79c8:442d:b528:802d%9]) with mapi id 15.20.2157.020; Fri, 9 Aug 2019
 14:24:30 +0000
From: Song Liu <songliubraving@fb.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [bug report] mm,thp: add read-only THP support for (non-shmem) FS
Thread-Topic: [bug report] mm,thp: add read-only THP support for (non-shmem)
 FS
Thread-Index: AQHVTq7a2zGZgPWlfUisz3BfCbKkEKby3vIA
Date: Fri, 9 Aug 2019 14:24:30 +0000
Message-ID: <B960CBFA-8EFC-4DA4-ABC5-1977FFF2CA57@fb.com>
References: <20190809123441.GA9573@mwanda>
In-Reply-To: <20190809123441.GA9573@mwanda>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::2084]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 85001cc6-8762-4643-c8db-08d71cd54b04
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1503;
x-ms-traffictypediagnostic: MWHPR15MB1503:
x-microsoft-antispam-prvs: <MWHPR15MB1503BAD238C712E73C4BBBDEB3D60@MWHPR15MB1503.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 01244308DF
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(376002)(39860400002)(366004)(136003)(189003)(199004)(99286004)(14454004)(186003)(57306001)(102836004)(5660300002)(316002)(66446008)(66556008)(66476007)(33656002)(64756008)(54906003)(66946007)(91956017)(76116006)(7736002)(305945005)(53546011)(6506007)(76176011)(50226002)(81166006)(81156014)(8676002)(6116002)(256004)(25786009)(6486002)(14444005)(6436002)(53936002)(6512007)(36756003)(46003)(6246003)(4326008)(11346002)(6916009)(486006)(478600001)(71200400001)(71190400001)(446003)(229853002)(476003)(2906002)(8936002)(2616005)(86362001)(142933001);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1503;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: +33B9u0dEJvNbqTDFbxMaYTRms2kQnLZwA95d87np1PWoUP6b+KPszEZkrj4qEt8w2ITebmDwzavx6QBjgnILNKeobtkhN6oQWnhmeu+17FsjFI6/7ovISSA8Jf6PmAWGXESnubbaEkp9YLKVJj8asWmZBBb/a4ejEeceUQjNVknelgNLIibjqILRvUdjeaCR+wRCNnP0iXgFA1NJYjBEXrMf/7exqg5F/9YKhGVkCj3hVzGprlf4ki0tSTkFOKqGBYBdmj3MdeLmvM6+/X7pzsZpGvreDDdYJ5yVjKyowRHUCcFiEGM4/NdG/k/zVKtxYS70gAN7HphNDowKfK6HYq2x2tPl6ShjEAj1r9BEd0efUSxE8xEv0753qeV+7fF7ADSfgbqSuFdxTXUn77r3BI50rLj3dblhmWuqspXNMs=
x-ms-exchange-transport-forked: True
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B2B07919BBD54D459BB6579E9F66C0A3@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 85001cc6-8762-4643-c8db-08d71cd54b04
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Aug 2019 14:24:30.6282
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: mCxvUH4+aHnV4fg/KdlEnvP8E/tpYnJTlFthMbf2ZBCO0gF2GA4KpyXVKQ51ynYR6Gxyl9RwRNTcXZZX51G2hQ==
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1503
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090147
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+ Andrew

> On Aug 9, 2019, at 5:34 AM, Dan Carpenter <dan.carpenter@oracle.com> wrot=
e:
>=20
> Hello Song Liu,
>=20
> The patch 89e1c65c0db7: "mm,thp: add read-only THP support for
> (non-shmem) FS" from Aug 7, 2019, leads to the following static
> checker warning:
>=20
> 	mm/khugepaged.c:1532 collapse_file()
> 	error: double unlock 'irq:'
>=20
[...]

Thanks Dan! The following patch fixes this issue.=20

Hi Andrew, could you please add this fix to the mm tree?

Thanks,
Song


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D 8< =3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

From 30fd3683bb62cb81bb144e945edb768aff7ca445 Mon Sep 17 00:00:00 2001
From: Song Liu <songliubraving@fb.com>
Date: Fri, 9 Aug 2019 07:15:17 -0700
Subject: [PATCH] khugepaged: fix double unlock in collapse_file()

In collapse_file, when try_to_release_page() fails, we need to goto
out_unlock, because we already called xas_unlock_irq().

Fixes: 89e1c65c0db7 ("mm,thp: add read-only THP support for (non-shmem) FS"=
)
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/khugepaged.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 40c25ddf29e4..f3b94a5a9c43 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1472,7 +1472,7 @@ static void collapse_file(struct mm_struct *mm,
                if (page_has_private(page) &&
                    !try_to_release_page(page, GFP_KERNEL)) {
                        result =3D SCAN_PAGE_HAS_PRIVATE;
-                       break;
+                       goto out_unlock;
                }

                if (page_mapped(page))
--
2.17.1

