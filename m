Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF4A86B02C3
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:28:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p37so4372132wrc.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 04:28:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o20si2134103wrg.477.2017.08.29.04.28.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 04:28:26 -0700 (PDT)
Date: Tue, 29 Aug 2017 13:28:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: do not back off draining pcp free
 pages from kworker context
Message-ID: <20170829112823.GA12413@dhcp22.suse.cz>
References: <20170828093341.26341-1-mhocko@kernel.org>
 <20170828153359.f9b252f99647eebd339a3a89@linux-foundation.org>
 <6e138348-aa28-8660-d902-96efafe1dcb2@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6e138348-aa28-8660-d902-96efafe1dcb2@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 29-08-17 20:20:39, Tetsuo Handa wrote:
> On 2017/08/29 7:33, Andrew Morton wrote:
> > On Mon, 28 Aug 2017 11:33:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> >> drain_all_pages backs off when called from a kworker context since
> >> 0ccce3b924212 ("mm, page_alloc: drain per-cpu pages from workqueue
> >> context") because the original IPI based pcp draining has been replaced
> >> by a WQ based one and the check wanted to prevent from recursion and
> >> inter workers dependencies. This has made some sense at the time
> >> because the system WQ has been used and one worker holding the lock
> >> could be blocked while waiting for new workers to emerge which can be a
> >> problem under OOM conditions.
> >>
> >> Since then ce612879ddc7 ("mm: move pcp and lru-pcp draining into single
> >> wq") has moved draining to a dedicated (mm_percpu_wq) WQ with a rescuer
> >> so we shouldn't depend on any other WQ activity to make a forward
> >> progress so calling drain_all_pages from a worker context is safe as
> >> long as this doesn't happen from mm_percpu_wq itself which is not the
> >> case because all workers are required to _not_ depend on any MM locks.
> >>
> >> Why is this a problem in the first place? ACPI driven memory hot-remove
> >> (acpi_device_hotplug) is executed from the worker context. We end
> >> up calling __offline_pages to free all the pages and that requires
> >> both lru_add_drain_all_cpuslocked and drain_all_pages to do their job
> >> otherwise we can have dangling pages on pcp lists and fail the offline
> >> operation (__test_page_isolated_in_pageblock would see a page with 0
> >> ref. count but without PageBuddy set).
> >>
> >> Fix the issue by removing the worker check in drain_all_pages.
> >> lru_add_drain_all_cpuslocked doesn't have this restriction so it works
> >> as expected.
> >>
> >> Fixes: 0ccce3b924212 ("mm, page_alloc: drain per-cpu pages from workqueue context")
> >> Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > No cc:stable?
> > 
> 
> Michal, are you sure that this patch does not cause deadlock?
> 
> As shown in "[PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq." thread, currently work
> items on mm_percpu_wq seem to be blocked by other work items not on mm_percpu_wq.

But we have a rescuer so we should make a forward progress eventually.
Or am I missing something. Tejun, could you have a look please?/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
