Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D93A6B004A
	for <linux-mm@kvack.org>; Sun, 10 Jul 2011 19:08:48 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2299279qwa.14
        for <linux-mm@kvack.org>; Sun, 10 Jul 2011 16:08:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1310244907-10144-1-git-send-email-dmitry.fink@palm.com>
References: <1310244149-9885-1-git-send-email-dmitry.fink@palm.com>
	<1310244907-10144-1-git-send-email-dmitry.fink@palm.com>
Date: Mon, 11 Jul 2011 08:08:46 +0900
Message-ID: <CAEwNFnDRZwSXnVP3EdXqYnNBrumcrihQ+m=N4fb9xouNE=TKRg@mail.gmail.com>
Subject: Re: [PATCH] mmap: Fix and tidy up overcommit page arithmetic
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Fink <dmitry.fink@palm.com>
Cc: Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, Jul 10, 2011 at 5:55 AM, Dmitry Fink <dmitry.fink@palm.com> wrote:
> - shmem pages are not immediately available, but they are not
> potentially available either, even if we swap them out, they will
> just relocate from memory into swap, total amount of immediate and
> potentially available memory is not going to be affected, so we
> shouldn't count them as potentially free in the first place.
>
> - nr_free_pages() is not an expensive operation anymore, there is
> no need to split the decision making in two halves and repeat code.
>
> Signed-off-by: Dmitry Fink <dmitry.fink@palm.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> ---
> =C2=A0mm/mmap.c =C2=A0| =C2=A0 33 ++++++++++++---------------------
> =C2=A0mm/nommu.c | =C2=A0 33 ++++++++++++---------------------
> =C2=A02 files changed, 24 insertions(+), 42 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index d49736f..b6ed22e 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -122,9 +122,16 @@ int __vm_enough_memory(struct mm_struct *mm, long pa=
ges, int cap_sys_admin)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sysctl_overcommit_memory =3D=3D OVERCOMMIT=
_GUESS) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long n;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =3D global_page_s=
tate(NR_FREE_PAGES);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 free +=3D global_page_=
state(NR_FILE_PAGES);
> +
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* shmem pages shouldn=
't be counted as free in this

Nitpick.
You didn't correct comment style. It's not a linux kernel coding style.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
