Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C34BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:09:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3789020854
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 09:09:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=eInfochipsIndia.onmicrosoft.com header.i=@eInfochipsIndia.onmicrosoft.com header.b="K52nwug/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3789020854
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=einfochips.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB76F6B0003; Mon, 18 Mar 2019 05:09:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C408D6B0006; Mon, 18 Mar 2019 05:09:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABA986B0007; Mon, 18 Mar 2019 05:09:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6500C6B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 05:09:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v3so4204226pgk.9
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 02:09:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=Mmcu9NkRQ+AJ9r2kGJSeNDf3M1wKhjrgDXMO84Au2Cg=;
        b=VUP8wmvp60i9E29gFUGRyGDmDj2Px9boD3J6r0T3q5dedwvy0dXH0Y8tMaFVlu5Lit
         +jCM541+s3myUYdkMANKhIwWlkfiNX3QU4Ip9IotRlqluBC1gy1F3yjQoWMTyHIeJ7IA
         YS1BP0krb0bOv3McgKkCC5OMoIYmPkmBC8NizsQwDEzZdnM77skHKyP99dVLF2KqmYTY
         t+I2sFH93DarwbG8HMDivoPn201jfETJnTXj952I1SSfnvCFEhJCdqibkNNregdn90yz
         AnEZFm+5/61FqDj9Z9zlgJbIZhGQW5d4+hO3til6nBwfb99uuuK9IGZCBPA8YlE4mwe2
         2u5Q==
X-Gm-Message-State: APjAAAX0+cpoNwb6BHciai/iGjInaKpwo24AJJi05LP8LdV+EsLt/2+f
	jTC5NrbVhWSb6F+JSmoYGdtpWG1ZU7zCrAQur7DL/d9FLlSFOv/+GnHIWnBtXRSFpY/yS5HErlX
	AlBxCahu5fhuRZAlsuAnwwwpHcw984dTgpz/OozesiN0PUoNEqEJtVh//bfwYkf4tBQ==
X-Received: by 2002:aa7:9141:: with SMTP id 1mr17966359pfi.38.1552900157945;
        Mon, 18 Mar 2019 02:09:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7tV1vnqfYIBukLesGmwZK4tTfR88FQyyq8o25mePGYDwCnjpDROHAmVTkqLkDAt8AqeuC
X-Received: by 2002:aa7:9141:: with SMTP id 1mr17966252pfi.38.1552900156598;
        Mon, 18 Mar 2019 02:09:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552900156; cv=none;
        d=google.com; s=arc-20160816;
        b=ve8hYkTYy2Pb0er1R86LV0itr8EtOJ6dTu4lc7so1U32SaetuU8/JCQwlAT2tUbgsm
         hzEn4pKAEij3siXgBGzeRNr2gMbkiikpcCxhh0eMg1TuyQcfmH6shm28HnJf5jd8kNqE
         3S9Rb5pyu/W7Yc3/NwuSr8iBB1vOgmDwdjVzdFGRCnoqGKXt6hOFS2kv23Yuiw87rdnT
         LtfTNgxqu8S/PqJKnEHstVlGZ9XeP3MFjQz0d6eCmhKUCUNnF9AWQO4dBdXPPzXv4m3C
         7YXxg3Fm9yRiv6YxonEXTV2eQVnK4sAuEff4YUgDe88+5681a5WpZqOurWC8jWmJKA16
         krJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=Mmcu9NkRQ+AJ9r2kGJSeNDf3M1wKhjrgDXMO84Au2Cg=;
        b=TVftNZSU3Zr8Lctb1cxk8cCrBkDMr+izzsX+Vb529ZlZLJaw80xgZjnACBt9TXMijB
         LK4ygBIXZW2Tc9UuGDtRp31RIGCY7n8oeOHNVXU4NQPKA3mD6j71l3wnCFw7LWQRBW1j
         CkYxYKG/NDMu59rYvViJbrn7rxmYgTV4u7mMHY73ytq6PRkHsJddMesq8GWy98YQapjm
         SPRUvQt3LkTCCy8EKkX/uZRPbILig6eyeEIhlSrSoa2Bmx5B+fvpBSwluCtIa+MW9j+B
         kelj8JGfFezRbLP0FCn13IMa/mCERWSKcqNKKkvjnOmvI1mKpNQUV2J1zn1YKIpm+QcN
         04Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="K52nwug/";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.85 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
Received: from APC01-PU1-obe.outbound.protection.outlook.com (mail-eopbgr1320085.outbound.protection.outlook.com. [40.107.132.85])
        by mx.google.com with ESMTPS id w8si8746649plp.349.2019.03.18.02.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Mar 2019 02:09:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.85 as permitted sender) client-ip=40.107.132.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@eInfochipsIndia.onmicrosoft.com header.s=selector1-einfochips-com header.b="K52nwug/";
       spf=pass (google.com: domain of pankaj.suryawanshi@einfochips.com designates 40.107.132.85 as permitted sender) smtp.mailfrom=pankaj.suryawanshi@einfochips.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=eInfochipsIndia.onmicrosoft.com; s=selector1-einfochips-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Mmcu9NkRQ+AJ9r2kGJSeNDf3M1wKhjrgDXMO84Au2Cg=;
 b=K52nwug/IYzt9kQ1reIJgvMzSKdKsbQKf2IaBCUzPIRjyP3KzIgePhzcskqELxZAu4xl2s+Yt5S7xUqhdZ3Cq1EzOpFp0pCvBt3kiwC1amX4skYIipiTc1tRppwycXKakqN+WU/8xHmiqaB32rUOTY9e4opYWHZZ+DpHS6UgP3I=
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com (20.177.88.78) by
 SG2PR02MB3450.apcprd02.prod.outlook.com (20.177.82.138) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.14; Mon, 18 Mar 2019 09:09:11 +0000
Received: from SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b]) by SG2PR02MB3098.apcprd02.prod.outlook.com
 ([fe80::f432:20e4:2d22:e60b%4]) with mapi id 15.20.1709.015; Mon, 18 Mar 2019
 09:09:11 +0000
From: Pankaj Suryawanshi <pankaj.suryawanshi@einfochips.com>
To: Vlastimil Babka <vbabka@suse.cz>, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Michal Hocko <mhocko@kernel.org>, "aneesh.kumar@linux.ibm.com"
	<aneesh.kumar@linux.ibm.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"minchan@kernel.org" <minchan@kernel.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "khandual@linux.vnet.ibm.com"
	<khandual@linux.vnet.ibm.com>, "hillf.zj@alibaba-inc.com"
	<hillf.zj@alibaba-inc.com>
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
Thread-Topic: [External] Re: vmscan: Reclaim unevictable pages
Thread-Index: AQHU3WaYCAMWaFadm0e/0+hd2XPYGaYRGYZ/
Date: Mon, 18 Mar 2019 09:09:11 +0000
Message-ID:
 <SG2PR02MB309841EA4764E675D4649139E8470@SG2PR02MB3098.apcprd02.prod.outlook.com>
References:
 <SG2PR02MB3098A05E09B0D3F3CB1C3B9BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB309806967AE91179CAFEC34BE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098B751EC6B8E32806A42FBE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <20190314084120.GF7473@dhcp22.suse.cz>
 <SG2PR02MB309894F6D7DF9148846088F3E84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <226a92b9-94c5-b859-c54b-3aacad3089cc@virtuozzo.com>
 <SG2PR02MB3098299456FB6AE2FD822C4CE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB30988333AD658F8124070ABEE84B0@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098AB587F4BFCD6B9D042FDE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>
 <SG2PR02MB3098E6F2C4BAEB56AE071EDCE8440@SG2PR02MB3098.apcprd02.prod.outlook.com>,<0b86dbca-cbc9-3b43-e3b9-8876bcc24f22@suse.cz>
In-Reply-To: <0b86dbca-cbc9-3b43-e3b9-8876bcc24f22@suse.cz>
Accept-Language: en-GB, en-US
Content-Language: en-GB
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pankaj.suryawanshi@einfochips.com; 
x-originating-ip: [14.98.130.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1b17ae03-8d82-41cf-3dfc-08d6ab8162cc
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600127)(711020)(4605104)(4534185)(7168020)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SG2PR02MB3450;
x-ms-traffictypediagnostic: SG2PR02MB3450:|SG2PR02MB3450:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs:
 <SG2PR02MB3450BFEAB9ADEA390CEA39B7E8470@SG2PR02MB3450.apcprd02.prod.outlook.com>
x-forefront-prvs: 098076C36C
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(396003)(376002)(39840400004)(346002)(366004)(136003)(54534003)(189003)(199004)(8936002)(7736002)(2906002)(81156014)(81166006)(9686003)(93886005)(305945005)(6306002)(74316002)(55016002)(11346002)(6116002)(110136005)(99286004)(33656002)(229853002)(478600001)(25786009)(5660300002)(486006)(6436002)(316002)(476003)(54906003)(97736004)(102836004)(446003)(68736007)(52536014)(3846002)(14454004)(966005)(2501003)(76176011)(66574012)(71190400001)(66066001)(71200400001)(86362001)(6506007)(53546011)(55236004)(186003)(26005)(106356001)(4326008)(14444005)(44832011)(256004)(105586002)(6246003)(5024004)(78486014)(7696005)(53936002)(8676002);DIR:OUT;SFP:1101;SCL:1;SRVR:SG2PR02MB3450;H:SG2PR02MB3098.apcprd02.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: einfochips.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 mAzQWBE32OxvnBZLQr3efBzLXx8U+O7SZZpj823P0/IF42aJaUUNdw7uMGzNYbwIwhcCQKm5WLJvQFWJVE6HWUpCBYAu/k1Ho4Mb7oTdV5N09Vnp1kT+wMhRGWwRws6mZvhamWRcQlEzdgmHkrKy704OUyK6D9PF6IclU+6kG8QqZ06NNn3FI6ycrXGHpUDcMO8lBnda5csjI2Sc8KKFK2A5Vd4wKwjD7S5stIXh4VkUT0FV5qX8Ane13SkbpJz3lFVmMN1eE15Md+hRMp+TZYSKgnKsLxNkDzAQ5KgOkCStOx49AjLDEiEwsU4mss95SRywF0g40AC4wRu7Th8iOU7eJQ7+7z3i22dQNfxxCDIpXJ0icMwYCM5Nye2k9gk6ychN05dGA2tvX6aKkI+e6bquFG8KN/1uaOAwjChNEXk=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: einfochips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1b17ae03-8d82-41cf-3dfc-08d6ab8162cc
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Mar 2019 09:09:11.3815
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0adb040b-ca22-4ca6-9447-ab7b049a22ff
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SG2PR02MB3450
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hello

shrink_page_list() returns , number of pages reclaimed, when pages is unevi=
ctable it returns VM_BUG_ON_PAGE(PageLRU(page) || PageUnevicatble(page),pag=
e);

We can add the unevictable pages in reclaim list in shrink_page_list(), ret=
urn total number of reclaim pages including unevictable pages, let the call=
er handle unevictable pages.

I think the problem is shrink_page_list is awkard. If page is unevictable i=
t goto activate_locked->keep_locked->keep lables, keep lable list_add the u=
nevictable pages and throw the VM_BUG instead of passing it to caller while=
 it relies on caller for non-reclaimed-non-unevictable  page's putback.
I think we can make it consistent so that shrink_page_list could return non=
-reclaimed pages via page_list and caller can handle it. As an advance, it =
could try to migrate mlocked pages without retrial.


Below is the issue of CMA_ALLOC of large size buffer : (Kernel version - 4.=
14.65 (On Android pie [ARM])).

[=A0=A0 24.718792] page dumped because: VM_BUG_ON_PAGE(PageLRU(page) || Pag=
eUnevictable(page))
[=A0=A0 24.726949] page->mem_cgroup:bd008c00
[=A0=A0 24.730693] ------------[ cut here ]------------
[=A0=A0 24.735304] kernel BUG at mm/vmscan.c:1350!
[=A0=A0 24.739478] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM


Below is the patch which solved this issue :

diff --git a/mm/vmscan.c b/mm/vmscan.c
index be56e2e..12ac353 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_head =
*page_list,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sc->nr_scanned++;
=A0
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (unlikely(!page_evictable(=
page)))
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto ac=
tivate_locked;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto cull_=
mlocked;
=A0
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!sc->may_unmap && page_ma=
pped(page))
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto =
keep_locked;
@@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct list_he=
ad *page_list,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 } else
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_=
add(&page->lru, &free_pages);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
-
+cull_mlocked:
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page))
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 try_=
to_free_swap(page);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unlock_page(page);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_add(&page->lru, &ret_pa=
ges);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
=A0activate_locked:
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* Not a candidate for swappi=
ng, so reclaim swap space. */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page) && (m=
em_cgroup_swap_full(page) ||




It fixes the below issue.

1. Large size buffer allocation using cma_alloc successful with unevictable=
 pages.

cma_alloc of current kernel will fail due to unevictable page

Please let me know if anything i am missing.

Regards,
Pankaj
 =20
From: Vlastimil Babka <vbabka@suse.cz>
Sent: 18 March 2019 14:12:50
To: Pankaj Suryawanshi; Kirill Tkhai; Michal Hocko; aneesh.kumar@linux.ibm.=
com
Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org; k=
handual@linux.vnet.ibm.com; hillf.zj@alibaba-inc.com
Subject: Re: [External] Re: vmscan: Reclaim unevictable pages
=A0=20

On 3/15/19 11:11 AM, Pankaj Suryawanshi wrote:
>=20
> [ cc Aneesh kumar, Anshuman, Hillf, Vlastimil]

Can you send a proper patch with changelog explaining the change? I
don't know the context of this thread.

> From: Pankaj Suryawanshi
> Sent: 15 March 2019 11:35:05
> To: Kirill Tkhai; Michal Hocko
> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org; linux-mm@kvack.org
> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>=20
>=20
>=20
> [ cc linux-mm ]
>=20
>=20
> From: Pankaj Suryawanshi
> Sent: 14 March 2019 19:14:40
> To: Kirill Tkhai; Michal Hocko
> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>=20
>=20
>=20
> Hello ,
>=20
> Please ignore the curly braces, they are just for debugging.
>=20
> Below is the updated patch.
>=20
>=20
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index be56e2e..12ac353 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -998,7 +998,7 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 sc->nr_scanned++;
>=20
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (unlikely(!page_evicta=
ble(page)))
> -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto =
activate_locked;
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 goto cul=
l_mlocked;
>=20
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!sc->may_unmap && pag=
e_mapped(page))
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 g=
oto keep_locked;
> @@ -1331,7 +1331,12 @@ static unsigned long shrink_page_list(struct list_=
head *page_list,
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 } else
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 l=
ist_add(&page->lru, &free_pages);
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
> -
> +cull_mlocked:
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page))
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 tr=
y_to_free_swap(page);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 unlock_page(page);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_add(&page->lru, &ret_=
pages);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 continue;
>=A0 activate_locked:
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /* Not a candidate for sw=
apping, so reclaim swap space. */
>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (PageSwapCache(page) &=
& (mem_cgroup_swap_full(page) ||
>=20
>=20
>=20
> Regards,
> Pankaj
>=20
>=20
> From: Kirill Tkhai <ktkhai@virtuozzo.com>
> Sent: 14 March 2019 14:55:34
> To: Pankaj Suryawanshi; Michal Hocko
> Cc: linux-kernel@vger.kernel.org; minchan@kernel.org
> Subject: Re: Re: [External] Re: vmscan: Reclaim unevictable pages
>=20
>=20
> On 14.03.2019 11:52, Pankaj Suryawanshi wrote:
>>
>> I am using kernel version 4.14.65 (on Android pie [ARM]).
>>
>> No additional patches applied on top of vanilla.(Core MM).
>>
>> If=A0 I change in the vmscan.c as below patch, it will work.
>=20
> Sorry, but 4.14.65 does not have braces around trylock_page(),
> like in your patch below.
>=20
> See=A0=A0=A0=A0  https://git.kernel.org/pub/scm/linux/kernel/git/stable/l=
inux.git/tree/mm/vmscan.c?h=3Dv4.14.65
>=20
> [...]
>=20
>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> index be56e2e..2e51edc 100644
>>> --- a/mm/vmscan.c
>>> +++ b/mm/vmscan.c
>>> @@ -990,15 +990,17 @@ static unsigned long shrink_page_list(struct list=
_head *page_list,
>>>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 page =3D lru_to_page=
(page_list);
>>>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 list_del(&page->lru)=
;
>>>
>>>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (!trylock_page(page)=
) {
>>>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 goto keep;
>>>=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
>=20
> *************************************************************************=
***************************************************************************=
********* eInfochips Business Disclaimer: This e-mail message and all attac=
hments transmitted with it are intended  solely for the use of the addresse=
e and may contain legally privileged and confidential information. If the r=
eader of this message is not the intended recipient, or an employee or agen=
t responsible for delivering this message to the intended recipient, you  a=
re hereby notified that any dissemination, distribution, copying, or other =
use of this message or its attachments is strictly prohibited. If you have =
received this message in error, please notify the sender immediately by rep=
lying to this message and please  delete it from your computer. Any views e=
xpressed in this message are those of the individual sender unless otherwis=
e stated. Company has taken enough precautions to prevent the spread of vir=
uses. However the company accepts no liability for any damage caused  by an=
y virus transmitted by this email. ****************************************=
***************************************************************************=
******************************************
>=20

    =

