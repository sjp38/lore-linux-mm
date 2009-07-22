Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0F56B0083
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:00:38 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 00/60] Kernel based checkpoint/restart
Date: Wed, 22 Jul 2009 05:59:22 -0400
Message-Id: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>
List-ID: <linux-mm.kvack.org>

Application checkpoint/restart (c/r) is the ability to save the state
of a running application so that it can later resume its execution
from the time at which it was checkpointed, on the same or a different
machine.

This version introduces 'clone_with_pids()' syscall to preset pid(s)
for a child process. It is used by restart(2) to recreate process
hierarchy with the same pids as at checkpoint time.

It also adds a freezer state CHECKPOINTING to safeguard processes
during a checkpoint. Other important changes include support for
threads and zombies, credentials, signal handling, and improved
restart logic. See below for a more detailed changelog.

Compiled and tested against v2.6.31-rc3.

For more information, check out Documentation/checkpoint/*.txt

Q: How useful is this code as it stands in real-world usage?
A: Right now, the application can be single- or multi-processes and
   threads. Supports open files - regular files and directories on
   ext[234], pipes, and /dev/{null,zero,random,urandom}. All sort of
   shared memory work. sysv IPC also works (except for semaphore 
   undo). It's already suitable for many types of batch jobs. (Note:
   it is assumed that the fs view is available at restart).

Q: What can it checkpoint and restart ?
A: A (single threaded) process can checkpoint itself, aka "self"
   checkpoint, if it calls the new system calls. Otherise, for an
   "external" checkpoint, the caller must first freeze the target
   processes. One can either checkpoint an entire container (and
   we make best effort to ensure that the result is self-contained),
   or merely a subtree of a process hierarchy.

Q: What about namespaces ?
A: Currrently, UTS and IPC namespaces are restored. They demonstrate
   how namespaces are handled. More to come.

Q: What additional work needs to be done to it?
A: Fill in the gory details following the examples so far. WIP
   includes (pending) signals, fifos, pseudo terminals, unix-
   domain sockets, event-poll, architectures: powerpc and x86_64,
   and more file systems types. 
   
Q: How can I try it ?
A: This one can actually be used for simple batch jobs (pipes, too),
   a whole container or just a subtree of tasks. Try it:

   create the freezer cgroup:
     $ mount -t cgroup -ofreezer freezer /cgroup
     $ mkdir /cgroup/0
   
   run the test, freeze it:  
     $ test/multitask &
     [1] 2754
     $ for i in `pidof multitask`; do echo $i > /cgroup/0/tasks; done
     $ echo FROZEN > /cgruop/0/freezer.state
   
   checkpoint:
     $ ./ckpt 2754 > ckpt.out
   
   restart:
     $ ./mktree < ckpt.out
   
   voila :)
   
To do all this, you'll need:

The git tree tracking v17, branch 'ckpt-v17' (and past versions):
	git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git

Restarting multiple processes requires 'mktree' userspace tool with
the matching branch (v17):
	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git

Oren.


Changelog:

[2009-Jul-21] v17
  - Introduce syscall clone_with_pids() to restore original pids
  - Support threads and zombies
  - Save/restore task->files
  - Save/restore task->sighand
  - Save/restore futex
  - Save/restore credentials
  - Introduce PF_RESTARTING to skip notifications on task exit
  - restart(2) allow caller to ask to freeze tasks after restart
  - restart(2) isn't idempotent: return -EINTR if interrupted
  - Improve debugging output handling 
  - Make multi-process restart logic more robust and complete
  - Correctly select return value for restarting tasks on success
  - Tighten ptrace test for checkpoint to PTRACE_MODE_ATTACH
  - Use CHECKPOINTING state for frozen checkpointed tasks
  - Fix compilation without CONFIG_CHECKPOINT
  - Fix compilation with CONFIG_COMPAT
  - Fix headers includes and exports
  - Leak detection performed in two steps
  - Detect "inverse" leaks of objects (dis)appearing unexpectedly
  - Memory: save/restore mm->{flags,def_flags,saved_auxv}
  - Memory: only collect sub-objects of mm once (leak detection)
  - Files: validate f_mode after restore
  - Namespaces: leak detection for nsproxy sub-components
  - Namespaces: proper restart from namespace(s) without namespace(s)
  - Save global constants in header instead of per-object
  - IPC: replace sys_unshare() with create_ipc_ns()
  - IPC: restore objects in suitable namespace
  - IPC: correct behavior under !CONFIG_IPC_NS
  - UTS: save/restore all fields
  - UTS: replace sys_unshare() with create_uts_ns()
  - X86_32: sanitize cpu, debug, and segment registers on restart
  - cgroup_freezer: add CHECKPOINTING state to safeguard checkpoint
  - cgroup_freezer: add interface to freeze a cgroup (given a task)

[2009-May-27] v16
  - Privilege checks for IPC checkpoint
  - Fix error string generation during checkpoint
  - Use kzalloc for header allocation
  - Restart blocks are arch-independent
  - Redo pipe c/r using splice
  - Fixes to s390 arch
  - Remove powerpc arch (temporary)
  - Explicitly restore ->nsproxy
  - All objects in image are precedeed by 'struct ckpt_hdr'
  - Fix leaks detection (and leaks)
  - Reorder of patchset
  - Misc bugs and compilation fixes

[2009-Apr-12] v15
  - Minor fixes

[2009-Apr-28] v14
  - Tested against kernel v2.6.30-rc3 on x86_32.
  - Refactor files chekpoint to use f_ops (file operations)
  - Refactor mm/vma to use vma_ops
  - Explicitly handle VDSO vma (and require compat mode)
  - Added code to c/r restat-blocks (restart timeout related syscalls)
  - Added code to c/r namespaces: uts, ipc (with Dan Smith)
  - Added code to c/r sysvipc (shm, msg, sem)
  - Support for VM_CLONE shared memory
  - Added resource leak detection for whole-container checkpoint
  - Added sysctl gauge to allow unprivileged restart/checkpoint
  - Improve and simplify the code and logic of shared objects
  - Rework image format: shared objects appear prior to their use
  - Merge checkpoint and restart functionality into same files
  - Massive renaming of functions: prefix "ckpt_" for generics,
    "checkpoint_" for checkpoint, and "restore_" for restart.
  - Report checkpoint errors as a valid (string record) in the output
  - Merged PPC architecture (by Nathan Lunch),
  - Requires updates to userspace tools too.
  - Misc nits and bug fixes

[2009-Mar-31] v14-rc2
  - Change along Dave's suggestion to use f_ops->checkpoint() for files
  - Merge patch simplifying Kconfig, with CONFIG_CHECKPOINT_SUPPORT
  - Merge support for PPC arch (Nathan Lynch)
  - Misc cleanups and fixes in response to comments

[2009-Mar-20] v14-rc1:
  - The 'h.parent' field of 'struct cr_hdr' isn't used - discard
  - Check whether calls to cr_hbuf_get() succeed or fail.
  - Fixed of pipe c/r code
  - Prevent deadlock by refusing c/r when a pipe inode == ctx->file inode
  - Refuse non-self checkpoint if a task isn't frozen
  - Use unsigned fields in checkpoint headers unless otherwise required
  - Rename functions in files c/r to better reflect their role
  - Add support for anonymous shared memory
  - Merge support for s390 arch (Dan Smith, Serge Hallyn)
    
[2008-Dec-03] v13:
  - Cleanups of 'struct cr_ctx' - remove unused fields
  - Misc fixes for comments
  
[2008-Dec-17] v12:
  - Fix re-alloc/reset of pgarr chain to correctly reuse buffers
    (empty pgarr are saves in a separate pool chain)
  - Add a couple of missed calls to cr_hbuf_put()
  - cr_kwrite/cr_kread() again use vfs_read(), vfs_write() (safer)
  - Split cr_write/cr_read() to two parts: _cr_write/read() helper
  - Befriend with sparse: explicit conversion to 'void __user *'
  - Redrefine 'pr_fmt' ind replace cr_debug() with pr_debug()

[2008-Dec-05] v11:
  - Use contents of 'init->fs->root' instead of pointing to it
  - Ignore symlinks (there is no such thing as an open symlink)
  - cr_scan_fds() retries from scratch if it hits size limits
  - Add missing test for VM_MAYSHARE when dumping memory
  - Improve documentation about: behavior when tasks aren't fronen,
    life span of the object hash, references to objects in the hash
 
[2008-Nov-26] v10:
  - Grab vfs root of container init, rather than current process
  - Acquire dcache_lock around call to __d_path() in cr_fill_name()
  - Force end-of-string in cr_read_string() (fix possible DoS)
  - Introduce cr_write_buffer(), cr_read_buffer() and cr_read_buf_type()

[2008-Nov-10] v9:
  - Support multiple processes c/r
  - Extend checkpoint header with archtiecture dependent header 
  - Misc bug fixes (see individual changelogs)
  - Rebase to v2.6.28-rc3.

[2008-Oct-29] v8:
  - Support "external" checkpoint
  - Include Dave Hansen's 'deny-checkpoint' patch
  - Split docs in Documentation/checkpoint/..., and improve contents

[2008-Oct-17] v7:
  - Fix save/restore state of FPU
  - Fix argument given to kunmap_atomic() in memory dump/restore

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
