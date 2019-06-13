Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B82E2C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:48:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60737215EA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:48:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="kfU++h+W";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="NOAI+P8y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60737215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEC888E0002; Thu, 13 Jun 2019 12:48:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9CAE8E0001; Thu, 13 Jun 2019 12:48:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3F4C8E0002; Thu, 13 Jun 2019 12:48:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id B30BB8E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:48:10 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id z124so19233068ybz.15
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:48:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Yog5lUhwzhrj3l87JI4a0vFJVeE21mtAfI2CL3gCx10=;
        b=KYrpWHQImpnarFZWbEYzNMG+x7O7mPuCF+YmXXWYl3TR7sl8jzd8CZRb3Nk/A04Nvg
         uXhSH81AMcr6uaqbqM2unZiFRzaiAnqLAea3RzkP/iyqXeNoNKxEfv767Ejj7ceS3Ruk
         0MBOV79SkDVA6VeYCUfE1WWn7Cf0IC0Q8+ErzpFEX9T04F/5NsA6pXKaiJBMWfi4IjLg
         zaZOCoGM5bGTxmPOQIJLew7ylkYA3OZ3i1/m4d+ATzFjO5CQ5BBo5CZ68RXMhSWfiLeT
         pIyB8oqoLKagZojiB4c0mgnGeWD726G4YS6Xf7upJPYKtmkCwQqfSuk442ok0uweycVv
         7zsA==
X-Gm-Message-State: APjAAAVRh3xJJbK+Ek4gcYvPMq7dtfubfiPl7Eoy76Z+I0tsCJ3u5BBW
	Gli7HWgs0/+zQSkJgn1U/FPtgdDO2NcstqDUgF7D6iduAyDBBEpBhwVhCqDpsp0sf4fwm17A4qd
	ursNCK/Mt6Ce9MsKge8OwUHWFoyKsjsG/HGlO1CGwtkoCYHoaix2GAauoHkzC5+ctIw==
X-Received: by 2002:a81:67c2:: with SMTP id b185mr36429351ywc.504.1560444490470;
        Thu, 13 Jun 2019 09:48:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9o5BNF65j8KJtShvJLJQeDaHu15GnzGNn08RH/owSPqUnPtZ0eWA7DouY/Pj0x0Wd+6c3
X-Received: by 2002:a81:67c2:: with SMTP id b185mr36429320ywc.504.1560444489786;
        Thu, 13 Jun 2019 09:48:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560444489; cv=none;
        d=google.com; s=arc-20160816;
        b=Ze6y5SJwwdDNSAIJi/yW49+KqlMjh9IBkZs6nBEHsTtAkgL1W0UxBFYr4onTqVb95b
         ZVK6umxVCHWxkjBFgj727lVKHYnZhVvEJVluwlZLyknudZD6ZeLQbqiIWQs6GKPR2+t5
         Hjmm5eoO+trz5upxcCe/wIM9QUnCNT4YBdY51/2qlZmZWw/2vPU9mdowiejVkqQvH7TP
         zd42rVzBIAUy8XrHlALgFGrjSLaPVo1aI523lYBcLgGNXiIc6MBKLjImP2g/jZ6WUkgk
         5122bncL0yK2ZGuAfM7IdocqgdkTaWTVFmKcQlwXSGG8UoRnrDwUrFRVeiszMQnY96o6
         0qTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Yog5lUhwzhrj3l87JI4a0vFJVeE21mtAfI2CL3gCx10=;
        b=QbTevItg2AR8tyt3DZOoD1izTHoUshrJ2zsBX0DvdNLmYUX4rXWfum5UOKYmmbMaRk
         s8qEuzLcxmQrzSAeXBFj6oXSABUdmpRx0ua/HmkgU4SJD9FUkYYDAyWnrTVVdssn7UQc
         T1lzoheINKNLriPSVapOyGxcloRge9VZ5ATVQG9Ho/U/Q00mtaxqMP112VnGrEfRTJht
         khj07A+b/t12GoyeKxys7H7rxdG2NhDZqouKqmQHN70bi0tb4TaJBL6ywtuvl2tKj9Ml
         96i6opn+khSwXxnkNQQqyo2DfyohSzDlmnSWX9fAWztCPT0/vLHNoWQ1cvEAIWDxjQlg
         ZzpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kfU++h+W;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=NOAI+P8y;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g186si181620ywa.172.2019.06.13.09.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 09:48:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=kfU++h+W;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=NOAI+P8y;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5DGlGsD028140;
	Thu, 13 Jun 2019 09:47:36 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Yog5lUhwzhrj3l87JI4a0vFJVeE21mtAfI2CL3gCx10=;
 b=kfU++h+W9TEIlf46Q6hjkfXxacDlM+NgTOsQs/q3KpbXTaq7M8gqw3TPKGe9jLEMGcd6
 uxMbh+Q0rLP5Zpr32EUaJt9aQcCKR09zuhimXeIjQUcbNGsqjiJO89pYT2pUmr7WLVm7
 /RO7FPi14Qz84TM6IYmRKxsRVjKrMgZzVBA= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2t356240vp-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Thu, 13 Jun 2019 09:47:35 -0700
Received: from prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) by
 prn-hub02.TheFacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 13 Jun 2019 09:47:27 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-mbx02.TheFacebook.com (2620:10d:c081:6::16) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Thu, 13 Jun 2019 09:47:27 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Thu, 13 Jun 2019 09:47:27 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Yog5lUhwzhrj3l87JI4a0vFJVeE21mtAfI2CL3gCx10=;
 b=NOAI+P8yCvYIh1xwLO82nGNn+gj6M59Yx9qezJNrhOfuIzjOkeDN6SYsmdbq818gfdEJYe1MUSzALKA/Eo7IqtMXbHk273nrQooRXb43pHGqxKcAiem0Fy4PBnBvV4YmYZOENRpyVYUHTFUwke+UwI+ZQfwgiqw9MO/a9Fh4oGg=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1181.namprd15.prod.outlook.com (10.175.9.8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1987.11; Thu, 13 Jun 2019 16:47:25 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.1987.012; Thu, 13 Jun 2019
 16:47:25 +0000
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
Thread-Index: AQHVIWtWTe7ps5z8rEO6sAR2s+F9WKaZjDkAgAAQ0ICAAAU/gIAADRAAgAADJ4CAAAK6gIAAF0oA
Date: Thu, 13 Jun 2019 16:47:25 +0000
Message-ID: <97DE480E-A8D5-46AC-BA7F-110A4071250B@fb.com>
References: <20190612220320.2223898-1-songliubraving@fb.com>
 <20190612220320.2223898-4-songliubraving@fb.com>
 <20190613125718.tgplv5iqkbfhn6vh@box>
 <5A80A2B9-51C3-49C4-97B6-33889CC47F08@fb.com>
 <20190613141615.yvmckzi3fac4qjag@box>
 <32E15B93-24B9-4DBB-BDD4-DDD8537C7CE0@fb.com>
 <20190613151417.7cjxwudjssl5h2pf@black.fi.intel.com>
 <F711F5A6-8822-4EE5-B7F8-0A9D5007CAB9@fb.com>
In-Reply-To: <F711F5A6-8822-4EE5-B7F8-0A9D5007CAB9@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::706c]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 027e62a0-5ffe-411d-9b76-08d6f01ed073
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1181;
x-ms-traffictypediagnostic: MWHPR15MB1181:
x-microsoft-antispam-prvs: <MWHPR15MB118100889EDDA38FFFE3A155B3EF0@MWHPR15MB1181.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6430;
x-forefront-prvs: 0067A8BA2A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39860400002)(346002)(136003)(366004)(376002)(199004)(189003)(4326008)(99286004)(6116002)(229853002)(6486002)(71190400001)(6246003)(33656002)(54906003)(478600001)(7416002)(486006)(14454004)(36756003)(6512007)(5660300002)(68736007)(71200400001)(25786009)(2616005)(476003)(86362001)(446003)(11346002)(81166006)(8676002)(7736002)(186003)(102836004)(305945005)(46003)(2906002)(76176011)(6436002)(316002)(6916009)(53546011)(73956011)(6506007)(50226002)(8936002)(81156014)(57306001)(64756008)(66556008)(66476007)(76116006)(66446008)(53936002)(14444005)(256004)(66946007);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1181;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: r+RFogk3KmYQ0OHDWKllViNjF/E+iNuncJXknSyDRSCEIy4jF1yyTsX3gquQFip5S4OLdSmoXi8exi3u8s6H8Ayp7BCgFOQ0zJZHIun7o3gSIpyi+lL1pbvOv5eWp3VJ1buOMEUGTHvxcQBKzFnPCCLMykouMptpEqiTIiVj1iFnM8lVelNfQC1/f4c/T/YJ46NG+34LSFO3GB3DUHK6O8LwqVEPt4cY22hPzY83b3zWf9q7X54UHlZIkBkEASJjPI6w8BAlhkgWAhlfoUKMYKsAff5omBooMDBkFg3+I4K69tdHOC0lOVfJQ9R7ccmGo6wK2jtmk0a1gUpXytWZTSb5+yaSJTbp9NyMocgG9te1pVMOcs4Jw06aafiq7y+ozXgCw7HpWB6X6kMcM0AyFM3OlYK4QhJ7ybu6U5Gf33Q=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6450BBCF402CC54CAEC5E3F375A91DA6@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 027e62a0-5ffe-411d-9b76-08d6f01ed073
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Jun 2019 16:47:25.4064
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1181
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130122
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kirill,

> On Jun 13, 2019, at 8:24 AM, Song Liu <songliubraving@fb.com> wrote:
>=20
>=20
>=20
>> On Jun 13, 2019, at 8:14 AM, Kirill A. Shutemov <kirill.shutemov@linux.i=
ntel.com> wrote:
>>=20
>> On Thu, Jun 13, 2019 at 03:03:01PM +0000, Song Liu wrote:
>>>=20
>>>=20
>>>> On Jun 13, 2019, at 7:16 AM, Kirill A. Shutemov <kirill@shutemov.name>=
 wrote:
>>>>=20
>>>> On Thu, Jun 13, 2019 at 01:57:30PM +0000, Song Liu wrote:
>>>>>> And I'm not convinced that it belongs here at all. User requested PM=
D
>>>>>> split and it is done after split_huge_pmd(). The rest can be handled=
 by
>>>>>> the caller as needed.
>>>>>=20
>>>>> I put this part here because split_huge_pmd() for file-backed THP is
>>>>> not really done after split_huge_pmd(). And I would like it done befo=
re
>>>>> calling follow_page_pte() below. Maybe we can still do them here, jus=
t=20
>>>>> for file-backed THPs?
>>>>>=20
>>>>> If we would move it, shall we move to callers of follow_page_mask()?=
=20
>>>>> In that case, we will probably end up with similar code in two places=
:
>>>>> __get_user_pages() and follow_page().=20
>>>>>=20
>>>>> Did I get this right?
>>>>=20
>>>> Would it be enough to replace pte_offset_map_lock() in follow_page_pte=
()
>>>> with pte_alloc_map_lock()?
>>>=20
>>> This is similar to my previous version:
>>>=20
>>> +		} else {  /* flags & FOLL_SPLIT_PMD */
>>> +			pte_t *pte;
>>> +			spin_unlock(ptl);
>>> +			split_huge_pmd(vma, pmd, address);
>>> +			pte =3D get_locked_pte(mm, address, &ptl);
>>> +			if (!pte)
>>> +				return no_page_table(vma, flags);
>>> +			spin_unlock(ptl);
>>> +			ret =3D 0;
>>> +		}
>>>=20
>>> I think this is cleaner than use pte_alloc_map_lock() in follow_page_pt=
e().=20
>>> What's your thought on these two versions (^^^ vs. pte_alloc_map_lock)?
>>=20
>> It's additional lock-unlock cycle and few more lines of code...
>>=20
>>>> This will leave bunch not populated PTE entries, but it is fine: they =
will
>>>> be populated on the next access to them.
>>>=20
>>> We need to handle page fault during next access, right? Since we alread=
y
>>> allocated everything, we can just populate the PTE entries and saves a
>>> lot of page faults (assuming we will access them later).=20
>>=20
>> Not a lot due to faultaround and they may never happen, but you need to
>> tear down the mapping any way.
>=20
> I see. Let me try this way.=20
>=20
> Thanks,
> Song

To make sure I understand your suggestions. Here is what I got:

diff --git c/mm/gup.c w/mm/gup.c
index ddde097cf9e4..85e6f46fd925 100644
--- c/mm/gup.c
+++ w/mm/gup.c
@@ -197,7 +197,10 @@ static struct page *follow_page_pte(struct vm_area_str=
uct *vma,
        if (unlikely(pmd_bad(*pmd)))
                return no_page_table(vma, flags);

-       ptep =3D pte_offset_map_lock(mm, pmd, address, &ptl);
+       ptep =3D pte_alloc_map_lock(mm, pmd, address, &ptl);
+       if (!ptep)
+               return ERR_PTR(-ENOMEM);
+
        pte =3D *ptep;
        if (!pte_present(pte)) {
                swp_entry_t entry;
@@ -398,7 +401,7 @@ static struct page *follow_pmd_mask(struct vm_area_stru=
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
@@ -407,7 +410,7 @@ static struct page *follow_pmd_mask(struct vm_area_stru=
ct *vma,
                        split_huge_pmd(vma, pmd, address);
                        if (pmd_trans_unstable(pmd))
                                ret =3D -EBUSY;
-               } else {
+               } else if (flags & FOLL_SPLIT) {
                        if (unlikely(!try_get_page(page))) {
                                spin_unlock(ptl);
                                return ERR_PTR(-ENOMEM);
@@ -419,6 +422,10 @@ static struct page *follow_pmd_mask(struct vm_area_str=
uct *vma,
                        put_page(page);
                        if (pmd_none(*pmd))
                                return no_page_table(vma, flags);
+               } else {  /* flags & FOLL_SPLIT_PMD */
+                       spin_unlock(ptl);
+                       split_huge_pmd(vma, pmd, address);
+                       ret =3D 0;
                }

                return ret ? ERR_PTR(ret) :
                        follow_page_pte(vma, address, pmd, flags, &ctx->pgm=
ap);


This version doesn't work as-is, because it returns at the first check:

        if (unlikely(pmd_bad(*pmd)))
                return no_page_table(vma, flags);

Did I misunderstand anything here?

Thanks,
Song


>=20
>>=20
>> --=20
>> Kirill A. Shutemov

