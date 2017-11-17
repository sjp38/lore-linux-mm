Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D095C6B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 11:46:20 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id p96so1764890wrb.12
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 08:46:20 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m25si2185083edm.209.2017.11.17.08.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 08:46:19 -0800 (PST)
Date: Fri, 17 Nov 2017 16:45:48 +0000
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm/shmem: set default tmpfs size according to memcg limit
Message-ID: <20171117164531.GA23745@castle>
References: <1510888199-5886-1-git-send-email-laoar.shao@gmail.com>
 <CALvZod7AY=J3i0NL-VuWWOxjdVmWh7VnpcQhdx7+Jt-Hnqrk+g@mail.gmail.com>
 <20171117155509.GA920@castle>
 <CALOAHbAWvYKve4eB9+zissgi24cNKeFih1=avfSi_dH5upQVOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALOAHbAWvYKve4eB9+zissgi24cNKeFih1=avfSi_dH5upQVOg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, Tejun Heo <tj@kernel.org>, khlebnikov@yandex-team.ru, mka@chromium.org, Hugh Dickins <hughd@google.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, Nov 18, 2017 at 12:20:40AM +0800, Yafang Shao wrote:
> 2017-11-17 23:55 GMT+08:00 Roman Gushchin <guro@fb.com>:
> > On Thu, Nov 16, 2017 at 08:43:17PM -0800, Shakeel Butt wrote:
> >> On Thu, Nov 16, 2017 at 7:09 PM, Yafang Shao <laoar.shao@gmail.com> wrote:
> >> > Currently the default tmpfs size is totalram_pages / 2 if mount tmpfs
> >> > without "-o size=XXX".
> >> > When we mount tmpfs in a container(i.e. docker), it is also
> >> > totalram_pages / 2 regardless of the memory limit on this container.
> >> > That may easily cause OOM if tmpfs occupied too much memory when swap is
> >> > off.
> >> > So when we mount tmpfs in a memcg, the default size should be limited by
> >> > the memcg memory.limit.
> >> >
> >>
> >> The pages of the tmpfs files are charged to the memcg of allocators
> >> which can be in memcg different from the memcg in which the mount
> >> operation happened. So, tying the size of a tmpfs mount where it was
> >> mounted does not make much sense.
> >
> > Also, memory limit is adjustable,
> 
> Yes. But that's irrelevant.
> 
> > and using a particular limit value
> > at a moment of tmpfs mounting doesn't provide any warranties further.
> >
> 
> I can not agree.
> The default size of tmpfs is totalram / 2, the reason we do this is to
> provide any warranties further IMHO.
> 
> > Is there a reason why the userspace app which is mounting tmpfs can't
> > set the size based on memory.limit?
> 
> That's because of misuse.
> The application should set size with "-o size=" when mount tmpfs, but
> not all applications do this.
> As we can't guarantee that all applications will do this, we should
> give them a proper default value.

The value you're suggesting is proper only if an app which is mounting
tmpfs resides in the same memcg and the memory limit will not be adjusted
significantly later. Otherwise you can end up with a default value, which
is worse than totalram/2, for instance, if tmpfs is mounted by some helper,
which is located in a separate and very limited memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
