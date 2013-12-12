Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7073F6B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 14:23:32 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so709045yho.24
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 11:23:32 -0800 (PST)
Received: from mail-yh0-x232.google.com (mail-yh0-x232.google.com [2607:f8b0:4002:c01::232])
        by mx.google.com with ESMTPS id v1si22608078yhg.276.2013.12.12.11.23.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 11:23:31 -0800 (PST)
Received: by mail-yh0-f50.google.com with SMTP id b6so720487yha.37
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 11:23:31 -0800 (PST)
Date: Thu, 12 Dec 2013 14:23:19 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom
 notifications to access reserves
Message-ID: <20131212192319.GL32683@htj.dyndns.org>
References: <20131205025026.GA26777@htj.dyndns.org>
 <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
 <20131206190105.GE13373@htj.dyndns.org>
 <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com>
 <20131210215037.GB9143@htj.dyndns.org>
 <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
 <20131211124240.GA24557@htj.dyndns.org>
 <CAAAKZwsmM-C=kLGV=RW=Y4Mq=BWpQzuPruW6zvEr9p0Xs4GD5g@mail.gmail.com>
 <20131212142156.GB32683@htj.dyndns.org>
 <CAAAKZwtuydFdiiSsKMuOUv3nr9trjuKvKoDO2aM0QsJKu1TMZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAAKZwtuydFdiiSsKMuOUv3nr9trjuKvKoDO2aM0QsJKu1TMZA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Hockin <thockin@hockin.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>

Hello, Tim.

On Thu, Dec 12, 2013 at 10:42:20AM -0800, Tim Hockin wrote:
> Yeah sorry.  Replying from my phone is awkward at best.  I know better :)

Heh, sorry about being bitchy. :)

> In my mind, the ONLY point of pulling system-OOM handling into
> userspace is to make it easier for crazy people (Google) to implement
> bizarre system-OOM policies.  Example:

I think that's one of the places where we largely disagree.  If at all
possible, I'd much prefer google's workload to be supported inside the
general boundaries of the upstream kernel without having to punch a
large hole in it.  To me, the general development history of memcg in
general and this thread in particular seem to epitomize why it is a
bad idea to have isolated, large and deep "crazy" use cases.  Punching
the initial hole is the easy part; however, we all are quite limited
in anticpating future needs and sooner or later that crazy use case is
bound to evolve further towards the isolated extreme it departed
towards and require more and larger holes and further contortions to
accomodate such progress.

The concern I have with the suggested solution is not necessarily that
it's technically complex than it looks like on the surface - I'm sure
it can be made to work one way or the other - but that it's a fairly
large step toward an isolated extreme which memcg as a project
probably should not head toward.

There sure are cases where such exceptions can't be avoided and are
good trade-offs but, here, we're talking about a major architectural
decision which not only affects memcg but mm in general.  I'm afraid
this doesn't sound like an no-brainer flexibility we can afford.

> When we have a system OOM we want to do a walk of the administrative
> memcg tree (which is only a couple levels deep, users can make
> non-admin sub-memcgs), selecting the lowest priority entity at each
> step (where both tasks and memcgs have a priority and the priority
> range is much wider than the current OOM scores, and where memcg
> priority is sometimes a function of memcg usage), until we reach a
> leaf.
> 
> Once we reach a leaf, I want to log some info about the memcg doing
> the allocation, the memcg being terminated, and maybe some other bits
> about the system (depending on the priority of the selected victim,
> this may or may not be an "acceptable" situation).  Then I want to
> kill *everything* under that memcg.  Then I want to "publish" some
> information through a sane API (e.g. not dmesg scraping).
> 
> This is basically our policy as we understand it today.  This is
> notably different than it was a year ago, and it will probably evolve
> further in the next year.

I think per-memcg score and killing is something which makes
fundamental sense.  In fact, killing a single process has never made
much sense to me as that is a unit which ultimately is only meaningful
to the kernel itself and not necessraily to userland, so no matter
what I think we're gonna gain per-memcg behavior and it seems most,
albeit not all, of what you described above should be implementable
through that.

Ultimately, if the use case calls for very fine level of control, I
think the right thing to do is making nesting work properly which is
likely to take some time.  In the meantime, even if such use case
requires modifying the kernel to tailor the OOM behavior, I think
sticking to kernel OOM provides a lot easier way to eventual
convergence.  Userland system OOM basically means giving up and would
lessen the motivation towards improving the shared infrastructures
while adding significant pressure towards schizophreic diversion.

> We have a long tail of kernel memory usage.  If we provision machines
> so that the "do work here" first-level memcg excludes the average
> kernel usage, we have a huge number of machines that will fail to
> apply OOM policy because of actual overcommitment.  If we provision
> for 95th or 99th percentile kernel usage, we're wasting large amounts
> of memory that could be used to schedule jobs.  This is the
> fundamental problem we face with static apportionment (and we face it
> in a dozen other situations, too).  Expressing this set-aside memory
> as "off-the-top" rather than absolute limits makes the whole system
> more flexible.

I agree that's pretty sad.  Maybe I shouldn't be surprised given the
far-from-perfect coverage of kmemcg at this point, but, again,
*everyone* wants [k]memcg coverage to be more complete and we have and
are still building the infrastructures to make that possible, so I'm
still of the opinion that making [k]memcg work better is the better
direction to pursue and given the short development history of kmemcg
I'm fairly sure there are quite a few low hanging fruits.

Another thing which *might* be relevant is the rigidity of the upper
limit and the vagueness of soft limit of the current implementation.
I have a rather strong suspicion that the way memcg config knobs
behave now - one finicky, the other whatever - is likely hindering the
use cases to fan out more naturally.  I could be completely wrong on
this but your mention of inflexibility of absolute limits reminds me
of the issue.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
