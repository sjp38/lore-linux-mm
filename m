Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 091736B0068
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 14:54:09 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1302723pad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 11:54:09 -0700 (PDT)
Date: Wed, 31 Oct 2012 11:54:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: zram OOM behavior
In-Reply-To: <20121031005738.GM15767@bbox>
Message-ID: <alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com>
References: <CAA25o9QcaqMsYV-Z6zTyKdXXwtCHCAV_riYv+Bhtv2RW0niJHQ@mail.gmail.com> <20121022235321.GK13817@bbox> <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com> <CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
 <alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com> <CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com> <20121030001809.GL15767@bbox> <CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
 <alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com> <CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com> <20121031005738.GM15767@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Wed, 31 Oct 2012, Minchan Kim wrote:

> It sounds right in your kernel but principal problem is min_filelist_kbytes patch.
> If normal exited process in exit path requires a page and there is no free page
> any more, it ends up going to OOM path after try to reclaim memory several time.
> Then,
> In select_bad_process,
> 
>         if (task->flags & PF_EXITING) {
>                if (task == current)             <== true
>                         return OOM_SCAN_SELECT;
> In oom_kill_process,
> 
>         if (p->flags & PF_EXITING)
>                 set_tsk_thread_flag(p, TIF_MEMDIE);
> 
> At last, normal exited process would get a free page.
> 

select_bad_process() won't actually select the process for oom kill, 
though, if there are other PF_EXITING threads other than current.  So if 
multiple threads are page faulting on tsk->robust_list, then no thread 
ends up getting killed.  The temporary workaround would be to do a kill -9 
so that the logic in out_of_memory() could immediately give such threads 
access to memory reserves so the page fault will succeed.  The real fix 
would be to audit all possible cases in between setting 
tsk->flags |= PF_EXITING and tsk->mm = NULL that could cause a memory 
allocation and make exemptions for them in oom_scan_process_thread().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
