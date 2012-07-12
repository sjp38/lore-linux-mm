Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id B61396B0083
	for <linux-mm@kvack.org>; Thu, 12 Jul 2012 05:12:43 -0400 (EDT)
Date: Thu, 12 Jul 2012 11:12:27 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 01/10] mm: memcg: fix compaction/migration failing due to
 memcg limits
Message-ID: <20120712091227.GA1239@cmpxchg.org>
References: <1342026142-7284-1-git-send-email-hannes@cmpxchg.org>
 <1342026142-7284-2-git-send-email-hannes@cmpxchg.org>
 <20120712085354.GA3181@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120712085354.GA3181@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 12, 2012 at 04:54:07PM +0800, Wanpeng Li wrote:
> On Wed, Jul 11, 2012 at 07:02:13PM +0200, Johannes Weiner wrote:
> >Compaction (and page migration in general) can currently be hindered
> >through pages being owned by memory cgroups that are at their limits
> >and unreclaimable.
> >
> >The reason is that the replacement page is being charged against the
> >limit while the page being replaced is also still charged.  But this
> >seems unnecessary, given that only one of the two pages will still be
> >in use after migration finishes.
> >
> >This patch changes the memcg migration sequence so that the
> >replacement page is not charged.  Whatever page is still in use after
> >successful or failed migration gets to keep the charge of the page
> >that was going to be replaced.
> >
> >The replacement page will still show up temporarily in the rss/cache
> >statistics, this can be fixed in a later patch as it's less urgent.
> 
> So I want to know after this patch be merged if mem_cgroup_wait_acct_move
> still make sense, if the answer is no, I will send a patch to remove it.

This change is about migrating a charge from one physical page to
another, account moving is about migrating charges between groups.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
