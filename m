Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 041D16B004D
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 23:00:31 -0400 (EDT)
Received: by pvg2 with SMTP id 2so303318pvg.14
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 20:00:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	 <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	 <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100315112829.GI18274@csn.ul.ie>
	 <1268657329.1889.4.camel@barrios-desktop>
	 <20100315142124.GL18274@csn.ul.ie>
	 <20100316084934.3798576c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 17 Mar 2010 12:00:15 +0900
Message-ID: <28c262361003162000w34cc13ecnbd32840a0df80f95@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 11:12 AM, KAMEZAWA Hiroyuki
> BTW, I doubt freeing anon_vma can happen even when we check mapcount.
>
> "unmap" is 2-stage operation.
> =C2=A0 =C2=A0 =C2=A0 =C2=A01. unmap_vmas() =3D> modify ptes, free pages, =
etc.
> =C2=A0 =C2=A0 =C2=A0 =C2=A02. free_pgtables() =3D> free pgtables, unlink =
vma and free it.
>
> Then, if migration is enough slow.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Migration(): =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Exit():
> =C2=A0 =C2=A0 =C2=A0 =C2=A0check mapcount
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0replace pte with migration pte
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_unlock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0pte_lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0copy page etc... =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zap pte (clear pte)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0pte_unlock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0free_pgtables
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0->free vma
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0->free anon_vma
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0remap pte with new pfn(fail)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_unlock
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0lock anon_vma->lock =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 # modification after free.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0check list is empty

check list is empty?
Do you mean anon_vma->head?

If it is, is it possible that that list isn't empty since anon_vma is
used by others due to
SLAB_DESTROY_BY_RCU?

but such case is handled by page_check_address, vma_address, I think.

> =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock anon_vma->lock
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free anon_vma
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_unlock
>
>
> Hmm. IIUC, anon_vma is allocated as SLAB_DESTROY_BY_RCU. Then, while
> rcu_read_lock() is taken, anon_vma is anon_vma even if freed. But it
> may reused as anon_vma for someone else.
> (IOW, it may be reused but never pushed back to general purpose memory
> =C2=A0until RCU grace period.)
> Then, touching anon_vma->lock never cause any corruption.
>
> Does use-after-free check for SLAB_DESTROY_BY_RCU correct behavior ?

Could you elaborate your point?

> Above case is not use-after-free. It's safe and expected sequence.
>
> Thanks,
> -Kame
>
>
>
>> > ---
>> > =C2=A0mm/migrate.c | =C2=A0 13 +++++++++++++
>> > =C2=A01 files changed, 13 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/mm/migrate.c b/mm/migrate.c
>> > index 98eaaf2..6eb1efe 100644
>> > --- a/mm/migrate.c
>> > +++ b/mm/migrate.c
>> > @@ -603,6 +603,19 @@ static int unmap_and_move(new_page_t get_new_page=
, unsigned long private,
>> > =C2=A0 =C2=A0 =C2=A0*/
>> > =C2=A0 =C2=A0 if (PageAnon(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If the page has no mappin=
gs any more, just bail. An
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unmapped anon page is lik=
ely to be freed soon but worse,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* it's possible its anon_vm=
a disappeared between when
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the page was isolated and=
 when we reached here while
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the RCU lock was not held
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_mapcount(page)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_r=
ead_unlock();
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto =
uncharge;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > +
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_locked =3D 1;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 anon_vma =3D page_anon_vma(p=
age);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_inc(&anon_vma->migrat=
e_refcount);
>> >
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
