Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E82036B0047
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:51:00 -0400 (EDT)
Received: by rv-out-0708.google.com with SMTP id f25so1365008rvb.26
        for <linux-mm@kvack.org>; Sun, 22 Mar 2009 17:44:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1237752784-1989-3-git-send-email-hannes@cmpxchg.org>
References: <20090321102044.GA3427@cmpxchg.org>
	 <1237752784-1989-3-git-send-email-hannes@cmpxchg.org>
Date: Mon, 23 Mar 2009 09:44:42 +0900
Message-ID: <28c262360903221744r6d275294gdc8ad3a12b8c5361@mail.gmail.com>
Subject: Re: [patch 3/3] mm: keep pages from unevictable mappings off the LRU
	lists
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Hmm,,

This patch is another thing unlike previous series patches.
Firstly, It looked good to me.

I think add_to_page_cache_lru have to become a fast path.
But, how often would ramfs and shmem function be called ?

I have a concern for this patch to add another burden.
so, we need any numbers for getting pros and cons.

Any thoughts ?

On Mon, Mar 23, 2009 at 5:13 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> Check if the mapping is evictable when initially adding page cache
> pages to the LRU lists. =C2=A0If that is not the case, add them to the
> unevictable list immediately instead of leaving it up to the reclaim
> code to move them there.
>
> This is useful for ramfs and locked shmem which mark whole mappings as
> unevictable and we know at fault time already that it is useless to
> try reclaiming these pages.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: David Howells <dhowells@redhat.com>
> Cc: Nick Piggin <npiggin@suse.de>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.com>
> Cc: MinChan Kim <minchan.kim@gmail.com>
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> ---
> =C2=A0mm/filemap.c | =C2=A0 =C2=A04 +++-
> =C2=A01 files changed, 3 insertions(+), 1 deletions(-)
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 23acefe..8574530 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -506,7 +506,9 @@ int add_to_page_cache_lru(struct page *page, struct a=
ddress_space *mapping,
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D add_to_page_cache(page, mapping, offse=
t, gfp_mask);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret =3D=3D 0) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_is_file_cache=
(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mapping_unevictabl=
e(mapping))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 add_page_to_unevictable_list(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (page_is_file_=
cache(page))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0lru_cache_add_file(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0lru_cache_add_active_anon(page);
> --
> 1.6.2.1.135.gde769
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
