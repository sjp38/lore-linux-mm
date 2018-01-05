Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA31F280284
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 16:29:53 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id t88so3406519pfg.17
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 13:29:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4sor2248528plb.144.2018.01.05.13.29.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jan 2018 13:29:52 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page tables (core patch)
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <nycvar.YFH.7.76.1801052213140.11852@cbobk.fhfr.pm>
Date: Fri, 5 Jan 2018 13:29:50 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <F42FA32C-2774-4E21-8A3E-3B52F714DBFA@amacapital.net>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003447.1DB395E3@viggo.jf.intel.com> <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com> <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com> <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com> <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com> <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm> <282e2a56-ded1-6eb9-5ecb-22858c424bd7@linux.intel.com> <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm> <868196c9-52ed-4270-968f-97b7a6784f61@linux.intel.com> <nycvar.YFH.7.76.1801052213140.11852@cbobk.fhfr.pm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, hughd@google.com, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>



> On Jan 5, 2018, at 1:14 PM, Jiri Kosina <jikos@kernel.org> wrote:
>=20
> On Fri, 5 Jan 2018, Dave Hansen wrote:
>=20
>>>>> --- a/arch/x86/platform/efi/efi_64.c
>>>>> +++ b/arch/x86/platform/efi/efi_64.c
>>>>> @@ -95,6 +95,12 @@ pgd_t * __init efi_call_phys_prolog(void
>>>>>        save_pgd[pgd] =3D *pgd_offset_k(pgd * PGDIR_SIZE);
>>>>>        vaddress =3D (unsigned long)__va(pgd * PGDIR_SIZE);
>>>>>        set_pgd(pgd_offset_k(pgd * PGDIR_SIZE), *pgd_offset_k(vaddress)=
);
>>>>> +        /*
>>>>> +         * pgprot API doesn't clear it for PGD
>>>>> +         *
>>>>> +         * Will be brought back automatically in _epilog()
>>>>> +         */
>>>>> +        pgd_offset_k(pgd * PGDIR_SIZE)->pgd &=3D ~_PAGE_NX;
>>>>>    }
>>>>>    __flush_tlb_all();
>>>>=20
>>>> Wait a sec...  Where does the _PAGE_USER come from?  Shouldn't we see
>>>> the &init_mm in there and *not* set _PAGE_USER?
>>>=20
>>> That's because pgd_populate() uses _PAGE_TABLE and not _KERNPG_TABLE for=
=20
>>> reasons that are behind me.
>>>=20
>>> I did put this on my TODO list, but for later.
>>>=20
>>> (and yes, I tried clearing _PAGE_USER from init_mm's PGD, and no obvious=
=20
>>> breakages appeared, but I wanted to give it more thought later).
>>=20
>> Feel free to add my Ack on this. =20
>=20
> Thanks. I'll extract the patch out of this thread and submit it=20
> separately, so that it doesn't get lost buried here.
>=20
>> I'd personally much rather muck with random relatively unused bits of=20
>> the efi code than touch the core PGD code.
>=20
> Exactly. Especially at this point.
>=20
>> We need to go look at it again in the 4.16 timeframe, probably.
>=20
> Agreed. On my TODO list already.

Can we just delete the old memmap code instead?

--Andy

>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
