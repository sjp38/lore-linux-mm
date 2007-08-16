Date: Wed, 15 Aug 2007 23:06:26 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: Question:  cpuset_update_task_memory_state() and mmap_sem ???
Message-Id: <20070815230626.dac091b1.pj@sgi.com>
In-Reply-To: <1187033902.5592.33.camel@localhost>
References: <1187033902.5592.33.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Lee wrote:
> In the comment block for the subject function in cpuset.c, it notes that
> "This routine also might acquire callback_mutex and
> current->mm->mmap_sem."
> 
> Is this is a stale comment?  I can't find any path from this function to
> a down_{read|write}() on the caller's mmap_sem [in 23-rc2-mm2].  I
> suspect that one would have noticed, as
> cpuset_update_task_memory_state() is called from
> alloc_page_vma() which, according to its comment block, can only be
> called with the mmap_sem held [for read, at least].

Hmmm ... you may be right  But I'm not sure.

Obviously, the callback_mutex mention in the comment is correct,
but the current->mm->mmap_sem mention seems bogus.

The routine mpol_rebind_task() is called from the last line of
cpuset_update_task_memory_state().  Whatever mmap_sem is taken
would be within that call.  But I can't find any taking of
mmap_sem within or below mpol_rebind_task(), and all the code
paths in mm/mempolicy.c that do take mmap_sem locks seem to be
on unrelated code paths.

I tried looking in a few old versions of kernel/cpuset.c and
mm/mempolicy.c to see if the mention of current->mm->mmap_sem
made more sense in some old version, but didn't see any version
of code that justified that comment.

... would you like to propose a patch, nuking the phrase:

   and current->mm->mmap_sem

from that comment?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
