Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0896B1B42
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 17:49:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id l185-v6so924012ite.2
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 14:49:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e185-v6sor3532614ioa.63.2018.08.20.14.49.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 14:49:02 -0700 (PDT)
MIME-Version: 1.0
References: <20180820212556.GC2230@char.us.oracle.com>
In-Reply-To: <20180820212556.GC2230@char.us.oracle.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 20 Aug 2018 14:48:51 -0700
Message-ID: <CA+55aFxZCyVZc4ZpRyZ3uDyakRSOG_=2XvnwMo4oejpsieF9=A@mail.gmail.com>
Subject: Re: Redoing eXclusive Page Frame Ownership (XPFO) with isolated CPUs
 in mind (for KVM to isolate its guests per CPU)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Kernel Hardening <kernel-hardening@lists.openwall.com>, Liran Alon <liran.alon@oracle.com>, deepa.srinivasan@oracle.com, linux-mm <linux-mm@kvack.org>, juerg.haefliger@hpe.com, Khalid Aziz <khalid.aziz@oracle.com>, chris.hyser@oracle.com, Tyler Hicks <tyhicks@canonical.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@google.com>, Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com, Andi Kleen <ak@linux.intel.com>, John Haxby <john.haxby@oracle.com>, jsteckli@os.inf.tu-dresden.de, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Aug 20, 2018 at 2:26 PM Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
>
> See eXclusive Page Frame Ownership (https://lwn.net/Articles/700606/) which was posted
> way back in in 2016..

Ok, so my gut feel is that the above was reasonable within the context
of 2016, but that the XPFO model is completely pointless and wrong in
the post-Meltdown world we now live in.

Why?

Because with the Meltdown patches, we ALREADY HAVE the isolated page
tables that XPFO tries to do.

They are just the normal user page tables.

So don't go around doing other crazy things.

All you need to do is to literally:

 - before you enter VMX mode, switch to the user page tables

 - when you exit, switch back to the kernel page tables

don't do anything else.  You're done.

Now, this is complicated a bit by the fact that in order to enter VMX
mode with the user page tables, you do need to add the VMX state
itself to those user page tables (and add the actual trampoline code
to the vmenter too).

So it does imply we need to slightly extend the user mapping with a
few new patches, but that doesn't sound bad.

In fact, it sounds absolutely trivial to me.

The other thing you want to do is is the trivial optimization of "hey.
we exited VMX mode due to a host interrupt", which would look like
this:

 * switch to user page tables in order to do vmenter
 * vmenter
 * host interrupt happens
    - switch to kernel page tables to handle irq
    - do_IRQ etc
    - switch back to user page tables
    - iret
 * switch to kernel page tables because the vmenter returned

so you want to have some trivial short-circuiting of that last "switch
to user page tables and back" dance. It may actually be that we don't
even need it, because the irq code may just be looking at what *mode*
we were in, not what page tables we were in. I looked at that code
back in the meltdown days, but that's already so last-year now that we
have all these _other_ CPU bugs we handled.

But other than small details like that, doesn't this "use our Meltdown
user page table" sound like the right thing to do?

And note: no new VM code or complexity. None. We already have the
"isolated KVM context with only pages for the KVM process" case
handled.

Of course, after the long (and entirely unrelated) discussion about
the TLB flushing bug we had, I'm starting to worry about my own
competence, and maybe I'm missing something really fundamental, and
the XPFO patches do something else than what I think they do, or my
"hey, let's use our Meltdown code" idea has some fundamental weakness
that I'm missing.

              Linus
