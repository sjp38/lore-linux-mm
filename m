Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id DA5226B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 11:13:06 -0400 (EDT)
Received: by qgev79 with SMTP id v79so60140729qge.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 08:13:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 201si13027025qhx.44.2015.09.19.08.13.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 08:13:06 -0700 (PDT)
Date: Sat, 19 Sep 2015 17:10:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150919151006.GC31952@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150919150316.GB31952@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

(off-topic)

On 09/19, Oleg Nesterov wrote:
>
> @@ -570,8 +590,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		victim = p;
>  	}
>
> -	/* mm cannot safely be dereferenced after task_unlock(victim) */
>  	mm = victim->mm;
> +	atomic_inc(&mm->mm_count);

Btw, I think we need this change anyway. This is pure theoretical, but
otherwise this task can exit and free its mm_struct right after task_unlock(),
then this mm_struct can be reallocated and used by another task, so we
can't trust the "p->mm == mm" check below.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
