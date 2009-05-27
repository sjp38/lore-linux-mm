Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EE2376B006A
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:33:00 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [RFC v16][PATCH 04/43] c/r: documentation
Date: Wed, 27 May 2009 13:32:30 -0400
Message-Id: <1243445589-32388-5-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Covers application checkpoint/restart, overall design, interfaces,
usage, shared objects, and and checkpoint image format.

Changelog[v16]:
  - Update documentation
  - Unify into readme.txt and usage.txt

Changelog[v14]:
  - Discard the 'h.parent' field
  - New image format (shared objects appear before they are referenced
    unless they are compound)

Changelog[v8]:
  - Split into multiple files in Documentation/checkpoint/...
  - Extend documentation, fix typos and comments from feedback

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---
 Documentation/checkpoint/ckpt.c     |   32 ++++
 Documentation/checkpoint/readme.txt |  349 +++++++++++++++++++++++++++++++++++
 Documentation/checkpoint/rstr.c     |   20 ++
 Documentation/checkpoint/self.c     |   57 ++++++
 Documentation/checkpoint/test.c     |   48 +++++
 Documentation/checkpoint/usage.txt  |  192 +++++++++++++++++++
 checkpoint/sys.c                    |    2 +-
 7 files changed, 699 insertions(+), 1 deletions(-)

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
diff --git a/Documentation/checkpoint/readme.txt b/Documentation/checkpoint/readme.txt
new file mode 100644
index 0000000..abc54c1
--- /dev/null
+++ b/Documentation/checkpoint/readme.txt
@@ -0,0 +1,349 @@
+
+	      Checkpoint-Restart support in the Linux kernel
+	==========================================================
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
+
+Introduction
+============
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
+Compared to hypervisor approaches, application C/R is more lightweight
+since it need only save the state associated with applications, while
+operating system data structures (e.g. buffer cache, drivers state
+and the like) are uninteresting.
+
+
+Overall design
+==============
+
+Checkpoint and restart are done in the kernel as much as possible.
+Two new system calls are introduced to provide C/R: sys_checkpoint()
+and sys_restart(). They both operate on a process tree (hierarchy),
+either a whole container or a subtree of a container.
+
+Checkpointing entire containers ensures that there are no dependencies
+on anything outside the container, which guarantees that a matching
+restart will succeed (assuming that the file system state remains
+consistent). However, it requires that users will always run the tasks
+that they wish to checkpoint inside containers. This is ideal for,
+e.g., private virtual servers and the like.
+
+In contrast, when checkpointing a subtree of a container it is up to
+the user to ensure that dependencies either don't exist or can be
+safely ignored. This is useful, for instance, for HPC scenarios or
+even a user that would like to periodically checkpoint a long-running
+batch job.
+
+An additional system call, a la madvise(), is planned, so that tasks
+can advise the kernel how to handle specific resources. For instance,
+a task could ask to skip a memory area at checkpoint to save space,
+or to use a preset file descriptor at restart instead of restoring it
+from the checkpoint image. It will provide the flexibility that is
+particularly useful to address the needs of a diverse crowd of users
+and use-cases.
+
+Syscall sys_checkpoint() is given a pid that indicates the top of the
+hierarchy, a file descriptor to store the image, and flags. The code
+serializes internal user- and kernel-state and writes it out to the
+file descriptor. The resulting image is stream-able. The processes are
+expected to be frozen for the duration of the checkpoint.
+
+In general, a checkpoint consists of 5 steps:
+1. Pre-dump
+2. Freeze the container/subtree
+3. Save tasks' and kernel state		<-- sys_checkpoint()
+4. Thaw (or kill) the container/subtree
+5. Post-dump
+
+Step 3 is done by calling sys_checkpoint(). Steps 1 and 5 are an
+optimization to reduce application downtime. In particular, "pre-dump"
+works before freezing the container, e.g. the pre-copy for live
+migration, and "post-dump" works after the container resumes
+execution, e.g. write-back the data to secondary storage.
+
+The kernel exports a relatively opaque 'blob' of data to userspace
+which can then be handed to the new kernel at restart time.  The
+'blob' contains data and state of select portions of kernel structures
+such as VMAs and mm_structs, as well as copies of the actual memory
+that the tasks use. Any changes in this blob's format between kernel
+revisions can be handled by an in-userspace conversion program.
+
+To restart, userspace first create a process hierarchy that matches
+that of the checkpoint, and each task calls sys_restart(). The syscall
+reads the saved kernel state from a file descriptor, and re-creates
+the resources that the tasks need to resume execution. The restart
+code is executed by each task that is restored in the new hierarchy to
+reconstruct its own state.
+
+In general, a restart consists of 3 steps:
+1. Create hierarchy
+2. Restore tasks' and kernel state	<-- sys_restart()
+3. Resume userspace (or freeze tasks)
+
+Because the process hierarchy, during restart in created in userspace,
+the restarting tasks have the flexibility to prepare before calling
+sys_restart().
+
+
+Checkpoint image format
+=======================
+
+The checkpoint image format is built of records that consist of a
+pre-header identifying its contents, followed by a payload. This
+format allow userspace tools to easily parse and skip through the
+image without requiring intimate knowledge of the data. It will also
+be handy to enable parallel checkpointing in the future where multiple
+threads interleave data from multiple processes into a single stream.
+
+The pre-header is defined by 'struct ckpt_hdr' as follows: @type
+identifies the type of the payload, @len tells its length in bytes
+including the pre-header.
+
+struct ckpt_hdr {
+	__s32 type;
+	__s32 len;
+};
+
+The pre-header must be the first component in all other headers. For
+instance, the task data is saved in 'struct ckpt_hdr_task', which
+looks something like this:
+
+struct ckpt_hdr_task {
+	struct ckpt_hdr h;
+	__u32 pid;
+	...
+};
+
+THE IMAGE FORMAT IS EXPECTED TO CHANGE over time as more features are
+supported, or as existing features change in the kernel and require to
+adjust their representation. Any such changes will be be handled by
+in-userspace conversion tools.
+
+The general format of the checkpoint image is as follows:
+1. Image header
+2. Task hierarchy
+3. Tasks' state
+4. Image trailer
+
+The image always begins with a general header that holds a magic
+number, an architecture identifier (little endian format), a format
+version number (@rev), followed by information about the kernel
+(currently version and UTS data). It also holds the time of the
+checkpoint and the flags given to sys_checkpoint(). This header is
+followed by an arch-specific header.
+
+The task hierarchy comes next so that userspace tools can read it
+early (even from a stream) and re-create the restarting tasks. This is
+basically an array of all checkpointed tasks, and their relationships
+(parent, siblings, threads, etc).
+
+Then the state of all tasks is saved, in the order that they appear in
+the tasks array above. For each state, we save data like task_struct,
+namespaces, open files, memory layout, memory contents, cpu state,
+signals and signal handlers, etc. For resources that are shared among
+multiple processes, we first checkpoint said resource (and only once),
+and in the task data we give a reference to it. More about shared
+resources below.
+
+Finally, the image always ends with a trailer that holds a (different)
+magic number, serving for sanity check.
+
+
+Shared objects
+==============
+
+Many resources may be shared by multiple tasks (e.g. file descriptors,
+memory address space, etc), or even have multiple references from
+other resources (e.g. a single inode that represents two ends of a
+pipe).
+
+Shared objects are tracked using a hash table (objhash) to ensure that
+they are only checkpointed or restored once. To handle a shared
+object, it is first looked up in the hash table, to determine if is
+the first encounter or a recurring appearance.  The hash table itself
+is not saved as part of the checkpoint image: it is constructed
+dynamically during both checkpoint and restart, and discarded at the
+end of the operation.
+
+During checkpoint, when a shared object is encountered for the first
+time, it is inserted to the hash table, indexed by its kernel address.
+It is assigned an identifier (@objref) in order of appearance, and
+then its state if saved. Subsequent lookups of that object in the hash
+will yield that entry, in which case only the @objref is saved, as
+opposed the entire state of the object.
+
+During restart, shared objects are indexed by their @objref as given
+during the checkpoint. On the first appearance of each shared object,
+a new resource will be created and its state restored from the image.
+Then the object is added to the hash table. Subsequent lookups of the
+same unique identifier in the hash table will yield that entry, and
+then the existing object instance is reused instead of creating
+a new one.
+
+The hash grabs a reference to each object that is inserted, and
+maintains this reference for the entire lifetime of the hash. Thus,
+it is always safe to reference an object that is stored in the hash.
+The hash is "one-way" in the sense that objects that are added are
+never deleted from the hash until the hash is discarded. This, in
+turn, happens only when the checkpoint (or restart) terminates.
+
+Shared objects are thus saved when they are first seen, and _before_
+the parent object that uses them. Therefore by the time the parent
+objects needs them, they should already be in the objhash. The one
+exception is when more than a single shared resource will be restarted
+at once (e.g. like the two ends of a pipe, or all the namespaces in an
+nsproxy). In this case the parent object is dumped first followed by
+the individual sub-resources).
+
+The checkpoint image is stream-able, meaning that restarting from it
+may not require lseek(). This is enforced at checkpoint time, by
+carefully selecting the order of shared objects, to respect the rule
+that an object is always saved before the objects that refers to it.
+
+
+Memory contents format
+======================
+
+The memory contents of a given memory address space (->mm) is dumped
+as a sequence of vma objects, represented by 'struct ckpt_hdr_vma'.
+This header details the vma properties, and a reference to a file
+(if file backed) or an inode (or shared memory) object.
+
+The vma header is followed by the actual contents - but only those
+pages that need to be saved, i.e. dirty pages. They are written in
+chunks of data, where each chunks contains a header that indicates
+that number of pages in the chunk, followed by an array of virtual
+addresses and then an array of actual page contents. The last chunk
+holds zero pages.
+
+To illustrate this, consider a single simple task with two vmas: one
+is file mapped with two dumped pages, and the other is anonymous with
+three dumped pages. The memory dump will look like this:
+
+	ckpt_hdr + ckpt_hdr_vma
+		ckpt_hdr_pgarr (nr_pages = 2)
+			addr1, addr2
+			page1, page2
+		ckpt_hdr_pgarr (nr_pages = 0)
+	ckpt_hdr + ckpt_hdr_vma
+		ckpt_hdr_pgarr (nr_pages = 3)
+		addr3, addr4, addr5
+		page3, page4, page5
+		ckpt_hdr_pgarr (nr_pages = 0)
+
+
+Error handling
+==============
+
+Both checkpoint and restart operations may fail due to a variety of
+reasons. Using a simple, single return value from the system call is
+insufficient to report the reason of a failure.
+
+Checkpoint - to provide informative status report upon failure, the
+checkpoint image may contain one (or more) error objects, 'struct
+ckpt_hdr_err'.  An error objects consists of a mandatory pre-header
+followed by a null character ('\0'), and then a string that describes
+the error. By default, if an error occurs, this will be the last
+object written to the checkpoint image.
+
+Upon failure, the caller can examine the image (e.g. with 'ckptinfo')
+and extract the detailed error message. The leading '\0' is useful if
+one wants to seek back from the end of the checkpoint image, instead
+of parsing the entire image separately.
+
+Restart - to be defined.
+
+
+Security
+========
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
+However, this can be controlled with a sysctl-variable.
+
+
+Kernel interfaces
+=================
+
+To checkpoint a vma, the 'struct vm_operations_struct' needs to
+provide a method ->checkpoint:
+  int checkpoint(struct ckpt_ctx *, struct vma_struct *)
+Restart requires a matching (exported) restore:
+  int restore(struct ckpt_ctx *, struct mm_struct *, struct ckpt_hdr_vma *)
+
+To checkpoint a vma, the 'struct file_operations' needs to provide
+a method ->checkpoint:
+  int checkpoint(struct ckpt_ctx *, struct file *)
+Restart requires a matching (exported) restore:
+  int restore(struct ckpt_ctx *, struct ckpt_hdr_file *)
+For most file systems, generic_file_{checkpoint,restore}() can be
+used.
+
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
index 0000000..3432dc1
--- /dev/null
+++ b/Documentation/checkpoint/usage.txt
@@ -0,0 +1,192 @@
+
+	      How to use Checkpoint-Restart
+	=========================================
+
+
+API
+===
+
+The API consists of two new system calls:
+
+* int checkpoint(pid_t pid, int fd, unsigned long flag);
+
+ Checkpoint a (sub-)container whose root task is identified by @pid,
+ to the open file indicated by @fd. @flags may be on or more of:
+   - CHECKPOINT_SUBTREE : allow checkpoint of sub-container
+ (other value are not allowed).
+
+ Returns: a positive checkpoint identifier (ckptid) upon success, 0 if
+ it returns from a restart, and -1 if an error occurs. The ckptid will
+ uniquely identify a checkpoint image, for as long as the checkpoint
+ is kept in the kernel (e.g. if one wishes to keep a checkpoint, or a
+ partial checkpoint, residing in kernel memory).
+
+* int sys_restart(pid_t pid, int fd, unsigned long flags);
+
+ Restart a process hierarchy from a checkpoint image that is read from
+ the blob stored in the file indicated by @fd. The @flags' will have
+ future meaning (must be 0 for now). @pid indicates the root of the
+ hierarchy (may mean 'ckptid' to identify an in-kernel checkpoint
+ image, with some @flags in the future).
+
+ Returns: -1 if an error occurs, 0 on success when restarting from a
+ "self" checkpoint, and return value of system call at the time of the
+ checkpoint when restarting from an "external" checkpoint.
+
+ TODO: upon successful "external" restart, the container will end up
+ in a frozen state.
+
+
+Sysctl/proc
+===========
+
+/proc/sys/kernel/ckpt_unpriv_allowed		[default = 1]
+  controls whether c/r operation is allowed for unprivileged users
+
+
+Operation
+=========
+
+The granularity of a checkpoint usually is a process hierarchy. The
+'pid' argument is interpreted in the caller's pid namespace. So to
+checkpoint a container whose init task (pid 1 in that pidns) appears
+as pid 3497 the caller's pidns, the caller must use pid 3497. Passing
+pid 1 will attempt to checkpoint the caller's container, and if the
+caller isn't privileged and init is owned by root, it will fail.
+
+Unless the CHECKPOINT_SUBTREE flag is set, if the caller passes a pid
+which does not refer to a container's init task, then sys_checkpoint()
+would return -EINVAL.
+
+We assume that during checkpoint and restart the container state is
+quiescent. During checkpoint, this means that all affected tasks are
+frozen (or otherwise stopped). During restart, this means that all
+affected tasks are executing the sys_restart() call. In both cases, if
+there are other tasks possible sharing state with the container, they
+must not modify it during the operation. It is the responsibility of
+the caller to follow this requirement.
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
+User tools
+==========
+
+* ckpt: a tool to perform a checkpoint of a container/subtree
+* mktree: a tool to restart a container/subtree
+* ckptinfo: a tool to examine a checkpoint image
+
+It is best to use the dedicated user tools for checkpoint and restart.
+
+If you insist, then here is a code snippet that illustrates how a
+checkpoint is initiated by a process inside a container - the logic is
+similar to fork():
+	...
+	ckptid = checkpoint(1, ...);
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
+	if (restart(pid, ...) < 0)
+		perror("restart failed");
+	/* only get here if restart failed */
+	...
+
+Note, that the code also supports "self" checkpoint, where a process
+can checkpoint itself. This mode does not capture the relationships of
+the task with other tasks, or any shared resources. It is useful for
+application that wish to be able to save and restore their state.
+They will either not use (or care about) shared resources, or they
+will be aware of the operations and adapt suitably after a restart.
+The code above can also be used for "self" checkpoint.
+
+
+You may find the following sample programs useful:
+
+* ckpt.c: accepts a 'pid' argument and checkpoint that task to stdout
+* rstr.c: restarts a checkpoint image from stdin
+* self.c: a simple test program doing self-checkpoint
+* test.c: a simple test program to checkpoint
+
+
+"External" checkpoint
+=====================
+
+To do "external" checkpoint, you need to first freeze that other task
+either using the freezer cgroup.
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
+
+"Self checkpoint
+================
+
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
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 9d4caff..881965b 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -1,7 +1,7 @@
 /*
  *  Generic container checkpoint-restart
  *
- *  Copyright (C) 2008 Oren Laadan
+ *  Copyright (C) 2008-2009 Oren Laadan
  *
  *  This file is subject to the terms and conditions of the GNU General Public
  *  License.  See the file COPYING in the main directory of the Linux
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
