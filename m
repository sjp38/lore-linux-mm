Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 490AE6B0038
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 14:15:52 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id gt1so2814884wjc.0
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 11:15:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o28si13970099wra.69.2017.02.09.11.15.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 11:15:50 -0800 (PST)
Date: Thu, 9 Feb 2017 20:15:47 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170209191547.GA31906@dhcp22.suse.cz>
References: <20170208152106.GP5686@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org>
 <alpine.DEB.2.20.1702081838560.3536@nanos>
 <alpine.DEB.2.20.1702082109530.13608@east.gentwo.org>
 <alpine.DEB.2.20.1702091240000.3604@nanos>
 <alpine.DEB.2.20.1702090759370.22559@east.gentwo.org>
 <alpine.DEB.2.20.1702091548300.3604@nanos>
 <alpine.DEB.2.20.1702090940190.23960@east.gentwo.org>
 <alpine.DEB.2.20.1702091708270.3604@nanos>
 <alpine.DEB.2.20.1702091048330.24346@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1702091048330.24346@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu 09-02-17 11:22:49, Cristopher Lameter wrote:
> On Thu, 9 Feb 2017, Thomas Gleixner wrote:
> 
> > You are just not getting it, really.
> >
> > The problem is that this for_each_online_cpu() is racy against a concurrent
> > hot unplug and therefor can queue stuff for a not longer online cpu. That's
> > what the mm folks tried to avoid by preventing a CPU hotplug operation
> > before entering that loop.
> 
> With a stop machine action it is NOT racy because the machine goes into a
> special kernel state that guarantees that key operating system structures
> are not touched. See mm/page_alloc.c's use of that characteristic to build
> zonelists. Thus it cannot be executing for_each_online_cpu and related
> tasks (unless one does not disable preempt .... but that is a given if a
> spinlock has been taken)..

Christoph, you are completely ignoring the reality and the code. There
is no need for stop_machine nor it is helping anything. As the matter
of fact there is a synchronization with the cpu hotplug needed if you
want to make a per-cpu specific operations. get_online_cpus is the
most straightforward and heavy weight way to do this synchronization
but not the only one. As the patch [1] describes we do not really need
get_online_cpus in drain_all_pages because we can do _better_. But
this is not in any way a generic thing applicable to other code paths.

If you disagree then you are free to post patches but hand waving you
are doing here is just wasting everybody's time. So please cut it here
unless you have specific proposals to improve the current situation.

Thanks!

[1] http://lkml.kernel.org/r/20170207201950.20482-1-mhocko@kernel.org
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
