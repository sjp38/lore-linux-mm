Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9ACBD6B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:56:50 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id s68so25734406qkh.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 07:56:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x64si7732307qhx.22.2016.01.29.07.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 07:56:49 -0800 (PST)
Date: Fri, 29 Jan 2016 16:56:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: why do we do ALLOC_WMARK_HIGH before going out_of_memory
Message-ID: <20160129155644.GK12228@redhat.com>
References: <20160128163802.GA15953@dhcp22.suse.cz>
 <20160128190204.GJ12228@redhat.com>
 <20160128201123.GB621@dhcp22.suse.cz>
 <20160128211240.GA4163@cmpxchg.org>
 <20160128215514.GF621@dhcp22.suse.cz>
 <20160128234018.GA5530@cmpxchg.org>
 <20160129143806.GC32174@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160129143806.GC32174@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 29, 2016 at 03:38:06PM +0100, Michal Hocko wrote:
> That would require the oom victim to release the memory and drop
> TIF_MEMDIE before we go out_of_memory again. And that might happen
> anytime whether we are holding oom_trylock or not because it doesn't
> synchronize the exit path. So we are basically talking about:
> 
> should_alloc_retry
> [1]
> get_page_from_freelist(ALLOC_WMARK_HIGH)
> [2]
> out_of_memory
> 
> and the race window for 1 is much smaller than 2 because [2] is quite

[1] is before should_alloc_retry is set. It covers the entire reclaim.

> costly operation. I wonder if this last moment request ever succeeds. I
> have run my usual oom flood tests and it hasn't shown up a single time.

For this check to make a difference, you need a lot of small programs
all hitting OOM at the same time. Perhaps the trylock on the oom_lock
tends to hide the race like you suggested earlier but it doesn't sound
accurate if we proceed to oom kill without checking the high wmark at all
before killing another task after a random reclaim failure.

Also note there's no CPU to save here, this is a very slow path,
anything that can increase accuracy and avoid OOM kill false
positives (at practical zero CPU cost like here) sounds worth it.

> That being said I do not care that much. I just find this confusing and
> basically pointless because the whole thing is racy by definition and we
> are trying to cover a smaller window. I would understand if we did such
> a last attempt right before we are going to kill a selected victim. This
> would cover much larger race window.

The high wmark itself is still an arbitrary value so yes, it isn't
perfect, but the whole OOM killing is an heuristic, so tiny race
window to me sounds better than huge race window.

Moving this check down inside out_of_memory to reduce the window even
further is quite a different proposition than removing the check.

Currently we're doing this check after holding the oom_lock, back in
2.6.x it was more more racy, now thanks to the oom_lock it's way more
reliable. If you want to increase reliability further I sure agree,
but removing the check would drop reliability instead so I don't see
how it could be preferable.

We can increase reliability further if we'd move this high wmark check
after select_bad_process() returned a task (and not -1UL) to be sure
all TIF_MEMDIE tasks already were flushed out, before checking the
high wmark. Just it would complicate the code and that's probably why
it wasn't done.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
