Date: Tue, 27 May 2008 01:47:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] 2.6.26-rc: x86: pci-dma.c: use __GFP_NO_OOM instead of
 __GFP_NORETRY
Message-Id: <20080527014720.6db68517.akpm@linux-foundation.org>
In-Reply-To: <20080526234940.GA1376@xs4all.net>
References: <20080526234940.GA1376@xs4all.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <mikevs@xs4all.net>
Cc: Andi Kleen <andi@firstfloor.org>, Glauber Costa <gcosta@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 27 May 2008 01:49:47 +0200 Miquel van Smoorenburg <mikevs@xs4all.net> wrote:

> Please consider the below patch for 2.6.26 (can somebody from the
> x86 team pick this up please? Thank you)
> 
> 
> 
> [PATCH] 2.6.26-rc: x86: pci-dma.c: use __GFP_NO_OOM instead of __GFP_NORETRY
> 
> arch/x86/kernel/pci-dma.c::dma_alloc_coherent() adds __GFP_NORETRY to
> the gfp flags before calling alloc_pages() to prevent the oom killer
> from running.

Now, why does dma_alloc_coherent() do that?

If __GFP_FS is cleared (most cases) then we won't be calling
out_of_memory() anyway.

If __GFP_FS _is_ set then setting __GFP_NORETRY will do much more than
avoiding oom-killings.  It will prevent the page allocator from
retrying and will cause the problems which one assumes (without
evidence :() you have observed.

So...  why not just remove the setting of __GFP_NORETRY?  Why is it
wrong to oom-kill things in this case?

> This has the expected side effect that that alloc_pages() doesn't
> retry anymore. Not really a problem for dma_alloc_coherent(.. GFP_ATOMIC)
> which is the way most drivers use it (through pci_alloc_consistent())
> but drivers that call dma_alloc_coherent(.. GFP_KERNEL) directly can get
> unexpected failures.
> 
> Until we have the mask allocator, use a new flag __GFP_NO_OOM
> instead of __GFP_NORETRY.
> 

But this change increases the chances of a caller getting stuck in the
page allocator for ever, unable to make progress?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
