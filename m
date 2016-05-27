Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53F726B0265
	for <linux-mm@kvack.org>; Fri, 27 May 2016 12:18:32 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w143so173776374oiw.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 09:18:32 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0137.outbound.protection.outlook.com. [157.56.112.137])
        by mx.google.com with ESMTPS id e189si14355486oig.162.2016.05.27.09.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 May 2016 09:18:31 -0700 (PDT)
Date: Fri, 27 May 2016 19:18:21 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 3/6] mm, oom_adj: make sure processes sharing mm have
 same view of oom_score_adj
Message-ID: <20160527161821.GE26059@esperanza>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
 <1464266415-15558-4-git-send-email-mhocko@kernel.org>
 <20160527111803.GG27686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160527111803.GG27686@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, May 27, 2016 at 01:18:03PM +0200, Michal Hocko wrote:
...
> @@ -1087,7 +1105,25 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>  	unlock_task_sighand(task, &flags);
>  err_put_task:
>  	put_task_struct(task);
> +
> +	if (mm) {
> +		struct task_struct *p;
> +
> +		rcu_read_lock();
> +		for_each_process(p) {
> +			task_lock(p);
> +			if (!p->vfork_done && process_shares_mm(p, mm)) {
> +				p->signal->oom_score_adj = oom_adj;
> +				if (!legacy && has_capability_noaudit(current, CAP_SYS_RESOURCE))
> +					p->signal->oom_score_adj_min = (short)oom_adj;
> +			}
> +			task_unlock(p);

I.e. you write to /proc/pid1/oom_score_adj and get
/proc/pid2/oom_score_adj updated if pid1 and pid2 share mm?
IMO that looks unexpected from userspace pov.

May be, we'd better add mm->oom_score_adj and set it to the min
signal->oom_score_adj over all processes sharing it? This would
require iterating over all processes every time oom_score_adj gets
updated, but that's a slow path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
