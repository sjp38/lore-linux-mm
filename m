From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] Re: [patch 1/9] EMM Notifier: The notifier calls
Date: Wed, 2 Apr 2008 10:59:50 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com>
	<20080402064952.GF19189@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080402064952.GF19189@duo.random>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Wed, 2 Apr 2008, Andrea Arcangeli wrote:

> There are much bigger issues besides the rcu safety in this patch,
> proper aging of the secondary mmu through access bits set by hardware
> is unfixable with this model (you would need to do age |=
> e->callback), which is the proof of why this isn't flexibile enough by
> forcing the same parameter and retvals for all methods. No idea why
> you go for such inferior solution that will never get the aging right
> and will likely fall apart if we add more methods in the future.

There is always the possibility to add special functions in the same way 
as done in the mmu notifier series if it really becomes necessary. EMM 
does  in no way preclude that.

Here f.e. We can add a special emm_age() function that iterates 
differently and does the | for you.

> For example the "switch" you have to add in
> xpmem_emm_notifier_callback doesn't look good, at least gcc may be
> able to optimize it with an array indexing simulating proper pointer
> to function like in #v9.

Actually the switch looks really good because it allows code to run
for all callbacks like f.e. xpmem_tg_ref(). Otherwise the refcounting code 
would have to be added to each callback.

> 
> Most other patches will apply cleanly on top of my coming mmu
> notifiers #v10 that I hope will go in -mm.
> 
> For #v10 the only two left open issues to discuss are:

Did I see #v10? Could you start a new subject when you post please? Do 
not respond to some old message otherwise the threading will be wrong.

>    methods will be correctly replied allowing GRU not to corrupt
>    memory after the registration method. EMM would also need a fix
>    like this for GRU to be safe on top of EMM.

How exactly does the GRU corrupt memory?
 
>    Another less obviously safe approach is to allow the register
>    method to succeed only when mm_users=1 and the task is single
>    threaded. This way if all the places where the mmu notifers aren't
>    invoked on the mm not by the current task, are only doing
>    invalidates after/before zapping ptes, if the istantiation of new
>    ptes is single threaded too, we shouldn't worry if we miss an
>    invalidate for a pte that is zero and doesn't point to any physical
>    page. In the places where current->mm != mm I'm using
>    invalidate_page 99% of the time, and that only follows the
>    ptep_clear_flush. The problem are the range_begin that will happen
>    before zapping the pte in places where current->mm !=
>    mm. Unfortunately in my incremental patch where I move all
>    invalidate_page outside of the PT lock to prepare for allowing
>    sleeping inside the mmu notifiers, I used range_begin/end in places
>    like try_to_unmap_cluster where current->mm != mm. In general
>    this solution looks more fragile than the seqlock.

Hmmm... Okay that is one solution that would just require a BUG_ON in the 
registration methods.

> 2) I'm uncertain how the driver can handle a range_end called before
>    range_begin. Also multiple range_begin can happen in parallel later
>    followed by range_end, so if there's a global seqlock that
>    serializes the secondary mmu page fault, that will screwup (you
>    can't seqlock_write in range_begin and sequnlock_write in
>    range_end). The write side of the seqlock must be serialized and
>    calling seqlock_write twice in a row before any sequnlock operation
>    will break.

Well doesnt the requirement of just one execution thread also deal with 
that issue?
