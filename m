Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BD17C6B025E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 17:25:21 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q79so688173qke.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 14:25:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 188si32423774qhy.42.2016.05.31.14.25.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 14:25:21 -0700 (PDT)
Date: Tue, 31 May 2016 23:25:17 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm, oom_reaper: do not use siglock in try_oom_reaper
Message-ID: <20160531212517.GA26582@redhat.com>
References: <1464679423-30218-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464679423-30218-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/31, Michal Hocko wrote:
>
> @@ -636,10 +634,7 @@ void try_oom_reaper(struct task_struct *tsk)
>  			 * If the task is exiting make sure the whole thread group
>  			 * is exiting and cannot acces mm anymore.
>  			 */
> -			spin_lock_irq(&p->sighand->siglock);
> -			exiting = signal_group_exit(p->signal);
> -			spin_unlock_irq(&p->sighand->siglock);
> -			if (exiting)
> +			if (signal_group_exit(p->signal))
>  				continue;

Yes, thanks Michal. signal_group_exit() is not really right too (coredump)
but this is not that important and you are going to rework this code anyway.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
