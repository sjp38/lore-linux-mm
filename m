Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9894682F6B
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 16:03:50 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so136884917wic.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 13:03:50 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id m11si18584711wij.112.2015.10.05.13.03.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 13:03:49 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so130256777wic.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 13:03:49 -0700 (PDT)
Date: Mon, 5 Oct 2015 22:03:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 99471] System locks with kswapd0 and kworker taking full IO
 and mem
Message-ID: <20151005200345.GA12889@dhcp22.suse.cz>
References: <bug-99471-27@https.bugzilla.kernel.org/>
 <bug-99471-27-hjYeBz7jw2@https.bugzilla.kernel.org/>
 <20150910140418.73b33d3542bab739f8fd1826@linux-foundation.org>
 <20150915083919.GG2858@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150915083919.GG2858@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, gaguilar@aguilardelgado.com, sgh@sgh.dk, Rik van Riel <riel@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>

[Sorry for replying here but I couldn't find the original Andrew's email
in my mailbox]

On Tue 15-09-15 10:39:19, Johannes Weiner wrote:
> On Thu, Sep 10, 2015 at 02:04:18PM -0700, Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Tue, 01 Sep 2015 12:32:10 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> > > https://bugzilla.kernel.org/show_bug.cgi?id=99471
> > 
> > Guys, could you take a look please?
> > 
> > The machine went oom when there's heaps of unused swap and most memory
> > is being used on active_anon and inactive_anon.  We should have just
> > swapped that stuff out and kept going.

I would strongly suspect the memory is pinned by somebody which
completely ruins all the get_scan_count assumptions. The first
referenced OOM report might contain a hint:
[ 2162.123944] Purging GPU memory, 368640 bytes freed, 615292928 bytes still pinned.
[ 2175.996060] Purging GPU memory, 499712 bytes freed, 615251968 bytes still pinned.
[ 2175.998841] bash invoked oom-killer: gfp_mask=0x20858, order=0, oom_score_adj=0
[ 2175.998844] bash cpuset=/ mems_allowed=0
[...]
[ 2175.999016] active_anon:305425 inactive_anon:141206 isolated_anon:0
                active_file:5109 inactive_file:4666 isolated_file:0
                unevictable:4 dirty:2 writeback:0 unstable:0
                free:13218 slab_reclaimable:6552 slab_unreclaimable:11310
                mapped:21203 shmem:155079 pagetables:10921 bounce:0
                free_cma:0
[...]
[ 2175.999074] 169619 total pagecache pages
[ 2175.999076] 4752 pages in swap cache
[ 2175.999078] Swap cache stats: add 468915, delete 464163, find 76521/98873
[ 2175.999080] Free swap  = 1615656kB
[ 2175.999082] Total swap = 2097148kB
[ 2175.999083] 521838 pages RAM
[ 2175.999084] 0 pages HighMem/MovableOnly
[ 2175.999086] 11811 pages reserved
[ 2175.999087] 0 pages hwpoisoned

So there is more than 600MB used by the GPU. Later OOM invocations do
not mention GPU OOM shrinker at all. Anon+File+Unevict+Free+Slab+Pagetbl
gives us 1.9G so considerable amount of pinned memory has to be sitting
on LRU lists. I would bet it is shmem here but there is still more than
1G on the anon LRU lists. Is it possible they are pinned indirectly?
I am CCing Daniel for the GPU memory consumption. Maybe there is some
additional diagnostic to look at.

Another interesting thing to note is that
[ 2175.999473] Out of memory: Kill process 3566 (java) score 170 or sacrifice child
[ 2175.999477] Killed process 3566 (java) total-vm:3417044kB, anon-rss:703656kB, file-rss:0kB
[...]
[ 2176.000641] bash invoked oom-killer: gfp_mask=0x20858, order=0, oom_score_adj=0
[ 2176.000644] bash cpuset=/ mems_allowed=0
[...]
[ 2176.000798] active_anon:305425 inactive_anon:141206 isolated_anon:0
                active_file:5109 inactive_file:4666 isolated_file:0
                unevictable:4 dirty:2 writeback:0 unstable:0
                free:13187 slab_reclaimable:6552 slab_unreclaimable:11310
                mapped:21203 shmem:155079 pagetables:10921 bounce:0
                free_cma:0

So the anon LRU lists are intact even after java has exited so something
is clearly wrong the anon LRU list and it looks like a leak via elevated
page ref. counting.

It sounds like this is reproducible for you Gonzalo, could you invoke a
crash dump and save the vmcore so that the LRU can be investigated? We
would see the state after something went wrong but maybe there will be
some pattern to help us.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
