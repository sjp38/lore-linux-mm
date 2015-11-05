Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id BC5D082F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 20:11:22 -0500 (EST)
Received: by padhx2 with SMTP id hx2so61209220pad.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 17:11:22 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id wf4si5924965pac.32.2015.11.04.17.11.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 17:11:22 -0800 (PST)
Date: Thu, 5 Nov 2015 10:11:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 5/8] mm: move lazily freed pages to inactive list
Message-ID: <20151105011125.GG7357@bbox>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-6-git-send-email-minchan@kernel.org>
 <20151030172212.GB44946@kernel.org>
 <20151103005223.GD17906@bbox>
 <20151104175342.GA98327@kernel.org>
 <20151104182047.GA116691@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20151104182047.GA116691@kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

On Wed, Nov 04, 2015 at 10:20:47AM -0800, Shaohua Li wrote:
> On Wed, Nov 04, 2015 at 09:53:42AM -0800, Shaohua Li wrote:
> > On Tue, Nov 03, 2015 at 09:52:23AM +0900, Minchan Kim wrote:
> > > On Fri, Oct 30, 2015 at 10:22:12AM -0700, Shaohua Li wrote:
> > > > On Fri, Oct 30, 2015 at 04:01:41PM +0900, Minchan Kim wrote:
> > > > > MADV_FREE is a hint that it's okay to discard pages if there is memory
> > > > > pressure and we use reclaimers(ie, kswapd and direct reclaim) to free them
> > > > > so there is no value keeping them in the active anonymous LRU so this
> > > > > patch moves them to inactive LRU list's head.
> > > > > 
> > > > > This means that MADV_FREE-ed pages which were living on the inactive list
> > > > > are reclaimed first because they are more likely to be cold rather than
> > > > > recently active pages.
> > > > > 
> > > > > An arguable issue for the approach would be whether we should put the page
> > > > > to the head or tail of the inactive list.  I chose head because the kernel
> > > > > cannot make sure it's really cold or warm for every MADV_FREE usecase but
> > > > > at least we know it's not *hot*, so landing of inactive head would be a
> > > > > comprimise for various usecases.
> > > > > 
> > > > > This fixes suboptimal behavior of MADV_FREE when pages living on the
> > > > > active list will sit there for a long time even under memory pressure
> > > > > while the inactive list is reclaimed heavily.  This basically breaks the
> > > > > whole purpose of using MADV_FREE to help the system to free memory which
> > > > > is might not be used.
> > > > 
> > > > My main concern is the policy how we should treat the FREE pages. Moving it to
> > > > inactive lru is definitionly a good start, I'm wondering if it's enough. The
> > > > MADV_FREE increases memory pressure and cause unnecessary reclaim because of
> > > > the lazy memory free. While MADV_FREE is intended to be a better replacement of
> > > > MADV_DONTNEED, MADV_DONTNEED doesn't have the memory pressure issue as it free
> > > > memory immediately. So I hope the MADV_FREE doesn't have impact on memory
> > > > pressure too. I'm thinking of adding an extra lru list and wartermark for this
> > > > to make sure FREE pages can be freed before system wide page reclaim. As you
> > > > said, this is arguable, but I hope we can discuss about this issue more.
> > > 
> > > Yes, it's arguble. ;-)
> > > 
> > > It seems the divergence comes from MADV_FREE is *replacement* of MADV_DONTNEED.
> > > But I don't think so. If we could discard MADV_FREEed page *anytime*, I agree
> > > but it's not true because the page would be dirty state when VM want to reclaim. 
> > 
> > There certainly are other usage cases, but even your patch log mainly describes
> > the jemalloc usage case, which uses MADV_DONTNEED.
> > 
> > > I'm also against with your's suggestion which let's discard FREEed page before
> > > system wide page reclaim because system would have lots of clean cold page
> > > caches or anonymous pages. In such case, reclaiming of them would be better.
> > > Yeb, it's really workload-dependent so we might need some heuristic which is
> > > normally what we want to avoid.
> > > 
> > > Having said that, I agree with you we could do better than the deactivation
> > > and frankly speaking, I'm thinking of another LRU list(e.g. tentatively named
> > > "ezreclaim LRU list"). What I have in mind is to age (anon|file|ez)
> > > fairly. IOW, I want to percolate ez-LRU list reclaiming into get_scan_count.
> > > When the MADV_FREE is called, we could move hinted pages from anon-LRU to
> > > ez-LRU and then If VM find to not be able to discard a page in ez-LRU,
> > > it could promote it to acive-anon-LRU which would be very natural aging
> > > concept because it mean someone touches the page recenlty.
> > > 
> > > With that, I don't want to bias one side and don't want to add some knob for
> > > tuning the heuristic but let's rely on common fair aging scheme of VM.
> > > 
> > > Another bonus with new LRU list is we could support MADV_FREE on swapless
> > > system.
> > > 
> > > > 
> > > > Or do you want to push this first and address the policy issue later?
> > > 
> > > I believe adding new LRU list would be controversial(ie, not trivial)
> > > for maintainer POV even though code wouldn't be complicated.
> > > So, I want to see problems in *real practice*, not any theoritical
> > > test program before diving into that.
> > > To see such voice of request, we should release the syscall.
> > > So, I want to push this first.
> > 
> > The memory pressure issue isn't just in artificial test. In jemalloc, there is
> > a knob (lg_dirty_mult) to control the rate memory should be purged (using
> > MADV_DONTNEED). We already had several reports in our production environment
> > changing the knob can cause extra memory usage (and swap and so on). If
> > jemalloc uses MADV_FREE, jemalloc will not purge any memory, which is equivent
> > to disable current MADV_DONTNEED (eg, lg_dirty_mult = -1). I'm sure this will
> > cause the similar issue, eg (extram memory usage, swap). That said I don't
> > object to push this first, but the memory pressue issue can happen in real
> > production, I hope it's not ignored.
> 
> I think the question is if application uses MADV_DONTNEED originally, how much
> better if we replace it to MADV_FREE compared to just delete the MADV_DONTNEED,
> considering anonymous memory is hard to be reclaimed currently.

So, the question from my side is application will use MADV_FREE
as replacement of MADV_DONTNEED without any tune or modification?
At least, I'd like to know jemalloc if they have a plan.

> 
> Thanks,
> Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
