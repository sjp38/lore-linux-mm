Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E60EB6B025E
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 00:53:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so6658206wmr.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 21:53:33 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id s7si2893987wme.118.2016.07.14.21.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 21:53:32 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id f65so11403901wmi.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 21:53:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAGXu5jJy4O4tV2sB=MSkYh2DEfxUYkH4Q3ghmrHEGc6s-k285A@mail.gmail.com>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-3-git-send-email-keescook@chromium.org> <20160714232019.GA28254@350D>
 <1468544658.30053.26.camel@redhat.com> <20160715014151.GA13944@balbir.ozlabs.ibm.com>
 <CAGXu5jJy4O4tV2sB=MSkYh2DEfxUYkH4Q3ghmrHEGc6s-k285A@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 14 Jul 2016 21:53:31 -0700
Message-ID: <CAGXu5jLuQPdBH4a0BF9AgH7qQubfoz+fFW2sTi2rRxsU8u_8QQ@mail.gmail.com>
Subject: Re: [PATCH v2 02/11] mm: Hardened usercopy
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, "x86@kernel.org" <x86@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, sparclinux <sparclinux@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, Jul 14, 2016 at 9:05 PM, Kees Cook <keescook@chromium.org> wrote:
> On Thu, Jul 14, 2016 at 6:41 PM, Balbir Singh <bsingharora@gmail.com> wrote:
>> On Thu, Jul 14, 2016 at 09:04:18PM -0400, Rik van Riel wrote:
>>> On Fri, 2016-07-15 at 09:20 +1000, Balbir Singh wrote:
>>>
>>> > > ==
>>> > > +            ((unsigned long)end & (unsigned
>>> > > long)PAGE_MASK)))
>>> > > +         return NULL;
>>> > > +
>>> > > + /* Allow if start and end are inside the same compound
>>> > > page. */
>>> > > + endpage = virt_to_head_page(end);
>>> > > + if (likely(endpage == page))
>>> > > +         return NULL;
>>> > > +
>>> > > + /* Allow special areas, device memory, and sometimes
>>> > > kernel data. */
>>> > > + if (PageReserved(page) && PageReserved(endpage))
>>> > > +         return NULL;
>>> >
>>> > If we came here, it's likely that endpage > page, do we need to check
>>> > that only the first and last pages are reserved? What about the ones
>>> > in
>>> > the middle?
>>>
>>> I think this will be so rare, we can get away with just
>>> checking the beginning and the end.
>>>
>>
>> But do we want to leave a hole where an aware user space
>> can try a longer copy_* to avoid this check? If it is unlikely
>> should we just bite the bullet and do the check for the entire
>> range?
>
> I'd be okay with expanding the test -- it should be an extremely rare
> situation already since the common Reserved areas (kernel data) will
> have already been explicitly tested.
>
> What's the best way to do "next page"? Should it just be:
>
> for ( ; page <= endpage ; ptr += PAGE_SIZE, page = virt_to_head_page(ptr) ) {
>     if (!PageReserved(page))
>         return "<spans multiple pages>";
> }
>
> return NULL;
>
> ?

Er, I was testing the wrong thing. How about:

        /*
         * Reject if range is not Reserved (i.e. special or device memory),
         * since then the object spans several independently allocated pages.
         */
        for (; ptr <= end ; ptr += PAGE_SIZE, page = virt_to_head_page(ptr)) {
                if (!PageReserved(page))
                        return "<spans multiple pages>";
        }

        return NULL;



-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
