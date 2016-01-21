Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id AF0FB6B0005
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 11:51:52 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l65so228044723wmf.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 08:51:52 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id q10si2840921wjo.159.2016.01.21.08.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 08:51:50 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id n5so90745142wmn.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 08:51:50 -0800 (PST)
Date: Thu, 21 Jan 2016 17:51:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
Message-ID: <20160121165148.GF29520@dhcp22.suse.cz>
References: <20160120143719.GF14187@dhcp22.suse.cz>
 <569FA01A.4070200@oracle.com>
 <20160120151007.GG14187@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org>
 <569FAC90.5030407@oracle.com>
 <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
 <20160120212806.GA26965@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org>
 <20160121082402.GA29520@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 21-01-16 09:45:12, Christoph Lameter wrote:
> On Thu, 21 Jan 2016, Michal Hocko wrote:
[...]
> > The vmstat update might be still waiting for its timer, idle mode started
> > and kick vmstat_update which might cpumask_test_and_set_cpu. Once the
> > idle terminates and the originally schedule vmstate_update executes it
> > sees the bit set and BUG_ON.
> 
> Ok so we are going into idle mode and the vmstat_update timer is pending.
> Then the timer will not fire since going idle switches preemption off.
> quiet_vmstat will run without the chance of running vmstat_update
> 
> We could be going idle and not have disabled preemption yet. Then
> vmstat_update will run. On return to the idling operation preemption will
> be disabled and quiet_vmstat() will be run.
> 
> I do not see how these two things could race.

It goes like this:
CPU0:						CPU1
vmstat_update
  cpumask_test_and_set_cpu (0->1)
[...]
						vmstat_shepherd
<enter idle>					  cpumask_test_and_clear_cpu(CPU0) (1->0)
quiet_vmstat
  cpumask_test_and_set_cpu (0->1)
  						  queue_delayed_work_on(CPU0)
refresh_cpu_vm_stats()
[...]
vmstat_update
  nothing_to_do
  cpumask_test_and_set_cpu (1->1)
  VM_BUG_ON

Or am I missing something?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
