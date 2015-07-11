Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B06086B0253
	for <linux-mm@kvack.org>; Sat, 11 Jul 2015 15:43:42 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so202068847pdb.1
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 12:43:42 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id ob4si7298899pdb.122.2015.07.11.12.43.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jul 2015 12:43:41 -0700 (PDT)
Received: by pabvl15 with SMTP id vl15so184746029pab.1
        for <linux-mm@kvack.org>; Sat, 11 Jul 2015 12:43:41 -0700 (PDT)
Date: Sat, 11 Jul 2015 12:43:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] selinux: fix mprotect PROT_EXEC regression caused by mm
 change
In-Reply-To: <1436535659-13124-1-git-send-email-sds@tycho.nsa.gov>
Message-ID: <alpine.LSU.2.11.1507111233001.2032@eggly.anvils>
References: <1436535659-13124-1-git-send-email-sds@tycho.nsa.gov>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: paul@paul-moore.com, hughd@google.com, prarit@redhat.com, mstevens@fedoraproject.org, esandeen@redhat.com, david@fromorbit.com, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-mm@kvack.org, wagi@monom.org, selinux@tycho.nsa.gov, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Fri, 10 Jul 2015, Stephen Smalley wrote:

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

Thank you for correcting that, Stephen (and for the nicely detailed
commit description): it looks right to me so I'll say

Acked-by: Hugh Dickins <hughd@google.com>

but I know far too little of SElinux, and its defaults, to confirm
whether it actually does all you need - I'll trust you on that.

(There being various other references to the file in file_map_prot_check()
and selinux_file_mprotect(), and I couldn't tell if they should or should
not be modified by IS_PRIVATE(file_inode(file) checks too: my best guess
was that they wouldn't matter.)

> ---
>  security/selinux/hooks.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 6231081..564079c 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -3283,7 +3283,8 @@ static int file_map_prot_check(struct file *file, unsigned long prot, int shared
>  	int rc = 0;
>  
>  	if (default_noexec &&
> -	    (prot & PROT_EXEC) && (!file || (!shared && (prot & PROT_WRITE)))) {
> +	    (prot & PROT_EXEC) && (!file || IS_PRIVATE(file_inode(file)) ||
> +				   (!shared && (prot & PROT_WRITE)))) {
>  		/*
>  		 * We are making executable an anonymous mapping or a
>  		 * private file mapping that will also be writable.
> -- 
> 2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
