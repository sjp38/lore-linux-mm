Received: from sj-msg-av-2.cisco.com (sj-msg-av-2.cisco.com [171.69.24.12])
	by sj-msg-core-4.cisco.com (8.12.2/8.12.2) with ESMTP id g7SJwGW4001304
	for <linux-mm@kvack.org>; Wed, 28 Aug 2002 12:58:16 -0700 (PDT)
Received: from nisser.cisco.com (localhost [127.0.0.1])
	by sj-msg-av-2.cisco.com (8.12.2/8.12.2) with ESMTP id g7SJwFL3006767
	for <linux-mm@kvack.org>; Wed, 28 Aug 2002 12:58:15 -0700 (PDT)
Received: from HZHONGW2K1 (dhcp-171-71-49-187.cisco.com [171.71.49.187]) by nisser.cisco.com (8.8.6 (PHNE_14041)/CISCO.SERVER.1.2) with SMTP id MAA01102 for <linux-mm@kvack.org>; Wed, 28 Aug 2002 12:58:14 -0700 (PDT)
From: "Hua Zhong" <hzhong@cisco.com>
Subject: [Q] task_lock and mm_struct protection
Date: Wed, 28 Aug 2002 12:58:13 -0700
Message-ID: <FEEFKBEFIEBONNKJABKDGEAAFGAA.hzhong@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <FEEFKBEFIEBONNKJABKDGEPMFFAA.hzhong@cisco.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Please cc to me as I am not on the list....

I have a locking question regarding to task_lock and mm_struct.

Typically when we need to read mm_struct of another process, we do something
like:

	task_lock(task);
	mm = task->mm;
	if(mm)
		atomic_inc(&mm->mm_users);
	task_unlock(task);
	if (mm) {
		do_something_time_consuming(mm);
		mmput(mm);
	}

If the do_something_time_consuming() is not really time consuming, we may
just do:

	task_lock(task);
	mm = task->mm;
	if(mm)
		do_something(mm);
	task_unlock(task);

Is this correct? Do I need to do atomic_inc and mmput around do_something?
I.e., does task_lock already protect the mm_struct? I think so, otherwise
anything bad can happen b/t if(mm) and do_something(mm).

However I looked at the code of exit_mm(), and didn't find obvious code that
proves so. It seems to be a race condition to me. This is the code:

static inline void __exit_mm(struct task_struct * tsk)
{
	struct mm_struct * mm = tsk->mm;

	mm_release();
	if (mm) {
		atomic_inc(&mm->mm_count);
		if (mm != tsk->active_mm) BUG();
		/* more a memory barrier than a real lock */
		task_lock(tsk);
		tsk->mm = NULL;
		enter_lazy_tlb(mm, current, smp_processor_id());
		task_unlock(tsk);
		mmput(mm);
	}
}

Apparently, mmput(mm) doesn't require task_lock (it's outside). So could
this happen:

A (exit_mm)                      B (do something)
task_unlock(tsk)
                                 task_lock(tsk)
                                 mm = task->mm;
                                 if(mm)
mmput(mm)
                                     do_something(mm);
                                 task_unlock(task);

In this case even you do atomic_inc/mmput around do_something it wouldn't
work. I think I must be missing something, but it seems to me a race
condition anyway.

Thanks for your reply.

Hua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
