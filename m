From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [ofa-general] Re: EMM: disable other notifiers before register and
	unregister
Date: Thu, 03 Apr 2008 12:40:48 +0200
Message-ID: <1207219248.8514.819.camel@twins>
References: <20080401205531.986291575@sgi.com>
	<20080401205635.793766935@sgi.com> <20080402064952.GF19189@duo.random>
	<Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
	<20080402220148.GV19189@duo.random>
	<Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
	<20080402221716.GY19189@duo.random>
	<Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
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
Cc: Nick Piggin <npiggin@suse.de>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-Id: linux-mm.kvack.org

On Wed, 2008-04-02 at 18:24 -0700, Christoph Lameter wrote:
> Ok lets forget about the single theaded thing to solve the registration 
> races. As Andrea pointed out this still has ssues with other subscribed 
> subsystems (and also try_to_unmap). We could do something like what 
> stop_machine_run does: First disable all running subsystems before 
> registering a new one.
> 
> Maybe this is a possible solution.
> 
> 
> Subject: EMM: disable other notifiers before register and unregister
> 
> As Andrea has pointed out: There are races during registration if other
> subsystem notifiers are active while we register a callback.
> 
> Solve that issue by adding two new notifiers:
> 
> emm_stop
> 	Stops the notifier operations. Notifier must block on
> 	invalidate_start and emm_referenced from this point on.
> 	If an invalidate_start has not been completed by a call
> 	to invalidate_end then the driver must wait until the
> 	operation is complete before returning.
> 
> emm_start
> 	Restart notifier operations.

Please use pause and resume or something like that. stop-start is an
unnatural order; we usually start before we stop, whereas we pause first
and resume later.

> Before registration all other subscribed subsystems are stopped.
> Then the new subsystem is subscribed and things can get running
> without consistency issues.
> 
> Subsystems are restarted after the lists have been updated.
> 
> This also works for unregistering. If we can get all subsystems
> to stop then we can also reliably unregister a subsystem. So
> provide that callback.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  include/linux/rmap.h |   10 +++++++---
>  mm/rmap.c            |   30 ++++++++++++++++++++++++++++++
>  2 files changed, 37 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/include/linux/rmap.h
> ===================================================================
> --- linux-2.6.orig/include/linux/rmap.h	2008-04-02 18:16:07.906032549 -0700
> +++ linux-2.6/include/linux/rmap.h	2008-04-02 18:17:10.291070009 -0700
> @@ -94,7 +94,9 @@ enum emm_operation {
>  	emm_release,		/* Process exiting, */
>  	emm_invalidate_start,	/* Before the VM unmaps pages */
>  	emm_invalidate_end,	/* After the VM unmapped pages */
> - 	emm_referenced		/* Check if a range was referenced */
> + 	emm_referenced,		/* Check if a range was referenced */
> +	emm_stop,		/* Halt all faults/invalidate_starts */
> +	emm_start,		/* Restart operations */
>  };
>  
>  struct emm_notifier {
> @@ -126,13 +128,15 @@ static inline int emm_notify(struct mm_s
>  
>  /*
>   * Register a notifier with an mm struct. Release occurs when the process
> - * terminates by calling the notifier function with emm_release.
> + * terminates by calling the notifier function with emm_release or when
> + * emm_notifier_unregister is called.
>   *
>   * Must hold the mmap_sem for write.
>   */
>  extern void emm_notifier_register(struct emm_notifier *e,
>  					struct mm_struct *mm);
> -
> +extern void emm_notifier_unregister(struct emm_notifier *e,
> +					struct mm_struct *mm);
>  
>  /*
>   * Called from mm/vmscan.c to handle paging out
> Index: linux-2.6/mm/rmap.c
> ===================================================================
> --- linux-2.6.orig/mm/rmap.c	2008-04-02 18:16:09.378057062 -0700
> +++ linux-2.6/mm/rmap.c	2008-04-02 18:16:10.710079201 -0700
> @@ -289,16 +289,46 @@ void emm_notifier_release(struct mm_stru
>  /* Register a notifier */
>  void emm_notifier_register(struct emm_notifier *e, struct mm_struct *mm)
>  {
> +	/* Bring all other notifiers into a quiescent state */
> +	emm_notify(mm, emm_stop, 0, TASK_SIZE);
> +
>  	e->next = mm->emm_notifier;
> +
>  	/*
>  	 * The update to emm_notifier (e->next) must be visible
>  	 * before the pointer becomes visible.
>  	 * rcu_assign_pointer() does exactly what we need.
>  	 */
>  	rcu_assign_pointer(mm->emm_notifier, e);
> +
> +	/* Continue notifiers */
> +	emm_notify(mm, emm_start, 0, TASK_SIZE);
>  }
>  EXPORT_SYMBOL_GPL(emm_notifier_register);
>  
> +/* Unregister a notifier */
> +void emm_notifier_unregister(struct emm_notifier *e, struct mm_struct *mm)
> +{
> +	struct emm_notifier *p;
> +
> +	emm_notify(mm, emm_stop, 0, TASK_SIZE);
> +
> +	p = mm->emm_notifier;
> +	if (e == p)
> +		mm->emm_notifier = e->next;
> +	else {
> +		while (p->next != e)
> +			p = p->next;
> +
> +		p->next = e->next;
> +	}
> +	e->next = mm->emm_notifier;
> +
> +	emm_notify(mm, emm_start, 0, TASK_SIZE);
> +	e->callback(e, mm, emm_release, 0, TASK_SIZE);
> +}
> +EXPORT_SYMBOL_GPL(emm_notifier_unregister);
> +
>  /*
>   * Perform a callback
>   *
> 
