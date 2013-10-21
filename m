Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id ADFC16B0302
	for <linux-mm@kvack.org>; Mon, 21 Oct 2013 01:27:38 -0400 (EDT)
Received: by mail-pd0-f179.google.com with SMTP id y10so4063654pdj.38
        for <linux-mm@kvack.org>; Sun, 20 Oct 2013 22:27:38 -0700 (PDT)
Received: from psmtp.com ([74.125.245.112])
        by mx.google.com with SMTP id u9si7567338pbf.23.2013.10.20.22.27.36
        for <linux-mm@kvack.org>;
        Sun, 20 Oct 2013 22:27:37 -0700 (PDT)
Received: by mail-ee0-f48.google.com with SMTP id e50so1887218eek.7
        for <linux-mm@kvack.org>; Sun, 20 Oct 2013 22:27:34 -0700 (PDT)
Date: Mon, 21 Oct 2013 07:27:31 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 4/3] x86/vdso: Optimize setup_additional_pages()
Message-ID: <20131021052731.GA14476@gmail.com>
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
 <1382057438-3306-4-git-send-email-davidlohr@hp.com>
 <20131018060501.GA3411@gmail.com>
 <1382327556.2402.23.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382327556.2402.23.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Richard Kuo <rkuo@codeaurora.org>, Ralf Baechle <ralf@linux-mips.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Paul Mundt <lethal@linux-sh.org>, Chris Metcalf <cmetcalf@tilera.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>


* Davidlohr Bueso <davidlohr@hp.com> wrote:

> > 2)
> > 
> > I don't see the justification: this code gets executed in exec() where 
> > a new mm has just been allocated. There's only a single user of the mm 
> > and thus the critical section width of mmap_sem is more or less 
> > irrelevant.
> > 
> > mmap_sem critical section size only matters for codepaths that 
> > threaded programs can hit.
> 
> Yes, I was surprised by the performance boost I noticed when running 
> this patch. This weekend I re-ran the tests (including your 4/3 patch) 
> and noticed that while we're still getting some benefits (more like in 
> the +5% throughput range), it's not as good as I originally reported. I 
> believe the reason is because I had ran the tests on the vanilla kernel 
> without the max clock frequency, so the comparison was obviously not 
> fair. That said, I still think it's worth adding this patch, as it does 
> help at a micro-optimization level, and it's one less mmap_sem user we 
> have to worry about.

But it's a mmap_sem user that is essentially _guaranteed_ to have only a 
single user at that point, in the exec() path!

So I don't see how this can show _any_ measurable speedup, let alone a 5% 
speedup in a macro test. If our understanding is correct then the patch 
does nothing but shuffle around a flag setting operation. (the mmap_sem is 
equivalent to setting a single flag, in the single-user case.)

Now, if our understanding is incorrect then we need to improve our 
understanding.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
