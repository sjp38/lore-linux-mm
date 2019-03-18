Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F8FAC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 07:45:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 015D820828
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 07:45:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="B/qkxCgw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 015D820828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88BAA6B0007; Mon, 18 Mar 2019 03:45:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83A456B0008; Mon, 18 Mar 2019 03:45:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72A716B000A; Mon, 18 Mar 2019 03:45:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30CE66B0007
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 03:45:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f1so7768490pgv.12
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 00:45:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=vobyGWjfJEle45qjcEXi8CYcMoBBsBBJ9JPggHTJ1w8=;
        b=IJ+UR0J0Mvq4WZh1/6tpRfXY2i0KL01Jp8tvoe1+wCKjpJWOHgCTAThtKPasA0faH1
         bDZtbHBMK1ZR+DUw9F81047Nq3UMc/teWz+kw7EdlL7kI1GBeseE2Ooncpx3B/2UbsLU
         gvnsZ0sgXSm+66an9MoNjaAgxY622PAgHY+oZ77g1l123E/PuRK4IALiY2bm+l7JaXmT
         UPOka+pLN4D/VAjZ3aF7eI7hejB5GOqspdN6VZVq3Mn81gSHZlDhv8a2hPH7Z0Tlrxc4
         PFrSdmIfiyqR4vLcYLk7XLr9l+COdzk4577gIEPmzxeuYi/6oT3mr/8wMhOQmiTVBwgx
         croA==
X-Gm-Message-State: APjAAAU1WiPeCbrVrqYXNIhmBKPzaDoIMHGLaR1bHu253Hiyv+Sc+DXU
	JsKwOLsJbcqTkzBLoaO9Khtf6JoRfUkb0qzJRFW8ixRzVjJIbfPZLSa/f9HGtOVf2lsD7rQZLCJ
	qeR/6sDO7wWtgNDNKHhySIxku+ET+Lv1RcsFXyU2HuyKsCO6mYp9sKrlJEw99KW3dBA==
X-Received: by 2002:a63:78ca:: with SMTP id t193mr16524407pgc.253.1552895129684;
        Mon, 18 Mar 2019 00:45:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEol6gOkS7fP7OoUFsO5I/LWp/G/ETmgM7Q3gZgS7CNGEwCJerPCjszZB57zfx/16xD6DX
X-Received: by 2002:a63:78ca:: with SMTP id t193mr16524222pgc.253.1552895125970;
        Mon, 18 Mar 2019 00:45:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552895125; cv=none;
        d=google.com; s=arc-20160816;
        b=V40kx2Sh1uJjxOJW3qCkI7NdDrUapUSjLoSVDntjnzgE8v+dTABh+l/TJGPhoqIKH2
         oU79lIgohdD1DVaSdI6nS6CvjPa9rC5EwkyzvVgGkI90pdLftf/LGnCxETAJkOGtLP01
         yzv3jFTsXsCrOTCjBUuYW29M34gVJJvnYitEfrH2z/q3DA1sJ1D9BFLjtOrcBAS+IAQH
         x+0rolJo8Bv8I85CyuNSuseOQp0ZgwuaZDKNSgrJjyFZ4gc7Sk+ZxVqHlZthYryRfe/k
         4OWCEo1cvXwbaiLjGgHMCnyE6mKX5gJR/M7dtQHEIZCcUwfPNqDUMu6EAmyPVOX8S1yo
         D8Pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=vobyGWjfJEle45qjcEXi8CYcMoBBsBBJ9JPggHTJ1w8=;
        b=pncwycwizwCL/jzkbFvOq8dcnrvQZxdKkKVR8YkyV9LexrY/xvhI++LU8Y+KlbxCYO
         xqtDnWX9WKJfXeP5GI1/F8oUbAhiVdIrJ002Nl3+Cxd+HmOnAck8Zq18pk+L91gyzEOd
         oAlZyP5iXabR40wWLcV6a+5LnukYWBd0EQW0Z9FyPqt6cyH/gYEYrVaMHOpTluJfoFxf
         Ca5yajXKnYzRJdOWASlLXFYYTdy8YiwUB8dXOSZ7ILbxOlIS16OzEQuhQwHL2oWv6Gm2
         XfOTaHbGUeLeJZBXqClmpyvTvQv2j8+WTo0ks2anDzo4cueBojnP0yhhvIGzrVsoUBJ2
         DAxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="B/qkxCgw";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.53 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-SG2-obe.outbound.protection.outlook.com (mail-eopbgr1310053.outbound.protection.outlook.com. [40.107.131.53])
        by mx.google.com with ESMTPS id q12si8934115pli.428.2019.03.18.00.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 00:45:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.53 as permitted sender) client-ip=40.107.131.53;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="B/qkxCgw";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.131.53 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vobyGWjfJEle45qjcEXi8CYcMoBBsBBJ9JPggHTJ1w8=;
 b=B/qkxCgw/0inzSqvbD1IVSbMCCGVzxmdglxkTp04aP2YLku5H5LD30gGnAdq2HuS/nc564qTAKIkc1GJZ9b+8cwQjEFQQThVjAtpdFXVtgRqKFnj8KoPul0dS7yrxRUCajGlFf83hDjflPeEjDLl1Yk72+KRPPkgwzDtv1v5js0=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3909.apcprd02.prod.outlook.com (20.178.154.144) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.13; Mon, 18 Mar 2019 07:45:22 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Mon, 18 Mar 2019
 07:45:22 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>,
	"aneesh.kumar@linux.ibm.com" <aneesh.kumar@linux.ibm.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "khandual@linux.vnet.ibm.com"
	<khandual@linux.vnet.ibm.com>, "vbabka@suse.cz" <vbabka@suse.cz>
Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
Thread-Topic: Re: [External] Re: vmscan: Reclaim unevictable pages
Thread-Index:
 AQHU2jnLyCfGly2dbEuVu40O8aA4saYKwYIOgAACnP2AAArTAIAAAt0egAAJfgCAABwNcoAAK5EogAESNQaAAERN0oAEgdeU
Date: Mon, 18 Mar 2019 07:45:22 +0000
Message-ID:
 <SG2PR02MB3098361719B67448CB6FF28CE8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098A05E09B0D3F3CB1C3B9BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098B751EC6B8E32806A42FBE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190314084120.GF7473@dhcp22.suse.cz>
 <SG2PR02MB309894F6D7DF9148846088F3E84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<226a92b9-94c5-b859-c54b-3aacad3089cc@virtuozzo.com>,<SG2PR02MB3098299456FB6AE2FD822C4CE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<SG2PR02MB30988333AD658F8124070ABEE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<SG2PR02MB3098AB587F4BFCD6B9D042FDE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>,<SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
In-Reply-To:
 <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: d083cfe8-4f1a-4164-3f4e-08d6ab75ad2c
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3909;
x-ms-traffictypediagnostic: SG2PR02MB3909:|SG2PR02MB3909:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <SG2PR02MB390986D34F78486EA48056FDE8470@SG2PR02MB3909.apcprd02.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(366004)(396003)(39840400004)(136003)(376002)(346002)(189003)(199004)(93886005)(66066001)(229853002)(14454004)(966005)(4326008)(86362001)(44832011)(6246003)(2501003)(6306002)(106356001)(105586002)(55016002)(25786009)(478600001)(6436002)(53936002)(9686003)(486006)(33656002)(14444005)(256004)(476003)(8936002)(5024004)(11346002)(446003)(52536014)(66574012)(78486014)(3846002)(5660300002)(99286004)(102836004)(53546011)(6506007)(186003)(7696005)(7736002)(71190400001)(71200400001)(26005)(55236004)(76176011)(68736007)(81166006)(8676002)(81156014)(97736004)(54906003)(110136005)(74316002)(6116002)(305945005)(2906002)(316002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3909;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 +nr78HtQ8CV7T9N0M3tkKghB2qIpzjnMZKcMSt9JRk3nPyaD2LZ5KoQNRYMoeVULYfBB9M02KmNeb2kPlyg/xe53WTXFKHs+2aEDOMYUFQML8LEgSitfbnAwhUsMmkA/8m2l9k+2AWLf6DsgLqbUe+NNHnZ4QLePT70tEtt47IaH3XbOXpfLX8iqio2zs/13w9Ix37exPpBHDgjBXmEMg2GGHH+pKzX6Ewf9q2G5XPD+6yWmAc+BbtUAcfV5ndXrClbL1IsZnDc7hXApR5TJEwG603UqE+f0Y1tPPwiJe5s9AhXqwegGBqgSOR2R9GZnde9X+d1IPQ46YNcWCuhVuIYqFGNGAxe2EyU2yAbclpWSWLM7Z40F7czIYwn6EkhLoTNHZt4oslzvwvvUP1EJuKi3ak89o1Sf/FjzjmuUhN8=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d083cfe8-4f1a-4164-3f4e-08d6ab75ad2c
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 07:45:22.2043
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3909
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


It fixes the below issue.

1. Large size buffer allocation using cma_alloc successful with unevictable=
 pages.

cma_alloc of current kernel will fail due to unevictable pages.

Solved the below issue of cma_alloc

---------------------------------------------------------------------------=
--------------------------------------------------------------
 [   24.718792] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || PageUn=
evictable(page))
 [   24.726949] page->mem_cgroup:bd008c00
 [   24.730693] ------------[ cut here ]------------
 [   24.735304] kernel BUG at mm/vmscan.c:1350!
 [   24.739478] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
---------------------------------------------------------------------------=
--------------------------------------------------------------


From: Pankaj Suryawanshi
Sent: 15 March 2019 15:41:57
To: Kirill Tkhai; Michal Hocko; aneesh.kumar@linux.ibm.com
Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org; k=
handual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com; vbabka@suse.cz
Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages



[ cc Aneesh kumar, Anshuman, Hillf, Vlastimil]

From: Pankaj Suryawanshi
Sent: 15 March 2019 11:35:05
To: Kirill Tkhai; Michal Hocko
Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org
Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages



[ cc linux-mm ]


From: Pankaj Suryawanshi
Sent: 14 March 2019 19:14:40
To: Kirill Tkhai; Michal Hocko
Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages



Hello ,

Please ignore the curly braces, they are just for debugging.

Below is the updated patch.


diff --git a/mm/vmscan.c b/mm/vmscan.c
index be56e2e..12ac353 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_head =
*page_list,
                sc->nr_scanned++;

                if (unlikely(!page_evictable(page)))
-                       goto activate_locked;
+                      goto cull_mlocked;

                if (!sc->may_unmap && page_mapped(page))
                        goto keep_locked;
@@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct list_he=
ad *page_list,
                } else
                        list_add(&page->lru, &free_pages);
                continue;
-
+cull_mlocked:
+                if (PageSwapCache(page))
+                        try_to_free_swap(page);
+                unlock_page(page);
+                list_add(&page->lru, &ret_pages);
+                continue;
 activate_locked:
                /* Not a candidate for swapping, so reclaim swap space. */
                if (PageSwapCache(page) && (mem_cgroup_swap_full(page) ||



Regards,
Pankaj


From: Kirill Tkhai <ktkhai@virtuozzo.com>
Sent: 14 March 2019 14:55:34
To: Pankaj Suryawanshi; Michal Hocko
Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages


On 14.03.2019 11:52, Pankaj Suryawanshi wrote:
>
> I am using kernel version 4.14.65 (on Android pie [ARM]).
>
> No additional patches applied on top of vanilla.(Core MM).
>
> If  I change in the vmscan.c as below patch, it will work.

Sorry, but 4.14.65 does not have braces around trylock_page(),
like in your patch below.

See      https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/t=
ree/mm/vmscan.c?h=3Dv4.14.65

[...]

>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index be56e2e..2e51edc 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -990,15 +990,17 @@ static unsigned long shrink_page_list(struct list_=
head *page_list,
>>                  page =3D lru_to_page(page_list);
>>                  list_del(&page->lru);
>>
>>                 if (!trylock_page(page)) {
>>                          goto keep;
>>                 }

***************************************************************************=
***************************************************************************=
******* eInfochips Business Disclaimer: This e-mail message and all attachm=
ents transmitted with it are intended solely for the use of the addressee a=
nd may contain legally privileged and confidential information. If the read=
er of this message is not the intended recipient, or an employee or agent r=
esponsible for delivering this message to the intended recipient, you are h=
ereby notified that any dissemination, distribution, copying, or other use =
of this message or its attachments is strictly prohibited. If you have rece=
ived this message in error, please notify the sender immediately by replyin=
g to this message and please delete it from your computer. Any views expres=
sed in this message are those of the individual sender unless otherwise sta=
ted. Company has taken enough precautions to prevent the spread of viruses.=
 However the company accepts no liability for any damage caused by any viru=
s transmitted by this email. **********************************************=
***************************************************************************=
************************************

