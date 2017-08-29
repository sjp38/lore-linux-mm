Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 424E66B02B4
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:20:48 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a2so5454675pfj.2
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 04:20:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id a128si2130977pgc.772.2017.08.29.04.20.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 04:20:47 -0700 (PDT)
Subject: Re: [PATCH] mm, memory_hotplug: do not back off draining pcp free
 pages from kworker context
References: <20170828093341.26341-1-mhocko@kernel.org>
 <20170828153359.f9b252f99647eebd339a3a89@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <6e138348-aa28-8660-d902-96efafe1dcb2@I-love.SAKURA.ne.jp>
Date: Tue, 29 Aug 2017 20:20:39 +0900
MIME-Version: 1.0
In-Reply-To: <20170828153359.f9b252f99647eebd339a3a89@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2017/08/29 7:33, Andrew Morton wrote:
> On Mon, 28 Aug 2017 11:33:41 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
>> drain_all_pages backs off when called from a kworker context since
>> 0ccce3b924212 ("mm, page_alloc: drain per-cpu pages from workqueue
>> context") because the original IPI based pcp draining has been replaced
>> by a WQ based one and the check wanted to prevent from recursion and
>> inter workers dependencies. This has made some sense at the time
>> because the system WQ has been used and one worker holding the lock
>> could be blocked while waiting for new workers to emerge which can be a
>> problem under OOM conditions.
>>
>> Since then ce612879ddc7 ("mm: move pcp and lru-pcp draining into single
>> wq") has moved draining to a dedicated (mm_percpu_wq) WQ with a rescuer
>> so we shouldn't depend on any other WQ activity to make a forward
>> progress so calling drain_all_pages from a worker context is safe as
>> long as this doesn't happen from mm_percpu_wq itself which is not the
>> case because all workers are required to _not_ depend on any MM locks.
>>
>> Why is this a problem in the first place? ACPI driven memory hot-remove
>> (acpi_device_hotplug) is executed from the worker context. We end
>> up calling __offline_pages to free all the pages and that requires
>> both lru_add_drain_all_cpuslocked and drain_all_pages to do their job
>> otherwise we can have dangling pages on pcp lists and fail the offline
>> operation (__test_page_isolated_in_pageblock would see a page with 0
>> ref. count but without PageBuddy set).
>>
>> Fix the issue by removing the worker check in drain_all_pages.
>> lru_add_drain_all_cpuslocked doesn't have this restriction so it works
>> as expected.
>>
>> Fixes: 0ccce3b924212 ("mm, page_alloc: drain per-cpu pages from workqueue context")
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> No cc:stable?
> 

Michal, are you sure that this patch does not cause deadlock?

As shown in "[PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq." thread, currently work
items on mm_percpu_wq seem to be blocked by other work items not on mm_percpu_wq.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
