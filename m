Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id BDF8590001B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:48:28 -0400 (EDT)
Date: Thu, 13 Jun 2013 15:48:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] memcg: do not sleep on OOM waitqueue with full
 charge context
Message-ID: <20130613134826.GE23070@dhcp22.suse.cz>
References: <20130606173355.GB27226@cmpxchg.org>
 <alpine.DEB.2.02.1306061308320.9493@chino.kir.corp.google.com>
 <20130606215425.GM15721@cmpxchg.org>
 <alpine.DEB.2.02.1306061507330.15503@chino.kir.corp.google.com>
 <20130607000222.GT15576@cmpxchg.org>
 <alpine.DEB.2.02.1306111454030.4803@chino.kir.corp.google.com>
 <20130612082817.GA6706@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306121309500.23348@chino.kir.corp.google.com>
 <20130612203705.GB17282@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306121343500.24902@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306121343500.24902@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 12-06-13 13:49:47, David Rientjes wrote:
> On Wed, 12 Jun 2013, Michal Hocko wrote:
> 
> > The patch is a big improvement with a minimum code overhead. Blocking
> > any task which sits on top of an unpredictable amount of locks is just
> > broken. So regardless how many users are affected we should merge it and
> > backport to stable trees. The problem is there since ever. We seem to
> > be surprisingly lucky to not hit this more often.
> > 
> 
> Right now it appears that that number of users is 0 and we're talking 
> about a problem that was reported in 3.2 that was released a year and a 
> half ago.  The rules of inclusion in stable also prohibit such a change 
> from being backported, specifically "It must fix a real bug that bothers 
> people (not a, "This could be a problem..." type thing)".

As you can see there is an user seeing this in 3.2. The bug is _real_ and
I do not see what you are objecting against. Do you really think that
sitting on a time bomb is preferred more?

> We have deployed memcg on a very large number of machines and I can run a 
> query over all software watchdog timeouts that have occurred by 
> deadlocking on i_mutex during memcg oom.  It returns 0 results.

Do you capture /prc/<pid>/stack for each of them to find that your
deadlock (and you have reported that they happen) was in fact caused by
a locking issue? These kind of deadlocks might got unnoticed especially
when the oom is handled by userspace by increasing the limit (my mmecg
is stuck and increasing the limit a bit always helped).

> > I am not quite sure I understand your reservation about the patch to be
> > honest. Andrew still hasn't merged this one although 1/2 is in.
> 
> Perhaps he is as unconvinced?  The patch adds 100 lines of code, including 
> fields to task_struct for memcg, for a problem that nobody can reproduce.  
> My question still stands: can anybody, even with an instrumented kernel to 
> make it more probable, reproduce the issue this is addressing?

So the referenced discussion is not sufficient?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
