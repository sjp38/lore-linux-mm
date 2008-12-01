Message-ID: <49345505.5050104@cs.columbia.edu>
Date: Mon, 01 Dec 2008 16:20:05 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v10][PATCH 08/13] Dump open file descriptors
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>	 <1227747884-14150-9-git-send-email-orenl@cs.columbia.edu>	 <20081128101919.GO28946@ZenIV.linux.org.uk>	 <1228153645.2971.36.camel@nimitz>  <493447DD.7010102@cs.columbia.edu> <1228164679.2971.91.camel@nimitz>
In-Reply-To: <1228164679.2971.91.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>



Dave Hansen wrote:
> On Mon, 2008-12-01 at 15:23 -0500, Oren Laadan wrote:
>> Verifying that the size doesn't change does not ensure that the table's
>> contents remained the same, so we can still end up with obsolete data.
> 
> With the realloc() scheme, we have virtually no guarantees about how the
> fdtable that we read relates to the source.  All that we know is that
> the n'th fd was at this value at *some* time.
> 
> Using the scheme that I just suggested (and you evidently originally
> used) at least guarantees that we have an atomic copy of the fdtable.

It doesn't matter if the fdtable changes while we scan the fd's or
after we're done scanning the fd's, does it ?  the end result is the
same - inconsistency.

> Why is this done in two steps?  It first grabs a list of fd numbers
> which needs to be validated, then goes back and turns those into 'struct
> file's which it saves off.  Is there a problem with doing that
> fd->'struct file' conversion under the files->file_lock?

Again, say we get all the struct file for all those fd's. Now we have to
drop the lock, and start processing the struct files. So what if at this
point the fdtable changes ?  we still end up with potentially inconsistent
state.

We can do it atomically or non-atomically, I couldn't care less.

My argument is the following:
1) Ideally, the state should not change while we are checkpointing
2) If the state changes, then the behavior is undefined (but the kernel
   should not crash, of course).
3) It should be the userspace responsibility to ensure that (1) holds
   (for instance, that all tasks sharing these resources are frozen
   during the checkpoint)

#2 will be an uncommon event - a programmer/user/administrator mistake.
Kernel may help enforce this rule, but catching all such cases will be
expensive as it means looping through all tasks for each new resource.

As a first step, we can ensure that all threads of a process are frozen
at checkpoint time (and prevent unfreeze until checkpoint is over). But
that will not cover a clone() with CLONE_FS. And this will be the same
for other namespaces later.

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
