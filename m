Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 89B506B0033
	for <linux-mm@kvack.org>; Sat, 16 Dec 2017 06:36:50 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id h18so9749568pfi.2
        for <linux-mm@kvack.org>; Sat, 16 Dec 2017 03:36:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x10si6485464plm.608.2017.12.16.03.36.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 16 Dec 2017 03:36:49 -0800 (PST)
Date: Sat, 16 Dec 2017 12:36:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
Message-ID: <20171216113645.GG16951@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
 <20171215150429.f68862867392337f35a49848@linux-foundation.org>
 <cafa6cdb-886b-b010-753f-600ae86f5e71@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cafa6cdb-886b-b010-753f-600ae86f5e71@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat 16-12-17 16:14:07, Tetsuo Handa wrote:
> On 2017/12/16 8:04, Andrew Morton wrote:
> >> The implementation is steered toward an expensive slowpath, such as after
> >> the oom reaper has grabbed mm->mmap_sem of a still alive oom victim.
> > 
> > some tweakage, please review.
> > 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Subject: mm-mmu_notifier-annotate-mmu-notifiers-with-blockable-invalidate-callbacks-fix
> > 
> > make mm_has_blockable_invalidate_notifiers() return bool, use rwsem_is_locked()
> > 
> 
> > @@ -240,13 +240,13 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_invalid
> >   * Must be called while holding mm->mmap_sem for either read or write.
> >   * The result is guaranteed to be valid until mm->mmap_sem is dropped.
> >   */
> > -int mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
> > +bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
> >  {
> >  	struct mmu_notifier *mn;
> >  	int id;
> > -	int ret = 0;
> > +	bool ret = false;
> >  
> > -	WARN_ON_ONCE(down_write_trylock(&mm->mmap_sem));
> > +	WARN_ON_ONCE(!rwsem_is_locked(&mm->mmap_sem));
> >  
> >  	if (!mm_has_notifiers(mm))
> >  		return ret;
> 
> rwsem_is_locked() test isn't equivalent with __mutex_owner() == current test, is it?
> If rwsem_is_locked() returns true because somebody else has locked it, there is
> no guarantee that current thread has locked it before calling this function.
> 
> down_write_trylock() test isn't equivalent with __mutex_owner() == current test, is it?
> What if somebody else held it for read or write (the worst case is registration path),
> down_write_trylock() will return false even if current thread has not locked it for
> read or write.
> 
> I think this WARN_ON_ONCE() can not detect incorrect call to this function.

Yes it cannot catch _all_ cases. This is an inherent problem of
rwsem_is_locked because semaphores do not really have the owner concept.
The core idea behind this, I guess, is to catch obviously incorrect
usage and as such it gives us a reasonabe coverage. I could live without
the annotation but rwsem_is_locked looks better than down_write_trylock
to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
