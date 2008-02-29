Date: Thu, 28 Feb 2008 16:56:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mmu notifiers #v7
Message-Id: <20080228165608.de7c8ae4.akpm@linux-foundation.org>
In-Reply-To: <20080229004001.GN8091@v2.random>
References: <20080219084357.GA22249@wotan.suse.de>
	<20080219135851.GI7128@v2.random>
	<20080219231157.GC18912@wotan.suse.de>
	<20080220010941.GR7128@v2.random>
	<20080220103942.GU7128@v2.random>
	<20080221045430.GC15215@wotan.suse.de>
	<20080221144023.GC9427@v2.random>
	<20080221161028.GA14220@sgi.com>
	<20080227192610.GF28483@v2.random>
	<Pine.LNX.4.64.0802281456200.1152@schroedinger.engr.sgi.com>
	<20080229004001.GN8091@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Feb 2008 01:40:01 +0100 Andrea Arcangeli <andrea@qumranet.com> wrote:

> > > +#define mmu_notifier(function, mm, args...)				\
> > > +	do {								\
> > > +		struct mmu_notifier *__mn;				\
> > > +		struct hlist_node *__n;					\
> > > +									\
> > > +		if (unlikely(!hlist_empty(&(mm)->mmu_notifier.head))) { \
> > > +			rcu_read_lock();				\
> > > +			hlist_for_each_entry_rcu(__mn, __n,		\
> > > +						 &(mm)->mmu_notifier.head, \
> > > +						 hlist)			\
> > > +				if (__mn->ops->function)		\
> > > +					__mn->ops->function(__mn,	\
> > > +							    mm,		\
> > > +							    args);	\
> > > +			rcu_read_unlock();				\
> > > +		}							\
> > > +	} while (0)
> > 
> > Andrew recomended local variables for parameters used multile times. This 
> > means the mm parameter here.
> 
> I don't exactly see what "buggy macro" meant?

multiple refernces to the argument, so

	mmu_notifier(foo, bar(), zot);

will call bar() either once or twice.

Unlikely in this case, but bad practice.  Easily fixable by using another
temporary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
