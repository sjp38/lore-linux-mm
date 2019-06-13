Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F8B9C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:58:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDB7B20673
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 13:58:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="gQHWlxBo";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="qYg2Ce4h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDB7B20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C3EF6B000E; Thu, 13 Jun 2019 09:58:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94E846B0266; Thu, 13 Jun 2019 09:58:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C8406B026A; Thu, 13 Jun 2019 09:58:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E11F6B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:58:13 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b127so14518664pfb.8
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:58:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=sPKp7dftjDZTUROeV+8hlBIhmw8JOgf/Oya5kKKdvzY=;
        b=diiKFsKavAv5JmfYeEaA4Ev9JaHY116/89dixll2oQPN5S8DQjQYu7UAX7PatsCUc9
         ugVidasXGuRudAb423dKhUvoM8ctA8LbUBX1hlVzTsGmzMVj/D6yaOGA5P4k3cYBkBnM
         ZxCOl3sqlvprzNVbkSzrHWfTtrrfexH3uhrmII031hWJ7TCHmbgCHxBUSqQTYTm+EoYi
         Qosb1VIG36tyMDHymP74CPvdNi4wn5Sg1avTCPuLJR3RzRfj5QClDiTjx4nUwzJ3ke7S
         k1Mx867QDf9SQ7YPk7jcNEZQ40ZWerEWc6fVbtJ+fluUTHkeOPZP5z0sMSiKslcs5Qy4
         VQVA==
X-Gm-Message-State: APjAAAXiSke6FDRFU11rnpA3G0uNi+NcjUV+fBA/J5YRq3TcT+XRbywG
	NgIQJMz5vkSI8vyPaDuGjXDeq28XNTea7AuDs6M57bB8mg49vcQHclfY0Bps3PYjUDbv4fZ2GIJ
	Gzlq2PyqXwEz6+3tpLkw7M2c0BGTovCAQX3E/DKLfac+fuYsWyYfX736+lpib3OwRiw==
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr86891391plr.243.1560434292888;
        Thu, 13 Jun 2019 06:58:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+ZbSK0D15hd5HZoII/cgz122uYkCLAnZ18b/C+5sl94lLAXelYCG4nuPYuWHgGDhn2crm
X-Received: by 2002:a17:902:b495:: with SMTP id y21mr86891323plr.243.1560434292087;
        Thu, 13 Jun 2019 06:58:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560434292; cv=none;
        d=google.com; s=arc-20160816;
        b=uTYMXfWw02TzDLcKM99wKJ16N3Gaz1Lmb7BixBFq0WWOyTJmwMMmVaWtDjpM+/2uuX
         UtuAzLh8vyT2agu3N4GwNw+jFlcfZ1VcinKxXacb+nmd6wjah11U8PwtNuKuEE+F/EA5
         B+RadMPYE+YbkpIkaTJ9w80BtGMaBiivnQ16iLh9G5i+u9Jdc+p0tuzkTdcjZJz9+b5X
         OKNAHrnZZQZlB9uWT+dPpquQut3enK/T377u8YjY892yc/SRsFM7HmgSiajguUKv4NNA
         0TzT8msydDl45HWvrn/3wXrvppTxOP9yawRramJuaakJI8ca9PGHtYC5O1NpCw2mfNv7
         dGtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=sPKp7dftjDZTUROeV+8hlBIhmw8JOgf/Oya5kKKdvzY=;
        b=c6r+ciPfijZLv+/B5PeXq8EotSuE0fgbVnNyUP3NHbWEP3AgJsuosF+fK4ghwVO9vA
         KpZy86pbL6C3tWbXdD9ab2/VLnVnvBm9Z8JcqJYJPIu3kxjSvA3QFuNfS6kR3Qd8tsF1
         2Z6OozJweGQQgWj/ygNw2qa9GMqXiy2HkJXyM6yM0Z3wowNiztwhOy308dh/b+AUtF9G
         YWbcqg58sbbNXrf1uftF6MLK7Tx57q7d9nWijRNccLX730j8GmiZON1PbQ8epGZWpYE0
         /jprzXsQVkl6DZq1m011wrnnpZN4WZ4hKXNBcFT1FpC6OHoMw+jBWzaqwlLNUzWzPD1E
         cezA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=gQHWlxBo;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=qYg2Ce4h;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t2si3122959ply.133.2019.06.13.06.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 06:58:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=gQHWlxBo;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=qYg2Ce4h;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5DDnmql012717;
	Thu, 13 Jun 2019 06:57:34 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=sPKp7dftjDZTUROeV+8hlBIhmw8JOgf/Oya5kKKdvzY=;
 b=gQHWlxBogLv+y1N2nTtCcGAa/NS4luB8J3rrd1JqsR77caHn4OtuUI2TDpkuN20Agm0g
 UffKl79hSQCQGxtT1FBak78VOmNQoxz2FahQDGtk3MFEc9QyLYaon3eBlreAFbFvMr3C
 SwWmqMOimLIF9ymjZkq+I7Np8t+IOVVbD+k= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3pxp86p7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 13 Jun 2019 06:57:33 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-hub04.TheFacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 13 Jun 2019 06:57:32 -0700
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 13 Jun 2019 06:57:32 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sPKp7dftjDZTUROeV+8hlBIhmw8JOgf/Oya5kKKdvzY=;
 b=qYg2Ce4hHvBUgW7xQdritygfR20oO8gn4HPVA4A3MHdiDZ5ZeB0hREyurK+lbnEZHTRJE0aRc8ue+qV8xwR8fvDts5q4Pos/3SAKfGiL7zkMg5oPjKG9yPb+AQgmFTJORBBHUFaT8dCUO5KuC1CpuydKgNDgsqqV1ekjXM3GoU4=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1871.namprd15.prod.outlook.com (10.174.255.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 13 Jun 2019 13:57:30 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 13:57:30 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: LKML <linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "namit@vmware.com" <namit@vmware.com>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "oleg@redhat.com"
	<oleg@redhat.com>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "mhiramat@kernel.org" <mhiramat@kernel.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH v3 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Topic: [PATCH v3 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Index: AQHVIWtWTe7ps5z8rEO6sAR2s+F9WKaZjDkAgAAQ0IA=
Date: Thu, 13 Jun 2019 13:57:30 +0000
Message-ID: <5A80A2B9-51C3-49C4-97B6-33889CC47F08@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
 <20190612220320.2223898-4-songliubraving@fb.com>
 <20190613125718.tgplv5iqkbfhn6vh@box>
In-Reply-To: <20190613125718.tgplv5iqkbfhn6vh@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:7078]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 04ff8ad5-f00c-454a-60e6-08d6f00713de
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1871;
x-ms-traffictypediagnostic: MWHPR15MB1871:
x-microsoft-antispam-prvs: <MWHPR15MB18711CCA673769FF3A42D435B3EF0@MWHPR15MB1871.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(39860400002)(366004)(346002)(136003)(396003)(199004)(189003)(316002)(4326008)(36756003)(25786009)(14454004)(8936002)(5660300002)(81166006)(7736002)(81156014)(6246003)(305945005)(50226002)(478600001)(54906003)(8676002)(68736007)(66476007)(66556008)(6486002)(6436002)(66446008)(64756008)(76116006)(73956011)(66946007)(91956017)(57306001)(53936002)(14444005)(256004)(86362001)(2906002)(6916009)(6116002)(6512007)(33656002)(229853002)(7416002)(99286004)(53546011)(6506007)(446003)(11346002)(71190400001)(76176011)(71200400001)(2616005)(476003)(186003)(46003)(102836004)(486006);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1871;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: nTC3opoQDaugBMSZME5O9aa0UVJOH3kS3RB1oa7zQqJs8kV4CXyIv0UcRCEbJXrFV9O1YNQOvQiOd+vnpdJgIIla/hcpmWAQ+butJ+7QD+GbGrCDzbLXIxGMPMeAsWpEKAMQWgQxG1mIOx76/ufkytM6uRh0imkH6T3EPhqOs3rSqV7hSJgavEnGP6jdeXpUoQojZgRqnnVxUkfzvoXttKx+jhYYEXrlzqsSsHQ4fUZK15pojksr/733Yddw8eWQ7BRbot2quloPqzIMLvUM0+pTzY07tlR9b8C4i3IFVqHkvCAuOs9tWALX8uFKfL+XoNW44vn2ovKnLsD0aBVjk9Ihxx7B4c8y8iFJ5I8HexJiJx2g7/3GnfpZco7FFtgqMfWFMq8rWPCymek8zdkBtcDcavAkOTGZPC14O/NNiFw=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <AA72B8B2D2D6A04594DF1649487A026C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 04ff8ad5-f00c-454a-60e6-08d6f00713de
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 13:57:30.6830
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1871
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130106
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 13, 2019, at 5:57 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Wed, Jun 12, 2019 at 03:03:17PM -0700, Song Liu wrote:
>> This patches introduces a new foll_flag: FOLL_SPLIT_PMD. As the name say=
s
>> FOLL_SPLIT_PMD splits huge pmd for given mm_struct, the underlining huge
>> page stays as-is.
>>=20
>> FOLL_SPLIT_PMD is useful for cases where we need to use regular pages,
>> but would switch back to huge page and huge pmd on. One of such example
>> is uprobe. The following patches use FOLL_SPLIT_PMD in uprobe.
>>=20
>> Signed-off-by: Song Liu <songliubraving@fb.com>
>> ---
>> include/linux/mm.h |  1 +
>> mm/gup.c           | 38 +++++++++++++++++++++++++++++++++++---
>> 2 files changed, 36 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 0ab8c7d84cd0..e605acc4fc81 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -2642,6 +2642,7 @@ struct page *follow_page(struct vm_area_struct *vm=
a, unsigned long address,
>> #define FOLL_COW	0x4000	/* internal GUP flag */
>> #define FOLL_ANON	0x8000	/* don't do file mappings */
>> #define FOLL_LONGTERM	0x10000	/* mapping lifetime is indefinite: see bel=
ow */
>> +#define FOLL_SPLIT_PMD	0x20000	/* split huge pmd before returning */
>>=20
>> /*
>>  * NOTE on FOLL_LONGTERM:
>> diff --git a/mm/gup.c b/mm/gup.c
>> index ddde097cf9e4..3d05bddb56c9 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -398,7 +398,7 @@ static struct page *follow_pmd_mask(struct vm_area_s=
truct *vma,
>> 		spin_unlock(ptl);
>> 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
>> 	}
>> -	if (flags & FOLL_SPLIT) {
>> +	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
>> 		int ret;
>> 		page =3D pmd_page(*pmd);
>> 		if (is_huge_zero_page(page)) {
>> @@ -407,7 +407,7 @@ static struct page *follow_pmd_mask(struct vm_area_s=
truct *vma,
>> 			split_huge_pmd(vma, pmd, address);
>> 			if (pmd_trans_unstable(pmd))
>> 				ret =3D -EBUSY;
>> -		} else {
>> +		} else if (flags & FOLL_SPLIT) {
>> 			if (unlikely(!try_get_page(page))) {
>> 				spin_unlock(ptl);
>> 				return ERR_PTR(-ENOMEM);
>> @@ -419,8 +419,40 @@ static struct page *follow_pmd_mask(struct vm_area_=
struct *vma,
>> 			put_page(page);
>> 			if (pmd_none(*pmd))
>> 				return no_page_table(vma, flags);
>> -		}
>> +		} else {  /* flags & FOLL_SPLIT_PMD */
>> +			unsigned long addr;
>> +			pgprot_t prot;
>> +			pte_t *pte;
>> +			int i;
>> +
>> +			spin_unlock(ptl);
>> +			split_huge_pmd(vma, pmd, address);
>=20
> All the code below is only relevant for file-backed THP. It will break fo=
r
> anon-THP.

Oh, yes, that makes sense.=20

>=20
> And I'm not convinced that it belongs here at all. User requested PMD
> split and it is done after split_huge_pmd(). The rest can be handled by
> the caller as needed.

I put this part here because split_huge_pmd() for file-backed THP is
not really done after split_huge_pmd(). And I would like it done before
calling follow_page_pte() below. Maybe we can still do them here, just=20
for file-backed THPs?

If we would move it, shall we move to callers of follow_page_mask()?=20
In that case, we will probably end up with similar code in two places:
__get_user_pages() and follow_page().=20

Did I get this right?

>=20
>> +			lock_page(page);
>> +			pte =3D get_locked_pte(mm, address, &ptl);
>> +			if (!pte) {
>> +				unlock_page(page);
>> +				return no_page_table(vma, flags);
>=20
> Or should it be -ENOMEM?

Yeah, ENOMEM is more accurate.=20

Thanks,
Song

>=20
>> +			}
>>=20
>> +			/* get refcount for every small page */
>> +			page_ref_add(page, HPAGE_PMD_NR);
>> +
>> +			prot =3D READ_ONCE(vma->vm_page_prot);
>> +			for (i =3D 0, addr =3D address & PMD_MASK;
>> +			     i < HPAGE_PMD_NR; i++, addr +=3D PAGE_SIZE) {
>> +				struct page *p =3D page + i;
>> +
>> +				pte =3D pte_offset_map(pmd, addr);
>> +				VM_BUG_ON(!pte_none(*pte));
>> +				set_pte_at(mm, addr, pte, mk_pte(p, prot));
>> +				page_add_file_rmap(p, false);
>> +			}
>> +
>> +			spin_unlock(ptl);
>> +			unlock_page(page);
>> +			add_mm_counter(mm, mm_counter_file(page), HPAGE_PMD_NR);
>> +			ret =3D 0;
>> +		}
>> 		return ret ? ERR_PTR(ret) :
>> 			follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
>> 	}
>> --=20
>> 2.17.1
>>=20
>=20
> --=20
> Kirill A. Shutemov

