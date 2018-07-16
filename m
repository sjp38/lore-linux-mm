Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id F13AF6B0006
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 19:12:53 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a3-v6so4086028pgv.10
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 16:12:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q13-v6si22493961pgc.670.2018.07.16.16.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 16:12:51 -0700 (PDT)
Date: Mon, 16 Jul 2018 16:12:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-Id: <20180716161249.c76240cd487c070fb271d529@linux-foundation.org>
In-Reply-To: <20180716115058.5559-1-mhocko@kernel.org>
References: <20180716115058.5559-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?ISO-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Mon, 16 Jul 2018 13:50:58 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> There are several blockable mmu notifiers which might sleep in
> mmu_notifier_invalidate_range_start and that is a problem for the
> oom_reaper because it needs to guarantee a forward progress so it cannot
> depend on any sleepable locks.
> 
> Currently we simply back off and mark an oom victim with blockable mmu
> notifiers as done after a short sleep. That can result in selecting a
> new oom victim prematurely because the previous one still hasn't torn
> its memory down yet.
> 
> We can do much better though. Even if mmu notifiers use sleepable locks
> there is no reason to automatically assume those locks are held.
> Moreover majority of notifiers only care about a portion of the address
> space and there is absolutely zero reason to fail when we are unmapping an
> unrelated range. Many notifiers do really block and wait for HW which is
> harder to handle and we have to bail out though.
> 
> This patch handles the low hanging fruid. __mmu_notifier_invalidate_range_start
> gets a blockable flag and callbacks are not allowed to sleep if the
> flag is set to false. This is achieved by using trylock instead of the
> sleepable lock for most callbacks and continue as long as we do not
> block down the call chain.

I assume device driver developers are wondering "what does this mean
for me".  As I understand it, the only time they will see
blockable==false is when their driver is being called in response to an
out-of-memory condition, yes?  So it is a very rare thing.

Any suggestions regarding how the driver developers can test this code
path?  I don't think we presently have a way to fake an oom-killing
event?  Perhaps we should add such a thing, given the problems we're
having with that feature.

> I think we can improve that even further because there is a common
> pattern to do a range lookup first and then do something about that.
> The first part can be done without a sleeping lock in most cases AFAICS.
> 
> The oom_reaper end then simply retries if there is at least one notifier
> which couldn't make any progress in !blockable mode. A retry loop is
> already implemented to wait for the mmap_sem and this is basically the
> same thing.
> 
> ...
>
> +static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
> +				  unsigned long start, unsigned long end)
> +{
> +	int ret = 0;
> +	if (mm_has_notifiers(mm))
> +		ret = __mmu_notifier_invalidate_range_start(mm, start, end, false);
> +
> +	return ret;
>  }

nit,

{
	if (mm_has_notifiers(mm))
		return __mmu_notifier_invalidate_range_start(mm, start, end, false);
	return 0;
}

would suffice.


> 
> ...
>
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3074,7 +3074,7 @@ void exit_mmap(struct mm_struct *mm)
>  		 * reliably test it.
>  		 */
>  		mutex_lock(&oom_lock);
> -		__oom_reap_task_mm(mm);
> +		(void)__oom_reap_task_mm(mm);
>  		mutex_unlock(&oom_lock);

What does this do?

>  		set_bit(MMF_OOM_SKIP, &mm->flags);
> 
> ...
>
