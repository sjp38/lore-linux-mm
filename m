Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m3FCleBi029902
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 13:47:40 +0100
Received: from fg-out-1718.google.com (fge22.prod.google.com [10.86.5.22])
	by zps75.corp.google.com with ESMTP id m3FClcF2011617
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 05:47:39 -0700
Received: by fg-out-1718.google.com with SMTP id 22so1894389fge.18
        for <linux-mm@kvack.org>; Tue, 15 Apr 2008 05:47:37 -0700 (PDT)
Message-ID: <d43160c70804150547v7896e813t4bb1bafd932c30ec@mail.gmail.com>
Date: Tue, 15 Apr 2008 08:47:37 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: [PATCH 1/2] MM: Make page tables relocatable -- conditional flush (rc9)
In-Reply-To: <20080414155702.ca7eb622.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080414163933.A9628DCA48@localhost>
	 <20080414155702.ca7eb622.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2008 at 6:57 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
>  This patchset doesn't apply to the 2.6.26 queue because of the ongoing x86
>  shell game: the arch/x86/kernel/smp_??.c files were consolidated.

It's probably best to just wait until the smoke clears on 2.6.26 then.
 I'll add some comments, however I usually get in trouble for adding
too verbose comments, so I've learned to go the other way.  If you
prefer comments though, I'll add them.

>  - Must ->page_table_relocation_lock be a semaphore?  mutexes are
>   preferred.

Not any more.  It used to require a semaphore, but I can switch it
back to a mutex now.  I can even replace the mutex with an atomic
inc/dec which might be even better since it will work at interrupt
time as well.

>  - The patch adds a number of largeish inlined functions.  There's rarely
>   a need for this, and it can lead to large icache footprint which will, we
>   expect, produce slower code.

If these are the ones I'm thinking of, they are in the fast path on
page faults.  So they should be inlined.  However, I could easily
change it to a small macro or inline function and a regular function
call that would rarely be taken.  This should be a win from the icache
point of view and only a loss in a case we really don't care much
about.

>  - The patch adds a lot of macros which look like they could have been
>   implemented as inlines.  Inlines are preferred, please.  They look nicer,
>   they provide typechecking, they avoid accidental
>   multiple-reference-to-arguments bugs and they help to avoid
>   unused-variable warnings.

Here I disagree.  The only added function-like #define's I see are
either just aliasing functions, or the case when any function that
does nothing.  I guess the later could be replaced by inlines to avoid
warnings.

>  - Doing PAGE_SIZE memcpy under spin_lock_irqsave() might get a bit
>   expensive from an interrupt-latency POV.  It could (I think?) result in
>   large periods of time where interrupts are almost always disabled, which
>   might disrupt some device drivers.

Here I'm just being stupid.  There is no reason to have interrupts
disabled at this point.

>
>  - Why is this code doing spin_lock_irqsave() on page_table_lock?  The
>   rest of mm/ doesn't disable IRQs for that lock.  This implies that

Laziness.  I didn't feel like figuring this out if the irqsave was
necessary when I started, and forgot to go back and fix it later.
There is no reason.


>  - I haven't checked, but if the code is taking KM_USER0 from interrupt
>   context then that would be a bug.  Switching to KM_IRQ0 would fix that.

KM_USER0 is currently correct.  For memory hotplug, we may need to
change this in the future.


     Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
