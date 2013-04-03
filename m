Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 4D0AF6B00F3
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 08:35:06 -0400 (EDT)
Date: Wed, 3 Apr 2013 08:34:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, memcg: give exiting processes access to memory
 reserves
Message-ID: <20130403123452.GK1953@cmpxchg.org>
References: <alpine.DEB.2.02.1303271821120.5005@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303271821120.5005@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 27, 2013 at 06:22:10PM -0700, David Rientjes wrote:
> A memcg may livelock when oom if the process that grabs the hierarchy's
> oom lock is never the first process with PF_EXITING set in the memcg's
> task iteration.
> 
> The oom killer, both global and memcg, will defer if it finds an eligible
> process that is in the process of exiting and it is not being ptraced.
> The idea is to allow it to exit without using memory reserves before
> needlessly killing another process.
> 
> This normally works fine except in the memcg case with a large number of
> threads attached to the oom memcg.  In this case, the memcg oom killer
> only gets called for the process that grabs the hierarchy's oom lock; all
> others end up blocked on the memcg's oom waitqueue.  Thus, if the process
> that grabs the hierarchy's oom lock is never the first PF_EXITING process
> in the memcg's task iteration, the oom killer is constantly deferred
> without anything making progress.
> 
> The fix is to give PF_EXITING processes access to memory reserves so that
> we've marked them as oom killed without any iteration.  This allows
> __mem_cgroup_try_charge() to succeed so that the process may exit.  This
> makes the memcg oom killer exemption for TIF_MEMDIE tasks, now
> immediately granted for processes with pending SIGKILLs and those in the
> exit path, to be equivalent to what is done for the global oom killer.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
