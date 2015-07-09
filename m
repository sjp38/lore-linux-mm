Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id CA8D26B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 17:07:39 -0400 (EDT)
Received: by igpy18 with SMTP id y18so5838966igp.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:07:39 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com. [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id ka10si6416202igb.53.2015.07.09.14.07.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 14:07:39 -0700 (PDT)
Received: by iecvh10 with SMTP id vh10so185046149iec.3
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 14:07:39 -0700 (PDT)
Date: Thu, 9 Jul 2015 14:07:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] oom: Do not invoke oom notifiers on sysrq+f
In-Reply-To: <20150709085505.GB13872@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1507091404200.17177@chino.kir.corp.google.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com> <1436360661-31928-3-git-send-email-mhocko@suse.com> <alpine.DEB.2.10.1507081636180.16585@chino.kir.corp.google.com> <20150709085505.GB13872@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 9 Jul 2015, Michal Hocko wrote:

> > Nack, the oom notify list has no place in the oom killer, it should be 
> > called in the page allocator before calling out_of_memory().  
> 
> I cannot say I would like oom notifiers interface. Quite contrary, it is
> just a crude hack. It is living outside of the shrinker interface which is
> what the reclaim is using and it acts like the last attempt before OOM
> (e.g. i915_gem_shrinker_init registers both "shrinkers").

I agree.

> So I am not
> sure it belongs outside of the oom killer proper.
> 

Umm it has nothing to do with oom killing, it quite obviously doesn't 
belong in the oom killer.  It belongs prior to invoking the oom killer if 
memory could be freed.

> Besides that out_of_memory already contains shortcuts to prevent killing
> a task. Why is this any different? I mean why shouldn't callers of
> out_of_memory check whether the task is killed or existing before
> calling out_of_memory?
> 

Because the oom killer is for oom killing and the most vital part of oom 
killing is the granting of memory reserves, otherwise no forward progress 
can be made.

The line between "out of memory" and "not out of memory" is quite clear 
and logic that handles "out of memory" situations belongs in the oom 
killer and logic that handles "not out of memory" situations belongs in 
the page allocator.  This shouldn't be surprising whatsoever, but if you 
insist me moving the code to where it belongs, I will.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
