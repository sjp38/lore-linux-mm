Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2024A6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 07:39:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id h16so12389392wrf.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:39:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s95si7089422wrc.364.2017.09.26.04.39.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 04:39:54 -0700 (PDT)
Date: Tue, 26 Sep 2017 13:39:51 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,oom: Warn on racing with MMF_OOM_SKIP at
 task_will_free_mem(current).
Message-ID: <20170926113951.g5dr4rplcbjjugno@dhcp22.suse.cz>
References: <1506070646-4549-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170925143052.a57bqoiw6yuckwee@dhcp22.suse.cz>
 <201709262027.IJC34322.tMFOJFSOFVLHQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201709262027.IJC34322.tMFOJFSOFVLHQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov.dev@gmail.com, torvalds@linux-foundation.org

On Tue 26-09-17 20:27:40, Tetsuo Handa wrote:
[...]
> @@ -794,8 +794,10 @@ static bool task_will_free_mem(struct task_struct *task)
>  	 * This task has already been drained by the oom reaper so there are
>  	 * only small chances it will free some more
>  	 */
> -	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> +	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
> +		WARN(1, "Racing OOM victim selection. Please report to linux-mm@kvack.org if you saw this warning from non-artificial workloads.\n");
>  		return false;
> +	}

This can easily happen even without a race. Just consider that OOM
memory reserves got depleted. I think that the existing oom report will
tell us that the race happened by checking the mm counters.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
