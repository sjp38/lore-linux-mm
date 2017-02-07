Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB71F6B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 08:58:49 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x4so25552851wme.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 05:58:49 -0800 (PST)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id u203si12263162wmu.140.2017.02.07.05.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 05:58:47 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 60F461C1731
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 13:58:47 +0000 (GMT)
Date: Tue, 7 Feb 2017 13:58:46 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
References: <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170207123708.GO5065@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 07, 2017 at 01:37:08PM +0100, Michal Hocko wrote:
> > You cannot put sleepable lock inside the preempt disbaled section...
> > We can make it a spinlock right?
> 
> Scratch that! For some reason I thought that cpu notifiers are run in an
> atomic context. Now that I am checking the code again it turns out I was
> wrong. __cpu_notify uses __raw_notifier_call_chain so this is not an
> atomic context.

Indeed.

> Anyway, shouldn't be it sufficient to disable preemption
> on drain_local_pages_wq?

That would be sufficient for a hot-removed CPU moving the drain request
to another CPU and avoiding any scheduling events.

> The CPU hotplug callback will not preempt us
> and so we cannot work on the same cpus, right?
> 

I don't see a specific guarantee that it cannot be preempted and it
would depend on an the exact cpu hotplug implementation which is subject
to quite a lot of change. Hence, the mutex provides a guantee that the
hot-removed CPU teardown cannot run on the same CPU as a workqueue drain
running on a CPU it was not originally scheduled for.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
