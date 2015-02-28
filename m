Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 817F96B0088
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 14:56:27 -0500 (EST)
Received: by igkb16 with SMTP id b16so8425820igk.1
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 11:56:26 -0800 (PST)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id l10si4810498igx.55.2015.02.28.11.56.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Feb 2015 11:56:25 -0800 (PST)
Received: by iecrp18 with SMTP id rp18so38898881iec.9
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 11:56:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425107567.4645.108.camel@kernel.crashing.org>
References: <1422361485.6648.71.camel@opensuse.org>
	<54C78756.9090605@suse.cz>
	<alpine.LSU.2.11.1501271347440.30227@nerf60.vanv.qr>
	<1422364084.6648.82.camel@opensuse.org>
	<s5h7fw8hvdp.wl-tiwai@suse.de>
	<CA+55aFyzy_wYHHnr2gDcYr7qcgOKM2557bRdg6RBa=cxrynd+Q@mail.gmail.com>
	<CA+55aFxRnj97rpSQvvzLJhpo7C8TQ-F=eB1Ry2n53AV1rN8mwA@mail.gmail.com>
	<CAMo8BfLsKCV_2NfgMH4k9jGOHs_-3=NKjCD3o3KK1uH23-6RRg@mail.gmail.com>
	<CA+55aFzQ5QEZ1AYauWviq1gp5j=mqByAtt4fpteeK7amuxcyjw@mail.gmail.com>
	<1422836637.17302.9.camel@au1.ibm.com>
	<CA+55aFw9sg7pu9-2RbMGyPv5yUtcH54QowoH+5RhWqpPYg4YGQ@mail.gmail.com>
	<1425107567.4645.108.camel@kernel.crashing.org>
Date: Sat, 28 Feb 2015 11:56:25 -0800
Message-ID: <CA+55aFy5UvzSgOMKq09u4psz5twtC4aowuK6tofGKDEu-KFMJQ@mail.gmail.com>
Subject: Re: Generic page fault (Was: libsigsegv ....)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Fri, Feb 27, 2015 at 11:12 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
>
> Let me know what you think of the approach.

Hmm. I'm not happy with just how many of those arch wrapper/helper
functions there are, and some of it looks a bit unportable.

For example, the code "knows" that "err_code" and "address" are the
only two architecture-specific pieces of information (in addition to
"struct pt_regs", of course.

And the fault_is_user/write() stuff seems unnecessary - we have the
generic FAULT_FLAG_USER/WRITE flags for that, but instead of passing
in the generic version to the generic function, we pass in the
arch-specific ones.

The same goes for "access_error()". Right now it's an arch-specific
helper function, but it actually does some generic tests (like
checking the vma protections), and I think it could/should be entirely
generic if we just added the necessary FAULT_FLAG_READ/EXEC/NOTPRESENT
information to the "flags" register. Just looking at the ppc version,
my gut feel is that "access_error()" is just horribly error-prone
as-is even from an architecture standpoint.

Yes, the "read/exec/notpresent" bits are a bit weird, but old x86
isn't the only architecture that doesn't necessarily know the
difference between read and exec.

So I'd like a bit more encapsulation. The generic code should never
really need to look at the arch-specific details, although it is true
that then the error handling cases will likely need it (in order to
put it on the arch-specific stack info or similar).

So my *gut* feel is that the generic code should be passed

 - address and the generic flags (ie FAULT_FLAG_USER/WRITE filled in
by the caller)

   These are the only things the generic code should need to use itself

 - I guess we do need to pass in "struct pt_regs", because things like
generic tracing actually want it.

 - an opaque "arch specific fault information structure pointer". Not
used for anything but passing back to the error functions (ie very
much *not* for helper functions for the normal case, like the current
"access_error()" - if it's actually needed for those kinds of things,
then I'm wrong about the model)

   This would (for x86) contain "error_code", but I have the feeling
that other architectures might need/want more than one word of
information.

But I don't know. Maybe I'm wrong. I don't hate the patch as-is, I
just have this feeling that it coudl be more "generic", and less
"random small arch helpers".

                              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
