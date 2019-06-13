Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 123AFC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:24:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B46672082C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:24:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="AwqPgJ4i";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ZNz2GTn4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B46672082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 565DF6B0006; Thu, 13 Jun 2019 11:24:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EF558E0001; Thu, 13 Jun 2019 11:24:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 390886B000C; Thu, 13 Jun 2019 11:24:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 131806B0006
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:24:40 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f69so20187066ywb.21
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:24:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=5upTGPFsqkaNgj1lgYq0xrYnDw/z1eQKH2p21LD4RJw=;
        b=iDbEUGeMuxm/7tMqpgKE95aBbkDOM5R36Ju13e/53qRjQb+j5r5V+EzJYywAQK8bXX
         umIUSMExyh7drXbdI1acicrcIFuJECBDd0bQYYVHG5Jm5cdoALDAwDDWGYbpJg9NKYih
         KtAprOtz3qZT0/IL1j2NJojUx7Pg4j3saiDZzgz090P0K8KfldN4if5IcZu/5guREi6y
         jL17dAQgyszCGFnFhfM4iFDJfbjyZfdmKi44Tu3anvJQ7fakp4HpZw4lXMAGcBL7SGr6
         72EehwWD0zIrF7cPFwY8FS4yI8nCK0EIM5/dvtHp1vQaBYXbKOJR3zELPtwnqNUmyrMA
         1LTQ==
X-Gm-Message-State: APjAAAVEonM2IJwpkSHrUMcNIPpaR9iXoJo08swxCGd+kx1uipQqK+Ub
	IUspC/ZI6XHTFXTP0Mx+QMNxCTiBE2X2MWvp608e69QlagnchNORSkCgEfU8KkJ58++t8x+O3LK
	bZZJr+1uAYUaqgSBnGHS061l679PViSS+JIbF6zMfMqt7d6smytEgtOQ30AG6UCZyFA==
X-Received: by 2002:a81:4cd:: with SMTP id 196mr46865032ywe.101.1560439479777;
        Thu, 13 Jun 2019 08:24:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdlM0N3ffYOmMOWjRBE2oG5xb3sLmkyyNx1BlijWu0uPQzIMqpxtwkU3iTO49zmGGx1gW4
X-Received: by 2002:a81:4cd:: with SMTP id 196mr46864972ywe.101.1560439479014;
        Thu, 13 Jun 2019 08:24:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560439479; cv=none;
        d=google.com; s=arc-20160816;
        b=ToFi2MAGyCrB3wRuhCfFr7434nkyE4OpN72qg0PQ/12wYr3kdpyDRKTviaXfuuN9ri
         Ghg60loM46GCKD1iY0DLHF6M2tpdOlUyCKUZ3LIfQKwMryfioZfTw0eDpI8QsTBkt90S
         PRe9Yq9GFvDiazxghiuZPpzqj7/FsL107CAGSMPVvTlwXnyTUpolHQWfw5Sk4Zb2bVXk
         xow5D1EsYJdrV2PxofjCqLsYZv3NK/9EJDjuFwEz8wJNcQH019+2Xv9uVqKpfprilMnr
         i9mf9vizV70mhk9HfD3gTB2FHvBvUSEfE58r9K5e9sRqXSQDDjOYd/2cv2YHl3M3UHA+
         fqOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=5upTGPFsqkaNgj1lgYq0xrYnDw/z1eQKH2p21LD4RJw=;
        b=qDFsggLslqjGnvPrFwni0yymGra/7Z8lGI0JqXfCfPSz52ZSutwiNii1BOaOl2lRwz
         j7iC4HsPlVU2xbwvPdN9kpJr2VQfuikO7MTHVtrjC48+ekIVGtWecdM4YwewmGFaAU6U
         59JwRIeSUG26mr424o7jdA7lqegLEfZe9qxld1TU4oMevA8NUZ4zbg7PkqNF6LPlPl4E
         MdDrWEmh7YbMC1jXX5dBHtFXnc1/8Fv33P5XToa5UBmB6wDZdGGM6u9m2DJ3fL0ilTLO
         U68xLpfGLBGZKnY78YTHzY9FbhXtfvf2QgK/AO+/5T81kKAZ9LYKoon5FAEIjEBd8SgR
         orKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AwqPgJ4i;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ZNz2GTn4;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 134si111044ywr.91.2019.06.13.08.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 08:24:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AwqPgJ4i;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ZNz2GTn4;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5DFGUqo030339;
	Thu, 13 Jun 2019 08:24:07 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=5upTGPFsqkaNgj1lgYq0xrYnDw/z1eQKH2p21LD4RJw=;
 b=AwqPgJ4ittIgsIWi/jCa/WQ6GEnwl0Y6g95/jk5rdPePOTM5EBBdUrPaOFH/toZo4bRr
 gqUGU6T0BuCQd2+DA6Z2wEe4fZJGhfepLcjEgXEVXpomQplmEsUq6Z+JNYuc4tb7I5gS
 sqRPvBrXzEvJ1m32q+RLIfwQzW7DLP1mrG8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2t3qmj0bex-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 13 Jun 2019 08:24:07 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 13 Jun 2019 08:24:05 -0700
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 13 Jun 2019 08:24:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=5upTGPFsqkaNgj1lgYq0xrYnDw/z1eQKH2p21LD4RJw=;
 b=ZNz2GTn4OWPcEoVSxI95MdoYpFe7F1h3iDHQsMXVGL+aeVtinsJg6Xa0UxDsK1yaSHfCY6wO9PES+QaC4ctni7WoXg/7TUVEJ1QQFN/+OFOlOtnNcU/TzOimTITl5wC/jDky4mQK8Bec05OaY+nwFXu78Bii7B93Gen1hnfDhGY=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1437.namprd15.prod.outlook.com (10.173.234.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Thu, 13 Jun 2019 15:24:04 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 15:24:04 +0000
From: Song Liu <songliubraving@fb.com>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
CC: "Kirill A. Shutemov" <kirill@shutemov.name>,
        LKML
	<linux-kernel@vger.kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "namit@vmware.com" <namit@vmware.com>,
        "peterz@infradead.org"
	<peterz@infradead.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "mhiramat@kernel.org"
	<mhiramat@kernel.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH v3 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Topic: [PATCH v3 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Thread-Index: AQHVIWtWTe7ps5z8rEO6sAR2s+F9WKaZjDkAgAAQ0ICAAAU/gIAADRAAgAADJ4CAAAK6gA==
Date: Thu, 13 Jun 2019 15:24:04 +0000
Message-ID: <F711F5A6-8822-4EE5-B7F8-0A9D5007CAB9@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
 <20190612220320.2223898-4-songliubraving@fb.com>
 <20190613125718.tgplv5iqkbfhn6vh@box>
 <5A80A2B9-51C3-49C4-97B6-33889CC47F08@fb.com>
 <20190613141615.yvmckzi3fac4qjag@box>
 <32E15B93-24B9-4DBB-BDD4-DDD8537C7CE0@fb.com>
 <20190613151417.7cjxwudjssl5h2pf@black.fi.intel.com>
In-Reply-To: <20190613151417.7cjxwudjssl5h2pf@black.fi.intel.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:7078]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 20555ca9-9841-49a8-4261-08d6f0132bbf
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1437;
x-ms-traffictypediagnostic: MWHPR15MB1437:
x-microsoft-antispam-prvs: <MWHPR15MB14371465193428533D2231FCB3EF0@MWHPR15MB1437.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39860400002)(346002)(376002)(366004)(396003)(189003)(199004)(7416002)(5660300002)(6506007)(53546011)(102836004)(46003)(6512007)(476003)(11346002)(446003)(2616005)(53936002)(68736007)(2906002)(99286004)(186003)(6436002)(6916009)(76176011)(229853002)(6116002)(33656002)(57306001)(486006)(54906003)(14454004)(86362001)(25786009)(36756003)(71190400001)(71200400001)(4326008)(305945005)(7736002)(76116006)(478600001)(8676002)(6246003)(6486002)(316002)(8936002)(81166006)(81156014)(50226002)(66446008)(64756008)(66556008)(14444005)(66946007)(66476007)(256004)(73956011);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1437;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: cVUdMAju7C9HoBdVDE96XRFUhLjLOi/CYsB5I9Jp2s9PviHT+OYET71zA6Il/qKewnZeUsXHkaGQXF4U4nMebQWanRYAwuTPPzFg0FjeQeRaChFBBPAlJ8iY23kLuELglK5Y44gEsNICydcAAlBlJE9dExDqE4fvelL/6qN6dj8PjgsG8qwPf4tDeR72ouQZNRaHya0hB030khe8r7407tq8VoRT1N6f+AyUclmyY+GCTyr4tGXAKQUSw4cWISPgyF8MxAxxgQx75fxqxh5zE+Vz/rtblzEa8vw/WT3IsEvQyKiLi2qdbwl4BKJ07/7N3IZllsoJQFkQNeXrrwhjZWyZAY6YuX5YGwWv0uvwzHXflmDjANxMfUy6rHIAwRPN3jdMHdvR2z4l+DgmcBhNY9wbsIbso9N7Nho68QGYlUE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <0D44160B39BFE9428279B658D1C56286@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 20555ca9-9841-49a8-4261-08d6f0132bbf
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 15:24:04.7122
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1437
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130114
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 13, 2019, at 8:14 AM, Kirill A. Shutemov <kirill.shutemov@linux.in=
tel.com> wrote:
>=20
> On Thu, Jun 13, 2019 at 03:03:01PM +0000, Song Liu wrote:
>>=20
>>=20
>>> On Jun 13, 2019, at 7:16 AM, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>>>=20
>>> On Thu, Jun 13, 2019 at 01:57:30PM +0000, Song Liu wrote:
>>>>> And I'm not convinced that it belongs here at all. User requested PMD
>>>>> split and it is done after split_huge_pmd(). The rest can be handled =
by
>>>>> the caller as needed.
>>>>=20
>>>> I put this part here because split_huge_pmd() for file-backed THP is
>>>> not really done after split_huge_pmd(). And I would like it done befor=
e
>>>> calling follow_page_pte() below. Maybe we can still do them here, just=
=20
>>>> for file-backed THPs?
>>>>=20
>>>> If we would move it, shall we move to callers of follow_page_mask()?=20
>>>> In that case, we will probably end up with similar code in two places:
>>>> __get_user_pages() and follow_page().=20
>>>>=20
>>>> Did I get this right?
>>>=20
>>> Would it be enough to replace pte_offset_map_lock() in follow_page_pte(=
)
>>> with pte_alloc_map_lock()?
>>=20
>> This is similar to my previous version:
>>=20
>> +		} else {  /* flags & FOLL_SPLIT_PMD */
>> +			pte_t *pte;
>> +			spin_unlock(ptl);
>> +			split_huge_pmd(vma, pmd, address);
>> +			pte =3D get_locked_pte(mm, address, &ptl);
>> +			if (!pte)
>> +				return no_page_table(vma, flags);
>> +			spin_unlock(ptl);
>> +			ret =3D 0;
>> +		}
>>=20
>> I think this is cleaner than use pte_alloc_map_lock() in follow_page_pte=
().=20
>> What's your thought on these two versions (^^^ vs. pte_alloc_map_lock)?
>=20
> It's additional lock-unlock cycle and few more lines of code...
>=20
>>> This will leave bunch not populated PTE entries, but it is fine: they w=
ill
>>> be populated on the next access to them.
>>=20
>> We need to handle page fault during next access, right? Since we already
>> allocated everything, we can just populate the PTE entries and saves a
>> lot of page faults (assuming we will access them later).=20
>=20
> Not a lot due to faultaround and they may never happen, but you need to
> tear down the mapping any way.

I see. Let me try this way.=20

Thanks,
Song

>=20
> --=20
> Kirill A. Shutemov

