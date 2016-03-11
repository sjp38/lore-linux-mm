Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 30D326B0254
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:34:54 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id tt10so90369148pab.3
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 00:34:54 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o63si12337521pfi.141.2016.03.11.00.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 00:34:53 -0800 (PST)
Date: Fri, 11 Mar 2016 11:34:40 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below
 usage
Message-ID: <20160311083440.GI1946@esperanza>
References: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Mar 10, 2016 at 03:50:13PM -0500, Johannes Weiner wrote:
> When setting memory.high below usage, nothing happens until the next
> charge comes along, and then it will only reclaim its own charge and
> not the now potentially huge excess of the new memory.high. This can
> cause groups to stay in excess of their memory.high indefinitely.
> 
> To fix that, when shrinking memory.high, kick off a reclaim cycle that
> goes after the delta.

I agree that we should reclaim the high excess, but I don't think it's a
good idea to do it synchronously. Currently, memory.low and memory.high
knobs can be easily used by a single-threaded load manager implemented
in userspace, because it doesn't need to care about potential stalls
caused by writes to these files. After this change it might happen that
a write to memory.high would take long, seconds perhaps, so in order to
react quickly to changes in other cgroups, a load manager would have to
spawn a thread per each write to memory.high, which would complicate its
implementation significantly.

Since, in contrast to memory.max, memory.high definition allows cgroup
to breach it, I believe it would be better if we spawned an asynchronous
reclaim work from the kernel on write to memory.high instead of doing
this synchronously. I guess we could reuse mem_cgroup->high_work for
that.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
