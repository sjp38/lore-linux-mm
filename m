Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id DC7E06B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 18:15:08 -0400 (EDT)
Date: Wed, 14 Aug 2013 17:15:06 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
	embedded in the buddy allocator
Message-ID: <20130814221505.GA147490@asylum.americas.sgi.com>
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com> <1376344480-156708-1-git-send-email-nzimmer@sgi.com> <CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com> <520A6DFC.1070201@sgi.com> <CA+55aFwRHdQ_f6ryUU1yWkW1Qz8cG958jLZuyhd_YdOq4-rfRA@mail.gmail.com> <20130814110556.GH10849@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814110556.GH10849@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Travis <travis@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Peter Anvin <hpa@zytor.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Rob Landley <rob@landley.net>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

On Wed, Aug 14, 2013 at 01:05:56PM +0200, Ingo Molnar wrote:
> 
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > [...]
> > 
> > Ok, so I don't know all the issues, and in many ways I don't even really 
> > care. You could do it other ways, I don't think this is a big deal. The 
> > part I hate is the runtime hook into the core MM page allocation code, 
> > so I'm just throwing out any random thing that comes to my mind that 
> > could be used to avoid that part.
> 
> So, my hope was that it's possible to have a single, simple, zero-cost 
> runtime check [zero cost for already initialized pages], because it can be 
> merged into already existing page flag mask checks present here and 
> executed for every freshly allocated page:
> 
> static inline int check_new_page(struct page *page)
> {
>         if (unlikely(page_mapcount(page) |
>                 (page->mapping != NULL)  |
>                 (atomic_read(&page->_count) != 0)  |
>                 (page->flags & PAGE_FLAGS_CHECK_AT_PREP) |
>                 (mem_cgroup_bad_page_check(page)))) {
>                 bad_page(page);
>                 return 1;
>         }
>         return 0;
> }
> 
> We already run this for every new page allocated and the initialization 
> check could hide in PAGE_FLAGS_CHECK_AT_PREP in a zero-cost fashion.
> 
> I'd not do any of the ensure_page_is_initialized() or 
> __expand_page_initialization() complications in this patch-set - each page 
> head represents itself and gets iterated when check_new_page() is done.
> 
> During regular bootup we'd initialize like before, except we don't set up 
> the page heads but memset() them to zero. With each page head 32 bytes 
> this would mean 8 GB of page head memory to clear per 1 TB - with 16 TB 
> that's 128 GB to clear - that ought to be possible to do rather quickly, 
> perhaps with some smart SMP cross-call approach that makes sure that each 
> memset is done in a node-local fashion. [*]
> 
> Such an approach should IMO be far smaller and less invasive than the 
> patches presented so far: it should be below 100 lines or so.
> 
> I don't know why there's such a big difference between the theory I 
> outlined and the invasive patch-set implemented so far in practice, 
> perhaps I'm missing some complication. I was trying to probe that 
> difference, before giving up on the idea and punting back to the async 
> hotplug-ish approach which would obviously work well too.
> 

The reason, which I failed to mention, is once we pull off a page the lru in
either __rmqueue_fallback or __rmqueue_smallest the first thing we do with it
is expand() or sometimes move_freepages().  These then trip over some BUG_ON and
VM_BUG_ON.
Those BUG_ONs are what keep causing me to delve into the ensure/expand foolishness.

Nate

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
