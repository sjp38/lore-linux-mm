Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 462D26B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 10:28:52 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id f8so954291wiw.3
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 07:28:51 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lu12si1645539wic.1.2014.02.07.07.28.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 07:28:50 -0800 (PST)
Date: Fri, 7 Feb 2014 16:28:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] cgroup: use an ordered workqueue for cgroup destruction
Message-ID: <20140207152849.GF5121@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
 <20140207140402.GA3304@htj.dyndns.org>
 <20140207143740.GD5121@dhcp22.suse.cz>
 <20140207151341.GB3304@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207151341.GB3304@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 07-02-14 10:13:41, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Feb 07, 2014 at 03:37:40PM +0100, Michal Hocko wrote:
> > Hmm, this is a bit tricky. We cannot use memcg iterators to reach
> > children because css_tryget would fail on them. We can use cgroup
> > iterators instead, alright, and reparent pages from leafs but this all
> > sounds like a lot of complications.
> 
> Hmmm... I think we're talking past each other here.  Why would the
> parent need to reach down to the children?  Just bail out if it can't
> make things down to zero and let the child when it finishes its own
> cleaning walk up the tree propagating changes.  ->parent is always
> accessible.  Would that be complicated too?

This would be basically the option #2 bellow.

> > Another option would be weakening css_offline reparenting and do not
> > insist on having 0 charges. We want to get rid of as many charges as
> > possible but do not need to have all of them gone
> > (http://marc.info/?l=linux-kernel&m=139161412932193&w=2). The last part
> > would be reparenting to the upmost parent which is still online.
> > 
> > I guess this is implementable but I would prefer Hugh's fix for now and
> > for stable.
> 
> Yeah, for -stable, I think Hugh's patch is good but I really don't
> want to keep it long term.

Based on our recent discussion regarding css_offline semantic we want to
do some changes in that area. I thought we would simply update comments
but considering this report css_offline needs some changes as well. I
will look at it. The idea is to split mem_cgroup_reparent_charges into
two parts. The core one which drains LRUs and would be called from
mem_cgroup_css_offline and one which loops until all charges are gone
for mem_cgroup_css_free. mem_cgroup_move_parent will need an update as
well. It would have to go up the hierarchy to the first alive parent.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
