Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 991A66B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 02:50:36 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so6364496pad.26
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 23:50:36 -0800 (PST)
Received: from psmtp.com ([74.125.245.127])
        by mx.google.com with SMTP id z1si13582598pbn.181.2013.11.19.23.50.34
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 23:50:35 -0800 (PST)
Received: by mail-yh0-f49.google.com with SMTP id z20so2539785yhz.22
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 23:50:33 -0800 (PST)
Date: Tue, 19 Nov 2013 23:50:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: user defined OOM policies
In-Reply-To: <20131119131400.GC20655@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1311192341300.20752@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 19 Nov 2013, Michal Hocko wrote:

> Hi,
> it's been quite some time since LSFMM 2013 when this has been
> discussed[1]. In short, it seems that there are usecases with a
> strong demand on a better user/admin policy control for the global
> OOM situations. Per process oom_{adj,score} which is used for the
> prioritizing is no longer sufficient because there are other categories
> which might be important. For example, often it doesn't make sense to
> kill just a part of the workload and killing the whole group would be a
> better fit. I am pretty sure there are many others some of them workload
> specific and thus not appropriate for the generic implementation.
> 

Thanks for starting this thread.  We'd like to have two things:

 - allow userspace to call into our implementation of malloc() to free
   excess memory that will avoid requiring anything from being killed,
   which may include freeing userspace caches back to the kernel or
   using MADV_DONTNEED over a range of unused memory within the arena,
   and

 - enforce a hierarchical memcg prioritization policy so that memcgs can 
   be iterated at each level beneath the oom memcg (which may include the
   root memcg for system oom conditions) and eligible processes are killed 
   in the lowest priority memcg.

This obviously allows for much more powerful implementations as well that 
can be defined by users of memcgs to drop caches, increase memcg limits, 
signaling applications to free unused memory, start throttling memory 
usage, heap analysis, logging, etc. and userspace oom handlers are the 
perfect place to do so.

> We have basically ended up with 3 options AFAIR:
> 	1) allow memcg approach (memcg.oom_control) on the root level
>            for both OOM notification and blocking OOM killer and handle
>            the situation from the userspace same as we can for other
> 	   memcgs.

This is what I've been proposing both with my latest patches, the 
memory.oom_delay_millisecs patch in the past, and future patch to allow 
for per-memcg memory reserves that allow charging to be bypassed to a 
pre-defined threshold much like per-zone memory reserves for TIF_MEMDIE 
processes today so that userspace has access to memory to handle the 
situation even in system oom conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
