Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A3AD66B0038
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 10:08:57 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so1797047pad.7
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:08:57 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ds16si1352384pdb.90.2014.07.23.07.08.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jul 2014 07:08:56 -0700 (PDT)
Date: Wed, 23 Jul 2014 18:08:37 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC 0/5] Virtual Memory Resource Controller for cgroups
Message-ID: <20140723140837.GE30850@esperanza>
References: <cover.1404383187.git.vdavydov@parallels.com>
 <20140704121621.GE12466@dhcp22.suse.cz>
 <20140704153853.GA369@esperanza>
 <20140716120146.GI7121@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140716120146.GI7121@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, Jul 16, 2014 at 02:01:47PM +0200, Michal Hocko wrote:
> On Fri 04-07-14 19:38:53, Vladimir Davydov wrote:
> > Considering the example I've given above, both of these won't help if
> > the system has other active CTs: the container will be forcefully kept
> > around its high/low limit and, since it's definitely not enough for it,
> > it will be finally killed crossing out the computations it's spent so
> > much time on. High limit won't be good for the container even if there's
> > no other load on the node - it will be constantly swapping out anon
> > memory and evicting file caches. The application won't die quickly then,
> > but it will get a heavy slowdown, which is no better than killing I
> > guess.
> 
> It will get vmpressure notifications though and can help to release
> excessive buffers which were allocated optimistically.

But the user will only get the notification *after* his application has
touched the memory within the limit, which may take quite a long time.

> > Also, I guess it'd be beneficial to have
> > 
> >  - mlocked pages accounting per cgroup, because they affect memory
> >    reclaim, and how low/high limits work, so it'd be nice to have them
> >    limited to a sane value;
> > 
> >  - shmem areas accounting per cgroup, because the total amount of shmem
> >    on the system is limited, and it'll be no good if malicious
> >    containers eat it all.
> > 
> > IMO It wouldn't be a good idea to overwhelm memcg with those limits, the
> > VM controller suits much better.
> 
> yeah, I do not think adding more to memcg is a good idea. I am still not
> sure whether working around bad design decisions in applications is a
> good rationale for a new controller.

Where do you see "bad design decision" in the example I've given above?
To recap, the user doesn't know how much memory his application is going
to consume and he wants to be notified about a potential failure as soon
as possible instead of waiting until it touches all the memory within
the container limit.

Also, what's wrong if an application wants to eat a lot of shared
memory, which is a limited resource? Suppose the user sets memsw.limit
for his container to half of RAM hoping it's isolated and won't cause
any troubles, but eventually he finds other workloads failing on the
host due to the processes inside it has eaten all available shmem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
