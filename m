Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CAF4C6B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 09:41:05 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id t12-v6so2911242plo.9
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 06:41:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d15-v6si14859705plj.284.2018.03.08.06.41.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Mar 2018 06:41:03 -0800 (PST)
Subject: Re: [PATCH] mm: oom: Fix race condition between oom_badness and
 do_exit of task
References: <1520427454-22813-1-git-send-email-gkohli@codeaurora.org>
 <alpine.DEB.2.20.1803071254410.165297@chino.kir.corp.google.com>
 <22ebd655-ece4-37e5-5a98-e9750cb20665@codeaurora.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <d73682f9-f214-64c4-ce09-fd1ff3ffe252@I-love.SAKURA.ne.jp>
Date: Thu, 8 Mar 2018 23:05:33 +0900
MIME-Version: 1.0
In-Reply-To: <22ebd655-ece4-37e5-5a98-e9750cb20665@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kohli, Gaurav" <gkohli@codeaurora.org>, David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org

On 2018/03/08 13:51, Kohli, Gaurav wrote:
> On 3/8/2018 2:26 AM, David Rientjes wrote:
> 
>> On Wed, 7 Mar 2018, Gaurav Kohli wrote:
>>
>>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>>> index 6fd9773..5f4cc4b 100644
>>> --- a/mm/oom_kill.c
>>> +++ b/mm/oom_kill.c
>>> @@ -114,9 +114,11 @@ struct task_struct *find_lock_task_mm(struct task_struct *p)
>>> A  A A A A A  for_each_thread(p, t) {
>>> A A A A A A A A A  task_lock(t);
>>> +A A A A A A A  get_task_struct(t);
>>> A A A A A A A A A  if (likely(t->mm))
>>> A A A A A A A A A A A A A  goto found;
>>> A A A A A A A A A  task_unlock(t);
>>> +A A A A A A A  put_task_struct(t);
>>> A A A A A  }
>>> A A A A A  t = NULL;
>>> A  found:
>> We hold rcu_read_lock() here, so perhaps only do get_task_struct() before
>> doing rcu_read_unlock() and we have a non-NULL t?
> 
> Here rcu_read_lock will not help, as our task may change due to below algo:
> 
> for_each_thread(p, t) {
> A A A A A A A A  task_lock(t);
> +A A A A A A A  get_task_struct(t);
> A A A A A A A A  if (likely(t->mm))
> A A A A A A A A A A A A  goto found;
> A A A A A A A A  task_unlock(t);
> +A A A A A A A  put_task_struct(t)
> 
> 
> So only we can increase usage counter here only at the current task.

static int proc_single_show(struct seq_file *m, void *v)
{
	struct inode *inode = m->private;
	struct pid_namespace *ns;
	struct pid *pid;
	struct task_struct *task;
	int ret;

	ns = inode->i_sb->s_fs_info;
	pid = proc_pid(inode);
	task = get_pid_task(pid, PIDTYPE_PID); /* get_task_struct() is called upon success. */
	if (!task)
		return -ESRCH;

	ret = PROC_I(inode)->op.proc_show(m, ns, pid, task);

	put_task_struct(task);
	return ret;
}

static int proc_oom_score(struct seq_file *m, struct pid_namespace *ns,
			  struct pid *pid, struct task_struct *task)
{
	unsigned long totalpages = totalram_pages + total_swap_pages;
	unsigned long points = 0;

	points = oom_badness(task, NULL, NULL, totalpages) *
			     1000 / totalpages; /* task->usage > 0 due to proc_single_show() */
	seq_printf(m, "%lu\n", points);

	return 0;
}

struct task_struct *find_lock_task_mm(struct task_struct *p) /* p->usage > 0 */
{
	struct task_struct *t;

	rcu_read_lock();

	for_each_thread(p, t) {
		task_lock(t);
		if (likely(t->mm))
			goto found;
		task_unlock(t);
	}
	t = NULL;
found:
	rcu_read_unlock();

	return t; /* t->usage > 0 even if t != p because t->mm != NULL */
}

t->alloc_lock is still held when leaving find_lock_task_mm(), which means
that t->mm != NULL. But nothing prevents t from setting t->mm = NULL at
exit_mm() from do_exit() and calling exit_creds() from __put_task_struct(t)
after task_unlock(t) is called. Seems difficult to trigger race window. Maybe
something has preempted because oom_badness() becomes outside of RCU grace
period upon leaving find_lock_task_mm() when called from proc_oom_score().
