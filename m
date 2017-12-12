Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 45A946B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:29:25 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id u4so510236iti.2
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:29:25 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h14si12382982iof.40.2017.12.12.10.29.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 10:29:24 -0800 (PST)
Date: Tue, 12 Dec 2017 19:29:06 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [patch 11/16] x86/ldt: Force access bit for CS/SS
Message-ID: <20171212182906.cg635muwcdnh6p66@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de>
 <20171212173334.176469949@linutronix.de>
 <CALCETrX+d+5COyWX1gDxi3gX93zFuq79UE+fhs27+ySq85j3+Q@mail.gmail.com>
 <20171212180918.lc5fdk5jyzwmrcxq@hirez.programming.kicks-ass.net>
 <CALCETrVmFSVqDGrH1K+Qv=svPTP3E6maVb5T2feyDNRkKfDVKA@mail.gmail.com>
 <C3141266-5522-4B5E-A0CE-65523F598F6D@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C3141266-5522-4B5E-A0CE-65523F598F6D@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 10:22:48AM -0800, Andy Lutomirski wrote:
> 
> Also, why is LAR deferred to user exit?  And I thought that LAR didn't
> set the accessed bit.

LAR does not set the ACCESSED bit indeed, we need to explicitly set that
when creating the descriptor.

It also works if you do the LAR right after LLDT (which is what I
originally had). The reason its a TIF flag is that I originally LAR'ed
every entry in the table.

It got reduced to CS/SS, but the TIF thing stayed.

> If I had to guess, I'd guess that LAR is actually generating a read
> fault and forcing the pagetables to get populated.  If so, then it
> means the VMA code isn't quite right, or you're susceptible to
> failures under memory pressure.
> 
> Now maybe LAR will repopulate the PTE every time if you were to never
> clear it, but ick.

I did not observe #PFs from LAR, we had a giant pile of trace_printk()
in there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
