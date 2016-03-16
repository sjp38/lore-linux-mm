Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 74A186B0005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2016 16:14:19 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so205960442wmp.1
        for <linux-mm@kvack.org>; Wed, 16 Mar 2016 13:14:19 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g8si4597646wmf.40.2016.03.16.13.14.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Mar 2016 13:14:18 -0700 (PDT)
Date: Wed, 16 Mar 2016 13:13:29 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: memcontrol: reclaim and OOM kill when shrinking
 memory.max below usage
Message-ID: <20160316201329.GA15498@cmpxchg.org>
References: <1457643015-8828-2-git-send-email-hannes@cmpxchg.org>
 <20160311081825.GC27701@dhcp22.suse.cz>
 <20160311091931.GK1946@esperanza>
 <20160316051848.GA11006@cmpxchg.org>
 <20160316151509.GC18142@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160316151509.GC18142@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Mar 16, 2016 at 06:15:09PM +0300, Vladimir Davydov wrote:
> On Tue, Mar 15, 2016 at 10:18:48PM -0700, Johannes Weiner wrote:
> > On Fri, Mar 11, 2016 at 12:19:31PM +0300, Vladimir Davydov wrote:
> ...
> > > Come to think of it, shouldn't we restore the old limit and return EBUSY
> > > if we failed to reclaim enough memory?
> > 
> > I suspect it's very rare that it would fail. But even in that case
> > it's probably better to at least not allow new charges past what the
> > user requested, even if we can't push the level back far enough.
> 
> It's of course good to set the limit before trying to reclaim memory,
> but isn't it strange that even if the cgroup's memory can't be reclaimed
> to meet the new limit (tmpfs files or tasks protected from oom), the
> write will still succeed? It's a rare use case, but still.

It's not optimal, but there is nothing we can do about it, is there? I
don't want to go back to the racy semantics that allow the application
to balloon up again after the limit restriction fails.

> I've one more concern regarding this patch. It's about calling OOM while
> reclaiming cgroup memory. AFAIU OOM killer can be quite disruptive for a
> workload, so is it really good to call it when normal reclaim fails?
> 
> W/o OOM killer you can optimistically try to adjust memory.max and if it
> fails you can manually kill some processes in the container or restart
> it or cancel the limit update. With your patch adjusting memory.max
> never fails, but OOM might kill vital processes rendering the whole
> container useless. Wouldn't it be better to let the user decide if
> processes should be killed or not rather than calling OOM forcefully?

Those are the memory.max semantics, though. Why should there be a
difference between the container growing beyond the limit and the
limit cutting into the container?

If you don't want OOM kills, set memory.high instead. This way you get
the memory pressure *and* the chance to do your own killing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
