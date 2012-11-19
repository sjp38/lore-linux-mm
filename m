Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id C28A76B0082
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 09:19:43 -0500 (EST)
Message-ID: <50AA3FEF.2070100@parallels.com>
Date: Mon, 19 Nov 2012 18:19:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name> <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com> <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com> <20121115085224.GA4635@lizard> <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com> <50A60873.3000607@parallels.com> <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com> <50A6AC48.6080102@parallels.com> <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>


>>> Umm, why do users of cpusets not want to be able to trigger memory 
>>> pressure notifications?
>>>
>> Because cpusets only deal with memory placement, not memory usage.
> 
> The set of nodes that a thread is allowed to allocate from may face memory 
> pressure up to and including oom while the rest of the system may have a 
> ton of free memory.  Your solution is to compile and mount memcg if you 
> want notifications of memory pressure on those nodes.  Others in this 
> thread have already said they don't want to rely on memcg for any of this 
> and, as Anton showed, this can be tied directly into the VM without any 
> help from memcg as it sits today.  So why implement a simple and clean 
> mempressure cgroup that can be used alone or co-existing with either memcg 
> or cpusets?
> 

Forgot this one:

Because there is a huge ongoing work going on by Tejun aiming at
reducing the effects of orthogonal hierarchy. There are many controllers
today that are "close enough" to each other (cpu, cpuacct; net_prio,
net_cls), and in practice, it brought more problems than it solved.

So yes, *maybe* mempressure is the answer, but it need to be justified
with care. Long term, I think a saner notification API for memcg will
lead us to a better and brighter future.

There is also yet another aspect: This scheme works well for global
notifications. If we would always want this to be global, this would
work neatly. But as already mentioned in this thread, at some point
we'll want this to work for a group of processes as well. At that point,
you'll have to count how much memory is being used, so you can determine
whether or not pressure is going on. You will, then, have to redo all
the work memcg already does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
