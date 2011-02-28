Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 41B198D0039
	for <linux-mm@kvack.org>; Sun, 27 Feb 2011 21:35:28 -0500 (EST)
Received: by iyf13 with SMTP id 13so3363146iyf.14
        for <linux-mm@kvack.org>; Sun, 27 Feb 2011 18:35:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110228111822.41484020.nishimura@mxp.nes.nec.co.jp>
References: <1298821765-3167-1-git-send-email-minchan.kim@gmail.com>
	<20110228111822.41484020.nishimura@mxp.nes.nec.co.jp>
Date: Mon, 28 Feb 2011 11:35:26 +0900
Message-ID: <AANLkTik44K60MLTw_m431xd3ZFatAo=9O+42jUHscdFR@mail.gmail.com>
Subject: Re: [PATCH] memcg: clean up migration
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi, Daisuke

On Mon, Feb 28, 2011 at 11:18 AM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> On Mon, 28 Feb 2011 00:49:25 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> This patch cleans up unncessary BUG_ON check and confusing
>> charge variable.
>>
>> That's because memcg charge/uncharge could be handled by
>> mem_cgroup_[prepare/end] migration itself so charge local variable
>> in unmap_and_move lost the role since we introduced 01b1ae63c2.
>>
>> And mem_cgroup_prepare_migratio return 0 if only it is successful.
>> Otherwise, it jumps to unlock label to clean up so BUG_ON(charge)
>> isn;t meaningless.
>>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
>> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>
> It looks good to me, but I have one minor comment.
>
>> ---
>> =C2=A0mm/memcontrol.c | =C2=A0 =C2=A01 +
>> =C2=A0mm/migrate.c =C2=A0 =C2=A0| =C2=A0 14 ++++----------
>> =C2=A02 files changed, 5 insertions(+), 10 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 2fc97fc..6832926 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2872,6 +2872,7 @@ static inline int mem_cgroup_move_swap_account(swp=
_entry_t entry,
>> =C2=A0/*
>> =C2=A0 * Before starting migration, account PAGE_SIZE to mem_cgroup that=
 the old
>> =C2=A0 * page belongs to.
>> + * Return 0 if charge is successful. Otherwise return -errno.
>> =C2=A0 */
>> =C2=A0int mem_cgroup_prepare_migration(struct page *page,
>> =C2=A0 =C2=A0 =C2=A0 struct page *newpage, struct mem_cgroup **ptr, gfp_=
t gfp_mask)
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index eb083a6..737c2e5 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -622,7 +622,6 @@ static int unmap_and_move(new_page_t get_new_page, u=
nsigned long private,
>> =C2=A0 =C2=A0 =C2=A0 int *result =3D NULL;
>> =C2=A0 =C2=A0 =C2=A0 struct page *newpage =3D get_new_page(page, private=
, &result);
>> =C2=A0 =C2=A0 =C2=A0 int remap_swapcache =3D 1;
>> - =C2=A0 =C2=A0 int charge =3D 0;
>> =C2=A0 =C2=A0 =C2=A0 struct mem_cgroup *mem;
>> =C2=A0 =C2=A0 =C2=A0 struct anon_vma *anon_vma =3D NULL;
>>
>> @@ -637,9 +636,7 @@ static int unmap_and_move(new_page_t get_new_page, u=
nsigned long private,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (unlikely(split_huge=
_page(page)))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto move_newpage;
>>
>> - =C2=A0 =C2=A0 /* prepare cgroup just returns 0 or -ENOMEM */
>> =C2=A0 =C2=A0 =C2=A0 rc =3D -EAGAIN;
>> -
>> =C2=A0 =C2=A0 =C2=A0 if (!trylock_page(page)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!force)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto move_newpage;
>> @@ -678,13 +675,11 @@ static int unmap_and_move(new_page_t get_new_page,=
 unsigned long private,
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 /* charge against new page */
>> - =C2=A0 =C2=A0 charge =3D mem_cgroup_prepare_migration(page, newpage, &=
mem, GFP_KERNEL);
>> - =C2=A0 =C2=A0 if (charge =3D=3D -ENOMEM) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D -ENOMEM;
>> + =C2=A0 =C2=A0 rc =3D mem_cgroup_prepare_migration(page, newpage, &mem,=
 GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (rc)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto unlock;
>> - =C2=A0 =C2=A0 }
>> - =C2=A0 =C2=A0 BUG_ON(charge);
>>
>> + =C2=A0 =C2=A0 rc =3D -EAGAIN;
>> =C2=A0 =C2=A0 =C2=A0 if (PageWriteback(page)) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!force || !sync)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto uncharge;
> How about
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mem_cgroup_prepare_migration(..)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rc =3D -ENOMEM;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto unlock;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> ?
>
> Re-setting "rc" to -EAGAIN is not necessary in this case.
> "if (mem_cgroup_...)" is commonly used in many places.
>
It works now but Johannes doesn't like it and me, either.
It makes unnecessary dependency which mem_cgroup_preparre_migration
can't propagate error to migrate_pages.
Although we don't need it, I want to remove such unnecessary dependency.

> Anyway,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Acked-by: Daisuke Nishimura <nishimura@mxp.nes=
.nec.co.jp>
>
>

Thanks!.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
