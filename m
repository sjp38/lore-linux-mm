Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E845B6B0711
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 23:58:42 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t18so489891oih.11
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 20:58:42 -0700 (PDT)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id o186si400725oih.105.2017.08.03.20.58.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 20:58:41 -0700 (PDT)
Received: by mail-oi0-x244.google.com with SMTP id j194so533877oib.4
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 20:58:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170531035423.70970-3-leilei.lin@alibaba-inc.com>
References: <20170531035423.70970-1-leilei.lin@alibaba-inc.com> <20170531035423.70970-3-leilei.lin@alibaba-inc.com>
From: =?UTF-8?B?5p6X5a6I56OK?= <linxiulei@gmail.com>
Date: Fri, 4 Aug 2017 11:58:41 +0800
Message-ID: <CALPjY3mAV40cMD_iE=WVx2upxwgUYwBH-gdpgWY+RichywajfQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] fsnotify: use method copy_dname copying filename
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?55+z56Wk?= <leilei.lin@alibaba-inc.com>, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, zhiche.yy@alibaba-inc.com, torvalds@linux-foundation.org, linux-mm@kvack.org

Hi all

I sent this patch two months ago, then I found CVE from this link last nigh=
t

    http://seclists.org/oss-sec/2017/q3/240

which not only references this patch, but also provides a upstream fix

    https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3D49d31c2f389acfe83417083e1208422b4091cd9

I was wondering why @viro hadn't noticed this mail (And @viro fixed
this). I'm new here and nobody,
trying to do my best to help the this linux community. I was looking
forword to your reply, because some
insufficiency may exists in my work, I'd like to learn from you guys

Thanks and humble enough to wait your reply

=E5=9C=A8 2017=E5=B9=B45=E6=9C=8831=E6=97=A5 =E4=B8=8A=E5=8D=8811:54=EF=BC=
=8C=E7=9F=B3=E7=A5=A4 <linxiulei@gmail.com> =E5=86=99=E9=81=93=EF=BC=9A
> From: "leilei.lin" <leilei.lin@alibaba-inc.com>
>
> Kernel got panicked in inotify_handle_event, while running the rename
> operation against the same file. The root cause is that the race between
> fsnotify thread and file rename thread.  When fsnotify thread was
> copying the dentry name, another rename thread could change the dentry
> name at same time. With slub_debug=3DFZ boot args, this bug will trigger
> a trace like the following:
>
> [   87.733653] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> [   87.735350] BUG kmalloc-64 (Not tainted): Redzone overwritten
> [   87.736550] ----------------------------------------------------------=
-------------------
>
> [   87.738466] Disabling lock debugging due to kernel taint
> [   87.739556] INFO: 0xffff8e487a50b0f8-0xffff8e487a50b0fc. First byte 0x=
33 instead of 0xcc
> [   87.741188] INFO: Slab 0xfffff116c0e942c0 objects=3D46 used=3D43 fp=3D=
0xffff8e487a50bf80 flags=3D0xffff8000000101
> [   87.743133] INFO: Object 0xffff8e487a50b0b8 @offset=3D184 fp=3D0xffff8=
e487a50b0b8
>
> [   87.744942] Redzone ffff8e487a50b0b0: cc cc cc cc cc cc cc cc         =
                 ........
> [   87.746743] Object ffff8e487a50b0b8: b8 b0 50 7a 48 8e ff ff b8 b0 50 =
7a 48 8e ff ff  ..PzH.....PzH...
> [   87.748621] Object ffff8e487a50b0c8: 60 75 7e 7b 48 8e ff ff 08 00 00 =
08 00 00 00 00  `u~{H...........
> [   87.750583] Object ffff8e487a50b0d8: 01 00 00 00 00 00 00 00 0d 00 00 =
00 74 64 63 5f  ............tdc_
> [   87.752541] Object ffff8e487a50b0e8: 61 64 6d 69 6e 2e 4c 4f 47 2e 31 =
31 32 33 31 32  admin.LOG.112312
> [   87.754431] Redzone ffff8e487a50b0f8: 33 31 32 33 00 cc cc cc         =
                 3123....
> [   87.756172] Padding ffff8e487a50b100: 00 00 00 00 00 00 00 00         =
                 ........
> [   87.757988] CPU: 0 PID: 286 Comm: python Tainted: G    B           4.1=
1.0-rc4+ #29
> [   87.759574] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S rel-1.9.1-0-gb3ef39f-prebuilt.qemu-project.org 04/01/2014
> [   87.761878] Call Trace:
> [   87.762381]  dump_stack+0x65/0x88
> [   87.763063]  print_trailer+0x15d/0x250
> [   87.763833]  check_bytes_and_report+0xcd/0x110
> [   87.764731]  check_object+0x1ce/0x290
> [   87.765472]  free_debug_processing+0x9c/0x2e3
> [   87.766362]  ? inotify_free_event+0xe/0x10
> [   87.767191]  __slab_free+0x1ba/0x2b0
> [   87.767922]  ? async_page_fault+0x28/0x30
> [   87.768731]  ? inotify_free_event+0xe/0x10
> [   87.769558]  kfree+0x165/0x1a0
> [   87.770184]  inotify_free_event+0xe/0x10
> [   87.770974]  fsnotify_destroy_event+0x51/0x70
> [   87.771851]  inotify_read+0x1dc/0x3a0
> [   87.772582]  ? do_wait_intr_irq+0xa0/0xa0
> [   87.773388]  __vfs_read+0x37/0x150
> [   87.774078]  ? security_file_permission+0x9d/0xc0
> [   87.775009]  vfs_read+0x8c/0x130
> [   87.775657]  SyS_read+0x55/0xc0
> [   87.776328]  entry_SYSCALL_64_fastpath+0x1e/0xad
> [   87.777280] RIP: 0033:0x7fcc1375b210
> [   87.778001] RSP: 002b:00007ffe2f00b838 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000000
> [   87.779513] RAX: ffffffffffffffda RBX: 00007fcc1303d7b8 RCX: 00007fcc1=
375b210
> [   87.780932] RDX: 0000000000005c70 RSI: 00000000013fe9f4 RDI: 000000000=
0000004
> [   87.782337] RBP: 00007fcc1303d760 R08: 0000000000000080 R09: 000000000=
0005c95
> [   87.783780] R10: 0000000000000073 R11: 0000000000000246 R12: 000000000=
0005c95
> [   87.785203] R13: 0000000000002708 R14: 0000000000005ca1 R15: 00007fcc1=
303d7b8
> [   87.786636] FIX kmalloc-64: Restoring 0xffff8e487a50b0f8-0xffff8e487a5=
0b0fc=3D0xcc
>
> [   87.789388] FIX kmalloc-64: Object at 0xffff8e487a50b0b8 not freed
>
> Graph below is the flow of inotify subsystem handling
> notify event. If a rename syscall happened simultaneously,
> for example filename of "foobar" is rename to
> "foobar_longername", which would access memory illegally.
>
>             CPU 1                                       CPU 2
>
>      fsnotify()
>        inotify_handle_event()
>          strlen(file_name) // file_name -> "foobar"
>
>                                                     rename happen
>                                                     file_name -> "foobar_=
longername"
>
>          alloc_len +=3D len + 1;
>          event =3D kmalloc(alloc_len, GFP_KERNEL);
>          strcpy(event->name, file_name); -> overwritten
>
> Signed-off-by: leilei.lin <leilei.lin@alibaba-inc.com>
> ---
>  fs/notify/fsnotify.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/fs/notify/fsnotify.c b/fs/notify/fsnotify.c
> index b41515d..2c6f94d 100644
> --- a/fs/notify/fsnotify.c
> +++ b/fs/notify/fsnotify.c
> @@ -91,6 +91,7 @@ int __fsnotify_parent(const struct path *path, struct d=
entry *dentry, __u32 mask
>         struct dentry *parent;
>         struct inode *p_inode;
>         int ret =3D 0;
> +       char *name =3D NULL;
>
>         if (!dentry)
>                 dentry =3D path->dentry;
> @@ -108,14 +109,23 @@ int __fsnotify_parent(const struct path *path, stru=
ct dentry *dentry, __u32 mask
>                  * specifies these are events which came from a child. */
>                 mask |=3D FS_EVENT_ON_CHILD;
>
> +               ret =3D copy_dname(dentry, &name);
> +
> +               if (ret) {
> +                       dput(parent);
> +                       return ret;
> +               }
> +
>                 if (path)
>                         ret =3D fsnotify(p_inode, mask, path, FSNOTIFY_EV=
ENT_PATH,
> -                                      dentry->d_name.name, 0);
> +                                      name, 0);
>                 else
>                         ret =3D fsnotify(p_inode, mask, dentry->d_inode, =
FSNOTIFY_EVENT_INODE,
> -                                      dentry->d_name.name, 0);
> +                                      name, 0);
>         }
>
> +       kfree(name);
> +
>         dput(parent);
>
>         return ret;
> --
> 2.8.4.31.g9ed660f
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
