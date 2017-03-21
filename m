Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEB656B0398
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 14:49:54 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q126so365498371pga.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 11:49:54 -0700 (PDT)
Received: from mail.zytor.com ([2001:1868:a000:17::138])
        by mx.google.com with ESMTPS id a11si15777641pfl.214.2017.03.21.11.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 11:49:54 -0700 (PDT)
Date: Tue, 21 Mar 2017 11:49:37 -0700
In-Reply-To: <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
References: <20170321163712.20334-1-dsafonov@virtuozzo.com> <20170321171723.GB21564@uranus.lan> <CALCETrXoxRBTon8+jrYcbruYVUZASwgd-kzH-A96DGvT7gLXVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCHv2] x86/mm: set x32 syscall bit in SET_PERSONALITY()
From: hpa@zytor.com
Message-ID: <13EAF4BE-144F-47D6-8A38-3B6D97ACFF8A@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, Adam Borowski <kilobyte@angband.pl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrei Vagin <avagin@gmail.com>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, X86 ML <x86@kernel.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>

On March 21, 2017 10:45:57 AM PDT, Andy Lutomirski <luto@amacapital=2Enet> =
wrote:
>On Tue, Mar 21, 2017 at 10:17 AM, Cyrill Gorcunov <gorcunov@gmail=2Ecom>
>wrote:
>> On Tue, Mar 21, 2017 at 07:37:12PM +0300, Dmitry Safonov wrote:
>> =2E=2E=2E
>>> diff --git a/arch/x86/kernel/process_64=2Ec
>b/arch/x86/kernel/process_64=2Ec
>>> index d6b784a5520d=2E=2Ed3d4d9abcaf8 100644
>>> --- a/arch/x86/kernel/process_64=2Ec
>>> +++ b/arch/x86/kernel/process_64=2Ec
>>> @@ -519,8 +519,14 @@ void set_personality_ia32(bool x32)
>>>               if (current->mm)
>>>                       current->mm->context=2Eia32_compat =3D TIF_X32;
>>>               current->personality &=3D ~READ_IMPLIES_EXEC;
>>> -             /* in_compat_syscall() uses the presence of the x32
>>> -                syscall bit flag to determine compat status */
>>> +             /*
>>> +              * in_compat_syscall() uses the presence of the x32
>>> +              * syscall bit flag to determine compat status=2E
>>> +              * On the bitness of syscall relies x86 mmap() code,
>>> +              * so set x32 syscall bit right here to make
>>> +              * in_compat_syscall() work during exec()=2E
>>> +              */
>>> +             task_pt_regs(current)->orig_ax |=3D __X32_SYSCALL_BIT;
>>>               current->thread=2Estatus &=3D ~TS_COMPAT;
>>
>> Hi! I must admit I didn't follow close the overall series (so can't
>> comment much here :) but I have a slightly unrelated question -- is
>> there a way to figure out if task is running in x32 mode say with
>> some ptrace or procfs sign?
>
>You should be able to figure out of a *syscall* is x32 by simply
>looking at bit 30 in the syscall number=2E  (This is unlike i386, which
>is currently not reflected in ptrace=2E)
>
>Do we actually have an x32 per-task mode at all?  If so, maybe we can
>just remove it on top of Dmitry's series=2E

We do, for things like signal delivery mostly=2E  We have tried relying on=
 it as little as possible, intentionally=2E
--=20
Sent from my Android device with K-9 Mail=2E Please excuse my brevity=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
