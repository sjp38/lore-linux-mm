Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2AA6B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:23:56 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n5so110872817pfn.2
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 01:23:56 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0110.outbound.protection.outlook.com. [104.47.0.110])
        by mx.google.com with ESMTPS id l9si491186pfb.158.2016.03.17.01.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 17 Mar 2016 01:23:55 -0700 (PDT)
Date: Thu, 17 Mar 2016 11:23:45 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: reclaim and OOM kill when shrinking
 memory.max below usage
Message-ID: <20160317082345.GF18142@esperanza>
References: <1457643015-8828-2-git-send-email-hannes@cmpxchg.org>
 <20160311081825.GC27701@dhcp22.suse.cz>
 <20160311091931.GK1946@esperanza>
 <20160316051848.GA11006@cmpxchg.org>
 <20160316151509.GC18142@esperanza>
 <20160316201329.GA15498@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160316201329.GA15498@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Mar 16, 2016 at 01:13:29PM -0700, Johannes Weiner wrote:
> On Wed, Mar 16, 2016 at 06:15:09PM +0300, Vladimir Davydov wrote:
> > On Tue, Mar 15, 2016 at 10:18:48PM -0700, Johannes Weiner wrote:
> > > On Fri, Mar 11, 2016 at 12:19:31PM +0300, Vladimir Davydov wrote:
> > ...
> > > > Come to think of it, shouldn't we restore the old limit and return EBUSY
> > > > if we failed to reclaim enough memory?
> > > 
> > > I suspect it's very rare that it would fail. But even in that case
> > > it's probably better to at least not allow new charges past what the
> > > user requested, even if we can't push the level back far enough.
> > 
> > It's of course good to set the limit before trying to reclaim memory,
> > but isn't it strange that even if the cgroup's memory can't be reclaimed
> > to meet the new limit (tmpfs files or tasks protected from oom), the
> > write will still succeed? It's a rare use case, but still.
> 
> It's not optimal, but there is nothing we can do about it, is there? I
> don't want to go back to the racy semantics that allow the application
> to balloon up again after the limit restriction fails.
> 
> > I've one more concern regarding this patch. It's about calling OOM while
> > reclaiming cgroup memory. AFAIU OOM killer can be quite disruptive for a
> > workload, so is it really good to call it when normal reclaim fails?
> > 
> > W/o OOM killer you can optimistically try to adjust memory.max and if it
> > fails you can manually kill some processes in the container or restart
> > it or cancel the limit update. With your patch adjusting memory.max
> > never fails, but OOM might kill vital processes rendering the whole
> > container useless. Wouldn't it be better to let the user decide if
> > processes should be killed or not rather than calling OOM forcefully?
> 
> Those are the memory.max semantics, though. Why should there be a
> difference between the container growing beyond the limit and the
> limit cutting into the container?
> 
> If you don't want OOM kills, set memory.high instead. This way you get
> the memory pressure *and* the chance to do your own killing.

Fair enough.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
