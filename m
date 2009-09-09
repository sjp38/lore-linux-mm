Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 217146B004F
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 12:16:53 -0400 (EDT)
Received: by yxe10 with SMTP id 10so7493534yxe.12
        for <linux-mm@kvack.org>; Wed, 09 Sep 2009 09:16:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909072233240.15430@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
	 <Pine.LNX.4.64.0909072233240.15430@sister.anvils>
Date: Thu, 10 Sep 2009 01:16:57 +0900
Message-ID: <28c262360909090916w12d700b3w7fa8a970f3aba3af@mail.gmail.com>
Subject: Re: [PATCH 4/8] mm: FOLL_DUMP replace FOLL_ANON
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jeff Chua <jeff.chua.linux@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 8, 2009 at 6:35 AM, Hugh Dickins <hugh.dickins@tiscali.co.uk> w=
rote:
> The "FOLL_ANON optimization" and its use_zero_page() test have caused
> confusion and bugs: why does it test VM_SHARED? for the very good but
> unsatisfying reason that VMware crashed without. =A0As we look to maybe
> reinstating anonymous use of the ZERO_PAGE, we need to sort this out.
>
> Easily done: it's silly for __get_user_pages() and follow_page() to
> be guessing whether it's safe to assume that they're being used for
> a coredump (which can take a shortcut snapshot where other uses must
> handle a fault) - just tell them with GUP_FLAGS_DUMP and FOLL_DUMP.
>
> get_dump_page() doesn't even want a ZERO_PAGE: an error suits fine.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Just a nitpick below. :)

> ---
>
> =A0include/linux/mm.h | =A0 =A02 +-
> =A0mm/internal.h =A0 =A0 =A0| =A0 =A01 +
> =A0mm/memory.c =A0 =A0 =A0 =A0| =A0 43 ++++++++++++----------------------=
---------
> =A03 files changed, 14 insertions(+), 32 deletions(-)
>
> --- mm3/include/linux/mm.h =A0 =A0 =A02009-09-07 13:16:32.000000000 +0100
> +++ mm4/include/linux/mm.h =A0 =A0 =A02009-09-07 13:16:39.000000000 +0100
> @@ -1247,7 +1247,7 @@ struct page *follow_page(struct vm_area_
> =A0#define FOLL_WRITE =A0 =A0 0x01 =A0 =A0/* check pte is writable */
> =A0#define FOLL_TOUCH =A0 =A0 0x02 =A0 =A0/* mark page accessed */
> =A0#define FOLL_GET =A0 =A0 =A0 0x04 =A0 =A0/* do get_page on page */
> -#define FOLL_ANON =A0 =A0 =A00x08 =A0 =A0/* give ZERO_PAGE if no pgtable=
 */
> +#define FOLL_DUMP =A0 =A0 =A00x08 =A0 =A0/* give error on hole if it wou=
ld be zero */
>
> =A0typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long add=
r,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *data);
> --- mm3/mm/internal.h =A0 2009-09-07 13:16:22.000000000 +0100
> +++ mm4/mm/internal.h =A0 2009-09-07 13:16:39.000000000 +0100
> @@ -252,6 +252,7 @@ static inline void mminit_validate_memmo
>
> =A0#define GUP_FLAGS_WRITE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x01
> =A0#define GUP_FLAGS_FORCE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x02
> +#define GUP_FLAGS_DUMP =A0 =A0 =A0 =A0 0x04
>
> =A0int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long start, int len, int=
 flags,
> --- mm3/mm/memory.c =A0 =A0 2009-09-07 13:16:32.000000000 +0100
> +++ mm4/mm/memory.c =A0 =A0 2009-09-07 13:16:39.000000000 +0100
> @@ -1174,41 +1174,22 @@ no_page:
> =A0 =A0 =A0 =A0pte_unmap_unlock(ptep, ptl);
> =A0 =A0 =A0 =A0if (!pte_none(pte))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return page;
> - =A0 =A0 =A0 /* Fall through to ZERO_PAGE handling */
> +
> =A0no_page_table:
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * When core dumping an enormous anonymous area that nobod=
y
> - =A0 =A0 =A0 =A0* has touched so far, we don't want to allocate page tab=
les.
> + =A0 =A0 =A0 =A0* has touched so far, we don't want to allocate unnecess=
ary pages or
> + =A0 =A0 =A0 =A0* page tables. =A0Return error instead of NULL to skip h=
andle_mm_fault,
> + =A0 =A0 =A0 =A0* then get_dump_page() will return NULL to leave a hole =
in the dump.
> + =A0 =A0 =A0 =A0* But we can only make this optimization where a hole wo=
uld surely
> + =A0 =A0 =A0 =A0* be zero-filled if handle_mm_fault() actually did handl=
e it.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 if (flags & FOLL_ANON) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D ZERO_PAGE(0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flags & FOLL_GET)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_page(page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(flags & FOLL_WRITE);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 if ((flags & FOLL_DUMP) &&
> + =A0 =A0 =A0 =A0 =A0 (!vma->vm_ops || !vma->vm_ops->fault))

How about adding comment about zero page use?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-EFAULT);
> =A0 =A0 =A0 =A0return page;
> =A0}


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
