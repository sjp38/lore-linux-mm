Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A43EE6B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 15:53:11 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a26-v6so3163256pgw.7
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 12:53:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k91-v6si11490153pld.248.2018.07.24.12.53.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 12:53:10 -0700 (PDT)
Date: Tue, 24 Jul 2018 12:53:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-Id: <20180724125307.d6035c447adf46b2d74dfbd7@linux-foundation.org>
In-Reply-To: <20180724141747.GP28386@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
	<20180720170902.d1137060c23802d55426aa03@linux-foundation.org>
	<20180724141747.GP28386@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?UTF-8?Q?Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?ISO-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Tue, 24 Jul 2018 16:17:47 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 20-07-18 17:09:02, Andrew Morton wrote:
> [...]
> > - Undocumented return value.
> > 
> > - comment "failed to reap part..." is misleading - sounds like it's
> >   referring to something which happened in the past, is in fact
> >   referring to something which might happen in the future.
> > 
> > - fails to call trace_finish_task_reaping() in one case
> > 
> > - code duplication.
> > 
> > - Increases mmap_sem hold time a little by moving
> >   trace_finish_task_reaping() inside the locked region.  So sue me ;)
> > 
> > - Sharing the finish: path means that the trace event won't
> >   distinguish between the two sources of finishing.
> > 
> > Please take a look?
> 
> oom_reap_task_mm should return false when __oom_reap_task_mm return
> false. This is what my patch did but it seems this changed by
> http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-oom-remove-oom_lock-from-oom_reaper.patch
> so that one should be fixed.
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 104ef4a01a55..88657e018714 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -565,7 +565,7 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	/* failed to reap part of the address space. Try again later */
>  	if (!__oom_reap_task_mm(mm)) {
>  		up_read(&mm->mmap_sem);
> -		return true;
> +		return false;
>  	}
>  
>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",

OK, thanks, I added that.

> 
> On top of that the proposed cleanup looks as follows:
> 

Looks good to me.  Seems a bit strange that we omit the pr_info()
output if the mm was partially reaped - people would still want to know
this?   Not very important though.
