Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19A806B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 11:37:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 14so493645828pgg.4
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 08:37:36 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id s5si19606109plj.103.2017.02.01.08.37.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 08:37:35 -0800 (PST)
Date: Wed, 1 Feb 2017 08:37:12 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [RFC 0/6]mm: add new LRU list for MADV_FREE pages
Message-ID: <20170201163711.GA56014@shli-mbp.local>
References: <cover.1485748619.git.shli@fb.com>
 <20170131185949.GA5037@cmpxchg.org>
 <20170131194546.GA70126@shli-mbp.local>
 <20170131213810.GA12952@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170131213810.GA12952@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net

On Tue, Jan 31, 2017 at 04:38:10PM -0500, Johannes Weiner wrote:
> On Tue, Jan 31, 2017 at 11:45:47AM -0800, Shaohua Li wrote:
> > On Tue, Jan 31, 2017 at 01:59:49PM -0500, Johannes Weiner wrote:
> > > Hi Shaohua,
> > > 
> > > On Sun, Jan 29, 2017 at 09:51:17PM -0800, Shaohua Li wrote:
> > > > We are trying to use MADV_FREE in jemalloc. Several issues are found. Without
> > > > solving the issues, jemalloc can't use the MADV_FREE feature.
> > > > - Doesn't support system without swap enabled. Because if swap is off, we can't
> > > >   or can't efficiently age anonymous pages. And since MADV_FREE pages are mixed
> > > >   with other anonymous pages, we can't reclaim MADV_FREE pages. In current
> > > >   implementation, MADV_FREE will fallback to MADV_DONTNEED without swap enabled.
> > > >   But in our environment, a lot of machines don't enable swap. This will prevent
> > > >   our setup using MADV_FREE.
> > > > - Increases memory pressure. page reclaim bias file pages reclaim against
> > > >   anonymous pages. This doesn't make sense for MADV_FREE pages, because those
> > > >   pages could be freed easily and refilled with very slight penality. Even page
> > > >   reclaim doesn't bias file pages, there is still an issue, because MADV_FREE
> > > >   pages and other anonymous pages are mixed together. To reclaim a MADV_FREE
> > > >   page, we probably must scan a lot of other anonymous pages, which is
> > > >   inefficient. In our test, we usually see oom with MADV_FREE enabled and nothing
> > > >   without it.
> > > 
> > > Fully agreed, the anon LRU is a bad place for these pages.
> > > 
> > > > For the first two issues, introducing a new LRU list for MADV_FREE pages could
> > > > solve the issues. We can directly reclaim MADV_FREE pages without writting them
> > > > out to swap, so the first issue could be fixed. If only MADV_FREE pages are in
> > > > the new list, page reclaim can easily reclaim such pages without interference
> > > > of file or anonymous pages. The memory pressure issue will disappear.
> > > 
> > > Do we actually need a new page flag and a special LRU for them? These
> > > pages are basically like clean cache pages at that point. What do you
> > > think about clearing their PG_swapbacked flag on MADV_FREE and moving
> > > them to the inactive file list? The way isolate+putback works should
> > > not even need much modification, something like clear_page_mlock().
> > > 
> > > When the reclaim scanner finds anon && dirty && !swapbacked, it can
> > > again set PG_swapbacked and goto keep_locked to move the page back
> > > into the anon LRU to get reclaimed according to swapping rules.
> > 
> > Interesting idea! Not sure though, the MADV_FREE pages are actually anonymous
> > pages, this will introduce confusion. On the other hand, if the MADV_FREE pages
> > are mixed with inactive file pages, page reclaim need to reclaim a lot of file
> > pages first before reclaim the MADV_FREE pages. This doesn't look good. The
> > point of a separate LRU is to avoid scan other anon/file pages.
> 
> The LRU code and the rest of VM already use independent page type
> distinctions. That's because shmem pages are !PageAnon - they have a
> page->mapping that points to a real address space, not an anon_vma -
> but they are swapbacked and thus go through the anon LRU. This would
> just do the reverse: put PageAnon pages on the file LRU when they
> don't contain valid data and are thus not swapbacked.
> 
> As far as mixing with inactive file pages goes, it'd be possible to
> link the MADV_FREE pages to the tail of the inactive list, rather than
> the head. That said, I'm not sure reclaiming use-once filesystem cache
> before MADV_FREE is such a bad policy. MADV_FREE retains the vmas for
> the sole purpose of reusing them in the (near) future. That is
> actually a stronger reuse signal than we have for use-once file pages.
> If somebody does continuous writes to a logfile or a one-off search
> through one or more files, we should actually reclaim that cache
> before we go after MADV_FREE pages that are temporarily invalidated.

Thanks, I'll try this idea.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
