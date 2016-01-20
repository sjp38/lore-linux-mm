Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9D22B6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 16:57:44 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id z14so110718342igp.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 13:57:44 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id c18si45729410igr.94.2016.01.20.13.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 13:57:43 -0800 (PST)
Date: Wed, 20 Jan 2016 15:57:43 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <20160120212806.GA26965@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <20160120143719.GF14187@dhcp22.suse.cz> <569FA01A.4070200@oracle.com> <20160120151007.GG14187@dhcp22.suse.cz> <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org> <569FAC90.5030407@oracle.com>
 <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org> <20160120212806.GA26965@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 20 Jan 2016, Michal Hocko wrote:

> On Wed 20-01-16 09:55:22, Christoph Lameter wrote:
> [...]
> > Subject: vmstat: Remove BUG_ON from vmstat_update
> >
> > If we detect that there is nothing to do just set the flag and do not check
> > if it was already set before. Races really do not matter. If the flag is
> > set by any code then the shepherd will start dealing with the situation
> > and reenable the vmstat workers when necessary again.
> >
> > Concurrent actions could be onlining and offlining of processors or be a
> > result of concurrency issues when updating the cpumask from multiple
> > processors.
>
> Now that 7e988032 ("vmstat: make vmstat_updater deferrable again and
> shut down on idle) is merged the VM_BUG_ON is simply bogus because
> vmstat_update might "race" with quiet_vmstat. The changelog should
> reflect that. What about the following wording?

How can it race if preemption is off?

> Since 0eb77e988032 ("vmstat: make vmstat_updater deferrable again and
> shut down on idle") quiet_vmstat might update cpu_stat_off and mark a
> particular cpu to be handled by vmstat_shepherd. This might trigger
> a VM_BUG_ON in vmstat_update because the work item might have been
> sleeping during the idle period and see the cpu_stat_off updated after
> the wake up. The VM_BUG_ON is therefore misleading and no more
> appropriate. Moreover it doesn't really suite any protection from real
> bugs because vmstat_shepherd will simply reschedule the vmstat_work
> anytime it sees a particular cpu set or vmstat_update would do the same
> from the worker context directly. Even when the two would race the
> result wouldn't be incorrect as the counters update is fully idempotent.


Hmmm... the vmstat_update can be interrupted while running and the cpu put
into idle mode? If vmstat_update is running then the cpu is not idle but
running code. If this is really going on then there is other stuff wrong
with the idling logic.

> Fixes: 0eb77e988032 ("vmstat: make vmstat_updater deferrable again and
> shut down on idle")
> CC: stable # 4.4+

?? There has not been an upstream release with this yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
