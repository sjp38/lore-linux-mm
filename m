Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CA5196B0085
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:21:55 -0400 (EDT)
Received: by ywh41 with SMTP id 41so1054214ywh.23
        for <linux-mm@kvack.org>; Fri, 21 Aug 2009 08:21:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28c262360908190628i3f323714kf011f9b0fd4cd15@mail.gmail.com>
References: <20090816051502.GB13740@localhost>
	 <20090816112910.GA3208@localhost>
	 <20090818234310.A64B.A69D9226@jp.fujitsu.com>
	 <20090819120117.GB7306@localhost>
	 <2f11576a0908190505h6da96280xf67c962aa3f5ba07@mail.gmail.com>
	 <20090819121017.GA8226@localhost>
	 <28c262360908190525i6e56ead0mb8dcb01c3d1a69f1@mail.gmail.com>
	 <2f11576a0908190619t9951959o3841091e51324c8@mail.gmail.com>
	 <28c262360908190628i3f323714kf011f9b0fd4cd15@mail.gmail.com>
Date: Fri, 21 Aug 2009 20:17:51 +0900
Message-ID: <2f11576a0908210417y340f7017r20d87d81c6243184@mail.gmail.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Jeff Dike <jdike@addtoit.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> Hmm, I think
>>
>> 1. Anyway, we need turn on PG_mlock.
>
> I add my patch again to explain.
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index ed63894..283266c 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -358,6 +358,7 @@ static int page_referenced_one(struct page *page,
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (vma->vm_flags & VM_LOCKED) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*mapcount =3D 1; =A0/* break early from lo=
op */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *vm_flags |=3D VM_LOCKED;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unmap;
> =A0 =A0 =A0 =A0}
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index d224b28..d156e1d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -632,7 +632,8 @@ static unsigned long shrink_page_list(struct
> list_head *page_list,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0sc->mem_cgroup, &vm_flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* In active use or really unfreeable? =A0=
Activate it. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (sc->order <=3D PAGE_ALLOC_COSTLY_ORDER=
 &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 referenced && page_mapping_inuse(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 referenced && page_mapping_inuse(page)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 && !(vm_flags & VM_LOCKED))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto activate_locked;
>
> By this check, the page can be reached at try_to_unmap after
> page_referenced in shrink_page_list. At that time PG_mlocked will be
> set.

You are right.
Please add my Reviewed-by sign to your patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
