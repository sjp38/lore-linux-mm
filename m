Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5420D6B038B
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 04:45:22 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id q39so23802679wrb.3
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 01:45:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si27361307wrb.207.2017.02.21.01.45.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Feb 2017 01:45:21 -0800 (PST)
Date: Tue, 21 Feb 2017 10:45:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2 7/7] mm: add a separate RSS for MADV_FREE pages
Message-ID: <20170221094518.GH15595@dhcp22.suse.cz>
References: <cover.1486163864.git.shli@fb.com>
 <123396e3b523e8716dfc6fc87a5cea0c124ff29d.1486163864.git.shli@fb.com>
 <20170210133504.GO10893@dhcp22.suse.cz>
 <20170210180101.GF86050@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210180101.GF86050@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri 10-02-17 10:01:02, Shaohua Li wrote:
> On Fri, Feb 10, 2017 at 02:35:05PM +0100, Michal Hocko wrote:
> > On Fri 03-02-17 15:33:23, Shaohua Li wrote:
> > > Add a separate RSS for MADV_FREE pages. The pages are charged into
> > > MM_ANONPAGES (because they are mapped anon pages) and also charged into
> > > the MM_LAZYFREEPAGES. /proc/pid/statm will have an extra field to
> > > display the RSS, which userspace can use to determine the RSS excluding
> > > MADV_FREE pages.
> > > 
> > > The basic idea is to increment the RSS in madvise and decrement in unmap
> > > or page reclaim. There is one limitation. If a page is shared by two
> > > processes, since madvise only has mm cotext of current process, it isn't
> > > convenient to charge the RSS for both processes. So we don't charge the
> > > RSS if the mapcount isn't 1. On the other hand, fork can make a
> > > MADV_FREE page shared by two processes. To make things consistent, we
> > > uncharge the RSS from the source mm in fork.
> > > 
> > > A new flag is added to indicate if a page is accounted into the RSS. We
> > > can't use SwapBacked flag to do the determination because we can't
> > > guarantee the page has SwapBacked flag cleared in madvise. We are
> > > reusing mappedtodisk flag which should not be set for Anon pages.
> > > 
> > > There are a couple of other places we need to uncharge the RSS,
> > > activate_page and mark_page_accessed. activate_page is used by swap,
> > > where MADV_FREE pages are already not in lazyfree state before going
> > > into swap. mark_page_accessed is mainly used for file pages, but there
> > > are several places it's used by anonymous pages. I fixed gup, but not
> > > some gpu drivers and kvm. If the drivers use MADV_FREE, we might have
> > > inprecise RSS accounting.
> > > 
> > > Please note, the accounting is never going to be precise. MADV_FREE page
> > > could be written by userspace without notification to the kernel. The
> > > page can't be reclaimed like other clean lazyfree pages. The page isn't
> > > real lazyfree page. But since kernel isn't aware of this, the page is
> > > still accounted as lazyfree, thus the accounting could be incorrect.
> > 
> > This is all quite complex and as you say unprecise already. From the
> > description it is not even clear why do we need it at all. Why is
> > /proc/<pid>/smaps insufficient? I am also not fun of a new page flag -
> > even though you managed to recycle an existing one which is a plus.
> 
> We have monitor app running in the system to check other apps' RSS and kill
> them if RSS is abnormal. Checking /proc/pid/smaps is too complicated and slow,
> don't think we can go that way.

Could you be more specific about why "slow" matters?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
