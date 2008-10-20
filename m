From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v7][PATCH 6/9] Checkpoint/restart: initial documentation
Date: Mon, 20 Oct 2008 01:40:34 -0400
Message-Id: <1224481237-4892-7-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
References: <1224481237-4892-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Covers application checkpoint/restart, overall design, interfaces
and checkpoint image format.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 Documentation/checkpoint.txt |  374 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 374 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/checkpoint.txt

diff --git a/Documentation/checkpoint.txt b/Documentation/checkpoint.txt
new file mode 100644
index 0000000..a73a4f3
--- /dev/null
+++ b/Documentation/checkpoint.txt
@@ -0,0 +1,374 @@
+
+	=== Checkpoint-Restart support in the Linux kernel ===
+
+Copyright (C) 2008 Oren Laadan
+
+Author:		Oren Laadan <orenl@cs.columbia.edu>
+
+License:	The GNU Free Documentation License, Version 1.2
+		(dual licensed under the GPL v2)
+Reviewers:
+
+Application checkpoint/restart [CR] is the ability to save the state
+of a running application so that it can later resume its execution
+from the time at which it was checkpointed. An application can be
+migrated by checkpointing it on one machine and restarting it on
+another. CR can provide many potential benefits:
+
+* Failure recovery: by rolling back an to a previous checkpoint
+
+* Improved response time: by restarting applications from checkpoints
+  instead of from scratch.
+
+* Improved system utilization: by suspending long running CPU
+  intensive jobs and resuming them when load decreases.
+
+* Fault resilience: by migrating applications off of faulty hosts.
+
+* Dynamic load balancing: by migrating applications to less loaded
+  hosts.
+
+* Improved service availability and administration: by migrating
+  applications before host maintenance so that they continue to run
+  with minimal downtime
+
+* Time-travel: by taking periodic checkpoints and restarting from
+  any previous checkpoint.
+
+
+=== Overall design
+
+Checkpoint and restart is done in the kernel as much as possible. The
+kernel exports a relative opaque 'blob' of data to userspace which can
+then be handed to the new kernel at restore time.  The 'blob' contains
+data and state of select portions of kernel structures such as VMAs
+and mm_structs, as well as copies of the actual memory that the tasks
+use. Any changes in this blob's format between kernel revisions can be
+handled by an in-userspace conversion program. The approach is similar
+to virtually all of the commercial CR products out there, as well as
+the research project Zap.
+
+Two new system calls are introduced to provide CR: sys_checkpoint and
+sys_restart.  The checkpoint code basically serializes internal kernel
+state and writes it out to a file descriptor, and the resulting image
+is stream-able. More specifically, it consists of 5 steps:
+  1. Pre-dump
+  2. Freeze the container
+  3. Dump
+  4. Thaw (or kill) the container
+  5. Post-dump
+Steps 1 and 5 are an optimization to reduce application downtime:
+"pre-dump" works before freezing the container, e.g. the pre-copy for
+live migration, and "post-dump" works after the container resumes
+execution, e.g. write-back the data to secondary storage.
+
+The restart code basically reads the saved kernel state and from a
+file descriptor, and re-creates the tasks and the resources they need
+to resume execution. The restart code is executed by each task that
+is restored in a new container to reconstruct its own state.
+
+
+=== Interfaces
+
+int sys_checkpoint(pid_t pid, int fd, unsigned long flag);
+  Checkpoint a container whose init task is identified by pid, to the
+  file designated by fd. Flags will have future meaning (should be 0
+  for now).
+  Returns: a positive integer that identifies the checkpoint image
+  (for future reference in case it is kept in memory) upon success,
+  0 if it returns from a restart, and -1 if an error occurs.
+
+int sys_restart(int crid, int fd, unsigned long flags);
+  Restart a container from a checkpoint image identified by crid, or
+  from the blob stored in the file designated by fd. Flags will have
+  future meaning (should be 0 for now).
+  Returns: 0 on success and -1 if an error occurs.
+
+Thus, if checkpoint is initiated by a process in the container, one
+can use logic similar to fork():
+	...
+	crid = checkpoint(...);
+	switch (crid) {
+	case -1:
+		perror("checkpoint failed");
+		break;
+	default:
+		fprintf(stderr, "checkpoint succeeded, CRID=%d\n", ret);
+		/* proceed with execution after checkpoint */
+		...
+		break;
+	case 0:
+		fprintf(stderr, "returned after restart\n");
+		/* proceed with action required following a restart */
+		...
+		break;
+	}
+	...
+And to initiate a restart, the process in an empty container can use
+logic similar to execve():
+	...
+	if (restart(crid, ...) < 0)
+		perror("restart failed");
+	/* only get here if restart failed */
+	...
+
+See below a complete example in C.
+
+
+=== Order of state dump
+
+The order of operations, both save and restore, is as following:
+
+* Header section: header, container information, etc.
+* Global section: [TBD] global resources such as IPC, UTS, etc.
+* Process forest: [TBD] tasks and their relationships
+* Per task data (for each task):
+  -> task state: elements of task_struct
+  -> thread state: elements of thread_struct and thread_info
+  -> CPU state: registers etc, including FPU
+  -> memory state: memory address space layout and contents
+  -> filesystem state: [TBD] filesystem namespace state, chroot, cwd, etc
+  -> files state: open file descriptors and their state
+  -> signals state: [TBD] pending signals and signal handling state
+  -> credentials state: [TBD] user and group state, statistics
+
+
+=== Checkpoint image format
+
+The checkpoint image format is composed of records consistings of a
+pre-header that identifies its contents, followed by a payload. (The
+idea here is to enable parallel checkpointing in the future in which
+multiple threads interleave data from multiple processes into a single
+stream).
+
+The pre-header is defined by "struct cr_hdr" as follows:
+
+struct cr_hdr {
+	__s16 type;
+	__s16 len;
+	__u32 parent;
+};
+
+Here, 'type' field identifies the type of the payload, 'len' tells its
+length in bytes. The 'parent' identifies the owner object instance. The
+meaning of the 'parent field varies depending on the type. For example,
+for type CR_HDR_MM, the 'parent identifies the task to which this MM
+belongs. The payload also varies depending on the type, for instance,
+the data describing a task_struct is given by a 'struct cr_hdr_task'
+(type CR_HDR_TASK) and so on.
+
+The format of the memory dump is as follows: for each VMA, there is a
+'struct cr_vma'; if the VMA is file-mapped, it is followed by the file
+name. Following comes the actual contents, in one or more chunk: each
+chunk begins with a header that specifies how many pages it holds,
+then a the virtual addresses of all the dumped pages in that chunk,
+followed by the actual contents of all the dumped pages. A header with
+zero number of pages marks the end of the contents for a particular
+VMA. Then comes the next VMA and so on.
+
+To illustrate this, consider a single simple task with two VMAs: one
+is file mapped with two dumped pages, and the other is anonymous with
+three dumped pages. The checkpoint image will look like this:
+
+cr_hdr + cr_hdr_head
+cr_hdr + cr_hdr_task
+	cr_hdr + cr_hdr_mm
+		cr_hdr + cr_hdr_vma + cr_hdr + string
+			cr_hdr_pgarr (nr_pages = 2)
+			addr1, addr2
+			page1, page2
+			cr_hdr_pgarr (nr_pages = 0)
+		cr_hdr + cr_hdr_vma
+			cr_hdr_pgarr (nr_pages = 3)
+			addr3, addr4, addr5
+			page3, page4, page5
+			cr_hdr_pgarr (nr_pages = 0)
+		cr_hdr + cr_mm_context
+	cr_hdr + cr_hdr_thread
+	cr_hdr + cr_hdr_cpu
+cr_hdr + cr_hdr_tail
+
+
+=== Current Implementation
+
+[2008-Oct-07]
+There are several assumptions in the current implementation; they will
+be gradually relaxed in future versions. The main ones are:
+* A task can only checkpoint itself (missing "restart-block" logic).
+* Namespaces are not saved or restored; They will be treated as a type
+  of shared object.
+* In particular, it is assumed that the task's file system namespace
+  is the "root" for the entire container.
+* It is assumed that the same file system view is available for the
+  restart task(s). Otherwise, a file system snapshot is required.
+
+
+=== Sample code
+
+Two example programs: one uses checkpoint (called ckpt) to checkpoint
+itself, and another uses restart (called rstr) to restart from that
+checkpoint. Note the use of "dup2" to create a copy of an open file
+and show how shared objects are treated. Execute like this:
+
+orenl:~/test$ ./ckpt > out.1
+				<-- ctrl-c
+orenl:~/test$ cat /tmp/cr-rest.out
+hello, world!
+world, hello!
+(ret = 1)
+
+orenl:~/test$ ./ckpt > out.1
+				<-- ctrl-c
+orenl:~/test$ cat /tmp/cr-rest.out
+hello, world!
+world, hello!
+(ret = 2)
+
+				<-- now change the contents of the file
+orenl:~/test$ sed -i 's/world, hello!/xxxx/' /tmp/cr-rest.out
+orenl:~/test$ cat /tmp/cr-rest.out
+hello, world!
+xxxx
+(ret = 2)
+
+				<-- and do the restart
+orenl:~/test$ ./rstr < out.1
+				<-- ctrl-c
+orenl:~/test$ cat /tmp/cr-rest.out
+hello, world!
+world, hello!
+(ret = 0)
+
+(if you check the output of ps, you'll see that "rstr" changed its
+name to "ckpt", as expected).
+
+============================== ckpt.c ================================
+
+#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <asm/unistd.h>
+#include <sys/syscall.h>
+
+#define OUTFILE "/tmp/cr-test.out"
+
+int main(int argc, char *argv[])
+{
+	pid_t pid = getpid();
+	FILE *file;
+	int ret;
+
+	close(0);
+	close(2);
+
+	unlink(OUTFILE);
+	file = fopen(OUTFILE, "w+");
+	if (!file) {
+		perror("open");
+		exit(1);
+	}
+
+	if (dup2(0,2) < 0) {
+		perror("dups");
+		exit(1);
+	}
+
+	fprintf(file, "hello, world!\n");
+	fflush(file);
+
+	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
+	if (ret < 0) {
+		perror("checkpoint");
+		exit(2);
+	}
+
+	fprintf(file, "world, hello!\n");
+	fprintf(file, "(ret = %d)\n", ret);
+	fflush(file);
+
+	while (1)
+		;
+
+	return 0;
+}
+======================================================================
+
+============================== rstr.c ================================
+
+#define _GNU_SOURCE        /* or _BSD_SOURCE or _SVID_SOURCE */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <asm/unistd.h>
+#include <sys/syscall.h>
+
+int main(int argc, char *argv[])
+{
+	pid_t pid = getpid();
+	int ret;
+
+	ret = syscall(__NR_restart, pid, STDIN_FILENO, 0);
+	if (ret < 0)
+		perror("restart");
+
+	printf("should not reach here !\n");
+
+	return 0;
+}
+======================================================================
+
+
+=== Changelog
+
+[2008-Oct-17] v7:
+  - Fix save/restore state of FPU
+  - Fix argument given to kunmap_atomic() in memory dump/restore
+
+[2008-Oct-07] v6:
+  - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
+    (even though it's not really needed)
+  - Add 'current implementation' to docs to describe assumptions
+  - Misc fixes and cleanups
+
+[2008-Sep-11] v5:
+  - Config is 'def_bool n' by default
+  - Improve memory dump/restore code (following Dave Hansen's comments)
+  - Change dump format (and code) to allow chunks of <vaddrs, pages>
+    instead of one long list of each
+  - Fix use of follow_page() to avoid faulting in non-present pages
+  - Memory restore now maps user pages explicitly to copy data into them,
+    instead of reading directly to user space; got rid of mprotect_fixup()
+  - Remove preempt_disable() when restoring debug registers
+  - Rename headers files s/ckpt/checkpoint/
+  - Fix misc bugs in files dump/restore
+  - Fix cleanup on some error paths
+  - Fix misc coding style
+
+[2008-Sep-04] v4:
+  - Fix calculation of hash table size
+  - Fix header structure alignment
+  - Use stand list_... for cr_pgarr
+
+[2008-Aug-20] v3:
+  - Various fixes and clean-ups
+  - Use standard hlist_... for hash table
+  - Better use of standard kmalloc/kfree
+
+[2008-Aug-09] v2:
+  - Added utsname->{release,version,machine} to checkpoint header
+  - Pad header structures to 64 bits to ensure compatibility
+  - Address comments from LKML and linux-containers mailing list
+
+[2008-Jul-29] v1:
+In this incarnation, CR only works on single task. The address space
+may consist of only private, simple VMAs - anonymous or file-mapped.
+Both checkpoint and restart will ignore the first argument (pid/crid)
+and instead act on themselves.
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
