Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id D39486B7B23
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 18:46:31 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id z72-v6so15872011itc.8
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 15:46:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f12-v6si4462617jam.101.2018.09.06.15.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 15:46:30 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180824120339.GL29735@dhcp22.suse.cz>
 <eb546bcb-9c5f-7d5d-43a7-bfde489f0e7f@amd.com>
 <20180824123341.GN29735@dhcp22.suse.cz>
 <b11df415-baf8-0a41-3c16-60dfe8d32bd3@amd.com>
 <20180824130132.GP29735@dhcp22.suse.cz>
 <23d071d2-82e4-9b78-1000-be44db5f6523@gmail.com>
 <20180824132442.GQ29735@dhcp22.suse.cz>
 <86bd94d5-0ce8-c67f-07a5-ca9ebf399cdd@gmail.com>
 <20180824134009.GS29735@dhcp22.suse.cz>
 <735b0a53-5237-8827-d20e-e57fa24d798f@amd.com>
 <20180824135257.GU29735@dhcp22.suse.cz>
 <b78f8b3a-7bc6-0dea-6752-5ea798eccb6b@i-love.sakura.ne.jp>
 <0e80c531-4e91-fb1d-e7eb-46a7aecc4c9d@amd.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <841ae1fb-bb5a-8b1e-6383-ca2e70b6e759@i-love.sakura.ne.jp>
Date: Fri, 7 Sep 2018 07:46:09 +0900
MIME-Version: 1.0
In-Reply-To: <0e80c531-4e91-fb1d-e7eb-46a7aecc4c9d@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Michal Hocko <mhocko@kernel.org>
Cc: kvm@vger.kernel.org, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Sudeep Dutt <sudeep.dutt@intel.com>, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Dimitri Sivanich <sivanich@sgi.com>, Jason Gunthorpe <jgg@ziepe.ca>, linux-rdma@vger.kernel.org, amd-gfx@lists.freedesktop.org, David Airlie <airlied@linux.ie>, Doug Ledford <dledford@redhat.com>, David Rientjes <rientjes@google.com>, xen-devel@lists.xenproject.org, intel-gfx@lists.freedesktop.org, Leon Romanovsky <leonro@mellanox.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Felix Kuehling <felix.kuehling@amd.com>

On 2018/08/27 16:41, Christian KA?nig wrote:
> Am 26.08.2018 um 10:40 schrieb Tetsuo Handa:
>> I'm not following. Why don't we need to do like below (given that
>> nobody except amdgpu_mn_read_lock() holds ->read_lock) because e.g.
>> drm_sched_fence_create() from drm_sched_job_init() from amdgpu_cs_submit()
>> is doing GFP_KERNEL memory allocation with ->lock held for write?
> 
> That's a bug which needs to be fixed separately.
> 
> Allocating memory with GFP_KERNEL while holding a lock which is also taken in the reclaim code path is illegal not matter what you do.
> 
> Patches to fix this are already on the appropriate mailing list and will be pushed upstream today.
> 
> Regards,
> Christian.

Commit 4a2de54dc1d7668f ("drm/amdgpu: fix holding mn_lock while allocating memory")
seems to be calling amdgpu_mn_unlock() without amdgpu_mn_lock() when
drm_sched_job_init() failed... 



Michal, you are asking me to fix all bugs (including out of tree code) and prevent
future bugs just because you want to avoid using timeout in order to avoid OOM lockup
( https://marc.info/?i=55a3fb37-3246-73d7-0f45-5835a3f4831c@i-love.sakura.ne.jp ).
That is a too much request which is impossible for even you. More you count on
the OOM reaper, we exponentially complicates dependency and more likely to stumble
over unreviewed/untested code...
