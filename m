Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id CB5E46B009A
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 14:01:10 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so869082qeb.34
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 11:01:10 -0800 (PST)
Received: from mail-qe0-x236.google.com (mail-qe0-x236.google.com [2607:f8b0:400d:c02::236])
        by mx.google.com with ESMTPS id l3si3949006qac.158.2013.12.06.11.01.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 11:01:09 -0800 (PST)
Received: by mail-qe0-f54.google.com with SMTP id cy11so867240qeb.27
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 11:01:08 -0800 (PST)
Date: Fri, 6 Dec 2013 14:01:05 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20131206190105.GE13373@htj.dyndns.org>
References: <20131120152251.GA18809@dhcp22.suse.cz>
 <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com>
 <20131128115458.GK2761@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
 <20131204054533.GZ3556@cmpxchg.org>
 <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
 <20131205025026.GA26777@htj.dyndns.org>
 <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Yo, David.

On Thu, Dec 05, 2013 at 03:49:57PM -0800, David Rientjes wrote:
> Tejun, how are you?

Doing pretty good.  How's yourself? :)

> > Umm.. without delving into details, aren't you basically creating a
> > memory cgroup inside a memory cgroup?  Doesn't sound like a
> > particularly well thought-out plan to me.
> 
> I agree that we wouldn't need such support if we are only addressing memcg 
> oom conditions.  We could do things like A/memory.limit_in_bytes == 128M 
> and A/b/memory.limit_in_bytes == 126MB and then attach the process waiting 
> on A/b/memory.oom_control to A and that would work perfect.

Or even just create a separate parallel cgroup A/memory.limit_in_bytes
== 126M A-oom/memory.limit_in_bytes = 2M and avoid the extra layer of
nesting.

> However, we also need to discuss system oom handling.  We have an interest 
> in being able to allow userspace to handle system oom conditions since the 
> policy will differ depending on machine and we can't encode every possible 
> mechanism into the kernel.  For example, on system oom we want to kill a 
> process from the lowest priority top-level memcg.  We lack that ability 
> entirely in the kernel and since the sum of our top-level memcgs 
> memory.limit_in_bytes exceeds the amount of present RAM, we run into these 
> oom conditions a _lot_.
> 
> So the first step, in my opinion, is to add a system oom notification on 
> the root memcg's memory.oom_control which currently allows registering an 
> eventfd() notification but never actually triggers.  I did that in a patch 
> and it is was merged into -mm but was pulled out for later discussion.

Hmmm... this seems to be a different topic.  You're saying that it'd
be beneficial to add userland oom handling at the sytem level and if
that happens having per-memcg oom reserve would be consistent with the
system-wide one, right?  While I can see some merit in that argument,
the whole thing is predicated on system level userland oom handling
being justified && even then I'm not quite sure whether "consistent
interface" is enough to have oom reserve in all memory cgroups.  It
feels a bit backwards because, here, the root memcg is the exception,
not the other way around.  Root is the only one which can't put oom
handler in a separate cgroup, so it could make more sense to special
case that rather than spreading the interface for global userland oom
to everyone else.

But, before that, system level userland OOM handling sounds scary to
me.  I thought about userland OOM handling for memcgs and it does make
some sense.  ie. there is a different action that userland oom handler
can take which kernel oom handler can't - it can expand the limit of
the offending cgroup, effectively using OOM handler as a sizing
estimator.  I'm not sure whether that in itself is a good idea but
then again it might not be possible to clearly separate out sizing
from oom conditions.

Anyways, but for system level OOM handling, there's no other action
userland handler can take.  It's not like the OOM handler paging the
admin to install more memory is a reasonable mode of operation to
support.  The *only* action userland OOM handler can take is killing
something.  Now, if that's the case and we have kernel OOM handler
anyway, I think the best course of action is improving kernel OOM
handler and teach it to make the decisions that the userland handler
would consider good.  That should be doable, right?

The thing is OOM handling in userland is an inherently fragile thing
and it can *never* replace kernel OOM handling.  You may reserve any
amount of memory you want but there would still be cases that it may
fail.  It's not like we have owner-based allocation all through the
kernel or are willing to pay overhead for such thing.  Even if that
part can be guaranteed somehow (no idea how), the kernel still can
NEVER trust the userland OOM handler.  No matter what we do, we need a
kernel OOM handler with no resource dependency.

So, there isn't anything userland OOM handler can inherently do better
and we can't do away with kernel handler no matter what.  On both
accounts, it seems like the best course of action is making
system-wide kernel OOM handler to make better decisions if possible at
all.  If that's impossible, let's first think about why that's the
case before hastly opening this new can of worms.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
