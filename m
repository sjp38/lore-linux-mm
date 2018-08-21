Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0786B1FD3
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:20:04 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b12-v6so12007497plr.17
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 10:20:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y89-v6sor3801620pfk.78.2018.08.21.10.20.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 10:20:03 -0700 (PDT)
Date: Tue, 21 Aug 2018 10:20:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
In-Reply-To: <20180821060952.GU29735@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1808211016400.258924@chino.kir.corp.google.com>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20180806134550.GO19540@dhcp22.suse.cz> <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz> <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com> <20180810090735.GY1644@dhcp22.suse.cz> <alpine.DEB.2.21.1808191632230.193150@chino.kir.corp.google.com> <20180820060746.GB29735@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808201429400.58458@chino.kir.corp.google.com> <20180821060952.GU29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Tue, 21 Aug 2018, Michal Hocko wrote:

> > Ok, so it appears you're suggesting a per-mm counter of oom reaper retries 
> > and once it reaches a certain threshold, either give up and set 
> > MMF_OOM_SKIP or declare that exit_mmap() is responsible for it.  That's 
> > fine, but obviously I'll be suggesting that the threshold is rather large.  
> > So if I adjust my patch to be a retry counter rather than timestamp, do 
> > you have any other reservations?
> 
> It absolutely has to be an internal thing without any user API to be
> set. Also I still haven't heard any specific argument why would oom
> reaper need to do per-task attempt and loop over all victims on the
> list. Maybe you have some examples though.
> 

It would be per-mm in this case, the task itself is no longer important 
other than printing to the kernel log.  I think we could simply print that 
the oom reaper has reaped mm->owner.

The oom reaper would need to loop over the per-mm list because the retry 
counter is going to have a high threshold so that processes have the 
ability to free their memory before the oom reaper declares it can no 
longer make forward progress.  We cannot stall trying to reap a single mm 
with a high retry threshold from a memcg hierarchy when another memcg 
hierarchy is also oom.  The ability for one victim to make forward 
progress can depend on a lock held by another oom memcg hierarchy where 
reaping would allow it to be dropped.
