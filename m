Date: Fri, 24 Feb 2006 17:15:01 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fix sys_migrate_pages: Move all pages when invoked from root
Message-Id: <20060224171501.1e19d34a.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0602241649530.24668@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241616540.24013@schroedinger.engr.sgi.com>
	<20060224164733.6d5224a5.akpm@osdl.org>
	<Pine.LNX.4.64.0602241649530.24668@schroedinger.engr.sgi.com>
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
> > Also, this check from a few lines earlier:
> > 
> > 	/*
> > 	 * Check if this process has the right to modify the specified
> > 	 * process. The right exists if the process has administrative
> > 	 * capabilities, superuser priviledges or the same
> > 	 * userid as the target process.
> > 	 */
> > 	if ((current->euid != task->suid) && (current->euid != task->uid) &&
> > 	    (current->uid != task->suid) && (current->uid != task->uid) &&
> > 	    !capable(CAP_SYS_ADMIN)) {
> > 		err = -EPERM;
> > 		goto out;
> > 	}
> > 
> > appears to be a) somewhat duplicative of your patch and b) a heck of a lot
> > better way of determining whether to use MF_MOVE versus MF_MOVE_ALL.
> 
> Huh? This only checks the permission for allow a process to start 
> migration another process. It does not define the scope of actions.
> 
> How could this determine if a user would be allowed to move all pages? 

You want a check which says "can this user move that user's pages".  The
current proposal is to use CAP_SYS_ADMIN, which is a bit coarse.

<looks>

Oh, it uses the mapcount rather than a permission check on vma->vm_file. 
Oh well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
