Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79D3B280289
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 17:48:18 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id p144so2411763itc.9
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 14:48:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l26sor3391481ioc.315.2018.01.05.14.48.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jan 2018 14:48:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <nycvar.YFH.7.76.1801052213140.11852@cbobk.fhfr.pm>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com> <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com> <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
 <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com> <20a54a5f-f4e5-2126-fb73-6a995d13d52d@linux.intel.com>
 <alpine.LRH.2.00.1801051909160.27010@gjva.wvxbf.pm> <282e2a56-ded1-6eb9-5ecb-22858c424bd7@linux.intel.com>
 <nycvar.YFH.7.76.1801052014050.11852@cbobk.fhfr.pm> <868196c9-52ed-4270-968f-97b7a6784f61@linux.intel.com>
 <nycvar.YFH.7.76.1801052213140.11852@cbobk.fhfr.pm>
From: Hugh Dickins <hughd@google.com>
Date: Fri, 5 Jan 2018 14:48:16 -0800
Message-ID: <CANsGZ6ZxRTyov9CWD33J3h8KZdbmS3jUacMz4ohRYbwmWEXb5w@mail.gmail.com>
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@google.com>, x86@kernel.org, Andrea Arcangeli <aarcange@redhat.com>

On Fri, Jan 5, 2018 at 1:14 PM, Jiri Kosina <jikos@kernel.org> wrote:
> On Fri, 5 Jan 2018, Dave Hansen wrote:
>
>> >>> --- a/arch/x86/platform/efi/efi_64.c
>> >>> +++ b/arch/x86/platform/efi/efi_64.c
>> >>> @@ -95,6 +95,12 @@ pgd_t * __init efi_call_phys_prolog(void
>> >>>           save_pgd[pgd] = *pgd_offset_k(pgd * PGDIR_SIZE);
>> >>>           vaddress = (unsigned long)__va(pgd * PGDIR_SIZE);
>> >>>           set_pgd(pgd_offset_k(pgd * PGDIR_SIZE), *pgd_offset_k(vaddress));
>> >>> +         /*
>> >>> +          * pgprot API doesn't clear it for PGD
>> >>> +          *
>> >>> +          * Will be brought back automatically in _epilog()
>> >>> +          */
>> >>> +         pgd_offset_k(pgd * PGDIR_SIZE)->pgd &= ~_PAGE_NX;
>> >>>   }
>> >>>   __flush_tlb_all();
>> >>
>> >> Wait a sec...  Where does the _PAGE_USER come from?  Shouldn't we see
>> >> the &init_mm in there and *not* set _PAGE_USER?
>> >
>> > That's because pgd_populate() uses _PAGE_TABLE and not _KERNPG_TABLE for
>> > reasons that are behind me.

Oh, I completely missed that; and then the issue would have got hidden
by one of my later per-process-kaiser patches.

>> >
>> > I did put this on my TODO list, but for later.
>> >
>> > (and yes, I tried clearing _PAGE_USER from init_mm's PGD, and no obvious
>> > breakages appeared, but I wanted to give it more thought later).
>>
>> Feel free to add my Ack on this.

And mine - thanks a lot for dealing with this Jiri.

>
> Thanks. I'll extract the patch out of this thread and submit it
> separately, so that it doesn't get lost buried here.
>
>> I'd personally much rather muck with random relatively unused bits of
>> the efi code than touch the core PGD code.
>
> Exactly. Especially at this point.

Indeed.

>
>> We need to go look at it again in the 4.16 timeframe, probably.
>
> Agreed. On my TODO list already.
>
> Thanks,
>
> --
> Jiri Kosina
> SUSE Labs
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
