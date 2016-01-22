Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62491828DF
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:04:21 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id b14so133846248wmb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:04:21 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id t2si8611030wjx.60.2016.01.22.06.04.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 06:04:19 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id n5so133751702wmn.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:04:19 -0800 (PST)
Date: Fri, 22 Jan 2016 15:04:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
Message-ID: <20160122140418.GB19465@dhcp22.suse.cz>
References: <20160120151007.GG14187@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601200919520.21490@east.gentwo.org>
 <569FAC90.5030407@oracle.com>
 <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
 <20160120212806.GA26965@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org>
 <20160121082402.GA29520@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
 <20160121165148.GF29520@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 21-01-16 11:38:46, Christoph Lameter wrote:
> On Thu, 21 Jan 2016, Michal Hocko wrote:
> 
> > It goes like this:
> > CPU0:						CPU1
> > vmstat_update
> >   cpumask_test_and_set_cpu (0->1)
> > [...]
> > 						vmstat_shepherd
> > <enter idle>					  cpumask_test_and_clear_cpu(CPU0) (1->0)
> > quiet_vmstat
> >   cpumask_test_and_set_cpu (0->1)
> >   						  queue_delayed_work_on(CPU0)
> > refresh_cpu_vm_stats()
> > [...]
> > vmstat_update
> >   nothing_to_do
> >   cpumask_test_and_set_cpu (1->1)
> >   VM_BUG_ON
> >
> > Or am I missing something?
> 
> Ok then the following should fix it:

Wouldn't it be much more easier and simply get rid of the VM_BUG_ON?
What is the point of keeping it in the first place. The code can
perfectly cope with the race.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
