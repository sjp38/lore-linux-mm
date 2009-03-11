Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2341B6B003D
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 09:25:08 -0400 (EDT)
Received: by bwz18 with SMTP id 18so1365bwz.38
        for <linux-mm@kvack.org>; Wed, 11 Mar 2009 06:25:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <200903112254.56764.nickpiggin@yahoo.com.au>
References: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
	 <200903112254.56764.nickpiggin@yahoo.com.au>
Date: Wed, 11 Mar 2009 15:25:05 +0200
Message-ID: <8c5a844a0903110625y416e7a3ft448a44b1bf70c990@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: use list.h for vma list
From: Daniel Lowengrub <lowdanie@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 11, 2009 at 1:54 PM, Nick Piggin <nickpiggin@yahoo.com.au> wrot=
e:
> On Wednesday 11 March 2009 20:55:48 Daniel Lowengrub wrote:
>> diff -uNr linux-2.6.28.7.vanilla/arch/arm/mm/mmap.c
>> linux-2.6.28.7/arch/arm/mm/mmap.c
>>.....
>> - =A0 =A0 for (vma =3D find_vma(mm, addr); ; vma =3D vma->vm_next) {
>> + =A0 =A0 for (vma =3D find_vma(mm, addr); ; vma =3D vma->vma_next(vma))=
 {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* At this point: =A0(!vma || addr < vma->vm=
_end). */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (TASK_SIZE - len < addr) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>
> Careful with your replacements. I'd suggest a mechanical search &
> replace might be less error prone.

Thanks for pointing that out.  The code compiled and ran on my x86 machine
so I'll take an extra look at the other architectures.

>> linux-2.6.28.7/include/linux/mm.h
>> --- linux-2.6.28.7.vanilla/include/linux/mm.h 2009-03-06
>>...
>> +/* Interface for the list_head prev and next pointers. =A0They
>> + * don't let you wrap around the vm_list.
>> + */
>
> Hmm, I don't think these are really appropriate replacements for
> vma->vm_next. 2 branches and a lot of extra icache.
>
> A non circular list like hlist might work better, but I suspect if
> callers are converted properly to have conditions ensuring that it
> doesn't wrap and doesn't get NULL vmas passed in, then it could
> avoid both those branches and just be a wrapper around
> list_entry(vma->vm_list.next)
>
The main place I can think of where "list_entry(vma->vm_list.next)"
can be used without the extra conditionals is inside a loop where
we're going through every vma in the
list.  This is usually done  with "list_for_each_entry" which uses
"list_entry(...)" anyway.
But in all the places that we start from some point inside the list
(usually with a find_vma)
a regular "for" list is used with "vma_next" as the last parameter.
In this case it would
probably be better to use "list_for_each_entry_continue" which would
lower the amount of pointless calls to "vma_next".
The first condition in vma_next also does away with the excessive use
of the ternary operator in the mmap.c file.  Where else in the code
would it be faster to use
"list_entry(...)" together with conditionals?
I'll look through the code again with all this in mind and see if
calls to the vma_next function can be minimized to the point of
removing it like
you said.

>>  struct mm_struct {
>> -     struct vm_area_struct * mmap;           /* list of VMAs */
>> +     struct list_head mm_vmas;               /* list of VMAs */

>.... like this nice name change ;)
This and other parts of the patch are based on a previous attempt by
Paul Zijlstra.

>> @@ -988,7 +989,8 @@
>> =A0 =A0 =A0 lru_add_drain();
>> =A0 =A0 =A0 tlb =3D tlb_gather_mmu(mm, 0);
>> =A0 =A0 =A0 update_hiwater_rss(mm);
>> - =A0 =A0 end =3D unmap_vmas(&tlb, vma, address, end, &nr_accounted, det=
ails);
>> + =A0 =A0 end =3D unmap_vmas(&tlb, &mm->mm_vmas, vma, address, end,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &nr_accounted, details);
>
> Why do you change this if the caller knows where the list head is
> anyway, and extracts it from the mm? I'd prefer to keep changes to
> calling convention to a minimum (and I hope with the changes to
> vma_next I suggested then it wouldn't be needed to carry the list
> head around everywhere anyway).
>
The unmap_vmas was changed because sometimes (in exit_mmap for example)
"unmap_vmas" is used right after "detach_vmas_to_be_unmapped" which
now returns a list of the vmas we want to unmap.  Now that we already
have this list for free it seems like a good idea to be able to pass
it to "unmap_vmas".  Do you think that this causes
more damage than it's worth?
After reading what you said before, it looks like we could take better
advantage of this
if we use "list_entry(...) in unmap_vmas's main loop instead of a
regular for loop
with __vma_next.
Thank you for the helpful suggestions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
