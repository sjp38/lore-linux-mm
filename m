Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC6ECC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 06:05:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 651032184C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 06:05:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="gaDVm52k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 651032184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFD626B0273; Fri, 15 Mar 2019 02:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BACCB6B0274; Fri, 15 Mar 2019 02:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9B646B0275; Fri, 15 Mar 2019 02:05:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B3F26B0273
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 02:05:12 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id g6so10342228ywa.13
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 23:05:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=Ij7pgFfZeE2o3iJ00KCAjWgXYho9coqKEkdDoSzmM0A=;
        b=uDizgppm+hE4qdn+OPK499MjlNFwZyQuD87DWU0KGbKxbIAeiKoXHpbaElRq83kNCv
         uIw0fb6/Puk5a4wlOhxwCBl2fgFMyLTiyt/0O7rM0QA0dPrVimia8RTscBoU8Xsis+LE
         QXPKyMjFg4LgFqep+cncZbl63TFbkocfvkLbhLO5ee73cgHiexszgXnLpgCeNM70jMLl
         tUdloJIDIC+17/eb4xoV4jRdFxlNmOFHkDbhFSM4zCK07VXZ5tpIyoNge3hfwfKtdbvM
         mDRwgwBPb0nNQ4Js+TxVicnW/G/4ymWNDeBqQrD/T9F72ilIwtwgD6vQn4QVq8PxFk4p
         qVBg==
X-Gm-Message-State: APjAAAU1Qq919Ucmci9VMeenKqeBBx1qlxnLSM/rFglzCUKuC23X0jjU
	MgPetMsX7MGVWl96R/vgZQ8nCSC7GB12QZAAFjWN7930+NQ+m62YKi/Gnim/kTuz/ameruFsqnL
	hndJKlHMvQ7dO3oo+4KQwc2/xl0RiAHUzdEn8ph94r/DXEvH4XigNZjeCrVh2+TDVTA==
X-Received: by 2002:a25:b39a:: with SMTP id m26mr1529521ybj.220.1552629912194;
        Thu, 14 Mar 2019 23:05:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxY+YCWi9PYL33ZrCrsQ4oj4TaNJUdSnw58sDAvxnUnrxQ8XrJgV1pSC2c120mjAoeAKsQZ
X-Received: by 2002:a25:b39a:: with SMTP id m26mr1529485ybj.220.1552629911314;
        Thu, 14 Mar 2019 23:05:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552629911; cv=none;
        d=google.com; s=arc-20160816;
        b=k0Jn2LMIojUorqAZ3oPmmeLWv+6mrlVKE6stYM9aCvPkP0co3Pj/tgKrIsOxJuzHGs
         z2QHLW9T/zUlorWfgbgmpTExSp4O+1a1OoOUak6+wuvfvSAUjR2cp2gxjEFcxxTrV+G5
         x7tkB9bH9vo1NMEuq4pvJe4wZKV21o4+uUWwUndro+8rUOknkGdMLRY0rtfle3te+uvR
         pf/6OCWEDuopFdymP5z9jdqQEGVY9hqIE6iIK0T4PItEBblL7mDQ82N3/ARxbJ+Iy2k1
         zByX8xZbYC1o7+EYhvJG3/Bb2478Ci7Txksr/6FqJk3LJr+Lka/SUUAiALz7iZpMOuoq
         AplQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Ij7pgFfZeE2o3iJ00KCAjWgXYho9coqKEkdDoSzmM0A=;
        b=CzWF+neqHvh5igxXEZlnafh/NvjK2YZdVqZk9LYr8oTw+do4n01bjRfFdGqpXEOpse
         Wp9h1cTtlu1+5IexXFApcvnfirriOQ6uU6Prh/Xr5fIbSDfwomOw4mgUhQwabyavG1Dz
         NzDAfHuELwXhYWbJr5a+1qo7LhnTetWOzyj8dXtyL3ADv3RarwapqCjJWc3FORTjHj/1
         gAI0qeOpAikxrKJ/Pn2WNDLoEW4LQ4Nc55uSNWJLZRob6qt5fGpD6aYaIAppBn94vm1v
         gpiBxX4UjTxEie1hjy4QmatA9Fbm6zLjIjI8oBfm55wqCG2dL23ZV9LAW1m5b9v3N3J6
         6KIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=gaDVm52k;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.45 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320045.outbound.protection.outlook.com. [40.107.132.45])
        by mx.google.com with ESMTPS id i190si746798ywg.53.2019.03.14.23.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Mar 2019 23:05:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.45 as permitted sender) client-ip=40.107.132.45;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b=gaDVm52k;
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.45 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Ij7pgFfZeE2o3iJ00KCAjWgXYho9coqKEkdDoSzmM0A=;
 b=gaDVm52ka+qTzMi606pR7b6qO87ME6aylpLTFPvaf8b2i3XyKpHaiP4suwcCvYY2Zf2/BfPSPNSBiKbL5mZAsDSIaddFydCghRLoaOGY78QKjOrEBioTOE6sRwFJKf9QZCG+hmo+9S45lVoz3BCjwITzsDFDodkebn+yc4XEsTk=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB4217.apcprd02.prod.outlook.com (20.178.158.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Fri, 15 Mar 2019 06:05:06 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::3180:828f:84bc:ea3]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::3180:828f:84bc:ea3%4]) with mapi id 15.20.1686.021; Fri, 15 Mar 2019
 06:05:06 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
Thread-Topic: Re: [External] Re: vmscan: Reclaim unevictable pages
Thread-Index:
 AQHU2jnLyCfGly2dbEuVu40O8aA4saYKwYIOgAACnP2AAArTAIAAAt0egAAJfgCAABwNcoAAK5EogAESNQY=
Date: Fri, 15 Mar 2019 06:05:05 +0000
Message-ID:
 <SG2PR02MB3098AB587F4BFCD6B9D042FDE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098A05E09B0D3F3CB1C3B9BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098B751EC6B8E32806A42FBE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190314084120.GF7473@dhcp22.suse.cz>
 <SG2PR02MB309894F6D7DF9148846088F3E84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<226a92b9-94c5-b859-c54b-3aacad3089cc@virtuozzo.com>,<SG2PR02MB3098299456FB6AE2FD822C4CE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>,<SG2PR02MB30988333AD658F8124070ABEE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
In-Reply-To:
 <SG2PR02MB30988333AD658F8124070ABEE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 854f0f83-831c-480a-ca60-08d6a90c2c03
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB4217;
x-ms-traffictypediagnostic: SG2PR02MB4217:|SG2PR02MB4217:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <SG2PR02MB42179B04E04363C84D31EE83E8440@SG2PR02MB4217.apcprd02.prod.outlook.com>
x-forefront-prvs: 09778E995A
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(346002)(39850400004)(366004)(396003)(376002)(189003)(199004)(66574012)(7736002)(54906003)(305945005)(25786009)(78486014)(110136005)(4326008)(93886005)(33656002)(97736004)(6246003)(446003)(316002)(26005)(229853002)(68736007)(66066001)(2906002)(476003)(14454004)(74316002)(53546011)(6506007)(486006)(11346002)(44832011)(106356001)(186003)(55236004)(966005)(8936002)(5024004)(99286004)(8676002)(14444005)(256004)(7696005)(6306002)(71200400001)(102836004)(9686003)(71190400001)(105586002)(53936002)(6436002)(478600001)(86362001)(6116002)(3846002)(76176011)(5660300002)(81156014)(55016002)(52536014)(81166006);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB4217;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 dE574AWMVyvSXTzS7cWTg6gYGFgRn78PEeRkwDAmQOaDOu38qVq77G0FVxnCdaRuRiYbQFEFl9z+AV6BaEw7QaBoo2mb6kTokQbnHZxHyI+Z4fl1Cbj1xjB8J7KnGpGXCMXu4QdaTZpwIlNZ8g48hhK7rnpyhQqZ/cavvxaAlcmPBm4HUBYAGfUQSrQ4KymXxzvmoOHXoWrrSK/1gXwegjZpwU72WLTKPQ+pVAe+jD4XqFgPYxgXFKwUQpOy9dVP9oQ9JYFXJZ4uA0z3tY35HD8kMZo3qXjk3taVUTXLGF/QHrBjiWDKb/fQiXWiSGuFZIW5tDqIhCWCvnjlIjkTatw1nW7p9FNEnp1tAFuFqbgjuxSk3zgKHfkouD9iEUt6DYsQdJKaNdvJ8tkoztH2ArxNepcJif6w30srSni9Ogs=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 854f0f83-831c-480a-ca60-08d6a90c2c03
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Mar 2019 06:05:05.9118
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB4217
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


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

See    https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tre=
e/mm/vmscan.c?h=3Dv4.14.65

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

