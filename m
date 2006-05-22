Date: Mon, 22 May 2006 11:03:21 -0400 (EDT)
From: James Morris <jmorris@namei.org>
Subject: Re: Extract have_task_perm() from kill and migrate functions.
In-Reply-To: <Pine.LNX.4.64.0605220719310.3432@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0605221047070.25125@d.namei>
References: <Pine.LNX.4.64.0605220719310.3432@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 May 2006, Christoph Lameter wrote:

> +int have_task_perm(struct task_struct *t, int capability)
> +{
> +	if (capable(capability))
> +		return 1;
> +
> +	return (current->euid == t->suid || current->euid == t->uid ||
> +		  current->uid == t->suid || current->uid == t->uid);
> +}

There's another fairly common variant of this, for example, in 
sys_get_robust_list():

	if ((current->euid != p->euid) && (current->euid != p->uid) &&
                                !capable(CAP_SYS_PTRACE))

So I'd suggest a function for each.

Not sure this stuff belongs in kernel/signal.c.  What about 
kernel/capability.c and name the functions something like:

task_cap_or_perm_euid(task, cap)
task_cap_or_perm_suid(task, cap)

As for the rights stored in various kernel structures, I gather you mean 
examples like the calls in sys_shmctl().  In that case, perhaps make the 
above wrappers for functions which take the uid/euid/suid values as 
parameters:

cap_or_perm_euid(uid, euid, cap)
cap_or_perm_suid(uid, suid, cap)

then

static inline int task_cap_or_perm_euid(task, cap)
{
	return cap_or_perm_euid(task->uid, task->euid, cap);
}

Or similar.


- James
-- 
James Morris
<jmorris@namei.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
