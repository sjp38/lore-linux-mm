Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1EFEA6B0260
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 22:50:38 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id k15so358403383qtg.5
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:50:38 -0800 (PST)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id e49si11050374qta.160.2017.01.30.19.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 19:50:37 -0800 (PST)
Received: by mail-qk0-x244.google.com with SMTP id i34so19333941qkh.3
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:50:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <99f64a2676f0bec4ad32e39fc76eb0914ee091b8.1485571668.git.luto@kernel.org>
References: <cover.1485571668.git.luto@kernel.org> <99f64a2676f0bec4ad32e39fc76eb0914ee091b8.1485571668.git.luto@kernel.org>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Tue, 31 Jan 2017 16:50:16 +1300
Message-ID: <CAHO5Pa29Jnz8U9fp1zSy4RP2LdE0CwgB=ex1tog9SZKanAEwpQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] fs: Harden against open(..., O_CREAT, 02777) in a
 setgid directory
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: security@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Frank Filz <ffilzlnx@mindspring.com>, stable@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

[CC += linux-api@]

On Sat, Jan 28, 2017 at 3:49 PM, Andy Lutomirski <luto@kernel.org> wrote:
> Currently, if you open("foo", O_WRONLY | O_CREAT | ..., 02777) in a
> directory that is setgid and owned by a different gid than current's
> fsgid, you end up with an SGID executable that is owned by the
> directory's GID.  This is a Bad Thing (tm).  Exploiting this is
> nontrivial because most ways of creating a new file create an empty
> file and empty executables aren't particularly interesting, but this
> is nevertheless quite dangerous.
>
> Harden against this type of attack by detecting this particular
> corner case (unprivileged program creates SGID executable inode in
> SGID directory owned by a different GID) and clearing the new
> inode's SGID bit.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  fs/inode.c | 24 +++++++++++++++++++++---
>  1 file changed, 21 insertions(+), 3 deletions(-)
>
> diff --git a/fs/inode.c b/fs/inode.c
> index 0e1e141b094c..f6acb9232263 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -2025,12 +2025,30 @@ void inode_init_owner(struct inode *inode, const struct inode *dir,
>                         umode_t mode)
>  {
>         inode->i_uid = current_fsuid();
> +       inode->i_gid = current_fsgid();
> +
>         if (dir && dir->i_mode & S_ISGID) {
> +               bool changing_gid = !gid_eq(inode->i_gid, dir->i_gid);
> +
>                 inode->i_gid = dir->i_gid;
> -               if (S_ISDIR(mode))
> +
> +               if (S_ISDIR(mode)) {
>                         mode |= S_ISGID;
> -       } else
> -               inode->i_gid = current_fsgid();
> +               } else if (((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP))
> +                          && S_ISREG(mode) && changing_gid
> +                          && !capable(CAP_FSETID)) {
> +                       /*
> +                        * Whoa there!  An unprivileged program just
> +                        * tried to create a new executable with SGID
> +                        * set in a directory with SGID set that belongs
> +                        * to a different group.  Don't let this program
> +                        * create a SGID executable that ends up owned
> +                        * by the wrong group.
> +                        */
> +                       mode &= ~S_ISGID;
> +               }
> +       }
> +
>         inode->i_mode = mode;
>  }
>  EXPORT_SYMBOL(inode_init_owner);
> --
> 2.9.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
