Date: Fri, 14 Jan 2005 22:47:50 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
In-Reply-To: <20050114222210.51725.qmail@web14324.mail.yahoo.com>
Message-ID: <Pine.LNX.4.44.0501142243430.3143-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, davem@redhat.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, 14 Jan 2005, Kanoj Sarcar wrote:
> 
> Note that vmtruncate() does a i_size_write(), which
> does a write_seqcount_end() after updating the i_size,
> which has an embedded smp_wmb() right after the i_size
> update, so the case you are talking about is already
> handled. No? (Btw, I did not look at i_size_write() in
> the case of !CONFIG_SMP and CONFIG_PREEMPT, there
> might need to be some barriers put in there, not
> sure).
> 
> But, based on what you said, yes, I believe an
> smp_wmb() is required _after_
> atomic_inc(truncate_count) in unmap_mapping_range() to
> ensure that the write happens before  it does the TLB
> shootdown. Right?

Hmm, I'd better look tomorrow to see where you and
Andrea have decided the smp_wmb()s should go.

> I am sure there might be other ways to clean up this
> code. Some documentation could not hurt, it could save
> everyone's head hurting when they look at this code!
> 
> Btw, do all callers of vmtruncate() guarantee they do
> not concurrently invoke vmtruncate() on the same file?
> Seems like they could be stepping on each other while
> updating i_size ...

We're on safer ground there: inode->i_sem is held.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
