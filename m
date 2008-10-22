Message-ID: <48FE82DF.6030005@cs.columbia.edu>
Date: Tue, 21 Oct 2008 21:33:19 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v7][PATCH 2/9] General infrastructure for checkpoint	restart
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu> <1224481237-4892-3-git-send-email-orenl@cs.columbia.edu> <20081021124130.a002e838.akpm@linux-foundation.org> <20081021202410.GA10423@us.ibm.com>
In-Reply-To: <20081021202410.GA10423@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, tglx@linutronix.de, dave@linux.vnet.ibm.com, mingo@elte.hu, hpa@zytor.com, viro@zeniv.linux.org.uk
List-ID: <linux-mm.kvack.org>


Serge E. Hallyn wrote:
> Quoting Andrew Morton (akpm@linux-foundation.org):
>> On Mon, 20 Oct 2008 01:40:30 -0400
>> Oren Laadan <orenl@cs.columbia.edu> wrote:
>>>  asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>>>  {
>>> -	pr_debug("sys_checkpoint not implemented yet\n");
>>> -	return -ENOSYS;
>>> +	struct cr_ctx *ctx;
>>> +	int ret;
>>> +
>>> +	/* no flags for now */
>>> +	if (flags)
>>> +		return -EINVAL;
>>> +
>>> +	ctx = cr_ctx_alloc(pid, fd, flags | CR_CTX_CKPT);
>>> +	if (IS_ERR(ctx))
>>> +		return PTR_ERR(ctx);
>>> +
>>> +	ret = do_checkpoint(ctx);
>>> +
>>> +	if (!ret)
>>> +		ret = ctx->crid;
>>> +
>>> +	cr_ctx_free(ctx);
>>> +	return ret;
>>>  }
>> Is it appropriate that this be an unprivileged operation?
> 
> Early versions checked capable(CAP_SYS_ADMIN), and we reasoned that we
> would later attempt to remove the need for privilege so that all users
> could safely use it.
> 
> Arnd Bergmann called us on that nonsense, pointing out that it'd make
> more sense to let unprivileged users use them now, so that we'll be
> more careful about the security as patches roll in.
> 
> So, Oren's patchset right now only checkpoints current, despite pid
> being part of the API.  So the task can access its own data.  When
> the patch supports checkpointing another task (which Oren says he's
> doing right now), then our intent is to check for ptrace access to
> the target task.  (Right, Oren?)

Correct. That's already in the additional patch in the git tree - first
I locate the task and if found, I check ptrace_may_access() (read mode).

see the top patch in:
http://git.ncl.cs.columbia.edu/?p=linux-cr-dev.git;a=shortlog;h=refs/heads/ckpt-v7

> 
>> What happens if I pass it a pid which isn't system-wide unique?
> 
> pid must be checked in the caller's pid namespace.  So if I've create a
> container which I want to checkpoint, pid 1 in that pidns will be, say,
> 3497 in my pid_ns, and so 3497 is the pid I must use.  If I try to pass
> 1, I'll try to checkpoint my own container.  And, if I'm not privileged
> and init is owned by root, the ptrace() check I mentioned above will
> return -EPERM.

Yup.

> 
>> What happens if I pass it a pid of a process which I don't own?  This
>> is super security-sensitive and we need to go over the permission
>> checking with a toothcomb.  It needs to be exhaustively described in
>> the changelog.  It might have security/selinux implications - I don't
>> know, I didn't look, but lights are flashing and bells are ringing over
>> here.

This should be covered by ptrace_may_access() test.

In the longer run, I suppose SElinux people would want a security hook
there to approve or disapprove the operation.

>>
>> What happens if I pass it a pid of a process which I _do_ own, but it
>> does not refer to a container's init process?
> 
> I would assume that do_checkpoint() would return -EINVAL, but it's a
> great question:  Oren, did you have another plan?

Since we intentional provide minimal functionality to keep the patchset
simple and allow easy review - we only checkpoint one task; it doesn't
really matter because we don't deal with the entire container.

With the ability to checkpoint multiple process we will have to ensure
that we checkpoint an entire container. I planned to return -EINVAL if
the target task isn't a container init(1). Another option, if people
prefer, is to use any task in a container to "represent" the entire
container.

> 
>> If `pid' must refer to a container's init process, isn't it always
>> equal to 1??
> 
> Not in the caller's pid_namespace.
> 
>>>  /**
>>>   * sys_restart - restart a container
>>>   * @crid: checkpoint image identifier
>>> @@ -36,6 +234,19 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>>>   */
>>>  asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
>>>  {
>>> -	pr_debug("sys_restart not implemented yet\n");
>>> -	return -ENOSYS;
>>> +	struct cr_ctx *ctx;
>>> +	int ret;
>>> +
>>> +	/* no flags for now */
>>> +	if (flags)
>>> +		return -EINVAL;
>>> +
>>> +	ctx = cr_ctx_alloc(crid, fd, flags | CR_CTX_RSTR);
>>> +	if (IS_ERR(ctx))
>>> +		return PTR_ERR(ctx);
>>> +
>>> +	ret = do_restart(ctx);
>>> +
>>> +	cr_ctx_free(ctx);
>>> +	return ret;
>>>  }
>> Again, this is scary stuff.  We're allowing unprivileged userspace to
>> feed random numbers into kernel data structures.
> 
> Yes, all of the file opens and mmaps must not skip the usual security
> checks.  The task credentials are currently unsupported, meaning that
> euid, etc, come from the caller, not the checkpoint image.  When the

Actually, the fact that task credentials are not restored makes it
more secure, because the user can't do anything beyond her current
capabilities.

For the same reason, however, unless we agree on a secure way to
elevate credentials, there are various things that we cannot restore,
even though it may be something we would want to permit.

> restoration of credentials becomes supported, then definately the
> caller (of sys_restore())'s ability to setresuid/setresgid to those
> values must be checked.
> 
> So that's why we don't want CAP_SYS_ADMIN required up-front.  That way
> we will be forced to more carefully review each of those features.
> 
>> I'd like to see the security guys take a real close look at all of
>> this, and for them to do that effectively they should be provided with
>> a full description of the security design of this feature.
> 
> Right, some of the above should be spelled out somewhere.  Should it be
> in the patch description, in the Documentation/checkpoint.txt file,
> or someplace else?  Oren, do you want to filter the above information
> into the right place, or do you want me to do it and send you a patch?

I'll add something to the Documentation/checkpoint.txt.

Thanks,

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
