Date: Sat, 7 Oct 2006 13:44:07 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
Message-Id: <20061007134407.6aa4dd26.akpm@osdl.org>
In-Reply-To: <20061007105853.14024.95383.sendpatchset@linux.site>
References: <20061007105758.14024.70048.sendpatchset@linux.site>
	<20061007105853.14024.95383.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat,  7 Oct 2006 15:06:32 +0200 (CEST)
Nick Piggin <npiggin@suse.de> wrote:

> Nonlinear mappings are (AFAIKS) simply a virtual memory concept that
> encodes the virtual address -> file offset differently from linear
> mappings.
> 
> I can't see why the filesystem/pagecache code should need to know anything
> about it, except for the fact that the ->nopage handler didn't quite pass
> down enough information (ie. pgoff). But it is more logical to pass pgoff
> rather than have the ->nopage function calculate it itself anyway. And
> having the nopage handler install the pte itself is sort of nasty.
> 
> This patch introduces a new fault handler that replaces ->nopage and ->populate
> and (hopefully) ->page_mkwrite. Most of the old mechanism is still in place
> so there is a lot of duplication and nice cleanups that can be removed if
> everyone switches over.
> 
> The rationale for doing this in the first place is that nonlinear mappings
> are subject to the pagefault vs invalidate/truncate race too, and it seemed
> stupid to duplicate the synchronisation logic rather than just consolidate
> the two.

- You may find that gcc generates crap code for the initialisation of the
  `struct fault_data'.  If so, filling the fields in by hand one-at-a-time
  will improve things.

- So is the plan here to migrate all code over to using
  vm_operations.fault() and to finally remove vm_operations.nopage and
  .nopfn?  If so, that'd be nice.

- As you know, there is a case for constructing that `struct fault_data'
  all the way up in do_no_page(): so we can pass data back, asking
  do_no_page() to rerun the fault if we dropped mmap_sem.

- No useful opinion on the substance of this patch, sorry.  It's Saturday ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
