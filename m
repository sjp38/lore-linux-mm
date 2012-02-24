Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 37EE46B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 16:37:56 -0500 (EST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 24 Feb 2012 14:37:54 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id B9F3CC40002
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 14:37:51 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1OLbiin118034
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 14:37:44 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1OLbtP7032725
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 14:37:55 -0700
Message-ID: <4F480326.8070706@linux.vnet.ibm.com>
Date: Fri, 24 Feb 2012 13:37:42 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231536240.13554@router.home> <m1ehtkapn9.fsf@fess.ebiederm.org> <alpine.DEB.2.00.1202240859340.2621@router.home> <4F47BF56.6010602@linux.vnet.ibm.com> <alpine.DEB.2.00.1202241053220.3726@router.home> <alpine.DEB.2.00.1202241105280.3726@router.home> <4F47C800.4090903@linux.vnet.ibm.com> <alpine.DEB.2.00.1202241131400.3726@router.home>
In-Reply-To: <alpine.DEB.2.00.1202241131400.3726@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/24/2012 09:32 AM, Christoph Lameter wrote:
> @@ -1318,10 +1318,10 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
>  	rcu_read_lock();
>  	task = pid ? find_task_by_vpid(pid) : current;
>  	if (!task) {
> -		rcu_read_unlock();
>  		err = -ESRCH;
>  		goto out;
>  	}
...
> +	put_task_struct(task);
> +	task = NULL;
>  	err = do_migrate_pages(mm, old, new,
>  		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
>  out:
> +	if (task)
> +		put_task_struct(task);
> +
>  	if (mm)
>  		mmput(mm);
>  	NODEMASK_SCRATCH_FREE(scratch);

Man, patch did not like this for some reason.  I kept throwing most of
the mempolicy.c hunks away.  I've never seen anything like it.

Anyway...  This looks fine except I think that rcu_read_unlock() need to
stay.  There's currently no release of it after out:.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
