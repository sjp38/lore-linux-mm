Message-ID: <452AF546.4000901@yahoo.com.au>
Date: Tue, 10 Oct 2006 11:20:06 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: faults and signals
References: <20061009140354.13840.71273.sendpatchset@linux.site>	 <20061009140447.13840.20975.sendpatchset@linux.site>	 <1160427785.7752.19.camel@localhost.localdomain>	 <452AEC8B.2070008@yahoo.com.au> <1160442685.32237.27.camel@localhost.localdomain>
In-Reply-To: <1160442685.32237.27.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> OK, so we made some good progress... now remains my pet issue... faults
> and signals :)
> 
> So in SPUfs, I have cases where apps trying to access user-space
> registers of an SPE that is scheduled out might end up blocking a long
> time in the page fault handler. I'm not 100% sure about DRM at this
> point but I suppose they might have good use of a similar ability I'm
> trying to provide which is for a page fault to be interruptible. That
> would allow various cases of processes stuck in kernel for a logn time
> (or forever if something goes wrong).
> 
> I think your new fault() thingy is the perfect way to get there. In the
> normal page fault case, a signal is easy to handle: just refault
> (NOPAGE_REFAULT without your patch or return NULL; with your patch,
> though we might want to define a -EINTR result explicitely) and the
> signals will be handled on the return to userland path. However, we
> can't really handle them in get_user_pages() nor on kernel own faults
> (__get_user etc...), at least not until we define versions of these that
> can return -EINTR (we might want to do that for get_user_pages, but
> let's assume not for now).
> 
> Thus what is needed is a way to inform the page fault handler wether it
> can be interruptible or not. This could be done using the flags you have
> in there, or some other bits in the argument structure.

Yep, the flags field should be able to do that for you. Since we have
the handle_mm_fault wrapper for machine faults, it isn't too hard to
change the arguments: we should probably turn `write_access` into a
flag so we don't have to push too many arguments onto the stack.

This way we can distinguish get_user_pages faults. And your
architecture will have to switch over to using __handle_mm_fault, and
distinguish kernel faults. Something like that?

> That way, faults could basically check if coming from userland (testing
> the ptregs) and set interruptible in that case (and possibly a flag to
> get_user_pages() telling it can be interruptible for use by drivers who
> can deal with it).
> 
> At the vm_ops level, existing things are fine, they are not
> interruptible, and I can modify spufs to check that new flag and return
> -EINTR on signals when waiting.
> 
> In fact, it might be that filemap and some filesystems might even want
> to handle interruptible page faults :) but that's a different matter.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
