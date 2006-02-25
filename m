Date: Fri, 24 Feb 2006 16:47:33 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fix sys_migrate_pages: Move all pages when invoked from root
Message-Id: <20060224164733.6d5224a5.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0602241616540.24013@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241616540.24013@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> Currently sys_migrate_pages only moves pages belonging to a process.
> This is okay when invoked from a regular user. But if invoked from
> root it should move all pages as documented in the migrate_pages manpage.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.16-rc4/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.16-rc4.orig/mm/mempolicy.c	2006-02-24 14:32:02.000000000 -0800
> +++ linux-2.6.16-rc4/mm/mempolicy.c	2006-02-24 15:44:24.000000000 -0800
> @@ -940,7 +940,8 @@ asmlinkage long sys_migrate_pages(pid_t 
>  		goto out;
>  	}
>  
> -	err = do_migrate_pages(mm, &old, &new, MPOL_MF_MOVE);
> +	err = do_migrate_pages(mm, &old, &new,
> +		capable(CAP_SYS_ADMIN) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
>  out:
>  	mmput(mm);
>  	return err;

What a strange interface.  One would expect the syscall to pass in an arg
saying "move my pages" or "move all pages", and then permission checking
will either do that or it will reject it.

As it stands, programs will silently behave differently depending upon
whether root ran them, which is silly.

Also, this check from a few lines earlier:

	/*
	 * Check if this process has the right to modify the specified
	 * process. The right exists if the process has administrative
	 * capabilities, superuser priviledges or the same
	 * userid as the target process.
	 */
	if ((current->euid != task->suid) && (current->euid != task->uid) &&
	    (current->uid != task->suid) && (current->uid != task->uid) &&
	    !capable(CAP_SYS_ADMIN)) {
		err = -EPERM;
		goto out;
	}

appears to be a) somewhat duplicative of your patch and b) a heck of a lot
better way of determining whether to use MF_MOVE versus MF_MOVE_ALL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
