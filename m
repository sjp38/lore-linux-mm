Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B66D66B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:40:50 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 101so4445732ioj.6
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:40:50 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g35sor5297681iod.292.2017.10.18.03.40.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 03:40:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171017073326.GA23865@js1304-P5Q-DELUXE>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble>
 <20171011170120.7flnk6r77dords7a@treble> <20171017073326.GA23865@js1304-P5Q-DELUXE>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 18 Oct 2017 06:40:48 -0400
Message-ID: <CA+55aFxVnFeFcjt=MW=_Uxx6S7nJh5eFxhQCamE5BG6Jr8MXfg@mail.gmail.com>
Subject: Re: [lkp-robot] [x86/kconfig] 81d3871900: BUG:unable_to_handle_kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>, kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, linux-mm <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Tue, Oct 17, 2017 at 3:33 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>
> It looks like a compiler bug. The code of slob_units() try to read two
> bytes at ffff88001c4afffe. It's valid. But the compiler generates
> wrong code that try to read four bytes.
>
> static slobidx_t slob_units(slob_t *s)
> {
>   if (s->units > 0)
>     return s->units;
>   return 1;
> }
>
> s->units is defined as two bytes in this setup.
>
> Wrongly generated code for this part.
>
> 'mov 0x0(%rbp), %ebp'
>
> %ebp is four bytes.
>
> I guess that this wrong four bytes read cross over the valid memory
> boundary and this issue happend.

Hmm. I can see why the compiler would do that (16-bit accesses are
slow), but it's definitely wrong.

Does it work ok if that slob_units() code is written as

  static slobidx_t slob_units(slob_t *s)
  {
     int units = READ_ONCE(s->units);

     if (units > 0)
         return units;
     return 1;
  }

which might be an acceptable workaround for now?

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
