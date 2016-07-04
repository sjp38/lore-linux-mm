Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 144E56B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 06:39:43 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id r68so158971266qka.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 03:39:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x18si1667122qtx.42.2016.07.04.03.39.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 03:39:42 -0700 (PDT)
Date: Mon, 4 Jul 2016 12:39:32 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/8] mm,oom: Use list of mm_struct used by OOM victims.
Message-ID: <20160704103931.GA3882@redhat.com>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607031138.AHB35971.FLVQOtJFOMFHSO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

Tetsuo,

I'll try to actually read this series later, although I will leave the
actual review to maintainers anyway...

Just a couple of questions for now,

On 07/03, Tetsuo Handa wrote:
>
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -722,6 +722,7 @@ static inline void __mmput(struct mm_struct *mm)
>  	}
>  	if (mm->binfmt)
>  		module_put(mm->binfmt->module);
> +	exit_oom_mm(mm);

Is it strictly necessary? At first glance not. Sooner or later oom_reaper() should
find this mm_struct and do exit_oom_mm(). And given that mm->mm_users is already 0
the "extra" __oom_reap_vmas() doesn't really hurt.

It would be nice to remove exit_oom_mm() from __mmput(); it takes the global spinlock
for the very unlikely case, and if we can avoid it here then perhaps we can remove
->oom_mm from mm_struct.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
