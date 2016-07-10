Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97BDD6B0005
	for <linux-mm@kvack.org>; Sun, 10 Jul 2016 05:16:39 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so8120277wme.1
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 02:16:39 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id k190si1762434wme.130.2016.07.10.02.16.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Jul 2016 02:16:37 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id x83so11795980wma.3
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 02:16:37 -0700 (PDT)
Date: Sun, 10 Jul 2016 11:16:32 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Message-ID: <20160710091632.GA14172@gmail.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <CALCETrU5Emr7jZNH5bh7Z+C8fLOcAah9SzeJbDjqW7N-xWGxHA@mail.gmail.com>
 <578185D4.29090.242668C8@pageexec.freemail.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <578185D4.29090.242668C8@pageexec.freemail.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PaX Team <pageexec@freemail.hu>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Brad Spengler <spender@grsecurity.net>, Pekka Enberg <penberg@kernel.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Casey Schaufler <casey@schaufler-ca.com>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dmitry Vyukov <dvyukov@google.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, X86 ML <x86@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch <linux-arch@vger.kernel.org>, David Rientjes <rientjes@google.com>, Mathias Krause <minipli@googlemail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@fedoraproject.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Russell King <linux@armlinux.org.uk>, Michael Ellerman <mpe@ellerman.id.au>, Andrea Arcangeli <aarcange@redhat.com>, Fenghua Yu <fenghua.yu@intel.com>, linuxppc-dev@lists.ozlabs.org, Vitaly Wool <vitalywool@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, sparclinux@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>


* PaX Team <pageexec@freemail.hu> wrote:

> On 9 Jul 2016 at 14:27, Andy Lutomirski wrote:
> 
> > I like the series, but I have one minor nit to pick.  The effect of this 
> > series is to harden usercopy, but most of the code is really about 
> > infrastructure to validate that a pointed-to object is valid.
> 
> actually USERCOPY has never been about validating pointers. its sole purpose is 
> to validate the *size* argument of copy*user calls, a very specific form of 
> runtime bounds checking.

What this code has been about originally is largely immaterial, unless you can 
formulate it into a technical argument.

There are a number of cheap tests we can do and there are a number of ways how a 
'pointer' can be validated runtime, without any 'size' information:

 - for example if a pointer points into a red zone straight away then we know it's
   bogus.

 - or if a kernel pointer is points outside the valid kernel virtual memory range
   we know it's bogus as well.

So while only doing a bounds check might have been the original purpose of the 
patch set, Andy's point is that it might make sense to treat this facility as a 
more generic 'object validation' code of (pointer,size) object and not limit it to 
'runtime bounds checking'. That kind of extended purpose behind a facility should 
be reflected in the naming.

Confusing names are often the source of misunderstandings and bugs.

The 9-patch series as submitted here is neither just 'bounds checking' nor just 
pure 'pointer checking', it's about validating that a (pointer,size) range of 
memory passed to a (user) memory copy function is fully within a valid object the 
kernel might know about (in an fast to check fashion).

This necessary means:

 - the start of the range points to a valid object to begin with (if known)

 - the range itself does not point beyond the end of the object (if known)

 - even if the kernel does not know anything about the pointed to object it can 
   do a pointer check (for example is it pointing inside kernel virtual memory) 
   and do a bounds check on the size.

Do you disagree with that?

> > Might it make sense to call the infrastructure part something else?
> 
> yes, more bikeshedding will surely help, [...]

Insulting and ridiculing a reviewer who explicitly qualified his comments with 
"one minor nit to pick" sure does not help upstream integration either. (Unless 
the goal is to prevent upstream integration.)

> [...] like the renaming of .data..read_only to .data..ro_after_init which also 
> had nothing to do with init but everything to do with objects being conceptually 
> read-only...

.data..ro_after_init objects get written to during bootup so it's conceptually 
quite confusing to name it "read-only" without any clear qualifiers.

That it's named consistently with its role of "read-write before init and read 
only after init" on the other hand is not confusing at all. Not sure what your 
problem is with the new name.

Names within submitted patches get renamed on a routine basis during review. It's 
often only minor improvements in naming (which you can consider bike shedding), 
but in this particular case the rename was clearly useful in not just improving 
the name but in avoiding an actively confusing name. So I disagree not just with 
the hostile tone of your reply but with your underlying technical point as well.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
