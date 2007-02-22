Subject: Re: [PATCH 03/29] mm: allow PF_MEMALLOC from softirq context
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1172135783.6374.30.camel@twins>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
	 <20070221144841.823705000@taijtu.programming.kicks-ass.net>
	 <1172073217.3531.200.camel@laptopd505.fenrus.org>
	 <1172135783.6374.30.camel@twins>
Content-Type: text/plain
Date: Thu, 22 Feb 2007 10:48:08 +0100
Message-Id: <1172137688.3531.233.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-02-22 at 10:16 +0100, Peter Zijlstra wrote:
> On Wed, 2007-02-21 at 16:53 +0100, Arjan van de Ven wrote:
> > > Index: linux-2.6-git/kernel/softirq.c
> > > ===================================================================
> > > --- linux-2.6-git.orig/kernel/softirq.c	2006-12-14 10:02:18.000000000 +0100
> > > +++ linux-2.6-git/kernel/softirq.c	2006-12-14 10:02:52.000000000 +0100
> > > @@ -209,6 +209,8 @@ asmlinkage void __do_softirq(void)
> > >  	__u32 pending;
> > >  	int max_restart = MAX_SOFTIRQ_RESTART;
> > >  	int cpu;
> > > +	unsigned long pflags = current->flags;
> > > +	current->flags &= ~PF_MEMALLOC;
> > >  
> > >  	pending = local_softirq_pending();
> > >  	account_system_vtime(current);
> > > @@ -247,6 +249,7 @@ restart:
> > >  
> > >  	account_system_vtime(current);
> > >  	_local_bh_enable();
> > > +	current->flags = pflags;
> > 
> > this wipes out all the flags in one go.... evil.
> > What if something just selected this process for OOM killing? you nuke
> > that flag here again. Would be nicer if only the PF_MEMALLOC bit got
> > inherited in the restore path..
> 
> would something like this:
> 
> #define PF_PUSH(tsk, pflags, mask)		\
> do {						\
> 	(pflags) = ((tsk)->flags) & (mask);	\
> } while (0)
> 
> 
> #define PF_POP(tsk, pflags, mask)		\
> do {						\
> 	((tsk)->flags &= ~(mask);		\
> 	((tsk)->flags |= (pflags);		\
> } while (0)
> 
> be useful, or shall I just open code it in various places?

technically all you need is __get_bit and __set_bit() right?
(well a set_bit which sets to a value, not to always-1)

more generic name at least ;)

-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
