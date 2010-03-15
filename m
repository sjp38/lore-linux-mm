Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6E5366B00CA
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 03:11:33 -0400 (EDT)
Received: by pxi34 with SMTP id 34so1548913pxi.22
        for <linux-mm@kvack.org>; Mon, 15 Mar 2010 00:11:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100315154459.c665f68d.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <1268412087-13536-3-git-send-email-mel@csn.ul.ie>
	 <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	 <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361003142328w610f0478sbc17880ffa454fe8@mail.gmail.com>
	 <20100315154459.c665f68d.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 15 Mar 2010 16:11:31 +0900
Message-ID: <28c262361003150011u4525f6aas9c47760bf9c8faef@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 3:44 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com>
>> Thanks for detail explanation, Kame.
>> But it can't understand me enough, Sorry.
>>
>> Mel said he met "use-after-free errors in anon_vma".
>> So added the check in unmap_and_move.
>>
>> if (PageAnon(page)) {
>> =C2=A0....
>> =C2=A0if (!page_mapcount(page))
>> =C2=A0 =C2=A0goto uncharge;
>> =C2=A0rcu_read_lock();
>>
>> My concern what protects racy mapcount of the page?
>> For example,
>>
>> CPU A =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU B
>> unmap_and_move
>> page_mapcount check pass =C2=A0 =C2=A0zap_pte_range
>> <-- some stall --> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 pte_lock
>> <-- some stall --> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 page_remove_rmap(map_count is zero!)
>> <-- some stall --> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 pte_unlock
>> <-- some stall --> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 anon_vma_unlink
>> <-- some stall --> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 anon_vma free !!!!
>> rcu_read_lock
>> anon_vma has gone!!
>>
>> I think above scenario make error "use-after-free", again.
>> What prevent above scenario?
>>
> I think this patch is not complete.
> I guess this patch in [1/11] is trigger for the race.
> =3D=3D
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Drop an anon_vma reference if we took one */
> + =C2=A0 =C2=A0 =C2=A0 if (anon_vma && atomic_dec_and_lock(&anon_vma->mig=
rate_refcount, &anon_vma->lock)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int empty =3D list_emp=
ty(&anon_vma->head);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&anon_vma-=
>lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (empty)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 anon_vma_free(anon_vma);
> + =C2=A0 =C2=A0 =C2=A0 }
> =3D=3D
> If my understainding in above is correct, this "modify" freed anon_vma.
> Then, use-after-free happens. (In old implementation, there are no refcnt=
,
> so, there is no use-after-free ops.)
>

I agree.
Let's wait Mel's response.

>
> So, what I can think of now is a patch like following is necessary.
>
> =3D=3D
> static inline struct anon_vma *anon_vma_alloc(void)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct anon_vma *anon_vma;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0anon_vma =3D kmem_cache_alloc(anon_vma_cachep,=
 GFP_KERNEL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_set(&anon_vma->refcnt, 1);
> }
>
> void anon_vma_free(struct anon_vma *anon_vma)
> {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * This called when anon_vma is..
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * - anon_vma->vma_list becomes empty.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * - incremetned refcnt while migration, ksm e=
tc.. is dropped.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * - allocated but unused.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (atomic_dec_and_test(&anon_vma->refcnt))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kmem_cache_free(an=
on_vma_cachep, anon_vma);
> }
> =3D=3D
> Then all things will go simple.
> Overhead is concern but list_empty() helps us much.

When they made things complicated without atomic_op,
there was reasonable reason, I think. :)

My opinion depends on you and server guys(Hugh, Rik, Andrea Arcangeli and s=
o on)


>
> Thanks,
> -Kame
>
>
>
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
