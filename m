Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 823296B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 10:13:50 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so5438734qae.13
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 07:13:50 -0800 (PST)
Received: from mail-qc0-x22d.google.com (mail-qc0-x22d.google.com [2607:f8b0:400d:c01::22d])
        by mx.google.com with ESMTPS id z6si3722858qan.111.2014.02.07.07.13.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 07:13:47 -0800 (PST)
Received: by mail-qc0-f173.google.com with SMTP id i8so6095226qcq.18
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 07:13:44 -0800 (PST)
Date: Fri, 7 Feb 2014 10:13:41 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] cgroup: use an ordered workqueue for cgroup destruction
Message-ID: <20140207151341.GB3304@htj.dyndns.org>
References: <alpine.LSU.2.11.1402061541560.31342@eggly.anvils>
 <20140207140402.GA3304@htj.dyndns.org>
 <20140207143740.GD5121@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140207143740.GD5121@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Filipe Brandenburger <filbranden@google.com>, Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Markus Blank-Burian <burian@muenster.de>, Shawn Bohrer <shawn.bohrer@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Michal.

On Fri, Feb 07, 2014 at 03:37:40PM +0100, Michal Hocko wrote:
> Hmm, this is a bit tricky. We cannot use memcg iterators to reach
> children because css_tryget would fail on them. We can use cgroup
> iterators instead, alright, and reparent pages from leafs but this all
> sounds like a lot of complications.

Hmmm... I think we're talking past each other here.  Why would the
parent need to reach down to the children?  Just bail out if it can't
make things down to zero and let the child when it finishes its own
cleaning walk up the tree propagating changes.  ->parent is always
accessible.  Would that be complicated too?

> Another option would be weakening css_offline reparenting and do not
> insist on having 0 charges. We want to get rid of as many charges as
> possible but do not need to have all of them gone
> (http://marc.info/?l=linux-kernel&m=139161412932193&w=2). The last part
> would be reparenting to the upmost parent which is still online.
> 
> I guess this is implementable but I would prefer Hugh's fix for now and
> for stable.

Yeah, for -stable, I think Hugh's patch is good but I really don't
want to keep it long term.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
