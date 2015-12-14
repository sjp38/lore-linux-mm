Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5776B0259
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:48:49 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p66so68327723wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:48:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o204si26089727wma.118.2015.12.14.07.48.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 07:48:48 -0800 (PST)
Date: Mon, 14 Dec 2015 10:48:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/7] mm: memcontrol: charge swap to cgroup2
Message-ID: <20151214154836.GA14103@cmpxchg.org>
References: <cover.1449742560.git.vdavydov@virtuozzo.com>
 <265d8fe623ed2773d69a26d302eb31e335377c77.1449742560.git.vdavydov@virtuozzo.com>
 <20151214153037.GB4339@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214153037.GB4339@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 14, 2015 at 04:30:37PM +0100, Michal Hocko wrote:
> On Thu 10-12-15 14:39:14, Vladimir Davydov wrote:
> > In the legacy hierarchy we charge memsw, which is dubious, because:
> > 
> >  - memsw.limit must be >= memory.limit, so it is impossible to limit
> >    swap usage less than memory usage. Taking into account the fact that
> >    the primary limiting mechanism in the unified hierarchy is
> >    memory.high while memory.limit is either left unset or set to a very
> >    large value, moving memsw.limit knob to the unified hierarchy would
> >    effectively make it impossible to limit swap usage according to the
> >    user preference.
> > 
> >  - memsw.usage != memory.usage + swap.usage, because a page occupying
> >    both swap entry and a swap cache page is charged only once to memsw
> >    counter. As a result, it is possible to effectively eat up to
> >    memory.limit of memory pages *and* memsw.limit of swap entries, which
> >    looks unexpected.
> > 
> > That said, we should provide a different swap limiting mechanism for
> > cgroup2.
> > This patch adds mem_cgroup->swap counter, which charges the actual
> > number of swap entries used by a cgroup. It is only charged in the
> > unified hierarchy, while the legacy hierarchy memsw logic is left
> > intact.
> 
> I agree that the previous semantic was awkward. The problem I can see
> with this approach is that once the swap limit is reached the anon
> memory pressure might spill over to other and unrelated memcgs during
> the global memory pressure. I guess this is what Kame referred to as
> anon would become mlocked basically. This would be even more of an issue
> with resource delegation to sub-hierarchies because nobody will prevent
> setting the swap amount to a small value and use that as an anon memory
> protection.

Overcommitting untrusted workloads is already problematic because
reclaim is based on heuristics and references, and a malicious
workload can already interfere with it and create pressure on the
system or its neighboring groups. This patch doesn't make it better,
but it's not a new problem.

If you don't trust subhierarchies, don't give them more memory than
you can handle them taking. And then giving them swap is a resource
for them to use on top of that memory, not for you at the toplevel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
