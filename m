Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCB66B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:41:25 -0400 (EDT)
Received: by igau2 with SMTP id u2so76410306iga.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:41:25 -0700 (PDT)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id bx19si21312537igb.63.2015.07.08.16.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 16:41:24 -0700 (PDT)
Received: by iebmu5 with SMTP id mu5so165857706ieb.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:41:24 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:41:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] oom: split out forced OOM killer
In-Reply-To: <1436360661-31928-5-git-send-email-mhocko@suse.com>
Message-ID: <alpine.DEB.2.10.1507081638290.16585@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-5-git-send-email-mhocko@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

On Wed, 8 Jul 2015, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.cz>
> 
> The forced OOM killing is currently wired into out_of_memory() call
> even though their objective is different which makes the code ugly
> and harder to follow. Generic out_of_memory path has to deal with
> configuration settings and heuristics which are completely irrelevant
> to the forced OOM killer (e.g. sysctl_oom_kill_allocating_task or
> OOM killer prevention for already dying tasks). All of them are
> either relying on explicit force_kill check or indirectly by checking
> current->mm which is always NULL for sysrq+f. This is not nice, hard
> to follow and error prone.
> 
> Let's pull forced OOM killer code out into a separate function
> (force_out_of_memory) which is really trivial now.
> As a bonus we can clearly state that this is a forced OOM killer
> in the OOM message which is helpful to distinguish it from the
> regular OOM killer.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

It's really absurd that we have to go through this over and over and that 
your patches are actually being merged into -mm just because you don't get 
the point.

We have no need for a force_out_of_memory() function.  None whatsoever.  
Keeping oc->force_kill around is just more pointless space on a very deep 
stack and I'm tired of fixing stack overflows.  I'm certainly not going to 
introduce others because you think it looks cleaner in the code when 
memory compaction does the exact same thing by using cc->order == -1 to 
mean explicit compaction.

This is turning into a complete waste of time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
