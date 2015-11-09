Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB616B0255
	for <linux-mm@kvack.org>; Sun,  8 Nov 2015 19:24:24 -0500 (EST)
Received: by wmww144 with SMTP id w144so18372321wmw.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 16:24:24 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id b17si13516070wma.52.2015.11.08.16.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 16:24:23 -0800 (PST)
Received: by wmec201 with SMTP id c201so61470014wme.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 16:24:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1511081504460.14116@eggly.anvils>
References: <1446559981-26025-1-git-send-email-agruenba@redhat.com>
	<alpine.LSU.2.11.1511081504460.14116@eggly.anvils>
Date: Mon, 9 Nov 2015 01:24:23 +0100
Message-ID: <CAHpGcM+Wnt75ebrmsu3_GOuGESa9Pr8yEhwL3-Tbabsg+K20xw@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: listxattr should include POSIX ACL xattrs
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Michael Kerrisk <michael.kerrisk@gmail.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>, Aristeu Rozanski <arozansk@redhat.com>, Eric Paris <eparis@redhat.com>, linux-mm@kvack.org, Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>

2015-11-09 0:37 GMT+01:00 Hugh Dickins <hughd@google.com>:
> On Tue, 3 Nov 2015, Andreas Gruenbacher wrote:
>
>> When a file on tmpfs has an ACL or a Default ACL, listxattr should include the
>> corresponding xattr names.
>>
>> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
>> ---
>>  fs/kernfs/inode.c     |  2 +-
>>  fs/xattr.c            | 53 +++++++++++++++++++++++++++++++++++----------------
>>  include/linux/xattr.h |  2 +-
>>  mm/shmem.c            |  2 +-
>>  4 files changed, 40 insertions(+), 19 deletions(-)
>
> Hmm, can you make a stronger argument for this patch than above?
>
> My ignorance of ACLs and XATTRs is boundless, I'll have to defer to
> you and others.

That shouldn't be a problem.

> But when I read the listxattr(2) manpage saying
> "Filesystems like ext2, ext3 and XFS which implement POSIX ACLs
> using extended attributes, might return a list like ...",
> I don't see that as mandating that any filesystem which happens
> for its own internal convenience to implement ACLs via XATTRs,
> has to list the ACLs with the XATTRs - I read it rather as an
> apology that some of them (for their own simplicity) do so.

The user-space interface for POSIX ACLs is always the same no matter
how they are implemented in the kernel: they are exposed as two
extended attributes called "system.posix_acl_access" (directories and
non-directories) and "system.posix_acl_default" (diectories only). The
extended attribute syscalls are [fl]getxattr, [fl]setxattr,
[fl]listxattr, and [fl]removexattr.

The listxattr syscalls is expected to list all the attributes which
the calling process is allowed to see / access. Tmpfs misbehaves in
this regard; it doesn't list the extended attributes for POSIX ACLs
even when they are set.

This example on the listxattr manpage is rather unfortunate and should
be fixed; how filesystems implement stuff internally should really be
of no relevance here. I'm taking Michael into the CC.

> If this patch simplified the code, I'd be all for it;
> but it's the reverse, and we seem to have survived for several
> years without it: I don't see yet why it's needed.

It's a confusing inconsistency. Many utilities like ls and
getfacl/setfacl check for the presence of POSIX ACLs with getxattr,
they don't use listxattr for that. Other utilities that rely on
listxattr currently won't see when objects on tmpfs have POSIX ACLs
though; this is bad.

> I've no
> fundamental objection, but I'd like to understand why it's
> a step forwards rather than a step backwards.

Yes, I hope I could explain that well enough.

Thanks,
Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
