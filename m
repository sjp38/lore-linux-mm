Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 82EEE6B0032
	for <linux-mm@kvack.org>; Sun, 15 Feb 2015 23:36:57 -0500 (EST)
Received: by pdjz10 with SMTP id z10so32529964pdj.12
        for <linux-mm@kvack.org>; Sun, 15 Feb 2015 20:36:57 -0800 (PST)
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com. [209.85.192.180])
        by mx.google.com with ESMTPS id u6si2952438pdn.3.2015.02.15.20.36.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Feb 2015 20:36:56 -0800 (PST)
Received: by pdbfp1 with SMTP id fp1so32529580pdb.9
        for <linux-mm@kvack.org>; Sun, 15 Feb 2015 20:36:56 -0800 (PST)
Date: Mon, 16 Feb 2015 13:36:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20150216043644.GA19630@blaptop>
References: <20141205083249.GA2321@dhcp22.suse.cz>
 <54D0F9BC.4060306@gmail.com>
 <20150203234722.GB3583@blaptop>
 <20150206003311.GA2347@kernel.org>
 <20150206055103.GA13244@blaptop>
 <20150206182918.GA2290@kernel.org>
 <20150209071553.GC32300@blaptop>
 <20150210223826.GA2342@kernel.org>
 <20150211005620.GA4078@blaptop>
 <20150212001403.GA2380@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150212001403.GA2380@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Shaohua,

On Wed, Feb 11, 2015 at 04:14:03PM -0800, Shaohua Li wrote:
> On Wed, Feb 11, 2015 at 09:56:20AM +0900, Minchan Kim wrote:
> > Hi Shaohua,
> > 
> > On Tue, Feb 10, 2015 at 02:38:26PM -0800, Shaohua Li wrote:
> > > On Mon, Feb 09, 2015 at 04:15:53PM +0900, Minchan Kim wrote:
> > > > On Fri, Feb 06, 2015 at 10:29:18AM -0800, Shaohua Li wrote:
> > > > > On Fri, Feb 06, 2015 at 02:51:03PM +0900, Minchan Kim wrote:
> > > > > > Hi Shaohua,
> > > > > > 
> > > > > > On Thu, Feb 05, 2015 at 04:33:11PM -0800, Shaohua Li wrote:
> > > > > > > 
> > > > > > > Hi Minchan,
> > > > > > > 
> > > > > > > Sorry to jump in this thread so later, and if some issues are discussed before.
> > > > > > > I'm interesting in this patch, so tried it here. I use a simple test with
> > > > > > 
> > > > > > No problem at all. Interest is always win over ignorance.
> > > > > > 
> > > > > > > jemalloc. Obviously this can improve performance when there is no memory
> > > > > > > pressure. Did you try setup with memory pressure?
> > > > > > 
> > > > > > Sure but it was not a huge memory system like yours.
> > > > > 
> > > > > Yes, I'd like to check the symptom in memory pressure, so choose such test.
> > > > > 
> > > > > > > In my test, jemalloc will map 61G vma, and use about 32G memory without
> > > > > > > MADV_FREE. If MADV_FREE is enabled, jemalloc will use whole 61G memory because
> > > > > > > madvise doesn't reclaim the unused memory. If I disable swap (tweak your patch
> > > > > > 
> > > > > > Yes, IIUC, jemalloc replaces MADV_DONTNEED with MADV_FREE completely.
> > > > > 
> > > > > right.
> > > > > > > slightly to make it work without swap), I got oom. If swap is enabled, my
> > > > > > 
> > > > > > You mean you modified anon aging logic so it works although there is no swap?
> > > > > > If so, I have no idea why OOM happens. I guess it should free all of freeable
> > > > > > pages during the aging so although system stall happens more, I don't expect
> > > > > > OOM. Anyway, with MADV_FREE with no swap, we should consider more things
> > > > > > about anonymous aging.
> > > > > 
> > > > > In the patch, MADV_FREE will be disabled and fallback to DONTNEED if no swap is
> > > > > enabled. Our production environment doesn't enable swap, so I tried to delete
> > > > > the 'no swap' check and make MADV_FREE always enabled regardless if swap is
> > > > > enabled. I didn't change anything else. With such change, I saw oom
> > > > > immediately. So definitely we have aging issue, the pages aren't reclaimed
> > > > > fast.
> > > > 
> > > > In current VM implementation, it doesn't age anonymous LRU list if we have no
> > > > swap. That's the reason to drop freeing pages instantly.
> > > > I think it could be enhanced later.
> > > > http://lists.infradead.org/pipermail/linux-arm-kernel/2014-December/311591.html
> > > > 
> > > > > 
> > > > > > > system is totally stalled because of swap activity. Without the MADV_FREE,
> > > > > > > everything is ok. Considering we definitely don't want to waste too much
> > > > > > > memory, a system with memory pressure is normal, so sounds MADV_FREE will
> > > > > > > introduce big trouble here.
> > > > > > > 
> > > > > > > Did you think about move the MADV_FREE pages to the head of inactive LRU, so
> > > > > > > they can be reclaimed easily?
> > > > > > 
> > > > > > I think it's desirable if the page lived in active LRU.
> > > > > > The reason I didn't that was caused by volatile ranges system call which
> > > > > > was motivaion for MADV_FREE in my mind.
> > > > > > In last LSF/MM, there was concern about data's hotness.
> > > > > > Some of users want to keep that as it is in LRU position, others want to
> > > > > > handle that as cold(tail of inactive list)/warm(head of inactive list)/
> > > > > > hot(head of active list), for example.
> > > > > > The vrange syscall was just about volatiltiy, not depends on page hotness
> > > > > > so the decision on my head was not to change LRU order and let's make new
> > > > > > hotness advise if we need it later.
> > > > > > 
> > > > > > However, MADV_FREE's main customer is allocators and afaik, they want
> > > > > > to replace MADV_DONTNEED with MADV_FREE so I think it is really cold,
> > > > > > but we couldn't make sure so head of inactive is good compromise.
> > > > > > Another concern about tail of inactive list is that there could be
> > > > > > plenty of pages in there, which was asynchromos write-backed in
> > > > > > previous reclaim path, not-yet reclaimed because of not being able
> > > > > > to free the in softirq context of writeback. It means we ends up
> > > > > > freeing more potential pages to become workingset in advance
> > > > > > than pages VM already decided to evict.
> > > > > 
> > > > > Yes, they are definitely cold pages. I thought We should make sure the
> > > > > MADV_FREE pages are reclaimed first before other pages, at least in the anon
> > > > > LRU list, though there might be difficult to determine if we should reclaim
> > > > > writeback pages first or MADV_FREE pages first.
> > > > 
> > > > Frankly speaking, the issue with writeback page is just hurdle of
> > > > implementation, not design so if we could fix it, we might move
> > > > cold pages into tail of the inactive LRU. I tried it but don't have
> > > > time slot to continue these days. Hope to get a time to look soon.
> > > > https://lkml.org/lkml/2014/7/1/628
> > > > Even, it wouldn't be critical problem although we couldn't fix
> > > > the problem of writeback pages because they are already all
> > > > cold pages so it might be not important to keep order in LRU so
> > > > we could save working set and effort of VM to reclaim them
> > > > at the cost of moving all of hinting pages into tail of the LRU
> > > > whenever the syscall is called.
> > > > 
> > > > However, significant problem from my mind is we couldn't make
> > > > sure they are really cold pages. It would be true for allocators
> > > > but it's cache-friendly pages so it might be better to discard
> > > > tail pages of inactive LRU, which are really cold.
> > > > In addition, we couldn't expect all of usecase for MADV_FREE
> > > > so some of users might want to treat them as warm, not cold.
> > > > 
> > > > With moving them into inactive list's head, if we still see
> > > > a lot stall, I think it's a sign to add other logic, for example,
> > > > we could drop MADV_FREEed pages instantly if the zone is below
> > > > low min watermark when the syscall is called. Because everybody
> > > > doesn't like direct reclaim.
> > > 
> > > So I tried move the MADV_FREE pages to inactive list head or tail. It helps a
> > > little. But there are still stalls/oom. kswapd isn't fast enough to free the
> > > pages, App enters direct reclaim frequently. In one machine, no swap trigger,
> > > but MADV_FREE is 5x slower than MADV_DONTNEED. In another machine, MADV_FREE
> > 
> > It's expected. MADV_DONTNEED and MADV_FREE is really different.
> > MADV_DONTNEED is self-sacrificy for others in the system while MADV_FREE is
> > greedy approach for itself because random process asking the memory could
> > enter direct reclaim.
> > However, as I said earlier, we could mitigate the problem by checking
> > min_free_kbytes. If memory in the system is under min_free_kbytes, it is
> > pointless to impose reclaim overhead for hinted pages because we alreay
> > know the hint is "please free when you are trouble with memory" and we got
> > know it already.
> > 
> > When I test below patch on my 3G machine + 12 CPU + 8G swap with below test
> > test: 12 processes(each process does 5 iteration: mmap 512M + memset + madvise),
> > 
> > 1. MADV_DONTNEED : 41.884sec, sys:3m4.552
> > 2. MADV_FREE : 1m28sec, sys: 5m23
> > 3. MADV_FREE + below patch : 37.188s, sys: 2m20
> > 
> > Could you test?
> >         
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 6d0fcb8..da15f8f 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -523,7 +523,7 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
> >  		 * XXX: In this implementation, MADV_FREE works like
> >  		 * MADV_DONTNEED on swapless system or full swap.
> >  		 */
> > -		if (get_nr_swap_pages() > 0)
> > +		if (get_nr_swap_pages() > 0 && min_free_kbytes < nr_free_pages())
> >  			return madvise_free(vma, prev, start, end);
> >  		/* passthrough */
> >  	case MADV_DONTNEED:
> 
> The throttling makes a lot of sense, definitely should be included in the
> patch. At least my jemalloc test has similar performance result with/without

Yeb, I will post it with a little modification after long vacation.

> the patch in memory pressure case. So overall I'm pretty happy with it.

Thanks for the testing.

> However, this only solves half of the problem. pages which are MADV_FREE before
> watermark is hit are still hard to be reclaimed later if there are other
> allocations. I'm not sure how severe this issue is. My jemalloc test frequently
> does madvise (fallback to DONTNEED with above change), so itself can free a lot
> of memory in memory pressure. If application uses MADV_FREE before watermark is
> hit, but don't use it after watermark is hit, we will have trouble.

Fair enough. It might make those pages close to inactive LRU's tail
be unlikely to free, instead rotate back to active LRU.
Hmm, I don't know how such anonymous LRU scanning without freeing makes
trobule in huge system.

Anyway, one of the idea is we could use COW so that it could move recent
dirtied pages into active LRU's head. Although it adds more overhead for
MADV_FREE than now, it could solve above issue.

As well, I think we could make MADV_FREE support on swapless system easier.
On swapless system, we don't move pages in active LRU to inactive so
when MADV_FREE is called on, we could move those pages in inactive's LRU
and if recent access happens on those pages before discarding by VM,
we could move them from inactive to active list. So, inactive LRU list
could have mostly freeable pages(if swapoff race happens, some of
non-freeable pages remains inactive list) so it's not a performan
problem only if VM does aging if there are anonymous pages
in inactive LRU list on swapless system.

> 
> Thanks,
> Shaohua

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
