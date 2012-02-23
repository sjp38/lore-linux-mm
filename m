Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 1224B6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 14:12:10 -0500 (EST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 23 Feb 2012 12:12:08 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 3EA553E40047
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 12:10:46 -0700 (MST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1NJAdD7106300
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 12:10:40 -0700
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1NJA5MZ003620
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 17:10:05 -0200
Message-ID: <4F468F09.5050200@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2012 11:10:01 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home>
In-Reply-To: <alpine.DEB.2.00.1202231240590.9878@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/23/2012 10:45 AM, Christoph Lameter wrote:
> On Thu, 23 Feb 2012, Dave Hansen wrote:
>> This patch takes the pid-to-task code along with the credential
>> and security checks in sys_move_pages() and sys_migrate_pages()
>> and consolidates them.  It now takes a task reference in
>> the new function and requires the caller to drop it.  I
>> believe this resolves the race.
> 
> And this way its safer?

I think so... I'll talk about it below.

>> diff -puN include/linux/migrate.h~movememory-helper include/linux/migrate.h
>> --- linux-2.6.git/include/linux/migrate.h~movememory-helper	2012-02-16 09:59:17.270207242 -0800
>> +++ linux-2.6.git-dave/include/linux/migrate.h	2012-02-16 09:59:17.286207438 -0800
>> @@ -31,6 +31,7 @@ extern int migrate_vmas(struct mm_struct
>>  extern void migrate_page_copy(struct page *newpage, struct page *page);
>>  extern int migrate_huge_page_move_mapping(struct address_space *mapping,
>>  				  struct page *newpage, struct page *page);
>> +struct task_struct *can_migrate_get_task(pid_t pid);
> 
> Could we use something easier to understand? try_get_task()?

It's hard to see in the patch context, but can_migrate_get_task() does
two migration-specific operations:

>         tcred = __task_cred(task);
>         if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
>             cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
>             !capable(CAP_SYS_NICE)) {
>                 err = -EPERM;
>                 goto out;
>         }
> 
>         err = security_task_movememory(task);

So, I was trying to relate that it's checking the current's permissions
to _do_ migration on task.  try_get_task() wouldn't really say much
about that part of its job.


>> +struct task_struct *can_migrate_get_task(pid_t pid)
>>  {
>> -	const struct cred *cred = current_cred(), *tcred;
>>  	struct task_struct *task;
>> -	struct mm_struct *mm;
>> -	int err;
>> -
>> -	/* Check flags */
>> -	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
>> -		return -EINVAL;
>> -
>> -	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
>> -		return -EPERM;
>> +	const struct cred *cred = current_cred(), *tcred;
>> +	int err = 0;
>>
>> -	/* Find the mm_struct */
>>  	rcu_read_lock();
>>  	task = pid ? find_task_by_vpid(pid) : current;
>>  	if (!task) {
>>  		rcu_read_unlock();
>> -		return -ESRCH;
>> +		return ERR_PTR(-ESRCH);
>>  	}
>> -	mm = get_task_mm(task);
>> -	rcu_read_unlock();
>> -
>> -	if (!mm)
>> -		return -EINVAL;
>> +	get_task_struct(task);
> 
> Hmmm isnt the race still there between the determination of the task and
> the get_task_struct()? You would have to verify after the get_task_struct
> that this is really the task we wanted to avoid the race.

It's true that selecting a task by pid is inherently racy.  What that
code does is ensure that the task you've got current has 'pid', but not
ensure that 'pid' has never represented another task.  But, that's what
we do everywhere else in the kernel; there's not much better that we can do.

Maybe "race" is the wrong word for what we've got here.  It's a lack of
a refcount being taken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
