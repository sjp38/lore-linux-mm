Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6EEDA6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 16:34:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so18941625lfw.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 13:34:50 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id 131si22288588wma.114.2016.07.19.13.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 13:34:49 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id f65so151375455wmi.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 13:34:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <578E8A22.5080807@de.ibm.com>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org> <578DF109.5030704@de.ibm.com>
 <CAGXu5jKRDuELqGY1F-D4+MD+dMXSbiPGzf1hXb7Kp8ACBjpw9g@mail.gmail.com> <578E8A22.5080807@de.ibm.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 19 Jul 2016 13:34:46 -0700
Message-ID: <CAGXu5j+HqLY1gZycV9S9_Vf8uuQj4Z3qsV8WBxLORuseiJaw5Q@mail.gmail.com>
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Jul 19, 2016 at 1:14 PM, Christian Borntraeger
<borntraeger@de.ibm.com> wrote:
> On 07/19/2016 09:31 PM, Kees Cook wrote:
>> On Tue, Jul 19, 2016 at 2:21 AM, Christian Borntraeger
>> <borntraeger@de.ibm.com> wrote:
>>> On 07/15/2016 11:44 PM, Kees Cook wrote:
>>>> +config HAVE_ARCH_LINEAR_KERNEL_MAPPING
>>>> +     bool
>>>> +     help
>>>> +       An architecture should select this if it has a secondary linear
>>>> +       mapping of the kernel text. This is used to verify that kernel
>>>> +       text exposures are not visible under CONFIG_HARDENED_USERCOPY.
>>>
>>> I have trouble parsing this. (What does secondary linear mapping mean?)
>>
>> I likely need help clarifying this language...
>>
>>> So let me give an example below
>>>
>>>> +
>>> [...]
>>>> +/* Is this address range in the kernel text area? */
>>>> +static inline const char *check_kernel_text_object(const void *ptr,
>>>> +                                                unsigned long n)
>>>> +{
>>>> +     unsigned long textlow = (unsigned long)_stext;
>>>> +     unsigned long texthigh = (unsigned long)_etext;
>>>> +
>>>> +     if (overlaps(ptr, n, textlow, texthigh))
>>>> +             return "<kernel text>";
>>>> +
>>>> +#ifdef HAVE_ARCH_LINEAR_KERNEL_MAPPING
>>>> +     /* Check against linear mapping as well. */
>>>> +     if (overlaps(ptr, n, (unsigned long)__va(__pa(textlow)),
>>>> +                  (unsigned long)__va(__pa(texthigh))))
>>>> +             return "<linear kernel text>";
>>>> +#endif
>>>> +
>>>> +     return NULL;
>>>> +}
>>>
>>> s390 has an address space for user (primary address space from 0..4TB/8PB) and a separate
>>> address space (home space from 0..4TB/8PB) for the kernel. In this home space the kernel
>>> mapping is virtual containing the physical memory as well as vmalloc memory (creating aliases
>>> into the physical one). The kernel text is mapped from _stext to _etext in this mapping.
>>> So I assume this would qualify for HAVE_ARCH_LINEAR_KERNEL_MAPPING ?
>>
>> If I understand your example, yes. In the home space you have two
>> addresses that reference the kernel image?
>
> No, there is only one address that points to the kernel.
> As we have no kernel ASLR yet, and the kernel mapping is
> a 1:1 mapping from 0 to memory end and the kernel is only
> from _stext to _etext. The vmalloc area contains modules
> and vmalloc but not a 2nd kernel mapping.
>
> But thanks for your example, now I understood. If we have only
> one address
>>>> +     if (overlaps(ptr, n, textlow, texthigh))
>>>> +             return "<kernel text>";
>
> This is just enough.
>
> So what about for the CONFIG text:
>
>        An architecture should select this if the kernel mapping has a secondary
>        linear mapping of the kernel text - in other words more than one virtual
>        kernel address that points to the kernel image. This is used to verify
>        that kernel text exposures are not visible under CONFIG_HARDENED_USERCOPY.

Sounds good, I've adjusted it for now.

>> I wonder if I can avoid the CONFIG entirely if I just did a
>> __va(__pa(_stext)) != _stext test... would that break anyone?
>
> Can this be resolved on all platforms at compile time?

Well, I think it still needs a runtime check (compile-time may not be
able to tell about kaslr, or who knows what else). I would really like
to avoid the CONFIG if possible, though. Would this do the right thing
on s390? This appears to work where I'm able to test it (32/64 x86,
32/64 arm):

        unsigned long textlow = (unsigned long)_stext;
        unsigned long texthigh = (unsigned long)_etext;
        unsigned long textlow_linear = (unsigned long)__va(__pa(textlow);
        unsigned long texthigh_linear = (unsigned long)__va(__pa(texthigh);

        if (overlaps(ptr, n, textlow, texthigh))
                return "<kernel text>";

        /* Check against possible secondary linear mapping as well. */
        if (textlow != textlow_linear &&
            overlaps(ptr, n, textlow_linear, texthigh_linear))
                return "<linear kernel text>";

        return NULL;


-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
