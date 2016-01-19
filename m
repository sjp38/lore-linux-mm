Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 80CDB6B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 14:27:14 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id q63so185604742pfb.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 11:27:14 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id v88si49274368pfa.213.2016.01.19.11.27.13
        for <linux-mm@kvack.org>;
        Tue, 19 Jan 2016 11:27:13 -0800 (PST)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id A67AE20431
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:27:12 +0000 (UTC)
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A361E20575
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 19:27:10 +0000 (UTC)
Received: by mail-ob0-f170.google.com with SMTP id vt7so195807934obb.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 11:27:10 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 19 Jan 2016 11:26:50 -0800
Message-ID: <CALCETrXvyguKpRsyBC_6AGOxzSdMZ43Q5w_3zzAThsm+R91LSg@mail.gmail.com>
Subject: should_remove_suid capable check is busted
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@chromium.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, yalin wang <yalin.wang2010@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

On Jan 14, 2016 10:36 PM, "Konstantin Khlebnikov" <koct9i@gmail.com> wrote:
>
> On Fri, Jan 15, 2016 at 9:18 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> > While we're at it:
> >
> > int should_remove_suid(struct dentry *dentry)
> > {
> >         umode_t mode = d_inode(dentry)->i_mode;
> >         int kill = 0;
> >
> >         /* suid always must be killed */
> >         if (unlikely(mode & S_ISUID))
> >                 kill = ATTR_KILL_SUID;
> >
> >         /*
> >          * sgid without any exec bits is just a mandatory locking mark; leave
> >          * it alone.  If some exec bits are set, it's a real sgid; kill it.
> >          */
> >         if (unlikely((mode & S_ISGID) && (mode & S_IXGRP)))
> >                 kill |= ATTR_KILL_SGID;
> >
> >         if (unlikely(kill && !capable(CAP_FSETID) && S_ISREG(mode)))
> >                 return kill;
> >
> >         return 0;
> > }
> > EXPORT_SYMBOL(should_remove_suid);
> >
> > Oh wait, is that an implicit use of current_cred in vfs_write?  No, it
> > couldn't be.  Kernel developers *never* make that mistake.
> >
> > This is, of course, totally fucked because this function doesn't have
> > access to a struct file and therefore can't see f_cred.  I'm not going
> > to look in to this right now, but I swear I saw an exploit that took
> > advantage of this bug recently.  Anyone want to try to fix it?
>
> Good point. it's here since 2.3.43.
> As I see file->f_cred is reachable in all places.

Nope, vfs_truncate doesn't have f_cred reachable.  All other call sites are fine

And here's the reference:

http://www.halfdog.net/Security/2015/SetgidDirectoryPrivilegeEscalation/

Seriously, can we get away with removing the capable() check outright?
 nfs already explicitly ignores capabilities for this purpose, and in
my opinion having a security decision on write depend the FSETID
capability is just BS.  I'm a bit afraid of breaking some package
manager, though.

What a clusterfsck.

--Andy

>
> >
> > FWIW, posix says (man 3p write):
> >
> >        Upon  successful  completion,  where  nbyte  is greater than 0, write()
> >        shall mark for update the last data modification and last  file  status
> >        change  timestamps  of the file, and if the file is a regular file, the
> >        S_ISUID and S_ISGID bits of the file mode may be cleared.
> >
> > so maybe the thing to do is just drop the capable check entirely and
> > cross our fingers that nothing was relying on it.
> >
> > --Andy
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
