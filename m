Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id BBDEA6B000D
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 09:12:41 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t9so13494205wrx.7
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 06:12:41 -0700 (PDT)
Received: from thoth.sbs.de (thoth.sbs.de. [192.35.17.2])
        by mx.google.com with ESMTPS id c8-v6si8510797wrb.289.2018.10.15.06.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 06:12:39 -0700 (PDT)
Subject: Re: [PATCH] x86/entry/32: Fix setup of CS high bits
References: <1531906876-13451-1-git-send-email-joro@8bytes.org>
 <1531906876-13451-11-git-send-email-joro@8bytes.org>
 <97421241-2bc4-c3f1-4128-95b3e8a230d1@siemens.com>
 <35a24feb-5970-aa03-acbf-53428a159ace@web.de>
 <CALCETrWveao7jthnfKr5F=UyEpyowP0VA20eZi5OxizgT05EDA@mail.gmail.com>
From: Jan Kiszka <jan.kiszka@siemens.com>
Message-ID: <406a08c7-6199-a32d-d385-c032fb4c34d6@siemens.com>
Date: Mon, 15 Oct 2018 15:08:54 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrWveao7jthnfKr5F=UyEpyowP0VA20eZi5OxizgT05EDA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>

On 13.10.18 17:12, Andy Lutomirski wrote:
> On Sat, Oct 13, 2018 at 3:02 AM Jan Kiszka <jan.kiszka@web.de> wrote:
>>
>> From: Jan Kiszka <jan.kiszka@siemens.com>
>>
>> Even if we are not on an entry stack, we have to initialize the CS high
>> bits because we are unconditionally evaluating them
>> PARANOID_EXIT_TO_KERNEL_MODE. Failing to do so broke the boot on Galileo
>> Gen2 and IOT2000 boards.
>>
>> Fixes: b92a165df17e ("x86/entry/32: Handle Entry from Kernel-Mode on Entry-Stack")
>> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
>> ---
>>   arch/x86/entry/entry_32.S | 12 ++++++------
>>   1 file changed, 6 insertions(+), 6 deletions(-)
>>
>> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
>> index 2767c625a52c..95c94d48ecd2 100644
>> --- a/arch/x86/entry/entry_32.S
>> +++ b/arch/x86/entry/entry_32.S
>> @@ -389,6 +389,12 @@
>>           * that register for the time this macro runs
>>           */
>>
>> +       /*
>> +        * Clear unused upper bits of the dword containing the word-sized CS
>> +        * slot in pt_regs in case hardware didn't clear it for us.
>> +        */
>> +       andl    $(0x0000ffff), PT_CS(%esp)
>> +
> 
> Please improve the comment. Since commit:
> 
> commit 385eca8f277c4c34f361a4c3a088fd876d29ae21
> Author: Andy Lutomirski <luto@kernel.org>
> Date:   Fri Jul 28 06:00:30 2017 -0700
> 
>      x86/asm/32: Make pt_regs's segment registers be 16 bits
> 
> Those fields are genuinely 16 bit.  So the comment should say
> something like "Those high bits are used for CS_FROM_ENTRY_STACK and
> CS_FROM_USER_CR3".

/*
  * The high bits of the CS dword (__csh) are used for
  * CS_FROM_ENTRY_STACK and CS_FROM_USER_CR3. Clear them in case
  * hardware didn't do this for us.
  */

OK? I will send out v2 with this wording soon.

> 
> Also, can you fold something like this in:
> 
> diff --git a/arch/x86/entry/entry_32.S b/arch/x86/entry/entry_32.S
> index 2767c625a52c..358eed8cf62a 100644
> --- a/arch/x86/entry/entry_32.S
> +++ b/arch/x86/entry/entry_32.S
> @@ -171,7 +171,7 @@
>          ALTERNATIVE "jmp .Lend_\@", "", X86_FEATURE_PTI
>          .if \no_user_check == 0
>          /* coming from usermode? */
> -       testl   $SEGMENT_RPL_MASK, PT_CS(%esp)
> +       testb   $SEGMENT_RPL_MASK, PT_CS(%esp)
>          jz      .Lend_\@
>          .endif
>          /* On user-cr3? */
> 

Makes sense, but this looks like a separate patch to me.

Jan

-- 
Siemens AG, Corporate Technology, CT RDA IOT SES-DE
Corporate Competence Center Embedded Linux
