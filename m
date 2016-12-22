Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 313B76B03F2
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 00:17:06 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id d22so12007443qtd.3
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 21:17:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u37si16645144qte.230.2016.12.21.21.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 21:17:05 -0800 (PST)
Date: Wed, 21 Dec 2016 23:17:01 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: x86: warning in unwind_get_return_address
Message-ID: <20161222051701.soqwh47frxwsbkni@treble>
References: <CAAeHK+yqC-S=fQozuBF4xu+d+e=ikwc_ipn-xUGnmfnWsjUtoA@mail.gmail.com>
 <20161220210144.u47znzx6qniecuvv@treble>
 <CAAeHK+z7O-byXDL4AMZP5TdeWHSbY-K69cbN6EeYo5eAtvJ0ng@mail.gmail.com>
 <20161220233640.pc4goscldmpkvtqa@treble>
 <CAAeHK+yPSeO2PWQtsQs_7FQ0PeGzs4PgK_89UM8G=hFJrVzH1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAAeHK+yPSeO2PWQtsQs_7FQ0PeGzs4PgK_89UM8G=hFJrVzH1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: syzkaller <syzkaller@googlegroups.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Kostya Serebryany <kcc@google.com>

On Wed, Dec 21, 2016 at 01:46:36PM +0100, Andrey Konovalov wrote:
> On Wed, Dec 21, 2016 at 12:36 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> >
> > Thanks.  Looking at the stack trace, my guess is that an interrupt hit
> > while running in generated BPF code, and the unwinder got confused
> > because regs->ip points to the generated code.  I may need to disable
> > that warning until we figure out a better solution.
> >
> > Can you share your .config file?
> 
> Sure, attached.

Ok, I was able to recreate with your config.  The culprit was generated
code, as I suspected, though it wasn't BPF, it was a kprobe (created by
dccpprobe_init()).

I'll make a patch to disable the warning.

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
