Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 405016B0253
	for <linux-mm@kvack.org>; Fri, 27 May 2016 12:48:39 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 82so193101362ior.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:48:39 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0135.outbound.protection.outlook.com. [157.55.234.135])
        by mx.google.com with ESMTPS id f127si14435060oic.113.2016.05.27.09.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 May 2016 09:48:38 -0700 (PDT)
Date: Fri, 27 May 2016 19:48:30 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 4/6] mm, oom: skip over vforked tasks
Message-ID: <20160527164830.GF26059@esperanza>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-5-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1464266415-15558-5-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Thu, May 26, 2016 at 02:40:13PM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> vforked tasks are not really sitting on memory so it doesn't matter much
> to kill them. Parents are waiting for vforked task killable so it is
> better to chose parent which is the real mm owner. Teach oom_badness
> to ignore all tasks which haven't passed mm_release. oom_kill_process
> should ignore them as well because they will drop the mm soon and they
> will not block oom_reaper because they cannot touch any memory.

That is, if a process calls vfork->exec to spawn a child, and a newly
spawned child happens to invoke oom somewhere in exec, instead of
killing the child, which hasn't done anything yet, we'll kill the main
process while the child continues to run. Not sure if it's really bad
though.

...
> @@ -839,6 +841,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	for_each_process(p) {
>  		if (!process_shares_mm(p, mm))
>  			continue;
> +		/*
> +		 * vforked tasks are ignored because they will drop the mm soon
> +		 * hopefully and even if not they will not mind being oom
> +		 * reaped because they cannot touch any memory.

They shouldn't modify memory, but they still can touch it AFAIK.

> +		 */
> +		if (p->vfork_done)
> +			continue;
>  		if (same_thread_group(p, victim))
>  			continue;
>  		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
