Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD136B009D
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 08:05:46 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hi2so1418373wib.7
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 05:05:45 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga9si9759735wib.91.2014.11.06.05.05.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Nov 2014 05:05:45 -0800 (PST)
Date: Thu, 6 Nov 2014 14:05:43 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141106130543.GE7202@dhcp22.suse.cz>
References: <20141105124620.GB4527@dhcp22.suse.cz>
 <20141105130247.GA14386@htj.dyndns.org>
 <20141105133100.GC4527@dhcp22.suse.cz>
 <20141105134219.GD4527@dhcp22.suse.cz>
 <20141105154436.GB14386@htj.dyndns.org>
 <20141105160115.GA28226@dhcp22.suse.cz>
 <20141105162929.GD14386@htj.dyndns.org>
 <20141105163956.GD28226@dhcp22.suse.cz>
 <20141105165428.GF14386@htj.dyndns.org>
 <20141105170111.GG14386@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105170111.GG14386@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Wed 05-11-14 12:01:11, Tejun Heo wrote:
> On Wed, Nov 05, 2014 at 11:54:28AM -0500, Tejun Heo wrote:
> > > Still not following. How do you want to detect an on-going OOM without
> > > any interface around out_of_memory?
> > 
> > I thought you were using oom_killer_allowed_start() outside OOM path.
> > Ugh.... why is everything weirdly structured?  oom_killer_disabled
> > implies that oom killer may fail, right?  Why is
> > __alloc_pages_slowpath() checking it directly?  If whether oom killing
> > failed or not is relevant to its users, make out_of_memory() return an
> > error code.  There's no reason for the exclusion detail to leak out of
> > the oom killer proper.  The only interface should be disable/enable
> > and whether oom killing failed or not.
> 
> And what's implemented is wrong.  What happens if oom killing is
> already in progress and then a task blocks trying to write-lock the
> rwsem and then that task is selected as the OOM victim?

But this is nothing new. Suspend hasn't been checking for fatal signals
nor for TIF_MEMDIE since the OOM disabling was introduced and I suppose
even before.

This is not harmful though. The previous OOM kill attempt would kick the
current TASK and mark it with TIF_MEMDIE and retry the allocation. After
OOM is disabled the allocation simply fails. The current will die on its
way out of the kernel. Definitely worth fixing. In a separate patch.

> disable() call must be able to fail.

This would be a way to do it without requiring caller to check for
TIF_MEMDIE explicitly. The fewer of them we have the better.
---
