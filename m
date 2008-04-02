From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] Re: [patch 1/9] EMM Notifier: The notifier calls
Date: Wed, 2 Apr 2008 23:53:34 +0200
Message-ID: <20080402215334.GT19189@duo.random>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Wed, Apr 02, 2008 at 10:59:50AM -0700, Christoph Lameter wrote:
> Did I see #v10? Could you start a new subject when you post please? Do 
> not respond to some old message otherwise the threading will be wrong.

I wasn't clear enough, #v10 was in the works... I was thinking about
the last two issues before posting it.

> How exactly does the GRU corrupt memory?

Jack added synchronize_rcu, I assume for a reason.

>  
> >    Another less obviously safe approach is to allow the register
> >    method to succeed only when mm_users=1 and the task is single
> >    threaded. This way if all the places where the mmu notifers aren't
> >    invoked on the mm not by the current task, are only doing
> >    invalidates after/before zapping ptes, if the istantiation of new
> >    ptes is single threaded too, we shouldn't worry if we miss an
> >    invalidate for a pte that is zero and doesn't point to any physical
> >    page. In the places where current->mm != mm I'm using
> >    invalidate_page 99% of the time, and that only follows the
> >    ptep_clear_flush. The problem are the range_begin that will happen
> >    before zapping the pte in places where current->mm !=
> >    mm. Unfortunately in my incremental patch where I move all
> >    invalidate_page outside of the PT lock to prepare for allowing
> >    sleeping inside the mmu notifiers, I used range_begin/end in places
> >    like try_to_unmap_cluster where current->mm != mm. In general
> >    this solution looks more fragile than the seqlock.
> 
> Hmmm... Okay that is one solution that would just require a BUG_ON in the 
> registration methods.

Perhaps you didn't notice that this solution can't work if you call
range_begin/end not in the "current" context and try_to_unmap_cluster
does exactly that for both my patchset and yours. Missing an _end is
ok, missing a _begin is never ok.

> Well doesnt the requirement of just one execution thread also deal with 
> that issue?

Yes, except again it can't work for try_to_unmap_cluster.

This solution is only applicable to #v10 if I fix try_to_unmap_cluster
to only call invalidate_page (relaying on the fact the VM holds a pin
and a lock on any page that is being mmu-notifier-invalidated).

You can't use the single threaded approach to solve either 1 or 2,
because your _begin call is called anywhere and that's where you call
the secondary-tlb flush and it's fatal to miss it.

invalidate_page is called always after, so it enforced the tlb flush
to be called _after_ and so it's inherently safe.
