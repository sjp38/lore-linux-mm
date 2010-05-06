Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3844262009A
	for <linux-mm@kvack.org>; Thu,  6 May 2010 16:28:28 -0400 (EDT)
Message-ID: <4BE32640.8010402@oracle.com>
Date: Thu, 06 May 2010 13:27:44 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v21 020/100] c/r: documentation
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>	<1272723382-19470-21-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1272723382-19470-21-git-send-email-orenl@cs.columbia.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Matt Helsley <matthltc@us.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, linux-api@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat,  1 May 2010 10:15:02 -0400 Oren Laadan wrote:

> Covers application checkpoint/restart, overall design, interfaces,
> usage, shared objects, and and checkpoint image format.
> 
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> Acked-by: Serge E. Hallyn <serue@us.ibm.com>
> Tested-by: Serge E. Hallyn <serue@us.ibm.com>
> ---
>  Documentation/checkpoint/checkpoint.c      |   38 +++
>  Documentation/checkpoint/readme.txt        |  370 ++++++++++++++++++++++++++++
>  Documentation/checkpoint/self_checkpoint.c |   69 +++++
>  Documentation/checkpoint/self_restart.c    |   40 +++
>  Documentation/checkpoint/usage.txt         |  247 +++++++++++++++++++
>  5 files changed, 764 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/checkpoint/checkpoint.c
>  create mode 100644 Documentation/checkpoint/readme.txt
>  create mode 100644 Documentation/checkpoint/self_checkpoint.c
>  create mode 100644 Documentation/checkpoint/self_restart.c
>  create mode 100644 Documentation/checkpoint/usage.txt

> diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
> new file mode 100644
> index 0000000..4fa5560
> --- /dev/null
> +++ b/Documentation/checkpoint/readme.txt
> @@ -0,0 +1,370 @@
> +
...
> +In contrast, when checkpointing a subtree of a container it is up to
> +the user to ensure that dependencies either don't exist or can be
> +safely ignored. This is useful, for instance, for HPC scenarios or
> +even a user that would like to periodically checkpoint a long-running

               who

> +batch job.
> +
...

> +
> +Checkpoint image format
> +=======================
> +
...

> +
> +The container configuration section containers information that is

                                       contains

> +global to the container. Security (LSM) configuration is one example.
> +Network configuration and container-wide mounts may also go here, so
> +that the userspace restart coordinator can re-create a suitable
> +environment.
> +
...

> +
> +Then the state of all tasks is saved, in the order that they appear in
> +the tasks array above. For each state, we save data like task_struct,
> +namespaces, open files, memory layout, memory contents, cpu state,

                                                           CPU (throughout, please)

> +signals and signal handlers, etc. For resources that are shared among
> +multiple processes, we first checkpoint said resource (and only once),
> +and in the task data we give a reference to it. More about shared
> +resources below.
> +
...

> +
> +Shared objects
> +==============
> +
> +Many resources may be shared by multiple tasks (e.g. file descriptors,
> +memory address space, etc), or even have multiple references from

                         etc.),

> +other resources (e.g. a single inode that represents two ends of a
> +pipe).
> +
...

> +Memory contents format
> +======================
> +
> +The memory contents of a given memory address space (->mm) is dumped

                                                              are (I think)

> +as a sequence of vma objects, represented by 'struct ckpt_hdr_vma'.
> +This header details the vma properties, and a reference to a file
> +(if file backed) or an inode (or shared memory) object.
> +
> +The vma header is followed by the actual contents - but only those
> +pages that need to be saved, i.e. dirty pages. They are written in
> +chunks of data, where each chunks contains a header that indicates

                              chunk

> +that number of pages in the chunk, followed by an array of virtual

   the

> +addresses and then an array of actual page contents. The last chunk
> +holds zero pages.
> +
...

> +Kernel interfaces
> +=================
> +
> +* To checkpoint a vma, the 'struct vm_operations_struct' needs to
> +  provide a method ->checkpoint:
> +    int checkpoint(struct ckpt_ctx *, struct vma_struct *)
> +  Restart requires a matching (exported) restore:
> +    int restore(struct ckpt_ctx *, struct mm_struct *, struct ckpt_hdr_vma *)
> +
> +* To checkpoint a file, the 'struct file_operations' needs to provide
> +  the methods ->checkpoint and ->collect:
> +    int checkpoint(struct ckpt_ctx *, struct file *)
> +    int collect(struct ckpt_ctx *, struct file *)
> +  Restart requires a matching (exported) restore:
> +    int restore(struct ckpt_ctx *, struct ckpt_hdr_file *)
> +  For most file systems, generic_file_{checkpoint,restore}() can be
> +  used.
> +
> +* To checkpoint a socket, the 'struct proto_ops' needs to provide

     To checkpoint/restart a socket,

> +  the methods ->checkpoint, ->collect and ->restore:
> +    int checkpoint(struct ckpt_ctx *ctx, struct socket *sock);
> +    int collect(struct ckpt_ctx *ctx, struct socket *sock);
> +    int restore(struct ckpt_ctx *, struct socket *sock, struct ckpt_hdr_socket *h)


> diff --git a/Documentation/checkpoint/usage.txt b/Documentation/checkpoint/usage.txt
> new file mode 100644
> index 0000000..c6fc045
> --- /dev/null
> +++ b/Documentation/checkpoint/usage.txt
> @@ -0,0 +1,247 @@
> +
> +	      How to use Checkpoint-Restart
> +	=========================================
> +
> +
> +API
> +===
> +
> +The API consists of three new system calls:
> +
> +* long checkpoint(pid_t pid, int fd, unsigned long flag, int logfd);

                                                      flags,

> +
> + Checkpoint a (sub-)container whose root task is identified by @pid,
> + to the open file indicated by @fd. If @logfd isn't -1, it indicates
> + an open file to which error and debug messages are written. @flags
> + may be one or more of:
> +   - CHECKPOINT_SUBTREE : allow checkpoint of sub-container
> + (other value are not allowed).
> +
> + Returns: a positive checkpoint identifier (ckptid) upon success, 0 if
> + it returns from a restart, and -1 if an error occurs. The ckptid will
> + uniquely identify a checkpoint image, for as long as the checkpoint
> + is kept in the kernel (e.g. if one wishes to keep a checkpoint, or a
> + partial checkpoint, residing in kernel memory).
> +
> +* long sys_restart(pid_t pid, int fd, unsigned long flags, int logfd);
> +
> + Restart a process hierarchy from a checkpoint image that is read from
> + the blob stored in the file indicated by @fd.  If @logfd isn't -1, it
> + indicates an open file to which error and debug messages are written.
> + @flags will have future meaning (must be 0 for now). @pid indicates
> + the root of the hierarchy as seen in the coordinator's pid-namespace,
> + and is expected to be a child of the coordinator. @flags may be one
> + or more of:
> +   - RESTART_TASKSELF : (self) restart of a single process
> +   - RESTART_FROEZN : processes remain frozen once restart completes

                FROZEN ?

> +   - RESTART_GHOST : process is a ghost (placeholder for a pid)

about @flags:  Above says both of these:
a) @flags will have future meaning (must be 0 for now)
b) @flags may be one or more of:

so please decide which one it is ;)

> + (Note that this argument may mean 'ckptid' to identify an in-kernel
> + checkpoint image, with some @flags in the future).
> +
> + Returns: -1 if an error occurs, 0 on success when restarting from a
> + "self" checkpoint, and return value of system call at the time of the
> + checkpoint when restarting from an "external" checkpoint.
> +
...
> +
> +Sysctl/proc
> +===========
> +
> +/proc/sys/kernel/ckpt_unpriv_allowed		[default = 1]
> +  controls whether c/r operation is allowed for unprivileged users

                      C/R

> +
> +
> +Operation
> +=========
> +
> +The granularity of a checkpoint usually is a process hierarchy. The
> +'pid' argument is interpreted in the caller's pid namespace. So to
> +checkpoint a container whose init task (pid 1 in that pidns) appears
> +as pid 3497 the caller's pidns, the caller must use pid 3497. Passing
> +pid 1 will attempt to checkpoint the caller's container, and if the
> +caller isn't privileged and init is owned by root, it will fail.
> +
> +Unless the CHECKPOINT_SUBTREE flag is set, if the caller passes a pid
> +which does not refer to a container's init task, then sys_checkpoint()
> +would return -EINVAL.

   returns -EINVAL.

...

> +
> +
> +User tools
> +==========
> +
> +* checkpoint(1): a tool to perform a checkpoint of a container/subtree
> +* restart(1): a tool to restart a container/subtree
> +* ckptinfo: a tool to examine a checkpoint image
> +
> +It is best to use the dedicated user tools for checkpoint and restart.
> +
> +If you insist, then here is a code snippet that illustrates how a
> +checkpoint is initiated by a process inside a container - the logic is
> +similar to fork():
> +	...
> +	ckptid = checkpoint(0, ...);
> +	switch (crid) {

	       (ckptid) ?

> +	case -1:
> +		perror("checkpoint failed");
> +		break;
> +	default:
> +		fprintf(stderr, "checkpoint succeeded, CRID=%d\n", ret);

s/ret/ckptid/ ?

> +		/* proceed with execution after checkpoint */
> +		...
> +		break;
> +	case 0:
> +		fprintf(stderr, "returned after restart\n");
> +		/* proceed with action required following a restart */
> +		...
> +		break;
> +	}
> +	...
> +
> +And to initiate a restart, the process in an empty container can use
> +logic similar to execve():
> +	...
> +	if (restart(pid, ...) < 0)
> +		perror("restart failed");
> +	/* only get here if restart failed */
> +	...
> +
> +Note, that the code also supports "self" checkpoint, where a process

   Note that

> +can checkpoint itself. This mode does not capture the relationships of
> +the task with other tasks, or any shared resources. It is useful for
> +application that wish to be able to save and restore their state.

   applications

> +They will either not use (or care about) shared resources, or they
> +will be aware of the operations and adapt suitably after a restart.
> +The code above can also be used for "self" checkpoint.
> +
> +
> +You may find the following sample programs useful:
> +
> +* checkpoint.c: accepts a 'pid' and checkpoint that task to stdout

                                       checkpoints

> +* self_checkpoint.c: a simple test program doing self-checkpoint
> +* self_restart.c: restarts a (self-) checkpoint image from stdin
> +
> +See also the utilities 'checkpoint' and 'restart' (from user-cr).
> +
> +
> +"External" checkpoint
> +=====================
> +
> +To do "external" checkpoint, you need to first freeze that other task
> +either using the freezer cgroup.

eh?  cannot parse that.

> +
> +Restart does not preserve the original PID yet, (because we haven't
> +solved yet the fork-with-specific-pid issue). In a real scenario, you
> +probably want to first create a new names space, and have the init

                                       namespace,

> +task there call 'sys_restart()'.
> +
> +I tested it this way:

...

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
