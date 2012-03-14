Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 214FE6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 08:31:46 -0400 (EDT)
Received: by wibhq7 with SMTP id hq7so5683795wib.8
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 05:31:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331676929-25774-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20120313144501.d031f25d.kamezawa.hiroyu@jp.fujitsu.com>
	<1331676929-25774-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Wed, 14 Mar 2012 20:31:43 +0800
Message-ID: <CAJd=RBBjX2nL3UXoHZox3oU6Ve0xSawLNdXCawbdLaPpE8tQ1w@mail.gmail.com>
Subject: Re: [PATCH v4 1/3] memcg: clean up existing move charge code
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 14, 2012 at 6:15 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> From c9bdd8f19040f3cea1c7d36e98b03ee13c1b8505 Mon Sep 17 00:00:00 2001
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Tue, 13 Mar 2012 15:21:47 -0400
> Subject: [PATCH 1/3] memcg: clean up existing move charge code
>
> We'll introduce the thp variant of move charge code in later patches,
> but before doing that let's start with refactoring existing code.
> Here we replace lengthy function name is_target_pte_for_mc() with
> shorter one in order to avoid ugly line breaks.
> And for better readability, we explicitly use MC_TARGET_* instead of
> simply using integers.
>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.futjisu.com>

Acked-by: Hillf Danton <dhillf@gmail.com>

> ---
> =C2=A0mm/memcontrol.c | =C2=A0 17 ++++++++---------
> =C2=A01 files changed, 8 insertions(+), 9 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a288855..508a7ed 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5069,7 +5069,7 @@ one_by_one:
> =C2=A0}
>
> =C2=A0/**
> - * is_target_pte_for_mc - check a pte whether it is valid for move charg=
e
> + * get_mctgt_type - get target type of moving charge
> =C2=A0* @vma: the vma the pte to be checked belongs
> =C2=A0* @addr: the address corresponding to the pte to be checked
> =C2=A0* @ptent: the pte to be checked
> @@ -5092,7 +5092,7 @@ union mc_target {
> =C2=A0};
>
> =C2=A0enum mc_target_type {
> - =C2=A0 =C2=A0 =C2=A0 MC_TARGET_NONE, /* not used */
> + =C2=A0 =C2=A0 =C2=A0 MC_TARGET_NONE =3D 0,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MC_TARGET_PAGE,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0MC_TARGET_SWAP,
> =C2=A0};
> @@ -5173,12 +5173,12 @@ static struct page *mc_handle_file_pte(struct vm_=
area_struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return page;
> =C2=A0}
>
> -static int is_target_pte_for_mc(struct vm_area_struct *vma,
> +static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long addr=
, pte_t ptent, union mc_target *target)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page =3D NULL;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page_cgroup *pc;
> - =C2=A0 =C2=A0 =C2=A0 int ret =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 enum mc_target_type ret =3D MC_TARGET_NONE;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0swp_entry_t ent =3D { .val =3D 0 };
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (pte_present(ptent))
> @@ -5189,7 +5189,7 @@ static int is_target_pte_for_mc(struct vm_area_stru=
ct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D mc_handle=
_file_pte(vma, addr, ptent, &ent);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page && !ent.val)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pc =3D lookup_page=
_cgroup(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -5227,7 +5227,7 @@ static int mem_cgroup_count_precharge_pte_range(pmd=
_t *pmd,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pte =3D pte_offset_map_lock(vma->vm_mm, pmd, a=
ddr, &ptl);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (; addr !=3D end; pte++, addr +=3D PAGE_SI=
ZE)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (is_target_pte_for_=
mc(vma, addr, *pte, NULL))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (get_mctgt_type(vma=
, addr, *pte, NULL))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0mc.precharge++; /* increment precharge temporarily */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_unmap_unlock(pte - 1, ptl);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resched();
> @@ -5397,8 +5397,7 @@ retry:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!mc.precharge)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 type =3D is_target_pte=
_for_mc(vma, addr, ptent, &target);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (type) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 switch (get_mctgt_type=
(vma, addr, ptent, &target)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case MC_TARGET_PAG=
E:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0page =3D target.page;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (isolate_lru_page(page))
> @@ -5411,7 +5410,7 @@ retry:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mc.moved_charge++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0putback_lru_page(page);
> -put: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* i=
s_target_pte_for_mc() gets the page */
> +put: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* g=
et_mctgt_type() gets the page */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0put_page(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0break;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case MC_TARGET_SWA=
P:
> --
> 1.7.7.6
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
