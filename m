Date: Thu, 17 Apr 2008 19:14:43 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related
	operation to happen
Message-ID: <20080417171443.GM17187@duo.random>
References: <patchbomb.1207669443@duo.random> <ec6d8f91b299cf26cce5.1207669444@duo.random> <20080416163337.GJ22493@sgi.com> <Pine.LNX.4.64.0804161134360.12296@schroedinger.engr.sgi.com> <20080417155157.GC17187@duo.random> <20080417163642.GE11364@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080417163642.GE11364@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 11:36:42AM -0500, Robin Holt wrote:
> In this case, we are not making the call to unregister, we are waiting
> for the _release callout which has already removed it from the list.
> 
> In the event that the user has removed all the grants, we use unregister.
> That typically does not occur.  We merely wait for exit processing to
> clean up the structures.

Then it's very strange. LIST_POISON1 is set in n->next. If it was a
second hlist_del triggering the bug in theory list_poison2 should
trigger first, so perhaps it's really a notifier running despite a
mm_lock is taken? Could you post a full stack trace so I can see who's
running into LIST_POISON1? If it's really a notifier running outside
of some mm_lock that will be _immediately_ visible from the stack
trace that triggered the LIST_POISON1!

Also note, EMM isn't using the clean hlist_del, it's implementing list
by hand (with zero runtime gain) so all the debugging may not be
existent in EMM, so if it's really a mm_lock race, and it only
triggers with mmu notifiers and not with EMM, it doesn't necessarily
mean EMM is bug free. If you've a full stack trace it would greatly
help to verify what is mangling over the list when the oops triggers.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
