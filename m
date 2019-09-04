Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92F71C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:19:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6063622CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 12:19:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6063622CED
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFA0A6B0006; Wed,  4 Sep 2019 08:19:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAA726B0007; Wed,  4 Sep 2019 08:19:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC0096B0008; Wed,  4 Sep 2019 08:19:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0161.hostedemail.com [216.40.44.161])
	by kanga.kvack.org (Postfix) with ESMTP id B9F046B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:19:22 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4CB90181AC9B6
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:19:22 +0000 (UTC)
X-FDA: 75897143364.30.home81_51b0684c53726
X-HE-Tag: home81_51b0684c53726
X-Filterd-Recvd-Size: 3473
Received: from huawei.com (szxga08-in.huawei.com [45.249.212.255])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 12:19:21 +0000 (UTC)
Received: from DGGEML401-HUB.china.huawei.com (unknown [172.30.72.53])
	by Forcepoint Email with ESMTP id 409C5B175537DB1266F5;
	Wed,  4 Sep 2019 20:19:16 +0800 (CST)
Received: from DGGEML512-MBX.china.huawei.com ([169.254.2.60]) by
 DGGEML401-HUB.china.huawei.com ([fe80::89ed:853e:30a9:2a79%31]) with mapi id
 14.03.0439.000; Wed, 4 Sep 2019 20:19:11 +0800
From: sunqiuyang <sunqiuyang@huawei.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Thread-Topic: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Thread-Index: AQHVYi7CKRiSaGuZ20KJAhdeZXNZ4qcZaW+AgAFf/lT//8LbAIAAjGWd//+OTACAAMgqDg==
Date: Wed, 4 Sep 2019 12:19:11 +0000
Message-ID: <157FC541501A9C4C862B2F16FFE316DC190C3402@dggeml512-mbx.china.huawei.com>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>
 <20190903131737.GB18939@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C1B09@dggeml512-mbx.china.huawei.com>
 <20190904063836.GD3838@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C2EBD@dggeml512-mbx.china.huawei.com>,<20190904081408.GF3838@dhcp22.suse.cz>
In-Reply-To: <20190904081408.GF3838@dhcp22.suse.cz>
Accept-Language: en-US, zh-CN
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.177.249.127]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

=0A=
________________________________________=0A=
From: Michal Hocko [mhocko@kernel.org]=0A=
Sent: Wednesday, September 04, 2019 16:14=0A=
To: sunqiuyang=0A=
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org=0A=
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of no=
n-LRU movable pages=0A=
=0A=
Do not top post please=0A=
=0A=
On Wed 04-09-19 07:27:25, sunqiuyang wrote:=0A=
> isolate_migratepages_block() from another thread may try to isolate the p=
age again:=0A=
>=0A=
> for (; low_pfn < end_pfn; low_pfn++) {=0A=
>   /* ... */=0A=
>   page =3D pfn_to_page(low_pfn);=0A=
>  /* ... */=0A=
>   if (!PageLRU(page)) {=0A=
>     if (unlikely(__PageMovable(page)) && !PageIsolated(page)) {=0A=
>         /* ... */=0A=
>         if (!isolate_movable_page(page, isolate_mode))=0A=
>           goto isolate_success;=0A=
>       /*... */=0A=
> isolate_success:=0A=
>      list_add(&page->lru, &cc->migratepages);=0A=
>=0A=
> And this page will be added to another list.=0A=
> Or, do you see any reason that the page cannot go through this path?=0A=
=0A=
The page shouldn't be __PageMovable after the migration is done. All the=0A=
state should have been transfered to the new page IIUC.=0A=
=0A=
----=0A=
I don't see where page->mapping is modified after the migration is done. =
=0A=
=0A=
Actually, the last comment in move_to_new_page() says,=0A=
"Anonymous and movable page->mapping will be cleard by=0A=
free_pages_prepare so don't reset it here for keeping=0A=
the type to work PageAnon, for example. "=0A=
=0A=
Or did I miss something? Thanks,=0A=
=0A=
--=0A=
Michal Hocko=0A=
SUSE Labs=0A=

