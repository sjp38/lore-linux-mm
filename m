Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id B67306B0092
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 16:14:52 -0500 (EST)
Received: by mail-vc0-f170.google.com with SMTP id hq12so8685229vcb.1
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 13:14:52 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id m10si3580146vcm.1.2015.02.28.13.14.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 13:14:50 -0800 (PST)
Message-ID: <1425158083.4645.139.camel@kernel.crashing.org>
Subject: Re: Generic page fault (Was: libsigsegv ....)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 01 Mar 2015 08:14:43 +1100
In-Reply-To: <CA+55aFy5UvzSgOMKq09u4psz5twtC4aowuK6tofGKDEu-KFMJQ@mail.gmail.com>
References: <1422361485.6648.71.camel@opensuse.org>
	 <54C78756.9090605@suse.cz>
	 <alpine.LSU.2.11.1501271347440.30227@nerf60.vanv.qr>
	 <1422364084.6648.82.camel@opensuse.org> <s5h7fw8hvdp.wl-tiwai@suse.de>
	 <CA+55aFyzy_wYHHnr2gDcYr7qcgOKM2557bRdg6RBa=cxrynd+Q@mail.gmail.com>
	 <CA+55aFxRnj97rpSQvvzLJhpo7C8TQ-F=eB1Ry2n53AV1rN8mwA@mail.gmail.com>
	 <CAMo8BfLsKCV_2NfgMH4k9jGOHs_-3=NKjCD3o3KK1uH23-6RRg@mail.gmail.com>
	 <CA+55aFzQ5QEZ1AYauWviq1gp5j=mqByAtt4fpteeK7amuxcyjw@mail.gmail.com>
	 <1422836637.17302.9.camel@au1.ibm.com>
	 <CA+55aFw9sg7pu9-2RbMGyPv5yUtcH54QowoH+5RhWqpPYg4YGQ@mail.gmail.com>
	 <1425107567.4645.108.camel@kernel.crashing.org>
	 <CA+55aFy5UvzSgOMKq09u4psz5twtC4aowuK6tofGKDEu-KFMJQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sat, 2015-02-28 at 11:56 -0800, Linus Torvalds wrote:
> On Fri, Feb 27, 2015 at 11:12 PM, Benjamin Herrenschmidt
> <benh@kernel.crashing.org> wrote:
> >
> > Let me know what you think of the approach.
> 
> Hmm. I'm not happy with just how many of those arch wrapper/helper
> functions there are, and some of it looks a bit unportable.
> 
> For example, the code "knows" that "err_code" and "address" are the
> only two architecture-specific pieces of information (in addition to
> "struct pt_regs", of course.
> 
> And the fault_is_user/write() stuff seems unnecessary - we have the
> generic FAULT_FLAG_USER/WRITE flags for that, but instead of passing
> in the generic version to the generic function, we pass in the
> arch-specific ones.

I was trying to keep that fault mask local but it might indeed be a
mistake.

The reasoning is that if you look at more archs (the scary one is
sparc), there is potentially more arch "gunk" that needs to be hooked in
after find_vma()...

And a lot of that need arch specific flags coming in. For example on ppc
I check if the instruction is allowed to grow the stack before we take
the mm sem and pass that information for use by the stack growing check.

Here I could just I suppose add some arch specific fault flags but it
might get messy... 

> The same goes for "access_error()". Right now it's an arch-specific
> helper function, but it actually does some generic tests (like
> checking the vma protections), and I think it could/should be entirely
> generic if we just added the necessary FAULT_FLAG_READ/EXEC/NOTPRESENT
> information to the "flags" register. Just looking at the ppc version,
> my gut feel is that "access_error()" is just horribly error-prone
> as-is even from an architecture standpoint.

I was weary of going down the path of having access_error() be an arch
helper because it gets even wilder with other archs and the crazy
platform flags we deal with on ppc. Here. I was thinking of looking at
factoring that in a second step. You are right that most of it seems
to related to execute permission however (at least sparc, mips, powerpc
and arm).

The way to go would be to define a FAULT_FLAG_EXEC which the arch only
sets if it supports enforcing exec at fault time.

BTW. I fail to see how x86 checks PF_INSTR vs. VM_NOEXEC ... or it doesn't ?

> Yes, the "read/exec/notpresent" bits are a bit weird, but old x86
> isn't the only architecture that doesn't necessarily know the
> difference between read and exec.
> 
> So I'd like a bit more encapsulation. The generic code should never
> really need to look at the arch-specific details, although it is true
> that then the error handling cases will likely need it (in order to
> put it on the arch-specific stack info or similar).

Right, we might still have to pass error_code around, I'll have a look.

> So my *gut* feel is that the generic code should be passed
> 
>  - address and the generic flags (ie FAULT_FLAG_USER/WRITE filled in
> by the caller)
> 
>    These are the only things the generic code should need to use itself
>
>  - I guess we do need to pass in "struct pt_regs", because things like
> generic tracing actually want it.

And error handling but it could be in the latter...

>  - an opaque "arch specific fault information structure pointer". Not
> used for anything but passing back to the error functions (ie very
> much *not* for helper functions for the normal case, like the current
> "access_error()" - if it's actually needed for those kinds of things,
> then I'm wrong about the model)

Well, it might be needed for stack growth check. It's also somewhat
means we have yet *another* fault information structure which is a bit
sad but I don't see a good way to fold them into one.

For errors I was thinking instead of returning error info from the
generic code and leaving the generation of oops/signal to the caller,
which means less arch gunk to carry around.

>    This would (for x86) contain "error_code", but I have the feeling
> that other architectures might need/want more than one word of
> information.
> 
> But I don't know. Maybe I'm wrong. I don't hate the patch as-is, I
> just have this feeling that it coudl be more "generic", and less
> "random small arch helpers".

I don't like it that much either, it's a first draft to see what the
waters are like.

I'll play around more and see what It comes to.

Cheers,
Ben.

> 
>                               Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
