Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 616476B025F
	for <linux-mm@kvack.org>; Mon, 28 Aug 2017 18:34:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i76so2088739wme.2
        for <linux-mm@kvack.org>; Mon, 28 Aug 2017 15:34:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d23si1163955wrd.149.2017.08.28.15.34.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Aug 2017 15:34:02 -0700 (PDT)
Date: Mon, 28 Aug 2017 15:33:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, memory_hotplug: do not back off draining pcp free
 pages from kworker context
Message-Id: <20170828153359.f9b252f99647eebd339a3a89@linux-foundation.org>
In-Reply-To: <20170828093341.26341-1-mhocko@kernel.org>
References: <20170828093341.26341-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 28 Aug 2017 11:33:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> drain_all_pages backs off when called from a kworker context since
> 0ccce3b924212 ("mm, page_alloc: drain per-cpu pages from workqueue
> context") because the original IPI based pcp draining has been replaced
> by a WQ based one and the check wanted to prevent from recursion and
> inter workers dependencies. This has made some sense at the time
> because the system WQ has been used and one worker holding the lock
> could be blocked while waiting for new workers to emerge which can be a
> problem under OOM conditions.
> 
> Since then ce612879ddc7 ("mm: move pcp and lru-pcp draining into single
> wq") has moved draining to a dedicated (mm_percpu_wq) WQ with a rescuer
> so we shouldn't depend on any other WQ activity to make a forward
> progress so calling drain_all_pages from a worker context is safe as
> long as this doesn't happen from mm_percpu_wq itself which is not the
> case because all workers are required to _not_ depend on any MM locks.
> 
> Why is this a problem in the first place? ACPI driven memory hot-remove
> (acpi_device_hotplug) is executed from the worker context. We end
> up calling __offline_pages to free all the pages and that requires
> both lru_add_drain_all_cpuslocked and drain_all_pages to do their job
> otherwise we can have dangling pages on pcp lists and fail the offline
> operation (__test_page_isolated_in_pageblock would see a page with 0
> ref. count but without PageBuddy set).
> 
> Fix the issue by removing the worker check in drain_all_pages.
> lru_add_drain_all_cpuslocked doesn't have this restriction so it works
> as expected.
> 
> Fixes: 0ccce3b924212 ("mm, page_alloc: drain per-cpu pages from workqueue context")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

No cc:stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
