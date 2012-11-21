Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 34A0D6B0085
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 03:49:16 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so5286075pbc.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 00:49:15 -0800 (PST)
Date: Wed, 21 Nov 2012 00:46:03 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Message-ID: <20121121084603.GA18159@lizard>
References: <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard>
 <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com>
 <50A60873.3000607@parallels.com>
 <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com>
 <50A6AC48.6080102@parallels.com>
 <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com>
 <50AA3FEF.2070100@parallels.com>
 <alpine.DEB.2.00.1211201013460.4200@chino.kir.corp.google.com>
 <50AC9070.2030009@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <50AC9070.2030009@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Wed, Nov 21, 2012 at 12:27:28PM +0400, Glauber Costa wrote:
> On 11/20/2012 10:23 PM, David Rientjes wrote:
> > Anton can correct me if I'm wrong, but I certainly don't think this is 
> > where mempressure is headed: I don't think any accounting needs to be done

Yup, I'd rather not do any accounting, at least not in bytes.

> > and, if it is, it's a design issue that should be addressed now rather 
> > than later.  I believe notifications should occur on current's mempressure 
> > cgroup depending on its level of reclaim: nobody cares if your memcg has a 
> > limit of 64GB when you only have 32GB of RAM, we'll want the notification.
> 
> My main concern is that to trigger those notifications, one would have
> to first determine whether or not the particular group of tasks is under
> pressure.

As far as I understand, the notifications will be triggered by a process
that tries to allocate memory. So, effectively that would be a per-process
pressure.

So, if one process in a group is suffering, we notify that "a process in a
group is under pressure", and the notification goes to a cgroup listener

> And to do that, we need to somehow know how much memory we are
> using, and how much we are reclaiming, etc. On a system-wide level, we
> have this information. On a grouplevel, this is already accounted by memcg.
> 
> In fact, the current code already seems to rely on memcg:
> 
> +	vmpressure(sc->target_mem_cgroup,
> +		   sc->nr_scanned - nr_scanned, nr_reclaimed);

Well, I'm yet unsure about the details, but I guess in "mempressure"
cgroup approach, this will be derived from the current->, i.e. a task.

But note that we won't report pressure to a memcg cgroup, we will notify
only mempressure cgroup. But a process can be in both of them
simultaneously. In the code, the mempressure and memcg will not depend on
each other.

> Now, let's start simple: Assume we will have a different cgroup.
> We want per-group pressure notifications for that group. How would you
> determine that the specific group is under pressure?

If a process that tries to allocate memory & causes reclaim is a part of
the cgroup, then cgroup has a pressure.

At least that's very brief understanding of the idea, details to be
investigated... But I welcome David to comment whether I got everything
correctly. :)

Thanks,
Anton.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
