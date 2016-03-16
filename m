Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 66AA66B0264
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 01:42:06 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l68so173785865wml.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 22:42:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id oy10si1976826wjb.173.2016.03.15.22.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 22:42:05 -0700 (PDT)
Date: Tue, 15 Mar 2016 22:41:57 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: reclaim when shrinking memory.high below
 usage
Message-ID: <20160316054157.GB11006@cmpxchg.org>
References: <1457643015-8828-1-git-send-email-hannes@cmpxchg.org>
 <20160311083440.GI1946@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160311083440.GI1946@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Mar 11, 2016 at 11:34:40AM +0300, Vladimir Davydov wrote:
> On Thu, Mar 10, 2016 at 03:50:13PM -0500, Johannes Weiner wrote:
> > When setting memory.high below usage, nothing happens until the next
> > charge comes along, and then it will only reclaim its own charge and
> > not the now potentially huge excess of the new memory.high. This can
> > cause groups to stay in excess of their memory.high indefinitely.
> > 
> > To fix that, when shrinking memory.high, kick off a reclaim cycle that
> > goes after the delta.
> 
> I agree that we should reclaim the high excess, but I don't think it's a
> good idea to do it synchronously. Currently, memory.low and memory.high
> knobs can be easily used by a single-threaded load manager implemented
> in userspace, because it doesn't need to care about potential stalls
> caused by writes to these files. After this change it might happen that
> a write to memory.high would take long, seconds perhaps, so in order to
> react quickly to changes in other cgroups, a load manager would have to
> spawn a thread per each write to memory.high, which would complicate its
> implementation significantly.

While I do expect memory.high to be adjusted every once in a while, I
can't see anybody doing it by a significant fraction of the cgroup
every couple of seconds - or tighter than the workingset; and dropping
use-once cache is cheap. What kind of usecase would that be?

But even if we're wrong about it and this becomes a scalability issue,
the knob - even when reclaiming synchroneously - makes no guarantees
about the target being met once the write finishes. It's a best effort
mechanism. What would break if we made it async later on?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
