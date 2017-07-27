Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CA92B6B049D
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:56:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q198so64854645qke.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:56:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si15529763qtf.39.2017.07.27.07.56.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 07:56:10 -0700 (PDT)
Date: Thu, 27 Jul 2017 16:55:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170727145559.GD29716@redhat.com>
References: <20170724161146.GQ25221@dhcp22.suse.cz>
 <20170725142626.GJ26723@dhcp22.suse.cz>
 <20170725151754.3txp44a2kbffsxdg@node.shutemov.name>
 <20170725152300.GM26723@dhcp22.suse.cz>
 <20170725153110.qzfz7wpnxkjwh5bc@node.shutemov.name>
 <20170725160359.GO26723@dhcp22.suse.cz>
 <20170725191952.GR29716@redhat.com>
 <20170726054557.GB960@dhcp22.suse.cz>
 <20170726162912.GA29716@redhat.com>
 <20170727065023.GB20970@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727065023.GB20970@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 27, 2017 at 08:50:24AM +0200, Michal Hocko wrote:
> Yes this will work and it won't depend on the oom_lock. But isn't it
> just more ugly than simply doing
> 
> 	if (tsk_is_oom_victim) {
> 		down_write(&mm->mmap_sem);
> 		locked = true;
> 	}
> 	free_pgtables(...)
> 	[...]
> 	if (locked)
> 		down_up(&mm->mmap_sem);

To me not doing if (tsk_is_oom...) { down_write; up_write } is by
default a confusing implementation, because it's not strict and not
strict code is not self documenting and you've to think twice of why
you're doing something the way you're doing it.

The doubt on what was the point to hold the mmap_sem during
free_pgtables is precisely why I started digging into this issue
because it didn't look possible you could truly benefit from holding
the mmap_sem during free_pgtables.

I also don't like having a new invariant that your solution relies on,
that is mm->mmap = NULL, when we can make just set the MMF_OOM_SKIP a
bit earlier that it gets set anyway and use that to control the other
side of the race.

I like strict code that uses as fewer invariants as possible and that
never holds a lock for any instruction more than it is required (again
purely for self documenting reasons, the CPU won't notice much one
instruction more or less).

Even with your patch the two branches are unnecessary, that may not be
measurable, but it's still wasted CPU. It's all about setting mm->mmap
before the up_write. In fact my patch should at least put an incremental
unlikely around my single branch added to exit_mmap.

I see the {down_write;up_write} Hugh's ksm_exit-like as a strict
solution to this issue and I wrote it specifically while trying to
research a way to be more strict because from the start it didn't look
the holding of the mmap_sem during free_pgtables was necessary.

I'm also fine to drop the oom_lock but I think it can be done
incrementally as it's a separate issue, my second patch should allow
for it with no adverse side effects.

All I care about is the exit_mmap path because it runs too many times
not to pay deep attention to every bit of it ;).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
