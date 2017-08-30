Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB306B02B4
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 13:49:08 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l65so21004836qkc.1
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 10:49:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n5si5765853qkf.251.2017.08.30.10.49.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 10:49:07 -0700 (PDT)
Date: Wed, 30 Aug 2017 19:49:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH] mm, oom_reaper: skip mm structs with mmu notifiers
Message-ID: <20170830174904.GF13559@redhat.com>
References: <20170830084600.17491-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170830084600.17491-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Hello Michal,

On Wed, Aug 30, 2017 at 10:46:00AM +0200, Michal Hocko wrote:
> +	 * TODO: we really want to get rid of this ugly hack and make sure that
> +	 * notifiers cannot block for unbounded amount of time and add
> +	 * mmu_notifier_invalidate_range_{start,end} around unmap_page_range

KVM already should be ok in that respect. However the major reason to
prefer mmu_notifier_invalidate_range_start/end is those can block and
schedule waiting for stuff happening behind the PCI bus easily. So I'm
not sure if the TODO is good idea to keep.

> +	 */
> +	if (mm_has_notifiers(mm)) {
> +		schedule_timeout_idle(HZ);

Why the schedule_timeout? What's the difference with the OOM
reaper going to sleep again in the main loop instead?

> +		goto unlock_oom;
> +	}

mm_has_notifiers stops changing after obtaining the mmap_sem for
reading. See the do_mmu_notifier_register. So it's better to put the
mm_has_notifiers check immediately after the below:

>  	if (!down_read_trylock(&mm->mmap_sem)) {
>  		ret = false;
>  		trace_skip_task_reaping(tsk->pid);

If we succeed taking the mmap_sem for reading then we read a stable
value out of mm_has_notifiers and be sure it won't be set from under
us.

Otherwise the patch looks fine including the incremental comment about
why the mmu_notifier_invalidate_range in MMU gather wasn't enough.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
