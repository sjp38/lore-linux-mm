Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 865D06B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 13:41:32 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n127so143264wme.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:41:32 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id uw2si3946171wjb.55.2016.07.07.10.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 10:41:31 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id n127so25179987wme.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:41:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1467909317.13253.17.camel@redhat.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <1467843928-29351-2-git-send-email-keescook@chromium.org> <1467909317.13253.17.camel@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Jul 2016 13:41:30 -0400
Message-ID: <CAGXu5j+zxyPEfswD-03TDhuzxaG6itKsoc6-15rMuE+Sz3booA@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, Jul 7, 2016 at 12:35 PM, Rik van Riel <riel@redhat.com> wrote:
> On Wed, 2016-07-06 at 15:25 -0700, Kees Cook wrote:
>>
>> +     /* Allow kernel rodata region (if not marked as Reserved).
>> */
>> +     if (ptr >= (const void *)__start_rodata &&
>> +         end <= (const void *)__end_rodata)
>> +             return NULL;
>>
> One comment here.
>
> __check_object_size gets "to_user" as an argument.
>
> It may make sense to pass that to check_heap_object, and
> only allow copy_to_user from rodata, never copy_from_user,
> since that section should be read only.

Well, that's two votes for this extra check, but I'm still not sure
since it may already be allowed by the Reserved check, but I can
reorder things to _reject_ on rodata writes before the Reserved check,
etc.

I'll see what could work here...

-Kees

>
>> +void __check_object_size(const void *ptr, unsigned long n, bool
>> to_user)
>> +{
>>
>
> --
>
> All Rights Reversed.



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
