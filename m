Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 885AAC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 15:11:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD3E52133F
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 15:11:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="SFXde12Y";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="tJgSmMbC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD3E52133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74CB58E0005; Tue, 25 Jun 2019 11:11:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FDB58E0003; Tue, 25 Jun 2019 11:11:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 576A58E0005; Tue, 25 Jun 2019 11:11:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36A518E0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:11:22 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id q15so22314551ybq.3
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 08:11:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=Kvwq5HNUCNvByDWcUKNITjhLkvzGi+BuGWdxbaQd0cI=;
        b=k8y/FIaPgrQHJE+jlfuUnhfhGYwpSnQXxItjNgowtoKErB8rUntntbcXLV8DJjpMjA
         /FT0oBMAgb650A8qaGHTvrgN9KphU7K5efdvBKQqhEzSxyl4JIxYXGzb9w0SAG/vRyX4
         xvnEX8l+Kj5BAZ0RpLV/+I/sOjcwHQU+k8aR3ZvGMzHN59RzyT58obYBW9AWXYydzIV5
         3dwmdLf2WbxA2C4GZGS/SgtyHcVHn3Igg8xGx451KHU3SY8djPLj07lUHE1XR7SbOnbA
         lRlGJsQe7YZz+LQZYIbZREdoGs7yS/rUysOUOlNS2fvgTQifXtld0d9vstpXa1FnQ0pW
         NMpQ==
X-Gm-Message-State: APjAAAUbTW28iBCRA0QtOEGR7K533xA1f/ePdWEIpLTVZCCcOT7o0SqS
	zKTr+w2ZanW8FnNT+1n6+tpsmMzzxPHFaNUfDYWuC5mRNKkT29JVW5ddnJxt1d2CtKwqKWZL+z5
	6QEVLdyO+X42gPopU/RhaLNGvUCKdh8pShc+nF1wY5GRYW4jenWPRuMTpGoq3YdMGrg==
X-Received: by 2002:a81:338f:: with SMTP id z137mr20553979ywz.169.1561475481919;
        Tue, 25 Jun 2019 08:11:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4WWaR6Xhrx9W2tbY3HBbARN8RxDeErxC4n7htJB8BtUdCFnnMIuN0WibgUzxV90Jg/HzB
X-Received: by 2002:a81:338f:: with SMTP id z137mr20553915ywz.169.1561475480966;
        Tue, 25 Jun 2019 08:11:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561475480; cv=none;
        d=google.com; s=arc-20160816;
        b=Fd9C9PsHTb1X3ASt77/AI0j8folRmnnZ8wxq3OHwVP0NaHR7TdmPAzuhEnSU3jFaS4
         LrcyR392GZ0fLvccIOqpGXKWoTApnnXwXI4vBw9TxvxWlrQTNYQ/Oa2lmXG7wBCMYiao
         i0XIkblZr/XULKNAPgSA0hk/LKUcY+LzaKWIce/kUQHYppyWzF1uKTAi6z/k3jbxarwP
         ZX3GWczksHv08YjOTGj6nSQh7FhsnGq8soQYQI81NSIYh7PsfoqOmHmu350FN96r6YVr
         0wdPZs5JQj3NvX1Twx8jBJFN2DrMuZ3wlQwcXIjRnjz8fffLmnj9XgPTDy1Nn2IwfuKg
         2fwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=Kvwq5HNUCNvByDWcUKNITjhLkvzGi+BuGWdxbaQd0cI=;
        b=xQe1SZ0lEkui3jjTeFA2VD/lQNx6ESON/LND26EUxDDpNoEPWia34BQsqW+L29BA1i
         WWDJ6ZeYnK6MQXJ6nvKIuR2t0yaYm1zUZ9NhkvVaFeWC82QuRr7k1ifcB4kLynbfSqJB
         N7YMX7AELdvhfAVHRKln5nVsfZ4LhMEe0SrJYXTx5qOGVSXMMOwy009uAuQ/q2i2yT+q
         YMQcKmoXjIG8QQ+zD47oK9PiTxADg/SBleplNmW85g92dEiSxTQnLDTuGWLbT544ctX6
         bIols7jMnZ3Dj2ErUyyoI2fvU/3OIgnM+ePfEbLqIDbCR/ppAjJ51d9T7fR8zWydaypc
         ZTNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SFXde12Y;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=tJgSmMbC;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id j5si5097543ywb.213.2019.06.25.08.11.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 08:11:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=SFXde12Y;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=tJgSmMbC;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5PEwj3h012514;
	Tue, 25 Jun 2019 08:10:49 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=Kvwq5HNUCNvByDWcUKNITjhLkvzGi+BuGWdxbaQd0cI=;
 b=SFXde12YvTVZtIKUsqssvGYRZhfOnnsjN4X23+rgv39+wcHAyUANHAS8/ImIrDT/SOG0
 KVPFSpZb3wsGWFF/i6dh+Aak6F+pvyF7lk4WiNeD4ag3708fRhj3zrP/oar2/Ow8slYF
 hWdPKWtWYefuTgPsg7mhlfVt1WWpgQGQSCg= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2tbkm08jtx-7
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 25 Jun 2019 08:10:49 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-hub03.TheFacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Tue, 25 Jun 2019 08:10:45 -0700
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Tue, 25 Jun 2019 08:10:45 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Kvwq5HNUCNvByDWcUKNITjhLkvzGi+BuGWdxbaQd0cI=;
 b=tJgSmMbCCOZmgsBTpoCDe2SXnDETmQMqW2OejaIzU7pZKa4H6EEDtAqRknCPRUHktzT6h6qL4IKV+u1YLZl/0YP7hFvm9CPylY7vewBzqSbw/2I/81fhlU2JM2n3rqRrA0HGS6vatfjbT2kZ1q9QeEOKuozw0xWRK2w+W9YhvyA=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1485.namprd15.prod.outlook.com (10.173.234.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2008.16; Tue, 25 Jun 2019 15:10:44 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::400e:e329:ea98:aa0d%6]) with mapi id 15.20.2008.017; Tue, 25 Jun 2019
 15:10:43 +0000
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
Thread-Index: AQHVKYdbTu9KGYA+hEyrpX71HNVoZKaqy94AgAASewCAAVGdAIAAIT6AgAAbxwCAABBFAA==
Date: Tue, 25 Jun 2019 15:10:43 +0000
Message-ID: <86488574-4DE6-45BE-B3C7-6C89DA30BED2@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
 <20190623054829.4018117-6-songliubraving@fb.com>
 <20190624131934.m6gbktixyykw65ws@box>
 <24FB1072-E355-4F9D-855F-337C855C9AF9@fb.com>
 <20190625103404.3ypizksnpopcgwdk@box>
 <77DBF8A2-DF3D-4635-A5E6-66D80A8BFA50@fb.com>
 <20190625141228.j7w5j6jubxrd5ivr@box>
In-Reply-To: <20190625141228.j7w5j6jubxrd5ivr@box>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:200::3:8487]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 32912fbd-2239-44c6-1ec3-08d6f97f4b5a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1485;
x-ms-traffictypediagnostic: MWHPR15MB1485:
x-microsoft-antispam-prvs: <MWHPR15MB148595129D89A1EDA1C05598B3E30@MWHPR15MB1485.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0079056367
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(376002)(346002)(396003)(39860400002)(199004)(189003)(81156014)(8676002)(6116002)(8936002)(446003)(71200400001)(71190400001)(6916009)(7736002)(4326008)(2906002)(305945005)(33656002)(81166006)(57306001)(102836004)(53546011)(6246003)(186003)(316002)(25786009)(6512007)(76176011)(53936002)(99286004)(54906003)(36756003)(68736007)(478600001)(14454004)(6506007)(6436002)(6486002)(11346002)(86362001)(2616005)(486006)(50226002)(476003)(256004)(14444005)(5660300002)(229853002)(76116006)(66446008)(64756008)(66556008)(46003)(73956011)(66946007)(66476007);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1485;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: H7XHDt4GmSWuiISpRhF+Lb1WXvXaMiJ2sg5R144/9eGt4HCtvLJHyk8jPCQfBzPUrDXlJUjwst73JIaoPsZmn/hiZmhluvUgBBanCR1b31HInO4U7tvzfsU+I4N93KEugXhmBUtsT8VtAADPQX5XjWcFNqgwy31h/qAX5/V3XXdah3qGHSUz2JVrfme1smIi9so/wJB0ObVIXErg2yNQEbv8Ya29D04ZsJojobxU0F+e2/TcT9XAXyzS3Iot0MTKzapyb/wcogXYAWPvkqaPiCzNgVmeYGdVJc5Xr9ANwYW33kKb/dcHOF65v+H5XZMYp2Aw9GtaydCGvtLi/AlmN6YN1bZCZWZV4mxMsWWGZ4CAWBmKS0nS69sn9/cXtgdwXbNo2BfJ7pqgbJzg7WZIP/LiljTKCzsbpUj5lG0aseM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <B5ED4BB6388DB342A760FDB933B1891E@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 32912fbd-2239-44c6-1ec3-08d6f97f4b5a
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Jun 2019 15:10:43.7642
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1485
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-25_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=896 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250116
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 25, 2019, at 7:12 AM, Kirill A. Shutemov <kirill@shutemov.name> wr=
ote:
>=20
> On Tue, Jun 25, 2019 at 12:33:03PM +0000, Song Liu wrote:
>>=20
>>=20
>>> On Jun 25, 2019, at 3:34 AM, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>>>=20
>>> On Mon, Jun 24, 2019 at 02:25:42PM +0000, Song Liu wrote:
>>>>=20
>>>>=20
>>>>> On Jun 24, 2019, at 6:19 AM, Kirill A. Shutemov <kirill@shutemov.name=
> wrote:
>>>>>=20
>>>>> On Sat, Jun 22, 2019 at 10:48:28PM -0700, Song Liu wrote:
>>>>>> khugepaged needs exclusive mmap_sem to access page table. When it fa=
ils
>>>>>> to lock mmap_sem, the page will fault in as pte-mapped THP. As the p=
age
>>>>>> is already a THP, khugepaged will not handle this pmd again.
>>>>>>=20
>>>>>> This patch enables the khugepaged to retry retract_page_tables().
>>>>>>=20
>>>>>> A new flag AS_COLLAPSE_PMD is introduced to show the address_space m=
ay
>>>>>> contain pte-mapped THPs. When khugepaged fails to trylock the mmap_s=
em,
>>>>>> it sets AS_COLLAPSE_PMD. Then, at a later time, khugepaged will retr=
y
>>>>>> compound pages in this address_space.
>>>>>>=20
>>>>>> Since collapse may happen at an later time, some pages may already f=
ault
>>>>>> in. To handle these pages properly, it is necessary to prepare the p=
md
>>>>>> before collapsing. prepare_pmd_for_collapse() is introduced to prepa=
re
>>>>>> the pmd by removing rmap, adjusting refcount and mm_counter.
>>>>>>=20
>>>>>> prepare_pmd_for_collapse() also double checks whether all ptes in th=
is
>>>>>> pmd are mapping to the same THP. This is necessary because some subp=
age
>>>>>> of the THP may be replaced, for example by uprobe. In such cases, it
>>>>>> is not possible to collapse the pmd, so we fall back.
>>>>>>=20
>>>>>> Signed-off-by: Song Liu <songliubraving@fb.com>
>>>>>> ---
>>>>>> include/linux/pagemap.h |  1 +
>>>>>> mm/khugepaged.c         | 69 +++++++++++++++++++++++++++++++++++----=
--
>>>>>> 2 files changed, 60 insertions(+), 10 deletions(-)
>>>>>>=20
>>>>>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>>>>>> index 9ec3544baee2..eac881de2a46 100644
>>>>>> --- a/include/linux/pagemap.h
>>>>>> +++ b/include/linux/pagemap.h
>>>>>> @@ -29,6 +29,7 @@ enum mapping_flags {
>>>>>> 	AS_EXITING	=3D 4, 	/* final truncate in progress */
>>>>>> 	/* writeback related tags are not used */
>>>>>> 	AS_NO_WRITEBACK_TAGS =3D 5,
>>>>>> +	AS_COLLAPSE_PMD =3D 6,	/* try collapse pmd for THP */
>>>>>> };
>>>>>>=20
>>>>>> /**
>>>>>> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
>>>>>> index a4f90a1b06f5..9b980327fd9b 100644
>>>>>> --- a/mm/khugepaged.c
>>>>>> +++ b/mm/khugepaged.c
>>>>>> @@ -1254,7 +1254,47 @@ static void collect_mm_slot(struct mm_slot *m=
m_slot)
>>>>>> }
>>>>>>=20
>>>>>> #if defined(CONFIG_SHMEM) && defined(CONFIG_TRANSPARENT_HUGE_PAGECAC=
HE)
>>>>>> -static void retract_page_tables(struct address_space *mapping, pgof=
f_t pgoff)
>>>>>> +
>>>>>> +/* return whether the pmd is ready for collapse */
>>>>>> +bool prepare_pmd_for_collapse(struct vm_area_struct *vma, pgoff_t p=
goff,
>>>>>> +			      struct page *hpage, pmd_t *pmd)
>>>>>> +{
>>>>>> +	unsigned long haddr =3D page_address_in_vma(hpage, vma);
>>>>>> +	unsigned long addr;
>>>>>> +	int i, count =3D 0;
>>>>>> +
>>>>>> +	/* step 1: check all mapped PTEs are to this huge page */
>>>>>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAG=
E_SIZE) {
>>>>>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>>>>>> +
>>>>>> +		if (pte_none(*pte))
>>>>>> +			continue;
>>>>>> +
>>>>>> +		if (hpage + i !=3D vm_normal_page(vma, addr, *pte))
>>>>>> +			return false;
>>>>>> +		count++;
>>>>>> +	}
>>>>>> +
>>>>>> +	/* step 2: adjust rmap */
>>>>>> +	for (i =3D 0, addr =3D haddr; i < HPAGE_PMD_NR; i++, addr +=3D PAG=
E_SIZE) {
>>>>>> +		pte_t *pte =3D pte_offset_map(pmd, addr);
>>>>>> +		struct page *page;
>>>>>> +
>>>>>> +		if (pte_none(*pte))
>>>>>> +			continue;
>>>>>> +		page =3D vm_normal_page(vma, addr, *pte);
>>>>>> +		page_remove_rmap(page, false);
>>>>>> +	}
>>>>>> +
>>>>>> +	/* step 3: set proper refcount and mm_counters. */
>>>>>> +	page_ref_sub(hpage, count);
>>>>>> +	add_mm_counter(vma->vm_mm, mm_counter_file(hpage), -count);
>>>>>> +	return true;
>>>>>> +}
>>>>>> +
>>>>>> +extern pid_t sysctl_dump_pt_pid;
>>>>>> +static void retract_page_tables(struct address_space *mapping, pgof=
f_t pgoff,
>>>>>> +				struct page *hpage)
>>>>>> {
>>>>>> 	struct vm_area_struct *vma;
>>>>>> 	unsigned long addr;
>>>>>> @@ -1273,21 +1313,21 @@ static void retract_page_tables(struct addre=
ss_space *mapping, pgoff_t pgoff)
>>>>>> 		pmd =3D mm_find_pmd(vma->vm_mm, addr);
>>>>>> 		if (!pmd)
>>>>>> 			continue;
>>>>>> -		/*
>>>>>> -		 * We need exclusive mmap_sem to retract page table.
>>>>>> -		 * If trylock fails we would end up with pte-mapped THP after
>>>>>> -		 * re-fault. Not ideal, but it's more important to not disturb
>>>>>> -		 * the system too much.
>>>>>> -		 */
>>>>>> 		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
>>>>>> 			spinlock_t *ptl =3D pmd_lock(vma->vm_mm, pmd);
>>>>>> -			/* assume page table is clear */
>>>>>> +
>>>>>> +			if (!prepare_pmd_for_collapse(vma, pgoff, hpage, pmd)) {
>>>>>> +				spin_unlock(ptl);
>>>>>> +				up_write(&vma->vm_mm->mmap_sem);
>>>>>> +				continue;
>>>>>> +			}
>>>>>> 			_pmd =3D pmdp_collapse_flush(vma, addr, pmd);
>>>>>> 			spin_unlock(ptl);
>>>>>> 			up_write(&vma->vm_mm->mmap_sem);
>>>>>> 			mm_dec_nr_ptes(vma->vm_mm);
>>>>>> 			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
>>>>>> -		}
>>>>>> +		} else
>>>>>> +			set_bit(AS_COLLAPSE_PMD, &mapping->flags);
>>>>>> 	}
>>>>>> 	i_mmap_unlock_write(mapping);
>>>>>> }
>>>>>> @@ -1561,7 +1601,7 @@ static void collapse_file(struct mm_struct *mm=
,
>>>>>> 		/*
>>>>>> 		 * Remove pte page tables, so we can re-fault the page as huge.
>>>>>> 		 */
>>>>>> -		retract_page_tables(mapping, start);
>>>>>> +		retract_page_tables(mapping, start, new_page);
>>>>>> 		*hpage =3D NULL;
>>>>>>=20
>>>>>> 		khugepaged_pages_collapsed++;
>>>>>> @@ -1622,6 +1662,7 @@ static void khugepaged_scan_file(struct mm_str=
uct *mm,
>>>>>> 	int present, swap;
>>>>>> 	int node =3D NUMA_NO_NODE;
>>>>>> 	int result =3D SCAN_SUCCEED;
>>>>>> +	bool collapse_pmd =3D false;
>>>>>>=20
>>>>>> 	present =3D 0;
>>>>>> 	swap =3D 0;
>>>>>> @@ -1640,6 +1681,14 @@ static void khugepaged_scan_file(struct mm_st=
ruct *mm,
>>>>>> 		}
>>>>>>=20
>>>>>> 		if (PageTransCompound(page)) {
>>>>>> +			if (collapse_pmd ||
>>>>>> +			    test_and_clear_bit(AS_COLLAPSE_PMD,
>>>>>> +					       &mapping->flags)) {
>>>>>=20
>>>>> Who said it's the only PMD range that's subject to collapse? The bit =
has
>>>>> to be per-PMD, not per-mapping.
>>>>=20
>>>> I didn't assume this is the only PMD range that subject to collapse.=20
>>>> So once we found AS_COLLAPSE_PMD, it will continue scan the whole mapp=
ing:
>>>> retract_page_tables(), then continue.=20
>>>=20
>>> I still don't get it.
>>>=20
>>> Assume we have two ranges that subject to collapse. khugepaged_scan_fil=
e()
>>> sees and clears AS_COLLAPSE_PMD. Tries to collapse the first range, fai=
ls
>>> and set the bit again. khugepaged_scan_file() sees the second range,
>>> clears the bit, but this time collapse is successful: the bit is still =
not
>>> set, but it should be.
>>=20
>> Yeah, you are right. Current logic only covers multiple THPs within sing=
le
>> call of khugepaged_scan_file(). I missed the case you just described.=20
>>=20
>> What do you think about the first 4 patches of set and the other set? If=
=20
>> these patches look good, how about we get them in first? I will work on=
=20
>> proper fix (or re-design) for 5/6 and 6/6 in the meanwhile.=20
>=20
> You can use
>=20
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>=20
> for the first 4 patches.

Thanks Kirill!

Song

