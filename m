Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 599C16B0190
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 20:28:10 -0400 (EDT)
Received: by pvg2 with SMTP id 2so348436pvg.14
        for <linux-mm@kvack.org>; Sun, 14 Mar 2010 17:28:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1268412087-13536-3-git-send-email-mel@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <1268412087-13536-3-git-send-email-mel@csn.ul.ie>
Date: Mon, 15 Mar 2010 09:28:08 +0900
Message-ID: <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Mel.
On Sat, Mar 13, 2010 at 1:41 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> rmap_walk_anon() was triggering errors in memory compaction that looks li=
ke
> use-after-free errors in anon_vma. The problem appears to be that between
> the page being isolated from the LRU and rcu_read_lock() being taken, the
> mapcount of the page dropped to 0 and the anon_vma was freed. This patch
> skips the migration of anon pages that are not mapped by anyone.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> =C2=A0mm/migrate.c | =C2=A0 10 ++++++++++
> =C2=A01 files changed, 10 insertions(+), 0 deletions(-)
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 98eaaf2..3c491e3 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -602,6 +602,16 @@ static int unmap_and_move(new_page_t get_new_page, u=
nsigned long private,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * just care Anon page here.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageAnon(page)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If the page ha=
s no mappings any more, just bail. An
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unmapped anon =
page is likely to be freed soon but worse,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* it's possible =
its anon_vma disappeared between when
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the page was i=
solated and when we reached here while
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the RCU lock w=
as not held
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_mapcount(pag=
e))

As looking code about mapcount of page, I got confused.
I think mapcount of page is protected by pte lock.
But I can't find pte lock in unmap_and_move.
If I am right, what protects race between this condition check and
rcu_read_lock?
This patch makes race window very small but It can't remove race totally.

I think I am missing something.
Pz, point me out. :)


> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto uncharge;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_locked =3D 1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0anon_vma =3D page_=
anon_vma(page);
> --
> 1.6.5
>




--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
