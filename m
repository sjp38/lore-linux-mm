Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C618C6B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 00:15:26 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so157276666pdb.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 21:15:26 -0700 (PDT)
Received: from out11.biz.mail.alibaba.com (out114-135.biz.mail.alibaba.com. [205.204.114.135])
        by mx.google.com with ESMTP id nh9si7159780pdb.77.2015.07.08.21.15.24
        for <linux-mm@kvack.org>;
        Wed, 08 Jul 2015 21:15:25 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [patch v3 3/3] mm, oom: do not panic for oom kills triggered from sysrq
Date: Thu, 09 Jul 2015 12:15:01 +0800
Message-ID: <02e601d0b9fd$d644ec50$82cec4f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> Sysrq+f is used to kill a process either for debug or when the VM is
> otherwise unresponsive.
> 
> It is not intended to trigger a panic when no process may be killed.
> 
> Avoid panicking the system for sysrq+f when no processes are killed.
> 
> Suggested-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  v2: no change
>  v3: fix title per Hillf
> 
>  Documentation/sysrq.txt | 3 ++-
>  mm/oom_kill.c           | 7 +++++--
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/sysrq.txt b/Documentation/sysrq.txt
> --- a/Documentation/sysrq.txt
> +++ b/Documentation/sysrq.txt
> @@ -75,7 +75,8 @@ On all -  write a character to /proc/sysrq-trigger.  e.g.:
> 
>  'e'     - Send a SIGTERM to all processes, except for init.
> 
> -'f'	- Will call oom_kill to kill a memory hog process.
> +'f'	- Will call the oom killer to kill a memory hog process, but do not
> +	  panic if nothing can be killed.
> 
>  'g'	- Used by kgdb (kernel debugger)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -607,6 +607,9 @@ void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint,
>  		if (constraint != CONSTRAINT_NONE)
>  			return;
>  	}
> +	/* Do not panic for oom kills triggered by sysrq */
> +	if (oc->order == -1)
> +		return;
>  	dump_header(oc, NULL, memcg);
>  	panic("Out of memory: %s panic_on_oom is enabled\n",
>  		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
> @@ -686,11 +689,11 @@ bool out_of_memory(struct oom_control *oc)
> 
>  	p = select_bad_process(oc, &points, totalpages);
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
> -	if (!p) {
> +	if (!p && oc->order != -1) {
>  		dump_header(oc, NULL, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}

Given sysctl_panic_on_oom checked, AFAICU there seems
no chance for panic, no matter -1 or not.

> -	if (p != (void *)-1UL) {
> +	if (p && p != (void *)-1UL) {
>  		oom_kill_process(oc, p, points, totalpages, NULL,
>  				 "Out of memory");
>  		killed = 1;
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
