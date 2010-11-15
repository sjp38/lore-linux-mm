Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 077AF8D006C
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 18:32:51 -0500 (EST)
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
From: "Ricardo M. Correia" <ricardo.correia@oracle.com>
In-Reply-To: <alpine.DEB.2.00.1011151426360.20468@chino.kir.corp.google.com>
References: <1289421759.11149.59.camel@oralap>
	 <20101111120643.22dcda5b.akpm@linux-foundation.org>
	 <1289512924.428.112.camel@oralap>
	 <20101111142511.c98c3808.akpm@linux-foundation.org>
	 <1289840500.13446.65.camel@oralap>
	 <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
	 <1289859596.13446.151.camel@oralap>
	 <alpine.DEB.2.00.1011151426360.20468@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 16 Nov 2010 00:30:57 +0100
Message-ID: <1289863857.13446.199.camel@oralap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-15 at 14:50 -0800, David Rientjes wrote:
> Instead of extending the __*() functions with 
> more underscores like other places in the kernel (see mm/slab.c, for 
> instance), I'd suggest just appending _gfp() to their name so 
> __pmd_alloc() uses a new __pmd_alloc_gfp().

Sounds good to me.

> > For our case, I'd think it's better to either handle failure or somehow
> > retry until the allocation succeeds (if we know for sure that it will,
> > eventually).
> > 
> 
> If your use-case is going to block until this memory is available, there's 
> a serious problem that you'll need to address because nothing is going to 
> guarantee that memory will be freed unless something else is trying to 
> allocate memory and pages get written back or something gets killed as a 
> result.

In our use case, this code is only used on servers that are used for
serving a Lustre filesystem and nothing else, so we don't have to worry
about things like run-away memory hogs / user applications.

Currently we do block until this memory is available. I'd rather not go
much into this, but the amount of memory that can be allocated by this
method at any point in time is huge but it's bounded.

Also, we have a slab reclaim callback that signals a dedicated thread,
which asynchronously frees memory (it would free synchronously if
possible, but unfortunately it's not).

This thread is able to potentially free GBs of memory if necessary, and
therefore allow the vmalloc allocations in the I/O path to succeed
eventually. We know this because we limit the amount of memory that can
be allocated and nothing else can use a significant amount of memory on
our systems.

I know this is not how you'd typically do this, but we also have other
constraints (which again, I'd rather not go into) which makes this our
preferred solution.

>   Strictly relying on that behavior is concerning, but it's not 
> something that can be fixed in the VM.
>
> > Not sure what do you mean by this.. I don't see a typical vmalloc()
> > using __GFP_REPEAT anywhere (apart from functions such as
> > pmd_alloc_one(), which in the code above you suggested to keep passing
> > __GFP_REPEAT).. am I missing something?
> > 
> 
> __GFP_REPEAT will retry the allocation indefinitely until the needed 
> amount of memory is reclaimed without considering the order of the 
> allocation; all orders of interest in your case are order-0, so it will 
> loop indefinitely until a single page is reclaimed which won't happen with 
> GFP_NOFS.  Thus, passing the flag is the equivalent of asking the 
> allocator to loop forever until memory is available rather than failing 
> and returning to your error handling.

When you say loop forever, you don't mean in a busy loop, right?
Assuming we sleep in this loop (which AFAICS it does), then it's OK for
us because memory will be freed asynchronously.

If it didn't sleep then it'd be more concerning because all CPUs could
enter this loop and we'd deadlock..

Anyway, I will try the approach that you suggested and send out a new
patch. 

Thanks!

- Ricardo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
