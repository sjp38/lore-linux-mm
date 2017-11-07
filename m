Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A5508680F85
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 15:35:23 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id f20so3486840ioj.2
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 12:35:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v186sor1303174itc.92.2017.11.07.12.35.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 12:35:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <001a114096fec09301055d68d784@google.com>
References: <001a114096fec09301055d68d784@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 7 Nov 2017 12:35:21 -0800
Message-ID: <CAGXu5jJFwPYre6P2vf1v0XFBFfk-uqJEYEPP8WsjPspZoYDHCg@mail.gmail.com>
Subject: Re: WARNING in __check_heap_object
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <bot+2357afb48acb76780f3c18867ccfb7aa6fd6c4c9@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com, David Windsor <dave@nullcore.net>

On Tue, Nov 7, 2017 at 10:36 AM, syzbot
<bot+2357afb48acb76780f3c18867ccfb7aa6fd6c4c9@syzkaller.appspotmail.com>
wrote:
> Hello,
>
> syzkaller hit the following crash on
> 5a3517e009e979f21977d362212b7729c5165d92
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached
> Raw console output is attached.
> C reproducer is attached
> syzkaller reproducer is attached. See https://goo.gl/kgGztJ
> for information about syzkaller reproducers
>
>

Please include the line _before_ the "cut here" (dumb, I know, but
that's where warnings show up...)

Found in the raw.log:

[   44.227177] unexpected usercopy without slab whitelist from SCTPv6
offset 1648 size 11

This means some part of the SCTPv6 slab was being poked into userspace
without a usercopy whitelist.

>  check_heap_object mm/usercopy.c:222 [inline]
>  __check_object_size+0x22c/0x4f0 mm/usercopy.c:248
>  check_object_size include/linux/thread_info.h:112 [inline]
>  check_copy_size include/linux/thread_info.h:143 [inline]
>  copy_to_user include/linux/uaccess.h:154 [inline]
>  sctp_getsockopt_events net/sctp/socket.c:4972 [inline]
>  sctp_getsockopt+0x2b90/0x70b0 net/sctp/socket.c:7012
>  sock_common_getsockopt+0x95/0xd0 net/core/sock.c:2924
>  SYSC_getsockopt net/socket.c:1882 [inline]
>  SyS_getsockopt+0x178/0x340 net/socket.c:1864
>  entry_SYSCALL_64_fastpath+0x1f/0xbe

Looking at the SCTPv6 slab declaration, it seems David and I missed
the usercopy whitelist for the sctpv6_sock struct. I'll update the
usercopy whitelist patch with:

#syz fix: sctp: Define usercopy region in SCTP proto slab cache

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 5fd83974c5cc..8ac85877c0e4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -8492,6 +8492,10 @@ struct proto sctpv6_prot = {
        .unhash         = sctp_unhash,
        .get_port       = sctp_get_port,
        .obj_size       = sizeof(struct sctp6_sock),
+       .useroffset     = offsetof(struct sctp_sock, subscribe),
+       .usersize       = offsetof(struct sctp_sock, initmsg) -
+                               offsetof(struct sctp_sock, subscribe) +
+                               sizeof_field(struct sctp_sock, initmsg),
        .sysctl_mem     = sysctl_sctp_mem,
        .sysctl_rmem    = sysctl_sctp_rmem,
        .sysctl_wmem    = sysctl_sctp_wmem,

Thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
