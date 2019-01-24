Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDFE38E0047
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 03:22:54 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f17so1975540edm.20
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 00:22:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n3si1457801edo.15.2019.01.24.00.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jan 2019 00:22:53 -0800 (PST)
Date: Thu, 24 Jan 2019 09:22:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190124082252.GD4087@dhcp22.suse.cz>
References: <20190123223144.GA10798@chrisdown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190123223144.GA10798@chrisdown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Down <chris@chrisdown.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Wed 23-01-19 17:31:44, Chris Down wrote:
> memory.stat and other files already consider subtrees in their output,
> and we should too in order to not present an inconsistent interface.
> 
> The current situation is fairly confusing, because people interacting
> with cgroups expect hierarchical behaviour in the vein of memory.stat,
> cgroup.events, and other files. For example, this causes confusion when
> debugging reclaim events under low, as currently these always read "0"
> at non-leaf memcg nodes, which frequently causes people to misdiagnose
> breach behaviour. The same confusion applies to other counters in this
> file when debugging issues.
> 
> Aggregation is done at write time instead of at read-time since these
> counters aren't hot (unlike memory.stat which is per-page, so it does it
> at read time), and it makes sense to bundle this with the file
> notifications.

I do not think we can do that for two reasons. It breaks the existing
semantic userspace might depend on and more importantly this is not a
correct behavior IMO.

You have to realize that stats are hierarchical because that is how we
account. Events represent a way to inform that something has happened at
the specific level of the tree though. If you do not setup low/high/max
limit then you simply cannot expect to be informed those get hit because
they cannot by definition. Or put it other way, if you are waiting for
those events you really want to know the (sub)tree they happened and if
you propagate the event up the hierarchy you have hard time to tell that
(you would basically have to exclude all but the lowest one and that is
an awkward semantic at best.

Maybe we want to document this better but I do not see we are going to
change the behavior.

> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

btw. I do not see this patch posted anywhere yet it already comes with
an ack. Have I just missed a previous version?
-- 
Michal Hocko
SUSE Labs
