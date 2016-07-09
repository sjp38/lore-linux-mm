Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D27356B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 02:07:33 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a69so135974125pfa.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 23:07:33 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id m189si2195058pfm.259.2016.07.08.23.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 23:07:33 -0700 (PDT)
Message-ID: <578094a5.c626620a.c1221.ffff965cSMTPIN_ADDED_BROKEN@mx.google.com>
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy support
In-Reply-To: <8737njpd37.fsf@@concordia.ellerman.id.au>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com> <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org> <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com> <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org> <CAGXu5j+UdkQA+k39GNLe5CwBPVD5ZbRGTCQLqS8VF=kWx+PtsQ@mail.gmail.com> <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com> <8737njpd37.fsf@@concordia.ellerman.id.au>
Date: Sat, 09 Jul 2016 16:07:29 +1000
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Jan Kara <jack@suse.cz>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Case y Sc hauf ler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Michael Ellerman <mpe@ellerman.id.au> writes:

> Kees Cook <keescook@chromium.org> writes:
>
>> On Fri, Jul 8, 2016 at 1:41 PM, Kees Cook <keescook@chromium.org> wrote:
>>> So, as found already, the position in the usercopy check needs to be
>>> bumped down by red_left_pad, which is what Michael's fix does, so I'll
>>> include it in the next version.
>>
>> Actually, after some offline chats, I think this is better, since it
>> makes sure the ptr doesn't end up somewhere weird before we start the
>> calculations. This leaves the pointer as-is, but explicitly handles
>> the redzone on the offset instead, with no wrapping, etc:
>>
>>         /* Find offset within object. */
>>         offset = (ptr - page_address(page)) % s->size;
>>
>> +       /* Adjust for redzone and reject if within the redzone. */
>> +       if (s->flags & SLAB_RED_ZONE) {
>> +               if (offset < s->red_left_pad)
>> +                       return s->name;
>> +               offset -= s->red_left_pad;
>> +       }
>> +
>>         /* Allow address range falling entirely within object size. */
>>         if (offset <= s->object_size && n <= s->object_size - offset)
>>                 return NULL;
>
> That fixes the case for me in kstrndup(), which allows the system to boot.

Ugh, no it doesn't, booted the wrong kernel.

I don't see the oops in strndup_user(), but instead get:

usercopy: kernel memory overwrite attempt detected to d000000003610028 (cfq_io_cq) (88 bytes)
CPU: 11 PID: 1 Comm: systemd Not tainted 4.7.0-rc3-00098-g09d9556ae5d1-dirty #65
Call Trace:
[c0000001fb087bf0] [c0000000009bdbe8] dump_stack+0xb0/0xf0 (unreliable)
[c0000001fb087c30] [c00000000029cf44] __check_object_size+0x74/0x320
[c0000001fb087cb0] [c00000000005d4d0] copy_from_user+0x60/0xd4
[c0000001fb087cf0] [c0000000008b38f4] __get_filter+0x74/0x160
[c0000001fb087d30] [c0000000008b408c] sk_attach_filter+0x2c/0xc0
[c0000001fb087d60] [c000000000871c34] sock_setsockopt+0x954/0xc00
[c0000001fb087dd0] [c00000000086ac44] SyS_setsockopt+0x134/0x150
[c0000001fb087e30] [c000000000009260] system_call+0x38/0x108
Kernel panic - not syncing: Attempted to kill init! exitcode=0x00000009

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
