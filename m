Received: by rv-out-0708.google.com with SMTP id f25so2454626rvb.26
        for <linux-mm@kvack.org>; Tue, 28 Oct 2008 09:48:33 -0700 (PDT)
Message-ID: <cfd18e0f0810280948g1c3906c9j9484b7d05b658f5f@mail.gmail.com>
Date: Tue, 28 Oct 2008 11:48:33 -0500
From: "Michael Kerrisk" <mtk.manpages@googlemail.com>
Reply-To: mtk.manpages@gmail.com
Subject: Re: [RFC v7][PATCH 6/9] Checkpoint/restart: initial documentation
In-Reply-To: <1224481237-4892-7-git-send-email-orenl@cs.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
	 <1224481237-4892-7-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>
List-ID: <linux-mm.kvack.org>

Oren,

Some comments/suggested fixes below.

On Mon, Oct 20, 2008 at 12:40 AM, Oren Laadan <orenl@cs.columbia.edu> wrote:
> Covers application checkpoint/restart, overall design, interfaces
> and checkpoint image format.
>
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
> Acked-by: Serge Hallyn <serue@us.ibm.com>
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
> ---
>  Documentation/checkpoint.txt |  374 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 374 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/checkpoint.txt
>
> diff --git a/Documentation/checkpoint.txt b/Documentation/checkpoint.txt
> new file mode 100644
> index 0000000..a73a4f3
> --- /dev/null
> +++ b/Documentation/checkpoint.txt
> @@ -0,0 +1,374 @@
> +
> +       === Checkpoint-Restart support in the Linux kernel ===
> +
> +Copyright (C) 2008 Oren Laadan
> +
> +Author:                Oren Laadan <orenl@cs.columbia.edu>
> +
> +License:       The GNU Free Documentation License, Version 1.2
> +               (dual licensed under the GPL v2)
> +Reviewers:
> +
> +Application checkpoint/restart [CR] is the ability to save the state
> +of a running application so that it can later resume its execution
> +from the time at which it was checkpointed. An application can be
> +migrated by checkpointing it on one machine and restarting it on
> +another. CR can provide many potential benefits:
> +
> +* Failure recovery: by rolling back an to a previous checkpoint

Extraneous word "an"?

> +
> +* Improved response time: by restarting applications from checkpoints
> +  instead of from scratch.
> +
> +* Improved system utilization: by suspending long running CPU
> +  intensive jobs and resuming them when load decreases.
> +
> +* Fault resilience: by migrating applications off of faulty hosts.

s/off of/off/

> +
> +* Dynamic load balancing: by migrating applications to less loaded
> +  hosts.
> +
> +* Improved service availability and administration: by migrating
> +  applications before host maintenance so that they continue to run
> +  with minimal downtime
> +
> +* Time-travel: by taking periodic checkpoints and restarting from
> +  any previous checkpoint.
> +
> +
> +=== Overall design
> +
> +Checkpoint and restart is done in the kernel as much as possible. The
> +kernel exports a relative opaque 'blob' of data to userspace which can

s/relative/relatively/

> +then be handed to the new kernel at restore time.  The 'blob' contains
> +data and state of select portions of kernel structures such as VMAs
> +and mm_structs, as well as copies of the actual memory that the tasks
> +use. Any changes in this blob's format between kernel revisions can be
> +handled by an in-userspace conversion program. The approach is similar
> +to virtually all of the commercial CR products out there, as well as
> +the research project Zap.
> +
> +Two new system calls are introduced to provide CR: sys_checkpoint and
> +sys_restart.  The checkpoint code basically serializes internal kernel
> +state and writes it out to a file descriptor, and the resulting image
> +is stream-able. More specifically, it consists of 5 steps:
> +  1. Pre-dump
> +  2. Freeze the container
> +  3. Dump
> +  4. Thaw (or kill) the container
> +  5. Post-dump
> +Steps 1 and 5 are an optimization to reduce application downtime:
> +"pre-dump" works before freezing the container, e.g. the pre-copy for
> +live migration, and "post-dump" works after the container resumes
> +execution, e.g. write-back the data to secondary storage.
> +
> +The restart code basically reads the saved kernel state and from a

Extraneous word "and"

> +file descriptor, and re-creates the tasks and the resources they need
> +to resume execution. The restart code is executed by each task that
> +is restored in a new container to reconstruct its own state.
> +
> +
> +=== Interfaces
> +
> +int sys_checkpoint(pid_t pid, int fd, unsigned long flag);
> +  Checkpoint a container whose init task is identified by pid, to the

I seem to recall Andrew M. mentioning something about this.  Could you
add a bit of text here to explain why "pid" is not always "1".

> +  file designated by fd. Flags will have future meaning (should be 0
> +  for now).

Should be 0, or must be 0?  IMO, the text should be the latter.  And
the code should check that -- does it?

> +  Returns: a positive integer that identifies the checkpoint image

Can you add some more text here to describe the what this "positive
integer" is.  E..g., how is it generated, and what does it refer to
(an address, a file descriptor, something else).

Looking further down, it seems that this is the "crid", but you could
make that clearer already here.

> +  (for future reference in case it is kept in memory) upon success,
> +  0 if it returns from a restart, and -1 if an error occurs.
> +
> +int sys_restart(int crid, int fd, unsigned long flags);
> +  Restart a container from a checkpoint image identified by crid, or

See above -- that "crid" is the thing returned by checkpoint(), right?
 Make that clearer here.

> +  from the blob stored in the file designated by fd. Flags will have
> +  future meaning (should be 0 for now).

Again... Should be 0, or must be 0?  IMO, the text should be the
latter.  And the code should check that -- does it?

> +  Returns: 0 on success and -1 if an error occurs.
> +
> +Thus, if checkpoint is initiated by a process in the container, one
> +can use logic similar to fork():
> +       ...
> +       crid = checkpoint(...);
> +       switch (crid) {
> +       case -1:
> +               perror("checkpoint failed");
> +               break;
> +       default:
> +               fprintf(stderr, "checkpoint succeeded, CRID=%d\n", ret);
> +               /* proceed with execution after checkpoint */
> +               ...
> +               break;
> +       case 0:
> +               fprintf(stderr, "returned after restart\n");
> +               /* proceed with action required following a restart */
> +               ...
> +               break;
> +       }
> +       ...
> +And to initiate a restart, the process in an empty container can use
> +logic similar to execve():
> +       ...
> +       if (restart(crid, ...) < 0)
> +               perror("restart failed");
> +       /* only get here if restart failed */
> +       ...
> +
> +See below a complete example in C.
> +
> +
> +=== Order of state dump
> +
> +The order of operations, both save and restore, is as following:

s/is as following/is as follows/

> +
> +* Header section: header, container information, etc.
> +* Global section: [TBD] global resources such as IPC, UTS, etc.
> +* Process forest: [TBD] tasks and their relationships
> +* Per task data (for each task):
> +  -> task state: elements of task_struct
> +  -> thread state: elements of thread_struct and thread_info
> +  -> CPU state: registers etc, including FPU
> +  -> memory state: memory address space layout and contents
> +  -> filesystem state: [TBD] filesystem namespace state, chroot, cwd, etc
> +  -> files state: open file descriptors and their state
> +  -> signals state: [TBD] pending signals and signal handling state
> +  -> credentials state: [TBD] user and group state, statistics
> +
> +
> +=== Checkpoint image format
> +
> +The checkpoint image format is composed of records consistings of a

consisting

> +pre-header that identifies its contents, followed by a payload. (The
> +idea here is to enable parallel checkpointing in the future in which
> +multiple threads interleave data from multiple processes into a single
> +stream).
> +
> +The pre-header is defined by "struct cr_hdr" as follows:
> +
> +struct cr_hdr {
> +       __s16 type;
> +       __s16 len;
> +       __u32 parent;
> +};
> +
> +Here, 'type' field identifies the type of the payload, 'len' tells its

s/'type' field/'type'/
or
s/'type' field/the 'type' field/

> +length in bytes. The 'parent' identifies the owner object instance. The

add "field" after 'parent'

> +meaning of the 'parent field varies depending on the type. For example,
> +for type CR_HDR_MM, the 'parent identifies the task to which this MM

Missing ' (single quote)

> +belongs. The payload also varies depending on the type, for instance,
> +the data describing a task_struct is given by a 'struct cr_hdr_task'
> +(type CR_HDR_TASK) and so on.
> +
> +The format of the memory dump is as follows: for each VMA, there is a
> +'struct cr_vma'; if the VMA is file-mapped, it is followed by the file
> +name. Following comes the actual contents, in one or more chunk: each

s/Following comes/Following that are/

s/chunk/chunks/

> +chunk begins with a header that specifies how many pages it holds,
> +then a the virtual addresses of all the dumped pages in that chunk,

s/a the/the/

> +followed by the actual contents of all the dumped pages. A header with
> +zero number of pages marks the end of the contents for a particular
> +VMA. Then comes the next VMA and so on.
> +
> +To illustrate this, consider a single simple task with two VMAs: one
> +is file mapped with two dumped pages, and the other is anonymous with
> +three dumped pages. The checkpoint image will look like this:
> +
> +cr_hdr + cr_hdr_head
> +cr_hdr + cr_hdr_task
> +       cr_hdr + cr_hdr_mm
> +               cr_hdr + cr_hdr_vma + cr_hdr + string
> +                       cr_hdr_pgarr (nr_pages = 2)
> +                       addr1, addr2
> +                       page1, page2
> +                       cr_hdr_pgarr (nr_pages = 0)
> +               cr_hdr + cr_hdr_vma
> +                       cr_hdr_pgarr (nr_pages = 3)
> +                       addr3, addr4, addr5
> +                       page3, page4, page5
> +                       cr_hdr_pgarr (nr_pages = 0)
> +               cr_hdr + cr_mm_context
> +       cr_hdr + cr_hdr_thread
> +       cr_hdr + cr_hdr_cpu
> +cr_hdr + cr_hdr_tail
> +
> +
> +=== Current Implementation
> +
> +[2008-Oct-07]
> +There are several assumptions in the current implementation; they will
> +be gradually relaxed in future versions. The main ones are:
> +* A task can only checkpoint itself (missing "restart-block" logic).
> +* Namespaces are not saved or restored; They will be treated as a type
> +  of shared object.
> +* In particular, it is assumed that the task's file system namespace
> +  is the "root" for the entire container.
> +* It is assumed that the same file system view is available for the
> +  restart task(s). Otherwise, a file system snapshot is required.
> +
> +
> +=== Sample code
> +
> +Two example programs: one uses checkpoint (called ckpt) to checkpoint
> +itself, and another uses restart (called rstr) to restart from that
> +checkpoint. Note the use of "dup2" to create a copy of an open file
> +and show how shared objects are treated. Execute like this:
> +
> +orenl:~/test$ ./ckpt > out.1
> +                               <-- ctrl-c

It really would be more readable if you simplified the shell prompt to
just "$ " or "sh$ " or "bash$".  Future generations do not need to
know where you tested this code, or your username ;-).

[...]

Cheers,

Michael


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
git://git.kernel.org/pub/scm/docs/man-pages/man-pages.git
man-pages online: http://www.kernel.org/doc/man-pages/online_pages.html
Found a bug? http://www.kernel.org/doc/man-pages/reporting_bugs.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
