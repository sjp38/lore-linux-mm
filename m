Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A2756B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 17:48:27 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q79so2494164qke.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 14:48:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x10si32560449qtc.54.2016.05.31.14.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 14:48:26 -0700 (PDT)
Date: Tue, 31 May 2016 23:48:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 5/6] mm, oom: kill all tasks sharing the mm
Message-ID: <20160531214823.GC26582@redhat.com>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-6-git-send-email-mhocko@kernel.org>
 <20160530181816.GA25480@redhat.com>
 <20160531074318.GD26128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531074318.GD26128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 05/31, Michal Hocko wrote:
>
> On Mon 30-05-16 20:18:16, Oleg Nesterov wrote:
> >
> > perhaps the is_global_init() == T case needs a warning too? the previous changes
> > take care about vfork() from /sbin/init, so the only reason we can see it true
> > is that /sbin/init shares the memory with a memory hog... Nevermind, forget.
>
> I have another two patches waiting for this to settle and one of them
> adds a warning to that path.

Good,

> > This is a bit off-topic, but perhaps we can also change the PF_KTHREAD check later.
> > Of course we should not try to kill this kthread, but can_oom_reap can be true in
> > this case. A kernel thread which does use_mm() should handle the errors correctly
> > if (say) get_user() fails because we unmap the memory.
>
> I was worried that the kernel thread would see a zero page so this could
> lead to a data corruption.

We can't avoid this anyway. use_mm(victim->mm) can be called after we decide to kill
the victim.

So I think that we should always ignore kthreads, and in task_will_free_mem() too.

But let me repeat, I agree we should discuss this later, I am not trying to suggest
this change right now.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
