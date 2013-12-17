Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f43.google.com (mail-yh0-f43.google.com [209.85.213.43])
	by kanga.kvack.org (Postfix) with ESMTP id 91B7F6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 20:42:19 -0500 (EST)
Received: by mail-yh0-f43.google.com with SMTP id a41so4449690yho.30
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 17:42:19 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id 41si14206855yhf.77.2013.12.16.17.42.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 17:42:18 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id fa1so3735446pad.17
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 17:42:17 -0800 (PST)
Date: Mon, 16 Dec 2013 17:41:38 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
In-Reply-To: <20131216172143.GJ32509@htj.dyndns.org>
Message-ID: <alpine.LNX.2.00.1312161718001.2037@eggly.anvils>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils> <52AEC989.4080509@huawei.com> <20131216095345.GB23582@dhcp22.suse.cz> <20131216104042.GC23582@dhcp22.suse.cz> <20131216163530.GH32509@htj.dyndns.org> <20131216171937.GG26797@dhcp22.suse.cz>
 <20131216172143.GJ32509@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 16 Dec 2013, Tejun Heo wrote:
> On Mon, Dec 16, 2013 at 06:19:37PM +0100, Michal Hocko wrote:
> > I have to think about it some more (the brain is not working anymore
> > today). But what we really need is that nobody gets the same id while
> > the css is alive. So css_from_id returning NULL doesn't seem to be
> > enough.
> 
> Oh, I meant whether it's necessary to keep css_from_id() working
> (ie. doing successful lookups) between offline and release, because
> that's where lifetimes are coupled.  IOW, if it's enough for cgroup to
> not recycle the ID until all css's are released && fail css_from_id()
> lookup after the css is offlined, I can make a five liner quick fix.

Don't take my word on it, I'm too fuzzy on this: but although it would
be good to refrain from recycling the ID until all css's are released,
I believe that it would not be good enough to fail css_from_id() once
the css is offlined - mem_cgroup_uncharge_swap() needs to uncharge the
hierarchy of the dead memcg (for example, when tmpfs file is removed).

Uncharging the dead memcg itself is presumably irrelevant, but it does
need to locate the right parent to uncharge, and NULL css_from_id()
would make that impossible.  It would be easy if we said those charges
migrate to root rather than to parent, but that's inconsistent with
what we have happily converged upon doing elsewhere (in the preferred
use_hierarchy case), and it would be a change in behaviour.

I'm not nearly as enthusiastic for my patch as Michal is: I really
would prefer a five-liner from you or from Zefan.  I do think (and
this is probably what Michal likes) that my patch leaves MEMCG_SWAP
less surprising, and less likely to cause similar trouble in future;
but it's not how Kame chose to implement it, and it has those nasty
swap_cgroup array scans adding to the overhead of memcg removal -
we can layer on several different hacks/optimizations to reduce that
overhead, but I think it's debatable whether that will end up as an
improvement over what we have had until now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
