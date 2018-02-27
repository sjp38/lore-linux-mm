Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9BD6B0003
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 15:52:33 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id t134so120630vke.0
        for <linux-mm@kvack.org>; Tue, 27 Feb 2018 12:52:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h69sor12031vkf.189.2018.02.27.12.52.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Feb 2018 12:52:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180227131338.3699-1-blackzert@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 27 Feb 2018 12:52:29 -0800
Message-ID: <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Tue, Feb 27, 2018 at 5:13 AM, Ilya Smith <blackzert@gmail.com> wrote:
> This is more proof of concept. Current implementation doesn't randomize
> address returned by mmap. All the entropy ends with choosing mmap_base_ad=
dr
> at the process creation. After that mmap build very predictable layout
> of address space. It allows to bypass ASLR in many cases.

I'd like more details on the threat model here; if it's just a matter
of .so loading order, I wonder if load order randomization would get a
comparable level of uncertainty without the memory fragmentation,
like:
https://android-review.googlesource.com/c/platform/bionic/+/178130/2
If glibc, for example, could do this too, it would go a long way to
improving things. Obviously, it's not as extreme as loading stuff all
over the place, but it seems like the effect for an attack would be
similar. The search _area_ remains small, but the ordering wouldn't be
deterministic any more.

> This patch make randomization of address on any mmap call.
> It works good on 64 bit system, but usage under 32 bit systems is not
> recommended. This approach uses current implementation to simplify search
> of address.

It would be worth spelling out the "not recommended" bit some more
too: this fragments the mmap space, which has some serious issues on
smaller address spaces if you get into a situation where you cannot
allocate a hole large enough between the other allocations.

>
> Here I would like to discuss this approach.
>
> Signed-off-by: Ilya Smith <blackzert@gmail.com>
> ---
>  include/linux/mm.h |   4 ++
>  mm/mmap.c          | 171 +++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  2 files changed, 175 insertions(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ad06d42adb1a..f81b6c8a0bc5 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -25,6 +25,7 @@
>  #include <linux/err.h>
>  #include <linux/page_ref.h>
>  #include <linux/memremap.h>
> +#include <linux/sched.h>
>
>  struct mempolicy;
>  struct anon_vma;
> @@ -2253,6 +2254,7 @@ struct vm_unmapped_area_info {
>         unsigned long align_offset;
>  };
>
> +extern unsigned long unmapped_area_random(struct vm_unmapped_area_info *=
info);
>  extern unsigned long unmapped_area(struct vm_unmapped_area_info *info);
>  extern unsigned long unmapped_area_topdown(struct vm_unmapped_area_info =
*info);
>
> @@ -2268,6 +2270,8 @@ extern unsigned long unmapped_area_topdown(struct v=
m_unmapped_area_info *info);
>  static inline unsigned long
>  vm_unmapped_area(struct vm_unmapped_area_info *info)
>  {
> +       if (current->flags & PF_RANDOMIZE)
> +               return unmapped_area_random(info);

I think this will need a larger knob -- doing this by default is
likely to break stuff, I'd imagine? Bikeshedding: I'm not sure if this
should be setting "3" for /proc/sys/kernel/randomize_va_space, or a
separate one like /proc/sys/mm/randomize_mmap_allocation.

>         if (info->flags & VM_UNMAPPED_AREA_TOPDOWN)
>                 return unmapped_area_topdown(info);
>         else
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 9efdc021ad22..58110e065417 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -45,6 +45,7 @@
>  #include <linux/moduleparam.h>
>  #include <linux/pkeys.h>
>  #include <linux/oom.h>
> +#include <linux/random.h>
>
>  #include <linux/uaccess.h>
>  #include <asm/cacheflush.h>
> @@ -1780,6 +1781,176 @@ unsigned long mmap_region(struct file *file, unsi=
gned long addr,
>         return error;
>  }
>
> +unsigned long unmapped_area_random(struct vm_unmapped_area_info *info)
> +{
> +       // first lets find right border with unmapped_area_topdown

Nit: kernel comments are /* */. (It's a good idea to run patches
through scripts/checkpatch.pl first.)

> +       struct mm_struct *mm =3D current->mm;
> +       struct vm_area_struct *vma;
> +       struct vm_area_struct *right_vma =3D 0;
> +       unsigned long entropy;
> +       unsigned int entropy_count;
> +       unsigned long length, low_limit, high_limit, gap_start, gap_end;
> +       unsigned long addr, low, high;
> +
> +       /* Adjust search length to account for worst case alignment overh=
ead */
> +       length =3D info->length + info->align_mask;
> +       if (length < info->length)
> +               return -ENOMEM;
> +
> +       /*
> +        * Adjust search limits by the desired length.
> +        * See implementation comment at top of unmapped_area().
> +        */
> +       gap_end =3D info->high_limit;
> +       if (gap_end < length)
> +               return -ENOMEM;
> +       high_limit =3D gap_end - length;
> +
> +       info->low_limit =3D 0x10000;
> +       if (info->low_limit > high_limit)
> +               return -ENOMEM;
> +       low_limit =3D info->low_limit + length;
> +
> +       /* Check highest gap, which does not precede any rbtree node */
> +       gap_start =3D mm->highest_vm_end;
> +       if (gap_start <=3D high_limit)
> +               goto found;
> +
> +       /* Check if rbtree root looks promising */
> +       if (RB_EMPTY_ROOT(&mm->mm_rb))
> +               return -ENOMEM;
> +       vma =3D rb_entry(mm->mm_rb.rb_node, struct vm_area_struct, vm_rb)=
;
> +       if (vma->rb_subtree_gap < length)
> +               return -ENOMEM;
> +
> +       while (true) {
> +               /* Visit right subtree if it looks promising */
> +               gap_start =3D vma->vm_prev ? vm_end_gap(vma->vm_prev) : 0=
;
> +               if (gap_start <=3D high_limit && vma->vm_rb.rb_right) {
> +                       struct vm_area_struct *right =3D
> +                               rb_entry(vma->vm_rb.rb_right,
> +                                        struct vm_area_struct, vm_rb);
> +                       if (right->rb_subtree_gap >=3D length) {
> +                               vma =3D right;
> +                               continue;
> +                       }
> +               }
> +
> +check_current_down:
> +               /* Check if current node has a suitable gap */
> +               gap_end =3D vm_start_gap(vma);
> +               if (gap_end < low_limit)
> +                       return -ENOMEM;
> +               if (gap_start <=3D high_limit &&
> +                   gap_end > gap_start && gap_end - gap_start >=3D lengt=
h)
> +                       goto found;
> +
> +               /* Visit left subtree if it looks promising */
> +               if (vma->vm_rb.rb_left) {
> +                       struct vm_area_struct *left =3D
> +                               rb_entry(vma->vm_rb.rb_left,
> +                                        struct vm_area_struct, vm_rb);
> +                       if (left->rb_subtree_gap >=3D length) {
> +                               vma =3D left;
> +                               continue;
> +                       }
> +               }
> +
> +               /* Go back up the rbtree to find next candidate node */
> +               while (true) {
> +                       struct rb_node *prev =3D &vma->vm_rb;
> +
> +                       if (!rb_parent(prev))
> +                               return -ENOMEM;
> +                       vma =3D rb_entry(rb_parent(prev),
> +                                      struct vm_area_struct, vm_rb);
> +                       if (prev =3D=3D vma->vm_rb.rb_right) {
> +                               gap_start =3D vma->vm_prev ?
> +                                       vm_end_gap(vma->vm_prev) : 0;
> +                               goto check_current_down;
> +                       }
> +               }
> +       }

Everything from here up is identical to the existing
unmapped_area_topdown(), yes? This likely needs to be refactored
instead of copy/pasted, and adjust to handle both unmapped_area() and
unmapped_area_topdown().

> +
> +found:
> +       right_vma =3D vma;
> +       low =3D gap_start;
> +       high =3D gap_end - length;
> +
> +       entropy =3D get_random_long();
> +       entropy_count =3D 0;
> +
> +       // from left node to right we check if node is fine and
> +       // randomly select it.
> +       vma =3D mm->mmap;
> +       while (vma !=3D right_vma) {
> +               /* Visit left subtree if it looks promising */
> +               gap_end =3D vm_start_gap(vma);
> +               if (gap_end >=3D low_limit && vma->vm_rb.rb_left) {
> +                       struct vm_area_struct *left =3D
> +                               rb_entry(vma->vm_rb.rb_left,
> +                                        struct vm_area_struct, vm_rb);
> +                       if (left->rb_subtree_gap >=3D length) {
> +                               vma =3D left;
> +                               continue;
> +                       }
> +               }
> +
> +               gap_start =3D vma->vm_prev ? vm_end_gap(vma->vm_prev) : l=
ow_limit;
> +check_current_up:
> +               /* Check if current node has a suitable gap */
> +               if (gap_start > high_limit)
> +                       break;
> +               if (gap_end >=3D low_limit &&
> +                   gap_end > gap_start && gap_end - gap_start >=3D lengt=
h) {
> +                       if (entropy & 1) {
> +                               low =3D gap_start;
> +                               high =3D gap_end - length;
> +                       }
> +                       entropy >>=3D 1;
> +                       if (++entropy_count =3D=3D 64) {
> +                               entropy =3D get_random_long();
> +                               entropy_count =3D 0;
> +                       }
> +               }
> +
> +               /* Visit right subtree if it looks promising */
> +               if (vma->vm_rb.rb_right) {
> +                       struct vm_area_struct *right =3D
> +                               rb_entry(vma->vm_rb.rb_right,
> +                                        struct vm_area_struct, vm_rb);
> +                       if (right->rb_subtree_gap >=3D length) {
> +                               vma =3D right;
> +                               continue;
> +                       }
> +               }
> +
> +               /* Go back up the rbtree to find next candidate node */
> +               while (true) {
> +                       struct rb_node *prev =3D &vma->vm_rb;
> +
> +                       if (!rb_parent(prev))
> +                               BUG(); // this should not happen
> +                       vma =3D rb_entry(rb_parent(prev),
> +                                      struct vm_area_struct, vm_rb);
> +                       if (prev =3D=3D vma->vm_rb.rb_left) {
> +                               gap_start =3D vm_end_gap(vma->vm_prev);
> +                               gap_end =3D vm_start_gap(vma);
> +                               if (vma =3D=3D right_vma)

mm/mmap.c: In function =E2=80=98unmapped_area_random=E2=80=99:
mm/mmap.c:1939:8: warning: =E2=80=98vma=E2=80=99 may be used uninitialized =
in this
function [-Wmaybe-uninitialized]
     if (vma =3D=3D right_vma)
        ^

> +                                       break;
> +                               goto check_current_up;
> +                       }
> +               }
> +       }

What are the two phases here? Could this second one get collapsed into
the first?

> +
> +       if (high =3D=3D low)
> +               return low;
> +
> +       addr =3D get_random_long() % ((high - low) >> PAGE_SHIFT);
> +       addr =3D low + (addr << PAGE_SHIFT);
> +       return addr;
> +}
> +
>  unsigned long unmapped_area(struct vm_unmapped_area_info *info)
>  {
>         /*

How large are the gaps intended to be? Looking at the gaps on
something like Xorg they differ a lot.

Otherwise, looks interesting!

-Kees

--=20
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
