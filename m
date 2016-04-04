Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 60A0D6B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 01:48:06 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id fe3so136681203pab.1
        for <linux-mm@kvack.org>; Sun, 03 Apr 2016 22:48:06 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id o63si39325196pfi.141.2016.04.03.22.48.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 03 Apr 2016 22:48:05 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mm/hwpoison: fix wrong num_poisoned_pages account
Date: Mon, 4 Apr 2016 05:46:59 +0000
Message-ID: <20160404054658.GA23155@hori1.linux.bs1.fc.nec.co.jp>
References: <20160404053830.GA7042@bbox>
In-Reply-To: <20160404053830.GA7042@bbox>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <DB8C3814123DF74688CDCC9B093B5DD3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "bfields@fieldses.org" <bfields@fieldses.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "koct9i@gmail.com" <koct9i@gmail.com>, "aquini@redhat.com" <aquini@redhat.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, "rknize@motorola.com" <rknize@motorola.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

On Mon, Apr 04, 2016 at 02:38:30PM +0900, Minchan Kim wrote:
>=20
> Forking new thread,
>=20
> Hello Naoya,
>=20
> On Mon, Apr 04, 2016 at 04:45:12AM +0000, Naoya Horiguchi wrote:
> > On Mon, Apr 04, 2016 at 10:39:17AM +0900, Minchan Kim wrote:
> > > On Fri, Apr 01, 2016 at 02:58:21PM +0200, Vlastimil Babka wrote:
> > > > On 03/30/2016 09:12 AM, Minchan Kim wrote:
> > > > >Procedure of page migration is as follows:
> > > > >
> > > > >First of all, it should isolate a page from LRU and try to
> > > > >migrate the page. If it is successful, it releases the page
> > > > >for freeing. Otherwise, it should put the page back to LRU
> > > > >list.
> > > > >
> > > > >For LRU pages, we have used putback_lru_page for both freeing
> > > > >and putback to LRU list. It's okay because put_page is aware of
> > > > >LRU list so if it releases last refcount of the page, it removes
> > > > >the page from LRU list. However, It makes unnecessary operations
> > > > >(e.g., lru_cache_add, pagevec and flags operations. It would be
> > > > >not significant but no worth to do) and harder to support new
> > > > >non-lru page migration because put_page isn't aware of non-lru
> > > > >page's data structure.
> > > > >
> > > > >To solve the problem, we can add new hook in put_page with
> > > > >PageMovable flags check but it can increase overhead in
> > > > >hot path and needs new locking scheme to stabilize the flag check
> > > > >with put_page.
> > > > >
> > > > >So, this patch cleans it up to divide two semantic(ie, put and put=
back).
> > > > >If migration is successful, use put_page instead of putback_lru_pa=
ge and
> > > > >use putback_lru_page only on failure. That makes code more readabl=
e
> > > > >and doesn't add overhead in put_page.
> > > > >
> > > > >Comment from Vlastimil
> > > > >"Yeah, and compaction (perhaps also other migration users) has to =
drain
> > > > >the lru pvec... Getting rid of this stuff is worth even by itself.=
"
> > > > >
> > > > >Cc: Mel Gorman <mgorman@suse.de>
> > > > >Cc: Hugh Dickins <hughd@google.com>
> > > > >Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > > >Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > > > >Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > >=20
> > > > [...]
> > > >=20
> > > > >@@ -974,28 +986,28 @@ static ICE_noinline int unmap_and_move(new_p=
age_t get_new_page,
> > > > >  		list_del(&page->lru);
> > > > >  		dec_zone_page_state(page, NR_ISOLATED_ANON +
> > > > >  				page_is_file_cache(page));
> > > > >-		/* Soft-offlined page shouldn't go through lru cache list */
> > > > >+	}
> > > > >+
> > > > >+	/*
> > > > >+	 * If migration is successful, drop the reference grabbed during
> > > > >+	 * isolation. Otherwise, restore the page to LRU list unless we
> > > > >+	 * want to retry.
> > > > >+	 */
> > > > >+	if (rc =3D=3D MIGRATEPAGE_SUCCESS) {
> > > > >+		put_page(page);
> > > > >  		if (reason =3D=3D MR_MEMORY_FAILURE) {
> > > > >-			put_page(page);
> > > > >  			if (!test_set_page_hwpoison(page))
> > > > >  				num_poisoned_pages_inc();
> > > > >-		} else
> > > > >+		}
> > > >=20
> > > > Hmm, I didn't notice it previously, or it's due to rebasing, but it
> > > > seems that you restricted the memory failure handling (i.e. setting
> > > > hwpoison) to MIGRATE_SUCCESS, while previously it was done for all
> > > > non-EAGAIN results. I think that goes against the intention of
> > > > hwpoison, which is IIRC to catch and kill the poor process that
> > > > still uses the page?
> > >=20
> > > That's why I Cc'ed Naoya Horiguchi to catch things I might make
> > > mistake.
> > >=20
> > > Thanks for catching it, Vlastimil.
> > > It was my mistake. But in this chance, I looked over hwpoison code an=
d
> > > I saw other places which increases num_poisoned_pages are successful
> > > migration, already freed page and successful invalidated page.
> > > IOW, they are already successful isolated page so I guess it should
> > > increase the count when only successful migration is done?
> >=20
> > Yes, that's right. When exiting with migration's failure, we shouldn't =
call
> > test_set_page_hwpoison or num_poisoned_pages_inc, so current code check=
ing
> > (rc !=3D -EAGAIN) is simply incorrect. Your change fixes the bug in mem=
ory
> > error handling. Great!
>=20
> Thanks for confirming, Naoya.
> I will send it as separate patch with Ccing -stable.
>=20
> >=20
> > > And when I read memory_failure, it bails out without killing if it
> > > encounters HWPoisoned page so I think it's not for catching and
> > > kill the poor proces.
> > >
> > > >=20
> > > > Also (but not your fault) the put_page() preceding
> > > > test_set_page_hwpoison(page)) IMHO deserves a comment saying which
> > > > pin we are releasing and which one we still have (hopefully? if I
> > > > read description of da1b13ccfbebe right) otherwise it looks like
> > > > doing something with a page that we just potentially freed.
> > >
> > > Yes, while I read the code, I had same question. I think the releasin=
g
> > > refcount is for get_any_page.
> >=20
> > As the other callers of page migration do, soft_offline_page expects th=
e
> > migration source page to be freed at this put_page() (no pin remains.)
> > The refcount released here is from isolate_lru_page() in __soft_offline=
_page().
> > (the pin by get_any_page is released by put_hwpoison_page just after it=
.)
> >=20
> > .. yes, doing something just after freeing page looks weird, but that's
> > how PageHWPoison flag works. IOW, many other page flags are maintained
> > only during one "allocate-free" life span, but PageHWPoison still does
> > its job beyond it.
>=20
> Got it. Thanks for the clarification.
>=20
> >=20
> > As for commenting, this put_page() is called in any MIGRATEPAGE_SUCCESS
> > case (regardless of callers), so what we can say here is "we free the
> > source page here, bypassing LRU list" or something?
>=20
> Naoya, I wrote up the patch but hard to say I write up correct descriptio=
n.
> Could you review this?
>=20
> Thankks.
>=20
> From 916b0d5960169e93d1fa3c8b7bdb03fe2b86b455 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 4 Apr 2016 14:26:30 +0900
> Subject: [PATCH] mm/hwpoison: fix wrong num_poisoned_pages account
>=20
> Currently, migartion code increses num_poisoned_pages on *failed*

             migration ...  increase

> migration page as well as successfully migrated one at the trial
> of memory-failture. It will make the stat wrong.

            failure

> As well, it marks the page as PG_HWPoison even if the migration
> trial failed. It would make we cannot recover the corrupted page
> using memory-failure facility.
>=20
> This patches fixes it.
>=20
> Cc: stable@vger.kernel.org
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Thank you for the fix.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  mm/migrate.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>=20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 6c822a7b27e0..f9dfb18a4eba 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -975,7 +975,13 @@ static ICE_noinline int unmap_and_move(new_page_t ge=
t_new_page,
>  		dec_zone_page_state(page, NR_ISOLATED_ANON +
>  				page_is_file_cache(page));
>  		/* Soft-offlined page shouldn't go through lru cache list */
> -		if (reason =3D=3D MR_MEMORY_FAILURE) {
> +		if (reason =3D=3D MR_MEMORY_FAILURE && rc =3D=3D MIGRATEPAGE_SUCCESS) =
{
> +			/*
> +			 * With this release, we free successfully migrated
> +			 * page and set PG_HWPoison on just freed page
> +			 * intentionally. Although it's rather weird, it's how
> +			 * HWPoison flag works at the moment.
> +			 */
>  			put_page(page);
>  			if (!test_set_page_hwpoison(page))
>  				num_poisoned_pages_inc();
> --=20
> 1.9.1
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
