Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 88C796B0253
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 09:15:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id s78so2164539wmd.14
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:15:58 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 81si8660091wmn.49.2017.10.18.06.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 18 Oct 2017 06:15:56 -0700 (PDT)
Date: Wed, 18 Oct 2017 15:15:03 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [lkp-robot] [x86/kconfig] 81d3871900:
 BUG:unable_to_handle_kernel
In-Reply-To: <CA+55aFxVnFeFcjt=MW=_Uxx6S7nJh5eFxhQCamE5BG6Jr8MXfg@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1710181509310.1925@nanos>
References: <20171010121513.GC5445@yexl-desktop> <20171011023106.izaulhwjcoam55jt@treble> <20171011170120.7flnk6r77dords7a@treble> <20171017073326.GA23865@js1304-P5Q-DELUXE> <CA+55aFxVnFeFcjt=MW=_Uxx6S7nJh5eFxhQCamE5BG6Jr8MXfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Josh Poimboeuf <jpoimboe@redhat.com>, kernel test robot <xiaolong.ye@intel.com>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jiri Slaby <jslaby@suse.cz>, Mike Galbraith <efault@gmx.de>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, linux-mm <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On Wed, 18 Oct 2017, Linus Torvalds wrote:
> On Tue, Oct 17, 2017 at 3:33 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> >
> > It looks like a compiler bug. The code of slob_units() try to read two
> > bytes at ffff88001c4afffe. It's valid. But the compiler generates
> > wrong code that try to read four bytes.
> >
> > static slobidx_t slob_units(slob_t *s)
> > {
> >   if (s->units > 0)
> >     return s->units;
> >   return 1;
> > }
> >
> > s->units is defined as two bytes in this setup.
> >
> > Wrongly generated code for this part.
> >
> > 'mov 0x0(%rbp), %ebp'
> >
> > %ebp is four bytes.
> >
> > I guess that this wrong four bytes read cross over the valid memory
> > boundary and this issue happend.
> 
> Hmm. I can see why the compiler would do that (16-bit accesses are
> slow), but it's definitely wrong.
> 
> Does it work ok if that slob_units() code is written as
> 
>   static slobidx_t slob_units(slob_t *s)
>   {
>      int units = READ_ONCE(s->units);
> 
>      if (units > 0)
>          return units;
>      return 1;
>   }
> 
> which might be an acceptable workaround for now?

Discussed exactly that with Peter Zijlstra yesterday, but we came to the
conclusion that this is a whack a mole game. It might fix this slob issue,
but what guarantees that we don't have the same problem in some other
place? Just duct taping this particular instance makes me nervous.

Joonsoo says:

> gcc 4.8 and 4.9 fails to generate proper code. gcc 5.1 and
> the latest version works fine.

> I guess that this problem is related to the corner case of some
> optimization feature since minor code change makes the result
> different. And, with -O2, proper code is generated even if gcc 4.8 is
> used.

So it would be useful to figure out which optimization bit is causing that
and blacklist it for the affected compiler versions.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
