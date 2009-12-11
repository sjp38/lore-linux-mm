Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CBF5F6B0071
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 21:11:35 -0500 (EST)
Received: by pzk27 with SMTP id 27so345615pzk.12
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 18:11:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091210163429.2568.A69D9226@jp.fujitsu.com>
References: <20091210154822.2550.A69D9226@jp.fujitsu.com>
	 <20091210163429.2568.A69D9226@jp.fujitsu.com>
Date: Fri, 11 Dec 2009 11:11:33 +0900
Message-ID: <28c262360912101811x1d76d1c3v46ff6773620f94a2@mail.gmail.com>
Subject: Re: [RFC][PATCH v2 8/8] Don't deactivate many touched page
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, Kosaki.

On Thu, Dec 10, 2009 at 4:35 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Changelog
> =C2=A0o from v1
> =C2=A0 - Fix comments.
> =C2=A0 - Rename too_many_young_bit_found() with too_many_referenced()
> =C2=A0 =C2=A0 [as Rik's mention].
> =C2=A0o from andrea's original patch
> =C2=A0 - Rebase topon my patches.
> =C2=A0 - Use list_cut_position/list_splice_tail pair instead
> =C2=A0 =C2=A0 list_del/list_add to make pte scan fairness.
> =C2=A0 - Only use max young threshold when soft_try is true.
> =C2=A0 =C2=A0 It avoid wrong OOM sideeffect.
> =C2=A0 - Return SWAP_AGAIN instead successful result if max
> =C2=A0 =C2=A0 young threshold exceed. It prevent the pages without clear
> =C2=A0 =C2=A0 pte young bit will be deactivated wrongly.
> =C2=A0 - Add to treat ksm page logic
>
> Many shared and frequently used page don't need deactivate and
> try_to_unamp(). It's pointless while VM pressure is low, the page
> might reactivate soon. it's only makes cpu wasting.
>
> Then, This patch makes to stop pte scan if wipe_page_reference()
> found lots young pte bit.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> ---
> =C2=A0include/linux/rmap.h | =C2=A0 18 ++++++++++++++++++
> =C2=A0mm/ksm.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A04=
 ++++
> =C2=A0mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 19 ++++=
+++++++++++++++
> =C2=A03 files changed, 41 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 499972e..ddf2578 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -128,6 +128,24 @@ int wipe_page_reference_one(struct page *page,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0struct page_reference_context *refctx,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0struct vm_area_struct *vma, unsigned long address);
>
> +#define MAX_YOUNG_BIT_CLEARED 64
> +/*

This idea is good at embedded system which don't have access bit by hardwar=
e.

Such system emulates access bit as minor page fault AFAIK.
It means when VM clears young bit, kernel mark page table as non-permission
or something for refaulting.
So when next touch happens that address, kernel can do young bit set again.
It would be rather costly operation than one which have access bit by hardw=
are.

So  this idea is good in embedded system.
But 64 is rather big. many embedded system don't have many processes.
So I want to scale this number according to memory size like
inactive_raio for example.

Thanks for good idea and effort. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
