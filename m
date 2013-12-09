Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 87BC06B00DF
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 15:10:49 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id f11so3152705yha.28
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 12:10:49 -0800 (PST)
Received: from mail-yh0-x236.google.com (mail-yh0-x236.google.com [2607:f8b0:4002:c01::236])
        by mx.google.com with ESMTPS id z48si11013276yha.106.2013.12.09.12.10.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 12:10:48 -0800 (PST)
Received: by mail-yh0-f54.google.com with SMTP id z12so3088918yhz.41
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 12:10:48 -0800 (PST)
Date: Mon, 9 Dec 2013 12:10:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom notifications
 to access reserves
In-Reply-To: <20131206190105.GE13373@htj.dyndns.org>
Message-ID: <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com>
References: <20131120152251.GA18809@dhcp22.suse.cz> <alpine.DEB.2.02.1311201917520.7167@chino.kir.corp.google.com> <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com> <20131204054533.GZ3556@cmpxchg.org> <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com> <20131205025026.GA26777@htj.dyndns.org> <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
 <20131206190105.GE13373@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 6 Dec 2013, Tejun Heo wrote:

> > Tejun, how are you?
> 
> Doing pretty good.  How's yourself? :)
> 

Not bad, busy with holidays and all that.

> > I agree that we wouldn't need such support if we are only addressing memcg 
> > oom conditions.  We could do things like A/memory.limit_in_bytes == 128M 
> > and A/b/memory.limit_in_bytes == 126MB and then attach the process waiting 
> > on A/b/memory.oom_control to A and that would work perfect.
> 
> Or even just create a separate parallel cgroup A/memory.limit_in_bytes
> == 126M A-oom/memory.limit_in_bytes = 2M and avoid the extra layer of
> nesting.
> 

Indeed.  The setup I'm specifically trying to attack is where the sum of 
the limits of all non-oom handling memcgs (A/b in my model, A in yours) 
exceed the amount of RAM.  If the system has 256MB,

				/=256MB
	A=126MB		A-oom=2MB	B=188MB		B-oom=4MB

or

			/=256MB
	C=128MB				D=192MB
	C/a=126M			D/a=188MB

then it's possible for A + B or C/a + D/a to cause a system oom condition 
and meanwhile A-oom/tasks, B-oom/tasks, C/tasks, and D/tasks cannot 
allocate memory to handle it.

> > However, we also need to discuss system oom handling.  We have an interest 
> > in being able to allow userspace to handle system oom conditions since the 
> > policy will differ depending on machine and we can't encode every possible 
> > mechanism into the kernel.  For example, on system oom we want to kill a 
> > process from the lowest priority top-level memcg.  We lack that ability 
> > entirely in the kernel and since the sum of our top-level memcgs 
> > memory.limit_in_bytes exceeds the amount of present RAM, we run into these 
> > oom conditions a _lot_.
> > 
> > So the first step, in my opinion, is to add a system oom notification on 
> > the root memcg's memory.oom_control which currently allows registering an 
> > eventfd() notification but never actually triggers.  I did that in a patch 
> > and it is was merged into -mm but was pulled out for later discussion.
> 
> Hmmm... this seems to be a different topic.  You're saying that it'd
> be beneficial to add userland oom handling at the sytem level and if
> that happens having per-memcg oom reserve would be consistent with the
> system-wide one, right?

Right, and apologies for not discussing the system oom handling here since 
its notification on the root memcg is currently being debated as well.  
The idea is that admins and users aren't going to be concerned about 
memory allocation through the page allocator vs memory charging through 
the memory controller; they simply want memory for their userspace oom 
handling.  And since the notification would be tied to the root memcg, it 
makes sense to make the amount of memory allowed to allocate exclusively 
for these handlers a memcg interface.  So the cleanest solution, in my 
opinion, was to add the interface as part of memcg.

> While I can see some merit in that argument,
> the whole thing is predicated on system level userland oom handling
> being justified && even then I'm not quite sure whether "consistent
> interface" is enough to have oom reserve in all memory cgroups.  It
> feels a bit backwards because, here, the root memcg is the exception,
> not the other way around.  Root is the only one which can't put oom
> handler in a separate cgroup, so it could make more sense to special
> case that rather than spreading the interface for global userland oom
> to everyone else.
> 

It's really the same thing, though, from the user perspective.  They don't 
care about page allocation failure vs memcg charge failure, they simply 
want to ensure that the memory set aside for memory.oom_reserve_in_bytes 
is available in oom conditions.  With the suggested alternatives:

				/=256MB
	A=126MB		A-oom=2MB	B=188MB		B-oom=4MB

or

			/=256MB
	C=128MB				D=192MB
	C/a=126M			D/a=188MB

we can't distinguish between what is able to allocate below per-zone min 
watermarks in the page allocator as the oom reserve.  The key point is 
that the root memcg is not the only memcg concerned with page allocator 
memory reserves, it's any oom reserve.  If A's usage is 124MB and B's 
usage is 132MB, we can't specify that processes attached to B-oom should 
be able to bypass per-zone min watermarks without an interface such as 
that being proposed.

> But, before that, system level userland OOM handling sounds scary to
> me.  I thought about userland OOM handling for memcgs and it does make
> some sense.  ie. there is a different action that userland oom handler
> can take which kernel oom handler can't - it can expand the limit of
> the offending cgroup, effectively using OOM handler as a sizing
> estimator.  I'm not sure whether that in itself is a good idea but
> then again it might not be possible to clearly separate out sizing
> from oom conditions.
> 
> Anyways, but for system level OOM handling, there's no other action
> userland handler can take.  It's not like the OOM handler paging the
> admin to install more memory is a reasonable mode of operation to
> support.  The *only* action userland OOM handler can take is killing
> something.  Now, if that's the case and we have kernel OOM handler
> anyway, I think the best course of action is improving kernel OOM
> handler and teach it to make the decisions that the userland handler
> would consider good.  That should be doable, right?
> 

It's much more powerful than that; you're referring to the mechanism to 
guarantee future memory freeing so the system or memcg is no longer oom, 
and that's only one case of possible handling.  I have a customer who 
wants to save heap profiles at the time of oom as well, for example, and 
their sole desire is to be able to capture memory statistics before the 
oom kill takes place.  The sine qua non is that memory reserves allow 
something to be done in such conditions: if you try to do a "ps" or "ls" 
or cat a file in an oom memcg, you hang.  We need better functionality to 
ensure that we can do some action prior to the oom kill itself, whether 
that comes from userspace or the kernel.  We simply cannot rely on things 
like memory thresholds or vmpressure to grab these heap profiles, there is 
no guarantee that memory will not be exhausted and the oom kill would 
already have taken place before the process handling the notification 
wakes up.  (And any argument that it is possible by simply making the 
threshold happen early enough is a non-starter: it does not guarantee the 
heaps are collected for oom conditions and the oom kill can still occur 
prematurely in machines that overcommit their memcg limits, as we do.)

> The thing is OOM handling in userland is an inherently fragile thing
> and it can *never* replace kernel OOM handling.  You may reserve any
> amount of memory you want but there would still be cases that it may
> fail.  It's not like we have owner-based allocation all through the
> kernel or are willing to pay overhead for such thing.  Even if that
> part can be guaranteed somehow (no idea how), the kernel still can
> NEVER trust the userland OOM handler.  No matter what we do, we need a
> kernel OOM handler with no resource dependency.
> 

I was never an advocate for the current memory.oom_control behavior that 
allows you to disable the oom killer indefinitely for a memcg and I agree 
that it is dangerous if userspace will not cause future memory freeing or 
toggle the value such that the kernel will kill something.  So I agree 
with you with today's functionality, not with the functionality that this 
patchset, and the notification on the root memcg for system oom 
conditions, provides.  I also proposed a memory.oom_delay_millisecs that 
we have used for several years dating back to even cpusets that simply 
delays the oom kill such that userspace can do "something" like send a 
kill itself, collect heap profiles, send a signal to our malloc() 
implementation to free arena memory, etc. prior to the kernel oom kill.

> So, there isn't anything userland OOM handler can inherently do better
> and we can't do away with kernel handler no matter what.  On both
> accounts, it seems like the best course of action is making
> system-wide kernel OOM handler to make better decisions if possible at
> all.  If that's impossible, let's first think about why that's the
> case before hastly opening this new can of worms.
> 

We certainly can get away with the kernel oom killer in 99% of cases with 
this functionality for users who choose to have their own oom handling 
implementations.  We also can't possibly code every single handling policy 
into the kernel: we can't guarantee that our version of malloc() is 
guaranteed to be able to free memory back to the kernel when waking up on 
a memory.oom_control notification prior to the memcg oom killer killing 
something, for example, without this functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
