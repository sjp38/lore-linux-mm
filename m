Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B50F56B004D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 07:03:20 -0400 (EDT)
Received: by gxk18 with SMTP id 18so631022gxk.14
        for <linux-mm@kvack.org>; Fri, 05 Jun 2009 04:03:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090603132751.GA1813@cmpxchg.org>
References: <20090602223738.GA15475@cmpxchg.org>
	 <20090602233457.GY1065@one.firstfloor.org>
	 <20090603132751.GA1813@cmpxchg.org>
Date: Fri, 5 Jun 2009 20:03:17 +0900
Message-ID: <28c262360906050403o3b24aa92tf47cab8a3cbc2ab9@mail.gmail.com>
Subject: Re: [patch][v2] swap: virtual swap readahead
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Hannes.

On Wed, Jun 3, 2009 at 10:27 PM, Johannes Weiner<hannes@cmpxchg.org> wrote:
> On Wed, Jun 03, 2009 at 01:34:57AM +0200, Andi Kleen wrote:
>> On Wed, Jun 03, 2009 at 12:37:39AM +0200, Johannes Weiner wrote:
>> > + *
>> > + * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
>> > + */
>> > +struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struc=
t vm_area_struct *vma, unsigned long addr)
>> > +{
>> > + =C2=A0 unsigned long start, pos, end;
>> > + =C2=A0 unsigned long pmin, pmax;
>> > + =C2=A0 int cluster, window;
>> > +
>> > + =C2=A0 if (!vma || !vma->vm_mm) =C2=A0 =C2=A0 =C2=A0 =C2=A0/* XXX: s=
hmem case */
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return swapin_readahead_phys(entr=
y, gfp_mask, vma, addr);
>> > +
>> > + =C2=A0 cluster =3D 1 << page_cluster;
>> > + =C2=A0 window =3D cluster << PAGE_SHIFT;
>> > +
>> > + =C2=A0 /* Physical range to read from */
>> > + =C2=A0 pmin =3D swp_offset(entry) & ~(cluster - 1);
>>
>> Is cluster really properly sign extended on 64bit? Looks a little
>> dubious. long from the start would be safer
>
> Fixed.
>
>> > + =C2=A0 /* Virtual range to read from */
>> > + =C2=A0 start =3D addr & ~(window - 1);
>>
>> Same.
>
> Fixed.
>
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgd =3D pgd_offset(vma->vm_mm, po=
s);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pgd_present(*pgd))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pud =3D pud_offset(pgd, pos);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pud_present(*pud))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pmd =3D pmd_offset(pud, pos);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pmd_present(*pmd))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pte =3D pte_offset_map_lock(vma->=
vm_mm, pmd, pos, &ptl);
>>
>> You could be more efficient here by using the standard mm/* nested loop
>> pattern that avoids relookup of everything in each iteration. I suppose
>> it would mainly make a difference with 32bit highpte where mapping a pte
>> can be somewhat costly. And you would take less locks this way.
>
> I ran into weird problems here. =C2=A0The above version is actually faste=
r
> in the benchmarks than writing a nested level walker or using
> walk_page_range(). =C2=A0Still digging but it can take some time. =C2=A0B=
usy
> week :(
>
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D read_swap_cache_async(sw=
p, gfp_mask, vma, pos);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!page)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>>
>> That's out of memory, break would be better here because prefetch
>> while oom is usually harmful.
>
> It can also happen due to a race with something releasing the swap
> slot (i.e. swap_duplicate() fails). =C2=A0But the old version did a break
> too and this patch shouldn't do it differently. =C2=A0Fixed.

I think it would be better to read fault page earlier than readahead pages.
That's because,
1) Readahead pages would prevent to read fault page due to out-of-memory.
2)  If we can't get the fault page, we don't need extra pages(ie,
readahead pages)
     It's waste of memory or IO bandwidth. It's what you want.
3) If we read fault page at first and meet oom, we can also stop readahead.

--=20
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
