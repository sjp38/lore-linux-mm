Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8CB6B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:40:16 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so5210959pbb.5
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:40:15 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id xf3si20032116pab.15.2014.04.22.11.40.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 11:40:14 -0700 (PDT)
Date: Tue, 22 Apr 2014 14:39:43 -0400
From: Dwight Engen <dwight.engen@oracle.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
Message-ID: <20140422143943.20609800@oracle.com>
In-Reply-To: <20140420142830.GC22077@alpha.arachsys.com>
References: <20140416154650.GA3034@alpha.arachsys.com>
	<20140418155939.GE4523@dhcp22.suse.cz>
	<5351679F.5040908@parallels.com>
	<20140420142830.GC22077@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Max Kellermann <mk@cm4all.com>, Johannes Weiner <hannes@cmpxchg.org>, William Dauchy <wdauchy@gmail.com>, Tim Hockin <thockin@hockin.org>, Michal Hocko <mhocko@suse.cz>, Daniel Walsh <dwalsh@redhat.com>, Daniel Berrange <berrange@redhat.com>, cgroups@vger.kernel.org, containers@lists.linux-foundation.org, linux-mm@kvack.org

On Sun, 20 Apr 2014 15:28:30 +0100
Richard Davies <richard@arachsys.com> wrote:

> Vladimir Davydov wrote:
> > Richard Davies wrote:
> > > I have a simple reproducible test case in which untar in a memcg
> > > with a kmem limit gets into trouble during heavy disk i/o (on
> > > ext3) and never properly recovers. This is simplified from real
> > > world problems with heavy disk i/o inside containers.
> >
> > Unfortunately, work on per cgroup kmem limits is not completed yet.
> > Currently it lacks kmem reclaim on per cgroup memory pressure,
> > which is vital for using kmem limits in real life.
> ...
> > In short, kmem limiting for memory cgroups is currently broken. Do
> > not use it. We are working on making it usable though.
> 
> Thanks for explaining the strange errors I got.
> 
> 
> My motivation is to prevent a fork bomb in a container from affecting
> other processes outside that container.
> 
> kmem limits were the preferred mechanism in several previous
> discussions about two years ago (I'm copying in participants from
> those previous discussions and give links below). So I tried kmem
> first but found bugs.
> 
> 
> What is the best mechanism available today, until kmem limits mature?
> 
> RLIMIT_NPROC exists but is per-user, not per-container.
> 
> Perhaps there is an up-to-date task counter patchset or similar?

I updated Frederic's task counter patches and included Max Kellermann's
fork limiter here:

http://thread.gmane.org/gmane.linux.kernel.containers/27212

I can send you a more recent patchset (against 3.13.10) if you would
find it useful.

> Thank you all,
> 
> Richard.
> 
> 
> 
> Some references to previous discussions:
> 
> Fork bomb limitation in memcg WAS: Re: [PATCH 00/11] kmem controller
> for memcg: stripped down version
> http://thread.gmane.org/gmane.linux.kernel/1318266/focus=1319372
> 
> Re: [PATCH 00/10] cgroups: Task counter subsystem v8
> http://thread.gmane.org/gmane.linux.kernel/1246704/focus=1467310
> 
> [RFD] Merge task counter into memcg
> http://thread.gmane.org/gmane.linux.kernel/1280302
> 
> Re: [PATCH -mm] cgroup: Fix task counter common ancestor logic
> http://thread.gmane.org/gmane.linux.kernel/1212650/focus=1220186
> 
> [PATCH] new cgroup controller "fork"
> http://thread.gmane.org/gmane.linux.kernel/1210878
> 
> Re: Process Limit cgroups
> http://thread.gmane.org/gmane.linux.kernel.cgroups/9368/focus=9369
> 
> Re: [lxc-devel] process number limit
> https://www.mail-archive.com/lxc-devel@lists.sourceforge.net/msg03309.html
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
