Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 425A26B0031
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 00:00:46 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so2044860pdj.31
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 21:00:45 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id uj8si4264849pac.32.2013.12.19.21.00.43
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 21:00:44 -0800 (PST)
Date: Fri, 20 Dec 2013 14:00:49 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 13/14] mm, hugetlb: retry if failed to allocate and
 there is concurrent user
Message-ID: <20131220050049.GB1370@lge.com>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1387349640-8071-14-git-send-email-iamjoonsoo.kim@lge.com>
 <20131219170202.0df2d82a2adefa3ab616bdaa@linux-foundation.org>
 <20131220015810.GA1084@lge.com>
 <20131219181520.8a3bfb26.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131219181520.8a3bfb26.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Thu, Dec 19, 2013 at 06:15:20PM -0800, Andrew Morton wrote:
> On Fri, 20 Dec 2013 10:58:10 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > On Thu, Dec 19, 2013 at 05:02:02PM -0800, Andrew Morton wrote:
> > > On Wed, 18 Dec 2013 15:53:59 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > 
> > > > If parallel fault occur, we can fail to allocate a hugepage,
> > > > because many threads dequeue a hugepage to handle a fault of same address.
> > > > This makes reserved pool shortage just for a little while and this cause
> > > > faulting thread who can get hugepages to get a SIGBUS signal.
> > > > 
> > > 
> > > So if I'm understanding this correctly...  if N threads all generate a
> > > fault against the same address, they will all dive in and allocate a
> > > hugepage, will then do an enormous memcpy into that page and will then
> > > attempt to instantiate the page in pagetables.  All threads except one
> > > will lose the race and will free the page again!  This sounds terribly
> > > inefficient; it would be useful to write a microbenchmark which
> > > triggers this scenario so we can explore the impact.
> > 
> > Yes, you understand correctly, I think.
> > 
> > I have an idea to prevent this overhead. It is that marking page when it
> > is zeroed and unmarking when it is mapped to page table. If page mapping
> > is failed due to current thread, the zeroed page will keep the marker and
> > later we can determine if it is zeroed or not.
> 
> Well OK, but the other threads will need to test that in-progress flag
> and then do <something>.  Where <something> will involve some form of
> open-coded sleep/wakeup thing.  To avoid all that wheel-reinventing we
> can avoid using an internal flag and use an external flag instead. 
> There's one in struct mutex!

My idea consider only hugetlb_no_page() and doesn't need a sleep.
It just set <some> page flag after zeroing and if some thread takes
the page with this flag when faulting, simply use it without zeroing.

> 
> I doubt if the additional complexity of the external flag is worth it,
> but convincing performance testing results would sway me ;) Please have
> a think about it all.
> 
> > If you want to include this functionality in this series, I can do it ;)
> > Please let me know your decision.
> > 
> > > I'm wondering if a better solution to all of this would be to make
> > > hugetlb_instantiation_mutex an array of, say, 1024 mutexes and index it
> > > with a hash of the faulting address.  That will 99.9% solve the
> > > performance issue which you believe exists without introducing this new
> > > performance issue?
> > 
> > Yes, that approach would solve the performance issue.
> > IIRC, you already suggested this idea roughly 6 months ago and it is
> > implemented by Davidlohr. I remembered that there is a race issue on
> > COW case with this approach. See following link for more information.
> > https://lkml.org/lkml/2013/8/7/142
> 
> That seems to be unrelated to hugetlb_instantiation_mutex?

Yes, it is related to hugetlb_instantiation_mutex. In the link, I mentioned
about race condition of table mutex patches which is for replacing
hugetlb_instantiation_mutex, although conversation isn't easy to follow-up.

> 
> > And we need 1-3 patches to prevent other theorectical race issue
> > regardless any approaches.
> 
> Yes, I'll be going through patches 1-12 very soon, thanks.

Okay. Thanks :)

> 
> 
> And to reiterate: I'm very uncomfortable mucking around with
> performance patches when we have run no tests to measure their
> magnitude, or even whether they are beneficial at all!

Okay. I will keep in mind it. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
