Date: Sun, 20 Feb 2005 22:49:23 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview II
Message-ID: <20050220214922.GA14486@wotan.suse.de>
References: <m1vf8yf2nu.fsf@muc.de> <42114279.5070202@sgi.com> <20050215121404.GB25815@muc.de> <421241A2.8040407@sgi.com> <20050215214831.GC7345@wotan.suse.de> <4212C1A9.1050903@sgi.com> <20050217235437.GA31591@wotan.suse.de> <4215A992.80400@sgi.com> <20050218130232.GB13953@wotan.suse.de> <42168FF0.30700@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42168FF0.30700@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andi Kleen <ak@muc.de>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> >Perhaps node masks would be better and teaching the kernel to handle
> >relative distances inside the masks transparently while migrating?
> >Not sure how complicated this would be to implement though.
> >
> >Supporting interleaving on the new nodes may be also useful, that would
> >need a policy argument at least too and masks.
> >
> 
> The worry I have about using node masks is that it is not as general as
> old_node,new_node mappings (or preferably, the original proposal I made
> of old_node_list, new_node_list).  One can't differentiate between the

I agree that the node arrays are better for this case.

> >>and the majority of the memory is shared, then we only need to make
> >>one system call and one page table scan.  (We just "migrate" the
> >>shared object once.) So the time to do the page table scans disappears
> >
> >
> >I don't like this because it makes it much more complicated
> >to use for user space. And you can set separate policies for
> >shared objects anyways.
> 
> Yes, but only programs that care have to use the va_start and
> va_end.  Programs who want to move everything can specify
> 0 and MAX_INT there and they are done.

I still think it's fundamentally unclean and racy. External processes
shouldn't mess with virtual addresses of other processes.

> >-Andi
> 
> But we are least at the level of agreeing that the new system
> call looks something like the following:
> 
> migrate_pages(pid, count, old_list, new_list);
> 
> right?

For the external case probably yes. For internal (process does this
on its own address space) it should be hooked into mbind() too.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
