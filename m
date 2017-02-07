Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBE46B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 05:28:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r18so24554842wmd.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 02:28:12 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id v46si4518748wrc.22.2017.02.07.02.28.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 02:28:10 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 4DDF51C1C55
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 10:28:10 +0000 (GMT)
Date: Tue, 7 Feb 2017 10:28:09 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207102809.awh22urqmfrav5r6@techsingularity.net>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 07, 2017 at 10:49:28AM +0100, Vlastimil Babka wrote:
> On 02/07/2017 10:43 AM, Mel Gorman wrote:
> > If I'm reading this right, a hot-remove will set the pool POOL_DISASSOCIATED
> > and unbound. A workqueue queued for draining get migrated during hot-remove
> > and a drain operation will execute twice on a CPU -- one for what was
> > queued and a second time for the CPU it was migrated from. It should still
> > work with flush_work which doesn't appear to block forever if an item
> > got migrated to another workqueue. The actual drain workqueue function is
> > using the CPU ID it's currently running on so it shouldn't get confused.
> 
> Is the worker that will process this migrated workqueue also guaranteed
> to be pinned to a cpu for the whole work, though? drain_local_pages()
> needs that guarantee.
> 

It should be by running on a workqueue handler bound to that CPU (queued
on wq->cpu_pwqs in __queue_work)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
