Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC586B000E
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 02:17:25 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id s15-v6so3543696wrn.16
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 23:17:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a68-v6si11057406wrc.431.2018.07.24.23.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 23:17:23 -0700 (PDT)
Date: Wed, 25 Jul 2018 08:17:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
Message-ID: <20180725061722.GT28386@dhcp22.suse.cz>
References: <20180716115058.5559-1-mhocko@kernel.org>
 <20180720170902.d1137060c23802d55426aa03@linux-foundation.org>
 <20180724141747.GP28386@dhcp22.suse.cz>
 <20180724125307.d6035c447adf46b2d74dfbd7@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724125307.d6035c447adf46b2d74dfbd7@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On Tue 24-07-18 12:53:07, Andrew Morton wrote:
[...]
> > On top of that the proposed cleanup looks as follows:
> > 
> 
> Looks good to me.  Seems a bit strange that we omit the pr_info()
> output if the mm was partially reaped - people would still want to know
> this?   Not very important though.

I think that having a single output once we are done is better but I do
not have a strong opinion on this.

Btw. here is the changelog for the cleanup.

"
Andrew has noticed someinconsistencies in oom_reap_task_mm. Notably
 - Undocumented return value.

 - comment "failed to reap part..." is misleading - sounds like it's
   referring to something which happened in the past, is in fact
   referring to something which might happen in the future.

 - fails to call trace_finish_task_reaping() in one case

 - code duplication.

 - Increases mmap_sem hold time a little by moving
   trace_finish_task_reaping() inside the locked region.  So sue me ;)

 - Sharing the finish: path means that the trace event won't
   distinguish between the two sources of finishing.

Add a short explanation for the return value and fix the rest by
reorganizing the function a bit to have unified function exit paths.

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
"

-- 
Michal Hocko
SUSE Labs
