Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B18876B0253
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 06:43:25 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id i34so133939322qkh.6
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 03:43:25 -0800 (PST)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by mx.google.com with ESMTPS id v16si11762663qkv.89.2017.01.31.03.43.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 03:43:25 -0800 (PST)
Received: by mail-qk0-f178.google.com with SMTP id u25so160084375qki.2
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 03:43:25 -0800 (PST)
Message-ID: <1485863003.2700.10.camel@redhat.com>
Subject: Re: [PATCH v2 2/2] fs: Harden against open(..., O_CREAT, 02777) in
 a setgid directory
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 31 Jan 2017 06:43:23 -0500
In-Reply-To: <99f64a2676f0bec4ad32e39fc76eb0914ee091b8.1485571668.git.luto@kernel.org>
References: <cover.1485571668.git.luto@kernel.org>
	 <99f64a2676f0bec4ad32e39fc76eb0914ee091b8.1485571668.git.luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, security@kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Frank Filz <ffilzlnx@mindspring.com>, stable@vger.kernel.org

On Fri, 2017-01-27 at 18:49 -0800, Andy Lutomirski wrote:
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
>  			umode_t mode)
>  {
>  	inode->i_uid = current_fsuid();
> +	inode->i_gid = current_fsgid();
> +
>  	if (dir && dir->i_mode & S_ISGID) {

I'm surprised the compiler doesn't complain about ambiguous order of ops
in the above if statement. Might be nice to add some parenthesis there
since you're in here, just for clarity.

> +		bool changing_gid = !gid_eq(inode->i_gid, dir->i_gid);
> +
>  		inode->i_gid = dir->i_gid;
> -		if (S_ISDIR(mode))
> +
> +		if (S_ISDIR(mode)) {
>  			mode |= S_ISGID;
> -	} else
> -		inode->i_gid = current_fsgid();
> +		} else if (((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP))
> +			   && S_ISREG(mode) && changing_gid
> +			   && !capable(CAP_FSETID)) {
> +			/*
> +			 * Whoa there!  An unprivileged program just
> +			 * tried to create a new executable with SGID
> +			 * set in a directory with SGID set that belongs
> +			 * to a different group.  Don't let this program
> +			 * create a SGID executable that ends up owned
> +			 * by the wrong group.
> +			 */
> +			mode &= ~S_ISGID;
> +		}
> +	}
> +
>  	inode->i_mode = mode;
>  }
>  EXPORT_SYMBOL(inode_init_owner);

It's hard to picture any applications that would rely on the legacy
behavior, but if they come out of the woodwork, we could always add a
"make my kernel unsafe" command-line or compile time switch to bring it
back.

I think this is reasonable thing to do, but Michael K. is correct that
we should document the behavior changes in the relevant manpages.

Reviewed-by: Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
