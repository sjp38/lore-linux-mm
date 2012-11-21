Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 44D9D6B002B
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:27:42 -0500 (EST)
Message-ID: <50AC9070.2030009@parallels.com>
Date: Wed, 21 Nov 2012 12:27:28 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
References: <20121107105348.GA25549@lizard> <20121107112136.GA31715@shutemov.name> <CAOJsxLHY+3ZzGuGX=4o1pLfhRqjkKaEMyhX0ejB5nVrDvOWXNA@mail.gmail.com> <20121107114321.GA32265@shutemov.name> <alpine.DEB.2.00.1211141910050.14414@chino.kir.corp.google.com> <20121115033932.GA15546@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211141946370.14414@chino.kir.corp.google.com> <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net> <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com> <20121115085224.GA4635@lizard> <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com> <50A60873.3000607@parallels.com> <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com> <50A6AC48.6080102@parallels.com> <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com> <50AA3FEF.2070100@parallels.com> <alpine.DEB.2.00.1211201013460.4200@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211201013460.4200@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 11/20/2012 10:23 PM, David Rientjes wrote:
> Anton can correct me if I'm wrong, but I certainly don't think this is 
> where mempressure is headed: I don't think any accounting needs to be done 
> and, if it is, it's a design issue that should be addressed now rather 
> than later.  I believe notifications should occur on current's mempressure 
> cgroup depending on its level of reclaim: nobody cares if your memcg has a 
> limit of 64GB when you only have 32GB of RAM, we'll want the notification.

My main concern is that to trigger those notifications, one would have
to first determine whether or not the particular group of tasks is under
pressure. And to do that, we need to somehow know how much memory we are
using, and how much we are reclaiming, etc. On a system-wide level, we
have this information. On a grouplevel, this is already accounted by memcg.

In fact, the current code already seems to rely on memcg:

+	vmpressure(sc->target_mem_cgroup,
+		   sc->nr_scanned - nr_scanned, nr_reclaimed);

Now, let's start simple: Assume we will have a different cgroup.
We want per-group pressure notifications for that group. How would you
determine that the specific group is under pressure?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
