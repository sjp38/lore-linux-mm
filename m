Received: from balaton.wat.veritas.com([10.10.97.7]) (2020 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1GTg5N-0000TAC@megami.veritas.com>
	for <linux-mm@kvack.org>; Sat, 30 Sep 2006 07:45:01 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Sat, 30 Sep 2006 15:45:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Question: why hold source mm->mmap_sem write sem in dup_mmap()?
In-Reply-To: <000301c6e42c$12a62490$ff0da8c0@amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0609301504030.5193@blonde.wat.veritas.com>
References: <000301c6e42c$12a62490$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 29 Sep 2006, Chen, Kenneth W wrote:
> In the call chain of copy_page_range coming from do_fork(), dup_mmap holds
> write semaphore on the oldmm.  I don't see copy_page_range() or dup_mmap
> itself alter the source (oldmm)'s address space, what is the reason to hold
> write semaphore on the source mm?  Won't a down_read(&oldmm->mmap_sem) be
> sufficient?  Did I miss something there?

Good question, I think you're right: it's just a leftover from when 2.4.3
changed mmap_sem to an rwsem, and most down()s became down_write()s, with
the advantageously-concurrent faulting ones changed to down_read()s.

(For a while it was thought to hold rss steady, so copy_page_range didn't
bother to increment: but that only applied to faulting in, it was no
protection against vmscan swapping out, and so had to be fixed later.)

Hold on, there is one thing it's guarding against: expand_stack(), which
may extend stack vma with only down_read of mmap_sem (+ anon_vma_lock),
and in the downward case needs to adjust vm_start and vm_pgoff together.
Though I doubt that's conscious, nor a good reason to keep the down_write.

And I notice that total_vm and the vm_stat_account fields have been
copied over from oldmm to new mm, without any hold on mmap_sem at all:
not very serious, but we ought to fix it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
