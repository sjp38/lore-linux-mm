Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94122C3A5AB
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:27:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 568F022CEA
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 07:27:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 568F022CEA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01C076B0003; Wed,  4 Sep 2019 03:27:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE7A86B0006; Wed,  4 Sep 2019 03:27:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFCC66B0007; Wed,  4 Sep 2019 03:27:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0117.hostedemail.com [216.40.44.117])
	by kanga.kvack.org (Postfix) with ESMTP id C06F26B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 03:27:31 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 6B4DA824CA36
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:27:31 +0000 (UTC)
X-FDA: 75896407902.14.page00_76c5faf5af39
X-HE-Tag: page00_76c5faf5af39
X-Filterd-Recvd-Size: 4025
Received: from huawei.com (szxga03-in.huawei.com [45.249.212.189])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 07:27:30 +0000 (UTC)
Received: from dggeml406-hub.china.huawei.com (unknown [172.30.72.56])
	by Forcepoint Email with ESMTP id 09746421599CFEE9ECB1;
	Wed,  4 Sep 2019 15:27:27 +0800 (CST)
Received: from DGGEML422-HUB.china.huawei.com (10.1.199.39) by
 dggeml406-hub.china.huawei.com (10.3.17.50) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Wed, 4 Sep 2019 15:27:26 +0800
Received: from DGGEML512-MBX.china.huawei.com ([169.254.2.60]) by
 dggeml422-hub.china.huawei.com ([10.1.199.39]) with mapi id 14.03.0439.000;
 Wed, 4 Sep 2019 15:27:25 +0800
From: sunqiuyang <sunqiuyang@huawei.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Thread-Topic: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Thread-Index: AQHVYi7CKRiSaGuZ20KJAhdeZXNZ4qcZaW+AgAFf/lT//8LbAIAAjGWd
Date: Wed, 4 Sep 2019 07:27:25 +0000
Message-ID: <157FC541501A9C4C862B2F16FFE316DC190C2EBD@dggeml512-mbx.china.huawei.com>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>
 <20190903131737.GB18939@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C1B09@dggeml512-mbx.china.huawei.com>,<20190904063836.GD3838@dhcp22.suse.cz>
In-Reply-To: <20190904063836.GD3838@dhcp22.suse.cz>
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

isolate_migratepages_block() from another thread may try to isolate the pag=
e again:=0A=
=0A=
for (; low_pfn < end_pfn; low_pfn++) {=0A=
  /* ... */=0A=
  page =3D pfn_to_page(low_pfn);=0A=
 /* ... */=0A=
  if (!PageLRU(page)) {=0A=
    if (unlikely(__PageMovable(page)) && !PageIsolated(page)) {=0A=
        /* ... */=0A=
        if (!isolate_movable_page(page, isolate_mode))=0A=
          goto isolate_success;=0A=
      /*... */=0A=
isolate_success:=0A=
     list_add(&page->lru, &cc->migratepages);=0A=
=0A=
And this page will be added to another list.=0A=
Or, do you see any reason that the page cannot go through this path?=0A=
________________________________________=0A=
From: Michal Hocko [mhocko@kernel.org]=0A=
Sent: Wednesday, September 04, 2019 14:38=0A=
To: sunqiuyang=0A=
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org=0A=
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of no=
n-LRU movable pages=0A=
=0A=
On Wed 04-09-19 02:18:38, sunqiuyang wrote:=0A=
> The isolate path of non-lru movable pages:=0A=
>=0A=
> isolate_migratepages_block=0A=
>       isolate_movable_page=0A=
>               trylock_page=0A=
>               // if PageIsolated, goto out_no_isolated=0A=
>               a_ops->isolate_page=0A=
>               __SetPageIsolated=0A=
>               unlock_page=0A=
>       list_add(&page->lru, &cc->migratepages)=0A=
>=0A=
> The migration path:=0A=
>=0A=
> unmap_and_move=0A=
>       __unmap_and_move=0A=
>               lock_page=0A=
>               move_to_new_page=0A=
>                       a_ops->migratepage=0A=
>                       __ClearPageIsolated=0A=
>               unlock_page=0A=
>       /* here, the page could be isolated again by another thread, and ad=
ded into another cc->migratepages,=0A=
>       since PG_Isolated has been cleared, and not protected by page_lock =
*/=0A=
>       list_del(&page->lru)=0A=
=0A=
But the page has been migrated already and not freed yet because there=0A=
is still a pin on it. So nobody should be touching it at this stage.=0A=
Or do I still miss something?=0A=
--=0A=
Michal Hocko=0A=
SUSE Labs=0A=

