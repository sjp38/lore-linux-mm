Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E017F6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 06:13:58 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id x4so24744595wme.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 03:13:58 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id e72si11763257wma.116.2017.02.07.03.13.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 03:13:57 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 40C7898ABD
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 11:13:56 +0000 (UTC)
Date: Tue, 7 Feb 2017 11:13:55 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207111355.lyqfbrc6akwzgy4d@techsingularity.net>
References: <CACT4Y+asbKDni4RBavNf0-HwApTXjbbNko9eQbU6zCOgB2Yvnw@mail.gmail.com>
 <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <614e9873-c894-de42-a38a-1798fc0be039@suse.cz>
 <20170207104249.gpephtef2ajoqw62@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170207104249.gpephtef2ajoqw62@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 07, 2017 at 10:42:49AM +0000, Mel Gorman wrote:
> On Tue, Feb 07, 2017 at 10:23:31AM +0100, Vlastimil Babka wrote:
> > > cpu offlining. I have to check the code but my impression was that WQ
> > > code will ignore the cpu requested by the work item when the cpu is
> > > going offline. If the offline happens while the worker function already
> > > executes then it has to wait as we run with preemption disabled so we
> > > should be safe here. Or am I missing something obvious?
> > 
> > Tejun suggested an alternative solution to avoiding get_online_cpus() in
> > this thread:
> > https://lkml.kernel.org/r/<20170123170329.GA7820@htj.duckdns.org>
> 
> But it would look like the following as it could be serialised against
> pcpu_drain_mutex as the cpu hotplug teardown callback is allowed to sleep.
> 

Bah, this is obviously unsafe. It's guaranteed to deadlock.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
