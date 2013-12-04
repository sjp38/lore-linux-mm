Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f176.google.com (mail-ea0-f176.google.com [209.85.215.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEE86B0037
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 06:13:22 -0500 (EST)
Received: by mail-ea0-f176.google.com with SMTP id h14so10578679eaj.21
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 03:13:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si6372107eeo.200.2013.12.04.03.13.20
        for <linux-mm@kvack.org>;
        Wed, 04 Dec 2013 03:13:20 -0800 (PST)
Date: Wed, 4 Dec 2013 12:13:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131204111318.GE8410@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
 <20131118154115.GA3556@cmpxchg.org>
 <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org>
 <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com>
 <20131127163435.GA3556@cmpxchg.org>
 <20131202200221.GC5524@dhcp22.suse.cz>
 <20131202212500.GN22729@cmpxchg.org>
 <20131203120454.GA12758@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue 03-12-13 15:50:41, David Rientjes wrote:
> On Tue, 3 Dec 2013, Michal Hocko wrote:
> 
> > OK, as it seems that the notification part is too controversial, how
> > would you like the following? It reverts the notification part and still
> > solves the fault on exit path. I will prepare the full patch with the
> > changelog if this looks reasonable:
> 
> Um, no, that's not satisfactory because it obviously does the check after 
> mem_cgroup_oom_notify().  There is absolutely no reason why userspace 
> should be woken up when current simply needs access to memory reserves to 
> exit. 

Let me repeat, that the only reason I liked the patch was that it solves
the fault during exit with oom disabled issue which I am really worried
about.
A nice side effect was that it moves the TIF_MEMDIE logic into a common
place. It seems that you are selling the side effect as a primary
feature.
Johannes is obviously against such a change for the reasons I won't
repeat here again. It is true that such a change wouldn't give us the
"notify only when an action is taken" semantic because oom path might
bail out few more times before killing anything.  Until we have that,
or agree what is the actual semantic that makes the most sense let's
backout with this and fix the actual bug which is real and drop the
tweak that just it only half way.

> You can already get such notification by memory thresholds at the 
> memcg limit.
> 
> I'll repeat: Section 10 of Documentation/cgroups/memory.txt specifies what 
> userspace should do when waking up; one of those options is not "check if 
> the memcg is still actually oom in a short period of time once a charging 
> task with a pending SIGKILL or in the exit path has been able to exit."
> Users of this interface typically also disable the memcg oom killer 
> through the same file, it's ludicrous to put the responsibility on 
> userspace to determine if the wakeup is actionable and requires it to 
> intervene in one of the methods listed in section 10.

David, you would need to show us that such a condition happens in real
loads often enough that such a tweak is worth it. Repeating that a race
exists doesn't help, because yeah it does and it will after your patch
as well. So show us that it happens considerably less often with this
check.
 
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
