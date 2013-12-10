Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id C3D866B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 18:55:52 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so4511675yhz.15
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:55:52 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id u45si15479906yhc.103.2013.12.10.15.55.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 15:55:51 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so4482459yha.40
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:55:51 -0800 (PST)
Date: Tue, 10 Dec 2013 15:55:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom notifications
 to access reserves
In-Reply-To: <20131210215037.GB9143@htj.dyndns.org>
Message-ID: <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
References: <20131128115458.GK2761@dhcp22.suse.cz> <alpine.DEB.2.02.1312021504170.13465@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032116440.29733@chino.kir.corp.google.com> <alpine.DEB.2.02.1312032118570.29733@chino.kir.corp.google.com>
 <20131204054533.GZ3556@cmpxchg.org> <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com> <20131205025026.GA26777@htj.dyndns.org> <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com> <20131206190105.GE13373@htj.dyndns.org>
 <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com> <20131210215037.GB9143@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 10 Dec 2013, Tejun Heo wrote:

> > Indeed.  The setup I'm specifically trying to attack is where the sum of 
> > the limits of all non-oom handling memcgs (A/b in my model, A in yours) 
> > exceed the amount of RAM.  If the system has 256MB,
> > 
> > 				/=256MB
> > 	A=126MB		A-oom=2MB	B=188MB		B-oom=4MB
> > 
> > or
> > 
> > 			/=256MB
> > 	C=128MB				D=192MB
> > 	C/a=126M			D/a=188MB
> > 
> > then it's possible for A + B or C/a + D/a to cause a system oom condition 
> > and meanwhile A-oom/tasks, B-oom/tasks, C/tasks, and D/tasks cannot 
> > allocate memory to handle it.
> 
> "tasks"?  You mean that tasks can't be read reliably once system-OOM
> is hit regardless of memcg configuration?
> 

Not referring to the files themselves, rather the processes listed by 
those files, sorry.  Those processes would not be able to do a ps, ls, or 
anything useful even if they are mlocked into memory because they cannot 
allocate memory in oom conditions.

> > Right, and apologies for not discussing the system oom handling here since 
> > its notification on the root memcg is currently being debated as well.  
> > The idea is that admins and users aren't going to be concerned about 
> > memory allocation through the page allocator vs memory charging through 
> > the memory controller; they simply want memory for their userspace oom 
> > handling.  And since the notification would be tied to the root memcg, it 
> > makes sense to make the amount of memory allowed to allocate exclusively 
> > for these handlers a memcg interface.  So the cleanest solution, in my 
> > opinion, was to add the interface as part of memcg.
> 
> I'm still not quite following the reasoning.  Can you please elaborate
> on what the distinction between "page allocator" and "charges through
> memory controller" has to do with this interface?
> 

The interface would allow both access to memory reserves through the page 
allocator as well as charging above the memcg limit, it is the only way to 
guarantee that memory can be allocated by processes attached to the memcg 
in oom conditions.  We must be able to do both, otherwise no matter what 
overcharge we allow them via memcg, it is still possible for the 
allocation itself to fail in the page allocator before we even get to that 
point.

The confusion here is because the access to memory reserves in the page 
allocator is not presented here because there is another on-going 
discussion about when to notify processes waiting on the root memcg's 
memory.oom_control about system oom conditions.  I can certainly post that 
patch as well, but it wouldn't apply without resolving that side-thread 
first.

The high order bit is that we need to be able to address system oom 
conditions as well as memcg oom conditions in userspace and system oom 
conditions require us to specify the processes that are allowed access to 
a special memory reserve.  We can't do that with sibling or parent memcgs 
without some new tunable like memory.allow_page_alloc_reserves, but we 
would also have to specify the amount of reserves allowed.  It seemed 
clean and straight-forward to specify this as both the system oom memory 
reserve amount and memcg limit overcharge amount within the same file, 
memory.oom_reserve_in_bytes as this patch does.

> > It's really the same thing, though, from the user perspective.  They don't 
> > care about page allocation failure vs memcg charge failure, they simply 
> > want to ensure that the memory set aside for memory.oom_reserve_in_bytes 
> > is available in oom conditions.  With the suggested alternatives:
> > 
> > 				/=256MB
> > 	A=126MB		A-oom=2MB	B=188MB		B-oom=4MB
> > 
> > or
> > 
> > 			/=256MB
> > 	C=128MB				D=192MB
> > 	C/a=126M			D/a=188MB
> > 
> > we can't distinguish between what is able to allocate below per-zone min 
> > watermarks in the page allocator as the oom reserve.  The key point is 
> > that the root memcg is not the only memcg concerned with page allocator 
> > memory reserves, it's any oom reserve.  If A's usage is 124MB and B's 
> > usage is 132MB, we can't specify that processes attached to B-oom should 
> > be able to bypass per-zone min watermarks without an interface such as 
> > that being proposed.
> 
> Okay, are you saying that userland OOM handlers will be able to dip
> into kernel reserve memory?  Maybe I'm mistaken but you realize that
> that reserve is there to make things like task exits work under OOM
> conditions, right?  The only way userland OOM handlers as you describe
> would work would be creating a separate reserve for them.
> 

Yes, PF_OOM_HANDLER processes would be able to allocate this amount as 
specified by memory.oom_reserve_in_bytes below the per-zone watermarks and 
the amount of reserves can already be controlled via min_free_kbytes, 
which we already increase internally for thp.  This could obviously be 
limited to some sane value that is a fraction of the smallest zone's min 
watermark, that's not a problem: I've never had a memcg or system oom 
reserve larger than 2MB and most users would probably get away with 256KB 
or 512KB.

> > It's much more powerful than that; you're referring to the mechanism to 
> > guarantee future memory freeing so the system or memcg is no longer oom, 
> > and that's only one case of possible handling.  I have a customer who 
> > wants to save heap profiles at the time of oom as well, for example, and 
> > their sole desire is to be able to capture memory statistics before the 
> > oom kill takes place.  The sine qua non is that memory reserves allow 
> > something to be done in such conditions: if you try to do a "ps" or "ls" 
> > or cat a file in an oom memcg, you hang.  We need better functionality to 
> > ensure that we can do some action prior to the oom kill itself, whether 
> > that comes from userspace or the kernel.  We simply cannot rely on things 
> 
> Well, the gotcha there is that you won't be able to do that with
> system level OOM handler either unless you create a separately
> reserved memory, which, again, can be achieved using hierarchical
> memcg setup already.  Am I missing something here?
> 

System oom conditions would only arise when the usage of memcgs A + B 
above cause the page allocator to not be able to allocate memory without 
oom killing something even though the limits of both A and B may not have 
been reached yet.  No userspace oom handler can allocate memory with 
access to memory reserves in the page allocator in such a context; it's 
vital that if we are to handle system oom conditions in userspace that we 
given them access to memory that other processes can't allocate.  You 
could attach a userspace system oom handler to any memcg in this scenario 
with memory.oom_reserve_in_bytes and since it has PF_OOM_HANDLER it would 
be able to allocate in reserves in the page allocator and overcharge in 
its memcg to handle it.  This isn't possible only with a hierarchical 
memcg setup unless you ensure the sum of the limits of the top level 
memcgs do not equal or exceed the sum of the min watermarks of all memory 
zones, and we exceed that.

> > conditions, provides.  I also proposed a memory.oom_delay_millisecs that 
> > we have used for several years dating back to even cpusets that simply 
> > delays the oom kill such that userspace can do "something" like send a 
> > kill itself, collect heap profiles, send a signal to our malloc() 
> > implementation to free arena memory, etc. prior to the kernel oom kill.
> 
> All the above would require a separately reserved memory, right?
> Also, a curiosity, how would "sending a signal to our malloc()" work?
> If you mean sending a signal to malloc() in a different process,
> that's not gonna work.  How is that process gonna have memory to
> process the signal and free memory from malloc() under OOM condition?
> 

The signal is actually a wakeup from vmpressure, we don't want to wait 
until reclaim is completely exhausted before freeing this memory, we want 
to do it at VMPRESSURE_LOW.  We simply needed a way to avoid the immediate 
oom kill unless it has a chance to free excess memory from malloc() first.  
We can also avoid oom killing entirely if, upon memcg oom notification, we 
can simply increase its limit instead of freeing memory at all: we have 
internally the notion of "overlimit" memcgs that are the first memcgs to 
kill within on system oom but are allowed to exceed their reservation if 
memory is available.  It's advantageous to require them to aggressively 
reclaim up to their reservation and then only increase the memcg limit as 
a last resort.  If we hit system oom later, they get killed first.  With 
this functionality, it does not require more than a few pages of 
memory.oom_reserve_in_bytes to write to memory.limit_in_bytes.

> So, malloc() is mapped into the same process as the OOM handler which
> is gonna be able to tap into physically reserved memory?  Also, while
> freeing, it won't need to coordinate with other processes?
> 

This is only one example and our reasoning for it is somewhat convoluted: 
we require thp's max_ptes_none to be 0 rather than the default 
HPAGE_PMD_NR-1 because we don't overcharge anonymous memory that isn't 
used purely for the sake of thp.  This causes all of malloc()'s 
MADV_DONTNEED to force a split of every thp page because the number of 
pte_none()'s > 0.  Instead, it's better to queue these free()'s and 
perhaps recycle them by zeroing out the memory and returning it on a 
subsequent malloc() rather than actually doing the MADV_DONTNEED and 
causing the thp split.  We want to do the split under memory pressure, 
however, and so there's no coordination required other than malloc() 
dropping its queue of freed regions.

> If I'm not mistaken, we're talking about a lot of additional
> complexities throughout the whole mm layer for something which seems,
> to me, achieveable through proper memcg configuration without any
> modification to the kernel and doesn't seem all that necessary for 99%
> of use cases, as you said.  Unless I'm missing something major (quite
> possible, of course), I think you'd need stronger rationale.
> 

The stronger rationale is that you can't handle system oom in userspace 
without this functionality and we need to do so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
