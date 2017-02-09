Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85CC46B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 10:42:12 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id s10so28555290itb.7
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 07:42:12 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id p191si5121241itc.87.2017.02.09.07.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 07:42:11 -0800 (PST)
Date: Thu, 9 Feb 2017 09:42:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <alpine.DEB.2.20.1702091548300.3604@nanos>
Message-ID: <alpine.DEB.2.20.1702090940190.23960@east.gentwo.org>
References: <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org> <20170208152106.GP5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org>
 <alpine.DEB.2.20.1702081838560.3536@nanos> <alpine.DEB.2.20.1702082109530.13608@east.gentwo.org> <alpine.DEB.2.20.1702091240000.3604@nanos> <alpine.DEB.2.20.1702090759370.22559@east.gentwo.org> <alpine.DEB.2.20.1702091548300.3604@nanos>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 9 Feb 2017, Thomas Gleixner wrote:

> > The stop_machine would need to ensure that all cpus cease processing
> > before proceeding.
>
> Ok. I try again:
>
> CPU 0	     	  	    CPU 1
> for_each_online_cpu(cpu)
>   ==> cpu = 1
>  			    stop_machine()
>
> Stops processing on all CPUs by preempting the current execution and
> forcing them into a high priority busy loop with interrupts disabled.

Exactly that means we are outside of the sections marked with
get_online_cpous().

> It does exactly what you describe. It stops processing on all other cpus
> until release, but that does not invalidate any data on those cpus.

Why would it need to invalidate any data? The change of the cpu masks
would need to be done when the machine is stopped. This sounds exactly
like what we need and much of it is already there.

Lets get rid of get_online_cpus() etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
