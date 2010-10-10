Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7E2F76B006A
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 10:26:10 -0400 (EDT)
Date: Sun, 10 Oct 2010 16:25:51 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6 10/12] Handle async PF in non preemptable context
Message-ID: <20101010142551.GQ2397@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
 <1286207794-16120-11-git-send-email-gleb@redhat.com>
 <20101005195149.GC1786@amt.cnet>
 <20101006104132.GS11145@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101006104132.GS11145@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 12:41:32PM +0200, Gleb Natapov wrote:
> On Tue, Oct 05, 2010 at 04:51:50PM -0300, Marcelo Tosatti wrote:
> > On Mon, Oct 04, 2010 at 05:56:32PM +0200, Gleb Natapov wrote:
> > > If async page fault is received by idle task or when preemp_count is
> > > not zero guest cannot reschedule, so do sti; hlt and wait for page to be
> > > ready. vcpu can still process interrupts while it waits for the page to
> > > be ready.
> > > 
> > > Acked-by: Rik van Riel <riel@redhat.com>
> > > Signed-off-by: Gleb Natapov <gleb@redhat.com>
> > > ---
> > >  arch/x86/kernel/kvm.c |   40 ++++++++++++++++++++++++++++++++++------
> > >  1 files changed, 34 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
> > > index 36fb3e4..f73946f 100644
> > > --- a/arch/x86/kernel/kvm.c
> > > +++ b/arch/x86/kernel/kvm.c
> > > @@ -37,6 +37,7 @@
> > >  #include <asm/cpu.h>
> > >  #include <asm/traps.h>
> > >  #include <asm/desc.h>
> > > +#include <asm/tlbflush.h>
> > >  
> > >  #define MMU_QUEUE_SIZE 1024
> > >  
> > > @@ -78,6 +79,8 @@ struct kvm_task_sleep_node {
> > >  	wait_queue_head_t wq;
> > >  	u32 token;
> > >  	int cpu;
> > > +	bool halted;
> > > +	struct mm_struct *mm;
> > >  };
> > >  
> > >  static struct kvm_task_sleep_head {
> > > @@ -106,6 +109,11 @@ void kvm_async_pf_task_wait(u32 token)
> > >  	struct kvm_task_sleep_head *b = &async_pf_sleepers[key];
> > >  	struct kvm_task_sleep_node n, *e;
> > >  	DEFINE_WAIT(wait);
> > > +	int cpu, idle;
> > > +
> > > +	cpu = get_cpu();
> > > +	idle = idle_cpu(cpu);
> > > +	put_cpu();
> > >  
> > >  	spin_lock(&b->lock);
> > >  	e = _find_apf_task(b, token);
> > > @@ -119,19 +127,33 @@ void kvm_async_pf_task_wait(u32 token)
> > >  
> > >  	n.token = token;
> > >  	n.cpu = smp_processor_id();
> > > +	n.mm = current->active_mm;
> > > +	n.halted = idle || preempt_count() > 1;
> > > +	atomic_inc(&n.mm->mm_count);
> > 
> > Can't see why this reference is needed.
> I thought that if kernel thread does fault on behalf of some
> process mm can go away while kernel thread is sleeping. But it looks
> like kernel thread increase reference to mm it runs with by himself, so
> may be this is redundant (but not harmful).
> 
Actually it is not redundant. Kernel thread will release reference to
active_mm on reschedule.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
