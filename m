Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA096B01B5
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:09:41 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 00/96] Linux Checkpoint-Restart - v20
Date: Wed, 17 Mar 2010 12:07:48 -0400
Message-Id: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Following up on the thread on the checkpoint-restart patch set
(http://lkml.org/lkml/2010/3/1/422), the following series is the
latest checkpoint/restart, based on 2.6.33.

The first 20 patches are cleanups and prepartion for c/r; they
are followed by the actual c/r code.

Please apply to -mm, and let us know if there is any way we can
help.

Thanks,

Oren.

---

Linux Checkpoint-Restart:
 web, wiki:	http://www.linux-cr.org
 bug track:	https://www.linux-cr.org/redmine

The repositories for the project are in:
 kernel:	http://www.linux-cr.org/git/?p=linux-cr.git;a=summary
 user tools:	http://www.linux-cr.org/git/?p=user-cr.git;a=summary
 tests suite:	http://www.linux-cr.org/git/?p=tests-cr.git;a=summary

---

CHANGELOG:

v20 [2010-Mar-16]
 BUG FIXES (only)
  - [Serge Hallyn] Fix unlabeled restore case
  - [Serge Hallyn] Always restore msg_msg label
  - [Serge Hallyn] Selinux prevents msgrcv on restore message queues?
  - [Serge Hallyn] save_access_regs for self-checkpoint
  - [Serge Hallyn] send uses_interp=1 to arch_setup_additional_pages
  - Fix "scheduling in atomic" while restoring ipc (sem, shm, msg)
  - Cleanup: no need to restore perm->{id,key,seq}
  - Fix sysvipc=n compile
  - Make uts_ns=n compile
  - Only use arch_setup_additional_pages() if supported by arch
  - Export key symbols to enable c/r from kernel modules
  - Avoid crash if incoming object doesn't have .restore
  - Replace error_sem with an event completion
  - [Serge Hallyn] Change sysctl and default for unprivileged use
  - [Nathan Lynch] Use syscall_get_error
  - Add entry for checkpoint/restart in MAINTAINERS 

[2010-Feb-19] v19
 NEW FEATURES
  - Support for x86-64 architecture
  - Support for c/r of LSM (smack, selinux)
  - Support for c/r of task fs_root and pwd
  - Support for c/r of epoll
  - Support for c/r of eventfd
  - Enable C/R while executing over NFS
  - Preliminary c/r of mounts namespace
  - Add @logfd argument to sys_{checkpoint,restart} prototypes
  - Define new api for error and debug logging
  - Restart to handle checkpoint images lacking {uts,ipc}-ns
  - Refuse to checkpoint if monitoring directories with dnotify
  - Refuse to checkpoint if file locks and leases are held
  - Refuse to checkpoint files with f_owner 
 OTHER CHANGES
  - Rebase to kernel 2.6.33-rc8
  - Settled version of new sys_eclone()
  - [Serge Hallyn] Fix potential use-before-set return (vdso)
  - Update documentation and examples for new syscalls API (doc)
  - [Liu Alexander] Fix typos (doc)
  - [Serge Hallyn] Update checkpoint image format (doc)
  - [Serge Hallyn] Use ckpt_err() to for bad header values
  - sys_{checkpoint,restart} to use ptregs prototype
  - Set ctx->errno in do_ckpt_msg() if needed
  - Fix up headers so we can munge them for use by userspace
  - Multiple fixes to _ckpt_write_err() and friends
  - [Matt Helsley] Add cpp definitions for enums
  - [Serge Hallyn] Add global section container to image format
  - [Matt Helsley] Fix total byte read/write count for large images
  - ckpt_read_buf_type() to accept max payload (excludes ckpt_hdr)
  - [Serge Hallyn] Use ckpt_err() for arch incompatbilities
  - Introduce walk_task_subtree() to iterate through descendants
  - Call restore_notify_error for restart (not checkpoint !)
  - Make kread/kwrite() abort if CKPT_CTX_ERROR is set
  - [Serge Hallyn] Move init_completion(&ctx->complete) to ctx_alloc
  - Simplify logic of tracking restarting tasks (->ctx)
  - Coordinator kills descendants on failure for proper cleanup
  - Prepare descendants needs PTRACE_MODE_ATTACH permissions
  - Threads wait for entire thread group before restoring
  - Add debug process-tree status during restart
  - Fix handling of bogus pid arg to sys_restart
  - In reparent_thread() test for PF_RESTARTING on parent
  - Keep __u32s in even groups for 32-64 bit compatibility
  - Define ckpt_obj_try_fetch
  - Disallow zero or negative objref during restart
  - Check for valid destructor before calling it (deferqueue)
  - Fix false negative of test for unlinked files at checkpoint
  - [Serge Hallyn] Rename fs_mnt to root_fs_path
  - Restore thread/cpu state early
  - Ensure null-termination of file names read from image
  - Fix compile warning in restore_open_fname()
  - Introduce FOLL_DIRTY to follow_page() for "dirty" pages
  - [Serge Hallyn] Checkpoint saved_auxv as u64s
  - Export filemap_checkpoint()
  - [Serge Hallyn] Disallow checkpoint of tasks with aio requests
  - Fix compilation failure when !CONFIG_CHEKCPOINT (regression)
  - Expose page write functions
  - Do not hold mmap_sem while checkpointing vma's
  - Do not hold mmap_sem when reading memory pages on restart
  -  Move consider_private_page() to mm/memory.c:__get_dirty_page()
  - [Serge Hallyn] move destroy_mm into mmap.c and remove size check
  - [Serge Hallyn] fill vdso (syscall32_setup_pages) for TIF_IA32/x86_64
  - [Serge Hallyn] Fix return value of read_pages_contents()
  - [Serge Hallyn] Change m_type to long, not int (ipc)
  - Don't free sma if it's an error on restore
  - Use task->saves_sigmask and drop task->checkpoint_data
  - [Serge Hallyn] Handle saved_sigmask at checkpoint
  - Defer restore of blocked signals mask during restart
  - Self-restart to tolerate missing PGIDs
  - [Serge Hallyn] skb->tail can be offset
  - Export and leverage sock_alloc_file()
  - [Nathan Lynch] Fix net/checkpoint.c for 64-bit
  - [Dan Smith] Unify skb read/write functions and handle fragmented buffers
  - [Dan Smith] Update buffer restore code to match the new format
  - [Dan Smith] Fix compile issue with CONFIG_CHECKPOINT=n
  - [Dan Smith] Remove an unnecessary check on socket restart
  - [Dan Smith] Pass the stored sock->protocol into sock_create() on restore
  - Relax tcp.window_clamp value in INET restore
  - Restore gso_type fields on sockets and buffers for proper operation
  - Fix broken compilation for no-c/r architectures
  - Return -EBUSY (not BUG_ON) if fd is gone on restart
  - Fix the chunk size instead of auto-tune (epoll) 
 ARCH: x86 (32,64)
  - Use PTREGSCALL4 for sys_{checkpoint,restart}
  - Remove debug-reg support (need to redo with perf_events)
  - [Serge Hallyn] Support for ia32 (checkpoint, restart)
  - Split arch/x86/checkpoint.c to generic and 32bit specific parts
  - sys_{checkpoint,restore} to use ptregs
  - Allow X86_EFLAGS_RF on restart
  - [Serge Hallyn] Only allow 'restart' with same bit-ness as image.
  - Move checkpoint.c from arch/x86/mm->arch/x86/kernel 
 ARCH: s390 [Serge Hallyn]
  - Define s390x sys_restart wrapper
  - Fixes to restart-blocks logic and signal path
  - Fix checkpoint and restart compat wrappers
  - sys_{checkpoint,restore} to use ptregs
  - Use simpler test_task_thread to test current ti flags
  - Fix 31-bit s390 checkpoint/restart wrappers
  - Update sys_checkpoint (do_sys_checkpoint on all archs)
  - [Oren Laadan] Move checkpoint.c from arch/s390/mm->arch/s390/kernel 
 ARCH: powerpc [Nathan Lynch]
  - [Serge Hallyn] Add hook task_has_saved_sigmask()
  - Warn if full register state unavailable
  - Fix up checkpoint syscall, tidy restart
  - [Oren Laadan] Move checkpoint.c from arch/powerpc/{mm->kernel} 

[2009-Sep-22] v18
 NEW FEATURES
  - [Nathan Lynch] Re-introduce powerpc support
  - Save/restore pseudo-terminals
  - Save/restore (pty) controlling terminals
  - Save/restore restore PGIDs
  - [Dan Smith] Save/restore unix domain sockets
  - Save/restore FIFOs
  - Save/restore pending signals
  - Save/restore rlimits
  - Save/restore itimers
  - [Matt Helsley] Handle many non-pseudo file-systems
 OTHER CHANGES
  - Rename headerless struct ckpt_hdr_* to struct ckpt_*
  - [Nathan Lynch] discard const from struct cred * where appropriate
  - [Serge Hallyn][s390] Set return value for self-checkpoint 
  - Handle kmalloc failure in restore_sem_array()
  - [IPC] Collect files used by shm objects
  - [IPC] Use file (not inode) as shared object on checkpoint of shm
  - More ckpt_write_err()s to give information on checkpoint failure
  - Adjust format of pipe buffer to include the mandatory pre-header
  - [LEAKS] Mark the backing file as visited at chekcpoint
  - Tighten checks on supported vma to checkpoint or restart
  - [Serge Hallyn] Export filemap_checkpoint() (used for ext4)
  - Introduce ckpt_collect_file() that also uses file->collect method
  - Use ckpt_collect_file() instead of ckpt_obj_collect() for files
  - Fix leak-detection issue in collect_mm() (test for first-time obj)
  - Invoke set_close_on_exec() unconditionally on restart
  - [Dan Smith] Export fill_fname() as ckpt_fill_fname()
  - Interface to pass simple pointers as data with deferqueue
  - [Dan Smith] Fix ckpt_obj_lookup_add() leak detection logic
  - Replace EAGAIN with EBUSY where necessary
  - Introduce CKPT_OBJ_VISITED in leak detection
  - ckpt_obj_collect() returns objref for new objects, 0 otherwise
  - Rename ckpt_obj_checkpointed() to ckpt_obj_visited()
  - Introduce ckpt_obj_visit() to mark objects as visited
  - Set the CHECKPOINTED flag on objects before calling checkpoint
  - Introduce ckpt_obj_reserve()
  - Change ref_drop() to accept a @lastref argument (for cleanup)
  - Disallow multiple objects with same objref in restart
  - Allow _ckpt_read_obj_type() to read header only (w/o payload)
  - Fix leak of ckpt_ctx when restoring zombie tasks
  - Fix race of prepare_descendant() with an ongoing fork()
  - Track and report the first error if restart fails
  - Tighten logic to protect against bogus pids in input
  - [Matt Helsley] Improve debug output from ckpt_notify_error()
  - [Nathan Lynch] fix compilation errors with CONFIG_COMPAT=y
  - Detect error-headers in input data on restart, and abort.
  - Standard format for checkpoint error strings (and documentation)
  - [Dan Smith] Add an errno validation function
  - Add ckpt_read_payload(): read a variable-length object (no header)
  - Add ckpt_read_string(): same for strings (ensures null-terminated)
  - Add ckpt_read_consume(): consumes next object without processing
  - [John Dykstra] Fix no-dot-config-targets pattern in linux/Makefile

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
