Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBE36B0253
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:55:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so21613883wme.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:55:57 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id i130si272763wme.120.2016.07.19.15.55.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 15:55:56 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id f65so154381997wmi.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 15:55:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJqo55G0tHzbdobEg_rjKvFONQRk7mkPq1JXOd-Hneipw@mail.gmail.com>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org> <ea4cdd53-7336-63b5-25ed-a397859eca4d@redhat.com>
 <CAGXu5jJqo55G0tHzbdobEg_rjKvFONQRk7mkPq1JXOd-Hneipw@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 19 Jul 2016 15:55:54 -0700
Message-ID: <CAGXu5j+0RryPNbSeEYcn6o9zTqz4DKZV3XCuRVuus_X9oUfmww@mail.gmail.com>
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>, Daniel Micay <danielmicay@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Rik van Riel <riel@redhat.com>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Tue, Jul 19, 2016 at 12:12 PM, Kees Cook <keescook@chromium.org> wrote:
> On Mon, Jul 18, 2016 at 6:52 PM, Laura Abbott <labbott@redhat.com> wrote:
>> On 07/15/2016 02:44 PM, Kees Cook wrote:
>>> +static inline const char *check_heap_object(const void *ptr, unsigned
>>> long n,
>>> +                                           bool to_user)
>>> +{
>>> +       struct page *page, *endpage;
>>> +       const void *end = ptr + n - 1;
>>> +
>>> +       if (!virt_addr_valid(ptr))
>>> +               return NULL;
>>> +
>>
>>
>> virt_addr_valid returns true on vmalloc addresses on arm64 which causes some
>> intermittent false positives (tab completion in a qemu buildroot environment
>> was showing it fairly reliably). I think this is an arm64 bug because
>> virt_addr_valid should return true if and only if virt_to_page returns the
>> corresponding page. We can work around this for now by explicitly
>> checking against is_vmalloc_addr.
>
> Hrm, that's weird. Sounds like a bug too, but I'll add a check for
> is_vmalloc_addr() to catch it for now.

BTW, if you were testing against -next, KASAN moved things around in
copy_*_user() in a way I wasn't expecting (__copy* and copy* now both
call __arch_copy* instead of copy* calling __copy*). I'll have this
fixed in the next version.

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
