Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id A8F0982F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 13:22:14 -0400 (EDT)
Received: by iody8 with SMTP id y8so86499783iod.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 10:22:14 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id t100si8495316ioe.171.2015.10.30.10.22.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 10:22:14 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so83174633pac.3
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 10:22:13 -0700 (PDT)
Date: Fri, 30 Oct 2015 10:22:12 -0700
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH 5/8] mm: move lazily freed pages to inactive list
Message-ID: <20151030172212.GB44946@kernel.org>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-6-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1446188504-28023-6-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, "Wang, Yalin" <Yalin.Wang@sonymobile.com>

On Fri, Oct 30, 2015 at 04:01:41PM +0900, Minchan Kim wrote:
> MADV_FREE is a hint that it's okay to discard pages if there is memory
> pressure and we use reclaimers(ie, kswapd and direct reclaim) to free them
> so there is no value keeping them in the active anonymous LRU so this
> patch moves them to inactive LRU list's head.
> 
> This means that MADV_FREE-ed pages which were living on the inactive list
> are reclaimed first because they are more likely to be cold rather than
> recently active pages.
> 
> An arguable issue for the approach would be whether we should put the page
> to the head or tail of the inactive list.  I chose head because the kernel
> cannot make sure it's really cold or warm for every MADV_FREE usecase but
> at least we know it's not *hot*, so landing of inactive head would be a
> comprimise for various usecases.
> 
> This fixes suboptimal behavior of MADV_FREE when pages living on the
> active list will sit there for a long time even under memory pressure
> while the inactive list is reclaimed heavily.  This basically breaks the
> whole purpose of using MADV_FREE to help the system to free memory which
> is might not be used.

My main concern is the policy how we should treat the FREE pages. Moving it to
inactive lru is definitionly a good start, I'm wondering if it's enough. The
MADV_FREE increases memory pressure and cause unnecessary reclaim because of
the lazy memory free. While MADV_FREE is intended to be a better replacement of
MADV_DONTNEED, MADV_DONTNEED doesn't have the memory pressure issue as it free
memory immediately. So I hope the MADV_FREE doesn't have impact on memory
pressure too. I'm thinking of adding an extra lru list and wartermark for this
to make sure FREE pages can be freed before system wide page reclaim. As you
said, this is arguable, but I hope we can discuss about this issue more.

Or do you want to push this first and address the policy issue later?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
