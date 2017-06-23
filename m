Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 82EC56B0292
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 08:13:46 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g46so12259383wrd.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 05:13:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m185si3874652wme.155.2017.06.23.05.13.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 05:13:45 -0700 (PDT)
Date: Fri, 23 Jun 2017 14:13:42 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, swap: don't disable preemption while taking the
 per-CPU cache
Message-ID: <20170623121342.GT5308@dhcp22.suse.cz>
References: <20170623101254.k4zzbf3dfoukoxkq@linutronix.de>
 <20170623103423.GJ5308@dhcp22.suse.cz>
 <20170623114755.2ebxdysacvgxzott@linutronix.de>
 <20170623120233.GR5308@dhcp22.suse.cz>
 <20170623120842.oai2kiqkxz5jx6nh@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170623120842.oai2kiqkxz5jx6nh@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, tglx@linutronix.de, ying.huang@intel.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri 23-06-17 14:08:42, Sebastian Andrzej Siewior wrote:
> On 2017-06-23 14:02:33 [+0200], Michal Hocko wrote:
> > On Fri 23-06-17 13:47:55, Sebastian Andrzej Siewior wrote:
> > > get_cpu_var() disables preemption and returns the per-CPU version of the
> > > variable. Disabling preemption is useful to ensure atomic access to the
> > > variable within the critical section.
> > > In this case however, after the per-CPU version of the variable is
> > > obtained the ->free_lock is acquired. For that reason it seems the raw
> > > accessor could be used. It only seems that ->slots_ret should be
> > > retested (because with disabled preemption this variable can not be set
> > > to NULL otherwise).
> > > This popped up during PREEMPT-RT testing because it tries to take
> > > spinlocks in a preempt disabled section.
> > 
> > Ohh, because the spinlock can sleep with PREEMPT-RT right? Don't we have
> yup.
> 
> > much more places like that? It is perfectly valid to take a spinlock
> well we have more than just this one patch to fix things like that :)
> The easy/simple things (like this one which is valid in RT and !RT) I
> try to push upstream asap and the other remain in the RT tree.

yeah, makes sense to me.

> > while the preemption is disabled. E.g. we do take ptl lock inside
> > kmap_atomic sections which disables preemption on 32b systems.
> we don't disable preemption in kmap_atomic(). It would be bad :)

Ohh, I didn't know about that.

> > > Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> > 
> > Acked-by: Michal Hocko <mhocko@suse.com>
> Thanks.
> 
> Sebastian

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
