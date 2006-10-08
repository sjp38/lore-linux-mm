Message-ID: <45285E9A.9070009@yahoo.com.au>
Date: Sun, 08 Oct 2006 12:12:42 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
References: <20061007105758.14024.70048.sendpatchset@linux.site>	<20061007105853.14024.95383.sendpatchset@linux.site> <20061007134407.6aa4dd26.akpm@osdl.org>
In-Reply-To: <20061007134407.6aa4dd26.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>- You may find that gcc generates crap code for the initialisation of the
>  `struct fault_data'.  If so, filling the fields in by hand one-at-a-time
>  will improve things.
>

OK.

>- So is the plan here to migrate all code over to using
>  vm_operations.fault() and to finally remove vm_operations.nopage and
>  .nopfn?  If so, that'd be nice.
>

Definitely remove .nopage, .populate, and hopefully .page_mkwrite.

.nopfn is a little harder because it doesn't quite follow the same pattern
as the others (eg. has no struct page).

>- As you know, there is a case for constructing that `struct fault_data'
>  all the way up in do_no_page(): so we can pass data back, asking
>  do_no_page() to rerun the fault if we dropped mmap_sem.
>

That is what it is doing - do_no_page should go away (it is basically
duplicated in __do_fault -- I left it there because I don't know if people
are happy to have a flag day or slowly migrate over).

But I have converted regular pagecache (mm/filemap.c) to use .fault rather
than .nopage and .populate, so you should be able to do the mmap_sem thing
right now. That's something maybe you could look at if you get time? Ie.
whether this .fault handler thing will be sufficient for you.

>- No useful opinion on the substance of this patch, sorry.  It's Saturday ;)
>

No hurry. Thanks for the quick initial comments.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
