Date: Wed, 9 Apr 2008 16:29:45 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 02/10] emm: notifier logic
Message-ID: <20080409142945.GS10133@duo.random>
References: <20080404223048.374852899@sgi.com> <20080404223131.469710551@sgi.com> <20080405005759.GH14784@duo.random> <Pine.LNX.4.64.0804062246030.18148@schroedinger.engr.sgi.com> <20080407060602.GE9309@duo.random> <Pine.LNX.4.64.0804062314080.18728@schroedinger.engr.sgi.com> <20080407071330.GH9309@duo.random> <Pine.LNX.4.64.0804081320160.30874@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804081320160.30874@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 08, 2008 at 01:23:33PM -0700, Christoph Lameter wrote:
> It may also be useful to allow invalidate_start() to fail in some contexts 
> (try_to_unmap f.e., maybe if a certain flag is passed). This may allow the 
> device to get out of tight situations (pending I/O f.e. or time out if 
> there is no response for network communications). But then that 
> complicates the API.

That also complicates the fact that there can't be a spte mapped and a
pte not mapped or the spte would leak unswappable memory, so a failure
should re-establish the pte and undo the ptep_clear_flush or
equivalent... I think we can change the API later if needed. This is
an internal-only API invisible to userland so it can change and break
anytime to make the whole kernel faster and better (ask Greg for
kernel internal APIs).

One important detail is that because the secondary mmu page fault can
happen concurrently against invaldiate_page (there wasn't a
range_begin to block it), the secondary mmu page fault must ensure
that the pte is still established, before establishing the spte (with
proper locking that will block a concurrent invalidate_page). Having a
range_begin before the ptep_clear_flush effectively make lifes a bit
easier but it's not needed as those are locking issues that the driver
can solve (unlike range_begin being missed, now fixed by mm_lock) and
this allows for higher performance both when the lock is armed and
disarmed. I'm going to solve all the locking for kvm with spinlocks
and/or seqlocks to avoid any dependency on the patches that makes the
mmu notifier sleep capable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
