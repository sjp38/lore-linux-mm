Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CFD5F6B004A
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 06:19:14 -0500 (EST)
Message-ID: <4CDBD12C.4010807@kernel.dk>
Date: Thu, 11 Nov 2010 12:19:08 +0100
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: INFO: suspicious rcu_dereference_check() usage -  kernel/pid.c:419
 invoked rcu_dereference_check() without protection!
References: <xr93fwwbdh1d.fsf@ninji.mtv.corp.google.com> <20101107182028.GZ15561@linux.vnet.ibm.com> <20101108151509.GA3702@redhat.com> <20101109202900.GV4032@linux.vnet.ibm.com> <20101110155530.GA1905@redhat.com> <20101110160211.GA2562@redhat.com>
In-Reply-To: <20101110160211.GA2562@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2010-11-10 17:02, Oleg Nesterov wrote:
> (another try with the proper email address)
> 
> On 11/09, Paul E. McKenney wrote:
>>
>> Thank you, Oleg!  Greg, would you be willing to update your patch
>> to remove the comment?  (Perhaps tasklist_lock as well...)
> 
> Agreed, I think tasklock should be killed.
> 
> 
> But wait. Whatever we do, isn't this code racy? I do not see why, say,
> sys_ioprio_set(IOPRIO_WHO_PROCESS) can't install ->io_context after
> this task has already passed exit_io_context().
> 
> Jens, am I missed something?

Not sure, I think the original intent was for the tasklist_lock to
protect from a concurrent exit, but that looks like nonsense and it was
just there to protect the task lookup.

How about moving the ->io_context check and exit_io_context() in
do_exit() under the task lock? Coupled with a check for PF_EXITING in
set_task_ioprio().


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
