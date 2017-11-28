Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D09C96B0038
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 09:07:30 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 81so819602iof.4
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 06:07:30 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r64si5155222ioe.31.2017.11.28.06.07.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 06:07:28 -0800 (PST)
Subject: Re: [PATCH] mm,oom: Set ->signal->oom_mm to all thread groups sharing the victim's mm.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511872888-4579-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171128130017.ma4qzyjay7p2zsbg@dhcp22.suse.cz>
In-Reply-To: <20171128130017.ma4qzyjay7p2zsbg@dhcp22.suse.cz>
Message-Id: <201711282307.EBG97690.MQVOFLFFOJHtOS@I-love.SAKURA.ne.jp>
Date: Tue, 28 Nov 2017 23:07:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Tue 28-11-17 21:41:28, Tetsuo Handa wrote:
> > Due to commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> > oom_reaped tasks") and patch "mm,oom: Use ALLOC_OOM for OOM victim's last
> > second allocation.", thread groups sharing the OOM victim's mm without
> > setting ->signal->oom_mm before task_will_free_mem(current) is called
> > might fail to try ALLOC_OOM allocation attempt.
> 
> Look, this is getting insane. The code complexity grows without any
> real users asking for this.

This is the result of applying "mm,oom: Use ALLOC_OOM for OOM victim's
last second allocation." instead of "mm, oom: task_will_free_mem(current)
should ignore MMF_OOM_SKIP for once." More you go per-mm oriented rather
than per-signal oriented or per-thread oriented, more atomicity will be
needed.

>                             While this might look like an interesting
> excercise to you I really hate the direction you are heading. This code
> will always be just a heuristic and the more complicated it will be the
> bigger chances of other side effects there will be as well.
> 
> So NACK to this unless I you can show a _real_ usecase that would
> _suffer_ by this corner case.

But we send SIGKILL to all thread groups sharing the OOM victim's memory.
This means that (though it might be artificial/malicious) there can be
programs which hit this corner case.

This resembles setting TIF_MEMDIE to all threads at mark_oom_victim(),
and (if I understand correctly) cgroup-aware OOM killer discussion is
after all trying to split oom_kill_process() into "printk()" part and
"non-printk()" part.

Also, please don't preserve outdated comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
