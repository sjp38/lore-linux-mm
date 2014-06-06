Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id D63D06B0088
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 11:30:36 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so2716304wgh.31
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 08:30:36 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id ys3si18144086wjc.16.2014.06.06.08.30.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 08:30:35 -0700 (PDT)
Date: Fri, 6 Jun 2014 17:30:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2] mm: rmap: fix use-after-free in __put_anon_vma
Message-ID: <20140606153033.GC11371@laptop.programming.kicks-ass.net>
References: <20140606115620.GS3213@twins.programming.kicks-ass.net>
 <1402067370-5773-1-git-send-email-a.ryabinin@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1402067370-5773-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, koct9i@gmail.com, stable@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Fri, Jun 06, 2014 at 07:09:30PM +0400, Andrey Ryabinin wrote:
> While working address sanitizer for kernel I've discovered use-after-free
> bug in __put_anon_vma.
> For the last anon_vma, anon_vma->root freed before child anon_vma.
> Later in anon_vma_free(anon_vma) we are referencing to already freed anon=
_vma->root
> to check rwsem.
> This patch puts freeing of child anon_vma before freeing of anon_vma->roo=
t.
>=20
> Cc: <stable@vger.kernel.org> # v3.0+

Acked-by: Peter Zijlstra <peterz@infradead.org>

> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>=20
> Changes since v1:
>  - just made it more simple following Peter's suggestion
>=20
>  mm/rmap.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 9c3e773..cb5f70a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1564,10 +1564,10 @@ void __put_anon_vma(struct anon_vma *anon_vma)
>  {
>  	struct anon_vma *root =3D anon_vma->root;
> =20
> +	anon_vma_free(anon_vma);
> +
>  	if (root !=3D anon_vma && atomic_dec_and_test(&root->refcount))
>  		anon_vma_free(root);
> -
> -	anon_vma_free(anon_vma);
>  }
> =20
>  static struct anon_vma *rmap_walk_anon_lock(struct page *page,
> --=20
> 1.8.5.5
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
