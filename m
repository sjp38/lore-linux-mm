Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 417B962009A
	for <linux-mm@kvack.org>; Thu,  6 May 2010 11:59:58 -0400 (EDT)
Received: by gxk10 with SMTP id 10so74491gxk.10
        for <linux-mm@kvack.org>; Thu, 06 May 2010 08:59:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.1005060703540.901@i5.linux-foundation.org>
References: <1273065281-13334-1-git-send-email-mel@csn.ul.ie>
	 <1273065281-13334-2-git-send-email-mel@csn.ul.ie>
	 <alpine.LFD.2.00.1005050729000.5478@i5.linux-foundation.org>
	 <20100505145620.GP20979@csn.ul.ie>
	 <alpine.LFD.2.00.1005050815060.5478@i5.linux-foundation.org>
	 <20100505175311.GU20979@csn.ul.ie>
	 <alpine.LFD.2.00.1005051058380.27218@i5.linux-foundation.org>
	 <20100506002255.GY20979@csn.ul.ie>
	 <p2s28c262361005060247m2983625clff01aeaa1668402f@mail.gmail.com>
	 <alpine.LFD.2.00.1005060703540.901@i5.linux-foundation.org>
Date: Fri, 7 May 2010 00:59:55 +0900
Message-ID: <s2j28c262361005060859ga196a23eq8f4ee0c8ce5f3ea9@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing the
	wrong VMA information
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 6, 2010 at 11:06 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> On Thu, 6 May 2010, Minchan Kim wrote:
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 avc =3D list_first_entry(&anon_vma->head, struc=
t anon_vma_chain, same_anon_vma);
>>
>> Dumb question.
>>
>> I can't understand why we should use list_first_entry.
>
> It's not that we "should" use list_entry_first. It's that we want to find
> _any_ entry on the list, and the most natural one is the first one.
>
> So we could take absolutely any 'avc' entry that is reachable from the
> anon_vma, and use that to look up _any_ 'vma' that is associated with tha=
t
> anon_vma. And then, from _any_ of those vma's, we know how to get to the
> "root anon_vma" - the one that they are all associated with.
>
> So no, there's absolutely nothing special about the first entry. It's
> just a random easily found one.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linus
>

Thanks, Linus and Mel.
You understood my question correctly. :)

My concern was following case.

Child process does mmap new VMA but anon_vma is reused nearer child's
VMA which is linked parent's VMA by fork.
In that case, anon_vma_prepare calls list_add not list_add_tail.
ex) list_add(&avc->same_anon_vma, &anon_vma->head);

It means list_first_entry is the new VMA not old VMA and new VMA's
root_avc isn't linked at parent's one. It means we are locking each
other locks. That's why I have a question.

But I carefully looked at the reusable_anon_vma and found
list_is_singular. I remember Linus changed it to make problem simple.
So in my scenario, new VMA can't share old VMA's anon_vma.

So my story is broken.
If I miss something, please, correct me. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
