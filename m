Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id DAF2A6B0044
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 17:06:43 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id hj6so3008857wib.8
        for <linux-mm@kvack.org>; Mon, 26 Nov 2012 14:06:42 -0800 (PST)
Date: Mon, 26 Nov 2012 23:06:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121126220640.GE12602@dhcp22.suse.cz>
References: <20121125135542.GE10623@dhcp22.suse.cz>
 <20121126013855.AF118F5E@pobox.sk>
 <20121126131837.GC17860@dhcp22.suse.cz>
 <20121126174622.GE2799@cmpxchg.org>
 <20121126180444.GA12602@dhcp22.suse.cz>
 <20121126182421.GB2301@cmpxchg.org>
 <20121126190329.GB12602@dhcp22.suse.cz>
 <20121126192941.GC2301@cmpxchg.org>
 <20121126200848.GC12602@dhcp22.suse.cz>
 <20121126201918.GD2301@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121126201918.GD2301@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: azurIt <azurit@pobox.sk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon 26-11-12 15:19:18, Johannes Weiner wrote:
> On Mon, Nov 26, 2012 at 09:08:48PM +0100, Michal Hocko wrote:
[...]
> > OK, I guess I am getting what you are trying to say. So what you are
> > suggesting is to just let mem_cgroup_out_of_memory send the signal and
> > move on without retry (or with few charge retries without further OOM
> > killing) and fail the charge with your new FAULT_OOM_HANDLED (resp.
> > something like FAULT_RETRY) error code resp. ENOMEM depending on the
> > caller.  OOM disabled case would be "you are on your own" because this
> > has been dangerous anyway. Correct?
> 
> Yes.
> 
> > I do agree that the current endless retry loop is far from being ideal
> > and can see some updates but I am quite nervous about any potential
> > regressions in this area (e.g. too aggressive OOM etc...). I have to
> > think about it some more.
> 
> Agreed on all points.  Maybe we can keep a couple of the oom retry
> iterations or something like that, which is still much more than what
> global does and I don't think the global OOM killer is overly eager.

Yes we can offer less blood and more confort

> 
> Testing will show more.
> 
> > Anyway if you have some more specific ideas I would be happy to review
> > patches.
> 
> Okay, I just wanted to check back with you before going down this
> path.  What are we going to do short term, though?  Do you want to
> push the disable-oom-for-pagecache for now or should we put the
> VM_FAULT_OOM_HANDLED fix in the next version and do stable backports?
> 
> This issue has been around for a while so frankly I don't think it's
> urgent enough to rush things.

Yes, but now we have a real usecase where this hurts AFAIU. Unless
we come up with a fix/reasonable workaround I would rather go with
something simpler for starter and more sofisticated later.

I have to double check other places where we do charging but the last
time I've checked we don't hold page locks on already visible pages (we
do precharge in __do_fault f.e.), mem_map for reading in the page fault
path is also safe (with oom enabled) and I guess that tmpfs is ok as
well. Then we have a page cache and that one should be covered by my
patch. So we should be covered.

But I like your idea long term.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
