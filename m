Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1F06B004D
	for <linux-mm@kvack.org>; Thu, 23 Jul 2009 11:33:29 -0400 (EDT)
Message-ID: <4A6882C0.6020302@librato.com>
Date: Thu, 23 Jul 2009 11:33:20 -0400
From: Oren Laadan <orenl@librato.com>
MIME-Version: 1.0
Subject: Re: [RFC v17][PATCH 22/60] c/r: external checkpoint of a task	other
 than ourself
References: <1248256822-23416-1-git-send-email-orenl@librato.com> <1248256822-23416-23-git-send-email-orenl@librato.com> <20090723144753.GA12416@us.ibm.com>
In-Reply-To: <20090723144753.GA12416@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl@librato.com):
>> +/* setup checkpoint-specific parts of ctx */
>> +static int init_checkpoint_ctx(struct ckpt_ctx *ctx, pid_t pid)
>> +{
>> +	struct task_struct *task;
>> +	struct nsproxy *nsproxy;
>> +	int ret;
>> +
>> +	/*
>> +	 * No need for explicit cleanup here, because if an error
>> +	 * occurs then ckpt_ctx_free() is eventually called.
>> +	 */
>> +
>> +	ctx->root_pid = pid;
>> +
>> +	/* root task */
>> +	read_lock(&tasklist_lock);
>> +	task = find_task_by_vpid(pid);
>> +	if (task)
>> +		get_task_struct(task);
>> +	read_unlock(&tasklist_lock);
>> +	if (!task)
>> +		return -ESRCH;
>> +	else
>> +		ctx->root_task = task;
>> +
>> +	/* root nsproxy */
>> +	rcu_read_lock();
>> +	nsproxy = task_nsproxy(task);
>> +	if (nsproxy)
>> +		get_nsproxy(nsproxy);
>> +	rcu_read_unlock();
>> +	if (!nsproxy)
>> +		return -ESRCH;
>> +	else
>> +		ctx->root_nsproxy = nsproxy;
>> +
>> +	/* root freezer */
>> +	ctx->root_freezer = task;
>> +	geT_task_struct(task);
>> +
>> +	ret = may_checkpoint_task(ctx, task);
>> +	if (ret) {
>> +		ckpt_write_err(ctx, NULL);
>> +		put_task_struct(task);
>> +		put_task_struct(task);
>> +		put_nsproxy(nsproxy);
> 
> I don't think this is safe - the ckpt_ctx_free() will
> free them a second time because you're not setting them
> to NULL, right?

Yes. Fortunately this hole chunk is removed by the 3rd-next patch.
I'll make sure it's correct here too.

Thanks,

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
