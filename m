Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B36CA6B02AB
	for <linux-mm@kvack.org>; Thu,  6 May 2010 05:47:19 -0400 (EDT)
Received: by iwn14 with SMTP id 14so7706251iwn.22
        for <linux-mm@kvack.org>; Thu, 06 May 2010 02:47:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100506002255.GY20979@csn.ul.ie>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>
	 <1273065281-13334-2-git-send-email-mel@csn.ul.ie>
	 <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org>
	 <20100505145620.GP20979@csn.ul.ie>
	 <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
	 <20100505175311.GU20979@csn.ul.ie>
	 <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org>
	 <20100506002255.GY20979@csn.ul.ie>
Date: Thu, 6 May 2010 18:47:12 +0900
Message-ID: <p2s28c262361005060247m2983625clff01aeaa1668402f@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing the
	wrong VMA information
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 6, 2010 at 9:22 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Wed, May 05, 2010 at 11:02:25AM -0700, Linus Torvalds wrote:
>>
>>
>> On Wed, 5 May 2010, Mel Gorman wrote:
>> >
>> > If the same_vma list is properly ordered then maybe something like the
>> > following is allowed?
>>
>> Heh. This is the same logic I just sent out. However:
>>
>> > + =C2=A0 anon_vma =3D page_rmapping(page);
>> > + =C2=A0 if (!anon_vma)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;
>> > +
>> > + =C2=A0 spin_lock(&anon_vma->lock);
>>
>> RCU should guarantee that this spin_lock() is valid, but:
>>
>> > + =C2=A0 /*
>> > + =C2=A0 =C2=A0* Get the oldest anon_vma on the list by depending on t=
he ordering
>> > + =C2=A0 =C2=A0* of the same_vma list setup by __page_set_anon_rmap
>> > + =C2=A0 =C2=A0*/
>> > + =C2=A0 avc =3D list_entry(&anon_vma->head, struct anon_vma_chain, sa=
me_anon_vma);
>>
>> We're not guaranteed that the 'anon_vma->head' list is non-empty.
>>
>> Somebody could have freed the list and the anon_vma and we have a stale
>> 'page->anon_vma' (that has just not been _released_ yet).
>>
>> And shouldn't that be 'list_first_entry'? Or &anon_vma->head.next?
>>
>> How did that line actually work for you? Or was it just a "it boots", bu=
t
>> no actual testing of the rmap walk?
>>
>
> This is what I just started testing on a 4-core machine. Lockdep didn't
> complain but there are two potential sources of badness in anon_vma_lock_=
root
> marked with XXX. The second is the most important because I can't see how=
 the
> local and root anon_vma locks can be safely swapped - i.e. release local =
and
> get the root without the root disappearing. I haven't considered the othe=
r
> possibilities yet such as always locking the root anon_vma. Going to
> sleep on it.
>
> Any comments?

<snip>
> +/* Given an anon_vma, find the root of the chain, lock it and return the=
 root */
> +struct anon_vma *anon_vma_lock_root(struct anon_vma *anon_vma)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct anon_vma *root_anon_vma;
> + =C2=A0 =C2=A0 =C2=A0 struct anon_vma_chain *avc, *root_avc;
> + =C2=A0 =C2=A0 =C2=A0 struct vm_area_struct *vma;
> +
> + =C2=A0 =C2=A0 =C2=A0 /* Lock the same_anon_vma list and make sure we ar=
e on a chain */
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&anon_vma->lock);
> + =C2=A0 =C2=A0 =C2=A0 if (list_empty(&anon_vma->head)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&anon_vma-=
>lock);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return NULL;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Get the root anon_vma on the list by depen=
ding on the ordering
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* of the same_vma list setup by __page_set_a=
non_rmap. Basically
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* we are doing
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* local anon_vma -> local vma -> deepest vma=
 -> anon_vma
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 avc =3D list_first_entry(&anon_vma->head, struct a=
non_vma_chain, same_anon_vma);

Dumb question.

I can't understand why we should use list_first_entry.

I looked over the code.
anon_vma_chain_link uses list_add_tail so I think that's right.
But anon_vma_prepare uses list_add. So it's not consistent.
How do we make sure list_first_entry returns deepest vma?

Sorry if I am missing.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
