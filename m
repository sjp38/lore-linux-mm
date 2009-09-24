Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D5B4F6B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 09:06:17 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n8OD6DTQ023864
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 18:36:13 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8OD6CGH2818086
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 18:36:12 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n8OD6CaL026078
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 23:06:12 +1000
Message-ID: <4ABB6EB6.2040204@linux.vnet.ibm.com>
Date: Thu, 24 Sep 2009 18:35:58 +0530
From: Rishikesh <risrajak@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/80] Kernel based checkpoint/restart [v18]
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Oren Laadan <orenl@librato.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Oren,

I am getting following build error while compiling linux-cr kernel.

git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git

...
76569 net/unix/af_unix.c:528: error: ?unix_collect? undeclared here (not 
in a function)
76570 LD [M] drivers/net/enic/enic.o
76571 make[2]: *** [net/unix/af_unix.o] Error 1
76572 make[1]: *** [net/unix] Error 2
76573 make: *** [net] Error 2
76574 make: *** Waiting for unfinished jobs....
...

Let me know if you need config file.

-Rishi
Oren Laadan wrote:
> Hi Andrew,
>
> This is our recent round of checkpoint/restart patches. It can
> checkpoint and restart interactive sessions of 'screen' across 
> kernel reboot. Please consider applying to -mm.
>
> Patches 1-17 are clean-ups and preparations for c/r:
>  * 1,2,3,4 and 9,10: cleanups, also useful for c/r.
>  * 5,6: fix freezer control group
>  * 7,8: extend freezer control group for c/r.
>  * 11-17: clone_with_pid
>
> Patch 18 reserves the system calls slots - please apply so we
> don't need to keep changing them.
>
> Patches 19-80 contain the actual c/r code; we've exhausted the
> reviewers for most of them.
>
> Patch 32 implements a deferqueue - mechanism for a process to
> defer work for some later time (unlike workqueue, designed for
> the work to execute in the context of same/original process).
>
> Thanks,
>
> Oren.
>
> ----
>
> Application checkpoint/restart (c/r) is the ability to save the state
> of a running application so that it can later resume its execution
> from the time at which it was checkpointed, on the same or a different
> machine.
>
> This version brings support many new features, including support for
> unix domain sockets, fifos, pseudo-terminals, and signals (see the
> detailed changelog below).
>
> With these in place, it can now checkpoint and restart not only batch
> jobs, but also interactive programs using 'screen'. For example, users
> can checkpoint a 'screen' session with multiple shells, upgrade their
> kernel, reboot, and restart their interactive 'screen' session from
> before !
>
> This patchset was compiled and tested against v2.6.31. For more
> information, check out Documentation/checkpoint/*.txt
>
> Q: How useful is this code as it stands in real-world usage?
> A: The application can be single- or multi-processes and threads. It
>    handles open files (regular files/directories on most file systems,
>    pipes, fifos, af_unix sockets, /dev/{null,zero,random,urandom} and
>    pseudo-terminals. It supports shared memory. sysv IPC (except undo
>    of sempahores). It's suitable for many types of batch jobs as well
>    as some interactive jobs. (Note: it is assumed that the fs view is
>    available at restart).
>
> Q: What can it checkpoint and restart ?
> A: A (single threaded) process can checkpoint itself, aka "self"
>    checkpoint, if it calls the new system calls. Otherise, for an
>    "external" checkpoint, the caller must first freeze the target
>    processes. One can either checkpoint an entire container (and
>    we make best effort to ensure that the result is self-contained),
>    or merely a subtree of a process hierarchy.
>
> Q: What about namespaces ?
> A: Currrently, UTS and IPC namespaces are restored. They demonstrate
>    how namespaces are handled. More to come.
>
> Q: What additional work needs to be done to it?
> A: Fill in the gory details following the examples so far. Current WIP
>    includes inet sockets, event-poll, and early work on inotify, mount
>    namespace and mount-points, pseudo file systems, and x86_64 support.
>    
> Q: How can I try it ?
> A: Use it for simple batch jobs (pipes, too), or an interactive
>    'screen' session, in a whole container or just a subtree of
>    tasks:
>
>    create the freezer cgroup:
>      $ mount -t cgroup -ofreezer freezer /cgroup
>      $ mkdir /cgroup/0
>    
>    run the test, freeze it:  
>      $ test/multitask &
>      [1] 2754
>      $ for i in `pidof multitask`; do echo $i > /cgroup/0/tasks; done
>      $ echo FROZEN > /cgruop/0/freezer.state
>    
>    checkpoint:
>      $ ./ckpt 2754 > ckpt.out
>    
>    restart:
>      $ ./mktree < ckpt.out
>    
>    voila :)
>    
> To do all this, you'll need:
>
> The git tree tracking v18, branch 'ckpt-v18' (and past versions):
> 	git://git.ncl.cs.columbia.edu/pub/git/linux-cr.git
>
> The userspace tools are available through the matching branch [v18]:
> 	git://git.ncl.cs.columbia.edu/pub/git/user-cr.git
>
>
> Changelog:
>
> [2009-Sep-22] v18
>
>   (new features)
>   - [Nathan Lynch] Re-introduce powerpc support
>   - Save/restore pseudo-terminals
>   - Save/restore (pty) controlling terminals
>   - Save/restore restore PGIDs
>   - [Dan Smith] Save/restore unix domain sockets
>   - Save/restore FIFOs
>   - Save/restore pending signals
>   - Save/restore rlimits
>   - Save/restore itimers
>   - [Matt Helsley] Handle many non-pseudo file-systems
>
>   (other changes)
>   - Rename headerless struct ckpt_hdr_* to struct ckpt_*
>   - [Nathan Lynch] discard const from struct cred * where appropriate
>   - [Serge Hallyn][s390] Set return value for self-checkpoint 
>   - Handle kmalloc failure in restore_sem_array()
>   - [IPC] Collect files used by shm objects
>   - [IPC] Use file (not inode) as shared object on checkpoint of shm
>   - More ckpt_write_err()s to give information on checkpoint failure
>   - Adjust format of pipe buffer to include the mandatory pre-header
>   - [LEAKS] Mark the backing file as visited at chekcpoint
>   - Tighten checks on supported vma to checkpoint or restart
>   - [Serge Hallyn] Export filemap_checkpoint() (used for ext4)
>   - Introduce ckpt_collect_file() that also uses file->collect method
>   - Use ckpt_collect_file() instead of ckpt_obj_collect() for files
>   - Fix leak-detection issue in collect_mm() (test for first-time obj)
>   - Invoke set_close_on_exec() unconditionally on restart
>   - [Dan Smith] Export fill_fname() as ckpt_fill_fname()
>   - Interface to pass simple pointers as data with deferqueue
>   - [Dan Smith] Fix ckpt_obj_lookup_add() leak detection logic
>   - Replace EAGAIN with EBUSY where necessary
>   - Introduce CKPT_OBJ_VISITED in leak detection
>   - ckpt_obj_collect() returns objref for new objects, 0 otherwise
>   - Rename ckpt_obj_checkpointed() to ckpt_obj_visited()
>   - Introduce ckpt_obj_visit() to mark objects as visited
>   - Set the CHECKPOINTED flag on objects before calling checkpoint
>   - Introduce ckpt_obj_reserve()
>   - Change ref_drop() to accept a @lastref argument (for cleanup)
>   - Disallow multiple objects with same objref in restart
>   - Allow _ckpt_read_obj_type() to read header only (w/o payload)
>   - Fix leak of ckpt_ctx when restoring zombie tasks
>   - Fix race of prepare_descendant() with an ongoing fork()
>   - Track and report the first error if restart fails
>   - Tighten logic to protect against bogus pids in input
>   - [Matt Helsley] Improve debug output from ckpt_notify_error()
>   - [Nathan Lynch] fix compilation errors with CONFIG_COMPAT=y
>   - Detect error-headers in input data on restart, and abort.
>   - Standard format for checkpoint error strings (and documentation)
>   - [Dan Smith] Add an errno validation function
>   - Add ckpt_read_payload(): read a variable-length object (no header)
>   - Add ckpt_read_string(): same for strings (ensures null-terminated)
>   - Add ckpt_read_consume(): consumes next object without processing
>   - [John Dykstra] Fix no-dot-config-targets pattern in linux/Makefile
>
> [2009-Jul-21] v17
>   - Introduce syscall clone_with_pids() to restore original pids
>   - Support threads and zombies
>   - Save/restore task->files
>   - Save/restore task->sighand
>   - Save/restore futex
>   - Save/restore credentials
>   - Introduce PF_RESTARTING to skip notifications on task exit
>   - restart(2) allow caller to ask to freeze tasks after restart
>   - restart(2) isn't idempotent: return -EINTR if interrupted
>   - Improve debugging output handling 
>   - Make multi-process restart logic more robust and complete
>   - Correctly select return value for restarting tasks on success
>   - Tighten ptrace test for checkpoint to PTRACE_MODE_ATTACH
>   - Use CHECKPOINTING state for frozen checkpointed tasks
>   - Fix compilation without CONFIG_CHECKPOINT
>   - Fix compilation with CONFIG_COMPAT
>   - Fix headers includes and exports
>   - Leak detection performed in two steps
>   - Detect "inverse" leaks of objects (dis)appearing unexpectedly
>   - Memory: save/restore mm->{flags,def_flags,saved_auxv}
>   - Memory: only collect sub-objects of mm once (leak detection)
>   - Files: validate f_mode after restore
>   - Namespaces: leak detection for nsproxy sub-components
>   - Namespaces: proper restart from namespace(s) without namespace(s)
>   - Save global constants in header instead of per-object
>   - IPC: replace sys_unshare() with create_ipc_ns()
>   - IPC: restore objects in suitable namespace
>   - IPC: correct behavior under !CONFIG_IPC_NS
>   - UTS: save/restore all fields
>   - UTS: replace sys_unshare() with create_uts_ns()
>   - X86_32: sanitize cpu, debug, and segment registers on restart
>   - cgroup_freezer: add CHECKPOINTING state to safeguard checkpoint
>   - cgroup_freezer: add interface to freeze a cgroup (given a task)
>
> [2009-May-27] v16
>   - Privilege checks for IPC checkpoint
>   - Fix error string generation during checkpoint
>   - Use kzalloc for header allocation
>   - Restart blocks are arch-independent
>   - Redo pipe c/r using splice
>   - Fixes to s390 arch
>   - Remove powerpc arch (temporary)
>   - Explicitly restore ->nsproxy
>   - All objects in image are precedeed by 'struct ckpt_hdr'
>   - Fix leaks detection (and leaks)
>   - Reorder of patchset
>   - Misc bugs and compilation fixes
>
> [2009-Apr-12] v15
>   - Minor fixes
>
> [2009-Apr-28] v14
>   - Tested against kernel v2.6.30-rc3 on x86_32.
>   - Refactor files chekpoint to use f_ops (file operations)
>   - Refactor mm/vma to use vma_ops
>   - Explicitly handle VDSO vma (and require compat mode)
>   - Added code to c/r restat-blocks (restart timeout related syscalls)
>   - Added code to c/r namespaces: uts, ipc (with Dan Smith)
>   - Added code to c/r sysvipc (shm, msg, sem)
>   - Support for VM_CLONE shared memory
>   - Added resource leak detection for whole-container checkpoint
>   - Added sysctl gauge to allow unprivileged restart/checkpoint
>   - Improve and simplify the code and logic of shared objects
>   - Rework image format: shared objects appear prior to their use
>   - Merge checkpoint and restart functionality into same files
>   - Massive renaming of functions: prefix "ckpt_" for generics,
>     "checkpoint_" for checkpoint, and "restore_" for restart.
>   - Report checkpoint errors as a valid (string record) in the output
>   - Merged PPC architecture (by Nathan Lunch),
>   - Requires updates to userspace tools too.
>   - Misc nits and bug fixes
>
> [2009-Mar-31] v14-rc2
>   - Change along Dave's suggestion to use f_ops->checkpoint() for files
>   - Merge patch simplifying Kconfig, with CONFIG_CHECKPOINT_SUPPORT
>   - Merge support for PPC arch (Nathan Lynch)
>   - Misc cleanups and fixes in response to comments
>
> [2009-Mar-20] v14-rc1:
>   - The 'h.parent' field of 'struct cr_hdr' isn't used - discard
>   - Check whether calls to cr_hbuf_get() succeed or fail.
>   - Fixed of pipe c/r code
>   - Prevent deadlock by refusing c/r when a pipe inode == ctx->file inode
>   - Refuse non-self checkpoint if a task isn't frozen
>   - Use unsigned fields in checkpoint headers unless otherwise required
>   - Rename functions in files c/r to better reflect their role
>   - Add support for anonymous shared memory
>   - Merge support for s390 arch (Dan Smith, Serge Hallyn)
>     
> [2008-Dec-03] v13:
>   - Cleanups of 'struct cr_ctx' - remove unused fields
>   - Misc fixes for comments
>   
> [2008-Dec-17] v12:
>   - Fix re-alloc/reset of pgarr chain to correctly reuse buffers
>     (empty pgarr are saves in a separate pool chain)
>   - Add a couple of missed calls to cr_hbuf_put()
>   - cr_kwrite/cr_kread() again use vfs_read(), vfs_write() (safer)
>   - Split cr_write/cr_read() to two parts: _cr_write/read() helper
>   - Befriend with sparse: explicit conversion to 'void __user *'
>   - Redrefine 'pr_fmt' ind replace cr_debug() with pr_debug()
>
> [2008-Dec-05] v11:
>   - Use contents of 'init->fs->root' instead of pointing to it
>   - Ignore symlinks (there is no such thing as an open symlink)
>   - cr_scan_fds() retries from scratch if it hits size limits
>   - Add missing test for VM_MAYSHARE when dumping memory
>   - Improve documentation about: behavior when tasks aren't fronen,
>     life span of the object hash, references to objects in the hash
>
> [2008-Nov-26] v10:
>   - Grab vfs root of container init, rather than current process
>   - Acquire dcache_lock around call to __d_path() in cr_fill_name()
>   - Force end-of-string in cr_read_string() (fix possible DoS)
>   - Introduce cr_write_buffer(), cr_read_buffer() and cr_read_buf_type()
>
> [2008-Nov-10] v9:
>   - Support multiple processes c/r
>   - Extend checkpoint header with archtiecture dependent header 
>   - Misc bug fixes (see individual changelogs)
>   - Rebase to v2.6.28-rc3.
>
> [2008-Oct-29] v8:
>   - Support "external" checkpoint
>   - Include Dave Hansen's 'deny-checkpoint' patch
>   - Split docs in Documentation/checkpoint/..., and improve contents
>
> [2008-Oct-17] v7:
>   - Fix save/restore state of FPU
>   - Fix argument given to kunmap_atomic() in memory dump/restore
>
> [2008-Oct-07] v6:
>   - Balance all calls to cr_hbuf_get() with matching cr_hbuf_put()
>     (even though it's not really needed)
>   - Add assumptions and what's-missing to documentation
>   - Misc fixes and cleanups
>
> [2008-Sep-11] v5:
>   - Config is now 'def_bool n' by default
>   - Improve memory dump/restore code (following Dave Hansen's comments)
>   - Change dump format (and code) to allow chunks of <vaddrs, pages>
>     instead of one long list of each
>   - Fix use of follow_page() to avoid faulting in non-present pages
>   - Memory restore now maps user pages explicitly to copy data into them,
>     instead of reading directly to user space; got rid of mprotect_fixup()
>   - Remove preempt_disable() when restoring debug registers
>   - Rename headers files s/ckpt/checkpoint/
>   - Fix misc bugs in files dump/restore
>   - Fixes and cleanups on some error paths
>   - Fix misc coding style
>
> [2008-Sep-09] v4:
>   - Various fixes and clean-ups
>   - Fix calculation of hash table size
>   - Fix header structure alignment
>   - Use stand list_... for cr_pgarr
>
> [2008-Aug-29] v3:
>   - Various fixes and clean-ups
>   - Use standard hlist_... for hash table
>   - Better use of standard kmalloc/kfree
>
> [2008-Aug-20] v2:
>   - Added Dump and restore of open files (regular and directories)
>   - Added basic handling of shared objects, and improve handling of
>     'parent tag' concept
>   - Added documentation
>   - Improved ABI, 64bit padding for image data
>   - Improved locking when saving/restoring memory
>   - Added UTS information to header (release, version, machine)
>   - Cleanup extraction of filename from a file pointer
>   - Refactor to allow easier reviewing
>   - Remove requirement for CAPS_SYS_ADMIN until we come up with a
>     security policy (this means that file restore may fail)
>   - Other cleanup and response to comments for v1
>
> [2008-Jul-29] v1:
>   - Initial version: support a single task with address space of only
>     private anonymous or file-mapped VMAs; syscalls ignore pid/crid
>     argument and act on current process.
>
> --
> At the containers mini-conference before OLS, the consensus among
> all the stakeholders was that doing checkpoint/restart in the kernel
> as much as possible was the best approach.  With this approach, the
> kernel will export a relatively opaque 'blob' of data to userspace
> which can then be handed to the new kernel at restore time.
>
> This is different than what had been proposed before, which was
> that a userspace application would be responsible for collecting
> all of this data.  We were also planning on adding lots of new,
> little kernel interfaces for all of the things that needed
> checkpointing.  This unites those into a single, grand interface.
>
> The 'blob' will contain copies of select portions of kernel
> structures such as vmas and mm_structs.  It will also contain
> copies of the actual memory that the process uses.  Any changes
> in this blob's format between kernel revisions can be handled by
> an in-userspace conversion program.
>
> This is a similar approach to virtually all of the commercial
> checkpoint/restart products out there, as well as the research
> project Zap.
>
> These patches basically serialize internel kernel state and write
> it out to a file descriptor.  The checkpoint and restore are done
> with two new system calls: sys_checkpoint and sys_restart.
>
> In this incarnation, they can only work checkpoint and restore a
> single task. The task's address space may consist of only private,
> simple vma's - anonymous or file-mapped. The open files may consist
> of only simple files and directories.
> --
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
