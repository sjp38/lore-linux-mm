Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63EE86B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 07:02:13 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id x4so30525996wme.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 04:02:13 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o81si2118843wmb.108.2017.02.08.04.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 04:02:12 -0800 (PST)
Date: Wed, 8 Feb 2017 13:02:07 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <20170208073527.GA5686@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1702081253590.3536@nanos>
References: <20170207113435.6xthczxt2cx23r4t@techsingularity.net> <20170207114327.GI5065@dhcp22.suse.cz> <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz>
 <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz> <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 8 Feb 2017, Michal Hocko wrote:
> On Tue 07-02-17 23:25:17, Thomas Gleixner wrote:
> > On Tue, 7 Feb 2017, Christoph Lameter wrote:
> > > On Tue, 7 Feb 2017, Michal Hocko wrote:
> > > 
> > > > I am always nervous when seeing hotplug locks being used in low level
> > > > code. It has bitten us several times already and those deadlocks are
> > > > quite hard to spot when reviewing the code and very rare to hit so they
> > > > tend to live for a long time.
> > > 
> > > Yep. Hotplug events are pretty significant. Using stop_machine_XXXX() etc
> > > would be advisable and that would avoid the taking of locks and get rid of all the
> > > ocmplexity, reduce the code size and make the overall system much more
> > > reliable.
> > 
> > Huch? stop_machine() is horrible and heavy weight. Don't go there, there
> > must be simpler solutions than that.
> 
> Absolutely agreed. We are in the page allocator path so using the
> stop_machine* is just ridiculous. And, in fact, there is a much simpler
> solution [1]
> 
> [1] http://lkml.kernel.org/r/20170207201950.20482-1-mhocko@kernel.org

Well, yes. It's simple, but from an RT point of view I really don't like
it as we have to fix it up again.

On RT we solved the problem of the page allocator differently which allows
us to do drain_all_pages() from the caller CPU as a side effect. That's
interesting not only for RT, it's also interesting for NOHZ FULL scenarios
because you don't inflict the work on the other CPUs.

https://git.kernel.org/cgit/linux/kernel/git/rt/linux-rt-devel.git/commit/?h=linux-4.9.y-rt-rebase&id=d577a017da694e29a06af057c517f2a7051eb305

That uses local locks (an RT speciality which compile away into preempt/irq
disable/enable when RT is disabled).

Works like a charm :)

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
