Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B38D08D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 04:18:58 -0400 (EDT)
Date: Wed, 30 Mar 2011 10:18:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-ID: <20110330081853.GC15394@tiehlicka.suse.cz>
References: <20110328093957.089007035@suse.cz>
 <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
 <4D920066.7000609@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D920066.7000609@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 29-03-11 21:23:10, Balbir Singh wrote:
> On 03/28/11 16:33, KAMEZAWA Hiroyuki wrote:
> > On Mon, 28 Mar 2011 11:39:57 +0200
> > Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > Isn't it the same result with the case where no cgroup is used ?
> > What is the problem ?
> > Why it's not a problem of configuration ?
> > IIUC, you can put all logins to some cgroup by using cgroupd/libgcgroup.
> > 
> 
> I agree with Kame, I am still at loss in terms of understand the use
> case, I should probably see the rest of the patches

OK, it looks that I am really bad at explaining the usecase. Let's try
it again then (hopefully in a better way).

Consider a service which serves requests based on the in-memory
precomputed or preprocessed data. 
Let's assume that getting data into memory is rather costly operation
which considerably increases latency of the request processing. Memory
access can be considered random from the system POV because we never
know which requests will come from outside.
This workflow will benefit from having the memory resident as long as
and as much as possible because we have higher chances to be used more
often and so the initial costs would pay off.
Why is mlock not the right thing to do here? Well, if the memory would
be locked and the working set would grow (again this depends on the
incoming requests) then the application would have to unlock some
portions of the memory or to risk OOM because it basically cannot
overcommit.
On the other hand, if the memory is not mlocked and there is a global
memory pressure we can have some part of the costly memory swapped or
paged out which will increase requests latencies. If the application is
placed into an isolated cgroup, though, the global (or other cgroups)
activity doesn't influence its cgroup thus the working set of the
application.
If we compare that to mlock we will benefit from per-group reclaim when
we get over the limit (or soft limit). So we do not start evicting the
memory unless somebody makes really pressure on the _application_.
Cgroup limits would, of course, need to be selected carefully.

There might be other examples when simply kernel cannot know which
memory is important for the process and the long unused memory is not
the ideal choice.

Makes sense?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
