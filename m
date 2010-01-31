Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6CF7C6B0047
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 13:56:33 -0500 (EST)
Received: by pzk8 with SMTP id 8so164613pzk.22
        for <linux-mm@kvack.org>; Sun, 31 Jan 2010 10:56:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1001311616590.5897@sister.anvils>
References: <6cafb0f01001291657q4ccbee86rce3143a4be7a1433@mail.gmail.com>
	 <201001301929.47659.rjw@sisk.pl>
	 <alpine.LSU.2.00.1001311616590.5897@sister.anvils>
Date: Sun, 31 Jan 2010 10:56:31 -0800
Message-ID: <6cafb0f01001311056k3c6a882fla42b714256bb1e6d@mail.gmail.com>
Subject: Re: Bug in find_vma_prev - mmap.c
From: Tony Perkins <da.perk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jan 31, 2010 at 8:25 AM, Hugh Dickins
<hugh.dickins@tiscali.co.uk> wrote:
> On Sat, 30 Jan 2010, Rafael J. Wysocki wrote:
>
>> [Adding CCs]
>>
>> On Saturday 30 January 2010, Tony Perkins wrote:
>> > This code returns vma (mm->mmap) if it sees that addr is lower than fi=
rst VMA.
>> > However, I think it falsely returns vma (mm->mmap) on the case where
>> > addr is in the first VMA.
>> >
>> > If it is the first VMA region:
>> > - *pprev should be set to NULL
>> > - implying prev is NULL
>> > - and should therefore return vma (so in this case, I just added if
>> > it's the first VMA and it's within range)
>> >
>> > /* Same as find_vma, but also return a pointer to the previous VMA in =
*pprev. */
>> > struct vm_area_struct *
>> > find_vma_prev(struct mm_struct *mm, unsigned long addr,
>> > =A0 =A0 =A0 =A0 =A0 =A0 struct vm_area_struct **pprev)
>> > {
>> > =A0 =A0 struct vm_area_struct *vma =3D NULL, *prev =3D NULL;
>> > =A0 =A0 struct rb_node *rb_node;
>> > =A0 =A0 if (!mm)
>> > =A0 =A0 =A0 =A0 goto out;
>> >
>> > =A0 =A0 /* Guard against addr being lower than the first VMA */
>> > =A0 =A0 vma =3D mm->mmap;
>> >
>> > =A0 =A0 /* Go through the RB tree quickly. */
>> > =A0 =A0 rb_node =3D mm->mm_rb.rb_node;
>> >
>> > =A0 =A0 while (rb_node) {
>> > =A0 =A0 =A0 =A0 struct vm_area_struct *vma_tmp;
>> > =A0 =A0 =A0 =A0 vma_tmp =3D rb_entry(rb_node, struct vm_area_struct, v=
m_rb);
>> >
>> > =A0 =A0 =A0 =A0 if (addr < vma_tmp->vm_end) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 // TONY: if (vma_tmp->vm_start <=3D addr) vma =
=3D vma_tmp; //
>> > this returns the correct 'vma' when vma is the first node (i.e., no
>> > prev)
>> > =A0 =A0 =A0 =A0 =A0 =A0 rb_node =3D rb_node->rb_left;
>> > =A0 =A0 =A0 =A0 } else {
>> > =A0 =A0 =A0 =A0 =A0 =A0 prev =3D vma_tmp;
>> > =A0 =A0 =A0 =A0 =A0 =A0 if (!prev->vm_next || (addr < prev->vm_next->v=
m_end))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > =A0 =A0 =A0 =A0 =A0 =A0 rb_node =3D rb_node->rb_right;
>> > =A0 =A0 =A0 =A0 }
>> > =A0 =A0 }
>> >
>> > out:
>> > =A0 =A0 *pprev =3D prev;
>> > =A0 =A0 return prev ? prev->vm_next : vma;
>> > }
>> >
>> > Is this a known issue and/or has this problem been addressed?
>> > Also, please CC my email address with responses.
>>
>> Well, I guess you should let the mm people know (CCs added).
>
> Sorry, I don't see what the problem is: I may be misunderstanding.
> Why do you think it is wrong to return the vma which addr is in
> (whether or not that's the first vma)?
>
> find_vma_prev() is supposed to return the same vma as find_vma()
> does, but additionally fill in *pprev. =A0And find_vma() is supposed
> to return the vma containing or the next vma above the addr supplied.
>
> Hugh
>


Right Hugh,

Say for instance, that addr is not in the list (but is greater than
the last element).
find_vma_prev will return the last node in the list, whereas find_vma
will return NULL.

It seems that it is just inconsistent, in what it should return
regarding the two.
For instance, find_vma_prev will never return NULL, if there's at
least one node within the tree, whereas find_vma would.
find_extend_vma uses find_vma_prev and checks to see if it returns
NULL and is less than the return address (which would always be the
case).

Thanks!

--=20
Aim for Perfection!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
