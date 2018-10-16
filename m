Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6D326B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 13:28:40 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id h76-v6so24425690pfd.10
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 10:28:40 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id o9-v6si10167028pll.325.2018.10.16.10.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 10:28:39 -0700 (PDT)
Message-ID: <124c1c2805286c70a9b2cc8e4b0abad7ef997ed4.camel@intel.com>
Subject: Re: [RFC PATCH v4 21/27] x86/cet/shstk: ELF header parsing of
 Shadow Stack
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Tue, 16 Oct 2018 10:23:43 -0700
In-Reply-To: <CAGXu5jKO5Ot5VAJBMHudgx40g4N2tqhLKHeCdS7rkFj1bPaHig@mail.gmail.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
	 <20180921150351.20898-22-yu-cheng.yu@intel.com>
	 <CAGXu5jKO5Ot5VAJBMHudgx40g4N2tqhLKHeCdS7rkFj1bPaHig@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>
Cc: X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Mon, 2018-10-15 at 16:40 -0700, Kees Cook wrote:
> On Fri, Sep 21, 2018 at 8:03 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > Look in .note.gnu.property of an ELF file and check if Shadow Stack needs
> > to be enabled for the task.

[...]

> > +/*
> > + * The .note.gnu.property layout:
> > + *
> > + *     struct elf_note {
> > + *             u32 n_namesz; --> sizeof(n_name[]); always (4)
> > + *             u32 n_ndescsz;--> sizeof(property[])
> > + *             u32 n_type;   --> always NT_GNU_PROPERTY_TYPE_0
> > + *     };
> > + *     char n_name[4]; --> always 'GNU\0'
> > + *
> > + *     struct {
> > + *             struct property_x86 {
> > + *                     u32 pr_type;
> > + *                     u32 pr_datasz;
> > + *             };
> > + *             u8 pr_data[pr_datasz];
> > + *     }[];
> > + */
> 
> Does NT_GNU_PROPERTY_TYPE_0 only ever contain property_x86 bytes? (I
> assume not, since there is a pr_type?)

There are other property types, but we only look for NT_GNU_PROPERTY_TYPE_0.

> > +
> > +#define BUF_SIZE (PAGE_SIZE / 4)
> > +
> > +struct property_x86 {
> > +       u32 pr_type;
> > +       u32 pr_datasz;
> > +};
> > +
> > +typedef bool (test_fn)(void *buf, u32 *arg);
> > +typedef void *(next_fn)(void *buf, u32 *arg);
> > +
> > +static inline bool test_note_type_0(void *buf, u32 *arg)
> > +{
> > +       struct elf_note *n = buf;
> > +
> > +       return ((n->n_namesz == 4) && (memcmp(n + 1, "GNU", 4) == 0) &&
> > +               (n->n_type == NT_GNU_PROPERTY_TYPE_0));
> 
> Cheaper to test n_type first...

Yes, Thanks!

> 
> > +}
> > +
> > +static inline void *next_note(void *buf, u32 *arg)
> > +{
> > +       struct elf_note *n = buf;
> > +       u32 align = *arg;
> > +       int size;
> > +
> > +       size = round_up(sizeof(*n) + n->n_namesz, align);
> 
> I think this could overflow: n_namesz can be u64 for elf64_note.
> 
> > +       size = round_up(size + n->n_descsz, align);
> 
> Same here. You may want to use check_add_overflow(), etc, an u64 types.

Note->n_namesz is always four-byte.  I should have used u32.

> 
> > +
> > +       if (buf + size < buf)
> > +               return NULL;
> 
> I don't understand this. You want to check size not exceeding the
> allocation, which isn't passed into this function. Checking for a full
> unsigned address wrap around is not sufficient to detect overflow.

Here we only detect the warp around.  After this returns we then check other
types of overflow in scan().

> 
> > +       else
> > +               return (buf + size);
> > +}
> > +
> > +static inline bool test_property_x86(void *buf, u32 *arg)
> > +{
> > +       struct property_x86 *pr = buf;
> > +       u32 max_type = *arg;
> > +
> > +       if (pr->pr_type > max_type)
> > +               *arg = pr->pr_type;
> 
> Why is *arg being updated? I don't see last_pr used outside of here --
> are properties required to be pr_type-ordered?

Yes, they need to be in ascending order.

> 
> > +
> > +       return (pr->pr_type == GNU_PROPERTY_X86_FEATURE_1_AND);
> > +}
> > +
> > +static inline void *next_property(void *buf, u32 *arg)
> > +{
> > +       struct property_x86 *pr = buf;
> > +       u32 max_type = *arg;
> > +
> > +       if ((buf + sizeof(*pr) +  pr->pr_datasz < buf) ||
> 
> Again, this "< buf" test doesn't look at all correct to me.
> 
> > +           (pr->pr_type > GNU_PROPERTY_X86_FEATURE_1_AND) ||
> > +           (pr->pr_type > max_type))
> > +               return NULL;
> > +       else
> > +               return (buf + sizeof(*pr) + pr->pr_datasz);
> > +}
> > +
> > +/*
> > + * Scan 'buf' for a pattern; return true if found.
> > + * *pos is the distance from the beginning of buf to where
> > + * the searched item or the next item is located.
> > + */
> > +static int scan(u8 *buf, u32 buf_size, int item_size,
> > +                test_fn test, next_fn next, u32 *arg, u32 *pos)
> 
> I'm not a fan of the short "scan", "test" and "next" names, and I
> really don't like an arg named "arg". Something slightly more
> descriptive for all of these would be nice, please.

I need to work on that :-)  What would you suggest?

> 
> > +{
> > +       int found = 0;
> > +       u8 *p, *max;
> > +
> > +       max = buf + buf_size;
> > +       if (max < buf)
> > +               return 0;
> > +
> > +       p = buf;
> > +
> > +       while ((p + item_size < max) && (p + item_size > buf)) {
> 
> These comparisons are safe due to the BUF_SIZE limit of buf_size and
> the only used size of item_size, but if this becomes more generic, it
> should be more defensive on the size calculations (e.g. make sure than
> "item_size < max" and then here "p < max - item_size", etc).
> 
> I'd kind of rather this code walked the base type and check each for
> the matching feature. What is the general specification for what
> NT_GNU_PROPERTY_TYPE_0 contains?

There are other property types, but the kernel does not look at most of them.
If the kernel needs to look at others, we need to rewrite this.

[...]

> > +
> > +/*
> > + * Search a PT_NOTE segment for the first NT_GNU_PROPERTY_TYPE_0.
> > + */
> > +static int find_note_type_0(struct file *file, unsigned long note_size,
> > +                           loff_t file_offset, u32 align, u32 *feature)
> > +{
> > +       u8 *buf;
> > +       u32 buf_pos;
> > +       unsigned long read_size;
> > +       unsigned long done;
> > +       int found = 0;
> > +       int ret = 0;
> > +
> > +       buf = kmalloc(BUF_SIZE, GFP_KERNEL);
> > +       if (!buf)
> > +               return -ENOMEM;
> 
> Why kmalloc over stack variable? (Or, does BUF_SIZE here really need
> to be 1024?)

BUF_SIZE can be smaller, for example 64.  If it is too small, we need to do
kernel_read() too often.

> 
> > +
> > +       *feature = 0;
> > +       buf_pos = 0;
> > +
> > +       for (done = 0; done < note_size; done += buf_pos) {
> > +               read_size = note_size - done;
> > +               if (read_size > BUF_SIZE)
> > +                       read_size = BUF_SIZE;
> > +
> > +               ret = kernel_read(file, buf, read_size, &file_offset);
> > +
> > +               if (ret != read_size) {
> > +                       ret = (ret < 0) ? ret : -EIO;
> > +                       kfree(buf);
> > +                       return ret;
> > +               }
> > +
> > +               /*
> > +                * item_size = sizeof(struct elf_note) + elf_note.n_namesz.
> > +                * n_namesz is 4 for the note type we look for.
> > +                */
> > +               ret = 0;
> > +               found += scan(buf, read_size, sizeof(struct elf_note) + 4,
> > +                             test_note_type_0, next_note,
> > +                             &align, &buf_pos);
> > +
> > +               file_offset += buf_pos - read_size;
> > +
> > +               if (found == 1) {
> > +                       struct elf_note *n =
> > +                               (struct elf_note *)(buf + buf_pos);
> > +                       u32 start = round_up(sizeof(*n) + n->n_namesz,
> > align);
> > +                       u32 total = round_up(start + n->n_descsz, align);
> 
> Same overflow notes from earlier...
> 
> > +
> > +                       ret = find_feature_x86(file, n->n_descsz,
> > +                                              file_offset + start,
> > +                                              buf, feature);
> > +                       file_offset += total;
> > +                       buf_pos += total;
> > +               } else if (!buf_pos) {
> > +                       *feature = 0;
> > +                       break;
> > +               }
> > +       }
> > +
> > +       kfree(buf);
> > +       return ret;
> > +}
> > +
> > +#ifdef CONFIG_COMPAT
> > +static int check_notes_32(struct file *file, struct elf32_phdr *phdr,
> > +                         int phnum, u32 *feature)
> > +{
> > +       int i;
> > +       int err = 0;
> > +
> > +       for (i = 0; i < phnum; i++, phdr++) {
> > +               if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 4))
> > +                       continue;
> > +
> > +               err = find_note_type_0(file, phdr->p_filesz, phdr->p_offset,
> > +                                      phdr->p_align, feature);
> > +               if (err)
> > +                       return err;
> > +       }
> > +
> > +       return 0;
> > +}
> > +#endif
> > +
> > +#ifdef CONFIG_X86_64
> > +static int check_notes_64(struct file *file, struct elf64_phdr *phdr,
> > +                         int phnum, u32 *feature)
> > +{
> > +       int i;
> > +       int err = 0;
> > +
> > +       for (i = 0; i < phnum; i++, phdr++) {
> > +               if ((phdr->p_type != PT_NOTE) || (phdr->p_align != 8))
> > +                       continue;
> 
> Instead of a separate parser here, wouldn't it be a bit nicer to
> attach this to the existing binfmt_elf program header parsing loop:

We need to wait until SET_PERSONALITY2() is done.

[...]

> > +int arch_setup_features(void *ehdr_p, void *phdr_p,
> > +                       struct file *file, bool interp)
> > +{
> > +       int err = 0;
> > +       u32 feature = 0;
> > +
> > +       struct elf64_hdr *ehdr64 = ehdr_p;
> > +
> > +       if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +               return 0;
> > +
> > +       if (ehdr64->e_ident[EI_CLASS] == ELFCLASS64) {
> > +               struct elf64_phdr *phdr64 = phdr_p;
> > +
> > +               err = check_notes_64(file, phdr64, ehdr64->e_phnum,
> > +                                    &feature);
> > +               if (err < 0)
> > +                       goto out;
> > +       } else {
> > +#ifdef CONFIG_COMPAT
> > +               struct elf32_hdr *ehdr32 = ehdr_p;
> > +
> > +               if (ehdr32->e_ident[EI_CLASS] == ELFCLASS32) {
> > +                       struct elf32_phdr *phdr32 = phdr_p;
> > +
> > +                       err = check_notes_32(file, phdr32, ehdr32->e_phnum,
> > +                                            &feature);
> > +                       if (err < 0)
> > +                               goto out;
> > +               }
> > +#endif
> 
> Should there be an #else error here?

Yes, thanks.

> I'd like to be using this code for a few other cases too (not just
> x86-specific). For example, for marking KASan binaries as needing a
> "legacy" memory layouts[1]. Others might be setting things like
> no_new_privs at exec time, etc.

If the item is a bit of GNU_PROPERTY_X86_FEATURE_1_AND, then this code would
work.  Has it been finalized?

Yu-cheng
