Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 838E66B0681
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 19:32:35 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t1-v6so94489ply.23
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 16:32:35 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x5si5541350pgq.535.2018.11.08.16.32.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Nov 2018 16:32:34 -0800 (PST)
Date: Thu, 8 Nov 2018 16:32:25 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for
 shadow stack
Message-ID: <20181109003225.GQ3074@bombadil.infradead.org>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com>
 <20181011151523.27101-5-yu-cheng.yu@intel.com>
 <CALCETrVAe8R=crVHoD5QmbN-gAW+V-Rwkwe4kQP7V7zQm9TM=Q@mail.gmail.com>
 <4295b8f786c10c469870a6d9725749ce75dcdaa2.camel@intel.com>
 <CALCETrUKzXYzRrWRdi8Z7AdAF0uZW5Gs7J4s=55dszoyzc29rw@mail.gmail.com>
 <043a17ef-dc9f-56d2-5fba-1a58b7b0fd4d@intel.com>
 <20181108220054.GP3074@bombadil.infradead.org>
 <ead230ab-a904-50d6-c4cf-46d5804f6151@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ead230ab-a904-50d6-c4cf-46d5804f6151@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Yu-cheng Yu <yu-cheng.yu@intel.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Thu, Nov 08, 2018 at 03:35:02PM -0800, Dave Hansen wrote:
> On 11/8/18 2:00 PM, Matthew Wilcox wrote:
> > struct a {
> > 	char c;
> > 	struct b b;
> > };
> > 
> > we want struct b to start at offset 8, but with __packed, it will start
> > at offset 1.
> 
> You're talking about how we want the struct laid out in memory if we
> have control over the layout.  I'm talking about what happens if
> something *else* tells us the layout, like a hardware specification
> which is what is in play with the XSAVE instruction dictated layout
> that's in question here.
> 
> What I'm concerned about is a structure like this:
> 
> struct foo {
>         u32 i1;
>         u64 i2;
> };
> 
> If we leave that to natural alignment, we end up with a 16-byte
> structure laid out like this:
> 
> 	0-3	i1
> 	3-8	alignment gap
> 	8-15	i2

I know you actually meant:

	0-3	i1
	4-7	pad
	8-15	i2

> Which isn't what we want.  We want a 12-byte structure, laid out like this:
> 
> 	0-3	i1
> 	4-11	i2
> 
> Which we get with:
> 
> struct foo {
>         u32 i1;
>         u64 i2;
> } __packed;

But we _also_ get pessimised accesses to i1 and i2.  Because gcc can't
rely on struct foo being aligned to a 4 or even 8 byte boundary (it
might be embedded in "struct a" from above).

> Now, looking at Yu-cheng's specific example, it doesn't matter.  We've
> got 64-bit types and natural 64-bit alignment.  Without __packed, we
> need to look out for natural alignment screwing us up.  With __packed,
> it just does what it *looks* like it does.

The question is whether Yu-cheng's struct is ever embedded in another
struct.  And if so, what does the hardware do?
