Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 484096B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:11:21 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so2896270ead.24
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 05:11:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e48si4969031eeh.29.2013.12.17.05.11.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 05:11:20 -0800 (PST)
Date: Tue, 17 Dec 2013 14:11:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131217131119.GD28991@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
 <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216163530.GH32509@htj.dyndns.org>
 <20131216171937.GG26797@dhcp22.suse.cz>
 <20131216172143.GJ32509@htj.dyndns.org>
 <alpine.LNX.2.00.1312161718001.2037@eggly.anvils>
 <52AFC163.5010507@huawei.com>
 <alpine.LNX.2.00.1312162300410.16426@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1312162300410.16426@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 16-12-13 23:09:23, Hugh Dickins wrote:
> On Tue, 17 Dec 2013, Li Zefan wrote:
> > On 2013/12/17 9:41, Hugh Dickins wrote:
> > > On Mon, 16 Dec 2013, Tejun Heo wrote:
> > >> On Mon, Dec 16, 2013 at 06:19:37PM +0100, Michal Hocko wrote:
> > >>> I have to think about it some more (the brain is not working anymore
> > >>> today). But what we really need is that nobody gets the same id while
> > >>> the css is alive.
> > 
> > That's what I meant to do in my last reply.
> > 
> > But I'm confused by
> > 
> > "How would this work? .. the swap will be there
> > after the last reference to css as well."
> > 
> > >>> So css_from_id returning NULL doesn't seem to be
> > >>> enough.
> > >>
> > >> Oh, I meant whether it's necessary to keep css_from_id() working
> > >> (ie. doing successful lookups) between offline and release, because
> > >> that's where lifetimes are coupled.  IOW, if it's enough for cgroup to
> > >> not recycle the ID until all css's are released && fail css_from_id()
> > >> lookup after the css is offlined, I can make a five liner quick fix.
> > > 
> > > Don't take my word on it, I'm too fuzzy on this: but although it would
> > > be good to refrain from recycling the ID until all css's are released,
> > > I believe that it would not be good enough to fail css_from_id() once
> > > the css is offlined - mem_cgroup_uncharge_swap() needs to uncharge the
> > > hierarchy of the dead memcg (for example, when tmpfs file is removed).
> > > 
> > > Uncharging the dead memcg itself is presumably irrelevant, but it does
> > > need to locate the right parent to uncharge, and NULL css_from_id()
> > > would make that impossible.  It would be easy if we said those charges
> > > migrate to root rather than to parent, but that's inconsistent with
> > > what we have happily converged upon doing elsewhere (in the preferred
> > > use_hierarchy case), and it would be a change in behaviour.
> > > 
> > > I'm not nearly as enthusiastic for my patch as Michal is: I really
> > > would prefer a five-liner from you or from Zefan. 
> > 
> > I've come up with a fix. Though it's more than five-line, it mostly moves
> > a few lines from one place to another. I've tested it with your script.
> 
> It seems to be working very well for me.  I'm inclined to forgive you for
> taking more than five lines, given that there are almost as many -s as +s ;)
> 
> In my opinion, your patch is greatly preferable to mine - if there are
> good things in mine, memcg can incorporate them at leisure later on,
> but right now this seems a much better 3.13 solution.  I'm guessing
> Tejun and Hannes will feel the same way: how about you, Michal?

OK, let's go with this for now but I would like swap accounting less
tricky and confusing and explicit reparenting should help there I
believe.

And sorry for distracting you from the css based approach. I have
totally misinterpreted the comment above idr_remove.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
