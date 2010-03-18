Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8DE626B0139
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 09:23:34 -0400 (EDT)
Received: by pxi34 with SMTP id 34so1531687pxi.22
        for <linux-mm@kvack.org>; Thu, 18 Mar 2010 06:23:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1268916463-8757-1-git-send-email-user@bob-laptop>
References: <1268916463-8757-1-git-send-email-user@bob-laptop>
Date: Thu, 18 Mar 2010 21:19:49 +0800
Message-ID: <cf18f8341003180619va7d06fbt5904592dedbc373d@mail.gmail.com>
Subject: Re: [PATCH 2/2] mempolicy: remove redundant check
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, andi@firstfloor.org, rientjes@google.com, lee.schermerhorn@hp.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 18, 2010 at 8:47 PM, Bob Liu <lliubbo@gmail.com> wrote:
> From: Bob Liu <lliubbo@gmail.com>
>
> Lee's patch "mempolicy: use MPOL_PREFERRED for system-wide
> default policy" has made the MPOL_DEFAULT only used in the
> memory policy APIs. So, no need to check in __mpol_equal also.
> Also get rid of mpol_match_intent() and move its logic directly
> into __mpol_equal().
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
> =C2=A0mm/mempolicy.c | =C2=A0 16 +++++-----------
> =C2=A01 files changed, 5 insertions(+), 11 deletions(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index b88e914..17df048 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1787,16 +1787,6 @@ struct mempolicy *__mpol_cond_copy(struct mempolic=
y *tompol,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return tompol;
> =C2=A0}
>
> -static int mpol_match_intent(const struct mempolicy *a,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0const struct mempolicy *b)
> -{
> - =C2=A0 =C2=A0 =C2=A0 if (a->flags !=3D b->flags)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> - =C2=A0 =C2=A0 =C2=A0 if (!mpol_store_user_nodemask(a))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
> - =C2=A0 =C2=A0 =C2=A0 return nodes_equal(a->w.user_nodemask, b->w.user_n=
odemask);
> -}
> -
> =C2=A0/* Slow path of a mempolicy comparison */
> =C2=A0int __mpol_equal(struct mempolicy *a, struct mempolicy *b)
> =C2=A0{
> @@ -1804,7 +1794,11 @@ int __mpol_equal(struct mempolicy *a, struct mempo=
licy *b)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (a->mode !=3D b->mode)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> - =C2=A0 =C2=A0 =C2=A0 if (a->mode !=3D MPOL_DEFAULT && !mpol_match_inten=
t(a, b))
> + =C2=A0 =C2=A0 =C2=A0 if (a->flags !=3D b->flags)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 if (mpol_store_user_nodemask(a))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 if (!nodes_equal(a->w.user_nodemask, b->w.user_nod=
emask))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (a->mode) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0case MPOL_BIND:

This patch is uncorrect, I have resend a new one :-)

> --
> 1.5.6.3
>
>

--=20
Regards,
-Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
