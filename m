Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAB266B0007
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 19:48:17 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id w8-v6so13623355ywa.21
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:48:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10-v6sor1787870ywc.24.2018.10.15.16.48.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 16:48:16 -0700 (PDT)
Received: from mail-yb1-f174.google.com (mail-yb1-f174.google.com. [209.85.219.174])
        by smtp.gmail.com with ESMTPSA id j8-v6sm3350865ywa.17.2018.10.15.16.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 16:48:15 -0700 (PDT)
Received: by mail-yb1-f174.google.com with SMTP id g15-v6so8199622ybf.6
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 16:48:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180921150351.20898-22-yu-cheng.yu@intel.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com> <20180921150351.20898-22-yu-cheng.yu@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Mon, 15 Oct 2018 16:40:52 -0700
Message-ID: <CAGXu5jKO5Ot5VAJBMHudgx40g4N2tqhLKHeCdS7rkFj1bPaHig@mail.gmail.com>
Subject: Re: [RFC PATCH v4 21/27] x86/cet/shstk: ELF header parsing of Shadow Stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, Andy Lutomirski <luto@amacapital.net>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 8:03 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
> to be enabled for the task.

Ah, I've been wanting this for other things too (see below).

>
> Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/Kconfig                         |   4 +
>  arch/x86/include/asm/elf.h               |   5 +
>  arch/x86/include/uapi/asm/elf_property.h |  15 +
>  arch/x86/kernel/Makefile                 |   2 +
>  arch/x86/kernel/elf.c                    | 340 +++++++++++++++++++++++
>  fs/binfmt_elf.c                          |  15 +
>  include/uapi/linux/elf.h                 |   1 +
>  7 files changed, 382 insertions(+)
>  create mode 100644 arch/x86/include/uapi/asm/elf_property.h
>  create mode 100644 arch/x86/kernel/elf.c
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 808aa3aecf3c..6377125543cc 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1919,12 +1919,16 @@ config X86_INTEL_CET
>  config ARCH_HAS_SHSTK
>         def_bool n
>
> +config ARCH_HAS_PROGRAM_PROPERTIES
> +       def_bool n
> +
>  config X86_INTEL_SHADOW_STACK_USER
>         prompt "Intel Shadow Stack for user-mode"
>         def_bool n
>         depends on CPU_SUP_INTEL && X86_64
>         select X86_INTEL_CET
>         select ARCH_HAS_SHSTK
> +       select ARCH_HAS_PROGRAM_PROPERTIES
>         ---help---
>           Shadow stack provides hardware protection against program stack
>           corruption.  Only when all the following are true will an application
> diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
> index 0d157d2a1e2a..5b5f169c5c07 100644
> --- a/arch/x86/include/asm/elf.h
> +++ b/arch/x86/include/asm/elf.h
> @@ -382,4 +382,9 @@ struct va_alignment {
>
>  extern struct va_alignment va_align;
>  extern unsigned long align_vdso_addr(unsigned long);
> +
> +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> +extern int arch_setup_features(void *ehdr, void *phdr, struct file *file,
> +                              bool interp);
> +#endif
>  #endif /* _ASM_X86_ELF_H */
> diff --git a/arch/x86/include/uapi/asm/elf_property.h b/arch/x86/include/uapi/asm/elf_property.h
> new file mode 100644
> index 000000000000..af361207718c
> --- /dev/null
> +++ b/arch/x86/include/uapi/asm/elf_property.h
> @@ -0,0 +1,15 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +#ifndef _UAPI_ASM_X86_ELF_PROPERTY_H
> +#define _UAPI_ASM_X86_ELF_PROPERTY_H
> +
> +/*
> + * pr_type
> + */
> +#define GNU_PROPERTY_X86_FEATURE_1_AND (0xc0000002)
> +
> +/*
> + * Bits for GNU_PROPERTY_X86_FEATURE_1_AND
> + */
> +#define GNU_PROPERTY_X86_FEATURE_1_SHSTK       (0x00000002)
> +
> +#endif /* _UAPI_ASM_X86_ELF_PROPERTY_H */
> diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
> index fbb2d91fb756..36b14ef410c8 100644
> --- a/arch/x86/kernel/Makefile
> +++ b/arch/x86/kernel/Makefile
> @@ -141,6 +141,8 @@ obj-$(CONFIG_UNWINDER_GUESS)                += unwind_guess.o
>
>  obj-$(CONFIG_X86_INTEL_CET)            += cet.o
>
> +obj-$(CONFIG_ARCH_HAS_PROGRAM_PROPERTIES) += elf.o
> +
>  ###
>  # 64 bit specific files
>  ifeq ($(CONFIG_X86_64),y)
> diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
> new file mode 100644
> index 000000000000..2fddd0bc545b
> --- /dev/null
> +++ b/arch/x86/kernel/elf.c
> @@ -0,0 +1,340 @@
> +/* SPDX-License-Identifier: GPL-2.0 */
> +/*
> + * Look at an ELF file's .note.gnu.property and determine if the file
> + * supports shadow stack and/or indirect branch tracking.
> + * The path from the ELF header to the note section is the following:
> + * elfhdr->elf_phdr->elf_note->property[].
> + */
> +
> +#include <asm/cet.h>
> +#include <asm/elf_property.h>
> +#include <asm/prctl.h>
> +#include <asm/processor.h>
> +#include <uapi/linux/elf-em.h>
> +#include <uapi/linux/prctl.h>
> +#include <linux/binfmts.h>
> +#include <linux/elf.h>
> +#include <linux/slab.h>
> +#include <linux/fs.h>
> +#include <linux/uaccess.h>
> +#include <linux/string.h>
> +#include <linux/compat.h>
> +
> +/*
> + * The .note.gnu.property layout:
> + *
> + *     struct elf_note {
> + *             u32 n_namesz; --> sizeof(n_name[]); always (4)
> + *             u32 n_ndescsz;--> sizeof(property[])
> + *             u32 n_type;   --> always NT_GNU_PROPERTY_TYPE_0
> + *     };
> + *     char n_name[4]; --> always 'GNU\0'
> + *
> + *     struct {
> + *             struct property_x86 {
> + *                     u32 pr_type;
> + *                     u32 pr_datasz;
> + *             };
> + *             u8 pr_data[pr_datasz];
> + *     }[];
> + */

Does NT_GNU_PROPERTY_TYPE_0 only ever contain property_x86 bytes? (I
assume not, since there is a pr_type?)

> +
> +#define BUF_SIZE (PAGE_SIZE / 4)
> +
> +struct property_x86 {
> +       u32 pr_type;
> +       u32 pr_datasz;
> +};
> +
> +typedef bool (test_fn)(void *buf, u32 *arg);
> +typedef void *(next_fn)(void *buf, u32 *arg);
> +
> +static inline bool test_note_type_0(void *buf, u32 *arg)
> +{
> +       struct elf_note *n = buf;
> +
> +       return ((n->n_namesz == 4) && (memcmp(n + 1, "GNU", 4) == 0) &&
> +               (n->n_type == NT_GNU_PROPERTY_TYPE_0));

Cheaper to test n_type first...

> +}
> +
> +static inline void *next_note(void *buf, u32 *arg)
> +{
> +       struct elf_note *n = buf;
> +       u32 align = *arg;
> +       int size;
> +
> +       size = round_up(sizeof(*n) + n->n_namesz, align);

I think this could overflow: n_namesz can be u64 for elf64_note.

> +       size = round_up(size + n->n_descsz, align);

Same here. You may want to use check_add_overflow(), etc, an u64 types.

> +
> +       if (buf + size < buf)
> +               return NULL;

I don't understand this. You want to check size not exceeding the
allocation, which isn't passed into this function. Checking for a full
unsigned address wrap around is not sufficient to detect overflow.

> +       else
> +               return (buf + size);
> +}
> +
> +static inline bool test_property_x86(void *buf, u32 *arg)
> +{
> +       struct property_x86 *pr = buf;
> +       u32 max_type = *arg;
> +
> +       if (pr->pr_type > max_type)
> +               *arg = pr->pr_type;

Why is *arg being updated? I don't see last_pr used outside of here --
are properties required to be pr_type-ordered?

> +
> +       return (pr->pr_type == GNU_PROPERTY_X86_FEATURE_1_AND);
> +}
> +
> +static inline void *next_property(void *buf, u32 *arg)
> +{
> +       struct property_x86 *pr = buf;
> +       u32 max_type = *arg;
> +
> +       if ((buf + sizeof(*pr) +  pr->pr_datasz < buf) ||

Again, this "< buf" test doesn't look at all correct to me.

> +           (pr->pr_type > GNU_PROPERTY_X86_FEATURE_1_AND) ||
> +           (pr->pr_type > max_type))
> +               return NULL;
> +       else
> +               return (buf + sizeof(*pr) + pr->pr_datasz);
> +}
> +
> +/*
> + * Scan 'buf' for a pattern; return true if found.
> + * *pos is the distance from the beginning of buf to where
> + * the searched item or the next item is located.
> + */
> +static int scan(u8 *buf, u32 buf_size, int item_size,
> +                test_fn test, next_fn next, u32 *arg, u32 *pos)

I'm not a fan of the short "scan", "test" and "next" names, and I
really don't like an arg named "arg". Something slightly more
descriptive for all of these would be nice, please.

> +{
> +       int found = 0;
> +       u8 *p, *max;
> +
> +       max = buf + buf_size;
> +       if (max < buf)
> +               return 0;
> +
> +       p = buf;
> +
> +       while ((p + item_size < max) && (p + item_size > buf)) {

These comparisons are safe due to the BUF_SIZE limit of buf_size and
the only used size of item_size, but if this becomes more generic, it
should be more defensive on the size calculations (e.g. make sure than
"item_size < max" and then here "p < max - item_size", etc).

I'd kind of rather this code walked the base type and check each for
the matching feature. What is the general specification for what
NT_GNU_PROPERTY_TYPE_0 contains?

> +               if (test(p, arg)) {
> +                       found = 1;
> +                       break;
> +               }
> +
> +               p = next(p, arg);
> +       }
> +
> +       *pos = (p + item_size <= buf) ? 0 : (u32)(p - buf);
> +       return found;
> +}
> +
> +/*
> + * Search a NT_GNU_PROPERTY_TYPE_0 for GNU_PROPERTY_X86_FEATURE_1_AND.
> + */
> +static int find_feature_x86(struct file *file, unsigned long desc_size,
> +                           loff_t file_offset, u8 *buf, u32 *feature)
> +{
> +       u32 buf_pos;
> +       unsigned long read_size;
> +       unsigned long done;
> +       int found = 0;
> +       int ret = 0;
> +       u32 last_pr = 0;
> +
> +       *feature = 0;
> +       buf_pos = 0;
> +
> +       for (done = 0; done < desc_size; done += buf_pos) {
> +               read_size = desc_size - done;
> +               if (read_size > BUF_SIZE)
> +                       read_size = BUF_SIZE;
> +
> +               ret = kernel_read(file, buf, read_size, &file_offset);
> +
> +               if (ret != read_size)
> +                       return (ret < 0) ? ret : -EIO;
> +
> +               ret = 0;
> +               found = scan(buf, read_size, sizeof(struct property_x86),
> +                            test_property_x86, next_property,
> +                            &last_pr, &buf_pos);
> +
> +               if ((!buf_pos) || found)
> +                       break;
> +
> +               file_offset += buf_pos - read_size;
> +       }
> +
> +       if (found) {
> +               struct property_x86 *pr =
> +                       (struct property_x86 *)(buf + buf_pos);
> +
> +               if (pr->pr_datasz == 4) {
> +                       u32 *max =  (u32 *)(buf + read_size);
> +                       u32 *data = (u32 *)((u8 *)pr + sizeof(*pr));
> +
> +                       if (data + 1 <= max) {
> +                               *feature = *data;
> +                       } else {
> +                               file_offset += buf_pos - read_size;
> +                               file_offset += sizeof(*pr);
> +                               ret = kernel_read(file, feature, 4,
> +                                                 &file_offset);
> +                       }
> +               }
> +       }
> +
> +       return ret;
> +}
> +
> +/*
> + * Search a PT_NOTE segment for the first NT_GNU_PROPERTY_TYPE_0.
> + */
> +static int find_note_type_0(struct file *file, unsigned long note_size,
> +                           loff_t file_offset, u32 align, u32 *feature)
> +{
> +       u8 *buf;
> +       u32 buf_pos;
> +       unsigned long read_size;
> +       unsigned long done;
> +       int found = 0;
> +       int ret = 0;
> +
> +       buf = kmalloc(BUF_SIZE, GFP_KERNEL);
> +       if (!buf)
> +               return -ENOMEM;

Why kmalloc over stack variable? (Or, does BUF_SIZE here really need
to be 1024?)

> +
> +       *feature = 0;
> +       buf_pos = 0;
> +
> +       for (done = 0; done < note_size; done += buf_pos) {
> +               read_size = note_size - done;
> +               if (read_size > BUF_SIZE)
> +                       read_size = BUF_SIZE;
> +
> +               ret = kernel_read(file, buf, read_size, &file_offset);
> +
> +               if (ret != read_size) {
> +                       ret = (ret < 0) ? ret : -EIO;
> +                       kfree(buf);
> +                       return ret;
> +               }
> +
> +               /*
> +                * item_size = sizeof(struct elf_note) + elf_note.n_namesz.
> +                * n_namesz is 4 for the note type we look for.
> +                */
> +               ret = 0;
> +               found += scan(buf, read_size, sizeof(struct elf_note) + 4,
> +                             test_note_type_0, next_note,
> +                             &align, &buf_pos);
> +
> +               file_offset += buf_pos - read_size;
> +
> +               if (found == 1) {
> +                       struct elf_note *n =
> +                               (struct elf_note *)(buf + buf_pos);
> +                       u32 start = round_up(sizeof(*n) + n->n_namesz, align);
> +                       u32 total = round_up(start + n->n_descsz, align);

Same overflow notes from earlier...

> +
> +                       ret = find_feature_x86(file, n->n_descsz,
> +                                              file_offset + start,
> +                                              buf, feature);
> +                       file_offset += total;
> +                       buf_pos += total;
> +               } else if (!buf_pos) {
> +                       *feature = 0;
> +                       break;
> +               }
> +       }
> +
> +       kfree(buf);
> +       return ret;
> +}
> +
> +#ifdef CONFIG_COMPAT
> +static int check_notes_32(struct file *file, struct elf32_phdr *phdr,
> +                         int phnum, u32 *feature)
> +{
> +       int i;
> +       int err = 0;
> +
> +       for (i = 0; i < phnum; i++, phdr++) {
> +               if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 4))
> +                       continue;
> +
> +               err = find_note_type_0(file, phdr->p_filesz, phdr->p_offset,
> +                                      phdr->p_align, feature);
> +               if (err)
> +                       return err;
> +       }
> +
> +       return 0;
> +}
> +#endif
> +
> +#ifdef CONFIG_X86_64
> +static int check_notes_64(struct file *file, struct elf64_phdr *phdr,
> +                         int phnum, u32 *feature)
> +{
> +       int i;
> +       int err = 0;
> +
> +       for (i = 0; i < phnum; i++, phdr++) {
> +               if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 8))
> +                       continue;

Instead of a separate parser here, wouldn't it be a bit nicer to
attach this to the existing binfmt_elf program header parsing loop:

        elf_ppnt = elf_phdata;
        for (i = 0; i < loc->elf_ex.e_phnum; i++, elf_ppnt++)
                switch (elf_ppnt->p_type) {
                case PT_GNU_STACK:
...
                case PT_LOPROC ... PT_HIPROC:
...


> +
> +               err = find_note_type_0(file, phdr->p_filesz, phdr->p_offset,
> +                                      phdr->p_align, feature);
> +               if (err)
> +                       return err;
> +       }
> +
> +       return 0;
> +}
> +#endif
> +
> +int arch_setup_features(void *ehdr_p, void *phdr_p,
> +                       struct file *file, bool interp)
> +{
> +       int err = 0;
> +       u32 feature = 0;
> +
> +       struct elf64_hdr *ehdr64 = ehdr_p;
> +
> +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> +               return 0;
> +
> +       if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
> +               struct elf64_phdr *phdr64 = phdr_p;
> +
> +               err = check_notes_64(file, phdr64, ehdr64->e_phnum,
> +                                    &feature);
> +               if (err < 0)
> +                       goto out;
> +       } else {
> +#ifdef CONFIG_COMPAT
> +               struct elf32_hdr *ehdr32 = ehdr_p;
> +
> +               if (ehdr32->e_ident[EI_CLASS] == ELFCLASS32) {
> +                       struct elf32_phdr *phdr32 = phdr_p;
> +
> +                       err = check_notes_32(file, phdr32, ehdr32->e_phnum,
> +                                            &feature);
> +                       if (err < 0)
> +                               goto out;
> +               }
> +#endif

Should there be an #else error here?

> +       }
> +
> +       memset(&current->thread.cet, 0, sizeof(struct cet_status));
> +
> +       if (cpu_feature_enabled(X86_FEATURE_SHSTK)) {

The CPU feature was already tested at arch_setup_features() entry.

> +               if (feature & GNU_PROPERTY_X86_FEATURE_1_SHSTK) {
> +                       err = cet_setup_shstk();
> +                       if (err < 0)
> +                               goto out;
> +               }
> +       }
> +
> +out:
> +       return err;
> +}
> diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> index efae2fb0930a..b891aa292b46 100644
> --- a/fs/binfmt_elf.c
> +++ b/fs/binfmt_elf.c
> @@ -1081,6 +1081,21 @@ static int load_elf_binary(struct linux_binprm *bprm)
>                 goto out_free_dentry;
>         }
>
> +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> +       if (interpreter) {
> +               retval = arch_setup_features(&loc->interp_elf_ex,
> +                                            interp_elf_phdata,
> +                                            interpreter, true);
> +       } else {
> +               retval = arch_setup_features(&loc->elf_ex,
> +                                            elf_phdata,
> +                                            bprm->file, false);
> +       }
> +
> +       if (retval < 0)
> +               goto out_free_dentry;
> +#endif
> +
>         if (elf_interpreter) {
>                 unsigned long interp_map_addr = 0;
>
> diff --git a/include/uapi/linux/elf.h b/include/uapi/linux/elf.h
> index c5358e0ae7c5..5ef25a565e88 100644
> --- a/include/uapi/linux/elf.h
> +++ b/include/uapi/linux/elf.h
> @@ -372,6 +372,7 @@ typedef struct elf64_shdr {
>  #define NT_PRFPREG     2
>  #define NT_PRPSINFO    3
>  #define NT_TASKSTRUCT  4
> +#define NT_GNU_PROPERTY_TYPE_0 5
>  #define NT_AUXV                6
>  /*
>   * Note to userspace developers: size of NT_SIGINFO note may increase
> --
> 2.17.1
>

I'd like to be using this code for a few other cases too (not just
x86-specific). For example, for marking KASan binaries as needing a
"legacy" memory layouts[1]. Others might be setting things like
no_new_privs at exec time, etc.

-Kees

[1] https://lkml.kernel.org/r/CAGXu5jL1HRG7Dn9vraw8Hu7LF+69k3EDpztt1Ju7ijEzmvRdhA@mail.gmail.com

-- 
Kees Cook
Pixel Security
