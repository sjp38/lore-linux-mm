Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0B2516B0032
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 16:06:17 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id m16so1179204qcq.19
        for <linux-mm@kvack.org>; Wed, 05 Jun 2013 13:06:17 -0700 (PDT)
Date: Wed, 5 Jun 2013 13:06:12 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605200612.GH10693@mtj.dyndns.org>
References: <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605143949.GQ15576@cmpxchg.org>
 <20130605172212.GA10693@mtj.dyndns.org>
 <20130605194552.GI15721@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605194552.GI15721@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

Hello,

On Wed, Jun 05, 2013 at 03:45:52PM -0400, Johannes Weiner wrote:
> I'm not sure what you are suggesting.  Synchroneously invalidate every
> individual iterator upwards the hierarchy every time a cgroup is
> destroyed?

Yeap.

> The invalidation I am talking about is what we do by increasing the
> dead counts.  This lazily invalidates all the weak pointers in the
> iterators of the hierarchy root.
> 
> Of course if you do a synchroneous invalidation of individual
> iterators, we don't need weak pointers anymore and RCU is enough, but
> that would mean nr_levels * nr_nodes * nr_zones * nr_priority_levels
> invalidation operations per destruction, whereas the weak pointers are
> invalidated with one atomic_inc() per nesting level.

While it does have to traverse the arrays, it's still bound by the
depth of nesting and cgroup destruction is a pretty cold path.  I
don't think it'd matter that much.

> As I said, the weak pointers are only a few lines of code that can be
> neatly self-contained (see the invalidate, load, store functions
> below).  Please convince me that your alternative solution will save
> complexity to such an extent that either the memory waste of
> indefinite css pinning, or the computational overhead of non-lazy
> iterator cleanup, is justifiable.

The biggest issue I see with the weak pointer is that it's special and
tricky.  If this is something which is absolutely necessary, it should
be somewhere more generic.  Also, if we can use the usual RCU deref
with O(depth) cleanup in the cold path, I don't see how this deviation
is justifiable.

For people who've been looking at it for long enough, it probably
isn't that different from using plain RCU but that's just because that
person has spent the time to build that pattern into his/her brain.
We now have a lot of people accustomed to plain RCU usages which in
itself is tricky already and introducing new constructs is actively
deterimental to maintainability.  We sure can do that when there's no
alternative but I don't think avoiding synchronous cleanup on cgroup
destruction path is a good enough reason.  It feels like an
over-engineering to me.

Another thing is that this matters the most when there are continuous
creation and destruction of cgroups and the weak pointer
implementation would keep resetting the iteration to the beginning.
Depending on timing, it'd be able to live-lock reclaim cursor to the
beginning of iteration even with fairly low rate of destruction,
right?  It can be pretty bad high up the tree.  With synchronous
cleanup, depending on how it's implemented, it can be made to keep the
iteration position.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
