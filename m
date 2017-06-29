Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD8D06B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 16:20:02 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m84so18157549ita.15
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:20:02 -0700 (PDT)
Received: from mail-it0-x232.google.com (mail-it0-x232.google.com. [2607:f8b0:4001:c0b::232])
        by mx.google.com with ESMTPS id r133si2078330itb.89.2017.06.29.13.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 13:20:01 -0700 (PDT)
Received: by mail-it0-x232.google.com with SMTP id m84so13889069ita.0
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 13:20:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJHCu1JxUA0b3mu4Z=NPBdCRv6SfmCKEQ5jGaMsLg2Q_9tm25g@mail.gmail.com>
References: <1497544976-7856-1-git-send-email-s.mesoraca16@gmail.com>
 <1497544976-7856-7-git-send-email-s.mesoraca16@gmail.com> <CAGXu5jJ2DykaU6bbFGRcOaZK9nn5dFUYQ6UjXCq9Y97DwYpCyA@mail.gmail.com>
 <CAJHCu1JxUA0b3mu4Z=NPBdCRv6SfmCKEQ5jGaMsLg2Q_9tm25g@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 29 Jun 2017 13:20:00 -0700
Message-ID: <CAGXu5jKiip2t8PpDJCnrCiakf_yWqxDsig-XfPOQHwD=G2N7eA@mail.gmail.com>
Subject: Re: [RFC v2 6/9] Creation of "pagefault_handler_x86" LSM hook
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-security-module <linux-security-module@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Brad Spengler <spender@grsecurity.net>, PaX Team <pageexec@freemail.hu>, Casey Schaufler <casey@schaufler-ca.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, Jann Horn <jannh@google.com>, Christoph Hellwig <hch@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Jun 29, 2017 at 12:30 PM, Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
> 2017-06-28 1:07 GMT+02:00 Kees Cook <keescook@chromium.org>:
>> On Thu, Jun 15, 2017 at 9:42 AM, Salvatore Mesoraca
>> <s.mesoraca16@gmail.com> wrote:
>>> Creation of a new hook to let LSM modules handle user-space pagefaults on
>>> x86.
>>> It can be used to avoid segfaulting the originating process.
>>> If it's the case it can modify process registers before returning.
>>> This is not a security feature by itself, it's a way to soften some
>>> unwanted side-effects of restrictive security features.
>>> In particular this is used by S.A.R.A. can be used to implement what
>>> PaX call "trampoline emulation" that, in practice, allow for some specific
>>> code sequences to be executed even if they are in non executable memory.
>>> This may look like a bad thing at first, but you have to consider
>>> that:
>>> - This allows for strict memory restrictions (e.g. W^X) to stay on even
>>>   when they should be turned off. And, even if this emulation
>>>   makes those features less effective, it's still better than having
>>>   them turned off completely.
>>> - The only code sequences emulated are trampolines used to make
>>>   function calls. In many cases, when you have the chance to
>>>   make arbitrary memory writes, you can already manipulate the
>>>   control flow of the program by overwriting function pointers or
>>>   return values. So, in many cases, the "trampoline emulation"
>>>   doesn't introduce new exploit vectors.
>>> - It's a feature that can be turned on only if needed, on a per
>>>   executable file basis.
>>
>> Can this be made arch-agnostic? It seems a per-arch register-handling
>> routine would be needed, though. :(
>
> S.A.R.A.'s "pagefault_handler_x86" implementation is fully arch specific
> so it won't benefit too much from this change.
> Anyway having a single hook for all archs is probably a cleaner solution,
> I'll change it in the v3.
> Would it be OK if I make it arch-agnostic while I actually keep it only
> in arch/x86/mm/fault.c?
> Thank you for your help.

It'd be nicer to wire it up unconditionally to all architectures, but
I'm not entirely sure if that's feasible. Perhaps SARA (or this LSM
hook) would be hidden behind some CONFIG_ARCH_HAS_LSM_PAGEFAULT or
something that each architecture could "select" in its Kconfig.

Perhaps some other LSM folks have some better ideas?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
