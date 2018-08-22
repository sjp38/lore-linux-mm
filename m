Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 10CE96B264F
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 16:54:54 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d40-v6so1423761pla.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 13:54:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s13-v6sor870177plr.147.2018.08.22.13.54.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 13:54:52 -0700 (PDT)
Date: Wed, 22 Aug 2018 13:54:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
In-Reply-To: <20180822080342.GE29735@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1808221348160.83182@chino.kir.corp.google.com>
References: <20180806134550.GO19540@dhcp22.suse.cz> <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com> <20180806205121.GM10003@dhcp22.suse.cz> <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com> <20180810090735.GY1644@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808191632230.193150@chino.kir.corp.google.com> <20180820060746.GB29735@dhcp22.suse.cz> <alpine.DEB.2.21.1808201429400.58458@chino.kir.corp.google.com> <20180821060952.GU29735@dhcp22.suse.cz> <alpine.DEB.2.21.1808211016400.258924@chino.kir.corp.google.com>
 <20180822080342.GE29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Wed, 22 Aug 2018, Michal Hocko wrote:

> > > > Ok, so it appears you're suggesting a per-mm counter of oom reaper retries 
> > > > and once it reaches a certain threshold, either give up and set 
> > > > MMF_OOM_SKIP or declare that exit_mmap() is responsible for it.  That's 
> > > > fine, but obviously I'll be suggesting that the threshold is rather large.  
> > > > So if I adjust my patch to be a retry counter rather than timestamp, do 
> > > > you have any other reservations?
> > > 
> > > It absolutely has to be an internal thing without any user API to be
> > > set. Also I still haven't heard any specific argument why would oom
> > > reaper need to do per-task attempt and loop over all victims on the
> > > list. Maybe you have some examples though.
> > > 
> > 
> > It would be per-mm in this case, the task itself is no longer important 
> > other than printing to the kernel log.  I think we could simply print that 
> > the oom reaper has reaped mm->owner.
> > 
> > The oom reaper would need to loop over the per-mm list because the retry 
> > counter is going to have a high threshold so that processes have the 
> > ability to free their memory before the oom reaper declares it can no 
> > longer make forward progress.
> 
> What do you actually mean by a high threshold?
> 

As suggested in the timeout based approach of my patchset, 10s seems to 
work well for current server memory capacities, so if combined with a 
schedule_timeout(HZ/10) after iterating through mm_struct's to reap, the 
threshold would be best defined so it can allow at least 10s.

> > We cannot stall trying to reap a single mm 
> > with a high retry threshold from a memcg hierarchy when another memcg 
> > hierarchy is also oom.  The ability for one victim to make forward 
> > progress can depend on a lock held by another oom memcg hierarchy where 
> > reaping would allow it to be dropped.
> 
> Could you be more specific please?
> 

It's problematic to stall for 10s trying to oom reap (or free through 
exit_mmap()) a single mm while not trying to free memory from others: if 
you are reaping memory from a memcg subtree's victim and it takes a long 
time, either for a single try with a lot of memory or many tries with 
little or no memory, it increases the likelihood of livelocks in other 
memcg hierarchies because of the oom reaper is not attempting to reap its 
memory.  The victim may depend on a lock that a memory charger is holding 
but the oom reaper is not able to help yet.
