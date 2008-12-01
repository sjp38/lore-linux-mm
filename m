Message-ID: <49344FA5.90004@cs.columbia.edu>
Date: Mon, 01 Dec 2008 15:57:09 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v10][PATCH 05/13] Dump memory address space
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>	 <1227747884-14150-6-git-send-email-orenl@cs.columbia.edu>	 <20081128105351.GQ28946@ZenIV.linux.org.uk> <1228154412.2971.44.camel@nimitz>
In-Reply-To: <1228154412.2971.44.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>



Dave Hansen wrote:
> On Fri, 2008-11-28 at 10:53 +0000, Al Viro wrote:
>>> +static int cr_ctx_checkpoint(struct cr_ctx *ctx, pid_t pid)
>>> +{
>>> +     ctx->root_pid = pid;
>>> +
>>> +     /*
>>> +      * assume checkpointer is in container's root vfs
>>> +      * FIXME: this works for now, but will change with real containers
>>> +      */
>>> +     ctx->vfsroot = &current->fs->root;
>>> +     path_get(ctx->vfsroot);
>> This is going to break as soon as you get another thread doing e.g. chroot(2)
>> while you are in there.
> 
> Yeah, we do need at least a read_lock(&current->fs->lock) to keep people
> from chroot()'ing underneath us.

True.
(while adapting older and safer code I omitted these tests with no reason).

> 
>> And it's a really, _really_ bad idea to take a
>> pointer to shared object, increment refcount on the current *contents* of
>> said object and assume that dropping refcount on the later contents of the
>> same will balance out.
> 
> Absolutely.  I assume you mean get_fs_struct(current) instead of
> path_get().

True.

Should change the type of ctx->vfsroot to not be a pointer, and do:

>>> +     ctx->vfsroot = *current->fs->root;
>>> +     path_get(&ctx->vfsroot);

and adjust accordingly in where the refcount is dropped.

What we need here is a reference point (this will change later when we handle
multiple fs-namespaces), which is the path of the "container root". Assuming
locking is correct so that current->fs does not change under us, it's enough
to get that path and later release that path.

BW, the current->fs is assumed to not change during the checkpoint; if it does,
then it's a mis-use of the checkpoint interface, and the resulting behavior
is undefined - restart is guaranteed to restore the exact old state even if
checkpoint succeeds.

Thanks,

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
