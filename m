Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8CCA46B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 02:36:40 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so28280990pfb.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:36:40 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id 82si10666861pfq.218.2016.02.24.23.36.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 23:36:39 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id fy10so27691228pac.1
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 23:36:39 -0800 (PST)
Date: Wed, 24 Feb 2016 23:36:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC v5 0/3] mm: make swapin readahead to gain more thp
 performance
In-Reply-To: <20150914144106.ee205c3ae3f4ec0e5202c9fe@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1602242301040.6947@eggly.anvils>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com> <20150914144106.ee205c3ae3f4ec0e5202c9fe@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, 14 Sep 2015, Andrew Morton wrote:
> On Mon, 14 Sep 2015 22:31:42 +0300 Ebru Akagunduz <ebru.akagunduz@gmail.com> wrote:
> 
> > This patch series makes swapin readahead up to a
> > certain number to gain more thp performance and adds
> > tracepoint for khugepaged_scan_pmd, collapse_huge_page,
> > __collapse_huge_page_isolate.
> 
> I'll merge this series for testing.  Hopefully Andrea and/or Hugh will
> find time for a quality think about the issue before 4.3 comes around.
> 
> It would be much better if we didn't have that sysfs knob - make the
> control automatic in some fashion.
> 
> If we can't think of a way of doing that then at least let's document
> max_ptes_swap very carefully.  Explain to our users what it does, why
> they should care about it, how they should set about determining (ie:
> measuring) its effect upon their workloads.

Ebru, I don't know whether you realize, but your THP swapin work has
been languishing in mmotm for five months now, without getting any
nearer to Linus's tree.

That's partly my fault - sorry - for not responding to Andrew's nudge
above.  But I think you also got caught up in conference, and in the
end did not get around to answering outstanding issues: please take a
look at your mailbox from last September, to see what more is needed.

Here's what mmotm's series file says...

#mm-add-tracepoint-for-scanning-pages.patch+2: Andrea/Hugh review?. 2 Fengguang warnings, one "kernel test robot" oops
#mm-make-optimistic-check-for-swapin-readahead.patch: TBU (docs)
mm-make-optimistic-check-for-swapin-readahead.patch
mm-make-optimistic-check-for-swapin-readahead-fix-2.patch
#mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch: Hugh/Kirill want collapse_huge_page() rework
mm-make-swapin-readahead-to-improve-thp-collapse-rate.patch
mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix.patch
mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-2.patch
#mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch: Ebru to test?
mm-make-swapin-readahead-to-improve-thp-collapse-rate-fix-3.patch

...but I think some of that is stale.  There were a few little bugs
when it first went into mmotm, which Kirill very swiftly fixed up,
and I don't think it has given anybody any trouble since then.

But do I want to see this work go in?  Yes and no.  The problem it
fixes (that although we give out a THP to someone who faults a single
page of it, after swapout the THP cannot be recovered until they have
faulted in every page of it) is real and embarrassing; the code is good;
and I don't mind the max_ptes_swap tunable that concerns Andrew above;
but Kirill and Vlastimil made important points that still trouble me.

I can't locate Kirill's mail right now, perhaps I'm misremembering:
but wasn't he concerned by your __collapse_huge_page_swapin() (likely
to be allocating many small pages) being called under down_write of
mmap_sem?  That's usually something we soon regret, and even down_read
of mmap_sem across many memory allocations would be unfortunate
(khugepaged used to allocate its THP that way, but we have
Vlastimil to thank for stopping that in his 8b1645685acf).

And didn't Vlastimil (9/4/15) make some other unanswered
observations about the call to __collapse_huge_page_swapin():

> Hmm it seems rather wasteful to call this when no swap entries were detected.
> Also it seems pointless to try continue collapsing when we have just only issued
> async swap-in? What are the chances they would finish in time?
> 
> I'm less sure about the relation vs khugepaged_alloc_page(). At this point, we
> have already succeeded the hugepage allocation. It makes sense not to swap-in if
> we can't allocate a hugepage. It makes also sense not to allocate a hugepage if
> we will just issue async swap-ins and then free the hugepage back. Swap-in means
> disk I/O that's best avoided if not useful. But the reclaim for hugepage
> allocation might also involve disk I/O. At worst, it could be creating new swap
> pte's in the very pmd we are scanning... Thoughts?

Doesn't this imply that __collapse_huge_page_swapin() will initiate all
the necessary swapins for a THP, then (given the FAULT_FLAG_ALLOW_RETRY)
not wait for them to complete, so khugepaged will give up on that extent
and move on to another; then after another full circuit of all the mms
it needs to examine, it will arrive back at this extent and build a THP
from the swapins it arranged last time.

Which may work well when a system transitions from busy+swappingout
to idle+swappingin, but isn't that rather a special case?  It feels
(meaning, I've not measured at all) as if the inbetween busyish case
will waste a lot of I/O and memory on swapins that have to be discarded
again before khugepaged has made its sedate way back to slotting them in.

So I wonder how useful this is in its present form.  The problem being,
not with your code as such, but the whole nature of khugepaged.  When
I had to solve a similar problem with recovering huge tmpfs pages (not
yet posted), I did briefly consider whether to hook in to use khugepaged;
but rejected that, and have never regretted using a workqueue item for
the extent instead.  Did Vlastimil (argh, him again!) propose something
similar to replace khugepaged?  Or should khugepaged fire off workqueue
items for THP extents needing swapin?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
