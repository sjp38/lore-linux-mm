Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 72AE36B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 04:49:50 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id kq3so24304650wjc.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 01:49:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k29si11505125wmh.124.2017.02.07.01.49.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 01:49:49 -0800 (PST)
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
Date: Tue, 7 Feb 2017 10:49:28 +0100
MIME-Version: 1.0
In-Reply-To: <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On 02/07/2017 10:43 AM, Mel Gorman wrote:
> If I'm reading this right, a hot-remove will set the pool POOL_DISASSOCIATED
> and unbound. A workqueue queued for draining get migrated during hot-remove
> and a drain operation will execute twice on a CPU -- one for what was
> queued and a second time for the CPU it was migrated from. It should still
> work with flush_work which doesn't appear to block forever if an item
> got migrated to another workqueue. The actual drain workqueue function is
> using the CPU ID it's currently running on so it shouldn't get confused.

Is the worker that will process this migrated workqueue also guaranteed
to be pinned to a cpu for the whole work, though? drain_local_pages()
needs that guarantee.

> Tejun, did I miss anything? Does a workqueue item queued on a CPU being
> offline get unbound and a caller can still flush it safely? In this
> specific case, it's ok that the workqueue item does not run on the CPU it
> was queued on.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
