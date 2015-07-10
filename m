Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 15F4D9003C7
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 16:30:59 -0400 (EDT)
Received: by obdbs4 with SMTP id bs4so198298211obd.3
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:30:58 -0700 (PDT)
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com. [209.85.214.173])
        by mx.google.com with ESMTPS id wc3si7614781oeb.6.2015.07.10.13.30.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Jul 2015 13:30:58 -0700 (PDT)
Received: by obbkm3 with SMTP id km3so198016309obb.1
        for <linux-mm@kvack.org>; Fri, 10 Jul 2015 13:30:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1436535659-13124-1-git-send-email-sds@tycho.nsa.gov>
References: <1436535659-13124-1-git-send-email-sds@tycho.nsa.gov>
Date: Fri, 10 Jul 2015 16:30:57 -0400
Message-ID: <CAHC9VhTMvQP034xj9xq6Bcfre4ZCFTzGOGcUyPzKD-rBrOJOsg@mail.gmail.com>
Subject: Re: [PATCH] selinux: fix mprotect PROT_EXEC regression caused by mm change
From: Paul Moore <paul@paul-moore.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: hughd@google.com, prarit@redhat.com, mstevens@fedoraproject.org, esandeen@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org, Eric Paris <eparis@redhat.com>, linux-mm@kvack.org, wagi@monom.org, selinux@tycho.nsa.gov, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Jul 10, 2015 at 9:40 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
> commit 66fc13039422ba7df2d01a8ee0873e4ef965b50b ("mm: shmem_zero_setup skip
> security check and lockdep conflict with XFS") caused a regression for
> SELinux by disabling any SELinux checking of mprotect PROT_EXEC on
> shared anonymous mappings.  However, even before that regression, the
> checking on such mprotect PROT_EXEC calls was inconsistent with the
> checking on a mmap PROT_EXEC call for a shared anonymous mapping.  On a
> mmap, the security hook is passed a NULL file and knows it is dealing with
> an anonymous mapping and therefore applies an execmem check and no file
> checks.  On a mprotect, the security hook is passed a vma with a
> non-NULL vm_file (as this was set from the internally-created shmem
> file during mmap) and therefore applies the file-based execute check and
> no execmem check.  Since the aforementioned commit now marks the shmem
> zero inode with the S_PRIVATE flag, the file checks are disabled and
> we have no checking at all on mprotect PROT_EXEC.  Add a test to
> the mprotect hook logic for such private inodes, and apply an execmem
> check in that case.  This makes the mmap and mprotect checking consistent
> for shared anonymous mappings, as well as for /dev/zero and ashmem.
>
> Signed-off-by: Stephen Smalley <sds@tycho.nsa.gov>
> ---
>  security/selinux/hooks.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Thanks for the discussion, and the patch.  I'll send this up to James
for 4.2 and mark it for stable.

> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 6231081..564079c 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -3283,7 +3283,8 @@ static int file_map_prot_check(struct file *file, unsigned long prot, int shared
>         int rc = 0;
>
>         if (default_noexec &&
> -           (prot & PROT_EXEC) && (!file || (!shared && (prot & PROT_WRITE)))) {
> +           (prot & PROT_EXEC) && (!file || IS_PRIVATE(file_inode(file)) ||
> +                                  (!shared && (prot & PROT_WRITE)))) {
>                 /*
>                  * We are making executable an anonymous mapping or a
>                  * private file mapping that will also be writable.
> --
> 2.1.0
>

-- 
paul moore
www.paul-moore.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
