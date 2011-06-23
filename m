Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 62B85900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:51:31 -0400 (EDT)
Received: by bwz17 with SMTP id 17so2314262bwz.14
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 06:51:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110623132312.GI31593@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
	<20110622121516.GA28359@infradead.org>
	<20110622123204.GC14343@tiehlicka.suse.cz>
	<20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623074133.GA31593@tiehlicka.suse.cz>
	<20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623090204.GE31593@tiehlicka.suse.cz>
	<20110623190157.1bc8cbb9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623115855.GF31593@tiehlicka.suse.cz>
	<BANLkTimshUCY5Yq5g9dnY0gi2TRneGscug@mail.gmail.com>
	<20110623132312.GI31593@tiehlicka.suse.cz>
Date: Thu, 23 Jun 2011 22:51:28 +0900
Message-ID: <BANLkTikykkd_xBoFxx5Xw+FddWGzZcYeLA@mail.gmail.com>
Subject: Re: [PATCH] mm: preallocate page before lock_page at filemap COW.
 (WasRe: [PATCH V2] mm: Do not keep page locked during page fault while
 charging it for memcg
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Lutz Vieweg <lvml@5t9.de>

2011/6/23 Michal Hocko <mhocko@suse.cz>:
> On Thu 23-06-11 22:01:40, Hiroyuki Kamezawa wrote:
>> 2011/6/23 Michal Hocko <mhocko@suse.cz>:
>> > On Thu 23-06-11 19:01:57, KAMEZAWA Hiroyuki wrote:
>> >> On Thu, 23 Jun 2011 11:02:04 +0200
>> >> Michal Hocko <mhocko@suse.cz> wrote:
>> >>
>> >> > On Thu 23-06-11 17:08:11, KAMEZAWA Hiroyuki wrote:
>> >> > > On Thu, 23 Jun 2011 09:41:33 +0200
>> >> > > Michal Hocko <mhocko@suse.cz> wrote:
>> >> > [...]
>> >> > > > Other than that:
>> >> > > > Reviewed-by: Michal Hocko <mhocko@suse.cz>
>> >> > > >
>> >> > >
>> >> > > I found the page is added to LRU before charging. (In this case,
>> >> > > memcg's LRU is ignored.) I'll post a new version with a fix.
>> >> >
>> >> > Yes, you are right. I have missed that.
>> >> > This means that we might race with reclaim which could evict the COWed
>> >> > page wich in turn would uncharge that page even though we haven't
>> >> > charged it yet.
>> >> >
>> >> > Can we postpone page_add_new_anon_rmap to the charging path or it would
>> >> > just race somewhere else?
>> >> >
>> >>
>> >> I got a different idea. How about this ?
>> >> I think this will have benefit for non-memcg users under OOM, too.
>> >
>> > Could you be more specific? I do not see how preallocation which might
>> > turn out to be pointless could help under OOM.
>> >
>>
>> We'll have no page allocation under lock_page() held in this path.
>> I think it is good.
>
> But it can also cause that the page, we are about to fault in, is evicted
> due to allocation so we would have to do a major fault... This is
> probably not that serious, though.

For other purpose, I have(had) other patch to prevent it (and planned
to post it.)

The basic logic is...

1. add a new member variable to vm_area_struct as

  vma->vm_faulting_to

2. at __do_fault(), set vm_faulting_to as

  vma->vm_faulting_to = pgoff.


3. chec vma->vm_faulting_to at page_referenced_file() as

  if (pgoff (Was page->index) == vma->vm_faulting_to)
        referenced++

Then, the page which someone is waiting for page-fault will be marked as
referenced  and go KEEP_LOCKED.

(vm_faulting_to can be cleared after we got lock_page()).

In corner case, several threads which shares vma may fault into a vma.
But this will help typical case and have no overheads, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
