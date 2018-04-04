Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5B886B0003
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 12:09:10 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i21so553072qtp.10
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 09:09:10 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0063.outbound.protection.outlook.com. [104.47.33.63])
        by mx.google.com with ESMTPS id c21si6577313qka.228.2018.04.04.09.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 04 Apr 2018 09:09:10 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH 09/11] x86/pti: enable global pages for shared areas
Date: Wed, 4 Apr 2018 16:09:07 +0000
Message-ID: <2D4AE288-DD01-416B-9633-1BC9B6A20BFF@vmware.com>
References: <20180404010946.6186729B@viggo.jf.intel.com>
 <20180404011007.A381CC8A@viggo.jf.intel.com>
 <5DEE9F6E-535C-4DBF-A513-69D9FD5C0235@vmware.com>
 <50385d91-58a9-4b14-06bc-2340b99933c3@linux.intel.com>
In-Reply-To: <50385d91-58a9-4b14-06bc-2340b99933c3@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <05255EB8D8517549915D5EB3357BD3D9@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "keescook@google.com" <keescook@google.com>, Hugh Dickins <hughd@google.com>, Juergen Gross <jgross@suse.com>, "x86@kernel.org" <x86@kernel.org>

Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 04/03/2018 09:45 PM, Nadav Amit wrote:
>> Dave Hansen <dave.hansen@linux.intel.com> wrote:
>>=20
>>> From: Dave Hansen <dave.hansen@linux.intel.com>
>>>=20
>>> The entry/exit text and cpu_entry_area are mapped into userspace and
>>> the kernel.  But, they are not _PAGE_GLOBAL.  This creates unnecessary
>>> TLB misses.
>>>=20
>>> Add the _PAGE_GLOBAL flag for these areas.
>>>=20
>>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>>> Cc: Andy Lutomirski <luto@kernel.org>
>>> Cc: Linus Torvalds <torvalds@linux-foundation.org>
>>> Cc: Kees Cook <keescook@google.com>
>>> Cc: Hugh Dickins <hughd@google.com>
>>> Cc: Juergen Gross <jgross@suse.com>
>>> Cc: x86@kernel.org
>>> Cc: Nadav Amit <namit@vmware.com>
>>> ---
>>>=20
>>> b/arch/x86/mm/cpu_entry_area.c |   10 +++++++++-
>>> b/arch/x86/mm/pti.c            |   14 +++++++++++++-
>>> 2 files changed, 22 insertions(+), 2 deletions(-)
>>>=20
>>> diff -puN arch/x86/mm/cpu_entry_area.c~kpti-why-no-global arch/x86/mm/c=
pu_entry_area.c
>>> --- a/arch/x86/mm/cpu_entry_area.c~kpti-why-no-global	2018-04-02 16:41:=
17.157605167 -0700
>>> +++ b/arch/x86/mm/cpu_entry_area.c	2018-04-02 16:41:17.162605167 -0700
>>> @@ -27,8 +27,16 @@ EXPORT_SYMBOL(get_cpu_entry_area);
>>> void cea_set_pte(void *cea_vaddr, phys_addr_t pa, pgprot_t flags)
>>> {
>>> 	unsigned long va =3D (unsigned long) cea_vaddr;
>>> +	pte_t pte =3D pfn_pte(pa >> PAGE_SHIFT, flags);
>>>=20
>>> -	set_pte_vaddr(va, pfn_pte(pa >> PAGE_SHIFT, flags));
>>> +	/*
>>> +	 * The cpu_entry_area is shared between the user and kernel
>>> +	 * page tables.  All of its ptes can safely be global.
>>> +	 */
>>> +	if (boot_cpu_has(X86_FEATURE_PGE))
>>> +		pte =3D pte_set_flags(pte, _PAGE_GLOBAL);
>>=20
>> I think it would be safer to check that the PTE is indeed present before
>> setting _PAGE_GLOBAL. For example, percpu_setup_debug_store() sets PAGE_=
NONE
>> for non-present entries. In this case, since PAGE_NONE and PAGE_GLOBAL u=
se
>> the same bit, everything would be fine, but it might cause bugs one day.
>=20
> That's a reasonable safety thing to add, I think.
>=20
> But, looking at it, I am wondering why we did this in
> percpu_setup_debug_store():
>=20
>        for (; npages; npages--, cea +=3D PAGE_SIZE)
>                cea_set_pte(cea, 0, PAGE_NONE);
>=20
> Did we really want that to be PAGE_NONE, or was it supposed to create a
> PTE that returns true for pte_none()?

I yield it to others to answer...

>=20
>>> /*
>>> +		 * Setting 'target_pmd' below creates a mapping in both
>>> +		 * the user and kernel page tables.  It is effectively
>>> +		 * global, so set it as global in both copies.  Note:
>>> +		 * the X86_FEATURE_PGE check is not _required_ because
>>> +		 * the CPU ignores _PAGE_GLOBAL when PGE is not
>>> +		 * supported.  The check keeps consistentency with
>>> +		 * code that only set this bit when supported.
>>> +		 */
>>> +		if (boot_cpu_has(X86_FEATURE_PGE))
>>> +			*pmd =3D pmd_set_flags(*pmd, _PAGE_GLOBAL);
>>=20
>> Same here.
>=20
> Is there  a reason that the pmd_none() check above this does not work?

For any practical reasons, right now, it should be fine. But pmd_none() wil=
l
not save us if _PAGE_PROTNONE ever changes, for example. Note that the chec=
k
is with pmd_none() and not pmd_protnone().
