Received: from inet-mail4.oracle.com (localhost [127.0.0.1])
	by inet-mail4.oracle.com (Switch-3.1.0/Switch-3.1.0) with ESMTP id h5IDE5l1004841
	for <linux-mm@kvack.org>; Wed, 18 Jun 2003 06:14:06 -0700 (PDT)
Received: from rgmgw5.us.oracle.com (rgmgw5.us.oracle.com [138.1.191.14])
	by inet-mail4.oracle.com (Switch-3.1.0/Switch-3.1.0) with ESMTP id h5IDE5l1004818
	for <linux-mm@kvack.org>; Wed, 18 Jun 2003 06:14:05 -0700 (PDT)
Received: from rgmgw5.us.oracle.com (localhost [127.0.0.1])
	by rgmgw5.us.oracle.com (Switch-2.1.5/Switch-2.1.0) with ESMTP id h5IDE4T07715
	for <linux-mm@kvack.org>; Wed, 18 Jun 2003 07:14:04 -0600 (MDT)
Subject: 2.5.72-mm1 - Under heavy testing with AIO,.. vmstat seems to blow
	the kernel
From: Philip Copeland <philip.copeland@oracle.com>
Content-Type: text/plain
Message-Id: <1055942007.20100.45.camel@emerald>
Mime-Version: 1.0
Date: 18 Jun 2003 14:13:55 +0100
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: suparna@in.ibm.com
List-ID: <linux-mm.kvack.org>

Admittedly this isn't the trace I was hoping to obtain however,..
(actually on reflection having written this note this particular failing
looks like a problem between vmstat, mm and the /proc fs.)

I'm having an issue with 2.5.7X and all of the related -mmX series
They all follow this fairly typical pattern
(note: I have the test box hooked up for kgdb so what follows is mostly
gdb output),...

Linux version 2.5.72-mm1 (root@emerald) (gcc version 3.2.2 20030222 (Red
Hat Linux 3.2.2-5)) #1 SMP Tue Jun 17 12:48:34 BST 2003

Program received signal SIGEMT, Emulation trap.
0xc01235ed in mmput (mm=0xe6356a5c) at list.h:148
148             BUG_ON(entry->prev->next != entry);
(gdb)

(gdb) info registers
eax            0x1      1
ecx            0xe6356a98       -432706920
edx            0x200200 2097664
ebx            0xe6356a5c       -432706980
esp            0xedc45e18       0xedc45e18
ebp            0xedc45e24       0xedc45e24
esi            0xe6356a5c       -432706980
edi            0xe6356a5c       -432706980
eip            0xc01235ed       0xc01235ed
eflags         0x10202  66050
cs             0x60     96
ss             0x68     104
ds             0xe4f8007b       -453508997
es             0x7b     123
fs             0xffff   65535
gs             0xffff   65535

(gdb) list
143      * in an undefined state.
144      */
145     #include <linux/kernel.h>       /* BUG_ON */
146     static inline void list_del(struct list_head *entry)
147     {
148             BUG_ON(entry->prev->next != entry);
149             BUG_ON(entry->next->prev != entry);
150             __list_del(entry->prev, entry->next);
151             entry->next = LIST_POISON1;
152             entry->prev = LIST_POISON2;

(gdb) info locals
No locals.

(gdb) where
#0  0xc01235ed in mmput (mm=0xe6356a5c) at list.h:148
#1  0xc01a2076 in proc_pid_stat (task=0xe6356a5c, 
    buffer=0x1 <Address 0x1 out of bounds>) at fs/proc/array.c:387
#2  0xc019e6ae in proc_info_read (file=0x1, 
    buf=0x804a220 "8 (kswapd0) S 1 1 1 0 -1 264256 0 0 0 0 0 0 0 0 25 0
0 0 324 0 0 4294967295 0 0 0 0 0 0 2147483647 0 0 3222609788 0 0 17 0 0
0\n0 0 0\n 0 0\n4294960144 0 0 1475401980 671819267 3222467115 0 0 0 0 0
0\nact"..., 
    count=3072, ppos=0xec27e1cc) at proc_fs.h:253
#3  0xc0165c20 in vfs_read (file=0xe6356a5c, 
    buf=0x804a220 "8 (kswapd0) S 1 1 1 0 -1 264256 0 0 0 0 0 0 0 0 25 0
0 0 324 0 0 4294967295 0 0 0 0 0 0 2147483647 0 0 3222609788 0 0 17 0 0
0\n0 0 0\n 0 0\n4294960144 0 0 1475401980 671819267 3222467115 0 0 0 0 0
0\nact"..., 
    count=8191, pos=0xe6356a5c) at fs/read_write.c:201
#4  0xc0165ed6 in sys_read (fd=1, buf=0x1 <Address 0x1 out of bounds>,
count=1)
    at fs/read_write.c:260

So I should be able to see the value of mm...

(gdb) print *mm
$1 = {mmap = 0xe61ec578, mm_rb = {rb_node = 0xe61ec11c}, 
  mmap_cache = 0xe61ecd7c, free_area_cache = 1073872896, pgd =
0xe61c3000, 
  mm_users = {counter = 0}, mm_count = {counter = 3}, map_count = 31, 
  mmap_sem = {count = 0, wait_lock = {lock = 1, magic = 3735899821}, 
    wait_list = {next = 0xe6356a88, prev = 0xe6356a88}}, page_table_lock
= {
    lock = 1, magic = 3735899821}, mmlist = {next = 0x100100, 
    prev = 0x200200}, start_code = 134512640, end_code = 134725512, 
  start_data = 134729632, end_data = 134731456, start_brk = 134754304, 
  brk = 134844416, start_stack = 3221223888, arg_start = 3221224208, 
  arg_end = 3221224233, env_start = 3221224233, env_end = 3221225453, 
  rss = 587, total_vm = 1070, locked_vm = 0, def_flags = 0, cpu_vm_mask
= 0, 
  swap_address = 0, dumpable = 1, used_hugetlb = 0, context = {size = 0,
    sem = {count = {counter = 1}, sleepers = 0, wait = {lock = {lock =
1, 
          magic = 3735899821}, task_list = {next = 0xe6356b00, 
          prev = 0xe6356b00}}}, ldt = 0x0}, core_waiters = 0, 
  core_startup_done = 0x0, core_done = {done = 0, wait = {lock = {lock =
0, 
        magic = 0}, task_list = {next = 0x0, prev = 0x0}}},
ioctx_list_lock = {
    lock = 16777216, magic = 3736018669}, ioctx_list = 0x0,
default_kioctx = {
    users = {counter = 1}, dead = 0, mm = 0xe6356a5c, user_id = 0, next
= 0x0, 
    wait = {lock = {lock = 1, magic = 3735899821}, task_list = {
        next = 0xe6356b50, prev = 0xe6356b50}}, ctx_lock = {lock = 1, 
      magic = 3735899821}, reqs_active = 0, active_reqs = {next = 0x0, 
      prev = 0x0}, run_list = {next = 0x0, prev = 0x0}, max_reqs =
4294967295, 
    ring_info = {mmap_base = 0, mmap_size = 0, ring_pages = 0x0,
ring_lock = {
        lock = 0, magic = 0}, nr_pages = 0, nr = 0, tail = 0, 
      internal_pages = {0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}}, wq = {
      pending = 0, entry = {next = 0x0, prev = 0x0}, func = 0, data =
0x0, 
      wq_data = 0x0, timer = {entry = {next = 0x0, prev = 0x0}, expires
= 0, 
        lock = {lock = 0, magic = 0}, magic = 0, function = 0, data = 0,
        base = 0x0}}}}

ok not too meaningful,...
lets go up a frame

=====================================================================

(gdb) up
#1  0xc01a2076 in proc_pid_stat (task=0xe6356a5c, 
    buffer=0x1 <Address 0x1 out of bounds>) at fs/proc/array.c:387
387                     mmput(mm);

(gdb) list
382                     task->exit_signal,
383                     task_cpu(task),
384                     task->rt_priority,
385                     task->policy);
386             if(mm)
387                     mmput(mm);
388             return res;
389     }
390
391     extern int task_statm(struct mm_struct *, int *, int *, int *,
int *);

mm contents are as previously displayed,..

(gdb) info locals
vsize = 4382720
eip = 0
esp = 0
wchan = 3222307163
priority = 5
nice = -10
tty_pgrp = -1
tty_nr = 0
sigign = {sig = {65536, 0}}
sigcatch = {sig = {0, 0}}
state = 68 'D'
res = -432706980
ppid = 1
mm = (struct mm_struct *) 0xe6356a5c

=====================================================================

(gdb) up
#2  0xc019e6ae in proc_info_read (file=0x1, 
    buf=0x804a220 "8 (kswapd0) S 1 1 1 0 -1 264256 0 0 0 0 0 0 0 0 25 0
0 0 324 0 0 4294967295 0 0 0 0 0 0 2147483647 0 0 3222609788 0 0 17 0 0
0\n0 0 0\n 0 0\n4294960144 0 0 1475401980 671819267 3222467115 0 0 0 0 0
0\nact"..., 
    count=3072, ppos=0xec27e1cc) at proc_fs.h:253
253     {

(gdb) list
248             struct proc_dir_entry *pde;
249             struct inode vfs_inode;
250     };
251
252     static inline struct proc_inode *PROC_I(const struct inode
*inode)
253     {
254             return container_of(inode, struct proc_inode,
vfs_inode);
255     }
256
257     static inline struct proc_dir_entry *PDE(const struct inode
*inode)

nothing of intrest,.. up again..

=====================================================================

(gdb) up
#3  0xc0165c20 in vfs_read (file=0xe6356a5c, 
    buf=0x804a220 "8 (kswapd0) S 1 1 1 0 -1 264256 0 0 0 0 0 0 0 0 25 0
0 0 324 0 0 4294967295 0 0 0 0 0 0 2147483647 0 0 3222609788 0 0 17 0 0
0\n0 0 0\n 0 0\n4294960144 0 0 1475401980 671819267 3222467115 0 0 0 0 0
0\nact"..., 
    count=8191, pos=0xe6356a5c) at fs/read_write.c:201
201                                     ret = file->f_op->read(file,
buf, count, pos);

(gdb) list
196             ret = locks_verify_area(FLOCK_VERIFY_READ, inode, file,
*pos, count);
197             if (!ret) {
198                     ret = security_file_permission (file, MAY_READ);
199                     if (!ret) {
200                             if (file->f_op->read)
201                                     ret = file->f_op->read(file,
buf, count, pos);
202                             else
203                                     ret = do_sync_read(file, buf,
count, pos);
204                             if (ret > 0)
205                                     dnotify_parent(file->f_dentry,
DN_ACCESS);

(gdb) info locals
inode = (struct inode *) 0xe6356a98
ret = -432706980

(gdb) print *file
$5 = {f_list = {next = 0xe61ec578, prev = 0xe61ec11c}, f_dentry =
0xe61ecd7c, 
  f_vfsmnt = 0x40020000, f_op = 0xe61c3000, f_count = {counter = 0}, 
  f_flags = 3, f_mode = 31, f_pos = 4294967296, f_owner = {lock = {
      lock = 3735899821, magic = 3862260360}, pid = -432706936, uid = 1,
    euid = 3735899821, signum = 1048832, security = 0x200200}, 
  f_uid = 134512640, f_gid = 134725512, f_error = 134729632, f_ra = {
    start = 134731456, size = 134754304, next_size = 134844416, 
    prev_page = 3221223888, ahead_start = 3221224208, ahead_size =
3221224233, 
    ra_pages = 3221224233}, f_version = 3221225453, f_security = 0x24b, 
  private_data = 0x42e, f_ep_links = {next = 0x0, prev = 0x0}, f_ep_lock
= {
    lock = 0, magic = 0}}

and up again

=====================================================================

(gdb) up
#4  0xc0165ed6 in sys_read (fd=1, buf=0x1 <Address 0x1 out of bounds>,
count=1)
    at fs/read_write.c:260
260                     ret = vfs_read(file, buf, count, &file->f_pos);

(gdb) list
255             ssize_t ret = -EBADF;
256             int fput_needed;
257
258             file = fget_light(fd, &fput_needed);
259             if (file) {
260                     ret = vfs_read(file, buf, count, &file->f_pos);
261                     fput_light(file, fput_needed);
262             }
263
264             return ret;

(gdb) info locals
file = (struct file *) 0xe6356a5c
ret = -432706980
fput_needed = 0

Fine,.. we  we were bailing out on a BUG_ON() so lets call dump_stack()

(gdb) call dump_stack()
Call Trace:
 [<c01a2076>] proc_pid_stat+0x4c8/0x585
 [<c010815b>] __down+0xd6/0x219
 [<c010815b>] __down+0xd6/0x219
 [<c019e6ae>] proc_info_read+0x66/0x147
 [<c0165c20>] vfs_read+0xaf/0x119
 [<c0165ed6>] sys_read+0x3f/0x5d
 [<c010986e>] sysenter_past_esp+0x5f/0x7d

humm is it normal to see a double __down()?

Phil
=--=

Long and possibly ignorable thread dump follows

(gdb) info thr
  526 Thread 32768  0xc01200b7 in schedule () at kernel/sched.c:659
  525 Thread 7302  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  524 Thread 7301  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  523 Thread 7300  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  522 Thread 7299  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  521 Thread 7298  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  520 Thread 7297  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  519 Thread 7296  __down (sem=0xc0378d00) at
arch/i386/kernel/semaphore.c:84
  518 Thread 7295  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  517 Thread 7294  __down (sem=0x0) at arch/i386/kernel/semaphore.c:84
  516 Thread 7293  io_schedule () at atomic.h:122
  515 Thread 7292  __down (sem=0x0) at arch/i386/kernel/semaphore.c:84
  514 Thread 7291  0xc01bc2e6 in do_get_write_access (handle=0xf225d1d4,
    jh=0xe952a6ac, force_copy=0, credits=0x0) at
fs/jbd/transaction.c:638
  513 Thread 7290  pipe_wait (inode=0xc03e2800) at fs/pipe.c:42
  512 Thread 7289  0xc01bc2e6 in do_get_write_access (handle=0xf225d2ec,
    jh=0xf708e1c0, force_copy=0, credits=0x0) at
fs/jbd/transaction.c:638
  511 Thread 7288  pipe_wait (inode=0xc03e2800) at fs/pipe.c:42
  510 Thread 7287  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  509 Thread 7286  __down (sem=0xf6bd5b7c) at
arch/i386/kernel/semaphore.c:84
  508 Thread 7285  __down (sem=0xe57d5dfc) at
arch/i386/kernel/semaphore.c:84
  507 Thread 7284  0xc01200b7 in schedule () at kernel/sched.c:659
  506 Thread 7282  0xc01200b7 in schedule () at kernel/sched.c:659
  505 Thread 7281  __down (sem=0x2) at arch/i386/kernel/semaphore.c:84
  504 Thread 7136  __down (sem=0xc17eab80) at
arch/i386/kernel/semaphore.c:84
  503 Thread 7133  wait_for_all_aios (ctx=0xf764a6b0) at system.h:212
  502 Thread 7130  pipe_wait (inode=0xe6351310) at fs/pipe.c:42
  501 Thread 7129  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  500 Thread 7127  pipe_wait (inode=0xe67de080) at fs/pipe.c:42
  499 Thread 7126  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  498 Thread 7124  pipe_wait (inode=0xe67dece0) at fs/pipe.c:42
  497 Thread 7123  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  496 Thread 7121  pipe_wait (inode=0xe67df940) at fs/pipe.c:42
  495 Thread 7120  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  494 Thread 7118  pipe_wait (inode=0xe6b1c6b0) at fs/pipe.c:42
  493 Thread 7117  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  492 Thread 7115  pipe_wait (inode=0xe6b1d310) at fs/pipe.c:42
  491 Thread 7114  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  490 Thread 7112  pipe_wait (inode=0xe6e58080) at fs/pipe.c:42
  489 Thread 7111  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  488 Thread 7109  pipe_wait (inode=0xe6e58ce0) at fs/pipe.c:42
  487 Thread 7108  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  486 Thread 7106  pipe_wait (inode=0xe6e59940) at fs/pipe.c:42
  485 Thread 7105  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  484 Thread 7103  pipe_wait (inode=0xe73166b0) at fs/pipe.c:42
  483 Thread 7102  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  482 Thread 7100  pipe_wait (inode=0xe7317310) at fs/pipe.c:42
  481 Thread 7099  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  480 Thread 7097  pipe_wait (inode=0xe7654080) at fs/pipe.c:42
  479 Thread 7096  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  478 Thread 7094  pipe_wait (inode=0xe7654ce0) at fs/pipe.c:42
  477 Thread 7093  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  476 Thread 7091  pipe_wait (inode=0xe7655940) at fs/pipe.c:42
  475 Thread 7090  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  474 Thread 7088  pipe_wait (inode=0xe7ae06b0) at fs/pipe.c:42
  473 Thread 7087  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  472 Thread 7085  pipe_wait (inode=0xe7ae1310) at fs/pipe.c:42
  471 Thread 7084  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  470 Thread 7082  pipe_wait (inode=0xe8b1e080) at fs/pipe.c:42
  469 Thread 7081  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  468 Thread 7079  pipe_wait (inode=0xe8b1ece0) at fs/pipe.c:42
  467 Thread 7078  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  466 Thread 7076  pipe_wait (inode=0xe8b1f940) at fs/pipe.c:42
  465 Thread 7075  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  464 Thread 7073  pipe_wait (inode=0xeba3c6b0) at fs/pipe.c:42
  463 Thread 7072  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  462 Thread 7070  pipe_wait (inode=0xeba3d310) at fs/pipe.c:42
  461 Thread 7069  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  460 Thread 7067  pipe_wait (inode=0xe8a7a080) at fs/pipe.c:42
  459 Thread 7066  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  458 Thread 7064  pipe_wait (inode=0xe8a7ace0) at fs/pipe.c:42
  457 Thread 7063  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  456 Thread 7061  pipe_wait (inode=0xe8a7b940) at fs/pipe.c:42
  455 Thread 7060  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  454 Thread 7058  pipe_wait (inode=0xea1066b0) at fs/pipe.c:42
  453 Thread 7057  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  452 Thread 7055  pipe_wait (inode=0xea107310) at fs/pipe.c:42
  451 Thread 7054  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  450 Thread 7052  pipe_wait (inode=0xe8a94080) at fs/pipe.c:42
  449 Thread 7051  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  448 Thread 7049  pipe_wait (inode=0xe8a94ce0) at fs/pipe.c:42
  447 Thread 7048  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  446 Thread 7046  pipe_wait (inode=0xe8a95940) at fs/pipe.c:42
  445 Thread 7045  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  444 Thread 7043  pipe_wait (inode=0xeffb26b0) at fs/pipe.c:42
  443 Thread 7042  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  442 Thread 7040  pipe_wait (inode=0xeffb3310) at fs/pipe.c:42
  441 Thread 7039  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  440 Thread 7037  pipe_wait (inode=0xeb05e080) at fs/pipe.c:42
  439 Thread 7036  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  438 Thread 7034  pipe_wait (inode=0xeb05ece0) at fs/pipe.c:42
  437 Thread 7033  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  436 Thread 7031  pipe_wait (inode=0xeb05f940) at fs/pipe.c:42
  435 Thread 7030  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  434 Thread 7028  pipe_wait (inode=0xe837c6b0) at fs/pipe.c:42
  433 Thread 7027  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  432 Thread 7025  pipe_wait (inode=0xe837d310) at fs/pipe.c:42
  431 Thread 7024  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  430 Thread 7022  pipe_wait (inode=0xed283940) at fs/pipe.c:42
  429 Thread 7021  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  428 Thread 7019  pipe_wait (inode=0xeda20ce0) at fs/pipe.c:42
  427 Thread 7018  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  426 Thread 7016  pipe_wait (inode=0xeda21310) at fs/pipe.c:42
  425 Thread 7015  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  424 Thread 7013  pipe_wait (inode=0xebc306b0) at fs/pipe.c:42
  423 Thread 7012  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  422 Thread 7010  pipe_wait (inode=0xeaae26b0) at fs/pipe.c:42
  421 Thread 7009  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  420 Thread 7007  pipe_wait (inode=0xeaae2ce0) at fs/pipe.c:42
  419 Thread 7006  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  418 Thread 7004  pipe_wait (inode=0xee6db310) at fs/pipe.c:42
  417 Thread 7003  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  416 Thread 7001  pipe_wait (inode=0xee193310) at fs/pipe.c:42
  415 Thread 7000  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  414 Thread 6998  pipe_wait (inode=0xf174ece0) at fs/pipe.c:42
  413 Thread 6997  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  412 Thread 6995  pipe_wait (inode=0xf174e6b0) at fs/pipe.c:42
  411 Thread 6994  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  410 Thread 6992  pipe_wait (inode=0xef747310) at fs/pipe.c:42
  409 Thread 6991  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  408 Thread 6989  pipe_wait (inode=0xeb4ec080) at fs/pipe.c:42
  407 Thread 6988  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  406 Thread 6986  pipe_wait (inode=0xeaf0d940) at fs/pipe.c:42
  405 Thread 6985  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  404 Thread 6983  pipe_wait (inode=0xebd606b0) at fs/pipe.c:42
  403 Thread 6982  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  402 Thread 6980  pipe_wait (inode=0xed8d7940) at fs/pipe.c:42
  401 Thread 6979  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  400 Thread 6977  pipe_wait (inode=0xee6126b0) at fs/pipe.c:42
  399 Thread 6976  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  398 Thread 6974  pipe_wait (inode=0xee2a2ce0) at fs/pipe.c:42
  397 Thread 6973  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  396 Thread 6971  pipe_wait (inode=0xecd126b0) at fs/pipe.c:42
  395 Thread 6970  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  394 Thread 6968  pipe_wait (inode=0xee845310) at fs/pipe.c:42
  393 Thread 6967  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  392 Thread 6965  pipe_wait (inode=0xee844080) at fs/pipe.c:42
  391 Thread 6964  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  390 Thread 6962  pipe_wait (inode=0xed448080) at fs/pipe.c:42
  389 Thread 6961  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  388 Thread 6959  pipe_wait (inode=0xea52ace0) at fs/pipe.c:42
  387 Thread 6958  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  386 Thread 6956  pipe_wait (inode=0xebd81940) at fs/pipe.c:42
  385 Thread 6955  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  384 Thread 6953  pipe_wait (inode=0xf1074080) at fs/pipe.c:42
  383 Thread 6952  __down (sem=0xf7ffd6d4) at
arch/i386/kernel/semaphore.c:84
  382 Thread 6950  pipe_wait (inode=0xf2758ce0) at fs/pipe.c:42
  381 Thread 6949  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  380 Thread 6947  pipe_wait (inode=0xece96080) at fs/pipe.c:42
  379 Thread 6946  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  378 Thread 6944  pipe_wait (inode=0xeaa746b0) at fs/pipe.c:42
  377 Thread 6943  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  376 Thread 6941  pipe_wait (inode=0xed2ff310) at fs/pipe.c:42
  375 Thread 6940  sys_wait4 (pid=-1, stat_addr=0xbff1115c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  374 Thread 6922  io_schedule () at atomic.h:122
  373 Thread 6921  io_schedule () at atomic.h:122
  372 Thread 6920  io_schedule () at atomic.h:122
  371 Thread 6919  io_schedule () at atomic.h:122
  370 Thread 6918  io_schedule () at atomic.h:122
  369 Thread 6917  io_schedule () at atomic.h:122
  368 Thread 6916  io_schedule () at atomic.h:122
  367 Thread 6915  io_schedule () at atomic.h:122
  366 Thread 6914  io_schedule () at atomic.h:122
  365 Thread 6913  io_schedule () at atomic.h:122
  364 Thread 6912  io_schedule () at atomic.h:122
  363 Thread 6911  io_schedule () at atomic.h:122
  362 Thread 6910  io_schedule () at atomic.h:122
  361 Thread 6909  io_schedule () at atomic.h:122
  360 Thread 6908  io_schedule () at atomic.h:122
  359 Thread 6907  io_schedule () at atomic.h:122
  358 Thread 6906  io_schedule () at atomic.h:122
  357 Thread 6905  io_schedule () at atomic.h:122
  356 Thread 6904  io_schedule () at atomic.h:122
  355 Thread 6903  io_schedule () at atomic.h:122
  354 Thread 6902  io_schedule () at atomic.h:122
  353 Thread 6901  io_schedule () at atomic.h:122
  352 Thread 6900  io_schedule () at atomic.h:122
  351 Thread 6899  0xc01200b7 in schedule () at kernel/sched.c:659
  350 Thread 6898  io_schedule () at atomic.h:122
  349 Thread 6897  io_schedule () at atomic.h:122
  348 Thread 6896  io_schedule () at atomic.h:122
  347 Thread 6895  io_schedule () at atomic.h:122
  346 Thread 6894  io_schedule () at atomic.h:122
  345 Thread 6893  io_schedule () at atomic.h:122
  344 Thread 6892  io_schedule () at atomic.h:122
  343 Thread 6891  io_schedule () at atomic.h:122
  342 Thread 6890  io_schedule () at atomic.h:122
  341 Thread 6889  io_schedule () at atomic.h:122
  340 Thread 6888  io_schedule () at atomic.h:122
  339 Thread 6887  io_schedule () at atomic.h:122
  338 Thread 6886  io_schedule () at atomic.h:122
  337 Thread 6885  0xc01200b7 in schedule () at kernel/sched.c:659
  336 Thread 6884  io_schedule () at atomic.h:122
  335 Thread 6883  io_schedule () at atomic.h:122
  334 Thread 6882  io_schedule () at atomic.h:122
  333 Thread 6881  io_schedule () at atomic.h:122
  332 Thread 6880  io_schedule () at atomic.h:122
  331 Thread 6879  io_schedule () at atomic.h:122
  330 Thread 6878  0xc01200b7 in schedule () at kernel/sched.c:659
  329 Thread 6877  io_schedule () at atomic.h:122
  328 Thread 6876  io_schedule () at atomic.h:122
  327 Thread 6875  io_schedule () at atomic.h:122
  326 Thread 6874  io_schedule () at atomic.h:122
  325 Thread 6873  io_schedule () at atomic.h:122
  324 Thread 6872  io_schedule () at atomic.h:122
  323 Thread 6871  io_schedule () at atomic.h:122
  322 Thread 6870  io_schedule () at atomic.h:122
  321 Thread 6869  io_schedule () at atomic.h:122
  320 Thread 6868  io_schedule () at atomic.h:122
  319 Thread 6867  io_schedule () at atomic.h:122
  318 Thread 6866  io_schedule () at atomic.h:122
  317 Thread 6865  io_schedule () at atomic.h:122
  316 Thread 6864  io_schedule () at atomic.h:122
  315 Thread 6863  io_schedule () at atomic.h:122
  314 Thread 6862  io_schedule () at atomic.h:122
  313 Thread 6861  io_schedule () at atomic.h:122
  312 Thread 6860  io_schedule () at atomic.h:122
  311 Thread 6859  io_schedule () at atomic.h:122

  310 Thread 6858  io_schedule () at atomic.h:122
  309 Thread 6857  io_schedule () at atomic.h:122
  308 Thread 6856  io_schedule () at atomic.h:122
  307 Thread 6855  io_schedule () at atomic.h:122
  306 Thread 6854  io_schedule () at atomic.h:122
  305 Thread 6853  io_schedule () at atomic.h:122
  304 Thread 6852  io_schedule () at atomic.h:122
  303 Thread 6851  io_schedule () at atomic.h:122
  302 Thread 6850  io_schedule () at atomic.h:122
  301 Thread 6849  io_schedule () at atomic.h:122
  300 Thread 6848  0xc01200b7 in schedule () at kernel/sched.c:659
  299 Thread 6847  io_schedule () at atomic.h:122
  298 Thread 6846  io_schedule () at atomic.h:122
  297 Thread 6845  io_schedule () at atomic.h:122
  296 Thread 6844  io_schedule () at atomic.h:122
  295 Thread 6843  io_schedule () at atomic.h:122
  294 Thread 6842  io_schedule () at atomic.h:122
  293 Thread 6841  io_schedule () at atomic.h:122
  292 Thread 6840  io_schedule () at atomic.h:122
  291 Thread 6839  io_schedule () at atomic.h:122
  290 Thread 6838  io_schedule () at atomic.h:122
  289 Thread 6837  io_schedule () at atomic.h:122
  288 Thread 6836  io_schedule () at atomic.h:122
  287 Thread 6835  io_schedule () at atomic.h:122
  286 Thread 6834  io_schedule () at atomic.h:122
  285 Thread 6833  io_schedule () at atomic.h:122
  284 Thread 6832  io_schedule () at atomic.h:122
  283 Thread 6831  io_schedule () at atomic.h:122
  282 Thread 6830  io_schedule () at atomic.h:122
  281 Thread 6829  io_schedule () at atomic.h:122
  280 Thread 6828  io_schedule () at atomic.h:122
  279 Thread 6827  io_schedule () at atomic.h:122
  278 Thread 6826  io_schedule () at atomic.h:122
  277 Thread 6825  0xc01200b7 in schedule () at kernel/sched.c:659
  276 Thread 6824  io_schedule () at atomic.h:122
  275 Thread 6823  io_schedule () at atomic.h:122
  274 Thread 6822  0xc01200b7 in schedule () at kernel/sched.c:659
  273 Thread 6821  io_schedule () at atomic.h:122
  272 Thread 6820  io_schedule () at atomic.h:122
  271 Thread 6819  io_schedule () at atomic.h:122
  270 Thread 6818  io_schedule () at atomic.h:122
  269 Thread 6817  io_schedule () at atomic.h:122
  268 Thread 6816  io_schedule () at atomic.h:122
  267 Thread 6815  io_schedule () at atomic.h:122
  266 Thread 6814  io_schedule () at atomic.h:122
  265 Thread 6813  io_schedule () at atomic.h:122
  264 Thread 6812  io_schedule () at atomic.h:122
  263 Thread 6811  io_schedule () at atomic.h:122
  262 Thread 6810  io_schedule () at atomic.h:122
  261 Thread 6809  io_schedule () at atomic.h:122
  260 Thread 6808  io_schedule () at atomic.h:122
  259 Thread 6807  io_schedule () at atomic.h:122
  258 Thread 6806  io_schedule () at atomic.h:122
  257 Thread 6805  io_schedule () at atomic.h:122
  256 Thread 6804  io_schedule () at atomic.h:122
  255 Thread 6803  io_schedule () at atomic.h:122
  254 Thread 6802  io_schedule () at atomic.h:122
  253 Thread 6801  io_schedule () at atomic.h:122
  252 Thread 6800  io_schedule () at atomic.h:122
  251 Thread 6799  io_schedule () at atomic.h:122
  250 Thread 6798  io_schedule () at atomic.h:122
  249 Thread 6797  io_schedule () at atomic.h:122
  248 Thread 6796  io_schedule () at atomic.h:122
  247 Thread 6795  io_schedule () at atomic.h:122
  246 Thread 6794  io_schedule () at atomic.h:122
  245 Thread 6793  io_schedule () at atomic.h:122
  244 Thread 6792  io_schedule () at atomic.h:122
  243 Thread 6791  io_schedule () at atomic.h:122
  242 Thread 6790  io_schedule () at atomic.h:122
  241 Thread 6789  io_schedule () at atomic.h:122
  240 Thread 6788  io_schedule () at atomic.h:122
  239 Thread 6787  io_schedule () at atomic.h:122
  238 Thread 6786  io_schedule () at atomic.h:122
  237 Thread 6785  io_schedule () at atomic.h:122
  236 Thread 6784  io_schedule () at atomic.h:122
  235 Thread 6783  io_schedule () at atomic.h:122
  234 Thread 6782  io_schedule () at atomic.h:122
  233 Thread 6781  io_schedule () at atomic.h:122
  232 Thread 6780  io_schedule () at atomic.h:122
  231 Thread 6779  io_schedule () at atomic.h:122
  230 Thread 6778  io_schedule () at atomic.h:122
  229 Thread 6777  io_schedule () at atomic.h:122
  228 Thread 6776  io_schedule () at atomic.h:122
  227 Thread 6775  io_schedule () at atomic.h:122
  226 Thread 6774  io_schedule () at atomic.h:122
  225 Thread 6773  io_schedule () at atomic.h:122
  224 Thread 6772  0xc01200b7 in schedule () at kernel/sched.c:659
  223 Thread 6771  io_schedule () at atomic.h:122
  222 Thread 6770  io_schedule () at atomic.h:122
  221 Thread 6769  io_schedule () at atomic.h:122
  220 Thread 6768  0xc01200b7 in schedule () at kernel/sched.c:659
  219 Thread 6767  io_schedule () at atomic.h:122
  218 Thread 6766  io_schedule () at atomic.h:122
  217 Thread 6765  io_schedule () at atomic.h:122
  216 Thread 6764  io_schedule () at atomic.h:122
  215 Thread 6763  io_schedule () at atomic.h:122
  214 Thread 6762  io_schedule () at atomic.h:122
  213 Thread 6761  io_schedule () at atomic.h:122
  212 Thread 6760  io_schedule () at atomic.h:122
  211 Thread 6759  io_schedule () at atomic.h:122
  210 Thread 6758  io_schedule () at atomic.h:122
  209 Thread 6757  io_schedule () at atomic.h:122
  208 Thread 6756  io_schedule () at atomic.h:122
  207 Thread 6755  0xc01200b7 in schedule () at kernel/sched.c:659
  206 Thread 6754  io_schedule () at atomic.h:122
  205 Thread 6753  0xc01200b7 in schedule () at kernel/sched.c:659
  204 Thread 6752  io_schedule () at atomic.h:122
  203 Thread 6751  io_schedule () at atomic.h:122
  202 Thread 6750  io_schedule () at atomic.h:122
  201 Thread 6749  io_schedule () at atomic.h:122
  200 Thread 6748  io_schedule () at atomic.h:122
  199 Thread 6747  io_schedule () at atomic.h:122
  198 Thread 6746  io_schedule () at atomic.h:122
  197 Thread 6745  io_schedule () at atomic.h:122
  196 Thread 6744  io_schedule () at atomic.h:122
  195 Thread 6743  io_schedule () at atomic.h:122
  194 Thread 6742  io_schedule () at atomic.h:122
  193 Thread 6741  io_schedule () at atomic.h:122
  192 Thread 6740  io_schedule () at atomic.h:122
  191 Thread 6739  io_schedule () at atomic.h:122
  190 Thread 6738  io_schedule () at atomic.h:122
  189 Thread 6737  io_schedule () at atomic.h:122
  188 Thread 6736  io_schedule () at atomic.h:122
  187 Thread 6735  io_schedule () at atomic.h:122
  186 Thread 6734  io_schedule () at atomic.h:122
  185 Thread 6733  io_schedule () at atomic.h:122
  184 Thread 6732  io_schedule () at atomic.h:122
  183 Thread 6731  0xc01200b7 in schedule () at kernel/sched.c:659
  182 Thread 6730  io_schedule () at atomic.h:122
  181 Thread 6729  io_schedule () at atomic.h:122
  180 Thread 6728  io_schedule () at atomic.h:122
  179 Thread 6727  io_schedule () at atomic.h:122
  178 Thread 6726  io_schedule () at atomic.h:122
  177 Thread 6725  io_schedule () at atomic.h:122
  176 Thread 6724  io_schedule () at atomic.h:122
  175 Thread 6723  io_schedule () at atomic.h:122
  174 Thread 6722  io_schedule () at atomic.h:122
  173 Thread 6721  io_schedule () at atomic.h:122
  172 Thread 6720  io_schedule () at atomic.h:122
  171 Thread 6719  io_schedule () at atomic.h:122
  170 Thread 6718  0xc01200b7 in schedule () at kernel/sched.c:659
  169 Thread 6717  io_schedule () at atomic.h:122
  168 Thread 6716  io_schedule () at atomic.h:122
  167 Thread 6715  io_schedule () at atomic.h:122
  166 Thread 6714  io_schedule () at atomic.h:122
  165 Thread 6713  io_schedule () at atomic.h:122
  164 Thread 6712  io_schedule () at atomic.h:122
  163 Thread 6711  io_schedule () at atomic.h:122
  162 Thread 6710  io_schedule () at atomic.h:122
  161 Thread 6709  io_schedule () at atomic.h:122
  160 Thread 6708  io_schedule () at atomic.h:122
  159 Thread 6707  io_schedule () at atomic.h:122
  158 Thread 6706  io_schedule () at atomic.h:122
  157 Thread 6705  io_schedule () at atomic.h:122
  156 Thread 6704  io_schedule () at atomic.h:122
  155 Thread 6703  io_schedule () at atomic.h:122
  154 Thread 6702  0xc01200b7 in schedule () at kernel/sched.c:659
  153 Thread 6701  io_schedule () at atomic.h:122
  152 Thread 6700  io_schedule () at atomic.h:122
  151 Thread 6699  io_schedule () at atomic.h:122
  150 Thread 6698  io_schedule () at atomic.h:122
  149 Thread 6697  io_schedule () at atomic.h:122
  148 Thread 6696  io_schedule () at atomic.h:122
  147 Thread 6695  io_schedule () at atomic.h:122
  146 Thread 6694  io_schedule () at atomic.h:122
  145 Thread 6693  io_schedule () at atomic.h:122
  144 Thread 6692  io_schedule () at atomic.h:122
  143 Thread 6691  io_schedule () at atomic.h:122
  142 Thread 6690  io_schedule () at atomic.h:122
  141 Thread 6689  io_schedule () at atomic.h:122
  140 Thread 6688  io_schedule () at atomic.h:122
  139 Thread 6687  io_schedule () at atomic.h:122
  138 Thread 6686  io_schedule () at atomic.h:122
  137 Thread 6685  io_schedule () at atomic.h:122
  136 Thread 6684  io_schedule () at atomic.h:122
  135 Thread 6683  io_schedule () at atomic.h:122
  134 Thread 6682  io_schedule () at atomic.h:122
  133 Thread 6681  io_schedule () at atomic.h:122
  132 Thread 6680  io_schedule () at atomic.h:122
  131 Thread 6679  io_schedule () at atomic.h:122
  130 Thread 6678  io_schedule () at atomic.h:122
  129 Thread 6677  io_schedule () at atomic.h:122
  128 Thread 6676  io_schedule () at atomic.h:122
  127 Thread 6675  io_schedule () at atomic.h:122
  126 Thread 6674  io_schedule () at atomic.h:122
  125 Thread 6673  io_schedule () at atomic.h:122
  124 Thread 6672  0xc01200b7 in schedule () at kernel/sched.c:659
  123 Thread 6671  io_schedule () at atomic.h:122
  122 Thread 6670  io_schedule () at atomic.h:122
  121 Thread 6669  io_schedule () at atomic.h:122
  120 Thread 6668  io_schedule () at atomic.h:122
  119 Thread 6667  io_schedule () at atomic.h:122
  118 Thread 6666  0xc01200b7 in schedule () at kernel/sched.c:659
  117 Thread 6665  io_schedule () at atomic.h:122
  116 Thread 6664  io_schedule () at atomic.h:122
  115 Thread 6663  io_schedule () at atomic.h:122
  114 Thread 6662  io_schedule () at atomic.h:122
  113 Thread 6661  io_schedule () at atomic.h:122
  112 Thread 6660  io_schedule () at atomic.h:122
  111 Thread 6659  io_schedule () at atomic.h:122
  110 Thread 6658  io_schedule () at atomic.h:122
  109 Thread 6657  io_schedule () at atomic.h:122
  108 Thread 6656  io_schedule () at atomic.h:122
  107 Thread 6655  io_schedule () at atomic.h:122
  106 Thread 6654  io_schedule () at atomic.h:122
  105 Thread 6653  io_schedule () at atomic.h:122
  104 Thread 6652  io_schedule () at atomic.h:122
  103 Thread 6651  io_schedule () at atomic.h:122
  102 Thread 6650  io_schedule () at atomic.h:122
  101 Thread 6649  io_schedule () at atomic.h:122
  100 Thread 6648  io_schedule () at atomic.h:122
  99 Thread 6647  io_schedule () at atomic.h:122
  98 Thread 6646  io_schedule () at atomic.h:122
  97 Thread 6645  io_schedule () at atomic.h:122
  96 Thread 6644  io_schedule () at atomic.h:122
  95 Thread 6643  io_schedule () at atomic.h:122
  94 Thread 6642  io_schedule () at atomic.h:122
  93 Thread 6641  io_schedule () at atomic.h:122
  92 Thread 6640  io_schedule () at atomic.h:122
  91 Thread 6639  io_schedule () at atomic.h:122
  90 Thread 6638  0xc01200b7 in schedule () at kernel/sched.c:659
  89 Thread 6637  io_schedule () at atomic.h:122
  88 Thread 6636  0xc01200b7 in schedule () at kernel/sched.c:659
  87 Thread 6635  io_schedule () at atomic.h:122
  86 Thread 6634  io_schedule () at atomic.h:122
  85 Thread 6633  io_schedule () at atomic.h:122
  84 Thread 6632  io_schedule () at atomic.h:122
  83 Thread 6631  io_schedule () at atomic.h:122
  82 Thread 6630  io_schedule () at atomic.h:122
  81 Thread 6629  io_schedule () at atomic.h:122
  80 Thread 6628  io_schedule () at atomic.h:122
  79 Thread 6627  io_schedule () at atomic.h:122
  78 Thread 6626  io_schedule () at atomic.h:122
  77 Thread 6625  io_schedule () at atomic.h:122
  76 Thread 6624  io_schedule () at atomic.h:122
  75 Thread 6623  io_schedule () at atomic.h:122
  74 Thread 6622  io_schedule () at atomic.h:122
  73 Thread 6621  io_schedule () at atomic.h:122
  72 Thread 6620  io_schedule () at atomic.h:122
  71 Thread 6586  sys_wait4 (pid=-1, stat_addr=0xbff1112c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  70 Thread 6573  0xc01bc2e6 in do_get_write_access (handle=0xf225d224, 
    jh=0xf708ee68, force_copy=0, credits=0x0) at
fs/jbd/transaction.c:638
  69 Thread 6317  sys_wait4 (pid=-1, stat_addr=0xbfffef98, options=2,
ru=0x0)
    at kernel/exit.c:1057
  68 Thread 6295  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1008
  67 Thread 6182  0xc01235ed in mmput (mm=0xe6356a5c) at list.h:148
  66 Thread 6091  sys_wait4 (pid=-1, stat_addr=0xbffffb78, options=2,
ru=0x0)
    at kernel/exit.c:1057
  65 Thread 6062  sys_wait4 (pid=-1, stat_addr=0xbffff4f4, options=0,
ru=0x0)
    at kernel/exit.c:1057
  64 Thread 6012  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1008
  63 Thread 5943  sys_wait4 (pid=-1, stat_addr=0xbffff758, options=0,
ru=0x0)
    at kernel/exit.c:1057
  62 Thread 5073  sys_pause () at kernel/signal.c:2428
  61 Thread 3127  io_schedule () at atomic.h:122
  60 Thread 3110  io_schedule () at atomic.h:122
  59 Thread 2420  io_schedule () at atomic.h:122
  58 Thread 2419  io_schedule () at atomic.h:122
  57 Thread 2414  sys_wait4 (pid=-1, stat_addr=0xbff1114c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  56 Thread 2407  io_schedule () at atomic.h:122
  55 Thread 2406  io_schedule () at atomic.h:122
  54 Thread 2405  sys_wait4 (pid=-1, stat_addr=0xbff1112c, options=0,
ru=0x0)
    at kernel/exit.c:1057
  53 Thread 2138  pipe_wait (inode=0xe6356da8) at fs/pipe.c:42
  52 Thread 1863  io_schedule () at atomic.h:122
  51 Thread 1816  sys_wait4 (pid=-1, stat_addr=0xbffffb78, options=2,
ru=0x0)
    at kernel/exit.c:1057
  50 Thread 1804  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1008
  49 Thread 1756  sys_wait4 (pid=-1, stat_addr=0xbffffb78, options=2,
ru=0x0)
    at kernel/exit.c:1057
  48 Thread 1746  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1008
  47 Thread 1745  schedule_timeout (timeout=1055938017) at
kernel/timer.c:1008
  46 Thread 1744  schedule_timeout (timeout=-1069634432) at
kernel/timer.c:1008
  45 Thread 1743  schedule_timeout (timeout=1055938017) at
kernel/timer.c:1008
  44 Thread 1742  schedule_timeout (timeout=1055938017) at
kernel/timer.c:1008
  43 Thread 1741  schedule_timeout (timeout=1055938017) at
kernel/timer.c:1008
  42 Thread 1740  schedule_timeout (timeout=-144883712) at
kernel/timer.c:1008
  41 Thread 1729  do_clock_nanosleep (which_clock=0, flags=0,
tsave=0xf2c1ffa8)
    at kernel/posix-timers.c:1210
  40 Thread 1719  do_clock_nanosleep (which_clock=0, flags=0,
tsave=0xf2cb1fa8)
    at kernel/posix-timers.c:1210
  39 Thread 1701  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1036
  38 Thread 1624  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1008
  37 Thread 1412  0xc01200b7 in schedule () at kernel/sched.c:659
  36 Thread 1401  do_clock_nanosleep (which_clock=0, flags=0,
tsave=0xf495ffa8)
    at kernel/posix-timers.c:1210
  35 Thread 1343  sys_wait4 (pid=-1, stat_addr=0xbfffef98, options=2,
ru=0x0)
    at kernel/exit.c:1057
  34 Thread 1336  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1036
  33 Thread 1316  schedule_timeout (timeout=-1069634432) at
kernel/timer.c:1036
  32 Thread 1307  schedule_timeout (timeout=1) at kernel/timer.c:1008
  31 Thread 1277  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1008
  30 Thread 1213  sys_wait4 (pid=-1, stat_addr=0xbfffe818, options=2,
ru=0x0)
    at kernel/exit.c:1057
  29 Thread 1207  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1008
  28 Thread 1205  sys_wait4 (pid=-1, stat_addr=0xbffffb08, options=2,
ru=0x0)
    at kernel/exit.c:1057
  27 Thread 1190  sys_pause () at kernel/signal.c:2428
  26 Thread 1180  schedule_timeout (timeout=-167338496) at
kernel/timer.c:1036
  25 Thread 1157  schedule_timeout (timeout=-1069634432) at
kernel/timer.c:1036
  24 Thread 1147  schedule_timeout (timeout=16) at kernel/timer.c:1008
  23 Thread 1130  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1008
  22 Thread 1128  schedule_timeout (timeout=-1069634432) at
kernel/timer.c:1008
  21 Thread 1113  schedule_timeout (timeout=-1069634432) at
kernel/timer.c:1008
  20 Thread 1071  schedule_timeout (timeout=0) at kernel/timer.c:1008
  19 Thread 1070  0xc03174b4 in rpciod (ptr=0xc03bc238)
    at net/sunrpc/sched.c:980
  18 Thread 1012  schedule_timeout (timeout=-1069634432) at
kernel/timer.c:1008
  17 Thread 993  schedule_timeout (timeout=16) at kernel/timer.c:1008
  16 Thread 967  0xc01200b7 in schedule () at kernel/sched.c:659
  15 Thread 963  0xc01c3e2c in log_wait_commit (journal=0xf7d33940,
tid=128281)
    at fs/jbd/journal.c:512
  14 Thread 617  kjournald (arg=0xc03eac80) at thread_info.h:82
  13 Thread 13  io_schedule () at atomic.h:122
  12 Thread 12  0xc02a54c0 in serio_thread (nothing=0x0)
    at drivers/input/serio/serio.c:113
  11 Thread 10  0xc01377ce in worker_thread (__startup=0x46)
    at kernel/workqueue.c:196
  10 Thread 9  __down (sem=0xf7d8fdfc) at
arch/i386/kernel/semaphore.c:84
  9 Thread 8  kswapd (p=0xc0378700) at mm/vmscan.c:988
  8 Thread 7  __pdflush (my_work=0x46) at thread_info.h:82
  7 Thread 6  __pdflush (my_work=0x46) at thread_info.h:82
  6 Thread 5  0xc01377ce in worker_thread (__startup=0x46)
    at kernel/workqueue.c:196
  5 Thread 4  0xc01377ce in worker_thread (__startup=0x46)
    at kernel/workqueue.c:196
  4 Thread 3  ksoftirqd (__bind_cpu=0x0) at thread_info.h:82
  3 Thread 2  migration_thread (data=0xf7f92000) at kernel/sched.c:2392
  2 Thread 1  schedule_timeout (timeout=-1070101248) at
kernel/timer.c:1036
  1 Thread 0  0xc01200b7 in schedule () at kernel/sched.c:659

humm thread 67 looks to be the culprit
thats process 6182... and from my frozen display that was running top at
the time...
  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME CPU
COMMAND
...
 6182 root      16   0  1416  464  1364 R     1.1  0.0   0:07   0 vmstat
...

erk,.. vmstat blew the kernel??





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
