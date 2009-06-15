Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 60B6E6B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 02:56:21 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id d14so1738130and.26
        for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:58:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090612143005.GA4429@csn.ul.ie>
References: <202cde0e0906112141n634c1bd6n15ec1ac42faa36d3@mail.gmail.com>
	 <20090612143005.GA4429@csn.ul.ie>
Date: Mon, 15 Jun 2009 18:58:08 +1200
Message-ID: <202cde0e0906142358x6474ad7fxeac0a3e60634021@mail.gmail.com>
Subject: Re: Huge pages for device drivers
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

>
> Ok. So the order is
>
> 1. driver alloc_pages()
> 2. driver DMA
> 3. userspace mmap
> 4. userspace fault
>
> ?
Correct.
The only minor difference in my case memory is remapped in mmap call
not in fault. (But this is not important)

> There is a subtle distinction depending on what you are really looking for.
> If all you are interested in is large contiguous pages, then that is relatively
> handy. I did a hatchet-job below to show how one could allocate pages from
> hugepage pools that should not break reservations. It's not tested, it's just
> to illustrate how something like this might be implemented because it's been
> asked for a number of times. However, I doubt it's what driver people really
> want, it's just what has been asked for on occasion :)

Good question. I remember just two cases, when it was desired:
1. Driver/libraries for video card which has no own video memory.
Implementation was based
on data handling through DirectFB interface. Video card allocated
128MB - 192MB of system RAM which was maped to user space. User space
library performed
big bunch of operations with RAM assigned for video card.  (Card and
drivers were for STB solution)

2. 10Gb networking, where data analysing can consume all available
resources  on most
powerful servers. Performance is critical here as 5-7% perf gain -
means xxk$ cheaper servers.
Both cases are pretty specific IMHO.

> If you must get those mapped into userspace, then it would be tricky to get the
> pages above mapped into userspace properly, particularly with respect to PTEs
> and then making sure the fault occurs properly. I'd hate to be maintaining such
> a driver. It could be worked around to some extent by doing something similar
> to what happens for shmget() and shmat() and this would be relatively reusable.
>
Yes it is a thing I need.

> 1. Create a wrapper around hugetlb_file_setup() similar to what happens in
> ipc/shm.c#newseg(). That would create a hugetlbfs file on an invisible mount
> and reserve the hugepages you will need.
>
> 2. Create a function that is similar to a nopage fault handler that allocates
> a hugepage within an offset in your hidden hugetlbfs file and inserts it
> into the hugetlbfs pagecache giving you back the page frame for use with DMA.
>
The main problem is here, because it is necessary to do operations with PTE
to insert huge pages into given VMA. So it is necessary to provide
some prototype for drivers
here. I'm fine to modify code here but completely not sure what
interfaces must be given for drivers.
(Not sure that it is good just to export calls like huge_pte_alloc? ).

> Most of the code you need is already there, just not quite in the shape
> you want it in. I have no plans to implement such a thing but I estimate it
> wouldn't take someone who really cared more than a few days to implement it.
>
> Anyway, here is the alloc_huge_page() prototype for what that's worth to
> you
>
Thank you so much for this prototype it is very helpful. I applied and
tried it today and stopped
at the problem of page fault handling.

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
