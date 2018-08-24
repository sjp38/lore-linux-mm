Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48A306B2F39
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:02:52 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m21-v6so7448575oic.7
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:02:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l205-v6si5477334oif.342.2018.08.24.06.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 06:02:50 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180716115058.5559-1-mhocko@kernel.org>
 <8cbfb09f-0c5a-8d43-1f5e-f3ff7612e289@I-love.SAKURA.ne.jp>
 <20180824113629.GI29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <103b1b33-1a1d-27a1-dcf8-5c8ad60056a6@i-love.sakura.ne.jp>
Date: Fri, 24 Aug 2018 22:02:23 +0900
MIME-Version: 1.0
In-Reply-To: <20180824113629.GI29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On 2018/08/24 20:36, Michal Hocko wrote:
>> That is, this API seems to be currently used by only out-of-tree users. Since
>> we can't check that nobody has memory allocation dependency, I think that
>> hmm_invalidate_range_start() should return -EAGAIN if blockable == false for now.
> 
> The code expects that the invalidate_range_end doesn't block if
> invalidate_range_start hasn't blocked. That is the reason why the end
> callback doesn't have blockable parameter. If this doesn't hold then the
> whole scheme is just fragile because those two calls should pair.
> 
That is

  More worrisome part in that patch is that I don't know whether using
  trylock if blockable == false at entry is really sufficient.

. Since those two calls should pair, I think that we need to determine whether
we need to return -EAGAIN at start call by evaluating both calls.

Like mn_invl_range_start() involves schedule_delayed_work() which could be
blocked on memory allocation under OOM situation, I worry that (currently
out-of-tree) users of this API are involving work / recursion.
And hmm_release() says that

	/*
	 * Drop mirrors_sem so callback can wait on any pending
	 * work that might itself trigger mmu_notifier callback
	 * and thus would deadlock with us.
	 */

and keeps "all operations protected by hmm->mirrors_sem held for write are
atomic". This suggests that "some operations protected by hmm->mirrors_sem held
for read will sleep (and in the worst case involves memory allocation
dependency)".
