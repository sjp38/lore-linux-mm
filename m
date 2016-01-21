Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8989C6B0253
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 10:45:13 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id q21so58210404iod.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 07:45:13 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id hy7si5424095igb.71.2016.01.21.07.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jan 2016 07:45:12 -0800 (PST)
Date: Thu, 21 Jan 2016 09:45:12 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
In-Reply-To: <20160121082402.GA29520@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
References: <5674A5C3.1050504@oracle.com> <20160120143719.GF14187@dhcp22.suse.cz> <569FA01A.4070200@oracle.com> <20160120151007.GG14187@dhcp22.suse.cz> <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org> <569FAC90.5030407@oracle.com>
 <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org> <20160120212806.GA26965@dhcp22.suse.cz> <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org> <20160121082402.GA29520@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, 21 Jan 2016, Michal Hocko wrote:

> > > Since 0eb77e988032 ("vmstat: make vmstat_updater deferrable again and
> > > shut down on idle") quiet_vmstat might update cpu_stat_off and mark a
> > > particular cpu to be handled by vmstat_shepherd. This might trigger
> > > a VM_BUG_ON in vmstat_update because the work item might have been
> > > sleeping during the idle period and see the cpu_stat_off updated after
> > > the wake up. The VM_BUG_ON is therefore misleading and no more
> > > appropriate. Moreover it doesn't really suite any protection from real
> > > bugs because vmstat_shepherd will simply reschedule the vmstat_work
> > > anytime it sees a particular cpu set or vmstat_update would do the same
> > > from the worker context directly. Even when the two would race the
> > > result wouldn't be incorrect as the counters update is fully idempotent.
> >
> >
> > Hmmm... the vmstat_update can be interrupted while running and the cpu put
> > into idle mode? If vmstat_update is running then the cpu is not idle but
> > running code. If this is really going on then there is other stuff wrong
> > with the idling logic.
>
> The vmstat update might be still waiting for its timer, idle mode started
> and kick vmstat_update which might cpumask_test_and_set_cpu. Once the
> idle terminates and the originally schedule vmstate_update executes it
> sees the bit set and BUG_ON.

Ok so we are going into idle mode and the vmstat_update timer is pending.
Then the timer will not fire since going idle switches preemption off.
quiet_vmstat will run without the chance of running vmstat_update

We could be going idle and not have disabled preemption yet. Then
vmstat_update will run. On return to the idling operation preemption will
be disabled and quiet_vmstat() will be run.

I do not see how these two things could race.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
