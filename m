Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C23556B01DB
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 10:33:03 -0400 (EDT)
Received: by pxi34 with SMTP id 34so1731382pxi.22
        for <linux-mm@kvack.org>; Mon, 15 Mar 2010 07:33:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100315142124.GL18274@csn.ul.ie>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	 <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	 <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100315112829.GI18274@csn.ul.ie>
	 <1268657329.1889.4.camel@barrios-desktop>
	 <20100315142124.GL18274@csn.ul.ie>
Date: Mon, 15 Mar 2010 23:33:01 +0900
Message-ID: <28c262361003150733j4d0c708eyfc525e1e3c5c1f7d@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 11:21 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Mon, Mar 15, 2010 at 09:48:49PM +0900, Minchan Kim wrote:
>> On Mon, 2010-03-15 at 11:28 +0000, Mel Gorman wrote:
>> > The use after free looks like
>> >
>> > 1. page_mapcount(page) was zero so anon_vma was no longer reliable
>> > 2. rcu lock taken but the anon_vma at this point can already be garbag=
e because the
>> > =C2=A0 =C2=A0process exited
>> > 3. call try_to_unmap, looks up tha anon_vma and locks it. This causes =
problems
>> >
>> > I thought the race would be closed but there is still a very tiny wind=
ow there all
>> > right. The following alternative should close it. What do you think?
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageAnon(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If the=
 page has no mappings any more, just bail. An
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* unmapp=
ed anon page is likely to be freed soon but worse,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* it's p=
ossible its anon_vma disappeared between when
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the pa=
ge was isolated and when we reached here while
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the RC=
U lock was not held
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page_mapc=
ount(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
rcu_read_unlock();
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 goto uncharge;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rcu_locked =3D=
 1;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 anon_vma =3D p=
age_anon_vma(page);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 atomic_inc(&an=
on_vma->external_refcount);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >
>> > The rcu_unlock label is not used here because the reference counts wer=
e not taken in
>> > the case where page_mapcount =3D=3D 0.
>> >
>>
>> Please, repost above code with your use-after-free scenario comment.
>>
>
> This will be the replacement patch so.
>
> =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
> mm,migration: Do not try to migrate unmapped anonymous pages
>
> rmap_walk_anon() was triggering errors in memory compaction that look lik=
e
> use-after-free errors. The problem is that between the page being isolate=
d
> from the LRU and rcu_read_lock() being taken, the mapcount of the page
> dropped to 0 and the anon_vma gets freed. This can happen during memory
> compaction if pages being migrated belong to a process that exits before
> migration completes. Hence, the use-after-free race looks like
>
> =C2=A01. Page isolated for migration
> =C2=A02. Process exits
> =C2=A03. page_mapcount(page) drops to zero so anon_vma was no longer reli=
able
> =C2=A04. unmap_and_move() takes the rcu_lock but the anon_vma is already =
garbage
> =C2=A04. call try_to_unmap, looks up tha anon_vma and "locks" it but the =
lock
> =C2=A0 =C2=A0is garbage.
>
> This patch checks the mapcount after the rcu lock is taken. If the
> mapcount is zero, the anon_vma is assumed to be freed and no further
> action is taken.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
