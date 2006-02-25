Date: Fri, 24 Feb 2006 16:57:41 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: Fix sys_migrate_pages: Move all pages when invoked from root
In-Reply-To: <20060224164733.6d5224a5.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0602241649530.24668@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0602241616540.24013@schroedinger.engr.sgi.com>
 <20060224164733.6d5224a5.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Feb 2006, Andrew Morton wrote:

> What a strange interface.  One would expect the syscall to pass in an arg
> saying "move my pages" or "move all pages", and then permission checking
> will either do that or it will reject it.

Another approach is to say that the migrate_pages() call moves the pages 
it is allowed to. A user should not move pages of other processes whereas
root is expected to be able to do everything. Migrate means migrate 
whatever you can because the pages are on the wrong nodes. And a regular 
user can only move his own stuff.

A detailed control over page migration is possible via the mbind() 
function call. Hmmm... Although adding some flag to sys_migrate_pages 
would allow more flexibility for root and may also allow other flags in 
the fture.

> As it stands, programs will silently behave differently depending upon
> whether root ran them, which is silly.

The processes affected will still run correctly and the user may only 
notice a performance difference.

> Also, this check from a few lines earlier:
> 
> 	/*
> 	 * Check if this process has the right to modify the specified
> 	 * process. The right exists if the process has administrative
> 	 * capabilities, superuser priviledges or the same
> 	 * userid as the target process.
> 	 */
> 	if ((current->euid != task->suid) && (current->euid != task->uid) &&
> 	    (current->uid != task->suid) && (current->uid != task->uid) &&
> 	    !capable(CAP_SYS_ADMIN)) {
> 		err = -EPERM;
> 		goto out;
> 	}
> 
> appears to be a) somewhat duplicative of your patch and b) a heck of a lot
> better way of determining whether to use MF_MOVE versus MF_MOVE_ALL.

Huh? This only checks the permission for allow a process to start 
migration another process. It does not define the scope of actions.

How could this determine if a user would be allowed to move all pages? 
If a user would be allowed to move all pages then he could move f.e. 
glibc or ldso pages (these are heavily shared) to a bad location affecting 
the performance of the processes of other users on the system.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
