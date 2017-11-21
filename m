Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB8736B0069
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:46:08 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id b17so7626592oth.6
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:46:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s3sor4906432otd.76.2017.11.21.14.46.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Nov 2017 14:46:07 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 12/30] x86, kaiser: map GDT into user page tables
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <f71ce70f-ea43-d22f-1a2a-fdf4e9dab6af@linux.intel.com>
Date: Tue, 21 Nov 2017 15:46:05 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <CBD89E9B-C146-42AE-A117-507C01CBF885@amacapital.net>
References: <20171110193058.BECA7D88@viggo.jf.intel.com> <20171110193125.EBF58596@viggo.jf.intel.com> <alpine.DEB.2.20.1711202115190.2348@nanos> <CALCETrVtXQbcTx6ZAjZGL3D8Z0OootVuP7saUdheBsW+mN6cvw@mail.gmail.com> <f71ce70f-ea43-d22f-1a2a-fdf4e9dab6af@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>



> On Nov 21, 2017, at 2:19 PM, Dave Hansen <dave.hansen@linux.intel.com> wro=
te:
>=20
> On 11/20/2017 12:46 PM, Andy Lutomirski wrote:
>>>> +     /*
>>>> +      * We could theoretically do this in setup_fixmap_gdt().
>>>> +      * But, we would need to rewrite the above page table
>>>> +      * allocation code to use the bootmem allocator.  The
>>>> +      * buddy allocator is not available at the time that we
>>>> +      * call setup_fixmap_gdt() for CPU 0.
>>>> +      */
>>>> +     kaiser_add_user_map_early(get_cpu_gdt_ro(0), PAGE_SIZE,
>>>> +                               __PAGE_KERNEL_RO | _PAGE_GLOBAL);
>>> This one is needs to stay.
>> When you rebase on to my latest version, this should change to mapping
>> the entire cpu_entry_area.
>=20
> I did this, but unfortunately it ends up having to individually map all
> four pieces of cpu_entry_area.  They all need different permissions and
> while theoretically we could do TSS+exception-stacks in the same call,
> they're not next to each other:
>=20
> GDT: R/O
> TSS: R/W at least because of trampoline stack
> entry code: EXEC+R/O
> exception stacks: R/W

Can you avoid code duplication by adding some logic right after the kernel c=
pu_entry_area is set up to iterate page by page over the PTEs in the cpu_ent=
ry_area for that CPU and just install exactly the same PTEs into the kaiser t=
able?  E.g. just call kaiser_add_mapping once per page but with the paramete=
rs read out from the fixmap PTEs instead of hard coded?

As a fancier but maybe better option, we could fiddle with the fixmap indice=
s so that the whole cpu_entry_area range is aligned to a PMD boundary or hig=
her.  We'd preallocate all the page tables for this range before booting any=
 APs.  Then the kaiser tables could just reference the same page tables, and=
 we don't need any AP kaiser setup at all.

This should be a wee bit faster, too, since we reduce the number of cache li=
nes needed to refill the TLB when needed.

I'm really hoping we can get rid of kaiser_add_mapping entirely.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
