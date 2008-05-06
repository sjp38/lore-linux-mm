Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m466X2hE028416
	for <linux-mm@kvack.org>; Tue, 6 May 2008 12:03:02 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m466Ws971401010
	for <linux-mm@kvack.org>; Tue, 6 May 2008 12:02:54 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m466X2a5009238
	for <linux-mm@kvack.org>; Tue, 6 May 2008 12:03:02 +0530
Message-ID: <481FFB6B.2000305@linux.vnet.ibm.com>
Date: Tue, 06 May 2008 12:02:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: on CONFIG_MM_OWNER=y, kernel panic is possible.
References: <20080506142255.AC5D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <481FF115.8030503@linux.vnet.ibm.com> <20080506150213.AC63.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080506150213.AC63.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>> That is not possible. If you look at where mm_update_next_owner() is called
>> from, we call it from
>>
>> exit_mm() and exec_mmap()
>>
>> In both cases, we ensure that the task's mm has changed (to NULL and the new mm
>> respectively), before we call mm_update_next_owner(), hence c->mm can never be
>> equal to p->mm.
> 
> if so, following patch is needed instead.
> 
> 
> 
> ---
>  fs/exec.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: b/fs/exec.c
> ===================================================================
> --- a/fs/exec.c 2008-05-04 22:57:09.000000000 +0900
> +++ b/fs/exec.c 2008-05-06 15:40:35.000000000 +0900
> @@ -735,7 +735,7 @@ static int exec_mmap(struct mm_struct *m
>         tsk->active_mm = mm;
>         activate_mm(active_mm, mm);
>         task_unlock(tsk);
> -       mm_update_next_owner(mm);
> +       mm_update_next_owner(old_mm);
>         arch_pick_mmap_layout(mm);
>         if (old_mm) {
>                 up_read(&old_mm->mmap_sem);
> 
> 

Yes, good catch.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

I'll go ahead and do some more testing on top of it. CC'ing Paul Menage as well.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
