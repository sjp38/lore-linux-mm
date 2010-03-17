Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E6046B007D
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 00:15:16 -0400 (EDT)
Received: by pxi34 with SMTP id 34so437049pxi.22
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 21:15:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100317121551.b619f55b.kamezawa.hiroyu@jp.fujitsu.com>
References: <1268412087-13536-1-git-send-email-mel@csn.ul.ie>
	 <28c262361003141728g4aa40901hb040144c5a4aeeed@mail.gmail.com>
	 <20100315143420.6ec3bdf9.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100315112829.GI18274@csn.ul.ie>
	 <1268657329.1889.4.camel@barrios-desktop>
	 <20100315142124.GL18274@csn.ul.ie>
	 <20100316084934.3798576c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100317111234.d224f3fd.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361003162000w34cc13ecnbd32840a0df80f95@mail.gmail.com>
	 <20100317121551.b619f55b.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 17 Mar 2010 13:15:14 +0900
Message-ID: <28c262361003162115k79e3d40fka6e1def6472823ef@mail.gmail.com>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
	anonymous pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 12:15 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 17 Mar 2010 12:00:15 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Wed, Mar 17, 2010 at 11:12 AM, KAMEZAWA Hiroyuki
>> > BTW, I doubt freeing anon_vma can happen even when we check mapcount.
>> >
>> > "unmap" is 2-stage operation.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A01. unmap_vmas() =3D> modify ptes, free page=
s, etc.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A02. free_pgtables() =3D> free pgtables, unli=
nk vma and free it.
>> >
>> > Then, if migration is enough slow.
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Migration(): =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Exit()=
:
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0check mapcount
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_lock
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0replace pte with migration pte
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_unlock
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0pte_lock
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0copy page etc... =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zap pte (clear p=
te)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0pte_unlock
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0free_pgtables
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0->free vma
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0->free anon_vma
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_lock
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0remap pte with new pfn(fail)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_unlock
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0lock anon_vma->lock =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 # modification after free.
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0check list is empty
>>
>> check list is empty?
>> Do you mean anon_vma->head?
>>
> yes.
>
>> If it is, is it possible that that list isn't empty since anon_vma is
>> used by others due to
>> SLAB_DESTROY_BY_RCU?
>>
> There are 4 cases.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0A) anon_vma->list is not empty because anon_vm=
a is not freed.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0B) anon_vma->list is empty because it's freed.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0C) anon_vma->list is empty but it's reused.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0D) anon_vma->list is not empty but it's reused=
.

E) anon_vma is used for other object.

That's because we don't hold rcu_read_lock.
I think Mel met this E) situation.

AFAIU, even slab page of SLAB_BY_RCU can be freed after grace period.
Do I miss something?

>
>> but such case is handled by page_check_address, vma_address, I think.
>>
> yes. Then, this corrupt nothing, as I wrote. We just modify anon_vma->loc=
k
> and it's safe because of SLAB_DESTROY_BY_RCU.
>
>
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock anon_vma->lock
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0free anon_vma
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_unlock
>> >
>> >
>> > Hmm. IIUC, anon_vma is allocated as SLAB_DESTROY_BY_RCU. Then, while
>> > rcu_read_lock() is taken, anon_vma is anon_vma even if freed. But it
>> > may reused as anon_vma for someone else.
>> > (IOW, it may be reused but never pushed back to general purpose memory
>> > =C2=A0until RCU grace period.)
>> > Then, touching anon_vma->lock never cause any corruption.
>> >
>> > Does use-after-free check for SLAB_DESTROY_BY_RCU correct behavior ?
>>
>> Could you elaborate your point?
>>
>
> Ah, my point is "how use-after-free is detected ?"
>
> If use-after-free is detected by free_pages() (DEBUG_PGALLOC), it seems
> strange because DESTROY_BY_RCU guarantee that never happens.
>
> So, I assume use-after-free is detected in SLAB layer. If so,
> in above B), C), D) case, it seems there is use-after free in slab's poin=
t
> of view but it works as expected, no corruption.
>
> Then, my question is
> "Does use-after-free check for SLAB_DESTROY_BY_RCU work correctly ?"
>

I am not sure Mel found that by DEBUG_PGALLOC.
But, E) case can be founded by DEBUG_PGALLOC.

> and implies we need this patch ?
> (But this will prevent unnecessary page copy etc. by easy check.)
>
> Thanks,
> -Kame
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
