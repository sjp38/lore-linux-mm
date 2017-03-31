Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 55ED06B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 15:32:59 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o123so89130933pga.16
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 12:32:59 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00133.outbound.protection.outlook.com. [40.107.0.133])
        by mx.google.com with ESMTPS id m5si5947840pgj.102.2017.03.31.12.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 31 Mar 2017 12:32:58 -0700 (PDT)
Subject: Re: sudo x86info -a => kernel BUG at mm/usercopy.c:78!
References: <d928849c-e7c3-6b81-e551-a39fa976f341@nokia.com>
 <CAGXu5jKo4gw=RHCmcY3v+GTiUUgteLbmvHDghd-Lrm7RprL8=Q@mail.gmail.com>
 <20170330194143.cbracica3w3ijrcx@codemonkey.org.uk>
 <CAGXu5jK8=g8rBx1J4+gC8-3nwRLe2Va89hHX=S-P6SvvgiVb9A@mail.gmail.com>
 <20170331171724.nm22iqiellfsvj5z@codemonkey.org.uk>
 <CAGXu5jL7MGNut_izksDKJHNJjPZqvu_84GBwHjqVeRbjDJyMWw@mail.gmail.com>
 <CA+55aFwOCnhSF4Tyk8x0+EpcWmaDd9X5bi1w=O1aReEK53OY8A@mail.gmail.com>
From: Tommi Rantala <tommi.t.rantala@nokia.com>
Message-ID: <a6543d13-6247-08de-903e-f4d1bbb52881@nokia.com>
Date: Fri, 31 Mar 2017 22:32:53 +0300
MIME-Version: 1.0
In-Reply-To: <CA+55aFwOCnhSF4Tyk8x0+EpcWmaDd9X5bi1w=O1aReEK53OY8A@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Kees Cook <keescook@chromium.org>
Cc: Dave Jones <davej@codemonkey.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>, Ingo Molnar <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Mark Rutland <mark.rutland@arm.com>, Eric Biggers <ebiggers@google.com>

On 31.03.2017 21:26, Linus Torvalds wrote:
> Hmm. Thinking more about this, we do allow access to the first 1MB of
> physical memory unconditionally (see devmem_is_allowed() in
> arch/x86/mm/init.c). And I think we only _reserve_ the first 64kB or
> something. So I guess even STRICT_DEVMEM isn't actually all that
> strict.
>
> So this should be visible even *with* STRICT_DEVMEM.
>
> Does a simple
>
>      sudo dd if=/dev/mem of=/dev/null bs=4096 count=256
>
> also show the same issue? Maybe regardless of STRICT_DEVMEM?

Yep, it is enough to trigger the bug.

Also crashes with the fedora kernel that has STRICT_DEVMEM:

$ sudo dd if=/dev/mem of=/dev/null bs=4096 count=256
Segmentation fault

[   73.224025] usercopy: kernel memory exposure attempt detected from 
ffff893a80059000 (dma-kmalloc-16) (4096 bytes)
[   73.224049] ------------[ cut here ]------------
[   73.224056] kernel BUG at mm/usercopy.c:75!
[   73.224060] invalid opcode: 0000 [#1] SMP
[   73.224237] CPU: 5 PID: 2860 Comm: dd Not tainted 
4.9.14-200.fc25.x86_64 #1


> Maybe we should change devmem_is_allowed() to return a ternary value,
> and then have it be "allow access" (for reserved pages), "disallow
> access" (for various random stuff), and "just read zero" (for pages in
> the low 1M that aren't marked reserved).
>
> That way things like that read the low 1M (like x86info) will
> hopefully not be unhappy, but also won't be reading random kernel
> data.
>
>               Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
