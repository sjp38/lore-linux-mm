Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 056F2900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 19:12:30 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so3297141igb.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 16:12:29 -0700 (PDT)
Received: from mail-ig0-x22a.google.com (mail-ig0-x22a.google.com. [2607:f8b0:4001:c05::22a])
        by mx.google.com with ESMTPS id c6si379818igg.0.2015.06.04.16.12.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 16:12:29 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so2856507igb.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 16:12:29 -0700 (PDT)
Date: Thu, 4 Jun 2015 16:12:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: always panic on OOM when panic_on_oom is
 configured
In-Reply-To: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
Message-ID: <alpine.DEB.2.10.1506041607020.16555@chino.kir.corp.google.com>
References: <1433159948-9912-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 1 Jun 2015, Michal Hocko wrote:

> panic_on_oom allows administrator to set OOM policy to panic the system
> when it is out of memory to reduce failover time e.g. when resolving
> the OOM condition would take much more time than rebooting the system.
> 
> out_of_memory tries to be clever and prevent from premature panics
> by checking the current task and prevent from panic when the task
> has fatal signal pending and so it should die shortly and release some
> memory. This is fair enough but Tetsuo Handa has noted that this might
> lead to a silent deadlock when current cannot exit because of
> dependencies invisible to the OOM killer.
> 
> panic_on_oom is disabled by default and if somebody enables it then any
> risk of potential deadlock is certainly unwelcome. The risk is really
> low because there are usually more sources of allocation requests and
> one of them would eventually trigger the panic but it is better to
> reduce the risk as much as possible.
> 
> Let's move check_panic_on_oom up before the current task is
> checked so that the knob value is . Do the same for the memcg in
> mem_cgroup_out_of_memory.
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Nack, this is not the appropriate response to exit path livelocks.  By 
doing this, you are going to start unnecessarily panicking machines that 
have panic_on_oom set when it would not have triggered before.  If there 
is no reclaimable memory and a process that has already been signaled to 
die to is in the process of exiting has to allocate memory, it is 
perfectly acceptable to give them access to memory reserves so they can 
allocate and exit.  Under normal circumstances, that allows the process to 
naturally exit.  With your patch, it will cause the machine to panic.

It's this simple: panic_on_oom is not a solution to workaround oom killer 
livelocks and shouldn't be suggested as the canonical way that such 
possibilities should be addressed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
