Date: Mon, 17 Oct 2005 19:13:40 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC] OVERCOMMIT_ALWAYS extension
In-Reply-To: <1129570219.23632.34.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.61.0510171904040.6406@goblin.wat.veritas.com>
References: <1129570219.23632.34.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Oct 2005, Badari Pulavarty wrote:
> 
> I have been looking at possible ways to extend OVERCOMMIT_ALWAYS
> to avoid its abuse.
> 
> Few of the applications (database) would like to overcommit
> memory (by creating shared memory segments more than RAM+swap),
> but use only portion of it at any given time and get rid
> of portions of them through madvise(DONTNEED), when needed. 
> They want this, especially to handle hotplug memory situations 
> (where apps may not have clear idea on how much memory they have 
> in the system at the time of shared memory create). Currently, 
> they are using OVERCOMMIT_ALWAYS system wide to do this - but 
> they are affecting every other application on the system.
> 
> I am wondering, if there is a better way to do this. Simple solution
> would be to add IPC_OVERCOMMIT flag or add CAP_SYS_ADMIN to
> do the overcommit. This way only specific applications, requesting
> this would be able to overcommit. I am worried about, the over
> all affects it has on the system. But again, this can't be worse
> than system wide  OVERCOMMIT_ALWAYS. Isn't it ?

mmap has MAP_NORESERVE, without CAP_SYS_ADMIN or other restriction,
which exempts that mmap from security_vm_enough_memory checking -
unless current setting is OVERCOMMIT_NEVER, in which case
MAP_NORESERVE is ignored.

So if you're content to move to the OVERCOMMIT_GUESS world, I
don't think you could be blamed for adding an IPC_NORESERVE which
behaves in the same way, without CAP_SYS_ADMIN restriction.

But if you want to move to OVERCOMMIT_NEVER, yet have a flag which
says overcommit now, you'll get into a tussle with NEVER-adherents.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
