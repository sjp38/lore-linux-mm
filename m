Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A67F528089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 12:46:14 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id yr2so34502025wjc.4
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 09:46:14 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 185si3263977wmm.14.2017.02.08.09.46.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 09:46:13 -0800 (PST)
Date: Wed, 8 Feb 2017 18:46:08 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org>
Message-ID: <alpine.DEB.2.20.1702081838560.3536@nanos>
References: <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org> <20170208152106.GP5686@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 8 Feb 2017, Christoph Lameter wrote:
> On Wed, 8 Feb 2017, Michal Hocko wrote:
> 
> > I have no idea what you are trying to say and how this is related to the
> > deadlock we are discussing here. We certainly do not need to add
> > stop_machine the problem. And yeah, dropping get_online_cpus was
> > possible after considering all fallouts.
> 
> This is not the first time get_online_cpus() causes problems due to the
> need to support hotplug for processors. Hotplugging is not happening
> frequently (which is low balling it. Actually the frequency of the hotplug
> events on almost all systems is zero) so the constant check is a useless
> overhead and causes trouble for development. In particular

There is a world outside yours. Hotplug is actually used frequently for
power purposes in some scenarios.

> get_online_cpus() is often needed in sections that need to hold locks.
> 
> So lets get rid of it. The severity, frequency and rarity of processor
> hotplug events would justify only allowing adding and removal of
> processors through the stop_machine_xx mechanism. With that in place the
> processor masks can be used without synchronization and the locking issues
> all over the kernel would become simpler.
> 
> It is likely that this will even improve the hotplug code because the
> easier form of synchronization (you have a piece of code that executed
> while the OS is in stop state) would allow to make more significant
> changes to the software environment. F.e. one could think about removing
> memory segments as well as maybe per cpu segments.

It will improve nothing. The stop machine context is extremly limited and
you cannot do complex things there at all. Not to talk about the inability
of taking a simple mutex which would immediately deadlock the machine.

stop machine is the last resort for things which need to be done atomically
and that operation can be done in a very restricted context.

And everything complex needs to be done _before_ that in normal
context. Hot unplug already uses stop machine for the final removal of the
outgoing CPU, but that's definitely not the place where you can do anything
complex like page management.

If you can prepare the outgoing cpu work during the cpu offline phase and
then just flip a bit in the stop machine part, then this might work, but
anything else is just handwaving and proliferation of wet dreams.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
