Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D8036B038A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 20:27:44 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id 205so31431305yws.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 17:27:44 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t2si6797341ywt.462.2017.02.21.17.27.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 17:27:43 -0800 (PST)
Date: Tue, 21 Feb 2017 17:27:13 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V2 7/7] mm: add a separate RSS for MADV_FREE pages
Message-ID: <20170222012712.GA97403@shli-mbp.local>
References: <cover.1486163864.git.shli@fb.com>
 <123396e3b523e8716dfc6fc87a5cea0c124ff29d.1486163864.git.shli@fb.com>
 <20170222004604.GA14056@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170222004604.GA14056@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Wed, Feb 22, 2017 at 09:46:05AM +0900, Minchan Kim wrote:
> Hi Shaohua,
> 
> On Fri, Feb 03, 2017 at 03:33:23PM -0800, Shaohua Li wrote:
> > Add a separate RSS for MADV_FREE pages. The pages are charged into
> > MM_ANONPAGES (because they are mapped anon pages) and also charged into
> > the MM_LAZYFREEPAGES. /proc/pid/statm will have an extra field to
> > display the RSS, which userspace can use to determine the RSS excluding
> > MADV_FREE pages.
> 
> I'm not sure statm is right place. With definition of statm and considering
> your usecase, it would be right place but when I look "stuats", it already
> shows RssAnon, RssFile and RssShmem so I thought we can add RssLazy to it.
> It would be more consistent if you don't have big overhead.
> 
> > 
> > The basic idea is to increment the RSS in madvise and decrement in unmap
> > or page reclaim. There is one limitation. If a page is shared by two
> > processes, since madvise only has mm cotext of current process, it isn't
> > convenient to charge the RSS for both processes. So we don't charge the
> > RSS if the mapcount isn't 1. On the other hand, fork can make a
> > MADV_FREE page shared by two processes. To make things consistent, we
> > uncharge the RSS from the source mm in fork.
> 
> I don't understand why we need new flag.
> 
> What's the problem like handling it normal anon|file|swapent|shmem?
> IOW, we can increase in madvise context and increase for child in copy_one_pte
> if the pte is still not dirty. And then decrease it in zap_pte_range/
> try_to_unmap_one if it finds it's dirty or discardable.
> 
> Although it's shared by fork, VM can discard it if processes doesn't
> make it dirty.

The thing is we could madvise the same page twice. madvise context can't
guarantee we move the page to inactive file list, so we could wrongly increase
the count.

> > 
> > A new flag is added to indicate if a page is accounted into the RSS. We
> > can't use SwapBacked flag to do the determination because we can't
> > guarantee the page has SwapBacked flag cleared in madvise. We are
> > reusing mappedtodisk flag which should not be set for Anon pages.
> > 
> > There are a couple of other places we need to uncharge the RSS,
> > activate_page and mark_page_accessed. activate_page is used by swap,
> > where MADV_FREE pages are already not in lazyfree state before going
> > into swap. mark_page_accessed is mainly used for file pages, but there
> > are several places it's used by anonymous pages. I fixed gup, but not
> > some gpu drivers and kvm. If the drivers use MADV_FREE, we might have
> > inprecise RSS accounting.
> > 
> > Please note, the accounting is never going to be precise. MADV_FREE page
> > could be written by userspace without notification to the kernel. The
> > page can't be reclaimed like other clean lazyfree pages. The page isn't
> > real lazyfree page. But since kernel isn't aware of this, the page is
> > still accounted as lazyfree, thus the accounting could be incorrect.
> 
> Right. Lazyfree is not inaccurate without CoW where it's point to decrease
> lazyfree rss count when the store happens so we might be tempted to make
> it to Cow at the cost of performance degradation but still it's not accurate
> without making mark_page_accessed be aware of each mm context which is
> hard part. So, I agree this stat is useful but don't want to make it
> complicate.

Yes, it only could be accurate with extra pagefault cost, but apparently nobody
wants to pay for it.

I talked to jemalloc guys here. They have concerns about the accounting since
it's not accurate. I'll drop the accounting patches in next post. The only
interface which can export accurate info is /proc/pid/smaps, we probably go
that.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
