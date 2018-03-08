Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id B2D706B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 19:58:26 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id n95so4119808ioo.2
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 16:58:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j97sor6201615ioo.173.2018.03.07.16.58.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Mar 2018 16:58:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180307235923.12469-1-mike.kravetz@oracle.com>
References: <20180306133135.4dc344e478d98f0e29f47698@linux-foundation.org> <20180307235923.12469-1-mike.kravetz@oracle.com>
From: Nic Losby <blurbdust@gmail.com>
Date: Wed, 7 Mar 2018 18:57:44 -0600
Message-ID: <CAD1dD3nnUeU8tJHOezRUBGH2FPuJNqNLoGTAL0sH40vXRR5iqA@mail.gmail.com>
Subject: Re: [PATCH] hugetlbfs: check for pgoff value overflow
Content-Type: multipart/alternative; boundary="001a114469d84511ce0566dc2c22"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>

--001a114469d84511ce0566dc2c22
Content-Type: text/plain; charset="UTF-8"

Confirmed as patched! The kernel no longer crashes after the patch was
applied. Thank you for your time!

On Wed, Mar 7, 2018 at 5:59 PM, Mike Kravetz <mike.kravetz@oracle.com>
wrote:

> A vma with vm_pgoff large enough to overflow a loff_t type when
> converted to a byte offset can be passed via the remap_file_pages
> system call.  The hugetlbfs mmap routine uses the byte offset to
> calculate reservations and file size.
>
> A sequence such as:
>   mmap(0x20a00000, 0x600000, 0, 0x66033, -1, 0);
>   remap_file_pages(0x20a00000, 0x600000, 0, 0x20000000000000, 0);
> will result in the following when task exits/file closed,
>   kernel BUG at mm/hugetlb.c:749!
> Call Trace:
>   hugetlbfs_evict_inode+0x2f/0x40
>   evict+0xcb/0x190
>   __dentry_kill+0xcb/0x150
>   __fput+0x164/0x1e0
>   task_work_run+0x84/0xa0
>   exit_to_usermode_loop+0x7d/0x80
>   do_syscall_64+0x18b/0x190
>   entry_SYSCALL_64_after_hwframe+0x3d/0xa2
>
> The overflowed pgoff value causes hugetlbfs to try to set up a
> mapping with a negative range (end < start) that leaves invalid
> state which causes the BUG.
>
> Reported-by: Nic Losby <blurbdust@gmail.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  fs/hugetlbfs/inode.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 8fe1b0aa2896..cb288dec5564 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -127,12 +127,13 @@ static int hugetlbfs_file_mmap(struct file *file,
> struct vm_area_struct *vma)
>         vma->vm_ops = &hugetlb_vm_ops;
>
>         /*
> -        * Offset passed to mmap (before page shift) could have been
> -        * negative when represented as a (l)off_t.
> +        * page based offset in vm_pgoff could be sufficiently large to
> +        * overflow a (l)off_t when converted to byte offset.
>          */
> -       if (((loff_t)vma->vm_pgoff << PAGE_SHIFT) < 0)
> +       if (vma->vm_pgoff && ((loff_t)vma->vm_pgoff << PAGE_SHIFT) <= 0)
>                 return -EINVAL;
>
> +       /* must be huge page aligned */
>         if (vma->vm_pgoff & (~huge_page_mask(h) >> PAGE_SHIFT))
>                 return -EINVAL;
>
> --
> 2.13.6
>
>

--001a114469d84511ce0566dc2c22
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Confirmed as patched! The kernel no longer crashes after t=
he patch was applied. Thank you for your time!</div><div class=3D"gmail_ext=
ra"><br><div class=3D"gmail_quote">On Wed, Mar 7, 2018 at 5:59 PM, Mike Kra=
vetz <span dir=3D"ltr">&lt;<a href=3D"mailto:mike.kravetz@oracle.com" targe=
t=3D"_blank">mike.kravetz@oracle.com</a>&gt;</span> wrote:<br><blockquote c=
lass=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;=
padding-left:1ex">A vma with vm_pgoff large enough to overflow a loff_t typ=
e when<br>
converted to a byte offset can be passed via the remap_file_pages<br>
system call.=C2=A0 The hugetlbfs mmap routine uses the byte offset to<br>
calculate reservations and file size.<br>
<br>
A sequence such as:<br>
=C2=A0 mmap(0x20a00000, 0x600000, 0, 0x66033, -1, 0);<br>
=C2=A0 remap_file_pages(0x20a00000, 0x600000, 0, 0x20000000000000, 0);<br>
will result in the following when task exits/file closed,<br>
=C2=A0 kernel BUG at mm/hugetlb.c:749!<br>
Call Trace:<br>
=C2=A0 hugetlbfs_evict_inode+0x2f/<wbr>0x40<br>
=C2=A0 evict+0xcb/0x190<br>
=C2=A0 __dentry_kill+0xcb/0x150<br>
=C2=A0 __fput+0x164/0x1e0<br>
=C2=A0 task_work_run+0x84/0xa0<br>
=C2=A0 exit_to_usermode_loop+0x7d/<wbr>0x80<br>
=C2=A0 do_syscall_64+0x18b/0x190<br>
=C2=A0 entry_SYSCALL_64_after_<wbr>hwframe+0x3d/0xa2<br>
<br>
The overflowed pgoff value causes hugetlbfs to try to set up a<br>
mapping with a negative range (end &lt; start) that leaves invalid<br>
state which causes the BUG.<br>
<br>
Reported-by: Nic Losby &lt;<a href=3D"mailto:blurbdust@gmail.com">blurbdust=
@gmail.com</a>&gt;<br>
Signed-off-by: Mike Kravetz &lt;<a href=3D"mailto:mike.kravetz@oracle.com">=
mike.kravetz@oracle.com</a>&gt;<br>
---<br>
=C2=A0fs/hugetlbfs/inode.c | 7 ++++---<br>
=C2=A01 file changed, 4 insertions(+), 3 deletions(-)<br>
<br>
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c<br>
index 8fe1b0aa2896..cb288dec5564 100644<br>
--- a/fs/hugetlbfs/inode.c<br>
+++ b/fs/hugetlbfs/inode.c<br>
@@ -127,12 +127,13 @@ static int hugetlbfs_file_mmap(struct file *file, str=
uct vm_area_struct *vma)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 vma-&gt;vm_ops =3D &amp;hugetlb_vm_ops;<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 * Offset passed to mmap (before page shift) co=
uld have been<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 * negative when represented as a (l)off_t.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * page based offset in vm_pgoff could be suffi=
ciently large to<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 * overflow a (l)off_t when converted to byte o=
ffset.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (((loff_t)vma-&gt;vm_pgoff &lt;&lt; PAGE_SHI=
FT) &lt; 0)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (vma-&gt;vm_pgoff &amp;&amp; ((loff_t)vma-&g=
t;vm_pgoff &lt;&lt; PAGE_SHIFT) &lt;=3D 0)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;<br>
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0/* must be huge page aligned */<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (vma-&gt;vm_pgoff &amp; (~huge_page_mask(h) =
&gt;&gt; PAGE_SHIFT))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL;<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
2.13.6<br>
<br>
</font></span></blockquote></div><br></div>

--001a114469d84511ce0566dc2c22--
