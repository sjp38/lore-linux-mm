Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEE76B0093
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 14:45:36 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: INFO: suspicious rcu_dereference_check() usage -  kernel/pid.c:419 invoked rcu_dereference_check() without protection!
References: <xr93fwwbdh1d.fsf@ninji.mtv.corp.google.com>
	<20101107182028.GZ15561@linux.vnet.ibm.com>
	<20101108151509.GA3702@redhat.com>
	<20101109202900.GV4032@linux.vnet.ibm.com>
	<20101110155530.GA1905@redhat.com> <20101110160211.GA2562@redhat.com>
	<4CDBD12C.4010807@kernel.dk> <20101111123015.GA25991@redhat.com>
	<4CDBE401.7040401@kernel.dk>
Date: Thu, 11 Nov 2010 11:45:17 -0800
In-Reply-To: <4CDBE401.7040401@kernel.dk> (Jens Axboe's message of "Thu, 11
	Nov 2010 13:39:29 +0100")
Message-ID: <xr93sjz73ar6.fsf@ninji.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <axboe@kernel.dk>
Cc: Oleg Nesterov <oleg@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens Axboe <axboe@kernel.dk> writes:

> On 2010-11-11 13:30, Oleg Nesterov wrote:
>> On 11/11, Jens Axboe wrote:
>>>
>>> On 2010-11-10 17:02, Oleg Nesterov wrote:
>>>>
>>>> But wait. Whatever we do, isn't this code racy? I do not see why, say,
>>>> sys_ioprio_set(IOPRIO_WHO_PROCESS) can't install ->io_context after
>>>> this task has already passed exit_io_context().
>>>>
>>>> Jens, am I missed something?
>>>
>>> Not sure, I think the original intent was for the tasklist_lock to
>>> protect from a concurrent exit, but that looks like nonsense and it was
>>> just there to protect the task lookup.
>> 
>> Probably. After that (perhaps) there was another reason, see
>> 
>> 	5b160f5e "copy_process: cosmetic ->ioprio tweak"
>> 	cf342e52 "Don't need to disable interrupts for tasklist_lock"
>> 
>> But this was dismissed by
>> 
>> 	fd0928df "ioprio: move io priority from task_struct to io_context"
>> 
>>> How about moving the ->io_context check and exit_io_context() in
>>> do_exit() under the task lock? Coupled with a check for PF_EXITING in
>>> set_task_ioprio().
>> 
>> Yes, I thought about this too. The only drawback is that we should
>> take task_lock() unconditionally in exit_io_context().
>
> Sure, not a big problem.
>
>> Btw, in theory get_task_ioprio() is racy too. "ret = p->io_context->ioprio"
>> can lead to use-after-free. Probably needs task_lock() as well.
>
> Indeed...
>
>> Hmm. And copy_io_context() has no callers ;)
>
> Good find. It was previously used by the AS io scheduler, seems there
> are no users left anymore. I queued up a patch to kill it.

>From this thread I gather the following changes are being proposed:

a) my original report added rcu_read_lock() to sys_ioprio_get() and
   claims that "something" is needed in sys_ioprio_set().

c) http://lkml.org/lkml/2010/10/29/168 added rcu locks to both
   sys_ioprio_get() and sys_ioprio_set() thus addressing the issues
   raised in a).  However, I do not see this patch in -mm.

   I just retested and confirmed that this warning still exists in
   unmodified mmotm-2010-11-09-15-31:
     Call Trace:
      [<ffffffff8109befc>] lockdep_rcu_dereference+0xaa/0xb3
      [<ffffffff81088aaf>] find_task_by_pid_ns+0x44/0x5d
      [<ffffffff81088aea>] find_task_by_vpid+0x22/0x24
      [<ffffffff81155ad2>] sys_ioprio_set+0xb4/0x29e
      [<ffffffff81476819>] ? trace_hardirqs_off_thunk+0x3a/0x3c
      [<ffffffff8105c409>] sysenter_dispatch+0x7/0x2c
      [<ffffffff814767da>] ? trace_hardirqs_on_thunk+0x3a/0x3f

   I can resubmit my patch, but want to know if there is a reason that
   http://lkml.org/lkml/2010/10/29/168 did not make it into either -mm
   or linux-next?

d) the sys_ioprio_set() comment indicating that "we can't use
   rcu_read_lock()" needs to be updated to be more clear.  I'm not sure
   what this should be updated to, which leads into the next
   sub-topic...

e) possibly removing tasklist_lock, though there seems to be some
   concern that this might introduce task->io_context usage race.  I
   think Jens is going to address this issue.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
