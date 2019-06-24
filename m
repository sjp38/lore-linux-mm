Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DF0AC4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:07:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF3CC204FD
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:07:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Oy/XfKc4";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="SCKGUzs5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF3CC204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73F966B0005; Mon, 24 Jun 2019 18:07:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F1088E0003; Mon, 24 Jun 2019 18:07:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5B8558E0002; Mon, 24 Jun 2019 18:07:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35A396B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 18:07:36 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id e7so17558562ybk.22
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:07:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=LbB+A2jZrl6/VgBQUWCu5No6mbMHqxjOmNm1doe7H+Q=;
        b=pKHOYovyBQqmU3oWqvWvWqVJswl3pPH2AnCr4/R+4BQEfzCng+HrjMs9lxNHo639UE
         aF7ddSbkwbGaEKxiMyEJuaPlpNOi3rtGNQjhxTcqU6JTDkabeMCc/kSuml1s7tD9uSoE
         ncvEw4rXrCu4Fv1ChA7Q5mEJzPU6wGuMWa0ioNPCrW8B8dGEmwOlVZMySBjseXyLVhBo
         69gJFYBFE28aYH04im4NuoFGEG7/YUFtet6Xah6Oba8WJDh7NcfLAVNdRZfbXliceWD8
         epr2H/HQ/L5dG+mzfJckCoO6MDmpNDcBh7Rejq/kNLa3duN6yHFDHUtAHSOz9zq9OX8+
         54DA==
X-Gm-Message-State: APjAAAXzMxwlqFyHN2CV+DBWsAN+hwC1jtLWw6INmaVtfdugVwFxAGkc
	tLCIXrAakKNsXajxbc6ffIdbqScwcgxVJ/QHsxcD9hj6du8wKCgAd3tqTgNQP5/bDpCz/hosK+j
	JFGNfIFgtzXsbzMupAX14cv39oyt9LczbOgDhI+IptPwEDlpLc6RlRmB/1Jh8TGYuug==
X-Received: by 2002:a25:4d55:: with SMTP id a82mr48366622ybb.383.1561414055886;
        Mon, 24 Jun 2019 15:07:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwYz26M9yw/ujQXy0+YbYoXaZJj7QpD/RfaqYzRrcBp5ww46OippS+tCWC1lF03Hxh4Dho
X-Received: by 2002:a25:4d55:: with SMTP id a82mr48366580ybb.383.1561414055228;
        Mon, 24 Jun 2019 15:07:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561414055; cv=none;
        d=google.com; s=arc-20160816;
        b=Jm4CnsWzKB+fjRkdMiNzdlXggQyJrcceZvmP+U0WjcIHGASL9HWq4i53cNXFGnEfwY
         YpGuxNkpluRK4zBxm8y5lnyQtSl26h22UDHdJf313KMllEwSRBQkIysX+4hYVUxJ1But
         lpCJdT7DDV8dRSI0EHOKw7A16QdBd7GjbseOTZr2rzpgtUjBVjCBCa6ki+qAfhj8rWhx
         ii/+IIqYrod9IwEIP9ACxzgxp+n0yLiGsfVHRnQK/9K7SFUVg5esWozlGmroq7Kfn/3r
         sczBithBbKiuKatO4MgIr0bXKDcDcj3pN+NrPmye8kN1GwqD2JYXYrCDeHCbuZ7eCYbB
         uPrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=LbB+A2jZrl6/VgBQUWCu5No6mbMHqxjOmNm1doe7H+Q=;
        b=IlaRl9SxD2Nn79x90l81fpbXxrPbMdoYgikXOlYkgdsXFQJrMFi5V2/tT+hJ0Gu/8X
         OqBhOg/Y0dT6h/y6cIiQ16fWU8cmszK0R+4OWU2CwECRTUjIcYgArsl5WZLuW9qHqCBH
         6EjOpdXfbekSQyHjXWxEq++fUu8z3PQE18bYW7AS4RbnvvejO1BYeAIrkrw1GcsU//JV
         Sfl7nEnXyLDenBkGyRpdXS07vdXCfEBfiSeLwZN2ldlXpZ9F6JEC711M4hDRIyhSJ8Ee
         q5SRae7SUb87hao2kp8oZEpmpL4TcM1ozBCow46RdrPTzY2uGLINsHQ9LF8PCu3z8pYA
         B1Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="Oy/XfKc4";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=SCKGUzs5;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id v10si4281655ybm.336.2019.06.24.15.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 15:07:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="Oy/XfKc4";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=SCKGUzs5;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5OM352x020882;
	Mon, 24 Jun 2019 15:07:03 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=LbB+A2jZrl6/VgBQUWCu5No6mbMHqxjOmNm1doe7H+Q=;
 b=Oy/XfKc4wxj0DYs3I0O9AyQ4+L65pGpUao35r3fj3Px/Gr9Mq7aVpfndPO34pvKPWfB7
 mTru5MBsuXj9PVKdSCQ5wI63cB5EUJBb29cfsfJOifjJf07wgTPlEbEKzqqBANgebGgR
 nfNNPgsrsWRCLlqhTxFqkdU1cX8QBkkM+5I= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2tb6j2g3x8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 24 Jun 2019 15:07:03 -0700
Received: from prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 24 Jun 2019 15:07:02 -0700
Received: from prn-hub05.TheFacebook.com (2620:10d:c081:35::129) by
 prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Mon, 24 Jun 2019 15:07:02 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.29) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Mon, 24 Jun 2019 15:07:02 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=LbB+A2jZrl6/VgBQUWCu5No6mbMHqxjOmNm1doe7H+Q=;
 b=SCKGUzs5bQvgaOXJSRdQjxJIp6Ta0YpqfbwTnndZjL6cXbB6nT/KdqCusm0/2XOXkN4+ZcaNo8mvlh48MXTrt41lyiH2AJOk7oR8IsHq7aotjzCjHfF0xjG8VnwRlGzmapmOZA4H2EtO5R25eO7wMrJWTXEfGbuTAiOyeHmAUy8=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1840.namprd15.prod.outlook.com (10.174.99.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.13; Mon, 24 Jun 2019 22:07:00 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.014; Mon, 24 Jun 2019
 22:07:00 +0000
From: Song Liu <songliubraving@fb.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "oleg@redhat.com"
	<oleg@redhat.com>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        Kernel Team
	<Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>
Subject: Re: [PATCH v6 5/6] khugepaged: enable collapse pmd for pte-mapped THP
Thread-Topic: [PATCH v6 5/6] khugepaged: enable collapse pmd for pte-mapped
 THP
Thread-Index: AQHVKYdbTu9KGYA+hEyrpX71HNVoZKarXzqA
Date: Mon, 24 Jun 2019 22:06:59 +0000
Message-ID: <867149FC-1F89-4FE9-98B3-621D2F42B366@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
 <20190623054829.4018117-6-songliubraving@fb.com>
In-Reply-To: <20190623054829.4018117-6-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [199.201.64.134]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4731ca80-ede4-48b6-b452-08d6f8f047e5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1840;
x-ms-traffictypediagnostic: MWHPR15MB1840:
x-microsoft-antispam-prvs: <MWHPR15MB1840052741ED71D6FDBE13B1B3E00@MWHPR15MB1840.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 007814487B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(136003)(396003)(39860400002)(346002)(189003)(199004)(54906003)(229853002)(6512007)(53936002)(6486002)(66946007)(64756008)(66446008)(76116006)(66556008)(66476007)(316002)(478600001)(99286004)(186003)(256004)(6506007)(53546011)(76176011)(2501003)(14444005)(73956011)(3846002)(102836004)(4326008)(68736007)(71190400001)(6116002)(25786009)(71200400001)(11346002)(5660300002)(476003)(446003)(86362001)(50226002)(8676002)(26005)(110136005)(305945005)(486006)(81156014)(8936002)(81166006)(66066001)(7736002)(2906002)(6436002)(6246003)(36756003)(14454004)(57306001)(33656002)(2616005);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1840;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: yk/JYMEiLyBBfP36bNvi+bhIvGrGi1PDlzEoC0oB/U5cOEAMr8JbZD6oiaHVNyKtIePgk64LsGJDJxIMhNWpJdV1VGA4xlRCgF68QQkKWi0I+O28P0Eqed2xnvjeIQDm/xKNqsR6W2VnmMyAKyIPWxBqDOPL1igU+oQWmKiyDRGbAZm5CMqTxjznG8AOpzsw3ECMbIFiGHlpg0kFf/N+tkChLN5J/ou4yJes4nQ31wS5/m3HrLsOvl7Lg5ALjvrWmVs6683WaMEtjGECOb8Ox5Iyb/LLoqPjmY+Pi2Avn1vaSPIIJcdgekFORbV7KqZWEVHCIPqE2o9rF0m35zMXWKBG3+1dRb1bkFfQ+m/bpzNJzCW+kPTQxlT2LUKDQ4Dwrmrq51Cj3kP4JHDhgqIqyOr6ZrwaRMS/Dij5JXtvtWQ=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <440EA5C2B4657A4DB95362F92DF168EC@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 4731ca80-ede4-48b6-b452-08d6f8f047e5
X-MS-Exchange-CrossTenant-originalarrivaltime: 24 Jun 2019 22:07:00.0148
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1840
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240174
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 22, 2019, at 10:48 PM, Song Liu <songliubraving@fb.com> wrote:
>=20
> khugepaged needs exclusive mmap_sem to access page table. When it fails
> to lock mmap_sem, the page will fault in as pte-mapped THP. As the page
> is already a THP, khugepaged will not handle this pmd again.
>=20
> This patch enables the khugepaged to retry retract_page_tables().
>=20
> A new flag AS_COLLAPSE_PMD is introduced to show the address_space may
> contain pte-mapped THPs. When khugepaged fails to trylock the mmap_sem,
> it sets AS_COLLAPSE_PMD. Then, at a later time, khugepaged will retry
> compound pages in this address_space.
>=20
> Since collapse may happen at an later time, some pages may already fault
> in. To handle these pages properly, it is necessary to prepare the pmd
> before collapsing. prepare_pmd_for_collapse() is introduced to prepare
> the pmd by removing rmap, adjusting refcount and mm_counter.
>=20
> prepare_pmd_for_collapse() also double checks whether all ptes in this
> pmd are mapping to the same THP. This is necessary because some subpage
> of the THP may be replaced, for example by uprobe. In such cases, it
> is not possible to collapse the pmd, so we fall back.
>=20
> Signed-off-by: Song Liu <songliubraving@fb.com>
> ---
> include/linux/pagemap.h |  1 +
> mm/khugepaged.c         | 69 +++++++++++++++++++++++++++++++++++------
> 2 files changed, 60 insertions(+), 10 deletions(-)
>=20
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 9ec3544baee2..eac881de2a46 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -29,6 +29,7 @@ enum mapping_flags {
> 	AS_EXITING	=3D 4, 	/* final truncate in progress */
> 	/* writeback related tags are not used */
> 	AS_NO_WRITEBACK_TAGS =3D 5,
> +	AS_COLLAPSE_PMD =3D 6,	/* try collapse pmd for THP */
> };
>=20
> /**
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index a4f90a1b06f5..9b980327fd9b 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1254,7 +1254,47 @@ static void collect_mm_slot(struct mm_slot *mm_slo=
t)
> }
>=20
> #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE)
> -static void retract_page_tables(struct address_space *mapping, pgoff_t p=
goff)
> +
> +/* return whether the pmd is ready for collapse */
> +bool prepare_pmd_for_collapse(struct vm_area_struct *vma, pgoff_t pgoff,
> +			      struct page *hpage, pmd_t *pmd)


kbuild test robot reported I missed "static" here. But I am holding off a=20
newer version that just fixes this.=20

Thanks,=20
Song

