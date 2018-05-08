Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 48CE36B02E0
	for <linux-mm@kvack.org>; Tue,  8 May 2018 17:04:11 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c187so459862pfa.20
        for <linux-mm@kvack.org>; Tue, 08 May 2018 14:04:11 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u1-v6sor2438366pls.81.2018.05.08.14.04.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 14:04:10 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: Proof-of-concept: better(?) page-table manipulation API
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20180507113124.ewpbrfd3anyg7pli@kshutemo-mobl1>
Date: Tue, 8 May 2018 14:04:07 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <C56B16CA-CADF-4270-85E5-776E9219D41A@amacapital.net>
References: <20180424154355.mfjgkf47kdp2by4e@black.fi.intel.com> <CALCETrVzD8oPv=h2q91AMdCHn3S782GmvsY-+mwoaPUw=5N7HQ@mail.gmail.com> <20180507113124.ewpbrfd3anyg7pli@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



>> On May 7, 2018, at 4:31 AM, Kirill A. Shutemov <kirill@shutemov.name> wro=
te:
>>=20
>> On Mon, May 07, 2018 at 04:51:57AM +0000, Andy Lutomirski wrote:
>> On Tue, Apr 24, 2018 at 8:44 AM Kirill A. Shutemov <
>> kirill.shutemov@linux.intel.com> wrote:
>>=20
>>> Hi everybody,
>>=20
>>> I've proposed to talk about page able manipulation API on the LSF/MM'201=
8,
>>> so I need something material to talk about.
>>=20
>>=20
>> I gave it a quick read.  I like the concept a lot, and I have a few
>> comments.
>=20
> Thank you for the input.
>=20
>>> +/*
>>> + * How manu bottom level we account to mm->pgtables_bytes
>>> + */
>>> +#define PT_ACCOUNT_LVLS 3
>>> +
>>> +struct pt_ptr {
>>> +       unsigned long *ptr;
>>> +       int lvl;
>>> +};
>>> +
>>=20
>> I think you've inherited something that I consider to be a defect in the
>> old code: you're conflating page *tables* with page table *entries*.  You=
r
>> 'struct pt_ptr' sounds like a pointer to an entire page table, but AFAICT=

>> you're using it to point to a specific entry within a table.  I think tha=
t
>> both the new core code and the code that uses it would be clearer and les=
s
>> error prone if you made the distinction explicit.  I can think of two cle=
an
>> ways to do it:
>>=20
>> 1. Add a struct pt_entry_ptr, and make it so that get_ptv(), etc take a
>> pt_entry_ptr instead of a pt_ptr.  Add a helper to find a pt_entry_ptr
>> given a pt_ptr and either an index or an address.
>>=20
>> 2. Don't allow pointers to page table entries at all.  Instead, get_ptv()=

>> would take an address or an index parameter.
>=20
> Well, I'm not sure how useful pointer to whole page tables are.
> Where do you them useful?

Hmm, that=E2=80=99s a fair question. I guess that, in your patch, you pass a=
round a ptv_t when you want to refer to a whole page table. That seems to wo=
rk okay. Maybe still rename ptp_t to ptep_t or similar to emphasize that it p=
oints to an entry, not a table.

That being said, once you implement map/unmap for real, it might be more nat=
ural for map to return a pointer to a table rather than a pointer to an entr=
y.

>=20
>  In x86-64 case I pretend that CR3 is single-entry page table. It
>  requires a special threatement in ptp_page_vaddr(), but works fine
>  otherwise.
>=20

Hmm. If you stick with that, it definitely needs better comments. Why do you=
 need this, though?  What=E2=80=99s the benefit over simply starting with a p=
ointer to the root table or a pointer to the first entry in the root table? =
 We certainly don=E2=80=99t want anyone to do ptp_set() on the fake CR3 entr=
y.

>=20
>>=20
>>> +/*
>>> + * When walking page tables, get the address of the next boundary,
>>> + * or the end address of the range if that comes earlier.  Although no
>>> + * vma end wraps to 0, rounded up __boundary may wrap to 0 throughout.
>>> + */
>>=20
>> I read this comment twice, and I still don't get it.  Can you clarify wha=
t
>> this function does and why you would use it?
>=20
> That's basically ported variant of p?d_addr_end. It helps step address by
> right value for the page table entry and handles wrapping properly.
>=20
> See example in copy_pt_range().

Ok

>=20
>>> +/* Operations on page table pointers */
>>> +
>>> +/* Initialize ptp_t with pointer to top page table level. */
>>> +static inline ptp_t ptp_init(struct mm_struct *mm)
>>> +{
>>> +       struct pt_ptr ptp =3D{
>>> +               .ptr =3D (unsigned long *)mm->pgd,
>>> +               .lvl =3D PT_TOP_LEVEL,
>>> +       };
>>> +
>>> +       return ptp;
>>> +}
>>> +
>>=20
>> On some architectures, there are multiple page table roots.  For example,=

>> ARM64 has a root for the kernel half of the address space and a root for
>> the user half (at least -- I don't fully understand it).  x86 PAE sort-of=

>> has four roots.  Would it make sense to expose this in the API for
>> real?
>=20
> I will give it a thought.
>=20
> Is there a reason not to threat it as an additional page table layer and
> deal with it in a unified way?

I was thinking that it would be more confusing to treat it as one table. Aft=
er all, it doesn=E2=80=99t exist in memory. Also, if anyone ever makes the t=
op half be per-cpu and the bottom half be per-mm (which would be awesome if x=
86 had hardware support, hint hint), then pretending that it=E2=80=99s one t=
able gets even weirder.  The code that emulates it as a table would have to k=
now what mm *and* what CPU it is faking.

>=20
>=20
>>> +static inline void ptp_walk(ptp_t *ptp, unsigned long addr)
>>> +{
>>> +       ptp->ptr =3D (unsigned long *)ptp_page_vaddr(ptp);
>>> +       ptp->ptr +=3D __pt_index(addr, --ptp->lvl);
>>> +}
>>=20
>> Can you add a comment that says what this function does?
>=20
> Okay, I will.
>=20
>> Why does it not change the level?
>=20
> It does. --ptp->lvl.

Hmm.

Maybe change this to ptp_t ptp_walk(ptp_t ptp, unsigned long addr)?  It=E2=80=
=99s less error prone and should generate identical code.

>=20
>>> +
>>> +static void ptp_free(struct mm_struct *mm, ptv_t ptv)
>>> +{
>>> +       if (ptv.lvl < PT_SPLIT_LOCK_LVLS)
>>> +               ptlock_free(pfn_to_page(ptv_pfn(ptv)));
>>> +}
>>> +
>>=20
>> As it stands, this is a function that seems easy easy to misuse given the=

>> confusion between page tables and page table entries.
>=20
> Hm. I probably have a blind spot, but I don't see it.
>=20

Hmm, I guess you=E2=80=99re right - it takes a ptv_t.

>> Finally, a general comment.  Actually fully implementing this the way
>> you've done it seems like a giant mess given that you need to support all=

>> architectures.  But couldn't you implement the new API as a wrapper aroun=
d
>> the old API so you automatically get all architectures?
>=20
> I will look into this. But I'm not sure if it possbile without measurable
> overhead.
>=20

So what?  Make x86 fast and everything else slow but correct. POWER, ARM64, a=
nd s390 will make themes fast. Everyone else can, too, if they care.=
