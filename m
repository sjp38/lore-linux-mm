Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A823C6B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 13:25:23 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so15244038lfe.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:25:23 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id tu11si4404031wjb.114.2016.07.07.10.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 10:25:22 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id 187so4075237wmz.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 10:25:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160707053710.GH2118@tarshish>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <1467843928-29351-2-git-send-email-keescook@chromium.org> <20160707053710.GH2118@tarshish>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 7 Jul 2016 13:25:21 -0400
Message-ID: <CAGXu5jJV4ZQp4VQ44SPQ49RxXpFXzx6d233A3+_Ka7txYHmuMw@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baruch Siach <baruch@tkos.co.il>
Cc: LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, Vitaly Wool <vitalywool@gmail.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

On Thu, Jul 7, 2016 at 1:37 AM, Baruch Siach <baruch@tkos.co.il> wrote:
> Hi Kees,
>
> On Wed, Jul 06, 2016 at 03:25:20PM -0700, Kees Cook wrote:
>> +#ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
>
> Should be CONFIG_HARDENED_USERCOPY to match the slab/slub implementation
> condition.
>
>> +const char *__check_heap_object(const void *ptr, unsigned long n,
>> +                             struct page *page);
>> +#else
>> +static inline const char *__check_heap_object(const void *ptr,
>> +                                           unsigned long n,
>> +                                           struct page *page)
>> +{
>> +     return NULL;
>> +}
>> +#endif

Hmm, I think what I have is correct: if the allocator supports the
heap object checking, it defines __check_heap_object as existing via
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR. If usercopy checking is done
at all is controlled by CONFIG_HARDENED_USERCOPY.

I.e. you can have the other usercopy checks even if your allocator
doesn't support object size checking.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
