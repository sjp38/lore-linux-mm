Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 730D56B0253
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 22:50:22 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id u25so81993287qki.3
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:50:22 -0800 (PST)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id z22si11069060qtz.87.2017.01.30.19.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 19:50:21 -0800 (PST)
Received: by mail-qk0-x241.google.com with SMTP id e1so22038300qkh.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 19:50:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <a7f76bd3e8787b54f6592311c288e15a56c613ca.1485571668.git.luto@kernel.org>
References: <cover.1485571668.git.luto@kernel.org> <a7f76bd3e8787b54f6592311c288e15a56c613ca.1485571668.git.luto@kernel.org>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Tue, 31 Jan 2017 16:50:00 +1300
Message-ID: <CAHO5Pa2yNqL=ERWsmF-ksCnDAim1rS7+G3RFL3CgqVK=M-pB_w@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] fs: Check f_cred as well as of current's creds in should_remove_suid()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: security@kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kees Cook <keescook@chromium.org>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Frank Filz <ffilzlnx@mindspring.com>, stable@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

[CC += linux-api@]

On Sat, Jan 28, 2017 at 3:49 PM, Andy Lutomirski <luto@kernel.org> wrote:
> If an unprivileged program opens a setgid file for write and passes
> the fd to a privileged program and the privileged program writes to
> it, we currently fail to clear the setgid bit.  Fix it by checking
> f_cred in addition to current's creds whenever a struct file is
> involved.
>
> I'm checking both because I'm nervous about preserving the SUID and
> SGID bits in any situation in which they're not currently preserved
> and because Ben Hutchings suggested doing it this way.
>
> I don't know why we check capabilities at all, and we could probably
> get away with clearing the setgid bit regardless of capabilities,
> but this change should be less likely to break some weird program.
>
> This mitigates exploits that take advantage of world-writable setgid
> files or directories.
>
> Cc: stable@vger.kernel.org
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  fs/inode.c         | 37 +++++++++++++++++++++++++++++++------
>  fs/internal.h      |  2 +-
>  fs/ocfs2/file.c    |  4 ++--
>  fs/open.c          |  2 +-
>  include/linux/fs.h |  2 +-
>  5 files changed, 36 insertions(+), 11 deletions(-)
>
> diff --git a/fs/inode.c b/fs/inode.c
> index 88110fd0b282..0e1e141b094c 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -1733,8 +1733,12 @@ EXPORT_SYMBOL(touch_atime);
>   *
>   *     if suid or (sgid and xgrp)
>   *             remove privs
> + *
> + * If a file is provided, we assume that this is write(), ftruncate() or
> + * similar on that file.  If a file is not provided, we assume that no
> + * file descriptor is involved (e.g. truncate()).
>   */
> -int should_remove_suid(struct dentry *dentry)
> +int should_remove_suid(struct dentry *dentry, struct file *file)
>  {
>         umode_t mode = d_inode(dentry)->i_mode;
>         int kill = 0;
> @@ -1750,8 +1754,29 @@ int should_remove_suid(struct dentry *dentry)
>         if (unlikely((mode & S_ISGID) && (mode & S_IXGRP)))
>                 kill |= ATTR_KILL_SGID;
>
> -       if (unlikely(kill && !capable(CAP_FSETID) && S_ISREG(mode)))
> -               return kill;
> +       if (unlikely(kill && S_ISREG(mode))) {
> +               /*
> +                * To minimize the degree to which this code works differently
> +                * from Linux 4.9 and below, we kill SUID/SGID if the writer
> +                * is unprivileged even if the file was opened by a privileged
> +                * process.  Yes, this is a hack and is a technical violation
> +                * of the "write(2) doesn't check current_cred()" rule.
> +                *
> +                * Ideally we would just kill the SUID bit regardless
> +                * of capabilities.
> +                */
> +               if (!capable(CAP_FSETID))
> +                       return kill;
> +
> +               /*
> +                * To avoid abuse of stdout/stderr redirection, we need to
> +                * kill SUID/SGID if the file was opened by an unprivileged
> +                * task.
> +                */
> +               if (file && file->f_cred != current_cred() &&
> +                   !file_ns_capable(file, &init_user_ns, CAP_FSETID))
> +                       return kill;
> +       }
>
>         return 0;
>  }
> @@ -1762,7 +1787,7 @@ EXPORT_SYMBOL(should_remove_suid);
>   * response to write or truncate. Return 0 if nothing has to be changed.
>   * Negative value on error (change should be denied).
>   */
> -int dentry_needs_remove_privs(struct dentry *dentry)
> +int dentry_needs_remove_privs(struct dentry *dentry, struct file *file)
>  {
>         struct inode *inode = d_inode(dentry);
>         int mask = 0;
> @@ -1771,7 +1796,7 @@ int dentry_needs_remove_privs(struct dentry *dentry)
>         if (IS_NOSEC(inode))
>                 return 0;
>
> -       mask = should_remove_suid(dentry);
> +       mask = should_remove_suid(dentry, file);
>         ret = security_inode_need_killpriv(dentry);
>         if (ret < 0)
>                 return ret;
> @@ -1807,7 +1832,7 @@ int file_remove_privs(struct file *file)
>         if (IS_NOSEC(inode))
>                 return 0;
>
> -       kill = dentry_needs_remove_privs(dentry);
> +       kill = dentry_needs_remove_privs(dentry, file);
>         if (kill < 0)
>                 return kill;
>         if (kill)
> diff --git a/fs/internal.h b/fs/internal.h
> index b63cf3af2dc2..c467ad502cac 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -119,7 +119,7 @@ extern struct file *filp_clone_open(struct file *);
>   */
>  extern long prune_icache_sb(struct super_block *sb, struct shrink_control *sc);
>  extern void inode_add_lru(struct inode *inode);
> -extern int dentry_needs_remove_privs(struct dentry *dentry);
> +extern int dentry_needs_remove_privs(struct dentry *dentry, struct file *file);
>
>  extern bool __atime_needs_update(const struct path *, struct inode *, bool);
>  static inline bool atime_needs_update_rcu(const struct path *path,
> diff --git a/fs/ocfs2/file.c b/fs/ocfs2/file.c
> index c4889655d32b..db6efd940ac0 100644
> --- a/fs/ocfs2/file.c
> +++ b/fs/ocfs2/file.c
> @@ -1903,7 +1903,7 @@ static int __ocfs2_change_file_space(struct file *file, struct inode *inode,
>                 }
>         }
>
> -       if (file && should_remove_suid(file->f_path.dentry)) {
> +       if (file && should_remove_suid(file->f_path.dentry, file)) {
>                 ret = __ocfs2_write_remove_suid(inode, di_bh);
>                 if (ret) {
>                         mlog_errno(ret);
> @@ -2132,7 +2132,7 @@ static int ocfs2_prepare_inode_for_write(struct file *file,
>                  * inode. There's also the dinode i_size state which
>                  * can be lost via setattr during extending writes (we
>                  * set inode->i_size at the end of a write. */
> -               if (should_remove_suid(dentry)) {
> +               if (should_remove_suid(dentry, file)) {
>                         if (meta_level == 0) {
>                                 ocfs2_inode_unlock(inode, meta_level);
>                                 meta_level = 1;
> diff --git a/fs/open.c b/fs/open.c
> index d3ed8171e8e0..8f54f34d1e3e 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -52,7 +52,7 @@ int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
>         }
>
>         /* Remove suid, sgid, and file capabilities on truncate too */
> -       ret = dentry_needs_remove_privs(dentry);
> +       ret = dentry_needs_remove_privs(dentry, filp);
>         if (ret < 0)
>                 return ret;
>         if (ret)
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 2ba074328894..87654fb21158 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2718,7 +2718,7 @@ extern void __destroy_inode(struct inode *);
>  extern struct inode *new_inode_pseudo(struct super_block *sb);
>  extern struct inode *new_inode(struct super_block *sb);
>  extern void free_inode_nonrcu(struct inode *inode);
> -extern int should_remove_suid(struct dentry *);
> +extern int should_remove_suid(struct dentry *, struct file *);
>  extern int file_remove_privs(struct file *);
>
>  extern void __insert_inode_hash(struct inode *, unsigned long hashval);
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
