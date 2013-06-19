Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 939466B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 17:31:02 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so5504006pbb.19
        for <linux-mm@kvack.org>; Wed, 19 Jun 2013 14:31:01 -0700 (PDT)
Date: Wed, 19 Jun 2013 14:30:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: add oom killer delay
In-Reply-To: <alpine.DEB.2.02.1306140254590.8780@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1306191429340.13015@chino.kir.corp.google.com>
References: <20130603193147.GC23659@dhcp22.suse.cz> <alpine.DEB.2.02.1306031411380.22083@chino.kir.corp.google.com> <20130604095514.GC31242@dhcp22.suse.cz> <alpine.DEB.2.02.1306042329320.20610@chino.kir.corp.google.com> <20130605093937.GK15997@dhcp22.suse.cz>
 <alpine.DEB.2.02.1306051657001.29626@chino.kir.corp.google.com> <20130610142321.GE5138@dhcp22.suse.cz> <alpine.DEB.2.02.1306111321360.32688@chino.kir.corp.google.com> <20130612202348.GA17282@dhcp22.suse.cz> <alpine.DEB.2.02.1306121408490.24902@chino.kir.corp.google.com>
 <20130613151602.GG23070@dhcp22.suse.cz> <alpine.DEB.2.02.1306131508300.8686@chino.kir.corp.google.com> <51BA6A2A.3060107@jp.fujitsu.com> <alpine.DEB.2.02.1306140254590.8780@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri, 14 Jun 2013, David Rientjes wrote:

> Even with all of the above (which is not actually that invasive of a 
> patch), I still think we need memory.oom_delay_millisecs.  I probably made 
> a mistake in describing what that is addressing if it seems like it's 
> trying to address any of the above.
> 
> If a userspace oom handler fails to respond even with access to those 
> "memcg reserves", the kernel needs to kill within that memcg.  Do we do 
> that above a set time period (this patch) or when the reserves are 
> completely exhausted?  That's debatable, but if we are to allow it for 
> global oom conditions as well then my opinion was to make it as safe as 
> possible; today, we can't disable the global oom killer from userspace and 
> I don't think we should ever allow it to be disabled.  I think we should 
> allow userspace a reasonable amount of time to respond and then kill if it 
> is exceeded.
> 
> For the global oom case, we want to have a priority-based memcg selection.  
> Select the lowest priority top-level memcg and kill within it.  If it has 
> an oom notifier, send it a signal to kill something.  If it fails to 
> react, kill something after memory.oom_delay_millisecs has elapsed.  If 
> there isn't a userspace oom notifier, kill something within that lowest 
> priority memcg.
> 
> The bottomline with my approach is that I don't believe there is ever a 
> reason for an oom memcg to remain oom indefinitely.  That's why I hate 
> memory.oom_control == 1 and I think for the global notification it would 
> be deemed a nonstarter since you couldn't even login to the machine.
> 

What's the status of this patch?  I'd love to be able to introduce memcg 
reserves so that userspace oom notifications can actually work, but we 
still require a failsafe in the kernel if those reserves are depleted or 
userspace cannot respond.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
