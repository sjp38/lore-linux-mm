Date: Fri, 14 Jan 2005 22:38:16 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
Message-ID: <20050114213816.GL8709@dualathlon.random>
References: <Pine.LNX.4.44.0501142012300.2938-100000@localhost.localdomain> <20050114211441.59635.qmail@web14305.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050114211441.59635.qmail@web14305.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Hugh Dickins <hugh@veritas.com>, Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, davem@redhat.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 14, 2005 at 01:14:40PM -0800, Kanoj Sarcar wrote:
> 
> unmap_mapping_range()
> 8. spin_lock(&mapping->i_mmap_lock); /* irrelevant */
> 9. atomic_inc(&mapping->truncate_count);

The above trace doesn't start there, it's the i_size_write/read we're
serializing against. You should start the above with i_size_write, then
it would make sense.

We probably thought the above spinlock was relevant (and that's why
there's no smp_wmb there yet) but it isn't, because it has inclusive
semantics, and in turn the i_size_write can pass it and it can even pass
atomic_inc (in common code terms of course, on x86 not). So we need a
smp_wmb() before atomic_inc too to be correct (not an issue for x86).
While the reader part (i.e. the smp_rmb erroneously removed), is an
issue at the very least for x86-64 and probably for x86 too despite the
increased 64bit locking for the long long i_size. since those x86* archs
can reorder reads (but not writes). (and atomic_read isn't implying any
cpu barrier, it's only a compiler barrier) So the bug you opened up is
real, while the missing smp_wmb I just noticed is not real for x86* and
it's theoretical only for ia64.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
