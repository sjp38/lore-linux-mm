Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 438136B00A1
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 17:47:03 -0500 (EST)
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
In-Reply-To: <20101111142511.c98c3808.akpm@linux-foundation.org>
References: <1289421759.11149.59.camel@oralap>
	 <20101111120643.22dcda5b.akpm@linux-foundation.org>
	 <1289512924.428.112.camel@oralap>
	 <20101111142511.c98c3808.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 11 Nov 2010 23:45:58 +0100
Message-ID: <1289515558.428.125.camel@oralap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-11-11 at 14:25 -0800, Andrew Morton wrote:
> And then we can set current->gfp_mask to GFP_ATOMIC when we take an
> interrupt, or take a spinlock.
> 
> And leave it at GFP_KERNEL when in process context.
> 
> And switch GFP_KERNEL to GFP_NOFS in the VM.
> 
> And switch to GFP_NOIO in the block layer.
> 
> So the allocation mode becomes implicit to the task state, so callers
> usually don't need to track it.
> 
> So, ultimately, kmalloc(), alloc_pages() etc don't actually need a mode
> arg at all.  We'll need new, special functions which _do_ take the
> gfp_t but they will be rarely-called specialised things.
>
> And probably we'll need interfaces like
> 
> 	gfp_t mm_set_alloc_mode(gfp_t flags);
> 	void mm_restore_alloc_mode(gfp_t flags);
> 
> 	gfp_t flags;
> 
> 	flags = mm_set_alloc_mode(GFP_NOIO);
> 	...
> 	mm_restore_alloc_mode(flags);

Actually, I think it may not be that simple...

Looking at some of the __GFP_* flags, it seems that some of them look
like allocation "options", i.e. something we may want or may not want to
do on a certain allocation, others look more like "capabilities", i.e.
something that we can or cannot do in a certain context.

For example, __GFP_ZERO, __GFP_REPEAT, __GFP_HIGHMEM, ... is something
that we'd probably want a caller to specify on each allocation, because
only he knows what he actually wants to do.

Others, like __GFP_FS, __GFP_IO, __GFP_WAIT, are things that we either
can or cannot do, depending on the context that we're in.

The latter ones seem worth to start tracking on the task_struct, but the
former ones I think we'd still want to pass them to kmalloc() on each
invocation.

Fortunately, if we put the latter ones in the task_struct, it removes
the need for having to propagate gfp_flags from function to function.

And contrary to what you said previously (which at the time sounded
correct to me), this can actually save a lot of stack space, especially
on more register-starved architectures, because the only places where we
need to save the flags on the stack is when we enter/exit a certain
context, as opposed to having to always having to pass the gfp_mask down
the call stack like we do now.

> argh, someone save us.

:-)

Thanks,
Ricardo


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
