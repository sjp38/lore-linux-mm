Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A42666B0268
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 16:02:22 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z80so9478960pff.11
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:02:22 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d17si955413pge.191.2017.10.13.13.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 13:02:20 -0700 (PDT)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5B62721A6F
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 20:02:20 +0000 (UTC)
Received: by mail-it0-f41.google.com with SMTP id f187so12656459itb.1
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:02:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyvK+proOBKfc41qSH8hoPU+mBiT0=hLhbt_ZQv4N82iA@mail.gmail.com>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble>
 <20171011170120.7flnk6r77dords7a@treble> <alpine.DEB.2.20.1710121202210.28556@nuc-kabylake>
 <20171013044521.662ck56gkwaw3xog@treble> <9a1c3232-86e3-7301-23f8-50116abf37d3@virtuozzo.com>
 <CA+55aFyvK+proOBKfc41qSH8hoPU+mBiT0=hLhbt_ZQv4N82iA@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 13 Oct 2017 13:01:59 -0700
Message-ID: <CALCETrV91zeKc__be4otCp_68HYjwobTEPpTEcu69-1FBQBHww@mail.gmail.com>
Subject: Re: [lkp-robot] [x86/kconfig] 81d3871900: BUG:unable_to_handle_kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Christopher Lameter <cl@linux.com>, kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, linux-mm <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Megha Dey <megha.dey@linux.intel.com>, Herbert Xu <herbert@gondor.apana.org.au>, "David S. Miller" <davem@davemloft.net>, Linux Crypto Mailing List <linux-crypto@vger.kernel.org>

On Fri, Oct 13, 2017 at 12:09 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Fri, Oct 13, 2017 at 6:56 AM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>> This could be fixed by s/vmovdqa/vmovdqu change like bellow, but maybe the right fix
>> would be to align the data properly?
>
> I suspect anything that has the SHA extensions should also do
> unaligned loads efficiently. The whole "aligned only" model is broken.
> It's just doing two loads from the state pointer, there's likely no
> point in trying to align it.
>
> So your patch looks fine, but maybe somebody could add the required
> alignment to the sha256 context allocation (which I don't know where
> it is).

IIRC if we try the latter, then we'll risk hitting the #*!&@% gcc bug
that mostly prevents 16-byte alignment from working on GCC before 4.8
or so.  That way lies debugging disasters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
