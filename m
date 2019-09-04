Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15465C3A5A2
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 02:18:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7635206BB
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 02:18:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7635206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 596B66B0007; Tue,  3 Sep 2019 22:18:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5480F6B0008; Tue,  3 Sep 2019 22:18:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45E9B6B000A; Tue,  3 Sep 2019 22:18:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0236.hostedemail.com [216.40.44.236])
	by kanga.kvack.org (Postfix) with ESMTP id 26E866B0007
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 22:18:46 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A4390640A
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:18:45 +0000 (UTC)
X-FDA: 75895629810.26.grain21_4c609b4583013
X-HE-Tag: grain21_4c609b4583013
X-Filterd-Recvd-Size: 5966
Received: from huawei.com (szxga02-in.huawei.com [45.249.212.188])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:18:44 +0000 (UTC)
Received: from dggeml406-hub.china.huawei.com (unknown [172.30.72.53])
	by Forcepoint Email with ESMTP id 3341017F6BB060C06155;
	Wed,  4 Sep 2019 10:18:42 +0800 (CST)
Received: from DGGEML422-HUB.china.huawei.com (10.1.199.39) by
 dggeml406-hub.china.huawei.com (10.3.17.50) with Microsoft SMTP Server (TLS)
 id 14.3.439.0; Wed, 4 Sep 2019 10:18:41 +0800
Received: from DGGEML512-MBX.china.huawei.com ([169.254.2.60]) by
 dggeml422-hub.china.huawei.com ([10.1.199.39]) with mapi id 14.03.0439.000;
 Wed, 4 Sep 2019 10:18:38 +0800
From: sunqiuyang <sunqiuyang@huawei.com>
To: Michal Hocko <mhocko@kernel.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Thread-Topic: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Thread-Index: AQHVYi7CKRiSaGuZ20KJAhdeZXNZ4qcZaW+AgAFf/lQ=
Date: Wed, 4 Sep 2019 02:18:38 +0000
Message-ID: <157FC541501A9C4C862B2F16FFE316DC190C1B09@dggeml512-mbx.china.huawei.com>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>,<20190903131737.GB18939@dhcp22.suse.cz>
In-Reply-To: <20190903131737.GB18939@dhcp22.suse.cz>
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

The isolate path of non-lru movable pages:=0A=
=0A=
isolate_migratepages_block=0A=
	isolate_movable_page=0A=
		trylock_page=0A=
		// if PageIsolated, goto out_no_isolated=0A=
		a_ops->isolate_page=0A=
		__SetPageIsolated=0A=
		unlock_page=0A=
	list_add(&page->lru, &cc->migratepages)=0A=
=0A=
The migration path:=0A=
=0A=
unmap_and_move=0A=
	__unmap_and_move=0A=
		lock_page=0A=
		move_to_new_page=0A=
			a_ops->migratepage=0A=
			__ClearPageIsolated=0A=
		unlock_page=0A=
	/* here, the page could be isolated again by another thread, and added int=
o another cc->migratepages,=0A=
	since PG_Isolated has been cleared, and not protected by page_lock */=0A=
	list_del(&page->lru)=0A=
=0A=
Suppose thread A isolates three pages in the order p1, p2, p3, A's cc->migr=
atepages will be like=0A=
	head_A - p3 - p2 - p1=0A=
After p2 is migrated (but before list_del), it is isolated by another threa=
d B. Then list_del will delete p2=0A=
from the cc->migratepages of B (instead of A). When A continues to migrate =
and delete p1, it will find:=0A=
	p1->prev =3D=3D p2=0A=
	p2->next =3D=3D LIST_POISON1. =0A=
=0A=
So we will end up with a bug like=0A=
"list_del corruption. prev->next should be ffffffbf0a1eb8e0, but was dead00=
0000000100"=0A=
(see __list_del_entry_valid).=0A=
=0A=
=0A=
________________________________________=0A=
From: Michal Hocko [mhocko@kernel.org]=0A=
Sent: Tuesday, September 03, 2019 21:17=0A=
To: sunqiuyang=0A=
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org=0A=
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of no=
n-LRU movable pages=0A=
=0A=
On Tue 03-09-19 16:27:46, sunqiuyang wrote:=0A=
> From: Qiuyang Sun <sunqiuyang@huawei.com>=0A=
>=0A=
> Currently, after a page is migrated, it=0A=
> 1) has its PG_isolated flag cleared in move_to_new_page(), and=0A=
> 2) is deleted from its LRU list (cc->migratepages) in unmap_and_move().=
=0A=
> However, between steps 1) and 2), the page could be isolated by another=
=0A=
> thread in isolate_movable_page(), and added to another LRU list, leading=
=0A=
> to list_del corruption later.=0A=
=0A=
Care to explain the race? Both paths use page_lock AFAICS=0A=
>=0A=
> This patch fixes the bug by moving list_del into the critical section=0A=
> protected by lock_page(), so that a page will not be isolated again befor=
e=0A=
> it has been deleted from its LRU list.=0A=
>=0A=
> Signed-off-by: Qiuyang Sun <sunqiuyang@huawei.com>=0A=
> ---=0A=
>  mm/migrate.c | 11 +++--------=0A=
>  1 file changed, 3 insertions(+), 8 deletions(-)=0A=
>=0A=
> diff --git a/mm/migrate.c b/mm/migrate.c=0A=
> index a42858d..c58a606 100644=0A=
> --- a/mm/migrate.c=0A=
> +++ b/mm/migrate.c=0A=
> @@ -1124,6 +1124,8 @@ static int __unmap_and_move(struct page *page, stru=
ct page *newpage,=0A=
>       /* Drop an anon_vma reference if we took one */=0A=
>       if (anon_vma)=0A=
>               put_anon_vma(anon_vma);=0A=
> +     if (rc !=3D -EAGAIN)=0A=
> +             list_del(&page->lru);=0A=
>       unlock_page(page);=0A=
>  out:=0A=
>       /*=0A=
> @@ -1190,6 +1192,7 @@ static ICE_noinline int unmap_and_move(new_page_t g=
et_new_page,=0A=
>                       put_new_page(newpage, private);=0A=
>               else=0A=
>                       put_page(newpage);=0A=
> +             list_del(&page->lru);=0A=
>               goto out;=0A=
>       }=0A=
>=0A=
> @@ -1200,14 +1203,6 @@ static ICE_noinline int unmap_and_move(new_page_t =
get_new_page,=0A=
>  out:=0A=
>       if (rc !=3D -EAGAIN) {=0A=
>               /*=0A=
> -              * A page that has been migrated has all references=0A=
> -              * removed and will be freed. A page that has not been=0A=
> -              * migrated will have kepts its references and be=0A=
> -              * restored.=0A=
> -              */=0A=
> -             list_del(&page->lru);=0A=
> -=0A=
> -             /*=0A=
>                * Compaction can migrate also non-LRU pages which are=0A=
>                * not accounted to NR_ISOLATED_*. They can be recognized=
=0A=
>                * as __PageMovable=0A=
> --=0A=
> 1.8.3.1=0A=
=0A=
--=0A=
Michal Hocko=0A=
SUSE Labs=0A=

