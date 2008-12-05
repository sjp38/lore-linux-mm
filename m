From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v11][PATCH 02/13] Checkpoint/restart: initial documentation
Date: Fri,  5 Dec 2008 12:31:11 -0500
Message-Id: <1228498282-11804-3-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Linux Torvalds <torvalds@osdl.org>, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, MinChan Kim <minchan.kim@gmail.com>, arnd@arndb.de, jeremy@goop.org
List-ID: <linux-mm.kvack.org>

Covers application checkpoint/restart, overall design, interfaces,
usage, shared objects, and and checkpoint image format.

Changelog[v8]:
  - Split into multiple files in Documentation/checkpoint/...
  - Extend documentation, fix typos and comments from feedback

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 Documentation/checkpoint/ckpt.c        |   32 ++++++
 Documentation/checkpoint/internals.txt |  133 +++++++++++++++++++++++++
 Documentation/checkpoint/readme.txt    |  105 +++++++++++++++++++
 Documentation/checkpoint/rstr.c        |   20 ++++
 Documentation/checkpoint/security.txt  |   38 +++++++
 Documentation/checkpoint/self.c        |   57 +++++++++++
 Documentation/checkpoint/test.c        |   48 +++++++++
 Documentation/checkpoint/usage.txt     |  171 ++++++++++++++++++++++++++++++++
 8 files changed, 604 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/checkpoint/ckpt.c
 create mode 100644 Documentation/checkpoint/internals.txt
 create mode 100644 Documentation/checkpoint/readme.txt
 create mode 100644 Documentation/checkpoint/rstr.c
 create mode 100644 Documentation/checkpoint/security.txt
 create mode 100644 Documentation/checkpoint/self.c
 create mode 100644 Documentation/checkpoint/test.c
 create mode 100644 Documentation/checkpoint/usage.txt

diff --git a/Documentation/checkpoint/ckpt.c b/Documentation/checkpoint/ckpt.c
new file mode 100644
index 0000000..094408c
--- /dev/null
+++ b/Documentation/checkpoint/ckpt.c
@@ -0,0 +1,32 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <sys/syscall.h>
+
+int main(int argc, char *argv[])
+{
+	pid_t pid;
+	int ret;
+
+	if (argc != 2) {
+		printf("usage: ckpt PID\n");
+		exit(1);
+	}
+
+	pid = atoi(argv[1]);
+	if (pid <= 0) {
+		printf("invalid pid\n");
+		exit(1);
+	}
+
+	ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
+
+	if (ret < 0)
+		perror("checkpoint");
+	else
+		printf("checkpoint id %d\n", ret);
+
+	return (ret > 0 ? 0 : 1);
+}
+
diff --git a/Documentation/checkpoint/internals.txt b/Documentation/checkpoint/internals.txt
new file mode 100644
index 0000000..b363e83
--- /dev/null
+++ b/Documentation/checkpoint/internals.txt
@@ -0,0 +1,133 @@
+
+	===== Internals of Checkpoint-Restart =====
+
+
+(1) Order of state dump
+
+The order of operations, both save and restore, is as follows:
+
+* Header section: header, container information, etc.
+
+* Global section: [TBD] global resources such as IPC, UTS, etc.
+
+* Process forest: [TBD] tasks and their relationships
+
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
+(2) Checkpoint image format
+
+The checkpoint image format is composed of records consisting of a
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
+'type' identifies the type of the payload, 'len' tells its length in
+bytes, and 'parent' identifies the owner object instance. The meaning
+of 'parent' varies depending on the type. For example, for CR_HDR_MM,
+'parent' identifies the task to which this MM belongs. The payload
+also varies depending on the type, for instance, the data describing a
+task_struct is given by a 'struct cr_hdr_task' (type CR_HDR_TASK) and
+so on.
+
+The format of the memory dump is as follows: for each VMA, there is a
+'struct cr_vma'; if the VMA is file-mapped, it is followed by the file
+name. Following comes the actual contents, in one or more chunks: each
+chunk begins with a header that specifies how many pages it holds,
+then the virtual addresses of all the dumped pages in that chunk,
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
+(3) Shared resources (objects)
+
+Many resources used by tasks may be shared by more than one task (e.g.
+file descriptors, memory address space, etc), or even have multiple
+references from other resources (e.g. a single inode that represents
+two ends of a pipe).
+
+Clearly, the state of shared objects need only be saved once, even if
+they occur multiple times. We use a hash table (ctx->objhash) to keep
+track of shared objects and whether they were already saved.  Shared
+objects are stored in a hash table as they appear, indexed by their
+kernel address. (The hash table itself is not saved as part of the
+checkpoint image: it is constructed dynamically during both checkpoint
+and restart, and discarded at the end of the operation).
+
+Each shared object that is found is first looked up in the hash table.
+On the first encounter, the object will not be found, so its state is
+dumped, and the object is assigned a unique identifier and also stored
+in the hash table. Subsequent lookups of that object in the hash table
+will yield that entry, and then only the unique identifier is saved,
+as opposed the entire state of the object.
+
+During restart, shared objects are seen by their unique identifiers as
+assigned during the checkpoint. Each shared object that it read in is
+first looked up in the hash table. On the first encounter it will not
+be found, meaning that the object needs to be created and its state
+read in and restored. Then the object is added to the hash table, this
+time indexed by its unique identifier. Subsequent lookups of the same
+unique identifier in the hash table will yield that entry, and then
+the existing object instance is reused instead of creating another one.
+
+The hash grabs a reference to each object that is inserted, and
+maintains this reference for the entire lifetime of the hash. Thus,
+it is always safe to reference an object that is stored in the hash.
+The hash is "one-way" in the sense that objects that are added are
+never deleted from the hash until the hash is discarded. This, in
+turn, happens only when the checkpoint (or restart) terminates.
+
+The interface for the hash table is the following:
+
+cr_obj_get_by_ptr() - find the unique object reference (objref)
+  of the object that is pointer to by ptr [checkpoint]
+
+cr_obj_add_ptr() - add the object pointed to by ptr to the hash table
+  if not already there, and fill its unique object reference (objref)
+
+cr_obj_get_by_ref() - return the pointer to the object whose unique
+  object reference is equal to objref [restart]
+
+cr_obj_add_ref() - add the object with given unique object reference
+  (objref), pointed to by ptr to the hash table. [restart]
+
diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
new file mode 100644
index 0000000..344a551
--- /dev/null
+++ b/Documentation/checkpoint/readme.txt
@@ -0,0 +1,105 @@
+
+	===== Checkpoint-Restart support in the Linux kernel =====
+
+Copyright (C) 2008 Oren Laadan
+
+Author:		Oren Laadan <orenl@cs.columbia.edu>
+
+License:	The GNU Free Documentation License, Version 1.2
+		(dual licensed under the GPL v2)
+
+Reviewers:	Serge Hallyn <serue@us.ibm.com>
+		Dave Hansen <dave@linux.vnet.ibm.com>
+
+Application checkpoint/restart [C/R] is the ability to save the state
+of a running application so that it can later resume its execution
+from the time at which it was checkpointed. An application can be
+migrated by checkpointing it on one machine and restarting it on
+another. C/R can provide many potential benefits:
+
+* Failure recovery: by rolling back to a previous checkpoint
+
+* Improved response time: by restarting applications from checkpoints
+  instead of from scratch.
+
+* Improved system utilization: by suspending long running CPU
+  intensive jobs and resuming them when load decreases.
+
+* Fault resilience: by migrating applications off faulty hosts.
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
+kernel exports a relatively opaque 'blob' of data to userspace which can
+then be handed to the new kernel at restore time.  The 'blob' contains
+data and state of select portions of kernel structures such as VMAs
+and mm_structs, as well as copies of the actual memory that the tasks
+use. Any changes in this blob's format between kernel revisions can be
+handled by an in-userspace conversion program. The approach is similar
+to virtually all of the commercial C/R products out there, as well as
+the research project Zap.
+
+Two new system calls are introduced to provide C/R: sys_checkpoint()
+and sys_restart(). The checkpoint code basically serializes internal
+kernel state and writes it out to a file descriptor, and the resulting
+image is stream-able. More specifically, it consists of 5 steps:
+
+1. Pre-dump
+2. Freeze the container
+3. Dump
+4. Thaw (or kill) the container
+5. Post-dump
+
+Steps 1 and 5 are an optimization to reduce application downtime. In
+particular, "pre-dump" works before freezing the container, e.g. the
+pre-copy for live migration, and "post-dump" works after the container
+resumes execution, e.g. write-back the data to secondary storage.
+
+The restart code basically reads the saved kernel state from a file
+descriptor, and re-creates the tasks and the resources they need to
+resume execution. The restart code is executed by each task that is
+restored in a new container to reconstruct its own state.
+
+
+=== Current Implementation
+
+* How useful is this code as it stands in real-world usage?
+
+Right now, the application must be a single process that does not
+share any resources with other processes. The only file descriptors
+that may be open are simple files and directories, they may not
+include devices, sockets or pipes.
+
+For an "external" checkpoint, the caller must first freeze (or stop)
+the target process. For "self" checkpoint, the application must be
+specifically written to use the new system calls. The restart does not
+yet preserve the pid of the original process, but will use whatever
+pid it was given by the kernel.
+
+What this means in practice is that it is useful for a simple
+application doing computational work and input/output from/to files.
+
+Currently, namespaces are not saved or restored. They will be treated
+as a class of a shared object. In particular, it is assumed that the
+task's file system namespace is the "root" for the entire container.
+It is also assumed that the same file system view is available for the
+restart task(s). Otherwise, a file system snapshot is required.
+
+* What additional work needs to be done to it?
+
+We know this design can work.  We have two commercial products and a
+horde of academic projects doing it today using this basic design.
+We're early in this particular implementation because we're trying to
+release early and often.
+
diff --git a/Documentation/checkpoint/rstr.c b/Documentation/checkpoint/rstr.c
new file mode 100644
index 0000000..288209d
--- /dev/null
+++ b/Documentation/checkpoint/rstr.c
@@ -0,0 +1,20 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
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
+
diff --git a/Documentation/checkpoint/security.txt b/Documentation/checkpoint/security.txt
new file mode 100644
index 0000000..e5b4107
--- /dev/null
+++ b/Documentation/checkpoint/security.txt
@@ -0,0 +1,38 @@
+
+	===== Security consideration for Checkpoint-Restart =====
+
+The main question is whether sys_checkpoint() and sys_restart()
+require privileged or unprivileged operation.
+
+Early versions checked capable(CAP_SYS_ADMIN) assuming that we would
+attempt to remove the need for privilege, so that all users could
+safely use it. Arnd Bergmann pointed out that it'd make more sense to
+let unprivileged users use them now, so that we'll be more careful
+about the security as patches roll in.
+
+Checkpoint: the main concern is whether a task that performs the
+checkpoint of another task has sufficient privileges to access its
+state. We address this by requiring that the checkpointer task will be
+able to ptrace the target task, by means of ptrace_may_access() with
+read mode.
+
+Restart: the main concern is that we may allow an unprivileged user to
+feed the kernel with random data. To this end, the restart works in a
+way that does not skip the usual security checks. Task credentials,
+i.e. euid, reuid, and LSM security contexts currently come from the
+caller, not the checkpoint image.  When restoration of credentials
+becomes supported, then definitely the ability of the task that calls
+sys_restore() to setresuid/setresgid to those values must be checked.
+
+Keeping the restart procedure to operate within the limits of the
+caller's credentials means that there various scenarios that cannot
+be supported. For instance, a setuid program that opened a protected
+log file and then dropped privileges will fail the restart, because
+the user won't have enough credentials to reopen the file. In these
+cases, we should probably treat restarting like inserting a kernel
+module: surely the user can cause havoc by providing incorrect data,
+but then again we must trust the root account.
+
+So that's why we don't want CAP_SYS_ADMIN required up-front. That way
+we will be forced to more carefully review each of those features.
+
diff --git a/Documentation/checkpoint/self.c b/Documentation/checkpoint/self.c
new file mode 100644
index 0000000..febb888
--- /dev/null
+++ b/Documentation/checkpoint/self.c
@@ -0,0 +1,57 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+#include <math.h>
+#include <sys/syscall.h>
+
+#define OUTFILE  "/tmp/cr-test.out"
+
+int main(int argc, char *argv[])
+{
+	pid_t pid = getpid();
+	FILE *file;
+	int i, ret;
+	float a;
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
+	if (dup2(0, 2) < 0) {
+		perror("dup2");
+		exit(1);
+	}
+
+	a = sqrt(2.53 * (getpid() / 1.21));
+
+	fprintf(file, "hello, world (%.2f)!\n", a);
+	fflush(file);
+
+	for (i = 0; i < 1000; i++) {
+		sleep(1);
+		/* make the fpu work ->  a = a + i/10  */
+		a = sqrt(a*a + 2*a*(i/10.0) + i*i/100.0);
+		fprintf(file, "count %d (%.2f)!\n", i, a);
+		fflush(file);
+
+		if (i == 2) {
+			ret = syscall(__NR_checkpoint, pid, STDOUT_FILENO, 0);
+			if (ret < 0) {
+				fprintf(file, "ckpt: %s\n", strerror(errno));
+				exit(2);
+			}
+			fprintf(file, "checkpoint ret: %d\n", ret);
+			fflush(file);
+		}
+	}
+
+	return 0;
+}
+
diff --git a/Documentation/checkpoint/test.c b/Documentation/checkpoint/test.c
new file mode 100644
index 0000000..1183655
--- /dev/null
+++ b/Documentation/checkpoint/test.c
@@ -0,0 +1,48 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <math.h>
+
+#define OUTFILE  "/tmp/cr-test.out"
+
+int main(int argc, char *argv[])
+{
+	FILE *file;
+	float a;
+	int i;
+
+	close(0);
+	close(1);
+	close(2);
+
+	unlink(OUTFILE);
+	file = fopen(OUTFILE, "w+");
+	if (!file) {
+		perror("open");
+		exit(1);
+	}
+	if (dup2(0, 2) < 0) {
+		perror("dup2");
+		exit(1);
+	}
+
+	a = sqrt(2.53 * (getpid() / 1.21));
+
+	fprintf(file, "hello, world (%.2f)!\n", a);
+	fflush(file);
+
+	for (i = 0; i < 1000; i++) {
+		sleep(1);
+		/* make the fpu work ->  a = a + i/10  */
+		a = sqrt(a*a + 2*a*(i/10.0) + i*i/100.0);
+		fprintf(file, "count %d (%.2f)!\n", i, a);
+		fflush(file);
+	}
+
+	fprintf(file, "world, hello (%.2f) !\n", a);
+	fflush(file);
+
+	return 0;
+}
+
diff --git a/Documentation/checkpoint/usage.txt b/Documentation/checkpoint/usage.txt
new file mode 100644
index 0000000..1b42d6b
--- /dev/null
+++ b/Documentation/checkpoint/usage.txt
@@ -0,0 +1,171 @@
+
+	===== How to use Checkpoint-Restart =====
+
+The API consists of two new system calls:
+
+* int sys_checkpoint(pid_t pid, int fd, unsigned long flag);
+
+    Checkpoint a container whose init task is identified by pid, to
+    the file designated by fd. 'flags' will have future meaning (must
+    be 0 for now).
+
+    Returns: a positive checkpoint identifier (crid) upon success, 0
+    if it returns from a restart, and -1 if an error occurs.
+
+    'crid' uniquely identifies a checkpoint image. For each checkpoint
+    the kernel allocates a unique 'crid', that remains valid for as
+    long as the checkpoint is kept in the kernel (for instance, when a
+    checkpoint, or a partial checkpoint, may reside in kernel memory).
+
+* int sys_restart(int crid, int fd, unsigned long flags);
+
+    Restart a container from a checkpoint image that is read from the
+    blob stored in the file designated by fd. 'crid' will have future
+    meaning (must be 0 for now). 'flags' will have future meaning
+    (must be 0 for now).
+
+    The role of 'crid' is to identify the checkpoint image in the case
+    that it remains in kernel memory. This will be useful to restart
+    from a checkpoint image that remains in kernel memory.
+
+    Returns: -1 if an error occurs, 0 on success when restarting from
+    a "self" checkpoint, and return value of system call at the time
+    of the checkpoint when restarting from an "external" checkpoint.
+
+    If restarting from an "external" checkpoint, tasks that were
+    executing a system call will observe the return value of that
+    system call (as it was when interrupted for the act of taking the
+    checkpoint), and tasks that were executing in user space will be
+    ready to return there.
+
+    Upon successful "external" restart, the container will end up in a
+    frozen state.
+
+The granularity of a checkpoint usually is a whole container. The
+'pid' argument is interpreted in the caller's pid namespace. So to
+checkpoint a container whose init task (pid 1 in that pidns) appears
+as pid 3497 the caller's pidns, the caller must use pid 3497. Passing
+pid 1 will attempt to checkpoint the caller's container, and if the
+caller isn't privileged and init is owned by root, it will fail.
+
+If the caller passes a pid which does not refer to a container's init
+task, then sys_checkpoint() would return -EINVAL. (This is because
+with nested containers a task may belong to more than one container).
+
+We assume that during checkpoint and restart the container state is
+quiescent. During checkpoint, this means that all affected tasks are
+frozen (or otherwise stopped). During restart, this means that all
+affected tasks are executing the sys_restart() call. In both cases,
+if there are other tasks possible sharing state with the container,
+they must not modify it during the operation. It is the reponsibility
+of the caller to follow this requirement.
+
+If the assumption that all tasks are frozen and that there is no other
+sharing doesn't hold - then the results of the operation are undefined
+(just as, e.g. not calling execve() immediately after vfork() produces
+undefined results). In particular, either checkpoint will fail, or it
+may produce a checkpoint image that can't be restarted, or (unlikely)
+the restart may produce a container whose state does not match that of
+the original container.
+
+
+Here is a code snippet that illustrates how a checkpoint is initiated
+by a process in a container - the logic is similar to fork():
+	...
+	crid = checkpoint(1, ...);
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
+
+And to initiate a restart, the process in an empty container can use
+logic similar to execve():
+	...
+	if (restart(crid, ...) < 0)
+		perror("restart failed");
+	/* only get here if restart failed */
+	...
+
+Note, that the code also supports "self" checkpoint, where a process
+can checkpoint itself. This mode does not capture the relationships
+of the task with other tasks, or any shared resources. It is useful
+for application that wish to be able to save and restore their state.
+They will either not use (or care about) shared resources, or they
+will be aware of the operations and adapt suitably after a restart.
+The code above can also be used for "self" checkpoint.
+
+To illustrate how the API works, refer to these sample programs:
+
+* ckpt.c: accepts a 'pid' argument and checkpoint that task to stdout
+* rstr.c: restarts a checkpoint image from stdin
+* self.c: a simple test program doing self-checkpoint
+* test.c: a simple test program to checkpoint
+
+"External" checkpoint:
+---------------------
+To do "external" checkpoint, you need to first freeze that other task
+either using the freezer cgroup, or by sending SIGSTOP.
+
+Restart does not preserve the original PID yet, (because we haven't
+solved yet the fork-with-specific-pid issue). In a real scenario, you
+probably want to first create a new names space, and have the init
+task there call 'sys_restart()'.
+
+I tested it this way:
+	$ ./test &
+	[1] 3493
+
+	$ kill -STOP 3493
+	$ ./ckpt 3493 > ckpt.image
+
+	$ mv /tmp/cr-test.out /tmp/cr-test.out.orig
+	$ cp /tmp/cr-test.out.orig /tmp/cr-test.out
+
+	$ kill -CONT 3493
+
+	$ ./rstr < ckpt.image
+Now compare the output of the two output files.
+
+"Self checkpoint:
+----------------
+To do "self" checkpoint, you can incorporate the code from ckpt.c into
+your application.
+
+Here is how to test the "self" checkpoint:
+	$ ./self > self.image &
+	[1] 3512
+
+	$ sleep 3
+	$ mv /tmp/cr-test.out /tmp/cr-test.out.orig
+	$ cp /tmp/cr-test.out.orig /tmp/cr-test.out
+
+	$ cat /tmp/cr-rest.out
+	hello, world (85.46)!
+	count 0 (85.46)!
+	count 1 (85.56)!
+	count 2 (85.76)!
+	count 3 (86.46)!
+
+	$ sed -i 's/count/xxxx/g' /tmp/cr-rest.out
+
+	$ ./rstr < self.image &
+Now compare the output of the two output files.
+
+Note how in test.c we close stdin, stdout, stderr - that's because
+currently we only support regular files (not ttys/ptys).
+
+If you check the output of ps, you'll see that "rstr" changed its name
+to "test" or "self", as expected.
+
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
