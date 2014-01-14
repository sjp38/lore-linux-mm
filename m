Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id BB62D6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 09:29:08 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id w8so6327095qac.36
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 06:29:08 -0800 (PST)
Received: from mail-qe0-x22a.google.com (mail-qe0-x22a.google.com [2607:f8b0:400d:c02::22a])
        by mx.google.com with ESMTPS id j9si912720qec.31.2014.01.14.06.29.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 06:29:08 -0800 (PST)
Received: by mail-qe0-f42.google.com with SMTP id b4so8655382qen.29
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 06:29:07 -0800 (PST)
Date: Tue, 14 Jan 2014 09:29:04 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/3] mm/memcg: iteration skip memcgs not yet fully
 initialized
Message-ID: <20140114142904.GA12131@htj.dyndns.org>
References: <alpine.LSU.2.11.1401131742370.2229@eggly.anvils>
 <alpine.LSU.2.11.1401131752360.2229@eggly.anvils>
 <20140114133005.GC32227@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140114133005.GC32227@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hey, Michal.

On Tue, Jan 14, 2014 at 02:30:05PM +0100, Michal Hocko wrote:
> On Mon 13-01-14 17:54:04, Hugh Dickins wrote:
> > It is surprising that the mem_cgroup iterator can return memcgs which
> > have not yet been fully initialized.  By accident (or trial and error?)
> > this appears not to present an actual problem; but it may be better to
> > prevent such surprises, by skipping memcgs not yet online.
> 
> My understanding was that !online cgroups are not visible for the
> iterator. it is css_online that has to be called before they are made
> visible.
> 
> Tejun?

>From the comment above css_for_each_descendant_pre()

 * Walk @root's descendants.  @root is included in the iteration and the
 * first node to be visited.  Must be called under rcu_read_lock().  A
 * descendant css which hasn't finished ->css_online() or already has
 * finished ->css_offline() may show up during traversal and it's each
 * subsystem's responsibility to verify that each @pos is alive.
     
What it guarantees is that an online css would *always* show up in the
iteration.  It's kinda difficult to guarantee both directions just
with RCU locking.  You gotta make at least one end loose to make it
work with RCU.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
