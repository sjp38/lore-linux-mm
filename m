Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 63D826B002B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2012 16:50:24 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so421666dad.14
        for <linux-mm@kvack.org>; Wed, 10 Oct 2012 13:50:23 -0700 (PDT)
Date: Wed, 10 Oct 2012 13:50:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] memcg: oom: fix totalpages calculation for
 swappiness==0
In-Reply-To: <20121010141142.GG23011@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.00.1210101346010.31237@chino.kir.corp.google.com>
References: <20121010141142.GG23011@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 10 Oct 2012, Michal Hocko wrote:

> Hi,
> I am sending the patch below as an RFC because I am not entirely happy
> about myself and maybe somebody can come up with a different approach
> which would be less hackish.

I don't see this as hackish, if memory.swappiness limits access to swap 
then this shouldn't be factored into the calculation, and that's what your 
patch fixes.

The reason why the process with the largest rss isn't killed in this case 
is because all processes have CAP_SYS_ADMIN so they get a 3% bonus; when 
factoring swap into the calculation and subtracting 3% from the score in 
oom_badness(), they all end up having an internal score of 1 so they are 
all considered equal.  It appears like the cgroup_iter_next() iteration 
for memcg ooms does this in reverse order, which is actually helpful so it 
will select the task that is newer.

The only suggestion I have to make is specify this is for 
memory.swappiness in the patch title, otherwise:

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
