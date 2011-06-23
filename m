Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE30900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:01:44 -0400 (EDT)
Received: by bwz17 with SMTP id 17so2263150bwz.14
        for <linux-mm@kvack.org>; Thu, 23 Jun 2011 06:01:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110623115855.GF31593@tiehlicka.suse.cz>
References: <20110622120635.GB14343@tiehlicka.suse.cz>
	<20110622121516.GA28359@infradead.org>
	<20110622123204.GC14343@tiehlicka.suse.cz>
	<20110623150842.d13492cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623074133.GA31593@tiehlicka.suse.cz>
	<20110623170811.16f4435f.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623090204.GE31593@tiehlicka.suse.cz>
	<20110623190157.1bc8cbb9.kamezawa.hiroyu@jp.fujitsu.com>
	<20110623115855.GF31593@tiehlicka.suse.cz>
Date: Thu, 23 Jun 2011 22:01:40 +0900
Message-ID: <BANLkTimshUCY5Yq5g9dnY0gi2TRneGscug@mail.gmail.com>
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
> On Thu 23-06-11 19:01:57, KAMEZAWA Hiroyuki wrote:
>> On Thu, 23 Jun 2011 11:02:04 +0200
>> Michal Hocko <mhocko@suse.cz> wrote:
>>
>> > On Thu 23-06-11 17:08:11, KAMEZAWA Hiroyuki wrote:
>> > > On Thu, 23 Jun 2011 09:41:33 +0200
>> > > Michal Hocko <mhocko@suse.cz> wrote:
>> > [...]
>> > > > Other than that:
>> > > > Reviewed-by: Michal Hocko <mhocko@suse.cz>
>> > > >
>> > >
>> > > I found the page is added to LRU before charging. (In this case,
>> > > memcg's LRU is ignored.) I'll post a new version with a fix.
>> >
>> > Yes, you are right. I have missed that.
>> > This means that we might race with reclaim which could evict the COWed
>> > page wich in turn would uncharge that page even though we haven't
>> > charged it yet.
>> >
>> > Can we postpone page_add_new_anon_rmap to the charging path or it would
>> > just race somewhere else?
>> >
>>
>> I got a different idea. How about this ?
>> I think this will have benefit for non-memcg users under OOM, too.
>
> Could you be more specific? I do not see how preallocation which might
> turn out to be pointless could help under OOM.
>

We'll have no page allocation under lock_page() held in this path.
I think it is good.

>>
>> A concerns is VM_FAULT_RETRY case but wait-for-lock will be much heavier
>> than preallocation + free-for-retry cost.
>
> Preallocation is rather costly when fault handler fails (e.g. SIGBUS
> which is the easiest one to trigger).
>
I think pcp cache of free page allocater does enough good job and I guess
we'll see no problem even if there is a storm of SIGBUS.

> I am not saying this approach is bad but I think that preallocation can
> be much more costly than unlock, charge and lock&recheck approach.

memcg_is_disabled() cannot help ROOT cgroup. And additional
lock/unlock method may kill FAULT_RETRY at lock contention optimization
which was added recently.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
