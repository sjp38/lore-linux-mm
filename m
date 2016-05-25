Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 830E56B0005
	for <linux-mm@kvack.org>; Tue, 24 May 2016 20:14:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 129so59389301pfx.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 17:14:58 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id vb10si8173905pab.56.2016.05.24.17.14.56
        for <linux-mm@kvack.org>;
        Tue, 24 May 2016 17:14:56 -0700 (PDT)
Date: Wed, 25 May 2016 08:14:51 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [linux-next:master 11896/11991] include/linux/page_idle.h:49:19:
 warning: unused variable 'page_ext'
Message-ID: <20160525001451.GA23164@wfg-t540p.sh.intel.com>
References: <201605241820.dS1jQptn%fengguang.wu@intel.com>
 <20160524124457.2fa8fca1db728522fd22de54@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160524124457.2fa8fca1db728522fd22de54@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Yang Shi <yang.shi@linaro.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, May 24, 2016 at 12:44:57PM -0700, Andrew Morton wrote:
> On Tue, 24 May 2016 18:48:23 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   66c198deda3725c57939c6cdaf2c9f5375cd79ad
> > commit: 186ba1a848cef542bdf7c881f863783e9e7a91df [11896/11991] mm-check-the-return-value-of-lookup_page_ext-for-all-call-sites-checkpatch-fixes
> > config: i386-randconfig-h1-05241552 (attached as .config)
> > compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> > reproduce:
> >         git checkout 186ba1a848cef542bdf7c881f863783e9e7a91df
> >         # save the attached .config to linux build tree
> >         make ARCH=i386 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >                                  ^~~~~~~~~~~~~~~~~~~~~~~~
> >    fs/proc/task_mmu.c:408:30: warning: unused variable 'proc_pid_maps_operations' [-Wunused-variable]
> >     const struct file_operations proc_pid_maps_operations = {
> >                                  ^~~~~~~~~~~~~~~~~~~~~~~
> 
> Confused.  proc_pid_maps_operations is referenced from fs/proc/base.o.
> 
> >    In file included from fs/proc/task_mmu.c:22:0:
> >    fs/proc/internal.h:299:37: warning: unused variable 'proc_pagemap_operations' [-Wunused-variable]
> >     extern const struct file_operations proc_pagemap_operations;
> >                                         ^~~~~~~~~~~~~~~~~~~~~~~
> 
> Even more confused.  Your config has CONFIG_PROC_PAGE_MONITOR=n, so
> proc_pagemap_operations doesn't get past the cpp stage.

They are confusing indeed.

> >    In file included from fs/proc/task_mmu.c:16:0:
> > >> include/linux/page_idle.h:49:19: warning: unused variable 'page_ext' [-Wunused-variable]
> >      struct page_ext *page_ext = lookup_page_ext(page);
> 
> This is the new one and is presumably caused by the great stream of
> missing ')'s in the CONFIG_64BIT=n section of page_idle.h.

That triggered so many noises (pasted below), it may be easier to look
closer at the error/warnings after fixing that issue.

-       if (unlikely(!page_ext)
+       if (unlikely(!page_ext))

All the error/warnings magically disappears after adding the missing ')'s!

Thanks,
Fengguang
---
make ARCH=i386 M=fs/proc/

grep -a -F fs/proc/ /tmp/build-err-186ba1a848cef542bdf7c881f863783e9e7a91df-wfg --color
warning: (VIDEO_EM28XX_V4L2) selects VIDEO_MT9V011 which has unmet direct dependencies (MEDIA_SUPPORT && I2C && VIDEO_V4L2 && MEDIA_CAMERA_SUPPORT)
warning: (VIDEO_EM28XX_V4L2) selects VIDEO_MT9V011 which has unmet direct dependencies (MEDIA_SUPPORT && I2C && VIDEO_V4L2 && MEDIA_CAMERA_SUPPORT)
In file included from ../fs/proc/task_mmu.c:16:0:
../include/linux/page_idle.h: In function 'page_is_young':
../include/linux/page_idle.h:139:0: error: unterminated argument list invoking macro "if"
--

In file included from ../include/linux/shmem_fs.h:4:0,
                 from ../fs/proc/task_mmu.c:17:
../include/linux/file.h:12:1: error: expected '(' before 'struct'
 struct file;
--
                    ^~~~~~~~~
In file included from ../include/linux/shmem_fs.h:9:0,
                 from ../fs/proc/task_mmu.c:17:
../include/linux/xattr.h:62:27: error: invalid storage class for function 'xattr_prefix'
 static inline const char *xattr_prefix(const struct xattr_handler *handler)
--
 static inline void simple_xattrs_free(struct simple_xattrs *xattrs)
                    ^~~~~~~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:17:0:
../include/linux/shmem_fs.h:22:16: error: field 'vfs_inode' has incomplete type
  struct inode  vfs_inode;
--
                 from ../include/linux/mmdebug.h:4,
                 from ../include/linux/mm.h:8,
                 from ../fs/proc/task_mmu.c:1:
../include/linux/shmem_fs.h: In function 'SHMEM_I':
../include/linux/kernel.h:831:48: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
--
  return container_of(inode, struct shmem_inode_info, vfs_inode);
         ^~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:17:0:
../include/linux/shmem_fs.h: In function 'page_is_young':
../include/linux/shmem_fs.h:64:28: error: invalid storage class for function 'shmem_read_mapping_page'
--
                            ^~~~~~~~~~~~~~~~~~~~~~~
In file included from ../arch/x86/include/asm/elf.h:94:0,
                 from ../fs/proc/task_mmu.c:19:
../arch/x86/include/asm/desc.h:11:20: error: invalid storage class for function 'fill_ldt'
 static inline void fill_ldt(struct desc_struct *desc, const struct user_desc *info)
--
                 from ../include/linux/gfp.h:5,
                 from ../include/linux/mm.h:9,
                 from ../fs/proc/task_mmu.c:1:
../include/linux/percpu-defs.h:86:33: error: section attribute cannot be specified for local variables
  extern __PCPU_DUMMY_ATTRS char __pcpu_scope_##name;  \
--
 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
In file included from ../arch/x86/include/asm/elf.h:94:0,
                 from ../fs/proc/task_mmu.c:19:
../arch/x86/include/asm/desc.h:48:35: error: invalid storage class for function 'get_cpu_gdt_table'
 static inline struct desc_struct *get_cpu_gdt_table(unsigned int cpu)
--
 static inline void load_current_idt(void)
                    ^~~~~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:19:0:
../arch/x86/include/asm/elf.h:345:19: error: invalid storage class for function 'mmap_is_ia32'
 static inline int mmap_is_ia32(void)
                   ^~~~~~~~~~~~
In file included from ../fs/proc/internal.h:12:0,
                 from ../fs/proc/task_mmu.c:22:
../include/linux/proc_fs.h:30:38: error: invalid storage class for function 'proc_create'
 static inline struct proc_dir_entry *proc_create(
--
 static inline struct proc_dir_entry *proc_net_mkdir(
                                      ^~~~~~~~~~~~~~
In file included from ../fs/proc/internal.h:13:0,
                 from ../fs/proc/task_mmu.c:22:
../include/linux/proc_ns.h:64:19: error: invalid storage class for function 'ns_alloc_inum'
 static inline int ns_alloc_inum(struct ns_common *ns)
                   ^~~~~~~~~~~~~
In file included from ../fs/proc/internal.h:16:0,
                 from ../fs/proc/task_mmu.c:22:
../include/linux/binfmts.h:86:20: error: invalid storage class for function 'register_binfmt'
 static inline void register_binfmt(struct linux_binfmt *fmt)
--
 static inline void insert_binfmt(struct linux_binfmt *fmt)
                    ^~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h:69:15: error: field 'vfs_inode' has incomplete type
  struct inode vfs_inode;
               ^~~~~~~~~
../fs/proc/internal.h:75:34: error: invalid storage class for function 'PROC_I'
 static inline struct proc_inode *PROC_I(const struct inode *inode)
                                  ^~~~~~
--
                 from ../include/linux/mmdebug.h:4,
                 from ../include/linux/mm.h:8,
                 from ../fs/proc/task_mmu.c:1:
../fs/proc/internal.h: In function 'PROC_I':
../include/linux/kernel.h:831:48: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
  const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                                                ^
../fs/proc/internal.h:77:9: note: in expansion of macro 'container_of'
  return container_of(inode, struct proc_inode, vfs_inode);
         ^~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h: In function 'page_is_young':
../fs/proc/internal.h:80:38: error: invalid storage class for function 'PDE'
 static inline struct proc_dir_entry *PDE(const struct inode *inode)
                                      ^~~
../fs/proc/internal.h:85:21: error: invalid storage class for function '__PDE_DATA'
 static inline void *__PDE_DATA(const struct inode *inode)
                     ^~~~~~~~~~
../fs/proc/internal.h:90:27: error: invalid storage class for function 'proc_pid'
 static inline struct pid *proc_pid(struct inode *inode)
                           ^~~~~~~~
../fs/proc/internal.h:95:35: error: invalid storage class for function 'get_proc_task'
 static inline struct task_struct *get_proc_task(struct inode *inode)
                                   ^~~~~~~~~~~~~
../fs/proc/internal.h: In function 'get_proc_task':
../fs/proc/internal.h:97:9: error: return from incompatible pointer type [-Werror=incompatible-pointer-types]
  return get_pid_task(proc_pid(inode), PIDTYPE_PID);
         ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h: In function 'page_is_young':
../fs/proc/internal.h:100:19: error: invalid storage class for function 'task_dumpable'
 static inline int task_dumpable(struct task_struct *task)
                   ^~~~~~~~~~~~~
../fs/proc/internal.h: In function 'task_dumpable':
../fs/proc/internal.h:105:12: error: passing argument 1 of 'task_lock' from incompatible pointer type [-Werror=incompatible-pointer-types]
  task_lock(task);
            ^~~~
In file included from ../include/linux/vmacache.h:4:0,
                 from ../fs/proc/task_mmu.c:2:
../include/linux/sched.h:2912:20: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
 static inline void task_lock(struct task_struct *p)
                    ^~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h:106:11: error: dereferencing pointer to incomplete type 'struct task_struct'
  mm = task->mm;
           ^~
../fs/proc/internal.h:109:14: error: passing argument 1 of 'task_unlock' from incompatible pointer type [-Werror=incompatible-pointer-types]
  task_unlock(task);
              ^~~~
In file included from ../include/linux/vmacache.h:4:0,
                 from ../fs/proc/task_mmu.c:2:
../include/linux/sched.h:2917:20: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
 static inline void task_unlock(struct task_struct *p)
                    ^~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h: In function 'page_is_young':
../fs/proc/internal.h:115:24: error: invalid storage class for function 'name_to_int'
 static inline unsigned name_to_int(const struct qstr *qstr)
                        ^~~~~~~~~~~
../fs/proc/internal.h:187:38: error: invalid storage class for function 'pde_get'
 static inline struct proc_dir_entry *pde_get(struct proc_dir_entry *pde)
                                      ^~~~~~~
../fs/proc/internal.h:194:20: error: invalid storage class for function 'is_empty_pde'
 static inline bool is_empty_pde(const struct proc_dir_entry *pde)
                    ^~~~~~~~~~~~
../fs/proc/task_mmu.c:24:6: error: static declaration of 'task_mem' follows non-static declaration
 void task_mem(struct seq_file *m, struct mm_struct *mm)
      ^~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h:305:13: note: previous declaration of 'task_mem' was here
 extern void task_mem(struct seq_file *, struct mm_struct *);
             ^~~~~~~~
../fs/proc/task_mmu.c:86:15: error: static declaration of 'task_vsize' follows non-static declaration
 unsigned long task_vsize(struct mm_struct *mm)
               ^~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h:301:22: note: previous declaration of 'task_vsize' was here
 extern unsigned long task_vsize(struct mm_struct *);
                      ^~~~~~~~~~
../fs/proc/task_mmu.c:91:15: error: static declaration of 'task_statm' follows non-static declaration
 unsigned long task_statm(struct mm_struct *mm,
               ^~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h:302:22: note: previous declaration of 'task_statm' was here
 extern unsigned long task_statm(struct mm_struct *,
                      ^~~~~~~~~~
../fs/proc/task_mmu.c:122:13: error: invalid storage class for function 'hold_task_mempolicy'
 static void hold_task_mempolicy(struct proc_maps_private *priv)
             ^~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:125:13: error: invalid storage class for function 'release_task_mempolicy'
 static void release_task_mempolicy(struct proc_maps_private *priv)
             ^~~~~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:130:13: error: invalid storage class for function 'vma_stop'
 static void vma_stop(struct proc_maps_private *priv)
             ^~~~~~~~
../fs/proc/task_mmu.c:140:1: error: invalid storage class for function 'm_next_vma'
 m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
 ^~~~~~~~~~
../fs/proc/task_mmu.c:147:13: error: invalid storage class for function 'm_cache_vma'
 static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
             ^~~~~~~~~~~
../fs/proc/task_mmu.c:153:14: error: invalid storage class for function 'm_start'
 static void *m_start(struct seq_file *m, loff_t *ppos)
              ^~~~~~~
../fs/proc/task_mmu.c:200:14: error: invalid storage class for function 'm_next'
 static void *m_next(struct seq_file *m, void *v, loff_t *pos)
              ^~~~~~
../fs/proc/task_mmu.c:212:13: error: invalid storage class for function 'm_stop'
 static void m_stop(struct seq_file *m, void *v)
             ^~~~~~
../fs/proc/task_mmu.c: In function 'm_stop':
../fs/proc/task_mmu.c:219:19: error: passing argument 1 of 'put_task_struct' from incompatible pointer type [-Werror=incompatible-pointer-types]
   put_task_struct(priv->task);
                   ^~~~
In file included from ../include/linux/vmacache.h:4:0,
                 from ../fs/proc/task_mmu.c:2:
../include/linux/sched.h:2135:20: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
 static inline void put_task_struct(struct task_struct *t)
                    ^~~~~~~~~~~~~~~
../fs/proc/task_mmu.c: In function 'page_is_young':
../fs/proc/task_mmu.c:224:12: error: invalid storage class for function 'proc_maps_open'
 static int proc_maps_open(struct inode *inode, struct file *file,
            ^~~~~~~~~~~~~~
../fs/proc/task_mmu.c: In function 'proc_maps_open':
../fs/proc/task_mmu.c:237:23: error: passing argument 1 of 'seq_release_private' from incompatible pointer type [-Werror=incompatible-pointer-types]
   seq_release_private(inode, file);
                       ^~~~~
In file included from ../include/linux/cgroup.h:17:0,
                 from ../include/linux/hugetlb.h:8,
                 from ../fs/proc/task_mmu.c:3:
../include/linux/seq_file.h:140:5: note: expected 'struct inode *' but argument is of type 'struct inode *'
 int seq_release_private(struct inode *, struct file *);
     ^~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c: In function 'page_is_young':
../fs/proc/task_mmu.c:244:12: error: invalid storage class for function 'proc_map_release'
 static int proc_map_release(struct inode *inode, struct file *file)
            ^~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c: In function 'proc_map_release':
../fs/proc/task_mmu.c:252:29: error: passing argument 1 of 'seq_release_private' from incompatible pointer type [-Werror=incompatible-pointer-types]
  return seq_release_private(inode, file);
                             ^~~~~
In file included from ../include/linux/cgroup.h:17:0,
                 from ../include/linux/hugetlb.h:8,
                 from ../fs/proc/task_mmu.c:3:
../include/linux/seq_file.h:140:5: note: expected 'struct inode *' but argument is of type 'struct inode *'
 int seq_release_private(struct inode *, struct file *);
     ^~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c: In function 'page_is_young':
../fs/proc/task_mmu.c:255:12: error: invalid storage class for function 'do_maps_open'
 static int do_maps_open(struct inode *inode, struct file *file,
            ^~~~~~~~~~~~
../fs/proc/task_mmu.c:266:12: error: invalid storage class for function 'is_stack'
 static int is_stack(struct proc_maps_private *priv,
            ^~~~~~~~
../fs/proc/task_mmu.c: In function 'is_stack':
../fs/proc/task_mmu.c:279:8: error: assignment from incompatible pointer type [-Werror=incompatible-pointer-types]
   task = pid_task(proc_pid(inode), PIDTYPE_PID);
        ^
../fs/proc/task_mmu.c:281:39: error: passing argument 2 of 'vma_is_stack_for_task' from incompatible pointer type [-Werror=incompatible-pointer-types]
    stack = vma_is_stack_for_task(vma, task);
                                       ^~~~
In file included from ../fs/proc/task_mmu.c:1:0:
../include/linux/mm.h:1360:5: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
 int vma_is_stack_for_task(struct vm_area_struct *vma, struct task_struct *t);
     ^~~~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c: In function 'page_is_young':
../fs/proc/task_mmu.c:288:1: error: invalid storage class for function 'show_map_vma'
 show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
 ^~~~~~~~~~~~
../fs/proc/task_mmu.c: In function 'show_map_vma':
../fs/proc/task_mmu.c:301:25: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
   struct inode *inode = file_inode(vma->vm_file);
                         ^~~~~~~~~~
../fs/proc/task_mmu.c:302:14: error: dereferencing pointer to incomplete type 'struct inode'
   dev = inode->i_sb->s_dev;
              ^~
../fs/proc/task_mmu.c: In function 'page_is_young':
../fs/proc/task_mmu.c:367:12: error: invalid storage class for function 'show_map'
 static int show_map(struct seq_file *m, void *v, int is_pid)
            ^~~~~~~~
../fs/proc/task_mmu.c:374:12: error: invalid storage class for function 'show_pid_map'
 static int show_pid_map(struct seq_file *m, void *v)
            ^~~~~~~~~~~~
../fs/proc/task_mmu.c:379:12: error: invalid storage class for function 'show_tid_map'
 static int show_tid_map(struct seq_file *m, void *v)
            ^~~~~~~~~~~~
../fs/proc/task_mmu.c:385:11: error: initializer element is not constant
  .start = m_start,
           ^~~~~~~
../fs/proc/task_mmu.c:385:11: note: (near initialization for 'proc_pid_maps_op.start')
../fs/proc/task_mmu.c:386:10: error: initializer element is not constant
  .next = m_next,
          ^~~~~~
../fs/proc/task_mmu.c:386:10: note: (near initialization for 'proc_pid_maps_op.next')
../fs/proc/task_mmu.c:387:10: error: initializer element is not constant
  .stop = m_stop,
          ^~~~~~
../fs/proc/task_mmu.c:387:10: note: (near initialization for 'proc_pid_maps_op.stop')
../fs/proc/task_mmu.c:388:10: error: initializer element is not constant
  .show = show_pid_map
          ^~~~~~~~~~~~
../fs/proc/task_mmu.c:388:10: note: (near initialization for 'proc_pid_maps_op.show')
../fs/proc/task_mmu.c:392:11: error: initializer element is not constant
  .start = m_start,
           ^~~~~~~
../fs/proc/task_mmu.c:392:11: note: (near initialization for 'proc_tid_maps_op.start')
../fs/proc/task_mmu.c:393:10: error: initializer element is not constant
  .next = m_next,
          ^~~~~~
../fs/proc/task_mmu.c:393:10: note: (near initialization for 'proc_tid_maps_op.next')
../fs/proc/task_mmu.c:394:10: error: initializer element is not constant
  .stop = m_stop,
          ^~~~~~
../fs/proc/task_mmu.c:394:10: note: (near initialization for 'proc_tid_maps_op.stop')
../fs/proc/task_mmu.c:395:10: error: initializer element is not constant
  .show = show_tid_map
          ^~~~~~~~~~~~
../fs/proc/task_mmu.c:395:10: note: (near initialization for 'proc_tid_maps_op.show')
../fs/proc/task_mmu.c:398:12: error: invalid storage class for function 'pid_maps_open'
 static int pid_maps_open(struct inode *inode, struct file *file)
            ^~~~~~~~~~~~~
../fs/proc/task_mmu.c:403:12: error: invalid storage class for function 'tid_maps_open'
 static int tid_maps_open(struct inode *inode, struct file *file)
            ^~~~~~~~~~~~~
../fs/proc/task_mmu.c:408:14: error: variable 'proc_pid_maps_operations' has initializer but incomplete type
 const struct file_operations proc_pid_maps_operations = {
              ^~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:408:30: error: declaration of 'proc_pid_maps_operations' with no linkage follows extern declaration
 const struct file_operations proc_pid_maps_operations = {
                              ^~~~~~~~~~~~~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h:292:37: note: previous declaration of 'proc_pid_maps_operations' was here
 extern const struct file_operations proc_pid_maps_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:409:2: error: unknown field 'open' specified in initializer
  .open  = pid_maps_open,
  ^
../fs/proc/task_mmu.c:409:11: warning: excess elements in struct initializer
  .open  = pid_maps_open,
           ^~~~~~~~~~~~~
../fs/proc/task_mmu.c:409:11: note: (near initialization for 'proc_pid_maps_operations')
../fs/proc/task_mmu.c:410:2: error: unknown field 'read' specified in initializer
  .read  = seq_read,
  ^
../fs/proc/task_mmu.c:410:11: warning: excess elements in struct initializer
  .read  = seq_read,
           ^~~~~~~~
../fs/proc/task_mmu.c:410:11: note: (near initialization for 'proc_pid_maps_operations')
../fs/proc/task_mmu.c:411:2: error: unknown field 'llseek' specified in initializer
  .llseek  = seq_lseek,
  ^
../fs/proc/task_mmu.c:411:13: warning: excess elements in struct initializer
  .llseek  = seq_lseek,
             ^~~~~~~~~
../fs/proc/task_mmu.c:411:13: note: (near initialization for 'proc_pid_maps_operations')
../fs/proc/task_mmu.c:412:2: error: unknown field 'release' specified in initializer
  .release = proc_map_release,
  ^
../fs/proc/task_mmu.c:412:13: warning: excess elements in struct initializer
  .release = proc_map_release,
             ^~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:412:13: note: (near initialization for 'proc_pid_maps_operations')
../fs/proc/task_mmu.c:408:30: error: storage size of 'proc_pid_maps_operations' isn't known
 const struct file_operations proc_pid_maps_operations = {
                              ^~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:415:14: error: variable 'proc_tid_maps_operations' has initializer but incomplete type
 const struct file_operations proc_tid_maps_operations = {
              ^~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:415:30: error: declaration of 'proc_tid_maps_operations' with no linkage follows extern declaration
 const struct file_operations proc_tid_maps_operations = {
                              ^~~~~~~~~~~~~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h:293:37: note: previous declaration of 'proc_tid_maps_operations' was here
 extern const struct file_operations proc_tid_maps_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:416:2: error: unknown field 'open' specified in initializer
  .open  = tid_maps_open,
  ^
../fs/proc/task_mmu.c:416:11: warning: excess elements in struct initializer
  .open  = tid_maps_open,
           ^~~~~~~~~~~~~
../fs/proc/task_mmu.c:416:11: note: (near initialization for 'proc_tid_maps_operations')
../fs/proc/task_mmu.c:417:2: error: unknown field 'read' specified in initializer
  .read  = seq_read,
  ^
../fs/proc/task_mmu.c:417:11: warning: excess elements in struct initializer
  .read  = seq_read,
           ^~~~~~~~
../fs/proc/task_mmu.c:417:11: note: (near initialization for 'proc_tid_maps_operations')
../fs/proc/task_mmu.c:418:2: error: unknown field 'llseek' specified in initializer
  .llseek  = seq_lseek,
  ^
../fs/proc/task_mmu.c:418:13: warning: excess elements in struct initializer
  .llseek  = seq_lseek,
             ^~~~~~~~~
../fs/proc/task_mmu.c:418:13: note: (near initialization for 'proc_tid_maps_operations')
../fs/proc/task_mmu.c:419:2: error: unknown field 'release' specified in initializer
  .release = proc_map_release,
  ^
../fs/proc/task_mmu.c:419:13: warning: excess elements in struct initializer
  .release = proc_map_release,
             ^~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:419:13: note: (near initialization for 'proc_tid_maps_operations')
../fs/proc/task_mmu.c:415:30: error: storage size of 'proc_tid_maps_operations' isn't known
 const struct file_operations proc_tid_maps_operations = {
                              ^~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:420:1: error: expected declaration or statement at end of input
 };
 ^
../fs/proc/task_mmu.c:415:30: warning: unused variable 'proc_tid_maps_operations' [-Wunused-variable]
 const struct file_operations proc_tid_maps_operations = {
                              ^~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/task_mmu.c:408:30: warning: unused variable 'proc_pid_maps_operations' [-Wunused-variable]
 const struct file_operations proc_pid_maps_operations = {
                              ^~~~~~~~~~~~~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:22:0:
../fs/proc/internal.h:299:37: warning: unused variable 'proc_pagemap_operations' [-Wunused-variable]
 extern const struct file_operations proc_pagemap_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:298:37: warning: unused variable 'proc_clear_refs_operations' [-Wunused-variable]
 extern const struct file_operations proc_clear_refs_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:297:37: warning: unused variable 'proc_tid_smaps_operations' [-Wunused-variable]
 extern const struct file_operations proc_tid_smaps_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:296:37: warning: unused variable 'proc_pid_smaps_operations' [-Wunused-variable]
 extern const struct file_operations proc_pid_smaps_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:295:37: warning: unused variable 'proc_tid_numa_maps_operations' [-Wunused-variable]
 extern const struct file_operations proc_tid_numa_maps_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:294:37: warning: unused variable 'proc_pid_numa_maps_operations' [-Wunused-variable]
 extern const struct file_operations proc_pid_numa_maps_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:270:30: warning: unused variable 'proc_root' [-Wunused-variable]
 extern struct proc_dir_entry proc_root;
                              ^~~~~~~~~
../fs/proc/internal.h:228:38: warning: unused variable 'proc_net_inode_operations' [-Wunused-variable]
 extern const struct inode_operations proc_net_inode_operations;
                                      ^~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:227:37: warning: unused variable 'proc_net_operations' [-Wunused-variable]
 extern const struct file_operations proc_net_operations;
                                     ^~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:222:37: warning: unused variable 'proc_ns_dir_operations' [-Wunused-variable]
 extern const struct file_operations proc_ns_dir_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:221:38: warning: unused variable 'proc_ns_dir_inode_operations' [-Wunused-variable]
 extern const struct inode_operations proc_ns_dir_inode_operations;
                                      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:211:38: warning: unused variable 'proc_pid_link_inode_operations' [-Wunused-variable]
 extern const struct inode_operations proc_pid_link_inode_operations;
                                      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:209:38: warning: unused variable 'proc_link_inode_operations' [-Wunused-variable]
 extern const struct inode_operations proc_link_inode_operations;
                                      ^~~~~~~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:162:39: warning: unused variable 'pid_dentry_operations' [-Wunused-variable]
 extern const struct dentry_operations pid_dentry_operations;
                                       ^~~~~~~~~~~~~~~~~~~~~
../fs/proc/internal.h:148:37: warning: unused variable 'proc_tid_children_operations' [-Wunused-variable]
 extern const struct file_operations proc_tid_children_operations;
                                     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~
In file included from ../fs/proc/internal.h:16:0,
                 from ../fs/proc/task_mmu.c:22:
../include/linux/binfmts.h:105:12: warning: unused variable 'suid_dumpable' [-Wunused-variable]
 extern int suid_dumpable;
            ^~~~~~~~~~~~~
In file included from ../fs/proc/internal.h:13:0,
                 from ../fs/proc/task_mmu.c:22:
../include/linux/proc_ns.h:29:40: warning: unused variable 'cgroupns_operations' [-Wunused-variable]
 extern const struct proc_ns_operations cgroupns_operations;
--
 extern const struct proc_ns_operations netns_operations;
                                        ^~~~~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:19:0:
../arch/x86/include/asm/elf.h:364:28: warning: unused variable 'va_align' [-Wunused-variable]
 extern struct va_alignment va_align;
                            ^~~~~~~~
In file included from ../arch/x86/include/asm/elf.h:94:0,
                 from ../fs/proc/task_mmu.c:19:
../arch/x86/include/asm/desc.h:40:18: warning: unused variable 'debug_idt_table' [-Wunused-variable]
 extern gate_desc debug_idt_table[];
--
 extern struct desc_ptr debug_idt_descr;
                        ^~~~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:19:0:
../arch/x86/include/asm/elf.h:82:21: warning: unused variable 'vdso32_enabled' [-Wunused-variable]
 extern unsigned int vdso32_enabled;
                     ^~~~~~~~~~~~~~
In file included from ../arch/x86/include/asm/elf.h:76:0,
                 from ../fs/proc/task_mmu.c:19:
../arch/x86/include/asm/vdso.h:39:32: warning: unused variable 'vdso_image_32' [-Wunused-variable]
 extern const struct vdso_image vdso_image_32;
                                ^~~~~~~~~~~~~
In file included from ../fs/proc/task_mmu.c:16:0:
../include/linux/page_idle.h:49:19: warning: unused variable 'page_ext' [-Wunused-variable]
  struct page_ext *page_ext = lookup_page_ext(page);
                   ^~~~~~~~
../fs/proc/task_mmu.c:420:1: warning: no return statement in function returning non-void [-Wreturn-type]
 };
 ^
At top level:
../fs/proc/task_mmu.c:91:15: warning: 'task_statm' defined but not used [-Wunused-function]
 unsigned long task_statm(struct mm_struct *mm,
               ^~~~~~~~~~
../fs/proc/task_mmu.c:86:15: warning: 'task_vsize' defined but not used [-Wunused-function]
 unsigned long task_vsize(struct mm_struct *mm)
               ^~~~~~~~~~
../fs/proc/task_mmu.c:24:6: warning: 'task_mem' defined but not used [-Wunused-function]
 void task_mem(struct seq_file *m, struct mm_struct *mm)
      ^~~~~~~~
cc1: some warnings being treated as errors
make[2]: *** [fs/proc/task_mmu.o] Error 1
make[2]: Target '__build' not remade because of errors.
make[1]: *** [fs/proc/] Error 2
make: *** [sub-make] Error 2
make[2]: *** No rule to make target 'fs/proc//task_mmu.o', needed by 'fs/proc//proc.o'.
make[2]: Target '__build' not remade because of errors.
make[1]: *** [_module_fs/proc/] Error 2
make[1]: Target '_all' not remade because of errors.
make: *** [sub-make] Error 2

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
