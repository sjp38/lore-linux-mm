Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29DD46B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 06:42:51 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id c7so165699wjb.7
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 03:42:51 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id z96si12565580wrb.48.2017.02.09.03.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 03:42:49 -0800 (PST)
Date: Thu, 9 Feb 2017 12:42:44 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <alpine.DEB.2.20.1702082109530.13608@east.gentwo.org>
Message-ID: <alpine.DEB.2.20.1702091240000.3604@nanos>
References: <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org> <20170208152106.GP5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org>
 <alpine.DEB.2.20.1702081838560.3536@nanos> <alpine.DEB.2.20.1702082109530.13608@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 8 Feb 2017, Christoph Lameter wrote:
> On Wed, 8 Feb 2017, Thomas Gleixner wrote:
> 
> > There is a world outside yours. Hotplug is actually used frequently for
> > power purposes in some scenarios.
> 
> The usual case does not inolve hotplug.

We do not care about your definition of "usual". The kernel serves _ALL_
use cases.

> > It will improve nothing. The stop machine context is extremly limited and
> > you cannot do complex things there at all. Not to talk about the inability
> > of taking a simple mutex which would immediately deadlock the machine.
> 
> You do not need to do complex things. Basically flipping some cpu mask
> bits will do it. stop machine ensures that code is not
> executing on the processors when the bits are flipped. That will ensure
> that there is no need to do any get_online_cpu() nastiness in critical VM
> paths since we are guaranteed not to be executing them.

And how does that solve the problem at hand? Not at all:

CPU 0	     	  	    CPU 1

for_each_online_cpu(cpu)
 ==> cpu = 1
			    stop_machine()
			    set_cpu_online(1, false)
 queue_work(cpu1)

Thanks,

	tglx


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
