Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id A9D7F6B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 09:26:17 -0400 (EDT)
Date: Wed, 19 Jun 2013 15:26:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2] memcg: do not trap chargers with full callstack
 on OOM
Message-ID: <20130619132614.GC16457@dhcp22.suse.cz>
References: <20130208171012.GH7557@dhcp22.suse.cz>
 <20130208220243.EDEE0825@pobox.sk>
 <20130210150310.GA9504@dhcp22.suse.cz>
 <20130210174619.24F20488@pobox.sk>
 <20130211112240.GC19922@dhcp22.suse.cz>
 <20130222092332.4001E4B6@pobox.sk>
 <20130606160446.GE24115@dhcp22.suse.cz>
 <20130606181633.BCC3E02E@pobox.sk>
 <20130607131157.GF8117@dhcp22.suse.cz>
 <20130617122134.2E072BA8@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617122134.2E072BA8@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 17-06-13 12:21:34, azurIt wrote:
> >Here we go. I hope I didn't screw anything (Johannes might double check)
> >because there were quite some changes in the area since 3.2. Nothing
> >earth shattering though. Please note that I have only compile tested
> >this. Also make sure you remove the previous patches you have from me.
> 
> 
> Hi Michal,
> 
> it, unfortunately, didn't work. Everything was working fine but
> original problem is still occuring. 

This would be more than surprising because tasks blocked at memcg OOM
don't hold any locks anymore. Maybe I have messed something up during
backport but I cannot spot anything.

> I'm unable to send you stacks or more info because problem is taking
> down the whole server for some time now (don't know what exactly
> caused it to start happening, maybe newer versions of 3.2.x).

So you are not testing with the same kernel with just the old patch
replaced by the new one?

> But i'm sure of one thing - when problem occurs, nothing is able to
> access hard drives (every process which tries it is freezed until
> problem is resolved or server is rebooted).

I would be really interesting to see what those tasks are blocked on.

> Problem is fixed after killing processes from cgroup which
> caused it and everything immediatelly starts to work normally. I
> find this out by keeping terminal opened from another server to one
> where my problem is occuring quite often and running several apps
> there (htop, iotop, etc.). When problem occurs, all apps which wasn't
> working with HDD was ok. The htop proved to be very usefull here
> because it's only reading proc filesystem and is also able to send
> KILL signals - i was able to resolve the problem with it
>   without rebooting the server.

sysrq+t will give you the list of all tasks and their traces.

> I created a special daemon (about month ago) which is able to detect
> and fix the problem so i'm not having server outages now. The point
> was to NOT access anything which is stored on HDDs, the daemon is
> only reading info from cgroup filesystem and sending KILL signals to
> processes. Maybe i should be able to also read stack files before
> killing, i will try it.
> 
> Btw, which vanilla kernel includes this patch?

None yet. But I hope it will be merged to 3.11 and backported to the
stable trees.
 
> Thank you and everyone involved very much for time and help.
> 
> azur

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
