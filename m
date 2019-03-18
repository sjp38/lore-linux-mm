Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 739B1C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:59:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D9AF2087C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:59:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="0+IC5O97"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D9AF2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95B4B6B0007; Mon, 18 Mar 2019 05:59:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 908CE6B0008; Mon, 18 Mar 2019 05:59:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F7F66B000A; Mon, 18 Mar 2019 05:59:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B14C6B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:59:07 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 73so18083188pga.18
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:59:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=AHS3+WiEBirGp9juV270he5zp7i0cndQFY9a7oyqWW8=;
        b=lqlJ8XySfmQVDJZxenr7ajck0upzXN8gE0GgKltjAulVHVES3UCUUq3hyMsmWv8M06
         ptKdQNyB88dk063pJe8hq5FOdY7ydlcmvri7gD6TPXapBcU4mF2SsTnJrTk6n1IKUr8x
         jpYFcvtemouVCFcEkkX+2jHPHEtMk4zRM9Jsjmt+xwhDmswwUAQ1KwTHG65iwZBCD1kw
         Rprz3HClhEvfBJ+e4F71xUJMfk2MlYoK+QoX+W4E9RXkpAuOq4T+eoQGB+gb+74BUj85
         JepDMgFs78ejoNZafcBTq4AfL8mt8kA6pIYnBNXMwBpYYlDzuESYz5/yXqxhiRM9vGvK
         b2+g==
X-Gm-Message-State: APjAAAUzV2hHe+ZBfRB7FXFQggcgmmJRL2HNtJHfcKV6vKC7Emr0J677
	DuhOopls6pw+WuzbEaEW+VzB1HfSthNeZq4fktfi8vBI4XfaNsXQvpE/C8MGsEiSpxmGzoSgIn1
	hKsvJ3PvgsKydNluniBrhFEiSXB0kd7Tl3FyM168YZjIz6vgcu/fRegau3f6/0neBSQ==
X-Received: by 2002:a63:1ce:: with SMTP id 197mr16700114pgb.47.1552903146856;
        Mon, 18 Mar 2019 02:59:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzITaf+kmFszv5jPX/1evLvE8vVomCiW7+7ItLrktCces2Ki78tk5snHuKzC7OdXZoz6pYW
X-Received: by 2002:a63:1ce:: with SMTP id 197mr16700052pgb.47.1552903145657;
        Mon, 18 Mar 2019 02:59:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552903145; cv=none;
        d=google.com; s=arc-20160816;
        b=YpP/iauB18AoUVNOCbh5r8qgtmNBhccWY+CRjDjwjl5AdMXCq4jLbZR6xTXGIcZm1y
         QMQy1usl9u0sb6kUcmIWQqsYzRAHPRAMlah886riWw84abXiuSM63nmPLHYxvAAyyhhp
         9mALIja689MfbFcEngw1eldEPmpkMT2yVlNRpp/g78pps1DJ/mPbSbRazrBORnXNpa3R
         A1e8xzI+MyPMcgvb2RJDhAVyZ6J7znG2ct2lhAYoUyuiPyxpL/wY8dMZhz4OOxE5aJVZ
         H5Px93kUwvOMpecV2nPSClsgsh6xStoLJNTrDDlsim3YtA05LNuNp1UwMouj3nA4Uo2A
         ltjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=AHS3+WiEBirGp9juV270he5zp7i0cndQFY9a7oyqWW8=;
        b=NNpzWplIpysIMkcqUEECIR0XjRDpmiLWkNBKRis1Sx5dvPNFUMddO8kp4QxwX5Pxdw
         f8JZuIiQLX/pY0Rx5fILGRmZaG3X0xqgqNcS7kA9BA1o4A62ND6RqicZrB6HRwf8oReG
         SJuP4LLvFeX6TZ10HS8PmExk1h69Xk4CWDGjBT6EsXYsmxQrDNONgV+dI7z3NsyO2pz3
         Nt1G1jnwEF0J1dzyP9yOwJn4SbNVOwsCRUmjQVwWfsscDZHzmzSYnqMq2w9b1FQFVUGw
         DQGtIMEohXrbdNOvKFCoC12mEkKSZ+0wQ6Lfmxm1jWNn7j8/JvEm7GQcb2oU5Ri1mGp3
         2uaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=0+IC5O97;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.49 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320049.outbound.protection.outlook.com. [40.107.132.49])
        by mx.google.com with ESMTPS id u9si8627174pgp.269.2019.03.18.02.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 02:59:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.49 as permitted sender) client-ip=40.107.132.49;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=0+IC5O97;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.49 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AHS3+WiEBirGp9juV270he5zp7i0cndQFY9a7oyqWW8=;
 b=0+IC5O9768ifP4WEVLjetXH0sXXXYYNHLUkXOA6exdcS4DvePrc/mbxBQkZ0DfRiLCJ20hdpKFxV0oKKfWk3E9ivx8CyoXo7pTx+2s055LwNPMHtezgAGt97K6IvKhJzQgvXw45jis5U5VResnzQN0tlxKiPKL9g5z3zLHOHE7Y=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3734.apcprd02.prod.outlook.com (20.177.170.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Mon, 18 Mar 2019 09:59:00 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Mon, 18 Mar 2019
 09:59:00 +0000
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
Thread-Index: AQHU3WaYCAMWaFadm0e/0+hd2XPYGaYRGYZ/gAAG5oCAAAD82oAAAx4AgAABDq0=
Date: Mon, 18 Mar 2019 09:59:00 +0000
Message-ID:
 <SG2PR02MB309869FC3A436C71B50FA57BE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098A05E09B0D3F3CB1C3B9BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098B751EC6B8E32806A42FBE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
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
 <SG2PR02MB3098EEAF291BFD72F4163936E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>,<4c05dda3-9fdf-e357-75ed-6ee3f25c9e52@virtuozzo.com>
In-Reply-To: <4c05dda3-9fdf-e357-75ed-6ee3f25c9e52@virtuozzo.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: c2c74ccd-776a-4dfa-6bfa-08d6ab885856
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3734;
x-ms-traffictypediagnostic: SG2PR02MB3734:|SG2PR02MB3734:
x-ms-exchange-purlcount: 2
x-microsoft-antispam-prvs:
 <SG2PR02MB3734622AB32612CD72817725E8470@SG2PR02MB3734.apcprd02.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(346002)(376002)(396003)(39850400004)(366004)(189003)(199004)(54534003)(71200400001)(229853002)(2906002)(5660300002)(14454004)(66066001)(68736007)(66574012)(78486014)(106356001)(53936002)(6246003)(316002)(54906003)(110136005)(97736004)(105586002)(2501003)(966005)(478600001)(93886005)(486006)(55016002)(44832011)(6436002)(256004)(53546011)(55236004)(102836004)(26005)(186003)(6506007)(14444005)(5024004)(11346002)(33656002)(305945005)(74316002)(25786009)(446003)(7736002)(52536014)(81156014)(81166006)(8676002)(3846002)(6116002)(4326008)(8936002)(71190400001)(86362001)(99286004)(9686003)(476003)(6306002)(7696005)(76176011);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3734;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 PdHObRrDKyICUSDsSf37n9CGLmrc6hTxTm9R6pVidgGmoS4Kr9Y7RKvflgv4O83DIDQJXUPYx2CKVTAJBscYMh/8tVqy37Vjx53/kuaN7Upioi3zLF8yuvzNEV/RZyWWXat+IxbEXKPco4Ugz0TBnwqafnTklL1fLRW9uW8pVcq8AiaP7xJ3so1vpbG1ho4HY1Tsn9GxMbFkEdR6eoOgTZu3SmILIcK+i3GGwGJcNX3EthpFzjwzGkJMt2yv/XL9qx4s88fC6xHQ1oT1N7u0JUkzm1Pt9XSqUse3+XzynEZ6wy2F5yuKl0Ikg3pUxJlV5do0MM1ReC1k3zWrguegGkEcpepxMf+gTB1z0WTyRZ/lqJNdlgFm34tUwlkNSfkyairJVwTd5XudmcDMQ7VSBdB2dZiMiI10wPuAoXqSOug=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: c2c74ccd-776a-4dfa-6bfa-08d6ab885856
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 09:59:00.2882
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3734
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

 =20
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Sent: 18 March 2019 15:17:56
To: Pankaj Suryawanshi; Vlastimil Babka; Michal Hocko; aneesh.kumar@linux.i=
bm.com
Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org; k=
handual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
=A0=20

On 18.03.2019 12:43, Pankaj Suryawanshi wrote:
> Hi Kirill Tkhai,
>

Please, do not top posting:  https://kernelnewbies.org/mailinglistguideline=
s

Okay.

mailinglistguidelines - Linux Kernel Newbies
kernelnewbies.org
Set of FAQs for kernelnewbies mailing list. If you are new to this list ple=
ase read this page before you go on your quest for squeezing all the knowle=
dge from fellow members.

> Please see mm/vmscan.c in which it first added to list and than throw the=
 error :
> -------------------------------------------------------------------------=
-------------------------
> keep:
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_add(&page->lru, &ret=
_pages);
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 VM_BUG_ON_PAGE(PageLRU(pa=
ge) || PageUnevictable(page), page);
> -------------------------------------------------------------------------=
--------------------------
>=20
> Before throwing error, pages are added to list, this is under iteration o=
f shrink_page_list().

I say about about the list, which is passed to shrink_page_list() as first =
argument.
Did you mean candidate list which is passed to shrink_page_list().

shrink_inactive_list()
{
=A0=A0=A0=A0=A0=A0=A0 isolate_lru_pages(&page_list); // <-- you can't obtai=
n unevictable pages here.
=A0=A0=A0=A0=A0=A0=A0 shrink_page_list(&page_list);
}

below is the overview of flow of calls for your information.

cma_alloc() ->
alloc_contig_range() ->
start_isolate_page_range() ->
__alloc_contig_migrate_range() ->
isolate_migratepages_range() ->
reclaim_clean_pages_from_list() ->
shrink_page_list()
=A0
> From: Kirill Tkhai <ktkhai@virtuozzo.com>
> Sent: 18 March 2019 15:03:15
> To: Pankaj Suryawanshi; Vlastimil Babka; Michal Hocko; aneesh.kumar@linux=
.ibm.com
> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org;=
 khandual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
> Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
> =A0=20
>=20
> Hi, Pankaj,
>=20
> On 18.03.2019 12:09, Pankaj Suryawanshi wrote:
>>
>> Hello
>>
>> shrink_page_list() returns , number of pages reclaimed, when pages is un=
evictable it returns VM_BUG_ON_PAGE(PageLRU(page) || PageUnevicatble(page),=
page);
>=20
> the general idea is shrink_page_list() can't iterate PageUnevictable() pa=
ges.
> PageUnevictable() pages are never being added to lists, which shrink_page=
_list()
> uses for iteration. Also, a page can't be marked as PageUnevictable(), wh=
en
> it's attached to a shrinkable list.
>=20
> So, the problem should be somewhere outside shrink_page_list().
>=20
> I won't suggest you something about CMA, since I haven't dived in that co=
de.
>=20
>> We can add the unevictable pages in reclaim list in shrink_page_list(), =
return total number of reclaim pages including unevictable pages, let the c=
aller handle unevictable pages.
>>
>> I think the problem is shrink_page_list is awkard. If page is unevictabl=
e it goto activate_locked->keep_locked->keep lables, keep lable list_add th=
e unevictable pages and throw the VM_BUG instead of passing it to caller wh=
ile it relies on caller for non-reclaimed-non-unevictable=A0=A0  page's put=
back.
>> I think we can make it consistent so that shrink_page_list could return =
non-reclaimed pages via page_list and caller can handle it. As an advance, =
it could try to migrate mlocked pages without retrial.
>>
>>
>> Below is the issue of CMA_ALLOC of large size buffer : (Kernel version -=
 4.14.65 (On Android pie [ARM])).
>>
>> [=A0=A0 24.718792] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || =
PageUnevictable(page))
>> [=A0=A0 24.726949] page->mem_cgroup:bd008c00
>> [=A0=A0 24.730693] ------------[ cut here ]------------
>> [=A0=A0 24.735304] kernel BUG at mm/vmscan.c:1350!
>> [=A0=A0 24.739478] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>>
>>
>> Below is the patch which solved this issue :
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index be56e2e..12ac353 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_he=
ad *page_list,
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sc->nr_scanned++;
>> =A0
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (unlikely(!page_evictab=
le(page)))
>> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto=
 activate_locked;
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto cu=
ll_mlocked;
>> =A0
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!sc->may_unmap && page=
_mapped(page))
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 go=
to keep_locked;
>> @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct list=
_head *page_list,
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 } else
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 li=
st_add(&page->lru, &free_pages);
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
>> -
>> +cull_mlocked:
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page))
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 t=
ry_to_free_swap(page);
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unlock_page(page);
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_add(&page->lru, &ret=
_pages);
>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
>> =A0activate_locked:
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* Not a candidate for swa=
pping, so reclaim swap space. */
>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page) &&=
 (mem_cgroup_swap_full(page) ||
>>
>>
>>
>>
>> It fixes the below issue.
>>
>> 1. Large size buffer allocation using cma_alloc successful with unevicta=
ble pages.
>>
>> cma_alloc of current kernel will fail due to unevictable page
>>
>> Please let me know if anything i am missing.
>>
>> Regards,
>> Pankaj
>> =A0=A0=20
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Sent: 18 March 2019 14:12:50
>> To: Pankaj Suryawanshi; Kirill Tkhai; Michal Hocko; aneesh.kumar@linux.i=
bm.com
>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org=
; khandual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
>> Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
>> =A0=20
>>
>> On 3/15/19 11:11 AM, Pankaj Suryawanshi wrote:
>>>
>>> [ cc Aneesh kumar, Anshuman, Hillf, Vlastimil]
>>
>> Can you send a proper patch with changelog explaining the change? I
>> don't know the context of this thread.
>>
>>> From: Pankaj Suryawanshi
>>> Sent: 15 March 2019 11:35:05
>>> To: Kirill Tkhai; Michal Hocko
>>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.or=
g
>>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>>
>>>
>>>
>>> [ cc linux-mm ]
>>>
>>>
>>> From: Pankaj Suryawanshi
>>> Sent: 14 March 2019 19:14:40
>>> To: Kirill Tkhai; Michal Hocko
>>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
>>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>>
>>>
>>>
>>> Hello ,
>>>
>>> Please ignore the curly braces, they are just for debugging.
>>>
>>> Below is the updated patch.
>>>
>>>
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index be56e2e..12ac353 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_h=
ead *page_list,
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sc->nr_scanned++;
>>>
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (unlikely(!page_evi=
ctable(page)))
>>> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 got=
o activate_locked;
>>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto c=
ull_mlocked;
>>>
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!sc->may_unmap && =
page_mapped(page))
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 goto keep_locked;
>>> @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct lis=
t_head *page_list,
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 } else
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 list_add(&page->lru, &free_pages);
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
>>> -
>>> +cull_mlocked:
>>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page))
>>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =
try_to_free_swap(page);
>>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unlock_page(page);
>>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_add(&page->lru, &re=
t_pages);
>>> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
>>> =A0 activate_locked:
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* Not a candidate for=
 swapping, so reclaim swap space. */
>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page=
) && (mem_cgroup_swap_full(page) ||
>>>
>>>
>>>
>>> Regards,
>>> Pankaj
>>>
>>>
>>> From: Kirill Tkhai <ktkhai@virtuozzo.com>
>>> Sent: 14 March 2019 14:55:34
>>> To: Pankaj Suryawanshi; Michal Hocko
>>> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
>>> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>>>
>>>
>>> On 14.03.2019 11:52, Pankaj Suryawanshi wrote:
>>>>
>>>> I am using kernel version 4.14.65 (on Android pie [ARM]).
>>>>
>>>> No additional patches applied on top of vanilla.(Core MM).
>>>>
>>>> If=A0 I change in the vmscan.c as below patch, it will work.
>>>
>>> Sorry, but 4.14.65 does not have braces around trylock_page(),
>>> like in your patch below.
>>>
>>> See=A0=A0=A0=A0=A0=A0  https://git.kernel.org/pub/scm/linux/kernel/git/=
stable/linux.git/tree/mm/vmscan.c?h=3Dv4.14.65
>>>
>>> [...]
>>>
>>>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>>>> index be56e2e..2e51edc 100644
>>>>> --- a/mm/vmscan.c
>>>>> +++ b/mm/vmscan.c
>>>>> @@ -990,15 +990,17 @@ static unsigned long shrink_page_list(struct li=
st_head *page_list,
>>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 page =3D lru_to_p=
age(page_list);
>>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_del(&page->l=
ru);
>>>>>
>>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!trylock_page(pa=
ge)) {
>>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 goto keep;
>>>>> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
>>>
>>> ***********************************************************************=
***************************************************************************=
*********** eInfochips Business Disclaimer: This e-mail message and all att=
achments transmitted with it are=A0  intended=A0 solely for the use of the =
addressee and may contain legally privileged and confidential information. =
If the reader of this message is not the intended recipient, or an employee=
 or agent responsible for delivering this message to the intended recipient=
,=A0  you=A0 are hereby notified that any dissemination, distribution, copy=
ing, or other use of this message or its attachments is strictly prohibited=
. If you have received this message in error, please notify the sender imme=
diately by replying to this message and=A0  please=A0 delete it from your c=
omputer. Any views expressed in this message are those of the individual se=
nder unless otherwise stated. Company has taken enough precautions to preve=
nt the spread of viruses. However the company accepts no liability for any =
damage=A0  caused=A0 by any virus transmitted by this email. **************=
***************************************************************************=
********************************************************************
>>>
>>
>> =A0=A0=A0=A0=20
>>
>=A0=A0=A0=A0=20
>=20
    =

