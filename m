Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B57916B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 06:23:16 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id h7so41845529wjy.6
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 03:23:16 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f87si5147166wmh.24.2017.02.13.03.23.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 03:23:15 -0800 (PST)
Date: Mon, 13 Feb 2017 12:22:54 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 1/5] x86/mm: split arch_mmap_rnd() on compat/native
 versions
In-Reply-To: <3a275384-0c4a-5334-f31b-5fadda9d8ee9@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1702131222330.3619@nanos>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-2-dsafonov@virtuozzo.com> <20170209135525.qlwrmlo7njk3fsaq@pd.tnic> <alpine.DEB.2.20.1702102057330.4042@nanos> <CAJwJo6b5oSbcDjE+L=wwS_cdYnimAR+mD5BTyuHQtb8zUQX4fA@mail.gmail.com>
 <alpine.DEB.2.20.1702110919370.3734@nanos> <3a275384-0c4a-5334-f31b-5fadda9d8ee9@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Borislav Petkov <bp@alien8.de>, open list <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, X86 ML <x86@kernel.org>, linux-mm@kvack.org

On Mon, 13 Feb 2017, Dmitry Safonov wrote:
> On 02/11/2017 11:23 AM, Thomas Gleixner wrote:
> > On Sat, 11 Feb 2017, Dmitry Safonov wrote:
> > 
> > > 2017-02-10 23:10 GMT+03:00 Thomas Gleixner <tglx@linutronix.de>:
> > > > On Thu, 9 Feb 2017, Borislav Petkov wrote:
> > > > > I can't say that I'm thrilled about the ifdeffery this is adding.
> > > > > 
> > > > > But I can't think of a cleaner approach at a quick glance, though -
> > > > > that's generic and arch-specific code intertwined muck. Sad face.
> > > > 
> > > > It's trivial enough to do ....
> > > > 
> > > > Thanks,
> > > > 
> > > >         tglx
> > > > 
> > > > ---
> > > >  arch/x86/mm/mmap.c |   22 ++++++++++------------
> > > >  1 file changed, 10 insertions(+), 12 deletions(-)
> > > > 
> > > > --- a/arch/x86/mm/mmap.c
> > > > +++ b/arch/x86/mm/mmap.c
> > > > @@ -55,6 +55,10 @@ static unsigned long stack_maxrandom_siz
> > > >  #define MIN_GAP (128*1024*1024UL + stack_maxrandom_size())
> > > >  #define MAX_GAP (TASK_SIZE/6*5)
> > > > 
> > > > +#ifndef CONFIG_COMPAT
> > > > +# define mmap_rnd_compat_bits  mmap_rnd_bits
> > > > +#endif
> > > > +
> > > 
> > > >From my POV, I can't say that it's clearer to shadow mmap_compat_bits
> > > like that then to have two functions with native/compat names.
> > > But if you insist, I'll resend patches set with your version.
> > 
> > You can make that
> > 
> > #ifdef CONFIG_64BIT
> > # define mmap32_rnd_bits  mmap_compat_rnd_bits
> > # define mmap64_rnd_bits  mmap_rnd_bits
> > #else
> > # define mmap32_rnd_bits  mmap_rnd_bits
> > # define mmap64_rnd_bits  mmap_rnd_bits
> > #endif
> > 
> > and use that. That's still way more readable than the unholy ifdef mess.
> 
> Ok, will send this version in v5.
> Ping me if you mind me using your SOB for this patch.

Suggested-by is enough

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
