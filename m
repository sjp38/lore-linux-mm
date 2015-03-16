Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 919896B006C
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 17:12:05 -0400 (EDT)
Received: by wetk59 with SMTP id k59so47365668wet.3
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 14:12:05 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id uj9si20023614wjc.15.2015.03.16.14.12.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 14:12:04 -0700 (PDT)
Date: Mon, 16 Mar 2015 17:11:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2 v2] mm: Allow small allocations to fail
Message-ID: <20150316211146.GA15456@phnom.home.cmpxchg.org>
References: <1426107294-21551-1-git-send-email-mhocko@suse.cz>
 <1426107294-21551-2-git-send-email-mhocko@suse.cz>
 <201503151443.CFE04129.MVFOOStLFHFOQJ@I-love.SAKURA.ne.jp>
 <20150315121317.GA30685@dhcp22.suse.cz>
 <201503152206.AGJ22930.HOStFFFQLVMOOJ@I-love.SAKURA.ne.jp>
 <20150316074607.GA24885@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150316074607.GA24885@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, david@fromorbit.com, mgorman@suse.de, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 16, 2015 at 08:46:07AM +0100, Michal Hocko wrote:
> @@ -707,6 +708,29 @@ sysctl, it will revert to this default behavior.
>  
>  ==============================================================
>  
> +retry_allocation_attempts
> +
> +Page allocator tries hard to not fail small allocations requests.
> +Currently it retries indefinitely for small allocations requests (<= 32kB).
> +This works mostly fine but under an extreme low memory conditions system
> +might end up in deadlock situations because the looping allocation
> +request might block further progress for OOM killer victims.
> +
> +Even though this hasn't turned out to be a huge problem for many years the
> +long term plan is to move away from this default behavior but as this is
> +a long established behavior we cannot change it immediately.
> +
> +This knob should help in the transition. It tells how many times should
> +allocator retry when the system is OOM before the allocation fails.
> +The default value (ULONG_MAX) preserves the old behavior. This is a safe
> +default for production systems which cannot afford any unexpected
> +downtimes. More experimental systems might set it to a small number
> +(>=1), the higher the value the less probable would be allocation
> +failures when OOM is transient and could be resolved without the
> +particular allocation to fail.

This is a negotiation between the page allocator and the various
requirements of its in-kernel users.  If *we* can't make an educated
guess with the entire codebase available, how the heck can we expect
userspace to?

And just assuming for a second that they actually do a better job than
us, are they going to send us a report of their workload and machine
specs and the value that worked for them?  Of course not, why would
you think they'd suddenly send anything but regression reports?

And we wouldn't get regression reports without changing the default,
because really, what is the incentive to mess with that knob?  Making
a lockup you probably never encountered less likely to trigger, while
adding failures of unknown quantity or quality into the system?

This is truly insane.  You're taking one magic factor out of a complex
kernel mechanism and dump it on userspace, which has neither reason
nor context to meaningfully change the default.  We'd never leave that
state of transition.  Only when machines do lock up in the wild, at
least we can tell them they should have set this knob to "like, 50?"

If we want to address this problem, we are the ones that have to make
the call.  Pick a value based on a reasonable model, make it the
default, then deal with the fallout and update our assumptions.

Once that is done, whether we want to provide a boolean failsafe to
revert this in the field is another question.

A sysctl certainly doesn't sound appropriate to me because this is not
a tunable that we expect people to set according to their usecase.  We
expect our model to work for *everybody*.  A boot flag would be
marginally better but it still reeks too much of tunable.

Maybe CONFIG_FAILABLE_SMALL_ALLOCS.  Maybe something more euphemistic.
But I honestly can't think of anything that wouldn't scream "horrible
leak of implementation details."  The user just shouldn't ever care.

Given that there are usually several stages of various testing between
when a commit gets merged upstream and when it finally makes it into a
critical production system, maybe we don't need to provide userspace
control over this at all?

So what value do we choose?

Once we kick the OOM killer we should give the victim some time to
exit and then try the allocation again.  Looping just ONCE after that
means we scan all the LRU pages in the system a second time and invoke
the shrinkers another twelve times, with ratios approaching 1.  If the
OOM killer doesn't yield an allocatable page after this, I see very
little point in going on.  After all, we expect all our callers to
handle errors.

So why not just pass an "oomed" bool to should_alloc_retry() and bail
on small allocations at that point?  Put it upstream and deal with the
fallout long before this hits critical infrastructure?  By presumably
fixing up caller error handling and GFP flags?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
