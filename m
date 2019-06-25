Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65460C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 12:33:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3579213F2
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 12:33:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Kc2FR3IN";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="pRWkOCjB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3579213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 663656B0003; Tue, 25 Jun 2019 08:33:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 614308E0003; Tue, 25 Jun 2019 08:33:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B4D18E0002; Tue, 25 Jun 2019 08:33:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 111066B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 08:33:58 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id z1so11785519pfb.7
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 05:33:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Xe6LkEZxFkRd/WTjSKucLrojQ+ICs1avXjuoJ2vFg38=;
        b=kpm5TMn01+Sf0F9wJBL0b9eRf+ercad5144FxILOFjCZ/oQx5gyTHSQCmRhpcHQiPP
         UKrDRJ9wAkN9ztWs1odBXBwZ9P3ExNMgcSerYWVZt+tuhRmKPHzZRWABdhQkU3EjxezG
         iNhUH6SaaDe6RT9b3Achh5Vj8ie+DpZgWtg+63N2oJobSxeMCApwKRV2+03JEJzWlNrZ
         FwjtrrvNZ+73ufW0o68huWumlExXm1yQZSrmluQA0GMHGeI57coVnZC4i4bZfFmaiZqv
         GEkEpBNUuC8sOKhIR9oV1D1w3+wUFOQrPKMSgf/3K0qLzCim3VEXebT/wQKlpJAR8/HD
         4Ftg==
X-Gm-Message-State: APjAAAWnaKlBlufRc7xh8psMcsQXCEnIF0skJY6tl7imTNe4TzOdbcXo
	1DF7vuwUVrnazWzv0YEIS29PJqod9o+mHGhVPNh+H+ufLsjTet0Yrl1oWKp8IsdNQScRM0dmrbw
	/VYxowXZlW56RKmLi1xQsJkcb99GDocW6aBHrrA9TssT7ETVQaSGsbT5lATnwCsmHbA==
X-Received: by 2002:a17:90a:1c1:: with SMTP id 1mr31780001pjd.72.1561466037632;
        Tue, 25 Jun 2019 05:33:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyafx4JFfwTP+XSnZP7YhO755a7J0Idc5jEqANqw71WPMCT7ymXEzKId0/QPbXK1cQWJj1L
X-Received: by 2002:a17:90a:1c1:: with SMTP id 1mr31779896pjd.72.1561466036562;
        Tue, 25 Jun 2019 05:33:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561466036; cv=none;
        d=google.com; s=arc-20160816;
        b=aKOmeRT/crtr88vsvf5RkAsI00l9RX95BiouK0jckWUV62bphtRXqx9GWPQYAf3/CD
         8Ph1NzIYlpphDkl+Qx2FSjxDTfvGIe5BGAIDNUc3htnts06RdxrtAGjrQ/Fyt1FCburh
         tu1s5bqxItdcu/vFf3rWtfZ4UamYl4hvrgU/9ofndZbiVnavJIOZy0FwucFg19L1m85S
         tDZ/yglZzvCYZzw/SZJf6KzcHRibhruR6Dffx00D21sdDE0qLWvCPIShUwaN3NG10nJJ
         H5pWGBhM0YD/NYAjWrnGP69DqGmyK697KvFiGa0lTjFMV5LZ656o7ran+lL4WZx2XE3F
         Tbjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Xe6LkEZxFkRd/WTjSKucLrojQ+ICs1avXjuoJ2vFg38=;
        b=Q7gknz0E6SAc2kz9o/UshaEUb+1XIk4nyfj3DPSUHCBSEgakaRDDs88W2rUtxuSUte
         aJzWTPye2P7Z2XIUHuG5dv+BXNkA6h9iSdRBcYHmPR51kvP9kUUIUi4vHNv2WqjrOssi
         ykODA6Y2yychzjv98XcFoJ7dK5UmpW1CTcfW6zOXu6/2e64W5LplLk7+y/cqk9glXWwI
         iBPmUO9fv4xUdrSb39DHTwhrUXnsFTXImKyUKVeroCDGFQfWw2dGbXL4ECkiLum9WqLm
         PWmCxQ0p9uPGyoWqtpE3FJrHg2dON4lnqVXm7gZJbs+tK6LpIaiA0CqTnT6+tHOLGR3R
         uKQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Kc2FR3IN;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=pRWkOCjB;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e123si14559196pfa.252.2019.06.25.05.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 05:33:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Kc2FR3IN;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=pRWkOCjB;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5PCMgW4023488;
	Tue, 25 Jun 2019 05:33:20 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Xe6LkEZxFkRd/WTjSKucLrojQ+ICs1avXjuoJ2vFg38=;
 b=Kc2FR3INTT0L7+w1tHbVsbD5KqLXAvSJyROAP4t7Y7AaEsaXiBNG7a+kCI62veAonyZ8
 Djb/jkyuM03hopzHrRtNEEE4qOb1IFhorVJ6jI7XzcCo5eMDZOfA+4O92ox9ctACZabH
 qWc0KJvEc34Vtir6tt+ifQjWFMGUMR/+CJQ= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2tb7gut8ra-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 25 Jun 2019 05:33:20 -0700
Received: from prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 25 Jun 2019 05:33:19 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx04.TheFacebook.com (2620:10d:c081:6::18) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 25 Jun 2019 05:33:19 -0700
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 25 Jun 2019 05:33:19 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Xe6LkEZxFkRd/WTjSKucLrojQ+ICs1avXjuoJ2vFg38=;
 b=pRWkOCjBMM8BGO8KycL9kUFUQsVLlonN2qKQiHs4lXGV3fkp0COIwNSlfdkHM4g9j4MDHn8uNZjGn4fx8NMnO+owgSjqTdImCZlRJ9lxs9vnzsqU0Tdg318tMybEblbRbbpQhsnkAyghiUp+PNPI7Bm1svz+vWXWbJaQPzr6KpA=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1181.namprd15.prod.outlook.com (10.175.9.8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Tue, 25 Jun 2019 12:33:04 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.017; Tue, 25 Jun 2019
 12:33:03 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
CC: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
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
Thread-Index: AQHVKYdbTu9KGYA+hEyrpX71HNVoZKaqy94AgAASewCAAVGdAIAAIT6A
Date: Tue, 25 Jun 2019 12:33:03 +0000
Message-ID: <77DBF8A2-DF3D-4635-A5E6-66D80A8BFA50@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
 <20190623054829.4018117-6-songliubraving@fb.com>
 <20190624131934.m6gbktixyykw65ws@box>
 <24FB1072-E355-4F9D-855F-337C855C9AF9@fb.com>
 <20190625103404.3ypizksnpopcgwdk@box>
In-Reply-To: <20190625103404.3ypizksnpopcgwdk@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:b854]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 858f89df-2bfd-4554-d1f6-08d6f96944b4
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1181;
x-ms-traffictypediagnostic: MWHPR15MB1181:
x-microsoft-antispam-prvs: <MWHPR15MB11817C001FFAC785C16B7F38B3E30@MWHPR15MB1181.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0079056367
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(346002)(376002)(396003)(366004)(136003)(189003)(199004)(14444005)(53936002)(256004)(8936002)(14454004)(66476007)(66446008)(5660300002)(81166006)(66556008)(76116006)(73956011)(8676002)(66946007)(81156014)(64756008)(99286004)(446003)(11346002)(2616005)(476003)(46003)(6246003)(68736007)(486006)(33656002)(478600001)(7736002)(305945005)(71190400001)(71200400001)(86362001)(229853002)(53546011)(6916009)(316002)(186003)(6486002)(2906002)(4326008)(102836004)(6436002)(25786009)(57306001)(54906003)(6116002)(50226002)(6512007)(36756003)(76176011)(6506007);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1181;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: hxgjeeUttwzu2e45bNmHoQY4Ys+5oPXhkRKmzqQnpF95YSSBenRneaYP20ucQH89IeCk9iJM6fb065G0ihKvA4HmO3WZe48Uj0j0kCgmuDO5E8FLBtCoThF5dBUBM2IRTusMa9hXDIfC9HMhOPBU5DQP/FMUda/jRBaAkykFr1S1n3I9gt5tkckBwAs67NV+/hpJl/lMhvUyH81SdICP1AQeO9L6veIJU/ye8wBJAEHlXdJq6tnxqjw/yk74f0pVOwqD4ftNCoTYEc56jVIi1ME4i0745H3Lf/34cWfkCGHjtDE5/vBdsl/8EVv/LQ7urnok+7Zv8qXXNApoVvqsQodtCpPvdz3+hVLzakUUSWwqjg4x1rBFxHmkHjZGUm4sCYgPTp2hadlmaCKI2GkxXwlxBm3/cBmROr+Rk+J+ZxY=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <55072553C2EAE7409F1689234ACA4FC6@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 858f89df-2bfd-4554-d1f6-08d6f96944b4
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 12:33:03.7796
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1181
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-25_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=858 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250099
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 25, 2019, at 3:34 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Mon, Jun 24, 2019 at 02:25:42PM +0000, Song Liu wrote:
>>=20
>>=20
>>> On Jun 24, 2019, at 6:19 AM, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>>>=20
>>> On Sat, Jun 22, 2019 at 10:48:28PM -0700, Song Liu wrote:
>>>> khugepaged needs exclusive mmap_sem to access page table. When it fail=
s
>>>> to lock mmap_sem, the page will fault in as pte-mapped THP. As the pag=
e
>>>> is already a THP, khugepaged will not handle this pmd again.
>>>>=20
>>>> This patch enables the khugepaged to retry retract_page_tables().
>>>>=20
>>>> A new flag AS_COLLAPSE_PMD is introduced to show the address_space may
>>>> contain pte-mapped THPs. When khugepaged fails to trylock the mmap_sem=
,
>>>> it sets AS_COLLAPSE_PMD. Then, at a later time, khugepaged will retry
>>>> compound pages in this address_space.
>>>>=20
>>>> Since collapse may happen at an later time, some pages may already fau=
lt
>>>> in. To handle these pages properly, it is necessary to prepare the pmd
>>>> before collapsing. prepare_pmd_for_collapse() is introduced to prepare
>>>> the pmd by removing rmap, adjusting refcount and mm_counter.
>>>>=20
>>>> prepare_pmd_for_collapse() also double checks whether all ptes in this
>>>> pmd are mapping to the same THP. This is necessary because some subpag=
e
>>>> of the THP may be replaced, for example by uprobe. In such cases, it
>>>> is not possible to collapse the pmd, so we fall back.
>>>>=20
>>>> Signed-off-by: Song Liu <songliubraving@fb.com>
>>>> ---
>>>> include/linux/pagemap.h |  1 +
>>>> mm/khugepaged.c         | 69 +++++++++++++++++++++++++++++++++++------
>>>> 2 files changed, 60 insertions(+), 10 deletions(-)
>>>>=20
>>>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>>>> index 9ec3544baee2..eac881de2a46 100644
>>>> --- a/include/linux/pagemap.h
>>>> +++ b/include/linux/pagemap.h
>>>> @@ -29,6 +29,7 @@ enum mapping_flags {
>>>> 	AS_EXITING	=3D 4, 	/* final truncate in progress */
>>>> 	/* writeback related tags are not used */
>>>> 	AS_NO_WRITEBACK_TAGS =3D 5,
>>>> +	AS_COLLAPSE_PMD =3D 6,	/* try collapse pmd for THP */
>>>> };
>>>>=20
>>>> /**
>>>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>>>> index a4f90a1b06f5..9b980327fd9b 100644
>>>> --- a/mm/khugepaged.c
>>>> +++ b/mm/khugepaged.c
>>>> @@ -1254,7 +1254,47 @@ static void collect_mm_slot(struct mm_slot *mm_=
slot)
>>>> }
>>>>=20
>>>> #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECACHE=
)
>>>> -static void retract_page_tables(struct address_space *mapping, pgoff_=
t pgoff)
>>>> +
>>>> +/* return whether the pmd is ready for collapse */
>>>> +bool prepare_pmd_for_collapse(struct vm_area_struct *vma, pgoff_t pgo=
ff,
>>>> +			      struct page *hpage, pmd_t *pmd)
>>>> +{
>>>> +	unsigned long haddr =3D page_address_in_vma(hpage, vma);
>>>> +	unsigned long addr;
>>>> +	int i, count =3D 0;
>>>> +
>>>> +	/* step 1: check all mapped PTEs are to this huge page */
>>>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAGE_=
SIZE) {
>>>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>>>> +
>>>> +		if (pte_none(*pte))
>>>> +			continue;
>>>> +
>>>> +		if (hpage + i !=3D vm_normal_page(vma, addr, *pte))
>>>> +			return false;
>>>> +		count++;
>>>> +	}
>>>> +
>>>> +	/* step 2: adjust rmap */
>>>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAGE_=
SIZE) {
>>>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>>>> +		struct page *page;
>>>> +
>>>> +		if (pte_none(*pte))
>>>> +			continue;
>>>> +		page =3D vm_normal_page(vma, addr, *pte);
>>>> +		page_remove_rmap(page, false);
>>>> +	}
>>>> +
>>>> +	/* step 3: set proper refcount and mm_counters. */
>>>> +	page_ref_sub(hpage, count);
>>>> +	add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
>>>> +	return true;
>>>> +}
>>>> +
>>>> +extern pid_t sysctl_dump_pt_pid;
>>>> +static void retract_page_tables(struct address_space *mapping, pgoff_=
t pgoff,
>>>> +				struct page *hpage)
>>>> {
>>>> 	struct vm_area_struct *vma;
>>>> 	unsigned long addr;
>>>> @@ -1273,21 +1313,21 @@ static void retract_page_tables(struct address=
_space *mapping, pgoff_t pgoff)
>>>> 		pmd =3D mm_find_pmd(vma->vm_mm, addr);
>>>> 		if (!pmd)
>>>> 			continue;
>>>> -		/*
>>>> -		 * We need exclusive mmap_sem to retract page table.
>>>> -		 * If trylock fails we would end up with pte-mapped THP after
>>>> -		 * re-fault. Not ideal, but it's more important to not disturb
>>>> -		 * the system too much.
>>>> -		 */
>>>> 		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
>>>> 			spinlock_t *ptl =3D pmd_lock(vma->vm_mm, pmd);
>>>> -			/* assume page table is clear */
>>>> +
>>>> +			if (!prepare_pmd_for_collapse(vma, pgoff, hpage, pmd)) {
>>>> +				spin_unlock(ptl);
>>>> +				up_write(&vma->vm_mm->mmap_sem);
>>>> +				continue;
>>>> +			}
>>>> 			_pmd =3D pmdp_collapse_flush(vma, addr, pmd);
>>>> 			spin_unlock(ptl);
>>>> 			up_write(&vma->vm_mm->mmap_sem);
>>>> 			mm_dec_nr_ptes(vma->vm_mm);
>>>> 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
>>>> -		}
>>>> +		} else
>>>> +			set_bit(AS_COLLAPSE_PMD, &mapping->flags);
>>>> 	}
>>>> 	i_mmap_unlock_write(mapping);
>>>> }
>>>> @@ -1561,7 +1601,7 @@ static void collapse_file(struct mm_struct *mm,
>>>> 		/*
>>>> 		 * Remove pte page tables, so we can re-fault the page as huge.
>>>> 		 */
>>>> -		retract_page_tables(mapping, start);
>>>> +		retract_page_tables(mapping, start, new_page);
>>>> 		*hpage =3D NULL;
>>>>=20
>>>> 		khugepaged_pages_collapsed++;
>>>> @@ -1622,6 +1662,7 @@ static void khugepaged_scan_file(struct mm_struc=
t *mm,
>>>> 	int present, swap;
>>>> 	int node =3D NUMA_NO_NODE;
>>>> 	int result =3D SCAN_SUCCEED;
>>>> +	bool collapse_pmd =3D false;
>>>>=20
>>>> 	present =3D 0;
>>>> 	swap =3D 0;
>>>> @@ -1640,6 +1681,14 @@ static void khugepaged_scan_file(struct mm_stru=
ct *mm,
>>>> 		}
>>>>=20
>>>> 		if (PageTransCompound(page)) {
>>>> +			if (collapse_pmd ||
>>>> +			    test_and_clear_bit(AS_COLLAPSE_PMD,
>>>> +					       &mapping->flags)) {
>>>=20
>>> Who said it's the only PMD range that's subject to collapse? The bit ha=
s
>>> to be per-PMD, not per-mapping.
>>=20
>> I didn't assume this is the only PMD range that subject to collapse.=20
>> So once we found AS_COLLAPSE_PMD, it will continue scan the whole mappin=
g:
>> retract_page_tables(), then continue.=20
>=20
> I still don't get it.
>=20
> Assume we have two ranges that subject to collapse. khugepaged_scan_file(=
)
> sees and clears AS_COLLAPSE_PMD. Tries to collapse the first range, fails
> and set the bit again. khugepaged_scan_file() sees the second range,
> clears the bit, but this time collapse is successful: the bit is still no=
t
> set, but it should be.

Yeah, you are right. Current logic only covers multiple THPs within single
call of khugepaged_scan_file(). I missed the case you just described.=20

What do you think about the first 4 patches of set and the other set? If=20
these patches look good, how about we get them in first? I will work on=20
proper fix (or re-design) for 5/6 and 6/6 in the meanwhile.=20

Thanks,
Song

