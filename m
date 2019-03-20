Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 206BAC10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:48:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC40A2184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:48:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="lIXiSAAc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC40A2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D9066B0003; Wed, 20 Mar 2019 02:48:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25D9E6B0006; Wed, 20 Mar 2019 02:48:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 101666B0007; Wed, 20 Mar 2019 02:48:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BAFEA6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:48:32 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b11so1588497pfo.15
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 23:48:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=pVJTyAUdYpW1rV9Zr3u1YGhOj2yB6ZXF0806FKC8c8E=;
        b=EKASTmhufuRNDvXWLXsKg7qRUJh/A/uXt65GrYqmDCau+Dnqz7U/gWqeW1DJMzogeD
         MK15g002gNrd6BECfmrRebaW/1fG81yTxbTWC1dXtX1ZTSJPM2uR9T47rF5IeUp/EP7q
         dnhZIvfk6cLjAj26OPX7gd/1UfY2nDff+lINcM0Lesm04bca50BDTyX8F47l/Kgm8mNu
         XzymkcTjpwG5YFdYl+9GgC8NQyy8hnl66OY8S/h87oQONrIIholE4HMxOf8G0t46Ca/P
         0zMOntd7YODfIv1FWRyKpWNi4kfYkNcQE1XTr9eQ7Q9scsY3wCFRjQNgkRCXYQrAZE/u
         ZcRA==
X-Gm-Message-State: APjAAAVTGLav5+zJ3KnmVZ2TfQz7pjS8+I4x16MYZoLYfnOESMj0BaHI
	B1aDxJcogIzSEGTY2IU9gHxkXmUDgWrkOnyTnZLsUI9qOC7FR2Dm7NurCrys/V5sZYGc0zMdJRY
	NlcnwSQsmsvHPOStHuxVhBOdtKvQ9DlCSHu9eYiYXKpdxCrQBnMMYjlI7s9E5CE4Kug==
X-Received: by 2002:a63:460a:: with SMTP id t10mr5682859pga.354.1553064512291;
        Tue, 19 Mar 2019 23:48:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwthC2IfgYvg9Rz52ZAYEXplm8J73QWlpxzgsxYMxdy93n6mvJV1UMuJ0OtVE3jl2B3QqQF
X-Received: by 2002:a63:460a:: with SMTP id t10mr5682788pga.354.1553064511066;
        Tue, 19 Mar 2019 23:48:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553064511; cv=none;
        d=google.com; s=arc-20160816;
        b=Hs6eVY90O/MR544/vrPImbg/USAzP5V9IS5sg6PGpOXEDxIbY8a8QpIs5qHiY8m2lw
         2Ra/a6e7FlDZMEYYcszYW8xCuHZ9KWaCQbO9XGX6bl/oia0qLA9KFE9se0CSXUDwMtx3
         0Wpt9no6llDjTSPKqPotXYXqf1yEIkcGuaPmbd+ZZNLAd23O/jSXJFtvZzJfL3OxU7E6
         oGSMEea9rWCWVwsQSWlUAcrlEiWduxzYqRGWSlJlMfOy33sYAkmrRoxujJ2cAsG34yHd
         FCtPg2N/+7uvq7FTSusjyoMVZJn/Vqm5K25WN6Xnz3qxOmEGi5UWHVSltZ7WTp5Hfpf4
         870Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=pVJTyAUdYpW1rV9Zr3u1YGhOj2yB6ZXF0806FKC8c8E=;
        b=V/do+6iQkJyU0yu+XqgVgAbjWJitRpJh+iw0P3897IFv850dWPUcpb1lO82fRUk2pU
         zeN4GFqdV84TcK+BLtQl9eR7cSIYAfP6OHerdpci3ZrjWsoS7lIp/kdbkoH05GFjgrm4
         FMZw4otog517/OWvdzXH5MqA10yl++6LIxpHkVyvYFnD3OeWTDcBU+MddyLphXkWZUaE
         59nt4QckKae6RseVJANE2gm4MKm1PXkWHf67xylv5iQqGGzzRBdrTpzKK7KF1CtdyB9X
         IIKOGuZJWqX9Cmtg2XLZVBSIhcX+/vsNQejw3v4ok73LjfR7ZeVYEthRryDig1rsq6kn
         e8KA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=lIXiSAAc;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.54 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310054.outbound.protection.outlook.com. [40.107.131.54])
        by mx.google.com with ESMTPS id r26si996446pgv.127.2019.03.19.23.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 23:48:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.54 as permitted sender) client-ip=40.107.131.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=lIXiSAAc;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.54 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=pVJTyAUdYpW1rV9Zr3u1YGhOj2yB6ZXF0806FKC8c8E=;
 b=lIXiSAAc/ZNRJcphW/W3cgL/1awBNa5DJ3EHviWWpXCATr01A/mY7+IfEaUb19QFy8FIwwPXrrLcnnO8BVBo+pOjwJLznMNAZsOMVgNRopugNyN2bjjj+p+twidTMAKwUKkqDia6aIxxf1fTJNxAstIxhMYN3o/0rFY9R1DGP44=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB2812.apcprd02.prod.outlook.com (20.177.86.138) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Wed, 20 Mar 2019 06:48:28 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Wed, 20 Mar 2019
 06:48:28 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@kernel.org>, "aneesh.kumar@linux.ibm.com"
	<aneesh.kumar@linux.ibm.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "khandual@linux.vnet.ibm.com"
	<khandual@linux.vnet.ibm.com>
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
Thread-Topic: [External] Re: vmscan: Reclaim unevictable pages
Thread-Index:
 AQHU3WaYCAMWaFadm0e/0+hd2XPYGaYRGYZ/gAAG5oCAAAD82oAAAx4AgAABDq2AAAzwgIAC47DN
Date: Wed, 20 Mar 2019 06:48:27 +0000
Message-ID:
 <SG2PR02MB309864258DBE630AD3AD2E10E8410@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098A05E09B0D3F3CB1C3B9BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190314084120.GF7473@dhcp22.suse.cz>
 <SG2PR02MB309894F6D7DF9148846088F3E84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <226a92b9-94c5-b859-c54b-3aacad3089cc@virtuozzo.com>
 <SG2PR02MB3098299456FB6AE2FD822C4CE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB30988333AD658F8124070ABEE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098AB587F4BFCD6B9D042FDE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <0b86dbca-cbc9-3b43-e3b9-8876bcc24f22@suse.cz>
 <SG2PR02MB309841EA4764E675D4649139E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <56862fc0-3e4b-8d1e-ae15-0df32bf5e4c0@virtuozzo.com>
 <SG2PR02MB3098EEAF291BFD72F4163936E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <4c05dda3-9fdf-e357-75ed-6ee3f25c9e52@virtuozzo.com>
 <SG2PR02MB309869FC3A436C71B50FA57BE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>,<09b6ee71-0007-7f1d-ac80-7e05421e4ec6@virtuozzo.com>
In-Reply-To: <09b6ee71-0007-7f1d-ac80-7e05421e4ec6@virtuozzo.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a56f1753-4002-4087-33db-08d6ad000ee8
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB2812;
x-ms-traffictypediagnostic: SG2PR02MB2812:|SG2PR02MB2812:
x-ms-exchange-purlcount: 2
x-microsoft-antispam-prvs:
 <SG2PR02MB28123E5AA8AE1525A7A75F7EE8410@SG2PR02MB2812.apcprd02.prod.outlook.com>
x-forefront-prvs: 098291215C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(39850400004)(366004)(376002)(346002)(136003)(54534003)(189003)(199004)(76176011)(11346002)(2501003)(86362001)(110136005)(93886005)(446003)(81156014)(486006)(6246003)(99286004)(7696005)(53546011)(476003)(54906003)(44832011)(8936002)(6506007)(53936002)(8676002)(74316002)(7736002)(68736007)(478600001)(26005)(2906002)(186003)(102836004)(55236004)(305945005)(6306002)(9686003)(6436002)(81166006)(55016002)(966005)(14454004)(316002)(256004)(105586002)(4326008)(5024004)(97736004)(14444005)(66574012)(5660300002)(52536014)(30864003)(25786009)(33656002)(71200400001)(71190400001)(78486014)(6116002)(66066001)(106356001)(3846002)(229853002)(586874002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB2812;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 /cEmGy6OmJUgXcQSWyDX3UUmb93rK2JR/w91DiiK1EysBR90Eti9b8LHb38RDRSpwXcSN4onXQemMi58I+pGfjGW0ZIhaZXorFWng5b8bZ6lcF2eLYamuGtYcflMrZIl2NL04acxVqv31tk2wtAx7ux3U0iBv+IzlqQfluFHTkyoq0u/8/IgVJ48euYGwnG0BrNqUSRwAM0wWoiMgoW4xubwKUyDROd9RWVYAdHrndnz1GVpSLbLbjyHYSjq0gBAQw5Kb682fmiOaoQTJHvi2KxlOREfKYaCVeV202Q5k8+xRG2HoNhx0znpjQytuj0pyE1WT/XbEloCHKY5hL0aVsgx46RlKPa2Fn9Te9ptk5GYBsBJrW+FerFDyOJNp8JPet++dJltm20+3r2+x4DkXYjdnAInU5lLaurXDY0ChOM=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a56f1753-4002-4087-33db-08d6ad000ee8
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Mar 2019 06:48:27.8966
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB2812
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


________________________________________
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Sent: 18 March 2019 16:08
To: Pankaj Suryawanshi; Vlastimil Babka; Michal Hocko; aneesh.kumar@linux.i=
bm.com
Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org; k=
handual@linux.vnet.ibm.com
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages

On 18.03.2019 12:59, Pankaj Suryawanshi wrote:
>
> From: Kirill Tkhai <ktkhai@virtuozzo.com>
> Sent: 18 March 2019 15:17:56
> To: Pankaj Suryawanshi; Vlastimil Babka; Michal Hocko; aneesh.kumar@linux=
.ibm.com
> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org;=
 khandual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
> Subject: Re: [External] Re: vmscan: Reclaim unevictable pages

Also, please, avoid irritating quoting like below ^^^. They just distract a=
ttention.

> On 18.03.2019 12:43, Pankaj Suryawanshi wrote:
>> Hi Kirill Tkhai,
>>
>
> Please, do not top posting:  https://kernelnewbies.org/mailinglistguideli=
nes
>
> Okay.
>
> mailinglistguidelines - Linux Kernel Newbies
> kernelnewbies.org
> Set of FAQs for kernelnewbies mailing list. If you are new to this list p=
lease read this page before you go on your quest for squeezing all the know=
ledge from fellow members.

And this spew ^^^.

>> Please see mm/vmscan.c in which it first added to list and than throw th=
e error :
>> ------------------------------------------------------------------------=
--------------------------
>> keep:
>>                  list_add(&page->lru, &ret_pages);
>>                  VM_BUG_ON_PAGE(PageLRU(page) || PageUnevictable(page), =
page);
>> ------------------------------------------------------------------------=
---------------------------
>>
>> Before throwing error, pages are added to list, this is under iteration =
of shrink_page_list().
>
> I say about about the list, which is passed to shrink_page_list() as firs=
t argument.
> Did you mean candidate list which is passed to shrink_page_list().
>
> shrink_inactive_list()
> {
>         isolate_lru_pages(&page_list); // <-- you can't obtain unevictabl=
e pages here.
>         shrink_page_list(&page_list);
> }
>
> below is the overview of flow of calls for your information.
>
> cma_alloc() ->
> alloc_contig_range() ->
> start_isolate_page_range() ->
> __alloc_contig_migrate_range() ->
> isolate_migratepages_range() ->
> reclaim_clean_pages_from_list() ->
> shrink_page_list()

Hm, isolate_migratepages_range() can take unevictable pages,
but then with your patch we just skip them in shrink_page_list().
Without your patch we bump into bug on.

I don't see any other issue/effect if i apply this patch.

These both look incorrect for me. Let's wait someone who familiar
with this logic.

>> From: Kirill Tkhai <ktkhai@virtuozzo.com>
>> Sent: 18 March 2019 15:03:15
>> To: Pankaj Suryawanshi; Vlastimil Babka; Michal Hocko; aneesh.kumar@linu=
x.ibm.com
>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org=
; khandual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
>> Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
>>
>>
>> Hi, Pankaj,
>>
>> On 18.03.2019 12:09, Pankaj Suryawanshi wrote:
>>>
>>> Hello
>>>
>>> shrink_page_list() returns , number of pages reclaimed, when pages is u=
nevictable it returns VM_BUG_ON_PAGE(PageLRU(page) || PageUnevicatble(page)=
,page);
>>
>> the general idea is shrink_page_list() can't iterate PageUnevictable() p=
ages.
>> PageUnevictable() pages are never being added to lists, which shrink_pag=
e_list()
>> uses for iteration. Also, a page can't be marked as PageUnevictable(), w=
hen
>> it's attached to a shrinkable list.
>>
>> So, the problem should be somewhere outside shrink_page_list().
>>
>> I won't suggest you something about CMA, since I haven't dived in that c=
ode.
>>
>>> We can add the unevictable pages in reclaim list in shrink_page_list(),=
 return total number of reclaim pages including unevictable pages, let the =
caller handle unevictable pages.
>>>
>>> I think the problem is shrink_page_list is awkard. If page is unevictab=
le it goto activate_locked->keep_locked->keep lables, keep lable list_add t=
he unevictable pages and throw the VM_BUG instead of passing it to caller w=
hile it relies on caller for non-reclaimed-non-unevictable    page's putbac=
k.
>>> I think we can make it consistent so that shrink_page_list could return=
 non-reclaimed pages via page_list and caller can handle it. As an advance,=
 it could try to migrate mlocked pages without retrial.
>>>
>>>
>>> Below is the issue of CMA_ALLOC of large size buffer : (Kernel version =
- 4.14.65 (On Android pie [ARM])).
>>>
>>> [=A0=A0 24.718792] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) ||=
 PageUnevictable(page))
>>> [=A0=A0 24.726949] page->mem_cgroup:bd008c00
>>> [=A0=A0 24.730693] ------------[ cut here ]------------
>>> [=A0=A0 24.735304] kernel BUG at mm/vmscan.c:1350!
>>> [=A0=A0 24.739478] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>>>
>>>
>>> Below is the patch which solved this issue :
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index be56e2e..12ac353 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_h=
ead *page_list,
>>>                 sc->nr_scanned++;
>>>
>>>                 if (unlikely(!page_evictable(page)))
>>> -                       goto activate_locked;
>>> +                      goto cull_mlocked;
>>>
>>>                 if (!sc->may_unmap && page_mapped(page))
>>>                         goto keep_locked;
>>> @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct lis=
t_head *page_list,
>>>                 } else
>>>                         list_add(&page->lru, &free_pages);
>>>                 continue;
>>> -
>>> +cull_mlocked:
>>> +                if (PageSwapCache(page))
>>> +                        try_to_free_swap(page);
>>> +                unlock_page(page);
>>> +                list_add(&page->lru, &ret_pages);
>>> +                continue;
>>>  activate_locked:
>>>                 /* Not a candidate for swapping, so reclaim swap space.=
 */
>>>                 if (PageSwapCache(page) && (mem_cgroup_swap_full(page) =
||
>>>
>>>
>>>
>>>
>>> It fixes the below issue.
>>>
>>> 1. Large size buffer allocation using cma_alloc successful with unevict=
able pages.
>>>
>>> cma_alloc of current kernel will fail due to unevictable page
>>>
>>> Please let me know if anything i am missing.
>>>
>>> Regards,
>>> Pankaj
>>>
>>> From: Vlastimil Babka <vbabka@suse.cz>
>>> Sent: 18 March 2019 14:12:50
>>> To: Pankaj Suryawanshi; Kirill Tkhai; Michal Hocko; aneesh.kumar@linux.=
ibm.com
>>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.or=
g; khandual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
>>> Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
>>>
>>>
>>> On 3/15/19 11:11 AM, Pankaj Suryawanshi wrote:
>>>>
>>>> [ cc Aneesh kumar, Anshuman, Hillf, Vlastimil]
>>>
>>> Can you send a proper patch with changelog explaining the change? I
>>> don't know the context of this thread.
>>>
>>>> From: Pankaj Suryawanshi
>>>> Sent: 15 March 2019 11:35:05
>>>> To: Kirill Tkhai; Michal Hocko
>>>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.o=
rg
>>>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>>>
>>>>
>>>>
>>>> [ cc linux-mm ]
>>>>
>>>>
>>>> From: Pankaj Suryawanshi
>>>> Sent: 14 March 2019 19:14:40
>>>> To: Kirill Tkhai; Michal Hocko
>>>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
>>>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>>>
>>>>
>>>>
>>>> Hello ,
>>>>
>>>> Please ignore the curly braces, they are just for debugging.
>>>>
>>>> Below is the updated patch.
>>>>
>>>>
>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>> index be56e2e..12ac353 100644
>>>> --- a/mm/vmscan.c
>>>> +++ b/mm/vmscan.c
>>>> @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_=
head *page_list,
>>>>                  sc->nr_scanned++;
>>>>
>>>>                  if (unlikely(!page_evictable(page)))
>>>> -                       goto activate_locked;
>>>> +                      goto cull_mlocked;
>>>>
>>>>                  if (!sc->may_unmap && page_mapped(page))
>>>>                          goto keep_locked;
>>>> @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct li=
st_head *page_list,
>>>>                  } else
>>>>                          list_add(&page->lru, &free_pages);
>>>>                  continue;
>>>> -
>>>> +cull_mlocked:
>>>> +                if (PageSwapCache(page))
>>>> +                        try_to_free_swap(page);
>>>> +                unlock_page(page);
>>>> +                list_add(&page->lru, &ret_pages);
>>>> +                continue;
>>>>   activate_locked:
>>>>                  /* Not a candidate for swapping, so reclaim swap spac=
e. */
>>>>                  if (PageSwapCache(page) && (mem_cgroup_swap_full(page=
) ||
>>>>
>>>>
>>>>
>>>> Regards,
>>>> Pankaj
>>>>
>>>>
>>>> From: Kirill Tkhai <ktkhai@virtuozzo.com>
>>>> Sent: 14 March 2019 14:55:34
>>>> To: Pankaj Suryawanshi; Michal Hocko
>>>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
>>>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>>>
>>>>
>>>> On 14.03.2019 11:52, Pankaj Suryawanshi wrote:
>>>>>
>>>>> I am using kernel version 4.14.65 (on Android pie [ARM]).
>>>>>
>>>>> No additional patches applied on top of vanilla.(Core MM).
>>>>>
>>>>> If  I change in the vmscan.c as below patch, it will work.
>>>>
>>>> Sorry, but 4.14.65 does not have braces around trylock_page(),
>>>> like in your patch below.
>>>>
>>>> See        https://git.kernel.org/pub/scm/linux/kernel/git/stable/linu=
x.git/tree/mm/vmscan.c?h=3Dv4.14.65
>>>>
>>>> [...]
>>>>
>>>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>>>> index be56e2e..2e51edc 100644
>>>>>> --- a/mm/vmscan.c
>>>>>> +++ b/mm/vmscan.c
>>>>>> @@ -990,15 +990,17 @@ static unsigned long shrink_page_list(struct l=
ist_head *page_list,
>>>>>>                   page =3D lru_to_page(page_list);
>>>>>>                   list_del(&page->lru);
>>>>>>
>>>>>>                  if (!trylock_page(page)) {
>>>>>>                           goto keep;
>>>>>>                  }
>>>>
>>>> **********************************************************************=
***************************************************************************=
************ eInfochips Business Disclaimer: This e-mail message and all at=
tachments transmitted with it are   intended  solely for the use of the add=
ressee and may contain legally privileged and confidential information. If =
the reader of this message is not the intended recipient, or an employee or=
 agent responsible for delivering this message to the intended recipient,  =
 you  are hereby notified that any dissemination, distribution, copying, or=
 other use of this message or its attachments is strictly prohibited. If yo=
u have received this message in error, please notify the sender immediately=
 by replying to this message and   please  delete it from your computer. An=
y views expressed in this message are those of the individual sender unless=
 otherwise stated. Company has taken enough precautions to prevent the spre=
ad of viruses. However the company accepts no liability for any damage   ca=
used  by any virus transmitted by this email. *****************************=
***************************************************************************=
*****************************************************
>>>>
>>>
>>>
>>>
>>
>>
>
>

