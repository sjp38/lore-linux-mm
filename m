Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20061007134407.6aa4dd26.akpm@osdl.org>
References: <20061007105758.14024.70048.sendpatchset@linux.site>
	 <20061007105853.14024.95383.sendpatchset@linux.site>
	 <20061007134407.6aa4dd26.akpm@osdl.org>
Content-Type: text/plain
Date: Mon, 09 Oct 2006 09:46:13 +1000
Message-Id: <1160351174.14601.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> - So is the plan here to migrate all code over to using
>   vm_operations.fault() and to finally remove vm_operations.nopage and
>   .nopfn?  If so, that'd be nice.

Agreed. That would also allow to pass down knowledge of wether we can be
interruptible or not (coming from userland or not). Useful in a few case
when dealing with strange hw mappings.

Now, fault() still returns a struct page and thus doesn't quite fix the
problem I'm exposing in my "User switchable HW mappings & cie" mail I
posted today in which case we need to either duplicate the truncate
logic in no_pfn() or get rid of no_pfn() and set the PTE from the fault
handler . I tend to prefer the later provided that it's strictly limited
for mappings that do not have a struct page though.
 
> - As you know, there is a case for constructing that `struct fault_data'
>   all the way up in do_no_page(): so we can pass data back, asking
>   do_no_page() to rerun the fault if we dropped mmap_sem.
> 
> - No useful opinion on the substance of this patch, sorry.  It's Saturday ;)
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
