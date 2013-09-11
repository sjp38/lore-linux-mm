Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 74F246B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 15:12:03 -0400 (EDT)
Date: Wed, 11 Sep 2013 15:11:50 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130911191150.GN856@cmpxchg.org>
References: <20130910183740.GI856@cmpxchg.org>
 <20130910213253.A1E666C5@pobox.sk>
 <20130910201222.GA25972@cmpxchg.org>
 <20130910230853.FEEC19B5@pobox.sk>
 <20130910211823.GJ856@cmpxchg.org>
 <20130910233247.9EDF4DBA@pobox.sk>
 <20130910220329.GK856@cmpxchg.org>
 <20130911143305.FFEAD399@pobox.sk>
 <20130911180327.GL856@cmpxchg.org>
 <20130911205448.656D9D7C@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130911205448.656D9D7C@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 11, 2013 at 08:54:48PM +0200, azurIt wrote:
> >On Wed, Sep 11, 2013 at 02:33:05PM +0200, azurIt wrote:
> >> >On Tue, Sep 10, 2013 at 11:32:47PM +0200, azurIt wrote:
> >> >> >On Tue, Sep 10, 2013 at 11:08:53PM +0200, azurIt wrote:
> >> >> >> >On Tue, Sep 10, 2013 at 09:32:53PM +0200, azurIt wrote:
> >> >> >> >> Here is full kernel log between 6:00 and 7:59:
> >> >> >> >> http://watchdog.sk/lkml/kern6.log
> >> >> >> >
> >> >> >> >Wow, your apaches are like the hydra.  Whenever one is OOM killed,
> >> >> >> >more show up!
> >> >> >> 
> >> >> >> 
> >> >> >> 
> >> >> >> Yeah, it's supposed to do this ;)
> >> >
> >> >How are you expecting the machine to recover from an OOM situation,
> >> >though?  I guess I don't really understand what these machines are
> >> >doing.  But if you are overloading them like crazy, isn't that the
> >> >expected outcome?
> >> 
> >> 
> >> 
> >> 
> >> 
> >> There's no global OOM, server has enough of memory. OOM is occuring only in cgroups (customers who simply don't want to pay for more memory).
> >
> >Yes, sure, but when the cgroups are thrashing, they use the disk and
> >CPU to the point where the overall system is affected.
> 
> 
> 
> 
> Didn't know that there is a disk usage because of this, i never noticed anything yet.

You said there was heavy IO going on...?

> >Okay, my suspicion is that the previous patches invoked the OOM killer
> >right away, whereas in this latest version it's invoked only when the
> >fault is finished.  Maybe the task that locked the group gets held up
> >somewhere else and then it takes too long until something is actually
> >killed.  Meanwhile, every other allocator drops into 5 reclaim cycles
> >before giving up, which could explain the thrashing.  And on the memcg
> >level we don't have BDI congestion sleeps like on the global level, so
> >everybody is backing off from the disk.
> >
> >Here is an incremental fix to the latest version, i.e. the one that
> >livelocked under heavy IO, not the one you are using right now.
> >
> >First, it reduces the reclaim retries from 5 to 2, which resembles the
> >global kswapd + ttfp somewhat.  Next, NOFS/NORETRY allocators are not
> >allowed to kick off the OOM killer, like in the global case, so that
> >we don't kill things and give up just because light reclaim can't free
> >anything.  Last, the memcg is marked under OOM when one task enters
> >OOM so that not everybody is livelocking in reclaim in a hopeless
> >situation.
> 
> 
> 
> Thank you i will boot it this night. I also created a new server load checking and recuing script so i hope i won't be forced to hard reboot the server in case something similar as before happens. Btw, patch didn't apply to 3.2.51, there were probably big changes in memory system (almost all hunks failed). I used 3.2.50 as before.

Yes, please don't change the test base in the middle of this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
