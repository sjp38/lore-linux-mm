Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DA41C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:17:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C082220896
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:17:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="L/o+F1YE";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="M2lZKjXj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C082220896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F5E96B000D; Wed, 12 Jun 2019 18:17:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A87A6B000E; Wed, 12 Jun 2019 18:17:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D1F66B0010; Wed, 12 Jun 2019 18:17:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01A666B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:17:37 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x9so12978146pfm.16
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:17:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=UVi6SBU+TU6DizdoSHF74BKKc4C3hYdoIzsJ+g9SNnA=;
        b=jpwIbH2SFIGkap89umSRAuz2T8uLuy5c70TdpHurH3m/QDwLecQzHwCed01EUF6rcj
         kh5M3qHWP+iM8Z5ouWd7hCMk3SuRDRHW/jU1yHLIN3+FcVQ1SezDFIpYtzvRKg3Ls7HF
         ys5XFI+xLtpW6U5jT4GbJKzMkIx7X7IaV3vNYEEMYKDhhXVzbYnw4usUPXsFDjAyynXS
         +orPOBisopV7EsvoXJuA2QOLIvuSQ2QEJAxqCgPa67UEKmhqvYk+z0wUqkz0Q8+SbpLN
         FTAliDK1c2EKpIeoyVEsqKifWosoTSYzHHJEsaEFCDibMuC/oeADGj/Nr8eX8gZuDZNN
         DrYw==
X-Gm-Message-State: APjAAAUT5E9pwJSK9Nb1XxGRsk5CcSDFOFpmL1D3Pipuuu6KT0/vKzGj
	iXlWOhbjEo1VJhHfw21rakfOwO1qbSnWBxyFf3JkLR/k7w0x1xQo05QeIit5kHDoJKr5Qa6Z4CR
	OiSKhaQIWX47qpky1R8xxiEHa7ZMRO9rXLQ1Y5PABhRpcW0zYinEavMvHfehXMz5HXw==
X-Received: by 2002:a17:902:2f:: with SMTP id 44mr21984646pla.5.1560377856653;
        Wed, 12 Jun 2019 15:17:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJfltPAWjJQz9FeaLvisjh6ck0uKzZkXmzYyLOzyV+4nH/WJ4+yL8PPjWaj1ZJEBsSX2bY
X-Received: by 2002:a17:902:2f:: with SMTP id 44mr21984592pla.5.1560377855883;
        Wed, 12 Jun 2019 15:17:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560377855; cv=none;
        d=google.com; s=arc-20160816;
        b=xnQ7q/Q2BuDCMq9M6WdwwHOvcxaaQd39t6bWBsxODhgA7e5zOkESCg+AbuDlCEWgBN
         uOUfypbSsYdrJ1hFFTLEF+J62H+J2n0PEwYM5Jq+xzCWXWbfzjaVAozf4fpO2fm/xQYy
         e775GCTSpRMIt9GenRCyNhL0iOdwcuYUqd1qr7zJmuBiFtaDF2or77MMkkjnimuRbRtv
         FgGVfQW4T6kYSO6rUnnmSvZzvLbZyPe/eqkqZr27L1CmbDcsYs0TT7+Ou0xCzbgk8yOo
         CfoeCAfmNsiMHe3XU5w4MNMUiVntEZ2E9EQdmBpSn8m/3OMM2VWPtv8DttD6092xbgZl
         yVAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=UVi6SBU+TU6DizdoSHF74BKKc4C3hYdoIzsJ+g9SNnA=;
        b=FG+RAqmKlltrS9WYUWqS1DpINIQTL2cJtE1lHYuqzQo9aU1WNiM5UpBG8UefNqlpyR
         fhFGjeO8OvR9DtNe/b7mclpMJmVeYj7p7lAHRsiRxVWKwk7w2sTKEY2s/SYBHZQaowuZ
         vWb2MfhqJ7BTh6buxuaq6Vx5UGAMgyKP/Zbt2QPeQstRMAnbUanMnH0Yd4YvM2/l4q0P
         nf/C6pnF9f0PxMTw4seLR2C7Tmu+/dc0TTQTaNWIp1nKTu/Y5wabLHSlTRqkdKEihXDW
         mU8CaTizhAfOH+li1iFz0jJZHmprfKAmB8GY5VDsL8ajNjdNJT5mqVd5h3r5HO9g++9f
         6KKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="L/o+F1YE";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=M2lZKjXj;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v5si870716pgs.285.2019.06.12.15.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:17:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="L/o+F1YE";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=M2lZKjXj;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5CMF27q025292;
	Wed, 12 Jun 2019 15:17:02 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=UVi6SBU+TU6DizdoSHF74BKKc4C3hYdoIzsJ+g9SNnA=;
 b=L/o+F1YEvKougvxpw/JLp475Ms2eLuI9AHg843Q0ZY6je/H1JRNLIss9qxkWUaBYlQvn
 g3obIW1d8pkaEHWzP8urS0plHtm7op2NxrThO/N6UdCytVrtlRE7CM4m2h6WK4nhLt8/
 F5lUzF/wO42ZevCzixoAI/tXJMpqmBekK6g= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t39sng1nu-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 12 Jun 2019 15:17:02 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 12 Jun 2019 15:17:02 -0700
Received: from prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 12 Jun 2019 15:17:02 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx05.TheFacebook.com (2620:10d:c081:6::19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 12 Jun 2019 15:17:00 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 12 Jun 2019 15:17:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=UVi6SBU+TU6DizdoSHF74BKKc4C3hYdoIzsJ+g9SNnA=;
 b=M2lZKjXjsCPh5yF468P+OMr9EAZOnxWgy+qbjrOqk+eLxIUHWuK8ZWwtP80iA4ofZn/O+dTwJKLLrIf5/har0Nub15qzKSEQDV7ucPbpIrp6iKfGyRHDpDuNA46SLBVwCG7H6eIrk5my22+qsbDkYuPcQj7m7pIo0+MTzKjsjJ4=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1614.namprd15.prod.outlook.com (10.175.140.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1965.14; Wed, 12 Jun 2019 22:16:56 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.012; Wed, 12 Jun 2019
 22:16:56 +0000
From: Song Liu <songliubraving@fb.com>
To: LKML <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>
CC: "namit@vmware.com" <namit@vmware.com>,
        Peter Zijlstra
	<peterz@infradead.org>,
        Oleg Nesterov <oleg@redhat.com>, Steven Rostedt
	<rostedt@goodmis.org>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
        "Kernel
 Team" <Kernel-team@fb.com>
Subject: Re: [PATCH v3 6/6] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Topic: [PATCH v3 6/6] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Index: AQHVIWshArYC/hbTQ0OTiKqf6fr6IKaYlj+A
Date: Wed, 12 Jun 2019 22:16:56 +0000
Message-ID: <A753B71F-6AA2-494F-A790-C32E13555B83@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
 <20190612220320.2223898-7-songliubraving@fb.com>
In-Reply-To: <20190612220320.2223898-7-songliubraving@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [199.201.64.139]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 088d4e8b-f3f5-492f-ed51-08d6ef83ae62
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1614;
x-ms-traffictypediagnostic: MWHPR15MB1614:
x-microsoft-antispam-prvs: <MWHPR15MB1614E995C0D243BE4E20EE68B3EC0@MWHPR15MB1614.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0066D63CE6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(376002)(39860400002)(346002)(396003)(199004)(189003)(186003)(66066001)(305945005)(53936002)(71200400001)(8676002)(2906002)(76176011)(71190400001)(6512007)(11346002)(81166006)(14454004)(50226002)(68736007)(25786009)(54906003)(110136005)(446003)(3846002)(86362001)(57306001)(316002)(6436002)(6486002)(81156014)(8936002)(6116002)(256004)(14444005)(4326008)(6506007)(66946007)(66556008)(73956011)(6246003)(64756008)(76116006)(66446008)(7736002)(36756003)(33656002)(99286004)(476003)(2616005)(478600001)(102836004)(53546011)(26005)(229853002)(486006)(66476007)(2501003)(5660300002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1614;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Rbs4AV9+FvBWKWHT4g3MPc8dI6PlePm4QQPrm7MpQh5caEqT9v4vJxuwSmAi0MICslS2yI879/Vwii8SjaIZpNaGEZ6KkdRlig6bjh1fo284ckq4EwvfLQSYApnkeUXlyBGLCB9xpkuEIdj2B2OtQ4PLN0ts1+5D2fTm+ckVgxKhQ8ZjbxNFudST1E+gKNV6rdLSUbKiCpDocvrieBuME5IB0eS1QStRDs00C2WxhaO0HTlI6pPpl5AzaKEbaKFheai5euyR/V8lIt2AeJ/H1LR585AQ9MfS98Yq0Q9RcVdhYvLlH8nB//NFeDPB/sLcf+AsziUWTl0P9Bzmf7Op6eXQgE3F6DrE+rsnr2sWzxjDex+1Z5tyIXHMJF9zgZ5Hp42NTEuZ+fMfK9O0tS+qmdA5qX32YxEgX1DT7FaUZuI=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <0643978759D03543AAFF76D809971BC1@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 088d4e8b-f3f5-492f-ed51-08d6ef83ae62
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Jun 2019 22:16:56.3836
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1614
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-12_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906120155
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 12, 2019, at 3:03 PM, Song Liu <songliubraving@fb.com> wrote:
>=20
> This patches introduces a new foll_flag: FOLL_SPLIT_PMD. As the name says
> FOLL_SPLIT_PMD splits huge pmd for given mm_struct, the underlining huge
> page stays as-is.
>=20
> FOLL_SPLIT_PMD is useful for cases where we need to use regular pages,
> but would switch back to huge page and huge pmd on. One of such example
> is uprobe. The following patches use FOLL_SPLIT_PMD in uprobe.
>=20
> Signed-off-by: Song Liu <songliubraving@fb.com>

Please ignore this one. It is a duplicated copy of 3/5, sent by accident.=20

Sorry for the noise.=20

Song

> ---
> include/linux/mm.h |  1 +
> mm/gup.c           | 38 +++++++++++++++++++++++++++++++++++---
> 2 files changed, 36 insertions(+), 3 deletions(-)
>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0ab8c7d84cd0..e605acc4fc81 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2642,6 +2642,7 @@ struct page *follow_page(struct vm_area_struct *vma=
, unsigned long address,
> #define FOLL_COW	0x4000	/* internal GUP flag */
> #define FOLL_ANON	0x8000	/* don't do file mappings */
> #define FOLL_LONGTERM	0x10000	/* mapping lifetime is indefinite: see belo=
w */
> +#define FOLL_SPLIT_PMD	0x20000	/* split huge pmd before returning */
>=20
> /*
>  * NOTE on FOLL_LONGTERM:
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097cf9e4..3d05bddb56c9 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -398,7 +398,7 @@ static struct page *follow_pmd_mask(struct vm_area_st=
ruct *vma,
> 		spin_unlock(ptl);
> 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
> 	}
> -	if (flags & FOLL_SPLIT) {
> +	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
> 		int ret;
> 		page =3D pmd_page(*pmd);
> 		if (is_huge_zero_page(page)) {
> @@ -407,7 +407,7 @@ static struct page *follow_pmd_mask(struct vm_area_st=
ruct *vma,
> 			split_huge_pmd(vma, pmd, address);
> 			if (pmd_trans_unstable(pmd))
> 				ret =3D -EBUSY;
> -		} else {
> +		} else if (flags & FOLL_SPLIT) {
> 			if (unlikely(!try_get_page(page))) {
> 				spin_unlock(ptl);
> 				return ERR_PTR(-ENOMEM);
> @@ -419,8 +419,40 @@ static struct page *follow_pmd_mask(struct vm_area_s=
truct *vma,
> 			put_page(page);
> 			if (pmd_none(*pmd))
> 				return no_page_table(vma, flags);
> -		}
> +		} else {  /* flags & FOLL_SPLIT_PMD */
> +			unsigned long addr;
> +			pgprot_t prot;
> +			pte_t *pte;
> +			int i;
> +
> +			spin_unlock(ptl);
> +			split_huge_pmd(vma, pmd, address);
> +			lock_page(page);
> +			pte =3D get_locked_pte(mm, address, &ptl);
> +			if (!pte) {
> +				unlock_page(page);
> +				return no_page_table(vma, flags);
> +			}
>=20
> +			/* get refcount for every small page */
> +			page_ref_add(page, HPAGE_PMD_NR);
> +
> +			prot =3D READ_ONCE(vma->vm_page_prot);
> +			for (i =3D 0, addr =3D address & PMD_MASK;
> +			     i < HPAGE_PMD_NR; i++, addr +=3D PAGE_SIZE) {
> +				struct page *p =3D page + i;
> +
> +				pte =3D pte_offset_map(pmd, addr);
> +				VM_BUG_ON(!pte_none(*pte));
> +				set_pte_at(mm, addr, pte, mk_pte(p, prot));
> +				page_add_file_rmap(p, false);
> +			}
> +
> +			spin_unlock(ptl);
> +			unlock_page(page);
> +			add_mm_counter(mm, mm_counter_file(page), HPAGE_PMD_NR);
> +			ret =3D 0;
> +		}
> 		return ret ? ERR_PTR(ret) :
> 			follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
> 	}
> --=20
> 2.17.1
>=20

