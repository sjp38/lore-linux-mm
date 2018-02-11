Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4426B0003
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 14:13:18 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id b193so1558416wmd.7
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 11:13:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10sor2989083wri.35.2018.02.11.11.13.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Feb 2018 11:13:16 -0800 (PST)
Date: Sun, 11 Feb 2018 20:13:12 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180211191312.54apu5edk3olsfz3@gmail.com>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
 <20180209191112.55zyjf4njum75brd@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209191112.55zyjf4njum75brd@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>


* Joerg Roedel <jroedel@suse.de> wrote:

> Hi Andy,
> 
> On Fri, Feb 09, 2018 at 05:47:43PM +0000, Andy Lutomirski wrote:
> > One thing worth noting is that performance of this whole series is
> > going to be abysmal due to the complete lack of 32-bit PCID.  Maybe
> > any kernel built with this option set that runs on a CPU that has the
> > PCID bit set in CPUID should print a big fat warning like "WARNING:
> > you are using 32-bit PTI on a 64-bit PCID-capable CPU.  Your
> > performance will increase dramatically if you switch to a 64-bit
> > kernel."
> 
> Thanks for your review. I can add this warning, but I just hope that not
> a lot of people will actually see it :)

Could you please measure the PTI kernel vs. vanilla kernel?

Nothing complex, just perf's built-in scheduler and syscall benchmark should be 
enough:

   perf stat --null --sync --repeat 10 perf bench sched messaging -g 20

this should give us a pretty good worst-case overhead figure for process 
workloads.

Add '-t' to test threaded workloads as well:

   perf stat --null --sync --repeat 10 perf bench sched messaging -g 20 -t

The 10 runs used should be enough to reach good stability in practice:

 Performance counter stats for 'perf bench sched messaging -g 20 -t' (10 runs):

       0.380742219 seconds time elapsed                                          ( +-  0.73% )

Maybe do the same on the 64-bit kernel as well, so that we have 4 good data points 
on the same hardware?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
