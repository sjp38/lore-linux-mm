Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0F66B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 13:10:01 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id b14so144579875wmb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:10:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t207si5826068wmt.84.2016.01.26.10.09.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 10:10:00 -0800 (PST)
Date: Tue, 26 Jan 2016 13:09:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] proposals for topics
Message-ID: <20160126180913.GA2428@cmpxchg.org>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org>
 <56A7A7E8.3060801@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A7A7E8.3060801@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Jan 26, 2016 at 06:07:52PM +0100, Vlastimil Babka wrote:
> On 01/25/2016 07:45 PM, Johannes Weiner wrote:
> >>>- One of the long lasting issue related to the OOM handling is when to
> >>>   actually declare OOM. There are workloads which might be trashing on
> >>>   few last remaining pagecache pages or on the swap which makes the
> >>>   system completely unusable for considerable amount of time yet the
> >>>   OOM killer is not invoked. Can we finally do something about that?
> >I'm working on this, but it's not an easy situation to detect.
> >
> >We can't decide based on amount of page cache, as you could have very
> >little of it and still be fine. Most of it could still be used-once.
> >
> >We can't decide based on number or rate of (re)faults, because this
> >spikes during startup and workingset changes, or can be even sustained
> >when working with a data set that you'd never expect to fit into
> >memory in the first place, while still making acceptable progress.
> 
> I would hope that workingset should help distinguish workloads thrashing due
> to low memory and those that can't fit there no matter what? Or would it
> require tracking lifetime of so many evicted pages that the memory overhead
> of that would be infeasible?

Yes, using the workingset code is exactly my plan. The only thing it
requires on top is a time component. Then we can kick the OOM killer
based on the share of time a workload (the system?) spends thrashing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
