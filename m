Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m466TEOI004539
	for <linux-mm@kvack.org>; Tue, 6 May 2008 16:29:14 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m466XsgJ237812
	for <linux-mm@kvack.org>; Tue, 6 May 2008 16:33:54 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m466Tq0a029337
	for <linux-mm@kvack.org>; Tue, 6 May 2008 16:29:52 +1000
Message-ID: <481FFAAB.3030008@linux.vnet.ibm.com>
Date: Tue, 06 May 2008 11:58:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: on CONFIG_MM_OWNER=y, kernel panic is possible.
References: <481FF115.8030503@linux.vnet.ibm.com> <20080506150213.AC63.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080506151510.AC66.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080506151510.AC66.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>>> That is not possible. If you look at where mm_update_next_owner() is called
>>> from, we call it from
>>>
>>> exit_mm() and exec_mmap()
>>>
>>> In both cases, we ensure that the task's mm has changed (to NULL and the new mm
>>> respectively), before we call mm_update_next_owner(), hence c->mm can never be
>>> equal to p->mm.
>> if so, following patch is needed instead.
> 
> and, one more.
> 
> comment of owner member of mm_struct is bogus.
> that is not guranteed point to thread-group-leader.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> ---
>  include/linux/mm_types.h |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> Index: b/include/linux/mm_types.h
> ===================================================================
> --- a/include/linux/mm_types.h  2008-05-04 22:56:52.000000000 +0900
> +++ b/include/linux/mm_types.h  2008-05-06 15:53:04.000000000 +0900
> @@ -231,8 +231,7 @@ struct mm_struct {
>         rwlock_t                ioctx_list_lock;        /* aio lock */
>         struct kioctx           *ioctx_list;
>  #ifdef CONFIG_MM_OWNER
> -       struct task_struct *owner;      /* The thread group leader that */
> -                                       /* owns the mm_struct.          */
> +       struct task_struct *owner;      /* point to one of task that owns the mm_struct. */
>  #endif
> 
>  #ifdef CONFIG_PROC_FS
> 
> 
> 

How about just, the task that owns the mm_struct? One of, implies multiple owners.


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
