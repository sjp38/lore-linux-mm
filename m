Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 97F3A6B005A
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 09:05:52 -0500 (EST)
Date: Thu, 29 Nov 2012 15:05:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121129140549.GC27887@dhcp22.suse.cz>
References: <50B403CA.501@jp.fujitsu.com>
 <20121127194813.GP24381@cmpxchg.org>
 <20121127205431.GA2433@dhcp22.suse.cz>
 <20121127205944.GB2433@dhcp22.suse.cz>
 <20121128152631.GT24381@cmpxchg.org>
 <20121128160447.GH12309@dhcp22.suse.cz>
 <20121128163736.GV24381@cmpxchg.org>
 <20121128164640.GB22201@dhcp22.suse.cz>
 <20121128164824.GC22201@dhcp22.suse.cz>
 <alpine.LNX.2.00.1211281023320.14341@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211281023320.14341@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Wed 28-11-12 12:20:44, Hugh Dickins wrote:
[...]
> Sorry, Michal, you've laboured hard on this: but I dislike it so much
> that I'm here overcoming my dread of entering an OOM-killer discussion,
> and the resultant deluge of unwelcome CCs for eternity afterwards.
> 
> I had been relying on Johannes to repeat his "This issue has been
> around for a while so frankly I don't think it's urgent enough to
> rush things", but it looks like I have to be the one to repeat it.

Well, the idea was to use this only as a temporal fix and come up with a
better solution without any hurry.

> Your analysis of azurIt's traces may well be correct, and this patch
> may indeed ameliorate the situation, and it's fine as something for
> azurIt to try and report on and keep in his tree; but I hope that
> it does not go upstream and to stable.
> 
> Why do I dislike it so much?  I suppose because it's both too general
> and too limited at the same time.
> 
> Too general in that it changes the behaviour on OOM for a large set
> of memcg charges, all those that go through add_to_page_cache_locked(),
> when only a subset of those have the i_mutex issue.

This is a fair point but the real fix which we were discussing with
Johannes would be even more risky for stable.

> If you're going to be that general, why not go further?  Leave the
> mem_cgroup_cache_charge() interface as is, make it not-OOM internally,
> no need for SGP_WRITE,SGP_FALLOC distinctions in mm/shmem.c.  No other
> filesystem gets the benefit of those distinctions: isn't it better to
> keep it simple?  (And I can see a partial truncation case where shmem
> uses SGP_READ under i_mutex; and the change to shmem_unuse behaviour
> is a non-issue, since swapoff invites itself to be killed anyway.)
> 
> Too limited in that i_mutex is just the held resource which azurIt's
> traces have led you to, but it's a general problem that the OOM-killed
> task might be waiting for a resource that the OOM-killing task holds.
> 
> I suspect that if we try hard enough (I admit I have not), we can find
> an example of such a potential deadlock for almost every memcg charge
> site.  mmap_sem? not as easy to invent a case with that as I thought,
> since it needs a down_write, and the typical page allocations happen
> with down_read, and I can't think of a process which does down_write
> on another's mm.
> 
> But i_mutex is always good, once you remember the case of write to
> file from userspace page which got paged out, so the fault path has
> to read it back in, while i_mutex is still held at the outer level.
> An unusual case?  Well, normally yes, but we're considering
> out-of-memory conditions, which may converge upon cases like this.
> 
> Wouldn't it be nice if I could be constructive?  But I'm sceptical
> even of Johannes's faith in what the global OOM killer would do:
> how does __alloc_pages_slowpath() get out of its "goto restart"
> loop, excepting the trivial case when the killer is the killed?

I am not sure I am following you here but the Johannes's idea was to
break out of the charge after a signal has been sent and the charge
still fails and either retry the fault or fail the allocation. I think
this should work but I am afraid that this needs some tuning (number of
retries f.e.) to prevent from too aggressive OOM or too many failurs.

Do we have any other possibilities to solve this issue? Or do you think
we should ignore the problem just because nobody complained for such a
long time?
Dunno, I think we should fix this with something less risky for now and
come up with a real fix after it sees sufficient testing.

> I wonder why this issue has hit azurIt and no other reporter?
> No swap plays a part in it, but that's not so unusual.
> 
> Yours glOOMily,
> Hugh

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
