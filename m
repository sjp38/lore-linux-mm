From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Wed,  8 Oct 2008 06:19:48 -0400
Message-Id: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, MinChan Kim <minchan.kim@gmail.com>, arnd@arndb.de, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

These patches implement basic checkpoint-restart [CR]. This version
(v6) supports basic tasks with simple private memory, and open files
(regular files and directories only). Changes mainly cleanups. See
original announcements below.

Oren.

--
Todo:
- Add support for x86-64 and improve ABI
- Refine or change syscall interface
- Extend to handle (multiple) tasks in a container
- Handle multiple namespaces in a container (e.g. save the filesystem
  namespaces state with the file descriptors)
- Security (without CAPS_SYS_ADMIN files restore may fail)

Changelog:

[2008-Oct-07] v6:
  - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
    (even though it's not really needed)
  - Add assumptions and what's-missing to documentation
  - Misc fixes and cleanups

[2008-Sep-11] v5:
  - Config is now 'def_bool n' by default
  - Improve memory dump/restore code (following Dave Hansen's comments)
  - Change dump format (and code) to allow chunks of <vaddrs, pages>
    instead of one long list of each
  - Fix use of follow_page() to avoid faulting in non-present pages
  - Memory restore now maps user pages explicitly to copy data into them,
    instead of reading directly to user space; got rid of mprotect_fixup()
  - Remove preempt_disable() when restoring debug registers
  - Rename headers files s/ckpt/checkpoint/
  - Fix misc bugs in files dump/restore
  - Fixes and cleanups on some error paths
  - Fix misc coding style

[2008-Sep-09] v4:
  - Various fixes and clean-ups
  - Fix calculation of hash table size
  - Fix header structure alignment
  - Use stand list_... for cr_pgarr

[2008-Aug-29] v3:
  - Various fixes and clean-ups
  - Use standard hlist_... for hash table
  - Better use of standard kmalloc/kfree

[2008-Aug-20] v2:
  - Added Dump and restore of open files (regular and directories)
  - Added basic handling of shared objects, and improve handling of
    'parent tag' concept
  - Added documentation
  - Improved ABI, 64bit padding for image data
  - Improved locking when saving/restoring memory
  - Added UTS information to header (release, version, machine)
  - Cleanup extraction of filename from a file pointer
  - Refactor to allow easier reviewing
  - Remove requirement for CAPS_SYS_ADMIN until we come up with a
    security policy (this means that file restore may fail)
  - Other cleanup and response to comments for v1

[2008-Jul-29] v1:
  - Initial version: support a single task with address space of only
    private anonymous or file-mapped VMAs; syscalls ignore pid/crid
    argument and act on current process.

--
(Dave Hansen's announcement)

At the containers mini-conference before OLS, the consensus among
all the stakeholders was that doing checkpoint/restart in the kernel
as much as possible was the best approach.  With this approach, the
kernel will export a relatively opaque 'blob' of data to userspace
which can then be handed to the new kernel at restore time.

This is different than what had been proposed before, which was
that a userspace application would be responsible for collecting
all of this data.  We were also planning on adding lots of new,
little kernel interfaces for all of the things that needed
checkpointing.  This unites those into a single, grand interface.

The 'blob' will contain copies of select portions of kernel
structures such as vmas and mm_structs.  It will also contain
copies of the actual memory that the process uses.  Any changes
in this blob's format between kernel revisions can be handled by
an in-userspace conversion program.

This is a similar approach to virtually all of the commercial
checkpoint/restart products out there, as well as the research
project Zap.

These patches basically serialize internel kernel state and write
it out to a file descriptor.  The checkpoint and restore are done
with two new system calls: sys_checkpoint and sys_restart.

In this incarnation, they can only work checkpoint and restore a
single task. The task's address space may consist of only private,
simple vma's - anonymous or file-mapped. The open files may consist
of only simple files and directories.

--
(Original announcement)

In the recent mini-summit at OLS 2008 and the following days it was
agreed to tackle the checkpoint/restart (CR) by beginning with a very
simple case: save and restore a single task, with simple memory
layout, disregarding other task state such as files, signals etc.

Following these discussions I coded a prototype that can do exactly
that, as a starter. This code adds two system calls - sys_checkpoint
and sys_restart - that a task can call to save and restore its state
respectively. It also demonstrates how the checkpoint image file can
be formatted, as well as show its nested nature (e.g. cr_write_mm()
-> cr_write_vma() nesting).

The state that is saved/restored is the following:
* some of the task_struct
* some of the thread_struct and thread_info
* the cpu state (including FPU)
* the memory address space

In the current code, sys_checkpoint will checkpoint the current task,
although the logic exists to checkpoint other tasks (not in the
checkpointee's execution context). A simple loop will extend this to
handle multiple processes. sys_restart restarts the current tasks, and
with multiple tasks each task will call the syscall independently.
(Actually, to checkpoint outside the context of a task, it is also
necessary to also handle restart-block logic when saving/restoring the
thread data).

It takes longer to describe what isn't implemented or supported by
this prototype ... basically everything that isn't as simple as the
above.

As for containers - since we still don't have a representation for a
container, this patch has no notion of a container. The tests for
consistent namespaces (and isolation) are also omitted.

Below are two example programs: one uses checkpoint (called ckpt) and
one uses restart (called rstr). Note the use of "dup2" to create a 
copy of an open file and show how shared objects are treated. Execute
like this (as a superuser):

orenl:~/test$ ./ckpt > out.1
				<-- ctrl-c
orenl:~/test$ cat /tmp/cr-rest.out
hello, world!
world, hello!
(ret = 1)

orenl:~/test$ ./ckpt > out.1
				<-- ctrl-c
orenl:~/test$ cat /tmp/cr-rest.out
hello, world!
world, hello!
(ret = 2)

				<-- now change the contents of the file
orenl:~/test$ sed -i 's/world, hello!/xxxx/' /tmp/cr-rest.out
orenl:~/test$ cat /tmp/cr-rest.out
hello, world!
xxxx
(ret = 2)

				<-- and do the restart
orenl:~/test$ ./rstr < out.1
				<-- ctrl-c
orenl:~/test$ cat /tmp/cr-rest.out
hello, world!
world, hello!
(ret = 0)

(if you check the output of ps, you'll see that "rstr" changed its
name to "ckpt", as expected). 

============================== ckpt.c ================================

#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

#define OUTFILE "/tmp/cr-test.out"

int main(int argc, char *argv[])
{
	pid_t pid = getpid();
	FILE *file;
	int ret;

	close(0);
	close(2);

	unlink(OUTFILE);
	file = fopen(OUTFILE, "w+");
	if (!file) {
		perror("open");
		exit(1);
	}

	if (dup2(0,2) < 0) {
		perror("dups");
		exit(1);
	}

	fprintf(file, "hello, world!\n");
	fflush(file);

	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
	if (ret < 0) {
		perror("checkpoint");
		exit(2);
	}

	fprintf(file, "world, hello!\n");
	fprintf(file, "(ret = %d)\n", ret);
	fflush(file);

	while (1)
		;

	return 0;
}

============================== rstr.c ================================

#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <asm/unistd.h>
#include <sys/syscall.h>

int main(int argc, char *argv[])
{
	pid_t pid = getpid();
	int ret;

	ret = syscall(__NR_restart, pid, STDIN_FILENO, 0);
	if (ret < 0)
		perror("restart");

	printf("should not reach here !\n");

	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
