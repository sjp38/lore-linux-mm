Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 186866B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 09:08:55 -0400 (EDT)
Received: by yxe28 with SMTP id 28so1055662yxe.12
        for <linux-mm@kvack.org>; Mon, 15 Jun 2009 06:09:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090615031253.530308256@intel.com>
References: <20090615024520.786814520@intel.com>
	 <20090615031253.530308256@intel.com>
Date: Mon, 15 Jun 2009 22:09:03 +0900
Message-ID: <28c262360906150609gd736bf7p7a57de1b81cedd97@mail.gmail.com>
Subject: Re: [PATCH 09/22] HWPOISON: Handle hardware poisoned pages in
	try_to_unmap
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 11:45 AM, Wu Fengguang<fengguang.wu@intel.com> wrot=
e:
> From: Andi Kleen <ak@linux.intel.com>
>
> When a page has the poison bit set replace the PTE with a poison entry.
> This causes the right error handling to be done later when a process runs
> into it.
>
> Also add a new flag to not do that (needed for the memory-failure handler
> later)
>
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
>
> ---
> =C2=A0include/linux/rmap.h | =C2=A0 =C2=A01 +
> =C2=A0mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A09=
 ++++++++-
> =C2=A02 files changed, 9 insertions(+), 1 deletion(-)
>
> --- sound-2.6.orig/mm/rmap.c
> +++ sound-2.6/mm/rmap.c
> @@ -958,7 +958,14 @@ static int try_to_unmap_one(struct page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Update high watermark before we lower rss *=
/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0update_hiwater_rss(mm);
>
> - =C2=A0 =C2=A0 =C2=A0 if (PageAnon(page)) {
> + =C2=A0 =C2=A0 =C2=A0 if (PageHWPoison(page) && !(flags & TTU_IGNORE_HWP=
OISON)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageAnon(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 dec_mm_counter(mm, anon_rss);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (!is_migration=
_entry(pte_to_swp_entry(*pte)))

Isn't it straightforward to use !is_hwpoison_entry ?


--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
