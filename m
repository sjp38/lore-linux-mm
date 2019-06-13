Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EEF2C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:43:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E91D2175B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:43:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="NPw0cgwb";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ElSpu1Vi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E91D2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D14C78E0003; Thu, 13 Jun 2019 13:43:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC4908E0002; Thu, 13 Jun 2019 13:43:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B67448E0003; Thu, 13 Jun 2019 13:43:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF878E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:43:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id s195so14333761pgs.13
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=M/xOAe1GDREebD3CF7w4WTuM36ah5JazCKWQug6eu+0=;
        b=UzQ/5d1AfDWZs63aMZDTWsM6J2Dri49y/jQ9L1dW9pnc6c3h5OwbxGQqb+wzrJVyu7
         XxtaTMxTkiZeRrpr5xBvQWUIiJyNCuD9mhNdYqHJX6Xq5DPdnbwm4QXatqGv9H/8VyB4
         ifn3+0/a7UPjXwGl9O8NC2SzTMNjCez8QdA1lW0yMDBBQVFaEuvGDOJMKaeYjWbL8gEd
         X94ZBBw7dAmI0eKvHuEklnbHyOcW/XZN5BgVQ0zYz+ngERlXmXzxQBZRFirs4MYuKWU3
         54JWT0pxGC1dOSs36aOgA5diVVcx9Eiye4h/csHDrBcDLSYMoq5HTg8rTrIuxnlgsErU
         GQPw==
X-Gm-Message-State: APjAAAVM0wG3mqqYhhBcjBTREWcVCAmjIFG7dXkcmQT/X7SDgxCoZWuN
	vW3E1g2zwgaudQPUB0vT/jEupxzXehi4xx+N97c835NZjjuwVd+J5Zwuh8iFXlMAz4HaWqcBJAP
	6qSP0Ys9Jd3JsaHpvvbd5RYxH3IBrrgfKusjj5qEIGNtJyyjaxS6qcFvgWPUnMCmAKA==
X-Received: by 2002:a63:8841:: with SMTP id l62mr30120803pgd.246.1560447800897;
        Thu, 13 Jun 2019 10:43:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwcHPj3140f0KWxc+HGrBWEWzaW/Dotw29THhah8T8Nyna776XAf76O/ymfBY1dbk7ayy1N
X-Received: by 2002:a63:8841:: with SMTP id l62mr30120744pgd.246.1560447800014;
        Thu, 13 Jun 2019 10:43:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560447800; cv=none;
        d=google.com; s=arc-20160816;
        b=g8n+j7sNQgom4oLihZzv4TGUypjRW+AyBl2zP4+7ryYNlB3Jvv4kvZRis5LGQGB8Wr
         5BKzWciSMNce9KlmHBhjkvA0+h9aoe0foeZdh+MMe+ZiywtiZOcaNcETHtILl+66WK7C
         aasHzM5qrF95fs8qD+BDW4jO05e6IoLQ/WjEpi3dsOMm7Z4ktMwbsP8h7gpBTEW2C9d1
         a0YWzYAdnLZ5omxaJz1zBa2NZG9W++KGGYNoCuZ6R0dBob3VGSrAWx8bmKl+tF1QPE67
         mIjY0jYfn7JoelObLeF3DAX1fX8AbmGsAwQ+m6YO0M2uXa1SeHVOPNMCNU6O2P+WOrK8
         RS8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=M/xOAe1GDREebD3CF7w4WTuM36ah5JazCKWQug6eu+0=;
        b=c/JJ7WG43A56dHnVnnJLNVS4RAjMIk/biNCgHY9Agq1Ko8G7apDjR+rOA/DE0vu50L
         Zc+eno/YSYMe/rlgq0+RMLMk/AtHzOORQ2TzAHKBT6cZuO7CLMd2jHwT5qEFMSy62DHg
         j4XA1fA7sPk2EupJXmNViV6vwArENwI7RoldiAL+rcPsVEdYkhf8pWDFqZBtg/wckDVK
         t0IjkwDfBTaZmH4atUI1GRZz2EH+HxfuBfXl8cwPSlk0iTu0sN0hF6j363BQfZRBGxEd
         +g3cGPEKDuxZkNgd6ZjC6B3Q0THbsi+PRH604ofxK5gE4J8R8OdX7B+tt2QE8VguCoJD
         DMaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=NPw0cgwb;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ElSpu1Vi;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v9si187931pfm.50.2019.06.13.10.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=NPw0cgwb;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ElSpu1Vi;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5DHZiNk007396;
	Thu, 13 Jun 2019 10:42:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=M/xOAe1GDREebD3CF7w4WTuM36ah5JazCKWQug6eu+0=;
 b=NPw0cgwb8GS76dnmSJ8pKJH6g4dXuyBp+/WnZ9T14N/r4q2vVbpT4/cWawX287kKMHJW
 NrPXKfMOQMPuMcmnvlg5boxtvdluLZS5Hg9EAjiRzSeISi4VtkQdcruIgmUS0HGXd7iY
 wfNzlDkO4pGlU6yi3Xv36JMKUgESC9ThMlk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3pash559-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Thu, 13 Jun 2019 10:42:44 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 13 Jun 2019 10:42:40 -0700
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.103) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Thu, 13 Jun 2019 10:42:40 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=M/xOAe1GDREebD3CF7w4WTuM36ah5JazCKWQug6eu+0=;
 b=ElSpu1VihQaiTcAjXumNxqGHl/SP1LxmtTU5q4OhI1uxrOgrVgykS7Y9jd0xwE8tRcMmvn89U6MNlse20xqTvbHtmSjaC2QDeKdRhMbBrFgfxICk8GvlkSGGlW37SwSVSoYSIleFuF+JaG2Hc9SHOtIMenFlPnywF+EgHlVCUFg=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1648.namprd15.prod.outlook.com (10.175.141.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.12; Thu, 13 Jun 2019 17:42:39 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 17:42:39 +0000
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
Thread-Index: AQHVIWtWTe7ps5z8rEO6sAR2s+F9WKaZjDkAgAAQ0ICAAAU/gIAADRAAgAADJ4CAAAK6gIAAF0oAgAAPbgA=
Date: Thu, 13 Jun 2019 17:42:39 +0000
Message-ID: <BF2C0154-4DC1-4B29-A7D1-F2192AFA9B4E@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
 <20190612220320.2223898-4-songliubraving@fb.com>
 <20190613125718.tgplv5iqkbfhn6vh@box>
 <5A80A2B9-51C3-49C4-97B6-33889CC47F08@fb.com>
 <20190613141615.yvmckzi3fac4qjag@box>
 <32E15B93-24B9-4DBB-BDD4-DDD8537C7CE0@fb.com>
 <20190613151417.7cjxwudjssl5h2pf@black.fi.intel.com>
 <F711F5A6-8822-4EE5-B7F8-0A9D5007CAB9@fb.com>
 <97DE480E-A8D5-46AC-BA7F-110A4071250B@fb.com>
In-Reply-To: <97DE480E-A8D5-46AC-BA7F-110A4071250B@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::706c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7d0da53c-82a8-4419-caa0-08d6f0268780
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1648;
x-ms-traffictypediagnostic: MWHPR15MB1648:
x-microsoft-antispam-prvs: <MWHPR15MB1648B9A1D2F3DFA697C9B834B3EF0@MWHPR15MB1648.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(366004)(396003)(376002)(136003)(39860400002)(189003)(199004)(316002)(6246003)(5660300002)(57306001)(54906003)(25786009)(186003)(46003)(53546011)(6506007)(4326008)(76176011)(476003)(102836004)(14444005)(446003)(256004)(2616005)(11346002)(6916009)(86362001)(33656002)(7416002)(486006)(6512007)(73956011)(6116002)(305945005)(66946007)(64756008)(66446008)(478600001)(66556008)(76116006)(66476007)(7736002)(229853002)(50226002)(81156014)(81166006)(8676002)(36756003)(2906002)(14454004)(6436002)(99286004)(8936002)(71190400001)(71200400001)(53936002)(6486002)(68736007);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1648;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: oVT6m7wYJJuOQLmAww4OWH4JcoPWpVvn2D2e8jVNdIqwVjP8RjMeMF9ECCm+RxGT0Rw/3d0yEW4J9qtgQtEC+jJKIV9ZUvp+UqGRua6unybTVjeaHW7PVxeDMjcyKO78zlAVLmcsi6wP9ImBciTsDsvpuFinypob45neepaClTva4pY25NOOUC5jucrtM/pAqBVnuwwUhNIgGVCeuLc/V4MXLOY+6qG1oTwCZMiv8YZSHlfK82dYZWMqsri0uUbXq1QKdtQNDS8YkTiF0G1AjoBJDyyS4URuJIxgMJvUrgwmgu+wpAMpDHPf0Q2fNsSYWklVftclsFhD2ppvY19UM0Kh/NfTi/mkwL9kgE+6ZRXvU1FDfdGj4aw26HP1dvG6Ubk/1qNKjDqQeZTfAYoiIkmcamxbt+Ci1vKqErXUog0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <179F1261998433469BA9F1676B96CEF4@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 7d0da53c-82a8-4419-caa0-08d6f0268780
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 17:42:39.0990
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1648
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130129
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 13, 2019, at 9:47 AM, Song Liu <songliubraving@fb.com> wrote:
>=20
> Hi Kirill,
>=20
>> On Jun 13, 2019, at 8:24 AM, Song Liu <songliubraving@fb.com> wrote:
>>=20
>>=20
>>=20
>>> On Jun 13, 2019, at 8:14 AM, Kirill A. Shutemov <kirill.shutemov@linux.=
intel.com> wrote:
>>>=20
>>> On Thu, Jun 13, 2019 at 03:03:01PM +0000, Song Liu wrote:
>>>>=20
>>>>=20
>>>>> On Jun 13, 2019, at 7:16 AM, Kirill A. Shutemov <kirill@shutemov.name=
> wrote:
>>>>>=20
>>>>> On Thu, Jun 13, 2019 at 01:57:30PM +0000, Song Liu wrote:
>>>>>>> And I'm not convinced that it belongs here at all. User requested P=
MD
>>>>>>> split and it is done after split_huge_pmd(). The rest can be handle=
d by
>>>>>>> the caller as needed.
>>>>>>=20
>>>>>> I put this part here because split_huge_pmd() for file-backed THP is
>>>>>> not really done after split_huge_pmd(). And I would like it done bef=
ore
>>>>>> calling follow_page_pte() below. Maybe we can still do them here, ju=
st=20
>>>>>> for file-backed THPs?
>>>>>>=20
>>>>>> If we would move it, shall we move to callers of follow_page_mask()?=
=20
>>>>>> In that case, we will probably end up with similar code in two place=
s:
>>>>>> __get_user_pages() and follow_page().=20
>>>>>>=20
>>>>>> Did I get this right?
>>>>>=20
>>>>> Would it be enough to replace pte_offset_map_lock() in follow_page_pt=
e()
>>>>> with pte_alloc_map_lock()?
>>>>=20
>>>> This is similar to my previous version:
>>>>=20
>>>> +		} else {  /* flags & FOLL_SPLIT_PMD */
>>>> +			pte_t *pte;
>>>> +			spin_unlock(ptl);
>>>> +			split_huge_pmd(vma, pmd, address);
>>>> +			pte =3D get_locked_pte(mm, address, &ptl);
>>>> +			if (!pte)
>>>> +				return no_page_table(vma, flags);
>>>> +			spin_unlock(ptl);
>>>> +			ret =3D 0;
>>>> +		}
>>>>=20
>>>> I think this is cleaner than use pte_alloc_map_lock() in follow_page_p=
te().=20
>>>> What's your thought on these two versions (^^^ vs. pte_alloc_map_lock)=
?
>>>=20
>>> It's additional lock-unlock cycle and few more lines of code...
>>>=20
>>>>> This will leave bunch not populated PTE entries, but it is fine: they=
 will
>>>>> be populated on the next access to them.
>>>>=20
>>>> We need to handle page fault during next access, right? Since we alrea=
dy
>>>> allocated everything, we can just populate the PTE entries and saves a
>>>> lot of page faults (assuming we will access them later).=20
>>>=20
>>> Not a lot due to faultaround and they may never happen, but you need to
>>> tear down the mapping any way.
>>=20
>> I see. Let me try this way.=20
>>=20
>> Thanks,
>> Song
>=20
> To make sure I understand your suggestions. Here is what I got:
>=20
> diff --git c/mm/gup.c w/mm/gup.c
> index ddde097cf9e4..85e6f46fd925 100644
> --- c/mm/gup.c
> +++ w/mm/gup.c
> @@ -197,7 +197,10 @@ static struct page *follow_page_pte(struct vm_area_s=
truct *vma,
>        if (unlikely(pmd_bad(*pmd)))
>                return no_page_table(vma, flags);
>=20
> -       ptep =3D pte_offset_map_lock(mm, pmd, address, &ptl);
> +       ptep =3D pte_alloc_map_lock(mm, pmd, address, &ptl);
> +       if (!ptep)
> +               return ERR_PTR(-ENOMEM);
> +
>        pte =3D *ptep;
>        if (!pte_present(pte)) {
>                swp_entry_t entry;
> @@ -398,7 +401,7 @@ static struct page *follow_pmd_mask(struct vm_area_st=
ruct *vma,
>                spin_unlock(ptl);
>                return follow_page_pte(vma, address, pmd, flags, &ctx->pgm=
ap);
>        }
> -       if (flags & FOLL_SPLIT) {
> +       if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
>                int ret;
>                page =3D pmd_page(*pmd);
>                if (is_huge_zero_page(page)) {
> @@ -407,7 +410,7 @@ static struct page *follow_pmd_mask(struct vm_area_st=
ruct *vma,
>                        split_huge_pmd(vma, pmd, address);
>                        if (pmd_trans_unstable(pmd))
>                                ret =3D -EBUSY;
> -               } else {
> +               } else if (flags & FOLL_SPLIT) {
>                        if (unlikely(!try_get_page(page))) {
>                                spin_unlock(ptl);
>                                return ERR_PTR(-ENOMEM);
> @@ -419,6 +422,10 @@ static struct page *follow_pmd_mask(struct vm_area_s=
truct *vma,
>                        put_page(page);
>                        if (pmd_none(*pmd))
>                                return no_page_table(vma, flags);
> +               } else {  /* flags & FOLL_SPLIT_PMD */
> +                       spin_unlock(ptl);
> +                       split_huge_pmd(vma, pmd, address);
> +                       ret =3D 0;
>                }
>=20
>                return ret ? ERR_PTR(ret) :
>                        follow_page_pte(vma, address, pmd, flags, &ctx->pg=
map);
>=20
>=20
> This version doesn't work as-is, because it returns at the first check:
>=20
>        if (unlikely(pmd_bad(*pmd)))
>                return no_page_table(vma, flags);
>=20
> Did I misunderstand anything here?
>=20
> Thanks,
> Song

I guess this would be the best. It _is_ a lot simpler.=20

diff --git c/mm/gup.c w/mm/gup.c
index ddde097cf9e4..0cd3ce599f41 100644
--- c/mm/gup.c
+++ w/mm/gup.c
@@ -398,7 +398,7 @@ static struct page *follow_pmd_mask(struct vm_area_stru=
ct *vma,
                spin_unlock(ptl);
                return follow_page_pte(vma, address, pmd, flags, &ctx->pgma=
p);
        }
-       if (flags & FOLL_SPLIT) {
+       if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
                int ret;
                page =3D pmd_page(*pmd);
                if (is_huge_zero_page(page)) {
@@ -407,7 +407,7 @@ static struct page *follow_pmd_mask(struct vm_area_stru=
ct *vma,
                        split_huge_pmd(vma, pmd, address);
                        if (pmd_trans_unstable(pmd))
                                ret =3D -EBUSY;
-               } else {
+               } else if (flags & FOLL_SPLIT) {
                        if (unlikely(!try_get_page(page))) {
                                spin_unlock(ptl);
                                return ERR_PTR(-ENOMEM);
@@ -419,6 +419,11 @@ static struct page *follow_pmd_mask(struct vm_area_str=
uct *vma,
                        put_page(page);
                        if (pmd_none(*pmd))
                                return no_page_table(vma, flags);
+               } else {  /* flags & FOLL_SPLIT_PMD */
+                       spin_unlock(ptl);
+                       ret =3D 0;
+                       split_huge_pmd(vma, pmd, address);
+                       pte_alloc(mm, pmd);
                }

Thanks again for the suggestions. I will send v4 soon.=20

Song


>=20
>=20
>>=20
>>>=20
>>> --=20
>>> Kirill A. Shutemov

