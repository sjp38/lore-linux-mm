Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD2D6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 21:50:07 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id x7so224570883qkd.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 18:50:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g143si15515369qhc.45.2016.05.19.18.50.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 18:50:04 -0700 (PDT)
Date: Fri, 20 May 2016 03:50:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160520015000.GA20132@redhat.com>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
 <20160518141545.GI21654@dhcp22.suse.cz>
 <20160518140932.6643b963e8d3fc49ff64df8d@linux-foundation.org>
 <20160519065329.GA26110@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160519065329.GA26110@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org

On 05/19, Michal Hocko wrote:
>
> Long term I
> would like to to move this logic into the mm_struct, it would be just
> larger surgery I guess.

Why we can't do this right now? Just another MMF_ flag set only once and
never cleared.

And. I personally like this change "in general", if nothing else I recently
blamed this for_each_process_thread() loop. But if we do this, I think we
should also shift find_lock_task_mm() into this loop.

And this makes me think again we need something like

	struct task_struct *next_task_with_mm(struct task_struct *p)
	{
		struct task_struct *t;

		p = p->group_leader;
		while ((p = next_task(p)) != &init_task) {
			if (p->flags & PF_KTHREAD)
				continue;

			t = find_lock_task_mm(p);
			if (t)
				return t;
		}

		return NULL;
	}

	#define for_each_task_lock_mm(p)
		for (p = &init_task; (p = next_task_with_mm(p)); task_unlock(p))

Or we we can move task_unlock() into next_task_with_mm(), it can check mm != NULL
or p != init_task.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
