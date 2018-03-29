Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E39E66B0003
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:26:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k6so2495386wmi.6
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:26:03 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id w5si1173304wma.212.2018.03.29.04.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 04:26:01 -0700 (PDT)
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 000/109] remove in-kernel calls to syscalls
Date: Thu, 29 Mar 2018 13:22:37 +0200
Message-Id: <20180329112426.23043-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, hmclauchlan@fb.com, tautschn@amazon.co.uk, Amir Goldstein <amir73il@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Darren Hart <dvhart@infradead.org>, "David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>, "H . Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Jaswinder Singh <jaswinder@infradead.org>, Jeff Dike <jdike@addtoit.com>, Jiri Slaby <jslaby@suse.com>, kexec@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, "Luis R . Rodriguez" <mcgrof@kernel.org>, netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, user-mode-linux-devel@lists.sourceforge.net, x86@kernel.org

[ While most parts of this patch set have been sent out already at least
  once, I send out *all* patches to lkml once again as this whole series
  touches several different subsystems in sensitive areas. ]

System calls are interaction points between userspace and the kernel.
Therefore, system call functions such as sys_xyzzy() or compat_sys_xyzzy()
should only be called from userspace via the syscall table, but not from
elsewhere in the kernel.

At least on 64-bit x86, it will likely be a hard requirement from v4.17
onwards to not call system call functions in the kernel: It is better to
use use a different calling convention for system calls there, where 
struct pt_regs is decoded on-the-fly in a syscall wrapper which then hands
processing over to the actual syscall function. This means that only those
parameters which are actually needed for a specific syscall are passed on
during syscall entry, instead of filling in six CPU registers with random
user space content all the time (which may cause serious trouble down the
call chain).[*]

Moreover, rules on how data may be accessed may differ between kernel data
and user data.  This is another reason why calling sys_xyzzy() is
generally a bad idea, and -- at most -- acceptable in arch-specific code.


This patchset removes all in-kernel calls to syscall functions in the
kernel with the exception of arch/. On top of this, it cleans up the
three places where many syscalls are referenced or prototyped, namely
kernel/sys_ni.c, include/linux/syscalls.h and include/linux/compat.h.
Patches 1 to 101 have been sent out earlier, namely
	- part 1 ( http://lkml.kernel.org/r/20180315190529.20943-1-linux@dominikbrodowski.net )
	- part 2 ( http://lkml.kernel.org/r/20180316170614.5392-1-linux@dominikbrodowski.net )
	- part 3 ( http://lkml.kernel.org/r/20180322090059.19361-1-linux@dominikbrodowski.net ).

Changes since these earlier versions are:

- I have added a lot more documentation and improved the commit messages,
  namely to explain the naming convention and the rationale of this
  patches.

- ACKs/Reviewed-by (thanks!) were added .

- Shuffle the patches around to have them grouped together systematically:

First goes a patch which defines the goal and explains the rationale:

  syscalls: define and explain goal to not call syscalls in the kernel

A few codepaths can trivially be converted to existing in-kernel interfaces:

  kernel: use kernel_wait4() instead of sys_wait4()
  kernel: open-code sys_rt_sigpending() in sys_sigpending()
  kexec: call do_kexec_load() in compat syscall directly
  mm: use do_futex() instead of sys_futex() in mm_release()
  x86: use _do_fork() in compat_sys_x86_clone()
  x86: remove compat_sys_x86_waitpid()

Then follow many patches which only affect specfic subsystems each, and
replace sys_*() with internal helpers named __sys_*() or do_sys_*(). Let's
start with net/:

  net: socket: add __sys_recvfrom() helper; remove in-kernel call to syscall
  net: socket: add __sys_sendto() helper; remove in-kernel call to syscall
  net: socket: add __sys_accept4() helper; remove in-kernel call to syscall
  net: socket: add __sys_socket() helper; remove in-kernel call to syscall
  net: socket: add __sys_bind() helper; remove in-kernel call to syscall
  net: socket: add __sys_connect() helper; remove in-kernel call to syscall
  net: socket: add __sys_listen() helper; remove in-kernel call to syscall
  net: socket: add __sys_getsockname() helper; remove in-kernel call to syscall
  net: socket: add __sys_getpeername() helper; remove in-kernel call to syscall
  net: socket: add __sys_socketpair() helper; remove in-kernel call to syscall
  net: socket: add __sys_shutdown() helper; remove in-kernel call to syscall
  net: socket: add __sys_setsockopt() helper; remove in-kernel call to syscall
  net: socket: add __sys_getsockopt() helper; remove in-kernel call to syscall
  net: socket: add do_sys_recvmmsg() helper; remove in-kernel call to syscall
  net: socket: move check for forbid_cmsg_compat to __sys_...msg()
  net: socket: replace calls to sys_send() with __sys_sendto()
  net: socket: replace call to sys_recv() with __sys_recvfrom()
  net: socket: add __compat_sys_recvfrom() helper; remove in-kernel call to compat syscall
  net: socket: add __compat_sys_setsockopt() helper; remove in-kernel call to compat syscall
  net: socket: add __compat_sys_getsockopt() helper; remove in-kernel call to compat syscall
  net: socket: add __compat_sys_recvmmsg() helper; remove in-kernel call to compat syscall
  net: socket: add __compat_sys_...msg() helpers; remove in-kernel calls to compat syscalls

The changes in ipc/ are limited to this specific subsystem. The wrappers are
named ksys_*() to denote that these functions are meant as a drop-in replacement
for the syscalls.

  ipc: add semtimedop syscall/compat_syscall wrappers
  ipc: add semget syscall wrapper
  ipc: add semctl syscall/compat_syscall wrappers
  ipc: add msgget syscall wrapper
  ipc: add shmget syscall wrapper
  ipc: add shmdt syscall wrapper
  ipc: add shmctl syscall/compat_syscall wrappers
  ipc: add msgctl syscall/compat_syscall wrappers
  ipc: add msgrcv syscall/compat_syscall wrappers
  ipc: add msgsnd syscall/compat_syscall wrappers

A few mindless conversions in kernel/ and mm/:

  kernel: add do_getpgid() helper; remove internal call to sys_getpgid()
  kernel: add do_compat_sigaltstack() helper; remove in-kernel call to compat syscall
  kernel: provide ksys_*() wrappers for syscalls called by kernel/uid16.c
  sched: add do_sched_yield() helper; remove in-kernel call to sched_yield()
  mm: add kernel_migrate_pages() helper, move compat syscall to mm/mempolicy.c
  mm: add kernel_move_pages() helper, move compat syscall to mm/migrate.c
  mm: add kernel_mbind() helper; remove in-kernel call to syscall
  mm: add kernel_[sg]et_mempolicy() helpers; remove in-kernel calls to syscalls

Then, let's handle those instances internal to fs/ which call syscalls:

  fs: add do_readlinkat() helper; remove internal call to sys_readlinkat()
  fs: add do_pipe2() helper; remove internal call to sys_pipe2()
  fs: add do_renameat2() helper; remove internal call to sys_renameat2()
  fs: add do_futimesat() helper; remove internal call to sys_futimesat()
  fs: add do_epoll_*() helpers; remove internal calls to sys_epoll_*()
  fs: add do_signalfd4() helper; remove internal calls to sys_signalfd4()
  fs: add do_eventfd() helper; remove internal call to sys_eventfd()
  fs: add do_lookup_dcookie() helper; remove in-kernel call to syscall
  fs: add do_vmsplice() helper; remove in-kernel call to syscall
  fs: add kern_select() helper; remove in-kernel call to sys_select()
  fs: add do_compat_fcntl64() helper; remove in-kernel call to compat syscall
  fs: add do_compat_select() helper; remove in-kernel call to compat syscall
  fs: add do_compat_signalfd4() helper; remove in-kernel call to compat syscall
  fs: add do_compat_futimesat() helper; remove in-kernel call to compat syscall
  inotify: add do_inotify_init() helper; remove in-kernel call to syscall
  fanotify: add do_fanotify_mark() helper; remove in-kernel call to syscall
  fs/quota: add kernel_quotactl() helper; remove in-kernel call to syscall
  fs/quota: use COMPAT_SYSCALL_DEFINE for sys32_quotactl()

Several fs- and some mm-related syscalls are called in initramfs, initrd and
init, devtmpfs, and pm code. While at least many of these instances should be
converted to use proper in-kernel VFS interfaces in future, convert them
mindlessly to ksys_*() helpers or wrappers for now.

  fs: add ksys_mount() helper; remove in-kernel calls to sys_mount()
  fs: add ksys_umount() helper; remove in-kernel call to sys_umount()
  fs: add ksys_dup{,3}() helper; remove in-kernel calls to sys_dup{,3}()
  fs: add ksys_chroot() helper; remove-in kernel calls to sys_chroot()
  fs: add ksys_write() helper; remove in-kernel calls to sys_write()
  fs: add ksys_chdir() helper; remove in-kernel calls to sys_chdir()
  fs: add ksys_unlink() wrapper; remove in-kernel calls to sys_unlink()
  hostfs: rename do_rmdir() to hostfs_do_rmdir()
  fs: add ksys_rmdir() wrapper; remove in-kernel calls to sys_rmdir()
  fs: add do_mkdirat() helper and ksys_mkdir() wrapper; remove in-kernel calls to syscall
  fs: add do_symlinkat() helper and ksys_symlink() wrapper; remove in-kernel calls to syscall
  fs: add do_mknodat() helper and ksys_mknod() wrapper; remove in-kernel calls to syscall
  fs: add do_linkat() helper and ksys_link() wrapper; remove in-kernel calls to syscall
  fs: add ksys_fchmod() and do_fchmodat() helpers and ksys_chmod() wrapper; remove in-kernel calls to syscall
  fs: add do_faccessat() helper and ksys_access() wrapper; remove in-kernel calls to syscall
  fs: add do_fchownat(), ksys_fchown() helpers and ksys_{,l}chown() wrappers
  fs: add ksys_ftruncate() wrapper; remove in-kernel calls to sys_ftruncate()
  fs: add ksys_close() wrapper; remove in-kernel calls to sys_close()
  fs: add ksys_open() wrapper; remove in-kernel calls to sys_open()
  fs: add ksys_getdents64() helper; remove in-kernel calls to sys_getdents64()
  fs: add ksys_ioctl() helper; remove in-kernel calls to sys_ioctl()
  fs: add ksys_lseek() helper; remove in-kernel calls to sys_lseek()
  fs: add ksys_read() helper; remove in-kernel calls to sys_read()
  fs: add ksys_sync() helper; remove in-kernel calls to sys_sync()
  kernel: add ksys_unshare() helper; remove in-kernel calls to sys_unshare()
  kernel: add ksys_setsid() helper; remove in-kernel call to sys_setsid()

To reach the goal to get rid of all in-kernel calls to syscalls for x86, we
need to handle a few further syscalls called from compat syscalls in x86 and
(mostly) from other architectures. Those could be made generic making use of
Al Viro's macro trickery. For v4.17, I'd suggest to keep it simple:

  fs: add ksys_sync_file_range helper(); remove in-kernel calls to syscall
  fs: add ksys_truncate() wrapper; remove in-kernel calls to sys_truncate()
  fs: add ksys_p{read,write}64() helpers; remove in-kernel calls to syscalls
  fs: add ksys_fallocate() wrapper; remove in-kernel calls to sys_fallocate()
  mm: add ksys_fadvise64_64() helper; remove in-kernel call to sys_fadvise64_64()
  mm: add ksys_mmap_pgoff() helper; remove in-kernel calls to sys_mmap_pgoff()
  mm: add ksys_readahead() helper; remove in-kernel calls to sys_readahead()
  x86/ioport: add ksys_ioperm() helper; remove in-kernel calls to sys_ioperm()

Then, throw in two fixes for x86:

  x86: fix sys_sigreturn() return type to be long, not unsigned long
  x86/sigreturn: use SYSCALL_DEFINE0 (by Michael Tautschnig)

... and clean up the three places where many syscalls are referenced or
prototyped (kernel/sys_ni.c, include/linux/syscalls.h and
include/linux/compat.h):

  kexec: move sys_kexec_load() prototype to syscalls.h
  syscalls: sort syscall prototypes in include/linux/syscalls.h
  net: remove compat_sys_*() prototypes from net/compat.h
  syscalls: sort syscall prototypes in include/linux/compat.h
  syscalls/x86: auto-create compat_sys_*() prototypes
  kernel/sys_ni: sort cond_syscall() entries
  kernel/sys_ni: remove {sys_,sys_compat} from cond_syscall definitions

Last but not least, add a patch by Howard McLauchlan to whitelist all syscalls
for error injection:

  bpf: whitelist all syscalls for error injection (by Howard McLauchlan)

Tze whole series is available at

	https://git.kernel.org/pub/scm/linux/kernel/git/brodo/linux.git syscalls-next

and I intend to push this upstream early in the v4.17-rc1 cycle.

Thanks,
	Dominik


 Documentation/process/adding-syscalls.rst |   34 +-
 arch/alpha/kernel/osf_sys.c               |    2 +-
 arch/arm/kernel/sys_arm.c                 |    2 +-
 arch/arm64/kernel/sys.c                   |    2 +-
 arch/ia64/kernel/sys_ia64.c               |    4 +-
 arch/m68k/kernel/sys_m68k.c               |    2 +-
 arch/microblaze/kernel/sys_microblaze.c   |    6 +-
 arch/mips/kernel/linux32.c                |   22 +-
 arch/mips/kernel/syscall.c                |    6 +-
 arch/parisc/kernel/sys_parisc.c           |   30 +-
 arch/powerpc/kernel/sys_ppc32.c           |   18 +-
 arch/powerpc/kernel/syscalls.c            |    6 +-
 arch/riscv/kernel/sys_riscv.c             |    4 +-
 arch/s390/kernel/compat_linux.c           |   37 +-
 arch/s390/kernel/sys_s390.c               |    2 +-
 arch/sh/kernel/sys_sh.c                   |    4 +-
 arch/sh/kernel/sys_sh32.c                 |   12 +-
 arch/sparc/kernel/setup_32.c              |    2 +-
 arch/sparc/kernel/sys_sparc32.c           |   26 +-
 arch/sparc/kernel/sys_sparc_32.c          |    6 +-
 arch/sparc/kernel/sys_sparc_64.c          |    2 +-
 arch/um/kernel/syscall.c                  |    2 +-
 arch/x86/entry/syscalls/syscall_32.tbl    |    4 +-
 arch/x86/ia32/ia32_signal.c               |    1 -
 arch/x86/ia32/sys_ia32.c                  |   50 +-
 arch/x86/include/asm/sys_ia32.h           |   67 --
 arch/x86/include/asm/syscalls.h           |    3 +-
 arch/x86/kernel/ioport.c                  |    7 +-
 arch/x86/kernel/signal.c                  |    5 +-
 arch/x86/kernel/sys_x86_64.c              |    2 +-
 arch/xtensa/kernel/syscall.c              |    2 +-
 drivers/base/devtmpfs.c                   |   11 +-
 drivers/tty/sysrq.c                       |    2 +-
 drivers/tty/vt/vt_ioctl.c                 |    6 +-
 fs/autofs4/dev-ioctl.c                    |    2 +-
 fs/binfmt_misc.c                          |    2 +-
 fs/dcookies.c                             |   11 +-
 fs/eventfd.c                              |    9 +-
 fs/eventpoll.c                            |   23 +-
 fs/fcntl.c                                |   12 +-
 fs/file.c                                 |   17 +-
 fs/hostfs/hostfs.h                        |    2 +-
 fs/hostfs/hostfs_kern.c                   |    2 +-
 fs/hostfs/hostfs_user.c                   |    2 +-
 fs/internal.h                             |   14 +
 fs/ioctl.c                                |    7 +-
 fs/namei.c                                |   61 +-
 fs/namespace.c                            |   19 +-
 fs/notify/fanotify/fanotify_user.c        |   14 +-
 fs/notify/inotify/inotify_user.c          |    9 +-
 fs/open.c                                 |   77 +-
 fs/pipe.c                                 |    9 +-
 fs/quota/compat.c                         |   13 +-
 fs/quota/quota.c                          |   10 +-
 fs/read_write.c                           |   45 +-
 fs/readdir.c                              |   11 +-
 fs/select.c                               |   29 +-
 fs/signalfd.c                             |   31 +-
 fs/splice.c                               |   12 +-
 fs/stat.c                                 |   12 +-
 fs/sync.c                                 |   19 +-
 fs/utimes.c                               |   25 +-
 include/linux/compat.h                    |  644 ++++++------
 include/linux/futex.h                     |   13 +-
 include/linux/kexec.h                     |    4 -
 include/linux/quotaops.h                  |    3 +
 include/linux/socket.h                    |   37 +-
 include/linux/syscalls.h                  | 1511 +++++++++++++++++------------
 include/net/compat.h                      |   11 -
 init/do_mounts.c                          |   26 +-
 init/do_mounts.h                          |    4 +-
 init/do_mounts_initrd.c                   |   42 +-
 init/do_mounts_md.c                       |   29 +-
 init/do_mounts_rd.c                       |   40 +-
 init/initramfs.c                          |   52 +-
 init/main.c                               |    9 +-
 init/noinitramfs.c                        |    6 +-
 ipc/msg.c                                 |   60 +-
 ipc/sem.c                                 |   44 +-
 ipc/shm.c                                 |   28 +-
 ipc/syscall.c                             |   58 +-
 ipc/util.h                                |   31 +
 kernel/compat.c                           |   55 --
 kernel/exit.c                             |    2 +-
 kernel/fork.c                             |   11 +-
 kernel/kexec.c                            |   52 +-
 kernel/pid_namespace.c                    |    6 +-
 kernel/power/hibernate.c                  |    2 +-
 kernel/power/suspend.c                    |    2 +-
 kernel/power/user.c                       |    2 +-
 kernel/sched/core.c                       |    8 +-
 kernel/signal.c                           |   29 +-
 kernel/sys.c                              |   74 +-
 kernel/sys_ni.c                           |  617 +++++++-----
 kernel/uid16.c                            |   25 +-
 kernel/uid16.h                            |   14 +
 kernel/umh.c                              |    4 +-
 mm/fadvise.c                              |   10 +-
 mm/mempolicy.c                            |   92 +-
 mm/migrate.c                              |   39 +-
 mm/mmap.c                                 |   17 +-
 mm/nommu.c                                |   17 +-
 mm/readahead.c                            |    7 +-
 net/compat.c                              |  136 ++-
 net/socket.c                              |  234 +++--
 105 files changed, 3129 insertions(+), 1868 deletions(-)
 delete mode 100644 arch/x86/include/asm/sys_ia32.h
 create mode 100644 kernel/uid16.h

[*] An early, not-yet-ready version and partly untested (i386, x32) of the
patches required to implement this on top of this series is available at
https://git.kernel.org/pub/scm/linux/kernel/git/brodo/linux.git syscalls-WIP

-- 
2.16.3
