Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2373E6B234E
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 04:03:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e15-v6so754744pfi.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 01:03:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a4-v6si1173686pff.1.2018.08.22.01.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 01:03:44 -0700 (PDT)
Date: Wed, 22 Aug 2018 10:03:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180822080342.GE29735@dhcp22.suse.cz>
References: <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com>
 <20180810090735.GY1644@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808191632230.193150@chino.kir.corp.google.com>
 <20180820060746.GB29735@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808201429400.58458@chino.kir.corp.google.com>
 <20180821060952.GU29735@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808211016400.258924@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1808211016400.258924@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Tue 21-08-18 10:20:00, David Rientjes wrote:
> On Tue, 21 Aug 2018, Michal Hocko wrote:
> 
> > > Ok, so it appears you're suggesting a per-mm counter of oom reaper retries 
> > > and once it reaches a certain threshold, either give up and set 
> > > MMF_OOM_SKIP or declare that exit_mmap() is responsible for it.  That's 
> > > fine, but obviously I'll be suggesting that the threshold is rather large.  
> > > So if I adjust my patch to be a retry counter rather than timestamp, do 
> > > you have any other reservations?
> > 
> > It absolutely has to be an internal thing without any user API to be
> > set. Also I still haven't heard any specific argument why would oom
> > reaper need to do per-task attempt and loop over all victims on the
> > list. Maybe you have some examples though.
> > 
> 
> It would be per-mm in this case, the task itself is no longer important 
> other than printing to the kernel log.  I think we could simply print that 
> the oom reaper has reaped mm->owner.
> 
> The oom reaper would need to loop over the per-mm list because the retry 
> counter is going to have a high threshold so that processes have the 
> ability to free their memory before the oom reaper declares it can no 
> longer make forward progress.

What do you actually mean by a high threshold?

> We cannot stall trying to reap a single mm 
> with a high retry threshold from a memcg hierarchy when another memcg 
> hierarchy is also oom.  The ability for one victim to make forward 
> progress can depend on a lock held by another oom memcg hierarchy where 
> reaping would allow it to be dropped.

Could you be more specific please?

-- 
Michal Hocko
SUSE Labs
