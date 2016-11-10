Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 471A06B0297
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 08:03:13 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r68so8791109wmd.0
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 05:03:13 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id da3si5070041wjb.46.2016.11.10.05.03.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 05:03:12 -0800 (PST)
Date: Thu, 10 Nov 2016 14:00:33 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Proposal: HAVE_SEPARATE_IRQ_STACK?
In-Reply-To: <CAHmME9pHYA82M3iDNfDtDE96gFaZORSsEAn_KnePd3rhFioqHQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1611101351260.3501@nanos>
References: <CAHmME9oSUcAXVMhpLt0bqa9DKHE8rd3u+3JDb_wgviZnOpP7JA@mail.gmail.com> <alpine.DEB.2.20.1611092227200.3501@nanos> <CAHmME9pGoRogjHSSy-G-sB4-cHMGcjCeW9PSrNw1h5FsKzfWAw@mail.gmail.com> <alpine.DEB.2.20.1611100959040.3501@nanos>
 <CAHmME9pHYA82M3iDNfDtDE96gFaZORSsEAn_KnePd3rhFioqHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, WireGuard mailing list <wireguard@lists.zx2c4.com>, k@vodka.home.kg

On Thu, 10 Nov 2016, Jason A. Donenfeld wrote:
> On Thu, Nov 10, 2016 at 10:03 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > Does the slowdown come from the kmalloc overhead or mostly from the less
> > efficient code?
> >
> > If it's mainly kmalloc, then you can preallocate the buffer once for the
> > kthread you're running in and be done with it. If it's the code, then bad
> > luck.
> 
> I fear both. GCC can optimize stack variables in ways that it cannot
> optimize various memory reads and writes.

The question is how much of it is code and how much of it is the kmalloc.
 
> Strangely, the solution that appeals to me most at the moment is to
> kmalloc (or vmalloc?) a new stack, copy over thread_info, and fiddle
> with the stack registers. I don't see any APIs, however, for a
> platform independent way of doing this. And maybe this is a horrible
> idea. But at least it'd allow me to keep my stack-based code the
> same...

Do not even think about going there. That's going to be a major
mess.

As a short time workaround you can increase THREAD_SIZE_ORDER for now and
then fix it proper with switching to seperate irq stacks.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
