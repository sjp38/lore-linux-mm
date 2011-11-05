Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9AE806B002D
	for <linux-mm@kvack.org>; Sat,  5 Nov 2011 10:48:47 -0400 (EDT)
Received: by ggnh4 with SMTP id h4so4654442ggn.14
        for <linux-mm@kvack.org>; Sat, 05 Nov 2011 07:48:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320503897.2428.8.camel@discretia>
References: <1320503897.2428.8.camel@discretia>
Date: Sat, 5 Nov 2011 15:48:45 +0100
Message-ID: <CAJdOS78xgf7-a1wGM4tyQVFhLrO3kWH1V4qoG2AT+QCa7nngBA@mail.gmail.com>
Subject: Re: [PATCH] mm: migrate: One less atomic operation
From: Jacobo Giralt <jacobo.giralt@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, minchan.kim@gmail.com, hughd@google.com, hannes@cmpxchg.org, npiggin@kernel.dk

I think I used an old e-mail address for Nick (got it from git blame),
I'm changing it now, sorry for the noise!

Regards,
Jacobo Giralt.

2011/11/5 Jacobo Giralt <jacobo.giralt@gmail.com>:
> From 3754c8617ef4377ce2ca2e3b28bdc28f8de1aa0d Mon Sep 17 00:00:00 2001
> From: Jacobo Giralt <jacobo.giralt@gmail.com>
> Date: Sat, 5 Nov 2011 13:12:50 +0100
> Subject: [PATCH] mm: migrate: One less atomic operation
>
> migrate_page_move_mapping drops a reference from the
> old page after unfreezing its counter. Both operations
> can be merged into a single atomic operation by
> directly unfreezing to one less reference.
>
> The same applies to migrate_huge_page_move_mapping.
>
> Signed-off-by: Jacobo Giralt <jacobo.giralt@gmail.com>
> ---
> =A0mm/migrate.c | =A0 10 ++++------
> =A01 files changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 33358f8..46d04a0 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -269,12 +269,12 @@ static int migrate_page_move_mapping(struct address=
_space *mapping,
>
> =A0 =A0 =A0 =A0radix_tree_replace_slot(pslot, newpage);
>
> - =A0 =A0 =A0 page_unfreeze_refs(page, expected_count);
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* Drop cache reference from old page.
> + =A0 =A0 =A0 =A0* Drop cache reference from old page by unfreezing
> + =A0 =A0 =A0 =A0* to one less reference.
> =A0 =A0 =A0 =A0 * We know this isn't the last reference.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 __put_page(page);
> + =A0 =A0 =A0 page_unfreeze_refs(page, expected_count - 1);
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If moved to a different zone then also account
> @@ -334,9 +334,7 @@ int migrate_huge_page_move_mapping(struct address_spa=
ce *mapping,
>
> =A0 =A0 =A0 =A0radix_tree_replace_slot(pslot, newpage);
>
> - =A0 =A0 =A0 page_unfreeze_refs(page, expected_count);
> -
> - =A0 =A0 =A0 __put_page(page);
> + =A0 =A0 =A0 page_unfreeze_refs(page, expected_count - 1);
>
> =A0 =A0 =A0 =A0spin_unlock_irq(&mapping->tree_lock);
> =A0 =A0 =A0 =A0return 0;
> --
> 1.7.5.4
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
