Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B440490010A
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 15:25:02 -0400 (EDT)
Received: by ewy9 with SMTP id 9so2562652ewy.14
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 12:24:59 -0700 (PDT)
Date: Mon, 18 Jul 2011 23:24:54 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC v2] implement SL*B and stack usercopy runtime checks
Message-ID: <20110718192454.GA4489@albatros>
References: <20110703111028.GA2862@albatros>
 <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
 <20110718183951.GA3748@albatros>
 <1311016102.23043.235.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311016102.23043.235.camel@calx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, kernel-hardening@lists.openwall.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 18, 2011 at 14:08 -0500, Matt Mackall wrote:
> On Mon, 2011-07-18 at 22:39 +0400, Vasiliy Kulikov wrote:
> > This patch implements 2 additional checks for the data copied from
> > kernelspace to userspace and vice versa (original PAX_USERCOPY from PaX
> > patch).  Currently there are some very simple and cheap comparisons of
> > supplied size and the size of a copied object known at the compile time
> > in copy_* functions.  This patch enhances these checks to check against
> > stack frame boundaries and against SL*B object sizes.
> > 
> > More precisely, it checks:
> > 
> > 1) if the data touches the stack, checks whether it fully fits in the stack
> > and whether it fully fits in a single stack frame.  The latter is arch
> > dependent, currently it is implemented for x86 with CONFIG_FRAME_POINTER=y
> > only.  It limits infoleaks/overwrites to a single frame and local variables
> > only, and prevents saved return instruction pointer overwriting.
> > 
> > 2) if the data is from the SL*B cache, checks whether it fully fits in a
> > slab page and whether it overflows a slab object.  E.g. if the memory
> > was allocated as kmalloc(64, GFP_KERNEL) and one tries to copy 150
> > bytes, the copy would fail.
> 
> FYI, this should almost certainly be split into (at least) two patches:
> 
> - the stack check
> - the SL*B check (probably one patch per allocator, preceded by one for
> any shared infrastructure)

Sure, also per architecture probably.  But I want to get the comments
about the feature itself before the division.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
