Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 695C96B0071
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 11:10:44 -0400 (EDT)
Received: by pwi7 with SMTP id 7so4331424pwi.14
        for <linux-mm@kvack.org>; Wed, 16 Jun 2010 08:10:42 -0700 (PDT)
Date: Thu, 17 Jun 2010 00:02:32 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/9] oom: oom_kill_process() doesn't select kthread
 child
Message-ID: <20100616150232.GC9278@barrios-desktop>
References: <20100616201948.72D7.A69D9226@jp.fujitsu.com>
 <20100616203126.72DD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100616203126.72DD.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 08:32:08PM +0900, KOSAKI Motohiro wrote:
> Now, select_bad_process() have PF_KTHREAD check, but oom_kill_process
> doesn't. It mean oom_kill_process() may choose wrong task, especially,
> when the child are using use_mm().
Now oom_kill_process is called by three place. 

1. mem_cgroup_out_of_memory
2. out_of_memory with sysctl_oom_kill_allocating_task
3. out_of_memory with non-sysctl_oom_kill_allocating_task

I think it's no problem in 1 and 3 since select_bad_process already checks
PF_KTHREAD. The problem in in 2. 
So How about put the check before calling oom_kill_process in case of
sysctl_oom_kill_allocating task?

if (sysctl_oom_kill_allocating_task) {
        if (!current->flags & PF_KTHREAD)
                oom_kill_process();
                        
It can remove duplicated PF_KTHREAD check in select_bad_process and
oom_kill_process. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
