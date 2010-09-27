Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4402E6B0078
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 05:55:48 -0400 (EDT)
Date: Mon, 27 Sep 2010 05:55:19 -0400 (EDT)
From: caiqian@redhat.com
Message-ID: <986278020.2030861285581319128.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1345860830.2030761285581270894.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: [PATCH 0/3] Generic support for revoking mappings
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, =?utf-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
List-ID: <linux-mm.kvack.org>


----- caiqian@redhat.com wrote:

> ----- "Am=C3=A9rico Wang" <xiyou.wangcong@gmail.com> wrote:
>=20
> > On Mon, Sep 27, 2010 at 04:52:29AM -0400, CAI Qian wrote:
> > >Just a head up. Tried to boot latest mmotm kernel with those
> patches
> > applied hit this. I am wondering what I did wrong.
The only tricky part of the merge I can tell was for Andrea's commit,

commit a30452568c9dc7635ab09402b494de6d0cf9a60e
Author: Andrea Arcangeli <aarcange@redhat.com>
Date:   Thu Sep 23 01:07:59 2010 +0200

    If __split_vma fails because of an out of memory condition the
    anon_vma_chain isn't teardown and freed potentially leading to rmap wal=
ks
    accessing freed vma information plus there's a memleak.
   =20
    Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
    Acked-by: Johannes Weiner <jweiner@redhat.com>
    Acked-by: Rik van Riel <riel@redhat.com>
    Acked-by: Hugh Dickins <hughd@google.com>
    Cc: Marcelo Tosatti <mtosatti@redhat.com>
    Cc: <stable@kernel.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/mmap.c b/mm/mmap.c
index 6128dc8..00161a4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2009,6 +2009,7 @@ static int __split_vma(struct mm_struct * mm, struct =
vm_area_struct * vma,
                        removed_exe_file_vma(mm);
                fput(new->vm_file);
        }
+       unlink_anon_vmas(new);
  out_free_mpol:
        mpol_put(pol);
  out_free_vma:

It became this after manually merged them,

@@ -2002,20 +2006,15 @@ static int __split_vma(struct mm_struct * mm, struc=
t vm_area_struct * vma,
                return 0;
=20
        /* Clean everything up if vma_adjust failed. */
-       if (new->vm_ops && new->vm_ops->close)
-               new->vm_ops->close(new);
-       if (new->vm_file) {
-               if (vma->vm_flags & VM_EXECUTABLE)
-                       removed_exe_file_vma(mm);
-               fput(new->vm_file);
-       }
        unlink_anon_vmas(new);
+       remove_vma(new);
+ out_err:
+       return err;
  out_free_mpol:
        mpol_put(pol);
  out_free_vma:
        kmem_cache_free(vm_area_cachep, new);
- out_err:
-       return err;
+       goto out_err;
 }
=20
 /*


> > >
> >=20
> > You missed the header of this oops/warning/bug, is that a BUG_ON or
> > WARN_ON or other thing?
> Oh, sorry. Here it is,
> BUG: unable to handle kernel paging request at ffffffffffffffc0
> IP: [<ffffffff811d4c78>] prio_tree_insert+0x188/0x2a0
> PGD 1827067 PUD 1828067 PMD 0=20
> Oops: 0000 [#1] SMP=20
> last sysfs file:=20
> CPU 5=20
>=20
> >=20
> >=20
> > >Pid: 1, comm: init Not tainted 2.6.36-rc5-mm1+ #2 /KVM
> > >RIP: 0010:[<ffffffff811d4c78>]  [<ffffffff811d4c78>]
> > prio_tree_insert+0x188/0x2a0
> > >RSP: 0018:ffff880c3b1bfcd8  EFLAGS: 00010202
> > >RAX: ffff880c374b40d8 RBX: 0000000000000100 RCX: ffff880c374b40d8
> > >RDX: 0000000000000179 RSI: 0000000000000000 RDI: 0000000000000179
> > >RBP: ffff880c9f4ba188 R08: 0000000000000001 R09: ffff880c374b9330
> > >R10: 0000000000000001 R11: 0000000000000002 R12: ffff880c374b40d8
> > >R13: 00000007fa7367ba R14: 00000007fa7367be R15: 0000000000000000
> > >FS:  00007fa7369d9700(0000) GS:ffff8800df540000(0000)
> > knlGS:0000000000000000
> > >CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > >CR2: ffffffffffffffc0 CR3: 0000000c374b1000 CR4: 00000000000006e0
> > >DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > >DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > >Process init (pid: 1, threadinfo ffff880c3b1be000, task
> > ffff880c3b1bd400)
> > >Stack:
> > > ffff880c3b1bd400 ffff880c374b4088 ffff880c374b40d8
> ffff880c374b4088
> > ><0> ffff880c9f4ba168 ffff880c9f4ba188 ffff880c374b3680
> > ffffffff810daff8
> > ><0> 0000000000000002 ffff880c374b41f8 ffff880c374b42b0
> > ffffffff810e9171
> > >Call Trace:
> > > [<ffffffff810daff8>] ? vma_prio_tree_insert+0x28/0x120
> > > [<ffffffff810e9171>] ? vma_adjust+0xe1/0x560
> > > [<ffffffff8119715b>] ? avc_has_perm+0x6b/0xa0
> > > [<ffffffff810e97b9>] ? __split_vma+0x1c9/0x250
> > > [<ffffffff810ebf88>] ? mprotect_fixup+0x708/0x7b0
> > > [<ffffffff810e4aca>] ? handle_mm_fault+0x1da/0xcf0
> > > [<ffffffff81033910>] ? pvclock_clocksource_read+0x50/0xc0
> > > [<ffffffff81047220>] ? __dequeue_entity+0x40/0x50
> > > [<ffffffff81198a31>] ? file_has_perm+0xf1/0x100
> > > [<ffffffff810ec1b2>] ? sys_mprotect+0x182/0x250
> > > [<ffffffff8100aec2>] ? system_call_fastpath+0x16/0x1b
> > >Code: 56 20 e9 d4 fe ff ff bb 01 00 00 00 48 d3 e3 48 85 db 0f 84
> 08
> > 01 00 00 45 31 ff 66 45 85 c0 4c 89 e1 74 78 0f 1f 80 00 00 00 00
> <48>
> > 8b 46 c0 48 2b 46 b8 4c 8b 6e 40 48 c1 e8 0c 4c 39 ef 4d 8d=20
> > >RIP  [<ffffffff811d4c78>] prio_tree_insert+0x188/0x2a0
> > > RSP <ffff880c3b1bfcd8>
> > >CR2: ffffffffffffffc0
> > >---[ end trace 667258bb79b38e02 ]---
> > >
> >=20
> > Looks like something wrong in page fault.
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
