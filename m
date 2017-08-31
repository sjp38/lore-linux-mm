Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2674F6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 01:29:39 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z91so11582169wrc.2
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 22:29:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 139si4559198wmi.4.2017.08.30.22.29.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Aug 2017 22:29:38 -0700 (PDT)
Date: Thu, 31 Aug 2017 07:29:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom_reaper: skip mm structs with mmu notifiers
Message-ID: <20170831052935.x3vo3wu6gc6l6w3p@dhcp22.suse.cz>
References: <20170830084600.17491-1-mhocko@kernel.org>
 <20170830174904.GF13559@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830174904.GF13559@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 30-08-17 19:49:04, Andrea Arcangeli wrote:
> Hello Michal,
> 
> On Wed, Aug 30, 2017 at 10:46:00AM +0200, Michal Hocko wrote:
> > +	 * TODO: we really want to get rid of this ugly hack and make sure that
> > +	 * notifiers cannot block for unbounded amount of time and add
> > +	 * mmu_notifier_invalidate_range_{start,end} around unmap_page_range
> 
> KVM already should be ok in that respect. However the major reason to
> prefer mmu_notifier_invalidate_range_start/end is those can block and
> schedule waiting for stuff happening behind the PCI bus easily. So I'm
> not sure if the TODO is good idea to keep.

Long term, I was thinking about a flag to reflect that all registered
notifiers are oom safe (aka they do not depend on memory allocations
or any locks which depend on an allocation) and then we can call into
notifiers. So the check would end up
	if (!mm_has_safe_notifiers(mm))
		...
 
> > +	 */
> > +	if (mm_has_notifiers(mm)) {
> > +		schedule_timeout_idle(HZ);
> 
> Why the schedule_timeout? What's the difference with the OOM
> reaper going to sleep again in the main loop instead?

Well, this is what I had initially - basically to return false here
and rely on oom_reap_task to retry. But my current understanding is that
mm_has_notifiers is likely to be a semi-permanent state (once set it
won't likely go away) so I figured it would be better to simply wait
here and fail right away. If my assumption is not correct then I will
simply return false here.

> 
> > +		goto unlock_oom;
> > +	}
> 
> mm_has_notifiers stops changing after obtaining the mmap_sem for
> reading. See the do_mmu_notifier_register. So it's better to put the
> mm_has_notifiers check immediately after the below:
> 
> >  	if (!down_read_trylock(&mm->mmap_sem)) {
> >  		ret = false;
> >  		trace_skip_task_reaping(tsk->pid);
> 
> If we succeed taking the mmap_sem for reading then we read a stable
> value out of mm_has_notifiers and be sure it won't be set from under
> us.

OK, I will move it.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
