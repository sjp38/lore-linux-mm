Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 70FEE6B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 12:40:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id c85so4987161wmi.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 09:40:30 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id i190si6916177wmd.75.2017.02.09.09.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 09:40:29 -0800 (PST)
Date: Thu, 9 Feb 2017 18:40:23 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <alpine.DEB.2.20.1702091048330.24346@east.gentwo.org>
Message-ID: <alpine.DEB.2.20.1702091833200.3604@nanos>
References: <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org> <20170208152106.GP5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org>
 <alpine.DEB.2.20.1702081838560.3536@nanos> <alpine.DEB.2.20.1702082109530.13608@east.gentwo.org> <alpine.DEB.2.20.1702091240000.3604@nanos> <alpine.DEB.2.20.1702090759370.22559@east.gentwo.org> <alpine.DEB.2.20.1702091548300.3604@nanos>
 <alpine.DEB.2.20.1702090940190.23960@east.gentwo.org> <alpine.DEB.2.20.1702091708270.3604@nanos> <alpine.DEB.2.20.1702091048330.24346@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 9 Feb 2017, Christoph Lameter wrote:
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

drain_all_pages() is called from preemptible context. So what are you
talking about again?

> > > Lets get rid of get_online_cpus() etc.
> >
> > And that solves what?
> 
> It gets rid of future issues with serialization in paths were we need to
> lock and still do for_each_online_cpu().

There are code pathes which might sleep inside the loop so
get_online_cpus() is the only way to serialize against hotplug.

Just because the only tool you know is stop machine it does not make
everything an atomic context where it can be applied.

> > Can you please start to understand the scope of the whole hotplug machinery
> > including the requirements for get_online_cpus() before you waste
> > everybodys time with your uninformed and halfbaken proposals?
> 
> Its an obvious solution to the issues that have arisen multiple times with
> get_online_cpus() within the slab allocators. The hotplug machinery should
> make things as easy as possible for other people and having these
> get_online_cpus() everywhere does complicate things.

It's no obvious solution to everything. It's context dependend and people
have to think hard how to solve their problem within the context they are
dealing with.

Your 'get rid of get_online_cpus()' mantra does make all of this magically
simple. Relying on the fact, that the CPU online bit is cleared via
stomp_machine(), which is a horrible operation in various aspects, only
applies to a very small subset of problems. You can repeat your mantra
another thousand times and that will not make the way larger set of
problems magically disappear.

Thanks,

	tglx



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
