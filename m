Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFED6B0033
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 14:46:21 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id v96so188199165ioi.5
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 11:46:21 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k68si16838619pfb.181.2017.01.31.11.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 11:46:20 -0800 (PST)
Date: Tue, 31 Jan 2017 11:45:47 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [RFC 0/6]mm: add new LRU list for MADV_FREE pages
Message-ID: <20170131194546.GA70126@shli-mbp.local>
References: <cover.1485748619.git.shli@fb.com>
 <20170131185949.GA5037@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170131185949.GA5037@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net

On Tue, Jan 31, 2017 at 01:59:49PM -0500, Johannes Weiner wrote:
> Hi Shaohua,
> 
> On Sun, Jan 29, 2017 at 09:51:17PM -0800, Shaohua Li wrote:
> > We are trying to use MADV_FREE in jemalloc. Several issues are found. Without
> > solving the issues, jemalloc can't use the MADV_FREE feature.
> > - Doesn't support system without swap enabled. Because if swap is off, we can't
> >   or can't efficiently age anonymous pages. And since MADV_FREE pages are mixed
> >   with other anonymous pages, we can't reclaim MADV_FREE pages. In current
> >   implementation, MADV_FREE will fallback to MADV_DONTNEED without swap enabled.
> >   But in our environment, a lot of machines don't enable swap. This will prevent
> >   our setup using MADV_FREE.
> > - Increases memory pressure. page reclaim bias file pages reclaim against
> >   anonymous pages. This doesn't make sense for MADV_FREE pages, because those
> >   pages could be freed easily and refilled with very slight penality. Even page
> >   reclaim doesn't bias file pages, there is still an issue, because MADV_FREE
> >   pages and other anonymous pages are mixed together. To reclaim a MADV_FREE
> >   page, we probably must scan a lot of other anonymous pages, which is
> >   inefficient. In our test, we usually see oom with MADV_FREE enabled and nothing
> >   without it.
> 
> Fully agreed, the anon LRU is a bad place for these pages.
> 
> > For the first two issues, introducing a new LRU list for MADV_FREE pages could
> > solve the issues. We can directly reclaim MADV_FREE pages without writting them
> > out to swap, so the first issue could be fixed. If only MADV_FREE pages are in
> > the new list, page reclaim can easily reclaim such pages without interference
> > of file or anonymous pages. The memory pressure issue will disappear.
> 
> Do we actually need a new page flag and a special LRU for them? These
> pages are basically like clean cache pages at that point. What do you
> think about clearing their PG_swapbacked flag on MADV_FREE and moving
> them to the inactive file list? The way isolate+putback works should
> not even need much modification, something like clear_page_mlock().
> 
> When the reclaim scanner finds anon && dirty && !swapbacked, it can
> again set PG_swapbacked and goto keep_locked to move the page back
> into the anon LRU to get reclaimed according to swapping rules.

Interesting idea! Not sure though, the MADV_FREE pages are actually anonymous
pages, this will introduce confusion. On the other hand, if the MADV_FREE pages
are mixed with inactive file pages, page reclaim need to reclaim a lot of file
pages first before reclaim the MADV_FREE pages. This doesn't look good. The
point of a separate LRU is to avoid scan other anon/file pages.
 
> > For the third issue, we can add a separate RSS count for MADV_FREE pages. The
> > count will be increased in madvise syscall and decreased in page reclaim (eg,
> > unmap). One issue is activate_page(). A MADV_FREE page can be promoted to
> > active page there. But there isn't mm_struct context at that place. Iterating
> > vma there sounds too silly. The patchset don't fix this issue yet. Hopefully
> > somebody can share a hint how to fix this issue.
> 
> This problem also goes away if we use the file LRUs.

Can you elaborate this please? Maybe you mean charge them to MM_FILEPAGES? But
that doesn't solve the problem. 'statm' proc file will still report a big RSS.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
