From: "Ollie Wild" <aaw@google.com>
Subject: Re: [patch] remove MAX_ARG_PAGES
Date: Sun, 31 Dec 2006 22:51:40 -0800
Message-ID: <65dd6fd50612312251x5d266ab3l8306236152b33585@mail.gmail.com>
References: <65dd6fd50610101705t3db93a72sc0847cd120aa05d3@mail.gmail.com>
	<1160572460.2006.79.camel@taijtu>
	<65dd6fd50610111448q7ff210e1nb5f14917c311c8d4@mail.gmail.com>
	<65dd6fd50610241048h24af39d9ob49c3816dfe1ca64@mail.gmail.com>
	<20061229200357.GA5940@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0310451956=="
Return-path: <parisc-linux-bounces@lists.parisc-linux.org>
In-Reply-To: <20061229200357.GA5940@elte.hu>
List-Unsubscribe: <http://lists.parisc-linux.org/mailman/listinfo/parisc-linux>,
	<mailto:parisc-linux-request@lists.parisc-linux.org?subject=unsubscribe>
List-Archive: <http://lists.parisc-linux.org/pipermail/parisc-linux>
List-Post: <mailto:parisc-linux@lists.parisc-linux.org>
List-Help: <mailto:parisc-linux-request@lists.parisc-linux.org?subject=help>
List-Subscribe: <http://lists.parisc-linux.org/mailman/listinfo/parisc-linux>,
	<mailto:parisc-linux-request@lists.parisc-linux.org?subject=subscribe>
Mime-version: 1.0
Sender: parisc-linux-bounces@lists.parisc-linux.org
Errors-To: parisc-linux-bounces@lists.parisc-linux.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@osdl.org>, linux-arch@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <ak@muc.de>, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, parisc-linux@lists.parisc-linux.org, Arjan van de Ven <arjan@infradead.org>
List-Id: linux-mm.kvack.org

--===============0310451956==
Content-Type: multipart/alternative;
	boundary="----=_Part_147502_21702467.1167634300468"

------=_Part_147502_21702467.1167634300468
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

There are still a couple outstanding issues which need to be resolved before
this is ready for inclusion in the mainline kernel.

The main one is support for CONFIG_STACK_GROWSUP, which I think is just
parisc.  I've been meaning to look into this for a while, but I was out of
commision for most of November so it got punted to the back burner.  I'll
try to revisit it soonish.  If someone from the parisc-linux list wants to
take a look, though, that's fine by me.

The other is support for the various executable formats.  I've tested elf
and script pretty thoroughly, but I'm not sure how to go about testing most
of the others -- does anyone use aout anymore?  Maybe the solution is just
to check it in and wait to see if someone complains.

Ollie

On 12/29/06, Ingo Molnar <mingo@elte.hu> wrote:
>
>
> FYI, i have forward ported your MAX_ARG_PAGES limit removal patch to
> 2.6.20-rc2 and have included it in the -rt kernel. It's working great -
> i can now finally do a "ls -t patches/*.patch" in my patch repository -
> something i havent been able to do for years ;-)
>
> what is keeping this fix from going upstream?
>
>         Ingo
>
> -------------->
> Subject: [patch] remove MAX_ARG_PAGES
> From: Ollie Wild <aaw@google.com>
>
> this patch removes the MAX_ARG_PAGES limit by copying between VMs. This
> makes process argv/env limited by the stack limit (and it's thus
> arbitrarily sizable). No more:
>
>   -bash: /bin/ls: Argument list too long
>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
> arch/x86_64/ia32/ia32_binfmt.c |   55 -----
> fs/binfmt_elf.c                |   12 -
> fs/binfmt_misc.c               |    4
> fs/binfmt_script.c             |    4
> fs/compat.c                    |  118 ++++--------
> fs/exec.c                      |  382
> +++++++++++++++++++----------------------
> include/linux/binfmts.h        |   14 -
> include/linux/mm.h             |    7
> kernel/auditsc.c               |    5
> mm/mprotect.c                  |    2
> mm/mremap.c                    |    2
> 11 files changed, 250 insertions(+), 355 deletions(-)
>
> Index: linux/arch/x86_64/ia32/ia32_binfmt.c
> ===================================================================
> --- linux.orig/arch/x86_64/ia32/ia32_binfmt.c
> +++ linux/arch/x86_64/ia32/ia32_binfmt.c
> @@ -279,9 +279,6 @@ do
> {                                                        \
> #define load_elf_binary load_elf32_binary
>
> #define ELF_PLAT_INIT(r, load_addr)    elf32_init(r)
> -#define setup_arg_pages(bprm, stack_top, exec_stack) \
> -       ia32_setup_arg_pages(bprm, stack_top, exec_stack)
> -int ia32_setup_arg_pages(struct linux_binprm *bprm, unsigned long
> stack_top, int executable_stack);
>
> #undef start_thread
> #define start_thread(regs,new_rip,new_rsp) do { \
> @@ -336,57 +333,7 @@ static void elf32_init(struct pt_regs *r
> int ia32_setup_arg_pages(struct linux_binprm *bprm, unsigned long
> stack_top,
>                          int executable_stack)
> {
> -       unsigned long stack_base;
> -       struct vm_area_struct *mpnt;
> -       struct mm_struct *mm = current->mm;
> -       int i, ret;
> -
> -       stack_base = stack_top - MAX_ARG_PAGES * PAGE_SIZE;
> -       mm->arg_start = bprm->p + stack_base;
> -
> -       bprm->p += stack_base;
> -       if (bprm->loader)
> -               bprm->loader += stack_base;
> -       bprm->exec += stack_base;
> -
> -       mpnt = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
> -       if (!mpnt)
> -               return -ENOMEM;
> -
> -       memset(mpnt, 0, sizeof(*mpnt));
> -
> -       down_write(&mm->mmap_sem);
> -       {
> -               mpnt->vm_mm = mm;
> -               mpnt->vm_start = PAGE_MASK & (unsigned long) bprm->p;
> -               mpnt->vm_end = stack_top;
> -               if (executable_stack == EXSTACK_ENABLE_X)
> -                       mpnt->vm_flags = VM_STACK_FLAGS |  VM_EXEC;
> -               else if (executable_stack == EXSTACK_DISABLE_X)
> -                       mpnt->vm_flags = VM_STACK_FLAGS & ~VM_EXEC;
> -               else
> -                       mpnt->vm_flags = VM_STACK_FLAGS;
> -               mpnt->vm_page_prot = (mpnt->vm_flags & VM_EXEC) ?
> -                       PAGE_COPY_EXEC : PAGE_COPY;
> -               if ((ret = insert_vm_struct(mm, mpnt))) {
> -                       up_write(&mm->mmap_sem);
> -                       kmem_cache_free(vm_area_cachep, mpnt);
> -                       return ret;
> -               }
> -               mm->stack_vm = mm->total_vm = vma_pages(mpnt);
> -       }
> -
> -       for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
> -               struct page *page = bprm->page[i];
> -               if (page) {
> -                       bprm->page[i] = NULL;
> -                       install_arg_page(mpnt, page, stack_base);
> -               }
> -               stack_base += PAGE_SIZE;
> -       }
> -       up_write(&mm->mmap_sem);
> -
> -       return 0;
> +       return setup_arg_pages(bprm, stack_top, executable_stack);
> }
> EXPORT_SYMBOL(ia32_setup_arg_pages);
>
> Index: linux/fs/binfmt_elf.c
> ===================================================================
> --- linux.orig/fs/binfmt_elf.c
> +++ linux/fs/binfmt_elf.c
> @@ -253,8 +253,8 @@ create_elf_tables(struct linux_binprm *b
>                 size_t len;
>                 if (__put_user((elf_addr_t)p, argv++))
>                         return -EFAULT;
> -               len = strnlen_user((void __user *)p,
> PAGE_SIZE*MAX_ARG_PAGES);
> -               if (!len || len > PAGE_SIZE*MAX_ARG_PAGES)
> +               len = strnlen_user((void __user *)p, MAX_ARG_STRLEN);
> +               if (!len || len > MAX_ARG_STRLEN)
>                         return 0;
>                 p += len;
>         }
> @@ -265,8 +265,8 @@ create_elf_tables(struct linux_binprm *b
>                 size_t len;
>                 if (__put_user((elf_addr_t)p, envp++))
>                         return -EFAULT;
> -               len = strnlen_user((void __user *)p,
> PAGE_SIZE*MAX_ARG_PAGES);
> -               if (!len || len > PAGE_SIZE*MAX_ARG_PAGES)
> +               len = strnlen_user((void __user *)p, MAX_ARG_STRLEN);
> +               if (!len || len > MAX_ARG_STRLEN)
>                         return 0;
>                 p += len;
>         }
> @@ -767,10 +767,6 @@ static int load_elf_binary(struct linux_
>         }
>
>         /* OK, This is the point of no return */
> -       current->mm->start_data = 0;
> -       current->mm->end_data = 0;
> -       current->mm->end_code = 0;
> -       current->mm->mmap = NULL;
>         current->flags &= ~PF_FORKNOEXEC;
>         current->mm->def_flags = def_flags;
>
> Index: linux/fs/binfmt_misc.c
> ===================================================================
> --- linux.orig/fs/binfmt_misc.c
> +++ linux/fs/binfmt_misc.c
> @@ -126,7 +126,9 @@ static int load_misc_binary(struct linux
>                 goto _ret;
>
>         if (!(fmt->flags & MISC_FMT_PRESERVE_ARGV0)) {
> -               remove_arg_zero(bprm);
> +               retval = remove_arg_zero(bprm);
> +               if (retval)
> +                       goto _ret;
>         }
>
>         if (fmt->flags & MISC_FMT_OPEN_BINARY) {
> Index: linux/fs/binfmt_script.c
> ===================================================================
> --- linux.orig/fs/binfmt_script.c
> +++ linux/fs/binfmt_script.c
> @@ -68,7 +68,9 @@ static int load_script(struct linux_binp
>          * This is done in reverse order, because of how the
>          * user environment and arguments are stored.
>          */
> -       remove_arg_zero(bprm);
> +       retval = remove_arg_zero(bprm);
> +       if (retval)
> +               return retval;
>         retval = copy_strings_kernel(1, &bprm->interp, bprm);
>         if (retval < 0) return retval;
>         bprm->argc++;
> Index: linux/fs/compat.c
> ===================================================================
> --- linux.orig/fs/compat.c
> +++ linux/fs/compat.c
> @@ -1389,6 +1389,7 @@ static int compat_copy_strings(int argc,
> {
>         struct page *kmapped_page = NULL;
>         char *kaddr = NULL;
> +       unsigned long kpos = 0;
>         int ret;
>
>         while (argc-- > 0) {
> @@ -1397,92 +1398,72 @@ static int compat_copy_strings(int argc,
>                 unsigned long pos;
>
>                 if (get_user(str, argv+argc) ||
> -                       !(len = strnlen_user(compat_ptr(str), bprm->p))) {
> +                   !(len = strnlen_user(compat_ptr(str),
> MAX_ARG_STRLEN))) {
>                         ret = -EFAULT;
>                         goto out;
>                 }
>
> -               if (bprm->p < len)  {
> +               if (MAX_ARG_STRLEN < len) {
>                         ret = -E2BIG;
>                         goto out;
>                 }
>
> -               bprm->p -= len;
> -               /* XXX: add architecture specific overflow check here. */
> +               /* We're going to work our way backwords. */
>                 pos = bprm->p;
> +               str += len;
> +               bprm->p -= len;
>
>                 while (len > 0) {
> -                       int i, new, err;
>                         int offset, bytes_to_copy;
> -                       struct page *page;
>
>                         offset = pos % PAGE_SIZE;
> -                       i = pos/PAGE_SIZE;
> -                       page = bprm->page[i];
> -                       new = 0;
> -                       if (!page) {
> -                               page = alloc_page(GFP_HIGHUSER);
> -                               bprm->page[i] = page;
> -                               if (!page) {
> -                                       ret = -ENOMEM;
> +                       if (offset == 0)
> +                               offset = PAGE_SIZE;
> +
> +                       bytes_to_copy = offset;
> +                       if (bytes_to_copy > len)
> +                               bytes_to_copy = len;
> +
> +                       offset -= bytes_to_copy;
> +                       pos -= bytes_to_copy;
> +                       str -= bytes_to_copy;
> +                       len -= bytes_to_copy;
> +
> +                       if (!kmapped_page || kpos != (pos & PAGE_MASK)) {
> +                               struct page *page;
> +
> +                               ret = get_user_pages(current, bprm->mm,
> pos,
> +                                                    1, 1, 1, &page,
> NULL);
> +                               if (ret <= 0) {
> +                                       /* We've exceed the stack rlimit.
> */
> +                                       ret = -E2BIG;
>                                         goto out;
>                                 }
> -                               new = 1;
> -                       }
>
> -                       if (page != kmapped_page) {
> -                               if (kmapped_page)
> +                               if (kmapped_page) {
>                                         kunmap(kmapped_page);
> +                                       put_page(kmapped_page);
> +                               }
>                                 kmapped_page = page;
>                                 kaddr = kmap(kmapped_page);
> +                               kpos = pos & PAGE_MASK;
>                         }
> -                       if (new && offset)
> -                               memset(kaddr, 0, offset);
> -                       bytes_to_copy = PAGE_SIZE - offset;
> -                       if (bytes_to_copy > len) {
> -                               bytes_to_copy = len;
> -                               if (new)
> -                                       memset(kaddr+offset+len, 0,
> -                                               PAGE_SIZE-offset-len);
> -                       }
> -                       err = copy_from_user(kaddr+offset,
> compat_ptr(str),
> -                                               bytes_to_copy);
> -                       if (err) {
> +                       if (copy_from_user(kaddr+offset, compat_ptr(str),
> +                                               bytes_to_copy)) {
>                                 ret = -EFAULT;
>                                 goto out;
>                         }
> -
> -                       pos += bytes_to_copy;
> -                       str += bytes_to_copy;
> -                       len -= bytes_to_copy;
>                 }
>         }
>         ret = 0;
> out:
> -       if (kmapped_page)
> +       if (kmapped_page) {
>                 kunmap(kmapped_page);
> -       return ret;
> -}
> -
> -#ifdef CONFIG_MMU
> -
> -#define free_arg_pages(bprm) do { } while (0)
> -
> -#else
> -
> -static inline void free_arg_pages(struct linux_binprm *bprm)
> -{
> -       int i;
> -
> -       for (i = 0; i < MAX_ARG_PAGES; i++) {
> -               if (bprm->page[i])
> -                       __free_page(bprm->page[i]);
> -               bprm->page[i] = NULL;
> +               put_page(kmapped_page);
>         }
> +       return ret;
> }
>
> -#endif /* CONFIG_MMU */
> -
> /*
>   * compat_do_execve() is mostly a copy of do_execve(), with the exception
>   * that it processes 32 bit argv and envp pointers.
> @@ -1495,7 +1476,6 @@ int compat_do_execve(char * filename,
>         struct linux_binprm *bprm;
>         struct file *file;
>         int retval;
> -       int i;
>
>         retval = -ENOMEM;
>         bprm = kzalloc(sizeof(*bprm), GFP_KERNEL);
> @@ -1509,24 +1489,19 @@ int compat_do_execve(char * filename,
>
>         sched_exec();
>
> -       bprm->p = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
>         bprm->file = file;
>         bprm->filename = filename;
>         bprm->interp = filename;
> -       bprm->mm = mm_alloc();
> -       retval = -ENOMEM;
> -       if (!bprm->mm)
> -               goto out_file;
>
> -       retval = init_new_context(current, bprm->mm);
> -       if (retval < 0)
> -               goto out_mm;
> +       retval = bprm_mm_init(bprm);
> +       if (retval)
> +               goto out_file;
>
> -       bprm->argc = compat_count(argv, bprm->p / sizeof(compat_uptr_t));
> +       bprm->argc = compat_count(argv, MAX_ARG_STRINGS);
>         if ((retval = bprm->argc) < 0)
>                 goto out_mm;
>
> -       bprm->envc = compat_count(envp, bprm->p / sizeof(compat_uptr_t));
> +       bprm->envc = compat_count(envp, MAX_ARG_STRINGS);
>         if ((retval = bprm->envc) < 0)
>                 goto out_mm;
>
> @@ -1551,10 +1526,8 @@ int compat_do_execve(char * filename,
>         if (retval < 0)
>                 goto out;
>
> -       retval = search_binary_handler(bprm, regs);
> +       retval = search_binary_handler(bprm,regs);
>         if (retval >= 0) {
> -               free_arg_pages(bprm);
> -
>                 /* execve success */
>                 security_bprm_free(bprm);
>                 acct_update_integrals(current);
> @@ -1563,19 +1536,12 @@ int compat_do_execve(char * filename,
>         }
>
> out:
> -       /* Something went wrong, return the inode and free the argument
> pages*/
> -       for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
> -               struct page * page = bprm->page[i];
> -               if (page)
> -                       __free_page(page);
> -       }
> -
>         if (bprm->security)
>                 security_bprm_free(bprm);
>
> out_mm:
>         if (bprm->mm)
> -               mmdrop(bprm->mm);
> +               mmput (bprm->mm);
>
> out_file:
>         if (bprm->file) {
> Index: linux/fs/exec.c
> ===================================================================
> --- linux.orig/fs/exec.c
> +++ linux/fs/exec.c
> @@ -174,6 +174,79 @@ exit:
>         goto out;
> }
>
> +#ifdef CONFIG_STACK_GROWSUP
> +#error I broke your build because I rearchitected the stack code, and I \
> +       don't have access to an architecture where CONFIG_STACK_GROWSUP is
> \
> +       set.  Please fixe this or send me a machine which I can test this
> on. \
> +       \
> +       -- Ollie Wild <aaw@google.com>
> +#endif
> +
> +/* Create a new mm_struct and populate it with a temporary stack
> + * vm_area_struct.  We don't have enough context at this point to set the
> + * stack flags, permissions, and offset, so we use temporary
> values.  We'll
> + * update them later in setup_arg_pages(). */
> +int bprm_mm_init(struct linux_binprm *bprm)
> +{
> +       int err;
> +       struct mm_struct *mm = NULL;
> +       struct vm_area_struct *vma = NULL;
> +
> +       bprm->mm = mm = mm_alloc();
> +       err = -ENOMEM;
> +       if (!mm)
> +               goto err;
> +
> +       if ((err = init_new_context(current, mm)))
> +               goto err;
> +
> +       bprm->vma = vma = kmem_cache_zalloc(vm_area_cachep, GFP_KERNEL);
> +       err = -ENOMEM;
> +       if (!vma)
> +               goto err;
> +
> +       down_write(&mm->mmap_sem);
> +       {
> +               vma->vm_mm = mm;
> +
> +               /* Place the stack at the top of user memory.  Later,
> we'll
> +                * move this to an appropriate place.  We don't use
> STACK_TOP
> +                * because that can depend on attributes which aren't
> +                * configured yet. */
> +               vma->vm_end = TASK_SIZE;
> +               vma->vm_start = vma->vm_end - PAGE_SIZE;
> +
> +               vma->vm_flags = VM_STACK_FLAGS;
> +               vma->vm_page_prot = protection_map[vma->vm_flags & 0x7];
> +               if ((err = insert_vm_struct(mm, vma))) {
> +                       up_write(&mm->mmap_sem);
> +                       goto err;
> +               }
> +
> +               mm->stack_vm = mm->total_vm = 1;
> +       }
> +       up_write(&mm->mmap_sem);
> +
> +       bprm->p = vma->vm_end - sizeof(void *);
> +
> +       return 0;
> +
> +err:
> +       if (vma) {
> +               bprm->vma = NULL;
> +               kmem_cache_free(vm_area_cachep, vma);
> +       }
> +
> +       if (mm) {
> +               bprm->mm = NULL;
> +               mmdrop(mm);
> +       }
> +
> +       return err;
> +}
> +
> +EXPORT_SYMBOL(bprm_mm_init);
> +
> /*
>   * count() counts the number of strings in array ARGV.
>   */
> @@ -199,15 +272,16 @@ static int count(char __user * __user *
> }
>
> /*
> - * 'copy_strings()' copies argument/environment strings from user
> - * memory to free pages in kernel mem. These are in a format ready
> - * to be put directly into the top of new user memory.
> + * 'copy_strings()' copies argument/environment strings from the old
> + * processes's memory to the new process's stack.  The call to
> get_user_pages()
> + * ensures the destination page is created and not swapped out.
>   */
> static int copy_strings(int argc, char __user * __user * argv,
>                         struct linux_binprm *bprm)
> {
>         struct page *kmapped_page = NULL;
>         char *kaddr = NULL;
> +       unsigned long kpos = 0;
>         int ret;
>
>         while (argc-- > 0) {
> @@ -216,69 +290,68 @@ static int copy_strings(int argc, char _
>                 unsigned long pos;
>
>                 if (get_user(str, argv+argc) ||
> -                               !(len = strnlen_user(str, bprm->p))) {
> +                               !(len = strnlen_user(str,
> MAX_ARG_STRLEN))) {
>                         ret = -EFAULT;
>                         goto out;
>                 }
>
> -               if (bprm->p < len)  {
> +               if (MAX_ARG_STRLEN < len) {
>                         ret = -E2BIG;
>                         goto out;
>                 }
>
> -               bprm->p -= len;
> -               /* XXX: add architecture specific overflow check here. */
> +               /* We're going to work our way backwords. */
>                 pos = bprm->p;
> +               str += len;
> +               bprm->p -= len;
>
>                 while (len > 0) {
> -                       int i, new, err;
>                         int offset, bytes_to_copy;
> -                       struct page *page;
>
>                         offset = pos % PAGE_SIZE;
> -                       i = pos/PAGE_SIZE;
> -                       page = bprm->page[i];
> -                       new = 0;
> -                       if (!page) {
> -                               page = alloc_page(GFP_HIGHUSER);
> -                               bprm->page[i] = page;
> -                               if (!page) {
> -                                       ret = -ENOMEM;
> +                       if (offset == 0)
> +                               offset = PAGE_SIZE;
> +
> +                       bytes_to_copy = offset;
> +                       if (bytes_to_copy > len)
> +                               bytes_to_copy = len;
> +
> +                       offset -= bytes_to_copy;
> +                       pos -= bytes_to_copy;
> +                       str -= bytes_to_copy;
> +                       len -= bytes_to_copy;
> +
> +                       if (!kmapped_page || kpos != (pos & PAGE_MASK)) {
> +                               struct page *page;
> +
> +                               ret = get_user_pages(current, bprm->mm,
> pos,
> +                                                    1, 1, 1, &page,
> NULL);
> +                               if (ret <= 0) {
> +                                       /* We've exceed the stack rlimit.
> */
> +                                       ret = -E2BIG;
>                                         goto out;
>                                 }
> -                               new = 1;
> -                       }
>
> -                       if (page != kmapped_page) {
> -                               if (kmapped_page)
> +                               if (kmapped_page) {
>                                         kunmap(kmapped_page);
> +                                       put_page(kmapped_page);
> +                               }
>                                 kmapped_page = page;
>                                 kaddr = kmap(kmapped_page);
> +                               kpos = pos & PAGE_MASK;
>                         }
> -                       if (new && offset)
> -                               memset(kaddr, 0, offset);
> -                       bytes_to_copy = PAGE_SIZE - offset;
> -                       if (bytes_to_copy > len) {
> -                               bytes_to_copy = len;
> -                               if (new)
> -                                       memset(kaddr+offset+len, 0,
> -                                               PAGE_SIZE-offset-len);
> -                       }
> -                       err = copy_from_user(kaddr+offset, str,
> bytes_to_copy);
> -                       if (err) {
> +                       if (copy_from_user(kaddr+offset, str,
> bytes_to_copy)) {
>                                 ret = -EFAULT;
>                                 goto out;
>                         }
> -
> -                       pos += bytes_to_copy;
> -                       str += bytes_to_copy;
> -                       len -= bytes_to_copy;
>                 }
>         }
>         ret = 0;
> out:
> -       if (kmapped_page)
> +       if (kmapped_page) {
>                 kunmap(kmapped_page);
> +               put_page(kmapped_page);
> +       }
>         return ret;
> }
>
> @@ -297,157 +370,79 @@ int copy_strings_kernel(int argc,char **
>
> EXPORT_SYMBOL(copy_strings_kernel);
>
> -#ifdef CONFIG_MMU
> -/*
> - * This routine is used to map in a page into an address space: needed by
> - * execve() for the initial stack and environment pages.
> - *
> - * vma->vm_mm->mmap_sem is held for writing.
> - */
> -void install_arg_page(struct vm_area_struct *vma,
> -                       struct page *page, unsigned long address)
> -{
> -       struct mm_struct *mm = vma->vm_mm;
> -       pte_t * pte;
> -       spinlock_t *ptl;
> -
> -       if (unlikely(anon_vma_prepare(vma)))
> -               goto out;
> -
> -       flush_dcache_page(page);
> -       pte = get_locked_pte(mm, address, &ptl);
> -       if (!pte)
> -               goto out;
> -       if (!pte_none(*pte)) {
> -               pte_unmap_unlock(pte, ptl);
> -               goto out;
> -       }
> -       inc_mm_counter(mm, anon_rss);
> -       lru_cache_add_active(page);
> -       set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
> -                                       page, vma->vm_page_prot))));
> -       page_add_new_anon_rmap(page, vma, address);
> -       pte_unmap_unlock(pte, ptl);
> -
> -       /* no need for flush_tlb */
> -       return;
> -out:
> -       __free_page(page);
> -       force_sig(SIGKILL, current);
> -}
> -
> #define EXTRA_STACK_VM_PAGES   20      /* random */
>
> +/* Finalizes the stack vm_area_struct.  The flags and permissions are
> updated,
> + * the stack is optionally relocated, and some extra space is added.
> + */
> int setup_arg_pages(struct linux_binprm *bprm,
>                     unsigned long stack_top,
>                     int executable_stack)
> {
> -       unsigned long stack_base;
> -       struct vm_area_struct *mpnt;
> +       unsigned long ret;
> +       unsigned long stack_base, stack_shift;
>         struct mm_struct *mm = current->mm;
> -       int i, ret;
> -       long arg_size;
>
> -#ifdef CONFIG_STACK_GROWSUP
> -       /* Move the argument and environment strings to the bottom of the
> -        * stack space.
> -        */
> -       int offset, j;
> -       char *to, *from;
> +       BUG_ON(stack_top > TASK_SIZE);
> +       BUG_ON(stack_top & ~PAGE_MASK);
>
> -       /* Start by shifting all the pages down */
> -       i = 0;
> -       for (j = 0; j < MAX_ARG_PAGES; j++) {
> -               struct page *page = bprm->page[j];
> -               if (!page)
> -                       continue;
> -               bprm->page[i++] = page;
> -       }
> -
> -       /* Now move them within their pages */
> -       offset = bprm->p % PAGE_SIZE;
> -       to = kmap(bprm->page[0]);
> -       for (j = 1; j < i; j++) {
> -               memmove(to, to + offset, PAGE_SIZE - offset);
> -               from = kmap(bprm->page[j]);
> -               memcpy(to + PAGE_SIZE - offset, from, offset);
> -               kunmap(bprm->page[j - 1]);
> -               to = from;
> -       }
> -       memmove(to, to + offset, PAGE_SIZE - offset);
> -       kunmap(bprm->page[j - 1]);
> -
> -       /* Limit stack size to 1GB */
> -       stack_base = current->signal->rlim[RLIMIT_STACK].rlim_max;
> -       if (stack_base > (1 << 30))
> -               stack_base = 1 << 30;
> -       stack_base = PAGE_ALIGN(stack_top - stack_base);
> -
> -       /* Adjust bprm->p to point to the end of the strings. */
> -       bprm->p = stack_base + PAGE_SIZE * i - offset;
> -
> -       mm->arg_start = stack_base;
> -       arg_size = i << PAGE_SHIFT;
> -
> -       /* zero pages that were copied above */
> -       while (i < MAX_ARG_PAGES)
> -               bprm->page[i++] = NULL;
> -#else
> -       stack_base = arch_align_stack(stack_top -
> MAX_ARG_PAGES*PAGE_SIZE);
> +       stack_base = arch_align_stack(stack_top - mm->stack_vm*PAGE_SIZE);
>         stack_base = PAGE_ALIGN(stack_base);
> -       bprm->p += stack_base;
> -       mm->arg_start = bprm->p;
> -       arg_size = stack_top - (PAGE_MASK & (unsigned long)
> mm->arg_start);
> -#endif
>
> -       arg_size += EXTRA_STACK_VM_PAGES * PAGE_SIZE;
> +       stack_shift = (bprm->p & PAGE_MASK) - stack_base;
> +       BUG_ON(stack_shift < 0);
> +       bprm->p -= stack_shift;
> +       mm->arg_start = bprm->p;
>
>         if (bprm->loader)
> -               bprm->loader += stack_base;
> -       bprm->exec += stack_base;
> -
> -       mpnt = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
> -       if (!mpnt)
> -               return -ENOMEM;
> -
> -       memset(mpnt, 0, sizeof(*mpnt));
> +               bprm->loader -= stack_shift;
> +       bprm->exec -= stack_shift;
>
>         down_write(&mm->mmap_sem);
>         {
> -               mpnt->vm_mm = mm;
> -#ifdef CONFIG_STACK_GROWSUP
> -               mpnt->vm_start = stack_base;
> -               mpnt->vm_end = stack_base + arg_size;
> -#else
> -               mpnt->vm_end = stack_top;
> -               mpnt->vm_start = mpnt->vm_end - arg_size;
> -#endif
> +               struct vm_area_struct *vma = bprm->vma;
> +               struct vm_area_struct *prev = NULL;
> +               unsigned long vm_flags = vma->vm_flags;
> +
>                 /* Adjust stack execute permissions; explicitly enable
>                  * for EXSTACK_ENABLE_X, disable for EXSTACK_DISABLE_X
>                  * and leave alone (arch default) otherwise. */
>                 if (unlikely(executable_stack == EXSTACK_ENABLE_X))
> -                       mpnt->vm_flags = VM_STACK_FLAGS |  VM_EXEC;
> +                       vm_flags |= VM_EXEC;
>                 else if (executable_stack == EXSTACK_DISABLE_X)
> -                       mpnt->vm_flags = VM_STACK_FLAGS & ~VM_EXEC;
> -               else
> -                       mpnt->vm_flags = VM_STACK_FLAGS;
> -               mpnt->vm_flags |= mm->def_flags;
> -               mpnt->vm_page_prot = protection_map[mpnt->vm_flags & 0x7];
> -               if ((ret = insert_vm_struct(mm, mpnt))) {
> +                       vm_flags &= ~VM_EXEC;
> +               vm_flags |= mm->def_flags;
> +
> +               ret = mprotect_fixup(vma, &prev, vma->vm_start,
> vma->vm_end,
> +                               vm_flags);
> +               if (ret) {
>                         up_write(&mm->mmap_sem);
> -                       kmem_cache_free(vm_area_cachep, mpnt);
>                         return ret;
>                 }
> -               mm->stack_vm = mm->total_vm = vma_pages(mpnt);
> -       }
> +               BUG_ON(prev != vma);
> +
> +               /* Move stack pages down in memory. */
> +               if (stack_shift) {
> +                       /* This should be safe even with overlap because
> we
> +                        * are shifting down. */
> +                       ret = move_vma(vma, vma->vm_start,
> +                                       vma->vm_end - vma->vm_start,
> +                                       vma->vm_end - vma->vm_start,
> +                                       vma->vm_start - stack_shift);
> +                       if (ret & ~PAGE_MASK) {
> +                               up_write(&mm->mmap_sem);
> +                               return ret;
> +                       }
> +               }
>
> -       for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
> -               struct page *page = bprm->page[i];
> -               if (page) {
> -                       bprm->page[i] = NULL;
> -                       install_arg_page(mpnt, page, stack_base);
> +               // Expand the stack.
> +               vma = find_vma(mm, bprm->p);
> +               BUG_ON(!vma || bprm->p < vma->vm_start);
> +               if (expand_stack(vma, stack_base -
> +                                       EXTRA_STACK_VM_PAGES * PAGE_SIZE))
> {
> +                       up_write(&mm->mmap_sem);
> +                       return -EFAULT;
>                 }
> -               stack_base += PAGE_SIZE;
>         }
>         up_write(&mm->mmap_sem);
>
> @@ -456,23 +451,6 @@ int setup_arg_pages(struct linux_binprm
>
> EXPORT_SYMBOL(setup_arg_pages);
>
> -#define free_arg_pages(bprm) do { } while (0)
> -
> -#else
> -
> -static inline void free_arg_pages(struct linux_binprm *bprm)
> -{
> -       int i;
> -
> -       for (i = 0; i < MAX_ARG_PAGES; i++) {
> -               if (bprm->page[i])
> -                       __free_page(bprm->page[i]);
> -               bprm->page[i] = NULL;
> -       }
> -}
> -
> -#endif /* CONFIG_MMU */
> -
> struct file *open_exec(const char *name)
> {
>         struct nameidata nd;
> @@ -993,8 +971,10 @@ void compute_creds(struct linux_binprm *
>
> EXPORT_SYMBOL(compute_creds);
>
> -void remove_arg_zero(struct linux_binprm *bprm)
> +int remove_arg_zero(struct linux_binprm *bprm)
> {
> +       int ret = 0;
> +
>         if (bprm->argc) {
>                 unsigned long offset;
>                 char * kaddr;
> @@ -1008,13 +988,23 @@ void remove_arg_zero(struct linux_binprm
>                                 continue;
>                         offset = 0;
>                         kunmap_atomic(kaddr, KM_USER0);
> +                       put_page(page);
> inside:
> -                       page = bprm->page[bprm->p/PAGE_SIZE];
> +                       ret = get_user_pages(current, bprm->mm, bprm->p,
> +                                            1, 0, 1, &page, NULL);
> +                       if (ret <= 0) {
> +                               ret = -EFAULT;
> +                               goto out;
> +                       }
>                         kaddr = kmap_atomic(page, KM_USER0);
>                 }
>                 kunmap_atomic(kaddr, KM_USER0);
>                 bprm->argc--;
> +               ret = 0;
>         }
> +
> +out:
> +       return ret;
> }
>
> EXPORT_SYMBOL(remove_arg_zero);
> @@ -1041,7 +1031,7 @@ int search_binary_handler(struct linux_b
>                 fput(bprm->file);
>                 bprm->file = NULL;
>
> -               loader = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
> +               loader = bprm->vma->vm_end - sizeof(void *);
>
>                 file = open_exec("/sbin/loader");
>                 retval = PTR_ERR(file);
> @@ -1134,7 +1124,6 @@ int do_execve(char * filename,
>         struct linux_binprm *bprm;
>         struct file *file;
>         int retval;
> -       int i;
>
>         retval = -ENOMEM;
>         bprm = kzalloc(sizeof(*bprm), GFP_KERNEL);
> @@ -1148,25 +1137,19 @@ int do_execve(char * filename,
>
>         sched_exec();
>
> -       bprm->p = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
> -
>         bprm->file = file;
>         bprm->filename = filename;
>         bprm->interp = filename;
> -       bprm->mm = mm_alloc();
> -       retval = -ENOMEM;
> -       if (!bprm->mm)
> -               goto out_file;
>
> -       retval = init_new_context(current, bprm->mm);
> -       if (retval < 0)
> -               goto out_mm;
> +       retval = bprm_mm_init(bprm);
> +       if (retval)
> +               goto out_file;
>
> -       bprm->argc = count(argv, bprm->p / sizeof(void *));
> +       bprm->argc = count(argv, MAX_ARG_STRINGS);
>         if ((retval = bprm->argc) < 0)
>                 goto out_mm;
>
> -       bprm->envc = count(envp, bprm->p / sizeof(void *));
> +       bprm->envc = count(envp, MAX_ARG_STRINGS);
>         if ((retval = bprm->envc) < 0)
>                 goto out_mm;
>
> @@ -1193,8 +1176,6 @@ int do_execve(char * filename,
>
>         retval = search_binary_handler(bprm,regs);
>         if (retval >= 0) {
> -               free_arg_pages(bprm);
> -
>                 /* execve success */
>                 security_bprm_free(bprm);
>                 acct_update_integrals(current);
> @@ -1203,19 +1184,12 @@ int do_execve(char * filename,
>         }
>
> out:
> -       /* Something went wrong, return the inode and free the argument
> pages*/
> -       for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
> -               struct page * page = bprm->page[i];
> -               if (page)
> -                       __free_page(page);
> -       }
> -
>         if (bprm->security)
>                 security_bprm_free(bprm);
>
> out_mm:
>         if (bprm->mm)
> -               mmdrop(bprm->mm);
> +               mmput (bprm->mm);
>
> out_file:
>         if (bprm->file) {
> Index: linux/include/linux/binfmts.h
> ===================================================================
> --- linux.orig/include/linux/binfmts.h
> +++ linux/include/linux/binfmts.h
> @@ -5,12 +5,9 @@
>
> struct pt_regs;
>
> -/*
> - * MAX_ARG_PAGES defines the number of pages allocated for arguments
> - * and envelope for the new program. 32 should suffice, this gives
> - * a maximum env+arg of 128kB w/4KB pages!
> - */
> -#define MAX_ARG_PAGES 32
> +/* FIXME: Find real limits, or none. */
> +#define MAX_ARG_STRLEN (PAGE_SIZE * 32)
> +#define MAX_ARG_STRINGS 0x7FFFFFFF
>
> /* sizeof(linux_binprm->buf) */
> #define BINPRM_BUF_SIZE 128
> @@ -22,7 +19,7 @@ struct pt_regs;
>   */
> struct linux_binprm{
>         char buf[BINPRM_BUF_SIZE];
> -       struct page *page[MAX_ARG_PAGES];
> +       struct vm_area_struct *vma;
>         struct mm_struct *mm;
>         unsigned long p; /* current top of mem */
>         int sh_bang;
> @@ -65,7 +62,7 @@ extern int register_binfmt(struct linux_
> extern int unregister_binfmt(struct linux_binfmt *);
>
> extern int prepare_binprm(struct linux_binprm *);
> -extern void remove_arg_zero(struct linux_binprm *);
> +extern int __must_check remove_arg_zero(struct linux_binprm *);
> extern int search_binary_handler(struct linux_binprm *,struct pt_regs *);
> extern int flush_old_exec(struct linux_binprm * bprm);
>
> @@ -82,6 +79,7 @@ extern int suid_dumpable;
> extern int setup_arg_pages(struct linux_binprm * bprm,
>                            unsigned long stack_top,
>                            int executable_stack);
> +extern int bprm_mm_init(struct linux_binprm *bprm);
> extern int copy_strings_kernel(int argc,char ** argv,struct linux_binprm
> *bprm);
> extern void compute_creds(struct linux_binprm *binprm);
> extern int do_coredump(long signr, int exit_code, struct pt_regs * regs);
> Index: linux/include/linux/mm.h
> ===================================================================
> --- linux.orig/include/linux/mm.h
> +++ linux/include/linux/mm.h
> @@ -775,7 +775,6 @@ static inline int handle_mm_fault(struct
>
> extern int make_pages_present(unsigned long addr, unsigned long end);
> extern int access_process_vm(struct task_struct *tsk, unsigned long addr,
> void *buf, int len, int write);
> -void install_arg_page(struct vm_area_struct *, struct page *, unsigned
> long);
>
> int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned
> long start,
>                 int len, int write, int force, struct page **pages, struct
> vm_area_struct **vmas);
> @@ -791,9 +790,15 @@ int FASTCALL(set_page_dirty(struct page
> int set_page_dirty_lock(struct page *page);
> int clear_page_dirty_for_io(struct page *page);
>
> +extern unsigned long move_vma(struct vm_area_struct *vma,
> +               unsigned long old_addr, unsigned long old_len,
> +               unsigned long new_len, unsigned long new_addr);
> extern unsigned long do_mremap(unsigned long addr,
>                                unsigned long old_len, unsigned long
> new_len,
>                                unsigned long flags, unsigned long
> new_addr);
> +extern int mprotect_fixup(struct vm_area_struct *vma,
> +                         struct vm_area_struct **pprev, unsigned long
> start,
> +                         unsigned long end, unsigned long newflags);
>
> /*
>   * Prototype to add a shrinker callback for ageable caches.
> Index: linux/kernel/auditsc.c
> ===================================================================
> --- linux.orig/kernel/auditsc.c
> +++ linux/kernel/auditsc.c
> @@ -1755,6 +1755,10 @@ int __audit_ipc_set_perm(unsigned long q
>
> int audit_bprm(struct linux_binprm *bprm)
> {
> +       /* FIXME: Don't do anything for now until I figure out how to
> handle
> +        * this.  With the latest changes, kmalloc could well fail under
> good
> +        * scenarios. */
> +#if 0
>         struct audit_aux_data_execve *ax;
>         struct audit_context *context = current->audit_context;
>         unsigned long p, next;
> @@ -1782,6 +1786,7 @@ int audit_bprm(struct linux_binprm *bprm
>         ax->d.type = AUDIT_EXECVE;
>         ax->d.next = context->aux;
>         context->aux = (void *)ax;
> +#endif
>         return 0;
> }
>
> Index: linux/mm/mprotect.c
> ===================================================================
> --- linux.orig/mm/mprotect.c
> +++ linux/mm/mprotect.c
> @@ -128,7 +128,7 @@ static void change_protection(struct vm_
>         flush_tlb_range(vma, start, end);
> }
>
> -static int
> +int
> mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>         unsigned long start, unsigned long end, unsigned long newflags)
> {
> Index: linux/mm/mremap.c
> ===================================================================
> --- linux.orig/mm/mremap.c
> +++ linux/mm/mremap.c
> @@ -155,7 +155,7 @@ static unsigned long move_page_tables(st
>         return len + old_addr - old_end;        /* how much done */
> }
>
> -static unsigned long move_vma(struct vm_area_struct *vma,
> +unsigned long move_vma(struct vm_area_struct *vma,
>                 unsigned long old_addr, unsigned long old_len,
>                 unsigned long new_len, unsigned long new_addr)
> {
>

------=_Part_147502_21702467.1167634300468
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

There are still a couple outstanding issues which need to be resolved befor=
e this is ready for inclusion in the mainline kernel.<br><br>The main one i=
s support for CONFIG_STACK_GROWSUP, which I think is just parisc.&nbsp; I&#=
39;ve been meaning to look into this for a while, but I was out of commisio=
n for most of November so it got punted to the back burner.&nbsp; I&#39;ll =
try to revisit it soonish.&nbsp; If someone from the parisc-linux list want=
s to take a look, though, that&#39;s fine by me.
<br><br>The other is support for the various executable formats.&nbsp; I&#3=
9;ve tested elf and script pretty thoroughly, but I&#39;m not sure how to g=
o about testing most of the others -- does anyone use aout anymore?&nbsp; M=
aybe the solution is just to check it in and wait to see if someone complai=
ns.
<br><br>Ollie<br><br><div><span class=3D"gmail_quote">On 12/29/06, <b class=
=3D"gmail_sendername">Ingo Molnar</b> &lt;<a href=3D"mailto:mingo@elte.hu">=
mingo@elte.hu</a>&gt; wrote:</span><blockquote class=3D"gmail_quote" style=
=3D"border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; p=
adding-left: 1ex;">
<br>FYI, i have forward ported your MAX_ARG_PAGES limit removal patch to<br=
>2.6.20-rc2 and have included it in the -rt kernel. It&#39;s working great =
-<br>i can now finally do a &quot;ls -t patches/*.patch&quot; in my patch r=
epository -
<br>something i havent been able to do for years ;-)<br><br>what is keeping=
 this fix from going upstream?<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;Ingo<br><br>--------------&gt;<br>Subject: [patch] remove MAX_AR=
G_PAGES<br>From: Ollie Wild &lt;<a href=3D"mailto:aaw@google.com">
aaw@google.com</a>&gt;<br><br>this patch removes the MAX_ARG_PAGES limit by=
 copying between VMs. This<br>makes process argv/env limited by the stack l=
imit (and it&#39;s thus<br>arbitrarily sizable). No more:<br><br>&nbsp;&nbs=
p;-bash: /bin/ls: Argument list too long
<br><br>Signed-off-by: Ingo Molnar &lt;<a href=3D"mailto:mingo@elte.hu">min=
go@elte.hu</a>&gt;<br>---<br> arch/x86_64/ia32/ia32_binfmt.c |&nbsp;&nbsp; =
55 -----<br> fs/binfmt_elf.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp; 12 -<br> fs/=
binfmt_misc.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;4
<br> fs/binfmt_script.c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;4<br> fs/compat.c&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;118 ++++--------<br> fs/exec.=
c&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;382 =
+++++++++++++++++++----------------------<br> include/linux/binfmts.h&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp; 14 -
<br> include/linux/mm.h&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;7<br> kernel/auditsc.c&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; |&nbsp;&nbsp;&nbsp;&nbsp;5<br> mm/mprotect.c&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;2<br> mm/mremap.c&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;2<br> 11 files changed, 250 inser=
tions(+), 355 deletions(-)
<br><br>Index: linux/arch/x86_64/ia32/ia32_binfmt.c<br>=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>--- linux.orig/arch/x86_64/ia32/ia32_b=
infmt.c<br>+++ linux/arch/x86_64/ia32/ia32_binfmt.c<br>@@ -279,9 +279,6 @@ =
do {&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\
<br> #define load_elf_binary load_elf32_binary<br><br> #define ELF_PLAT_INI=
T(r, load_addr)&nbsp;&nbsp;&nbsp;&nbsp;elf32_init(r)<br>-#define setup_arg_=
pages(bprm, stack_top, exec_stack) \<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; ia32_setup_arg_pages(bprm, stack_top, exec_stack)
<br>-int ia32_setup_arg_pages(struct linux_binprm *bprm, unsigned long stac=
k_top, int executable_stack);<br><br> #undef start_thread<br> #define start=
_thread(regs,new_rip,new_rsp) do { \<br>@@ -336,57 +333,7 @@ static void el=
f32_init(struct pt_regs *r
<br> int ia32_setup_arg_pages(struct linux_binprm *bprm, unsigned long stac=
k_top,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; int executable_stack)<br> {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; u=
nsigned long stack_base;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct vm=
_area_struct *mpnt;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct mm_stru=
ct *mm =3D current-&gt;mm;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int i, ret;<br>-<br>-&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; stack_base =3D stack_top - MAX_ARG_PAGES * PAGE_SI=
ZE;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mm-&gt;arg_start =3D bprm-&gt;=
p + stack_base;<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;p +=
=3D stack_base;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (bprm-&gt;loade=
r)<br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; bprm-&gt;loader +=3D stack_base;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; bprm-&gt;exec +=3D stack_base;<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; mpnt =3D kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);<br>-&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!mpnt)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return -ENOMEM;<b=
r>-<br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset(mpnt, 0, sizeof(*mpnt));<br>-<=
br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; down_write(&amp;mm-&gt;mmap_sem);<=
br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_mm =3D=
 mm;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_start =3D PAGE_MASK &amp; (unsigned long) bp=
rm-&gt;p;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; mpnt-&gt;vm_end =3D stack_top;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (executable_=
stack =3D=3D EXSTACK_ENABLE_X)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp; mpnt-&gt;vm_flags =3D VM_STACK_FLAGS |&nbsp;&nbsp;VM_EXEC=
;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; else if (executable_stack =3D=3D EXSTACK_DISABLE_X)
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_=
flags =3D VM_STACK_FLAGS &amp; ~VM_EXEC;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; else<br>-&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_flags =3D VM_STA=
CK_FLAGS;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_page_prot =3D (mpnt-&gt;vm_flags &amp; =
VM_EXEC) ?
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; PAGE_COPY_EX=
EC : PAGE_COPY;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if ((ret =3D insert_vm_struct(mm, mpnt))) {<b=
r>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; up_write(&amp;=
mm-&gt;mmap_sem);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; kmem_cache_free(vm_area_cachep, mpnt);
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return ret;<=
br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; }<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mm-&gt;stack_vm =3D mm-&gt;total_vm =3D vma_p=
ages(mpnt);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>-<br>-&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; for (i =3D 0 ; i &lt; MAX_ARG_PAGES ; i++) {<br>-=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; struct page *page =3D bprm-&gt;page[i];
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; if (page) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; bprm-&gt;page[i] =3D NULL;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; install_arg_page(mpnt, page, stack_base);<br>-&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp; }<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; stack_base +=3D PAGE_SIZE;<br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; up_write(&amp;mm-&gt;mmap_sem);<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp; return 0;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return setup_ar=
g_pages(bprm, stack_top, executable_stack);<br> }<br> EXPORT_SYMBOL(ia32_se=
tup_arg_pages);<br><br>Index: linux/fs/binfmt_elf.c
<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>--- linux.orig=
/fs/binfmt_elf.c<br>+++ linux/fs/binfmt_elf.c<br>@@ -253,8 +253,8 @@ create=
_elf_tables(struct linux_binprm *b<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;size_t len;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;if (__put_user((elf_addr_t)p, argv++))<br>&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return -EFAULT=
;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; len =3D strnlen_user((void __user *)p, PAGE_SIZE*MAX_ARG_PA=
GES);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; if (!len || len &gt; PAGE_SIZE*MAX_ARG_PAGES)
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; len =3D strnlen_user((void __user *)p, MAX_ARG_STRLEN);<br>+=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; if (!len || len &gt; MAX_ARG_STRLEN)<br>&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return 0;<br>&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;p +=3D len;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>@@ -=
265,8 +265,8 @@ create_elf_tables(struct linux_binprm *b
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;size_t len;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (__put_user=
((elf_addr_t)p, envp++))<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;return -EFAULT;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; len =3D strnlen_user((v=
oid __user *)p, PAGE_SIZE*MAX_ARG_PAGES);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!len || len &gt=
; PAGE_SIZE*MAX_ARG_PAGES)
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; len =3D strnlen_user((void __user *)p, MAX_ARG_STRLEN);<br>+=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; if (!len || len &gt; MAX_ARG_STRLEN)<br>&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return 0;<br>&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;p +=3D len;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>@@ -=
767,10 +767,6 @@ static int load_elf_binary(struct linux_
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/* OK, This is the point of no return */<=
br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; current-&gt;mm-&gt;start_data =3D =
0;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; current-&gt;mm-&gt;end_data =3D=
 0;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; current-&gt;mm-&gt;end_code =
=3D 0;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; current-&gt;mm-&gt;mmap =3D=
 NULL;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;current-&gt;flags &amp;=
=3D ~PF_FORKNOEXEC;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;curr=
ent-&gt;mm-&gt;def_flags =3D def_flags;<br><br>Index: linux/fs/binfmt_misc.=
c<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>---=20
linux.orig/fs/binfmt_misc.c<br>+++ linux/fs/binfmt_misc.c<br>@@ -126,7 +126=
,9 @@ static int load_misc_binary(struct linux<br>&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto=
 _ret;<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (!(fmt-&gt=
;flags &amp; MISC_FMT_PRESERVE_ARGV0)) {<br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; remove_arg_zero(bprm);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retval =3D remove_arg_zero(=
bprm);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; if (retval)<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; goto _ret;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;}<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (fmt-&gt=
;flags &amp; MISC_FMT_OPEN_BINARY) {
<br>Index: linux/fs/binfmt_script.c<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D<br>--- linux.orig/fs/binfmt_script.c<br>+++ linux/fs/binfmt=
_script.c<br>@@ -68,7 +68,9 @@ static int load_script(struct linux_binp
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * This is done in reve=
rse order, because of how the<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; * user environment and arguments are stored.<br>&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; */<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; re=
move_arg_zero(bprm);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retval =3D re=
move_arg_zero(bprm);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (retval)
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; return retval;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;retval =3D copy_strings_kernel(1, &amp;bprm-&gt;interp, bprm);<br>&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (retval &lt; 0) return retv=
al;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bprm-&gt;argc++;<br>=
Index: linux/fs/compat.c<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
<br>--- linux.orig/fs/compat.c<br>+++ linux/fs/compat.c<br>@@ -1389,6 +1389=
,7 @@ static int compat_copy_strings(int argc,<br> {<br>&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;struct page *kmapped_page =3D NULL;<br>&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;char *kaddr =3D NULL;<br>+&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long kpos =3D 0;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int ret;<br><br>&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;while (argc-- &gt; 0) {<br>@@ -139=
7,92 +1398,72 @@ static int compat_copy_strings(int argc,<br>&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;unsigned long pos;<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (get_user(str, arg=
v+argc) ||<br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; !(len =3D strnle=
n_user(compat_ptr(str), bprm-&gt;p))) {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; !(len =3D strnlen_user(compat_ptr(str), MAX_ARG_STRLEN))) {<br>&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ret =3D -EFAULT=
;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;g=
oto out;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (bprm-&gt;p &lt; len)&nbsp;=
&nbsp;{<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (MAX_ARG_STRLEN &lt; len) {<br>&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ret =3D -E2BIG;<br>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out;<br=
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;}
<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; bprm-&gt;p -=3D len;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* XXX: add architect=
ure specific overflow check here. */<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* We&#39;re going to wo=
rk our way backwords. */<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pos =3D bprm-&gt;p;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; str +=3D len;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;p -=3D len;<br><br>&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;while (len &gt; 0) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; int i, new, err;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int offset, bytes_to_copy;<br>-&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct page *page;
<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;offset =3D pos % PAGE_SIZE;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; i =3D pos/PAGE_SIZE;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; page =3D bprm-&gt;page[i];<br>-&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; new =3D 0;<br>-&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!page) {
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; page =3D alloc_page(GFP_HIGHUSER);<br>-=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;page[i] =3D page;<br>-&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp; if (!page) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D -ENOMEM;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (offset =
=3D=3D 0)<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; offset =3D PAGE_SIZE;<br>+<br>=
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_copy =
=3D offset;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; i=
f (bytes_to_copy &gt; len)<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_copy=
 =3D len;
<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; offset =
-=3D bytes_to_copy;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; pos -=3D bytes_to_copy;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp; str -=3D bytes_to_copy;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; len -=3D bytes_to_copy;<br>+<br>+&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!kmapped_page || kpos !=3D=
 (pos &amp; PAGE_MASK)) {
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct page *page;<br>+<br>+&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; ret =3D get_user_pages(current, bprm-&gt;mm, pos,<br>+&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;1, 1, 1, &amp;page, NULL);
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &lt;=3D 0) {<br>+&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* We&#39;=
ve exceed the stack rlimit. */<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D -E2BIG;<br>&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;go=
to out;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>-&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; new =3D 1;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; }<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; i=
f (page !=3D kmapped_page) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (kmapped=
_page)
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (kmapped_page) {<br>&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;k=
unmap(kmapped_page);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; put_page(kmapped_page);<br>+&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; }
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kmapped_page =3D page;<br>&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kaddr =3D kmap(kmapped_page);<br>+&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; kpos =3D pos &amp; PAGE_MASK;<br>&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>-&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (new &amp;&amp; offset)
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset(kaddr, 0, offset);<br>-&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_copy =3D PAGE_SIZ=
E - offset;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; i=
f (bytes_to_copy &gt; len) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_co=
py =3D len;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (new)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset(kaddr+offset+le=
n, 0,<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; PAGE_SIZE-off=
set-len);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<b=
r>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; err =3D copy_fro=
m_user(kaddr+offset, compat_ptr(str),<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; bytes_to_copy);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (err) {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; if (copy_from_user(kaddr+offset, compat_ptr(str),
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_copy)) {<=
br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ret =3D -EFAULT;<br>&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pos +=3D bytes_to_copy;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; str +=3D byt=
es_to_copy;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; l=
en -=3D bytes_to_copy;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;ret =3D 0;<br> out:<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (kmapped=
_page)<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (kmapped_page) {
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;kunmap(kmapped_page);<br>-&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; return ret;<br>-}<br>-<br>-#ifdef CONFIG_MMU<br>-<br>-#define =
free_arg_pages(bprm) do { } while (0)<br>-<br>-#else<br>-<br>-static inline=
 void free_arg_pages(struct linux_binprm *bprm)
<br>-{<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int i;<br>-<br>-&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; for (i =3D 0; i &lt; MAX_ARG_PAGES; i++) {<br>-&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; if (bprm-&gt;page[i])<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; __free_page(bprm-&gt;page[i]);<br>-&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;page=
[i] =3D NULL;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; put_page(kmapped_page);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;}<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return ret;<br> }=
<br><br>-#endif /* CONFIG_MMU */<br>-<br> /*<br>&nbsp;&nbsp;* compat_do_exe=
cve() is mostly a copy of do_execve(), with the exception<br>&nbsp;&nbsp;* =
that it processes 32 bit argv and envp pointers.
<br>@@ -1495,7 +1476,6 @@ int compat_do_execve(char * filename,<br>&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;struct linux_binprm *bprm;<br>&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;struct file *file;<br>&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int retval;<br>-&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp; int i;<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;retval =3D -ENOMEM;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;b=
prm =3D kzalloc(sizeof(*bprm), GFP_KERNEL);
<br>@@ -1509,24 +1489,19 @@ int compat_do_execve(char * filename,<br><br>&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sched_exec();<br><br>-&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;p =3D PAGE_SIZE*MAX_ARG_PAGES-sizeof=
(void *);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bprm-&gt;file =
=3D file;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bprm-&gt;filen=
ame =3D filename;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bprm-&gt;interp =3D fil=
ename;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;mm =3D mm_alloc();=
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retval =3D -ENOMEM;<br>-&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; if (!bprm-&gt;mm)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto out_file;<=
br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retval =3D init_new_context(cu=
rrent, bprm-&gt;mm);
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (retval &lt; 0)<br>-&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
goto out_mm;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retval =3D bprm_mm_in=
it(bprm);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (retval)<br>+&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; goto out_file;<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;argc=
 =3D compat_count(argv, bprm-&gt;p / sizeof(compat_uptr_t));
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;argc =3D compat_count(ar=
gv, MAX_ARG_STRINGS);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if=
 ((retval =3D bprm-&gt;argc) &lt; 0)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out_mm;<b=
r><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;envc =3D compat_count(=
envp, bprm-&gt;p / sizeof(compat_uptr_t));
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;envc =3D compat_count(en=
vp, MAX_ARG_STRINGS);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if=
 ((retval =3D bprm-&gt;envc) &lt; 0)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out_mm;<b=
r><br>@@ -1551,10 +1526,8 @@ int compat_do_execve(char * filename,<br>&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (retval &lt; 0)
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;goto out;<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; retval =3D search_binary_handler(bprm, regs);<br>+&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; retval =3D search_binary_handler(bprm,regs);<br>&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (retval &gt;=3D 0) {<br>-&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 free_arg_pages(bprm);<br>-
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;/* execve success */<br>&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;secur=
ity_bprm_free(bprm);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;acct_update_integrals(current)=
;<br>@@ -1563,19 +1536,12 @@ int compat_do_execve(char * filename,<br>&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>
 out:<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Something went wrong, ret=
urn the inode and free the argument pages*/<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; for (i =3D 0 ; i &lt; MAX_ARG_PAGES ; i++) {<br>-&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct=
 page * page =3D bprm-&gt;page[i];<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (page)
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; __free_page(=
page);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>-<br>&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (bprm-&gt;security)<br>&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;security_bprm_free(bprm);<br><br> out_mm:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;if (bprm-&gt;mm)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mmdrop(bprm-&gt;mm);
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; mmput (bprm-&gt;mm);<br><br> out_file:<br>&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (bprm-&gt;file) {<br>Index: linux/fs/exec.=
c<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br>--- linux.orig=
/fs/exec.c<br>+++ linux/fs/exec.c
<br>@@ -174,6 +174,79 @@ exit:<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;goto out;<br> }<br><br>+#ifdef CONFIG_STACK_GROWSUP<br>+#error I bro=
ke your build because I rearchitected the stack code, and I \<br>+&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; don&#39;t have access to an architecture where =
CONFIG_STACK_GROWSUP is \
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; set.&nbsp;&nbsp;Please fixe this =
or send me a machine which I can test this on. \<br>+&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; \<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; -- Ollie Wild &lt=
;<a href=3D"mailto:aaw@google.com">aaw@google.com</a>&gt;<br>+#endif<br>+<b=
r>+/* Create a new mm_struct and populate it with a temporary stack
<br>+ * vm_area_struct.&nbsp;&nbsp;We don&#39;t have enough context at this=
 point to set the<br>+ * stack flags, permissions, and offset, so we use te=
mporary values.&nbsp;&nbsp;We&#39;ll<br>+ * update them later in setup_arg_=
pages(). */<br>+int bprm_mm_init(struct linux_binprm *bprm)
<br>+{<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int err;<br>+&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; struct mm_struct *mm =3D NULL;<br>+&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; struct vm_area_struct *vma =3D NULL;<br>+<br>+&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;mm =3D mm =3D mm_alloc();<br>+&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; err =3D -ENOMEM;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; if (!mm)<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto err;
<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if ((err =3D init_new_contex=
t(current, mm)))<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto err;<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; bprm-&gt;vma =3D vma =3D kmem_cache_zalloc(vm_area_cachep, GFP_=
KERNEL);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; err =3D -ENOMEM;<br>+&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!vma)<br>
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; goto err;<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; down_wri=
te(&amp;mm-&gt;mmap_sem);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {<br>+&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; vma-&gt;vm_mm =3D mm;<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Place the stack at the =
top of user memory.&nbsp;&nbsp;Later, we&#39;ll<br>+&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* =
move this to an appropriate place.&nbsp;&nbsp;We don&#39;t use STACK_TOP
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;* because that can depend on attributes which are=
n&#39;t<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* configured yet. */<br>+&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vma-&gt=
;vm_end =3D TASK_SIZE;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vma-&gt;vm_start =3D vma-&gt;vm_end - =
PAGE_SIZE;
<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; vma-&gt;vm_flags =3D VM_STACK_FLAGS;<br>+&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vma-=
&gt;vm_page_prot =3D protection_map[vma-&gt;vm_flags &amp; 0x7];<br>+&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; if ((err =3D insert_vm_struct(mm, vma))) {<br>+&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; up_write(&amp;mm-&gt;mmap_sem);
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto err;<br=
>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; }<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mm-&gt;stack_vm =3D mm-&gt;total_vm =3D 1;=
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; up_write(&amp;mm-&gt;mmap_sem);<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; bprm-&gt;p =3D vma-&gt;vm_end - sizeof(void *);
<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return 0;<br>+<br>+err:<br>+=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (vma) {<br>+&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;vma =
=3D NULL;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; kmem_cache_free(vm_area_cachep, vma);<br>+&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 if (mm) {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;mm =3D NULL;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; mmdrop(mm);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>+<=
br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return err;<br>+}<br>+<br>+EXPORT_=
SYMBOL(bprm_mm_init);<br>+<br> /*<br>&nbsp;&nbsp;* count() counts the numbe=
r of strings in array ARGV.<br>&nbsp;&nbsp;*/<br>@@ -199,15 +272,16 @@ stat=
ic int count(char __user * __user *
<br> }<br><br> /*<br>- * &#39;copy_strings()&#39; copies argument/environme=
nt strings from user<br>- * memory to free pages in kernel mem. These are i=
n a format ready<br>- * to be put directly into the top of new user memory.
<br>+ * &#39;copy_strings()&#39; copies argument/environment strings from t=
he old<br>+ * processes&#39;s memory to the new process&#39;s stack.&nbsp;&=
nbsp;The call to get_user_pages()<br>+ * ensures the destination page is cr=
eated and not swapped out.
<br>&nbsp;&nbsp;*/<br> static int copy_strings(int argc, char __user * __us=
er * argv,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;struct linux_binprm *bprm)<br> {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;struct page *kmapped_page =3D NULL;<br>&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;char *kaddr =3D NULL;<br>+&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; unsigned long kpos =3D 0;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int ret;<br><br>&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;while (argc-- &gt; 0) {<br>@@ -216=
,69 +290,68 @@ static int copy_strings(int argc, char _<br>&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;unsigned long pos;<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (get_user(str, argv+=
argc) ||<br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; !(len =3D strnlen_user(str, bprm-&gt;p))) {=
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; !(len =3D strnlen_user(str, MAX_ARG_STR=
LEN))) {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;ret =3D -EFAULT;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;goto out;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (bprm-&gt;p &lt; len)&nbsp;=
&nbsp;{<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp; if (MAX_ARG_STRLEN &lt; len) {<br>&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ret =3D -E2BIG;<br>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out;<br=
>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;}
<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; bprm-&gt;p -=3D len;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* XXX: add architect=
ure specific overflow check here. */<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* We&#39;re going to wo=
rk our way backwords. */<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pos =3D bprm-&gt;p;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; str +=3D len;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;p -=3D len;<br><br>&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;while (len &gt; 0) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; int i, new, err;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int offset, bytes_to_copy;<br>-&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct page *page;
<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;offset =3D pos % PAGE_SIZE;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; i =3D pos/PAGE_SIZE;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; page =3D bprm-&gt;page[i];<br>-&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; new =3D 0;<br>-&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!page) {
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; page =3D alloc_page(GFP_HIGHUSER);<br>-=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;page[i] =3D page;<br>-&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp; if (!page) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D -ENOMEM;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (offset =
=3D=3D 0)<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; offset =3D PAGE_SIZE;<br>+<br>=
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_copy =
=3D offset;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; i=
f (bytes_to_copy &gt; len)<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_copy=
 =3D len;
<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; offset =
-=3D bytes_to_copy;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; pos -=3D bytes_to_copy;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp; str -=3D bytes_to_copy;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; len -=3D bytes_to_copy;<br>+<br>+&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!kmapped_page || kpos !=3D=
 (pos &amp; PAGE_MASK)) {
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct page *page;<br>+<br>+&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; ret =3D get_user_pages(current, bprm-&gt;mm, pos,<br>+&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;1, 1, 1, &amp;page, NULL);
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &lt;=3D 0) {<br>+&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* We&#39;=
ve exceed the stack rlimit. */<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D -E2BIG;<br>&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;go=
to out;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>-&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; new =3D 1;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp; }<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; i=
f (page !=3D kmapped_page) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (kmapped=
_page)
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (kmapped_page) {<br>&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;k=
unmap(kmapped_page);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; put_page(kmapped_page);<br>+&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; }
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kmapped_page =3D page;<br>&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kaddr =3D kmap(kmapped_page);<br>+&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; kpos =3D pos &amp; PAGE_MASK;<br>&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>-&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (new &amp;&amp; offset)
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset(kaddr, 0, offset);<br>-&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_copy =3D PAGE_SIZ=
E - offset;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; i=
f (bytes_to_copy &gt; len) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bytes_to_co=
py =3D len;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (new)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset(kaddr+offset+le=
n, 0,<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; PAGE_SIZE-off=
set-len);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<b=
r>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; err =3D copy_fro=
m_user(kaddr+offset, str, bytes_to_copy);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; if (err) {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; if (copy_from_user(kaddr+offset, str, bytes_to_c=
opy)) {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ret =3D -EFAULT;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out;<br>&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>-<br>-&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pos +=3D bytes_to_copy;<br>-=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; str +=3D bytes_to=
_copy;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; len -=
=3D bytes_to_copy;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ret =3D 0;<br> out:=
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (kmapped_page)<br>+&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; if (kmapped_page) {<br>&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kunma=
p(kmapped_page);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; put_page(kmapped_page);<br>+&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; }<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return ret;<br> }<br><br>@@=
 -297,157 +370,79 @@ int copy_strings_kernel(int argc,char **<br><br> EXPOR=
T_SYMBOL(copy_strings_kernel);<br><br>-#ifdef CONFIG_MMU<br>-/*<br>- * This=
 routine is used to map in a page into an address space: needed by
<br>- * execve() for the initial stack and environment pages.<br>- *<br>- *=
 vma-&gt;vm_mm-&gt;mmap_sem is held for writing.<br>- */<br>-void install_a=
rg_page(struct vm_area_struct *vma,<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; struct page *page, unsigned long address)
<br>-{<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct mm_struct *mm =3D vm=
a-&gt;vm_mm;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pte_t * pte;<br>-&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; spinlock_t *ptl;<br>-<br>-&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; if (unlikely(anon_vma_prepare(vma)))<br>-&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; got=
o out;<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; flush_dcache_page(page=
);
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pte =3D get_locked_pte(mm, addres=
s, &amp;ptl);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!pte)<br>-&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; goto out;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!pte_none(*pte))=
 {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; pte_unmap_unlock(pte, ptl);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto out;<br>-&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inc_mm_counter(mm, anon_rss);<br>=
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; lru_cache_add_active(page);<br>-&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; set_pte_at(mm, address, pte, pte_mkdirty(pt=
e_mkwrite(mk_pte(<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; page, vma-&gt;vm_page_prot))));
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; page_add_new_anon_rmap(page, vma,=
 address);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; pte_unmap_unlock(pte, p=
tl);<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* no need for flush_tlb=
 */<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return;<br>-out:<br>-&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; __free_page(page);<br>-&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; force_sig(SIGKILL, current);
<br>-}<br>-<br> #define EXTRA_STACK_VM_PAGES&nbsp;&nbsp; 20&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;/* random */<br><br>+/* Finalizes the stack vm_area_str=
uct.&nbsp;&nbsp;The flags and permissions are updated,<br>+ * the stack is =
optionally relocated, and some extra space is added.
<br>+ */<br> int setup_arg_pages(struct linux_binprm *bprm,<br>&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;unsigned long stack_top,<br>&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int executable_stack)<br> {<br>-&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; unsigned long stack_base;<br>-&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; struct vm_area_struct *mpnt;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long ret;<br>+&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long stack_base, stack_shift;<br>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;struct mm_struct *mm =3D current-=
&gt;mm;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int i, ret;<br>-&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; long arg_size;<br><br>-#ifdef CONFIG_STACK_GROWS=
UP<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Move the argument and enviro=
nment strings to the bottom of the
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* stack space.<br>-&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;*/<br>-&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; int offset, j;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; char =
*to, *from;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; BUG_ON(stack_top &gt; =
TASK_SIZE);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; BUG_ON(stack_top &amp;=
 ~PAGE_MASK);<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Start by shif=
ting all the pages down */
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; i =3D 0;<br>-&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; for (j =3D 0; j &lt; MAX_ARG_PAGES; j++) {<br>-&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; s=
truct page *page =3D bprm-&gt;page[j];<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!page)<br>-&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; continue;<br>-&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
bprm-&gt;page[i++] =3D page;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>-<br>-&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; /* Now move them within their pages */<br>-&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; offset =3D bprm-&gt;p % PAGE_SIZE;<br>-&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; to =3D kmap(bprm-&gt;page[0]);<br>-&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp; for (j =3D 1; j &lt; i; j++) {<br>-&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memmove(to, =
to + offset, PAGE_SIZE - offset);
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; from =3D kmap(bprm-&gt;page[j]);<br>-&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memcpy(to + P=
AGE_SIZE - offset, from, offset);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kunmap(bprm-&gt;page[j - 1]=
);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; to =3D from;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br=
>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memmove(to, to + offset, PAGE_SIZE -=
 offset);
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kunmap(bprm-&gt;page[j - 1]);<br>=
-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Limit stack size to 1GB */<br=
>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; stack_base =3D current-&gt;signal-&g=
t;rlim[RLIMIT_STACK].rlim_max;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if =
(stack_base &gt; (1 &lt;&lt; 30))<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; stack_base =3D 1 &lt;&lt; 3=
0;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; stack_base =3D PAGE_ALIGN(stack_t=
op - stack_base);<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Adjust b=
prm-&gt;p to point to the end of the strings. */<br>-&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; bprm-&gt;p =3D stack_base + PAGE_SIZE * i - offset;<br>-<br>=
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mm-&gt;arg_start =3D stack_base;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; arg_size =3D i &lt;&lt; PAGE_SHIF=
T;<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* zero pages that were co=
pied above */<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; while (i &lt; MAX_AR=
G_PAGES)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; bprm-&gt;page[i++] =3D NULL;<br>-#else<br>-&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; stack_base =3D arch_align_stack(stack_top - MAX=
_ARG_PAGES*PAGE_SIZE);
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; stack_base =3D arch_align_stack(s=
tack_top - mm-&gt;stack_vm*PAGE_SIZE);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;stack_base =3D PAGE_ALIGN(stack_base);<br>-&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; bprm-&gt;p +=3D stack_base;<br>-&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; mm-&gt;arg_start =3D bprm-&gt;p;<br>-&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; arg_size =3D stack_top - (PAGE_MASK &amp; (unsigned long) mm-&=
gt;arg_start);
<br>-#endif<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; arg_size +=3D EXTR=
A_STACK_VM_PAGES * PAGE_SIZE;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; stac=
k_shift =3D (bprm-&gt;p &amp; PAGE_MASK) - stack_base;<br>+&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp; BUG_ON(stack_shift &lt; 0);<br>+&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; bprm-&gt;p -=3D stack_shift;<br>
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mm-&gt;arg_start =3D bprm-&gt;p;<br><=
br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (bprm-&gt;loader)<br>=
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; bprm-&gt;loader +=3D stack_base;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; bprm-&gt;exec +=3D stack_base;<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; mpnt =3D kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!mpnt)<br>-&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return -=
ENOMEM;<br>-<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; memset(mpnt, 0, sizeo=
f(*mpnt));<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;loader -=3D stack_shift;<br>+&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;exec -=3D stack_shift;<br><br>&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;down_write(&amp;mm-&gt;mmap_sem);
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{<br>-&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&g=
t;vm_mm =3D mm;<br>-#ifdef CONFIG_STACK_GROWSUP<br>-&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_s=
tart =3D stack_base;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_end =3D stack_base + arg_siz=
e;<br>-#else<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_end =3D stack_top;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; mpnt-&gt;vm_start =3D mpnt-&gt;vm_end - arg_size;<br>-#endif=
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; struct vm_area_struct *vma =3D bprm-&gt;vma;<br>+&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; s=
truct vm_area_struct *prev =3D NULL;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long vm_flags =
=3D vma-&gt;vm_flags;
<br>+<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/* Adjust stack execute permissions; explicit=
ly enable<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * for EXSTACK_ENABLE_X, disable for EXST=
ACK_DISABLE_X<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; * and leave alone (arch default) oth=
erwise. */<br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;if (unlikely(executable_stack =3D=3D EXSTACK_ENABLE_X)=
)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm=
_flags =3D VM_STACK_FLAGS |&nbsp;&nbsp;VM_EXEC;<br>+&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vm_flags |=3D VM_EXEC;<br>&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;else if (executable_stack =3D=3D EXSTACK_DISABLE_X)
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_=
flags =3D VM_STACK_FLAGS &amp; ~VM_EXEC;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; else<br>-&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_flags =3D VM_STA=
CK_FLAGS;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; mpnt-&gt;vm_flags |=3D mm-&gt;def_flags;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; mpnt-&gt;vm_page_prot =3D protection_map[mpnt-&gt;vm_flags &=
amp; 0x7];<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp; if ((ret =3D insert_vm_struct(mm, mpnt))) {<br>+&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vm_flags &amp;=3D ~=
VM_EXEC;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp; vm_flags |=3D mm-&gt;def_flags;
<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; ret =3D mprotect_fixup(vma, &amp;prev, vma-&gt;vm_start=
, vma-&gt;vm_end,<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vm_flags);<br>+&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p; if (ret) {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;up_write(&amp;mm-&gt;mmap_sem);
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; kmem_cache_f=
ree(vm_area_cachep, mpnt);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;return ret;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>-&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 mm-&gt;stack_vm =3D mm-&gt;total_vm =3D vma_pages(mpnt);<br>-&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp; }<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; BUG_ON(prev !=3D vma);
<br>+<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; /* Move stack pages down in memory. */<br>+&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if=
 (stack_shift) {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; /* This should be safe even with overlap because we<br>+&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* are shifting down. =
*/
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D move=
_vma(vma, vma-&gt;vm_start,<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; vma-&gt;vm_end - vma-&gt;vm_start,<br>+=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; vma-&gt;vm_end - vma-&gt;vm_start,
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp; vma-&gt;vm_start - stack_shift);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &amp; ~PAGE_MASK) {<br>+&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp; up_write(&amp;mm-&gt;mmap_sem);<br>+&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp; return ret;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>+&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; }<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; for (i =3D 0 ; i &lt; MA=
X_ARG_PAGES ; i++) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct page *page =3D bprm-&gt;page[i];<=
br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp; if (page) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp; bprm-&gt;page[i] =3D NULL;
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; install_arg_=
page(mpnt, page, stack_base);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; // Expand the stack.<br>+&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp; vma =3D find_vma(mm, bprm-&gt;p);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; BUG_ON(!vma || bprm-&gt=
;p &lt; vma-&gt;vm_start);
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; if (expand_stack(vma, stack_base -<br>+&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; EXTRA_STACK_VM_PA=
GES * PAGE_SIZE)) {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; up_write(&amp;mm-&gt;mmap_sem);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp; return -EFAULT;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;}<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; stack_base +=3D PAGE_SIZE;<br>&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;up_write(&amp;mm-&gt;mmap_sem);<br><br>@@ -456,23 +45=
1,6 @@ int setup_arg_pages(struct linux_binprm<br><br> EXPORT_SYMBOL(setup_=
arg_pages);
<br><br>-#define free_arg_pages(bprm) do { } while (0)<br>-<br>-#else<br>-<=
br>-static inline void free_arg_pages(struct linux_binprm *bprm)<br>-{<br>-=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int i;<br>-<br>-&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; for (i =3D 0; i &lt; MAX_ARG_PAGES; i++) {<br>
-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; if (bprm-&gt;page[i])<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp; __free_page(bprm-&gt;page[i]);<br>-&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;p=
age[i] =3D NULL;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>-}<br>-<br>-=
#endif /* CONFIG_MMU */<br>-<br> struct file *open_exec(const char *name)
<br> {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;struct nameidata =
nd;<br>@@ -993,8 +971,10 @@ void compute_creds(struct linux_binprm *<br><br=
> EXPORT_SYMBOL(compute_creds);<br><br>-void remove_arg_zero(struct linux_b=
inprm *bprm)<br>+int remove_arg_zero(struct linux_binprm *bprm)
<br> {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int ret =3D 0;<br>+<br>&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (bprm-&gt;argc) {<br>&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;unsigned long offset;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;char * kaddr;<b=
r>@@ -1008,13 +988,23 @@ void remove_arg_zero(struct linux_binprm<br>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;continue;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;of=
fset =3D 0;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;kunmap_atomic(kaddr, KM_USER0);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp; put_page(page);<br> inside:<br>-&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; page =3D bprm-&gt;page[bprm-&gt;=
p/PAGE_SIZE];
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret =3D get_=
user_pages(current, bprm-&gt;mm, bprm-&gt;p,<br>+&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;1, 0, 1, &amp;page, NULL);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp; if (ret &lt;=3D 0) {<br>+&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp; ret =3D -EFAULT;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto out;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kaddr =3D kmap_atomic(page, KM_USER0);<br>&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;}<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;kunmap_atomic(kaddr, KM_USER0=
);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;bprm-&gt;argc--;
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; ret =3D 0;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;}<br>+<br>+out:<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return ret;<br> =
}<br><br> EXPORT_SYMBOL(remove_arg_zero);<br>@@ -1041,7 +1031,7 @@ int sear=
ch_binary_handler(struct linux_b<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;fput(bprm-&gt;file=
);
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;bprm-&gt;file =3D NULL;<br><br>-&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; loader =
=3D PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; loader =3D bprm-&=
gt;vma-&gt;vm_end - sizeof(void *);<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;file =3D op=
en_exec(&quot;/sbin/loader&quot;);
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;retval =3D PTR_ERR(file);<br>@@ -1134,7 +1124,6 @@=
 int do_execve(char * filename,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;struct linux_binprm *bprm;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;struct file *file;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;int retval;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int i;<br><br>&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retval =3D -ENOMEM;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bprm =3D kzalloc(sizeof=
(*bprm), GFP_KERNEL);<br>@@ -1148,25 +1137,19 @@ int do_execve(char * filen=
ame,<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sched_exec();<b=
r><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;p =3D PAGE_SIZE*MAX_AR=
G_PAGES-sizeof(void *);<br>-<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;bprm-&gt;file =3D file;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bprm-&gt;filename =3D f=
ilename;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;bprm-&gt;interp=
 =3D filename;<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;mm =3D mm_=
alloc();<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retval =3D -ENOMEM;<br>-&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (!bprm-&gt;mm)<br>-&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; goto ou=
t_file;<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retval =3D init_new_co=
ntext(current, bprm-&gt;mm);
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (retval &lt; 0)<br>-&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; =
goto out_mm;<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; retval =3D bprm_mm_in=
it(bprm);<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (retval)<br>+&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
; goto out_file;<br><br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;argc=
 =3D count(argv, bprm-&gt;p / sizeof(void *));
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;argc =3D count(argv, MAX=
_ARG_STRINGS);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if ((retv=
al =3D bprm-&gt;argc) &lt; 0)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out_mm;<br><br>-=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;envc =3D count(envp, bprm-&gt=
;p / sizeof(void *));<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; bprm-&gt;env=
c =3D count(envp, MAX_ARG_STRINGS);
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if ((retval =3D bprm-&g=
t;envc) &lt; 0)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;goto out_mm;<br><br>@@ -1193,8 +117=
6,6 @@ int do_execve(char * filename,<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;retval =3D search_binary_handler(bprm,regs);<br>&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (retval &gt;=3D 0) {
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; free_arg_pages(bprm);<br>-<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/* execve=
 success */<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;security_bprm_free(bprm);<br>&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;acct_update_integrals(current);<br>@@ -1203,19 +1184,12 @@ int d=
o_execve(char * filename,
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}<br><br> out:<br>-&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /* Something went wrong, return the inode =
and free the argument pages*/<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; for =
(i =3D 0 ; i &lt; MAX_ARG_PAGES ; i++) {<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct page * page =
=3D bprm-&gt;page[i];
<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; if (page)<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp; __free_page(page);<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<b=
r>-<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (bprm-&gt;securit=
y)<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;security_bprm_free(bprm);<br><br> out_mm:<br>&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (bprm-&gt;mm)<br>-&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 mmdrop(bprm-&gt;mm);
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; mmput (bprm-&gt;mm);<br><br> out_file:<br>&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (bprm-&gt;file) {<br>Index: linux/include/=
linux/binfmts.h<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D<br=
>--- linux.orig/include/linux/binfmts.h
<br>+++ linux/include/linux/binfmts.h<br>@@ -5,12 +5,9 @@<br><br> struct pt=
_regs;<br><br>-/*<br>- * MAX_ARG_PAGES defines the number of pages allocate=
d for arguments<br>- * and envelope for the new program. 32 should suffice,=
 this gives
<br>- * a maximum env+arg of 128kB w/4KB pages!<br>- */<br>-#define MAX_ARG=
_PAGES 32<br>+/* FIXME: Find real limits, or none. */<br>+#define MAX_ARG_S=
TRLEN (PAGE_SIZE * 32)<br>+#define MAX_ARG_STRINGS 0x7FFFFFFF<br><br> /* si=
zeof(linux_binprm-&gt;buf) */
<br> #define BINPRM_BUF_SIZE 128<br>@@ -22,7 +19,7 @@ struct pt_regs;<br>&n=
bsp;&nbsp;*/<br> struct linux_binprm{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;char buf[BINPRM_BUF_SIZE];<br>-&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; struct page *page[MAX_ARG_PAGES];<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp; struct vm_area_struct *vma;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;struct mm_struct *mm;<b=
r>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;unsigned long p; /* curre=
nt top of mem */<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int sh_=
bang;<br>@@ -65,7 +62,7 @@ extern int register_binfmt(struct linux_<br> ext=
ern int unregister_binfmt(struct linux_binfmt *);
<br><br> extern int prepare_binprm(struct linux_binprm *);<br>-extern void =
remove_arg_zero(struct linux_binprm *);<br>+extern int __must_check remove_=
arg_zero(struct linux_binprm *);<br> extern int search_binary_handler(struc=
t linux_binprm *,struct pt_regs *);
<br> extern int flush_old_exec(struct linux_binprm * bprm);<br><br>@@ -82,6=
 +79,7 @@ extern int suid_dumpable;<br> extern int setup_arg_pages(struct l=
inux_binprm * bprm,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long stack_top,
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp; int executable_stack);<br>+extern int bprm_mm_init(struct linux_=
binprm *bprm);<br> extern int copy_strings_kernel(int argc,char ** argv,str=
uct linux_binprm *bprm);<br> extern void compute_creds(struct linux_binprm =
*binprm);
<br> extern int do_coredump(long signr, int exit_code, struct pt_regs * reg=
s);<br>Index: linux/include/linux/mm.h<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D<br>--- linux.orig/include/linux/mm.h
<br>+++ linux/include/linux/mm.h<br>@@ -775,7 +775,6 @@ static inline int h=
andle_mm_fault(struct<br><br> extern int make_pages_present(unsigned long a=
ddr, unsigned long end);<br> extern int access_process_vm(struct task_struc=
t *tsk, unsigned long addr, void *buf, int len, int write);
<br>-void install_arg_page(struct vm_area_struct *, struct page *, unsigned=
 long);<br><br> int get_user_pages(struct task_struct *tsk, struct mm_struc=
t *mm, unsigned long start,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;int len, int write, int=
 force, struct page **pages, struct vm_area_struct **vmas);
<br>@@ -791,9 +790,15 @@ int FASTCALL(set_page_dirty(struct page<br> int se=
t_page_dirty_lock(struct page *page);<br> int clear_page_dirty_for_io(struc=
t page *page);<br><br>+extern unsigned long move_vma(struct vm_area_struct =
*vma,
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp; unsigned long old_addr, unsigned long old_len,<br>+&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
 unsigned long new_len, unsigned long new_addr);<br> extern unsigned long d=
o_mremap(unsigned long addr,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned lon=
g old_len, unsigned long new_len,
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsigned long flags, unsigned long new_a=
ddr);<br>+extern int mprotect_fixup(struct vm_area_struct *vma,<br>+&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbs=
p;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; struct vm_ar=
ea_struct **pprev, unsigned long start,<br>
+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; unsi=
gned long end, unsigned long newflags);<br><br> /*<br>&nbsp;&nbsp;* Prototy=
pe to add a shrinker callback for ageable caches.<br>Index: linux/kernel/au=
ditsc.c<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
<br>--- linux.orig/kernel/auditsc.c<br>+++ linux/kernel/auditsc.c<br>@@ -17=
55,6 +1755,10 @@ int __audit_ipc_set_perm(unsigned long q<br><br> int audit=
_bprm(struct linux_binprm *bprm)<br> {<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp; /* FIXME: Don&#39;t do anything for now until I figure out how to hand=
le
<br>+&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* this.&nbsp;&nbsp;Wit=
h the latest changes, kmalloc could well fail under good<br>+&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;* scenarios. */<br>+#if 0<br>&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;struct audit_aux_data_execve *ax;<br>&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;struct audit_context *context=
 =3D current-&gt;audit_context;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;unsigned long p, next;<=
br>@@ -1782,6 +1786,7 @@ int audit_bprm(struct linux_binprm *bprm<br>&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ax-&gt;d.type =3D AUDIT_EXECVE;<b=
r>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ax-&gt;d.next =3D context=
-&gt;aux;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;context-&gt;au=
x =3D (void *)ax;
<br>+#endif<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return 0;<br=
> }<br><br>Index: linux/mm/mprotect.c<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D<br>--- linux.orig/mm/mprotect.c<br>+++ linux/mm/mprotect=
.c<br>@@ -128,7 +128,7 @@ static void change_protection(struct vm_
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;flush_tlb_range(vma, st=
art, end);<br> }<br><br>-static int<br>+int<br> mprotect_fixup(struct vm_ar=
ea_struct *vma, struct vm_area_struct **pprev,<br>&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp;&nbsp;unsigned long start, unsigned long end, unsigned lon=
g newflags)
<br> {<br>Index: linux/mm/mremap.c<br>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D<br>--- linux.orig/mm/mremap.c<br>+++ linux/mm/mremap.c<br>@=
@ -155,7 +155,7 @@ static unsigned long move_page_tables(st
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;return len + old_addr -=
 old_end;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;/* how much done *=
/<br> }<br><br>-static unsigned long move_vma(struct vm_area_struct *vma,<b=
r>+unsigned long move_vma(struct vm_area_struct *vma,<br>&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;unsigned long old_addr, unsigned long old_len,
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;unsigned long new_len, unsigned long new_addr)<br>=
 {<br></blockquote></div><br>

------=_Part_147502_21702467.1167634300468--

--===============0310451956==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
parisc-linux mailing list
parisc-linux@lists.parisc-linux.org
http://lists.parisc-linux.org/mailman/listinfo/parisc-linux
--===============0310451956==--
