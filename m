Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3C56B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:31:19 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id r97so18148120lfi.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 12:31:19 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id 125si10530231ljj.76.2016.07.19.12.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 12:31:17 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id q128so30183809wma.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 12:31:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <578DF109.5030704@de.ibm.com>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org> <578DF109.5030704@de.ibm.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 19 Jul 2016 12:31:15 -0700
Message-ID: <CAGXu5jKRDuELqGY1F-D4+MD+dMXSbiPGzf1hXb7Kp8ACBjpw9g@mail.gmail.com>
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Jul 19, 2016 at 2:21 AM, Christian Borntraeger
<borntraeger@de.ibm.com> wrote:
> On 07/15/2016 11:44 PM, Kees Cook wrote:
>> +config HAVE_ARCH_LINEAR_KERNEL_MAPPING
>> +     bool
>> +     help
>> +       An architecture should select this if it has a secondary linear
>> +       mapping of the kernel text. This is used to verify that kernel
>> +       text exposures are not visible under CONFIG_HARDENED_USERCOPY.
>
> I have trouble parsing this. (What does secondary linear mapping mean?)

I likely need help clarifying this language...

> So let me give an example below
>
>> +
> [...]
>> +/* Is this address range in the kernel text area? */
>> +static inline const char *check_kernel_text_object(const void *ptr,
>> +                                                unsigned long n)
>> +{
>> +     unsigned long textlow = (unsigned long)_stext;
>> +     unsigned long texthigh = (unsigned long)_etext;
>> +
>> +     if (overlaps(ptr, n, textlow, texthigh))
>> +             return "<kernel text>";
>> +
>> +#ifdef HAVE_ARCH_LINEAR_KERNEL_MAPPING
>> +     /* Check against linear mapping as well. */
>> +     if (overlaps(ptr, n, (unsigned long)__va(__pa(textlow)),
>> +                  (unsigned long)__va(__pa(texthigh))))
>> +             return "<linear kernel text>";
>> +#endif
>> +
>> +     return NULL;
>> +}
>
> s390 has an address space for user (primary address space from 0..4TB/8PB) and a separate
> address space (home space from 0..4TB/8PB) for the kernel. In this home space the kernel
> mapping is virtual containing the physical memory as well as vmalloc memory (creating aliases
> into the physical one). The kernel text is mapped from _stext to _etext in this mapping.
> So I assume this would qualify for HAVE_ARCH_LINEAR_KERNEL_MAPPING ?

If I understand your example, yes. In the home space you have two
addresses that reference the kernel image? The intent is that if
__va(__pa(_stext)) != _stext, there's a linear mapping of physical
memory in the virtual memory range. On x86_64, the kernel is visible
in two locations in virtual memory. The kernel start in physical
memory address 0x01000000 maps to virtual address 0xffff880001000000,
and the "regular" virtual memory kernel address is at
0xffffffff81000000:

# grep Kernel /proc/iomem
  01000000-01a59767 : Kernel code
  01a59768-0213d77f : Kernel data
  02280000-02fdefff : Kernel bss

# grep startup_64 /proc/kallsyms
ffffffff81000000 T startup_64

# less /sys/kernel/debug/kernel_page_tables
...
---[ Low Kernel Mapping ]---
...
0xffff880001000000-0xffff880001a00000          10M     ro         PSE
 GLB NX pmd
0xffff880001a00000-0xffff880001a5c000         368K     ro   GLB NX pte
0xffff880001a5c000-0xffff880001c00000        1680K     RW   GLB NX pte
...
---[ High Kernel Mapping ]---
...
0xffffffff81000000-0xffffffff81a00000          10M     ro         PSE
 GLB x  pmd
0xffffffff81a00000-0xffffffff81a5c000         368K     ro   GLB x  pte
0xffffffff81a5c000-0xffffffff81c00000        1680K     RW   GLB NX pte
...

I wonder if I can avoid the CONFIG entirely if I just did a
__va(__pa(_stext)) != _stext test... would that break anyone?

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
