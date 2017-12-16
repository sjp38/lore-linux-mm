Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B571F6B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 06:33:39 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id c9so6526952wrb.4
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 03:33:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si6717922wrf.65.2017.12.16.03.33.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 03:33:38 -0800 (PST)
Date: Sat, 16 Dec 2017 12:33:29 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
Message-ID: <20171216113329.GF16951@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
 <20171215162534.GA16951@dhcp22.suse.cz>
 <0c555671-9214-5cb9-0121-5da04faf5329@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0c555671-9214-5cb9-0121-5da04faf5329@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat 16-12-17 15:21:51, Tetsuo Handa wrote:
> On 2017/12/16 1:25, Michal Hocko wrote:
> >>  struct mmu_notifier_ops {
> >> +	/*
> >> +	 * Flags to specify behavior of callbacks for this MMU notifier.
> >> +	 * Used to determine which context an operation may be called.
> >> +	 *
> >> +	 * MMU_INVALIDATE_DOES_NOT_BLOCK: invalidate_{start,end} does not
> >> +	 *				  block
> >> +	 */
> >> +	int flags;
> > 
> > This should be more specific IMHO. What do you think about the following
> > wording?
> > 
> > invalidate_{start,end,range} doesn't block on any locks which depend
> > directly or indirectly (via lock chain or resources e.g. worker context)
> > on a memory allocation.
> 
> I disagree. It needlessly complicates validating the correctness.

But it makes it clear what is the actual semantic.

> What if the invalidate_{start,end} calls schedule_timeout_idle(10 * HZ) ?

Let's talk seriously about a real code. Any mmu notifier doing this is
just crazy and should be fixed.

> schedule_timeout_idle() will not block on any locks which depend directly or
> indirectly on a memory allocation, but we are already blocking other memory
> allocating threads at mutex_trylock(&oom_lock) in __alloc_pages_may_oom().

Then the reaper will block and progress would be slower.

> This is essentially same with "sleeping forever due to schedule_timeout_killable(1) by
> SCHED_IDLE thread with oom_lock held" versus "looping due to mutex_trylock(&oom_lock)
> by all other allocating threads" lockup problem. The OOM reaper does not want to get
> blocked for so long.

Yes, it absolutely doesn't want to do that. MMu notifiers should be
reasonable because they are called from performance sensitive call
paths.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
