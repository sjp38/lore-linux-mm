Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 25D156B1B30
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 17:31:08 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r85-v6so1909808pgr.16
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 14:31:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17-v6sor2690088pgi.295.2018.08.20.14.31.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 14:31:06 -0700 (PDT)
Date: Mon, 20 Aug 2018 14:31:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
In-Reply-To: <20180820060746.GB29735@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1808201429400.58458@chino.kir.corp.google.com>
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20180806134550.GO19540@dhcp22.suse.cz> <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz> <alpine.DEB.2.21.1808091311030.244858@chino.kir.corp.google.com> <20180810090735.GY1644@dhcp22.suse.cz> <alpine.DEB.2.21.1808191632230.193150@chino.kir.corp.google.com> <20180820060746.GB29735@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On Mon, 20 Aug 2018, Michal Hocko wrote:

> > The oom reaper will always be unable to free some memory, such as page 
> > tables.  If it can't grab mm->mmap_sem in a reasonable amount of time, it 
> > also can give up early.  The munlock() case is another example.  We 
> > experience unnecessary oom killing during free_pgtables() where the 
> > single-threaded exit_mmap() is freeing an enormous amount of page tables 
> > (usually a malloc implementation such as tcmalloc that does not free 
> > virtual memory) and other processes are faulting faster than we can free.  
> > It's a combination of a multiprocessor system and a lot of virtual memory 
> > from the original victim.  This is the same case as being unable to 
> > munlock quickly enough in exit_mmap() to free the memory.
> > 
> > We must wait until free_pgtables() completes in exit_mmap() before killing 
> > additional processes in the large majority (99.96% of cases from my data) 
> > of instances where oom livelock does not occur.  In the remainder of 
> > situations, livelock has been prevented by what the oom reaper has been 
> > able to free.  We can, of course, not do free_pgtables() from the oom 
> > reaper.  So my approach was to allow for a reasonable amount of time for 
> > the victim to free a lot of memory before declaring that additional 
> > processes must be oom killed.  It would be functionally similar to having 
> > the oom reaper retry many, many more times than 10 and having a linked 
> > list of mm_structs to reap.  I don't care one way or another if it's a 
> > timeout based solution or many, many retries that have schedule_timeout() 
> > that yields the same time period in the end.
> 
> I would really keep the current retry logic with an extension to allow
> to keep retrying or hand over to exit_mmap when we know it is past the
> last moment of blocking.
> 

Ok, so it appears you're suggesting a per-mm counter of oom reaper retries 
and once it reaches a certain threshold, either give up and set 
MMF_OOM_SKIP or declare that exit_mmap() is responsible for it.  That's 
fine, but obviously I'll be suggesting that the threshold is rather large.  
So if I adjust my patch to be a retry counter rather than timestamp, do 
you have any other reservations?
