Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A90066B000C
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:14:00 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z16-v6so3546183wrs.22
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 23:14:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o15-v6si9915787wrs.13.2018.07.24.23.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 23:13:59 -0700 (PDT)
Date: Wed, 25 Jul 2018 08:13:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180725061355.GS28386@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <20180720170902.d1137060c23802d55426aa03@linux-foundation.org>
 <20180724141747.GP28386@dhcp22.suse.cz>
 <alpine.DEB.2.21.1807241405450.191477@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807241405450.191477@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Leon Romanovsky <leonro@mellanox.com>

On Tue 24-07-18 14:07:49, David Rientjes wrote:
[...]
> mm/oom_kill.c: clean up oom_reap_task_mm() fix
> 
> indicate reaping has been partially skipped so we can expect future skips 
> or another start before finish.

But we are not skipping. This is essentially the same case as mmap_sem
trylock fail. Maybe we can add a bool parameter to trace_finish_task_reaping
to denote partial success?

> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -569,10 +569,12 @@ static bool oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  
>  	trace_start_task_reaping(tsk->pid);
>  
> -	/* failed to reap part of the address space. Try again later */
>  	ret = __oom_reap_task_mm(mm);
> -	if (!ret)
> +	if (!ret) {
> +		/* Failed to reap part of the address space. Try again later */
> +		trace_skip_task_reaping(tsk->pid);
>  		goto out_finish;
> +	}
>  
>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>  			task_pid_nr(tsk), tsk->comm,

-- 
Michal Hocko
SUSE Labs
