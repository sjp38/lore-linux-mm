Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 937CE6B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 16:04:38 -0400 (EDT)
Date: Wed, 11 Sep 2013 16:04:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130911200426.GO856@cmpxchg.org>
References: <20130910201222.GA25972@cmpxchg.org>
 <20130910230853.FEEC19B5@pobox.sk>
 <20130910211823.GJ856@cmpxchg.org>
 <20130910233247.9EDF4DBA@pobox.sk>
 <20130910220329.GK856@cmpxchg.org>
 <20130911143305.FFEAD399@pobox.sk>
 <20130911180327.GL856@cmpxchg.org>
 <20130911205448.656D9D7C@pobox.sk>
 <20130911191150.GN856@cmpxchg.org>
 <20130911214118.7CDF2E71@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130911214118.7CDF2E71@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 11, 2013 at 09:41:18PM +0200, azurIt wrote:
> >On Wed, Sep 11, 2013 at 08:54:48PM +0200, azurIt wrote:
> >> >On Wed, Sep 11, 2013 at 02:33:05PM +0200, azurIt wrote:
> >> >> >On Tue, Sep 10, 2013 at 11:32:47PM +0200, azurIt wrote:
> >> >> >> >On Tue, Sep 10, 2013 at 11:08:53PM +0200, azurIt wrote:
> >> >> >> >> >On Tue, Sep 10, 2013 at 09:32:53PM +0200, azurIt wrote:
> >> >> >> >> >> Here is full kernel log between 6:00 and 7:59:
> >> >> >> >> >> http://watchdog.sk/lkml/kern6.log
> >> >> >> >> >
> >> >> >> >> >Wow, your apaches are like the hydra.  Whenever one is OOM killed,
> >> >> >> >> >more show up!
> >> >> >> >> 
> >> >> >> >> 
> >> >> >> >> 
> >> >> >> >> Yeah, it's supposed to do this ;)
> >> >> >
> >> >> >How are you expecting the machine to recover from an OOM situation,
> >> >> >though?  I guess I don't really understand what these machines are
> >> >> >doing.  But if you are overloading them like crazy, isn't that the
> >> >> >expected outcome?
> >> >> 
> >> >> 
> >> >> 
> >> >> 
> >> >> 
> >> >> There's no global OOM, server has enough of memory. OOM is occuring only in cgroups (customers who simply don't want to pay for more memory).
> >> >
> >> >Yes, sure, but when the cgroups are thrashing, they use the disk and
> >> >CPU to the point where the overall system is affected.
> >> 
> >> 
> >> 
> >> 
> >> Didn't know that there is a disk usage because of this, i never noticed anything yet.
> >
> >You said there was heavy IO going on...?
> 
> 
> 
> Yes, there usually was a big IO but it was related to that
> deadlocking bug in kernel (or i assume it was). I never saw a big IO
> in normal conditions even when there were lots of OOM in
> cgroups. I'm even not using swap because of this so i was assuming
> that lacks of memory is not doing any additional IO (or am i
> wrong?). And if you mean that last problem with IO from Monday, i
> don't exactly know what happens but it's really long time when we
> had so big problem with IO that it disables also root login on
> console.

The deadlocking problem should be separate from this.

Even without swap, the binaries and libraries of the running tasks can
get reclaimed (and immediately faulted back from disk, i.e thrashing).

Usually the OOM killer should kick in before tasks cannibalize each
other like that.

The patch you were using did in fact have the side effect of widening
the window between tasks entering heavy reclaim and the OOM killer
kicking in, so it could explain the IO worsening while fixing the dead
lock problem.

That followup patch tries to narrow this window by quite a bit and
tries to stop concurrent reclaim when the group is already OOM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
