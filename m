Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C9CD56B3033
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 10:52:47 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x145-v6so4306155oia.10
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:52:47 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o64-v6si4960190oih.242.2018.08.24.07.52.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 07:52:46 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: distinguish blockable mode for mmu notifiers
References: <20180716115058.5559-1-mhocko@kernel.org>
 <8cbfb09f-0c5a-8d43-1f5e-f3ff7612e289@I-love.SAKURA.ne.jp>
 <20180824113629.GI29735@dhcp22.suse.cz>
 <103b1b33-1a1d-27a1-dcf8-5c8ad60056a6@i-love.sakura.ne.jp>
 <20180824133207.GR29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <72844762-7398-c770-1702-f945573f4059@i-love.sakura.ne.jp>
Date: Fri, 24 Aug 2018 23:52:25 +0900
MIME-Version: 1.0
In-Reply-To: <20180824133207.GR29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Alex Deucher <alexander.deucher@amd.com>, David Airlie <airlied@linux.ie>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Felix Kuehling <felix.kuehling@amd.com>, kvm@vger.kernel.org, amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, linux-rdma@vger.kernel.org, xen-devel@lists.xenproject.org, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, Leon Romanovsky <leonro@mellanox.com>

On 2018/08/24 22:32, Michal Hocko wrote:
> On Fri 24-08-18 22:02:23, Tetsuo Handa wrote:
>> I worry that (currently
>> out-of-tree) users of this API are involving work / recursion.
> 
> I do not give a slightest about out-of-tree modules. They will have to
> accomodate to the new API. I have no problems to extend the
> documentation and be explicit about this expectation.

You don't need to care about out-of-tree modules. But you need to hear from
mm/hmm.c authors/maintainers when making changes for mmu-notifiers.

> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 133ba78820ee..698e371aafe3 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -153,7 +153,9 @@ struct mmu_notifier_ops {
>  	 *
>  	 * If blockable argument is set to false then the callback cannot
>  	 * sleep and has to return with -EAGAIN. 0 should be returned
> -	 * otherwise.
> +	 * otherwise. Please note that if invalidate_range_start approves
> +	 * a non-blocking behavior then the same applies to
> +	 * invalidate_range_end.

Prior to 93065ac753e44438 ("mm, oom: distinguish blockable mode for mmu
notifiers"), whether to utilize MMU_INVALIDATE_DOES_NOT_BLOCK was up to
mmu-notifiers users.

	-	 * If both of these callbacks cannot block, and invalidate_range
	-	 * cannot block, mmu_notifier_ops.flags should have
	-	 * MMU_INVALIDATE_DOES_NOT_BLOCK set.
	+	 * If blockable argument is set to false then the callback cannot
	+	 * sleep and has to return with -EAGAIN. 0 should be returned
	+	 * otherwise.

Even out-of-tree mmu-notifiers users had rights not to accommodate (i.e.
make changes) immediately by not setting MMU_INVALIDATE_DOES_NOT_BLOCK.

Now we are in a merge window. And we noticed a possibility that out-of-tree
mmu-notifiers users might have trouble with making changes immediately in order
to follow 93065ac753e44438 if expectation for mm/hmm.c changes immediately.
And you are trying to ignore such possibility by just updating expected behavior
description instead of giving out-of-tree users a grace period to check and update
their code.

>> and keeps "all operations protected by hmm->mirrors_sem held for write are
>> atomic". This suggests that "some operations protected by hmm->mirrors_sem held
>> for read will sleep (and in the worst case involves memory allocation
>> dependency)".
> 
> Yes and so what? The clear expectation is that neither of the range
> notifiers do not sleep in !blocking mode. I really fail to see what you
> are trying to say.

I'm saying "Get ACK from JA(C)rA'me about mm/hmm.c changes".
