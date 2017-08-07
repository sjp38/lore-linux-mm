Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B759B6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 15:21:47 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b130so1027008oii.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:21:47 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id e131si5202030oib.185.2017.08.07.12.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 12:21:47 -0700 (PDT)
Received: by mail-io0-x235.google.com with SMTP id g35so6052625ioi.3
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 12:21:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN=P9ph4f3S3SwSpmpApKKnQ=ce6JXLcpqHG+oJ8EpmSiur0AA@mail.gmail.com>
References: <CACT4Y+bLGEC=14CUJpkMhw0toSxvbyqKj49kqqW+gCLLBDFu4A@mail.gmail.com>
 <CAGXu5jJhFt8JNFRnB-oiGjNy=Auo4bGx=i=DDtCa__20acANBQ@mail.gmail.com>
 <CAN=P9pj_jbTgGoiECmu-b=s+NOL6uTkPbXDueXLhs8C6PVbLHg@mail.gmail.com>
 <CAGXu5jLRG6Xee-dJGPwmbfcVFLuTP9+5mexJyvZamQQdSaHNtA@mail.gmail.com>
 <1502131739.1803.12.camel@gmail.com> <CAGXu5jKj0M55wK=0WE_uKJpiJ031J5jPVAZR-VA7_O2qJUi=BQ@mail.gmail.com>
 <CAN=P9pj0TSbwTogLAJrm=yszq+86X0EmXNK-0Oq9f7wQCkQRjA@mail.gmail.com>
 <CAGXu5jJOOvv=zgSWnKJOae0edKG8MUV1pto1ipijPiRsOdKr+Q@mail.gmail.com>
 <CAN=P9pgcuXUk=+TvFC83UT7xT66=X2ouvEEWxzVVeM2mC=Tk=g@mail.gmail.com>
 <CAGXu5jJNW5PYacSNrGGnyAxnv4cRuhbo+P9myHP9kcV7hMzhkA@mail.gmail.com> <CAN=P9ph4f3S3SwSpmpApKKnQ=ce6JXLcpqHG+oJ8EpmSiur0AA@mail.gmail.com>
From: Kees Cook <keescook@google.com>
Date: Mon, 7 Aug 2017 12:21:45 -0700
Message-ID: <CAGXu5j+x=vFrd7Owu=CgQcF7YtFAgPxUVo6G=Jzk6fo6mOQZqg@mail.gmail.com>
Subject: Re: binfmt_elf: use ELF_ET_DYN_BASE only for PIE breaks asan
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kostya Serebryany <kcc@google.com>
Cc: Daniel Micay <danielmicay@gmail.com>, Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Reid Kleckner <rnk@google.com>, Peter Collingbourne <pcc@google.com>, Evgeniy Stepanov <eugenis@google.com>

On Mon, Aug 7, 2017 at 12:16 PM, Kostya Serebryany <kcc@google.com> wrote:
>
>
> On Mon, Aug 7, 2017 at 12:12 PM, Kees Cook <keescook@google.com> wrote:
>>
>> On Mon, Aug 7, 2017 at 12:05 PM, Kostya Serebryany <kcc@google.com> wrote:
>> >
>> >
>> > On Mon, Aug 7, 2017 at 11:59 AM, Kees Cook <keescook@google.com> wrote:
>> >>
>> >> On Mon, Aug 7, 2017 at 11:56 AM, Kostya Serebryany <kcc@google.com>
>> >> wrote:
>> >> > Is it possible to implement some userspace<=>kernel interface that
>> >> > will
>> >> > allow applications (sanitizers)
>> >> > to request *fixed* address ranges from the kernel at startup (so that
>> >> > the
>> >> > kernel couldn't refuse)?
>> >>
>> >> Wouldn't building non-PIE accomplish this?
>> >
>> >
>> > Well, many asan users do need PIE.
>> > Then, non-PIE only applies to the main executable, all DSOs are still
>> > PIC and the old change that moved DSOs from 0x7fff to 0x5555 caused us
>> > quite
>> > a bit of trouble too, even w/o PIE
>>
>> Hm? You can build non-PIE executables leaving all the DSOs PIC.
>
>
> Yes, but this won't help if the users actually want PIE executables.

But who wants a PIE executable that isn't randomized? (Or did I
misunderstand you? You want to allow userspace to declare the
randomization range? Doesn't *San use fixed addresses already, so ASLR
isn't actually a security defense? And if we did have such an
interface it would just lead us right back to security vulnerabilities
like the one this fix was trying to deal with ...)

>> If what you want is to entirely disable userspace ASLR under *San, you
>> can just set the ADDR_NO_RANDOMIZE personality flag.
>
>
> Mmm. How? Could you please elaborate?
> Do you suggest to call personality(ADDR_NO_RANDOMIZE) and re-execute the
> process?
> Or can I somehow set ADDR_NO_RANDOMIZE at link time?

I've normally seen it done with a launcher that sets the personality
and execs the desired executable.

Another future path would be to collapse the PIE load range into the
DSO load range (as now done when a loader executes a PIE binary).

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
