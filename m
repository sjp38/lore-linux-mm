Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 76F276B0071
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:23:15 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so392250pad.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 10:23:14 -0800 (PST)
Date: Tue, 20 Nov 2012 10:23:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
In-Reply-To: <50AA3FEF.2070100@parallels.com>
Message-ID: <alpine.DEB.2.00.1211201013460.4200@chino.kir.corp.google.com>
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name> <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com>
 <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard> <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com> <50A60873.3000607@parallels.com> <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com> <50A6AC48.6080102@parallels.com>
 <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com> <50AA3FEF.2070100@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Mon, 19 Nov 2012, Glauber Costa wrote:

> >> Because cpusets only deal with memory placement, not memory usage.
> > 
> > The set of nodes that a thread is allowed to allocate from may face memory 
> > pressure up to and including oom while the rest of the system may have a 
> > ton of free memory.  Your solution is to compile and mount memcg if you 
> > want notifications of memory pressure on those nodes.  Others in this 
> > thread have already said they don't want to rely on memcg for any of this 
> > and, as Anton showed, this can be tied directly into the VM without any 
> > help from memcg as it sits today.  So why implement a simple and clean 
> > mempressure cgroup that can be used alone or co-existing with either memcg 
> > or cpusets?
> > 
> 
> Forgot this one:
> 
> Because there is a huge ongoing work going on by Tejun aiming at
> reducing the effects of orthogonal hierarchy. There are many controllers
> today that are "close enough" to each other (cpu, cpuacct; net_prio,
> net_cls), and in practice, it brought more problems than it solved.
> 

I'm very happy that Tejun is working on that, but I don't see how it's 
relevant here: I'm referring to users who are not using memcg 
specifically.  This is what others brought up earlier in the thread: they 
do not want to be required to use memcg for this functionality.

There are users of cpusets today that do not enable nor comount memcg.  I 
argue that a mempressure cgroup allows them this functionality without the 
memory footprint of memcg (not only in text, but requiring page_cgroup).  
Additionally, there are probably users who do not want either cpusets or 
memcg and want notifications from mempressure at a global level.  Users 
who care so much about the memory pressure of their systems probably have 
strict footprint requirements, it would be a complete shame to require a 
semi-tractor trailer when all I want is a compact car.

> So yes, *maybe* mempressure is the answer, but it need to be justified
> with care. Long term, I think a saner notification API for memcg will
> lead us to a better and brighter future.
> 

You can easily comount mempressure with your memcg, this is not anything 
new.

> There is also yet another aspect: This scheme works well for global
> notifications. If we would always want this to be global, this would
> work neatly. But as already mentioned in this thread, at some point
> we'll want this to work for a group of processes as well. At that point,
> you'll have to count how much memory is being used, so you can determine
> whether or not pressure is going on. You will, then, have to redo all
> the work memcg already does.
> 

Anton can correct me if I'm wrong, but I certainly don't think this is 
where mempressure is headed: I don't think any accounting needs to be done 
and, if it is, it's a design issue that should be addressed now rather 
than later.  I believe notifications should occur on current's mempressure 
cgroup depending on its level of reclaim: nobody cares if your memcg has a 
limit of 64GB when you only have 32GB of RAM, we'll want the notification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
