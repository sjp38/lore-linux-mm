Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id DABE86B0006
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 22:01:53 -0500 (EST)
Received: by mail-ve0-f171.google.com with SMTP id b10so943365vea.30
        for <linux-mm@kvack.org>; Thu, 07 Mar 2013 19:01:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130308023511.GD23767@cmpxchg.org>
References: <CAGDaZ_rvfrBVCKMuEdPcSod684xwbUf9Aj4nbas4_vcG3V9yfg@mail.gmail.com>
 <20130308023511.GD23767@cmpxchg.org>
From: Raymond Jennings <shentino@gmail.com>
Date: Thu, 7 Mar 2013 19:01:12 -0800
Message-ID: <CAGDaZ_pr_Tv5yvdZJrhLJ_h=jNve_NAF8auuHnBeRy44VBqagg@mail.gmail.com>
Subject: Re: Swap defragging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>

Not to mention that swapped pages get freed when modified in RAM IIRC.

On Thu, Mar 7, 2013 at 6:35 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, Mar 07, 2013 at 06:07:23PM -0800, Raymond Jennings wrote:
>> Just a two cent question, but is there any merit to having the kernel
>> defragment swap space?
>
> That is a good question.
>
> Swap does fragment quite a bit, and there are several reasons for
> that.
>
> We swap pages in our LRU list order, but this list is sorted by first
> access, not by access frequency (not quite that cookie cutter, but the
> ordering is certainly fairly coarse).  This means that the pages may
> already be in suboptimal order for swap in at the time of swap out.
>
> Once written to disk, the layout tends to stick.  One reason is that
> we actually try to not free swap slots unless there is a shortage of
> swap space to save future swap out IO (grep for vm_swap_full()).  The
> other reason is that if a page shared among multiple threads is
> swapped out, it can not be removed from swap until all threads have
> faulted the page back in because of page table entries still referring
> to the swap slot on disk.  In a multi-threaded application, this is
> rather unlikely.
>
> So even though the referencing order of the application might change,
> the disk layout won't.  But adjusting the disk layout speculatively
> increases disk IO, so it could be hard to prove that you came up with
> a net improvement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
