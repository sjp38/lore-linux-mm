Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9C4DA6B02A7
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:52:02 -0400 (EDT)
Received: by bwz9 with SMTP id 9so4262675bwz.14
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 10:52:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1278756333-6850-1-git-send-email-lliubbo@gmail.com>
References: <1278756333-6850-1-git-send-email-lliubbo@gmail.com>
Date: Tue, 13 Jul 2010 20:52:04 +0300
Message-ID: <AANLkTikMcPcldBh_uVKxrH7rEIUju3Y_3X2jLi9jw2Vs@mail.gmail.com>
Subject: Re: [PATCH] slob_free:free objects to their own list
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mpm@selenic.com, hannes@cmpxchg.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi Bob,

[ Please CC me on SLOB patches. You can use the 'scripts/get_maintainer.pl'
  script to figure out automatically who to CC on your patches. ]

On Sat, Jul 10, 2010 at 1:05 PM, Bob Liu <lliubbo@gmail.com> wrote:
> slob has alloced smaller objects from their own list in reduce
> overall external fragmentation and increase repeatability,
> free to their own list also.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>

The patch looks sane to me. Matt, does it look OK to you as well?

It would be nice to have some fragmentation numbers for this. One
really simple test case is to grep for MemTotal and MemFree in
/proc/meminfo. I'd expect to see some small improvement with your
patch applied. Quantifying long term fragmentation would be even
better but I don't have a good test case for that so I'm CC'ing Mel.

> ---
> =A0mm/slob.c | =A0 =A09 ++++++++-
> =A01 files changed, 8 insertions(+), 1 deletions(-)
>
> diff --git a/mm/slob.c b/mm/slob.c
> index 3f19a34..d582171 100644
> --- a/mm/slob.c
> +++ b/mm/slob.c
> @@ -396,6 +396,7 @@ static void slob_free(void *block, int size)
> =A0 =A0 =A0 =A0slob_t *prev, *next, *b =3D (slob_t *)block;
> =A0 =A0 =A0 =A0slobidx_t units;
> =A0 =A0 =A0 =A0unsigned long flags;
> + =A0 =A0 =A0 struct list_head *slob_list;
>
> =A0 =A0 =A0 =A0if (unlikely(ZERO_OR_NULL_PTR(block)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
> @@ -424,7 +425,13 @@ static void slob_free(void *block, int size)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_slob(b, units,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(void *)((unsigned long)(b=
 +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0SLOB_UNITS(PAGE_SIZE)) & PAGE_MASK));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_slob_page_free(sp, &free_slob_small);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (size < SLOB_BREAK1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slob_list =3D &free_slob_sm=
all;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (size < SLOB_BREAK2)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slob_list =3D &free_slob_me=
dium;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slob_list =3D &free_slob_la=
rge;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_slob_page_free(sp, slob_list);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
>
> --
> 1.5.6.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
