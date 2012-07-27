Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id CD73D6B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 15:40:40 -0400 (EDT)
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 27 Jul 2012 15:40:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 998116E8039
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 15:39:49 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RJdnb6369578
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 15:39:49 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RJdm0V020928
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 13:39:48 -0600
Date: Fri, 27 Jul 2012 12:39:47 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120727193947.GK2442@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
 <1343335169.32120.18.camel@twins>
 <alpine.LSU.2.00.1207271155440.1328@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207271155440.1328@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 27, 2012 at 12:22:46PM -0700, Hugh Dickins wrote:
> On Thu, 26 Jul 2012, Peter Zijlstra wrote:
> > On Tue, 2012-07-24 at 14:51 -0700, Hugh Dickins wrote:
> > > I do love the status quo, but an audit would be welcome.  When
> > > it comes to patches, personally I tend to prefer ACCESS_ONCE() and
> > > smp_read_barrier_depends() and accompanying comments to be hidden away
> > > in the underlying macros or inlines where reasonable, rather than
> > > repeated all over; but I may have my priorities wrong on that.
> 
> I notice from that old radix_tree thread you pointed to in the previous
> mail (for which many thanks: lots of meat to digest in there) that this
> is also Linus's preference.
> 
> > > 
> > > 
> > Yeah, I was being lazy, and I totally forgot to actually look at the
> > alpha code.
> > 
> > How about we do a generic (cribbed from rcu_dereference):
> > 
> > #define page_table_deref(p)					\
> > ({								\
> > 	typeof(*p) *______p = (typeof(*p) __force *)ACCESS_ONCE(p);\
> > 	smp_read_barrier_depends();				\
> > 	((typeof(*p) __force __kernel *)(______p));		\
> > })
> > 
> > and use that all over to dereference page-tables. That way all this
> > lives in one place. Granted, I'll have to go edit all arch code, but I
> > seem to be doing that on a frequent basis anyway :/
> 
> If you're convinced that we now have (or are in danger of growing)
> a number of places which need this safety, yes, I suppose so.
> 
> Personally, I'd have gone for just adding the relatively-understandable
> ACCESS_ONCEs in all the arch/*/include/asm macros (which you're going to
> visit to make the above change), and leave the smp_read_barrier_depends()
> entirely in Alpha - one level of indirection less for the reader.
> But that's just me, you're the one proposing to do the work, and
> you may have very good reason for the above.
> 
> I'm unfamiliar with what value the __force __kernel annotations add.
> But I am interested to notice that you are only 6/9ths as insane as
> Paul: any chance of helping global underscore availability by not
> hoarding quite so many in there? 

Heh!!!  The number of underscores for the original rcu_dereference()'s
local variable was the outcome of an argument about how obfuscated that
variable's name should be in order to avoid possible collisions with names
in the enclosing scope.  Nine leading underscores might seem excessive,
or even as you say, insane, but on the other hand no name collisions
have ever come to my attention.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
