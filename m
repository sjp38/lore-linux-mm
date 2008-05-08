Date: Thu, 8 May 2008 04:24:24 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 08 of 11] anon-vma-rwsem
Message-ID: <20080508022424.GU8276@duo.random>
References: <20080507153103.237ea5b6.akpm@linux-foundation.org> <20080507224406.GI8276@duo.random> <20080507155914.d7790069.akpm@linux-foundation.org> <alpine.LFD.1.10.0805071610490.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071637360.14337@schroedinger.engr.sgi.com> <alpine.LFD.1.10.0805071655100.3024@woody.linux-foundation.org> <Pine.LNX.4.64.0805071752490.14829@schroedinger.engr.sgi.com> <alpine.LFD.1.10.0805071833450.3024@woody.linux-foundation.org> <20080508015249.GT8276@duo.random> <alpine.LFD.1.10.0805071853500.3024@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.1.10.0805071853500.3024@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, steiner@sgi.com, holt@sgi.com, npiggin@suse.de, a.p.zijlstra@chello.nl, kvm-devel@lists.sourceforge.net, kanojsarcar@yahoo.com, rdreier@cisco.com, swise@opengridcomputing.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, general@lists.openfabrics.org, hugh@veritas.com, rusty@rustcorp.com.au, aliguori@us.ibm.com, chrisw@redhat.com, marcelo@kvack.org, dada1@cosmosbay.com, paulmck@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2008 at 06:57:05PM -0700, Linus Torvalds wrote:
> Take five minutes. Take a deep breadth. And *think* about actually reading 
> what I wrote.
> 
> The bitflag *can* prevent taking the same lock twice. It just needs to be 
> in the right place.

It's not that I didn't read it, but to do it I've to grow every
anon_vma by 8 bytes. I thought it was implicit that the conclusion of
your email is that it couldn't possibly make sense to grow the size of
each anon_vma by 33%, when nobody loaded the kvm or gru or xpmem
kernel modules. It surely isn't my preferred solution, while capping
the number of vmas to 1024 means sort() will make around 10240 steps,
Matt call tell the exact number. The big cost shouldn't be in
sort. Even 512 vmas will be more than enough for us infact. Note that
I've a cond_resched in the sort compare function and I can re-add the
signal_pending check. I had the signal_pending check in the original
version that didn't use sort() but was doing an inner loop, I thought
signal_pending wasn't necessary after speeding it up with sort(). But
I can add it again, so then we'll only fail to abort inside sort() and
we'll be able to break the loop while taking all the spinlocks, but
with such as small array that can't be an issue and the result will
surely run faster than stop_machine with zero ram and cpu overhead for
the VM (besides stop_machine can't work or we'd need to disable
preemption between invalidate_range_start/end, even removing the xpmem
schedule-inside-mmu-notifier requirement).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
