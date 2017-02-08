Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2255728089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 11:17:24 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id c25so139474595qtg.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 08:17:24 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id j13si5923280qta.134.2017.02.08.08.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 08:17:23 -0800 (PST)
Date: Wed, 8 Feb 2017 10:17:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
In-Reply-To: <20170208152106.GP5686@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1702081011460.4938@east.gentwo.org>
References: <20170207123708.GO5065@dhcp22.suse.cz> <20170207135846.usfrn7e4znjhmogn@techsingularity.net> <20170207141911.GR5065@dhcp22.suse.cz> <20170207153459.GV5065@dhcp22.suse.cz> <20170207162224.elnrlgibjegswsgn@techsingularity.net> <20170207164130.GY5065@dhcp22.suse.cz>
 <alpine.DEB.2.20.1702071053380.16150@east.gentwo.org> <alpine.DEB.2.20.1702072319200.8117@nanos> <20170208073527.GA5686@dhcp22.suse.cz> <alpine.DEB.2.20.1702080906540.3955@east.gentwo.org> <20170208152106.GP5686@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 8 Feb 2017, Michal Hocko wrote:

> I have no idea what you are trying to say and how this is related to the
> deadlock we are discussing here. We certainly do not need to add
> stop_machine the problem. And yeah, dropping get_online_cpus was
> possible after considering all fallouts.

This is not the first time get_online_cpus() causes problems due to the
need to support hotplug for processors. Hotplugging is not happening
frequently (which is low balling it. Actually the frequency of the hotplug
events on almost all systems is zero) so the constant check is a useless
overhead and causes trouble for development. In particular
get_online_cpus() is often needed in sections that need to hold locks.

So lets get rid of it. The severity, frequency and rarity of processor
hotplug events would justify only allowing adding and removal of
processors through the stop_machine_xx mechanism. With that in place the
processor masks can be used without synchronization and the locking issues
all over the kernel would become simpler.

It is likely that this will even improve the hotplug code because the
easier form of synchronization (you have a piece of code that executed
while the OS is in stop state) would allow to make more significant
changes to the software environment. F.e. one could think about removing
memory segments as well as maybe per cpu segments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
