Subject: Re: [PATCH/RFC 0/14] Page Reclaim Scalability
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <alpine.LFD.0.999.0709141422110.16478@woody.linux-foundation.org>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <1189804264.5826.5.camel@lappy>
	 <alpine.LFD.0.999.0709141422110.16478@woody.linux-foundation.org>
Content-Type: text/plain
Date: Sat, 15 Sep 2007 00:02:25 +0200
Message-Id: <1189807345.5826.27.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 14:42 -0700, Linus Torvalds wrote:
> 
> On Fri, 14 Sep 2007, Peter Zijlstra wrote:
> > 
> > Also at Cambridge, Linus said that rw-spinlocks are usually a mistake.
> >
> > Their spinning nature can cause a lot of cacheline bouncing.
> 
> They seem to tend to exacerbate any locking problems, at least on x86. The 
> rw-spinlocks are more expensive than regular spinlocks, and while in 
> theory they should allow nice parallel work by multiple readers, in 
> practice the serialization and cost of locking itself seems to just make 
> things worse.

That was my understanding, so for a rwlock to be somewhat usefull the
write side should be rare, and the reader paths longish so as to win
some of the serialisation costs back.

When looking at the locking hierarchy as presented in rmap.c these two
locks are the first non sleeper locks (and from a quick look at the code
there are no IRQ troubles either), so changing them to a sleeping lock
is quite doable - if that turns out to have advantages over rwlock_t in
this case.


<snip the tasklist_lock story>

> So the rwlocks have certainly been successful at times. They just have 
> been less successful than people perhaps expected. They're certainly not 
> very "cheap", and not really scalable to many readers like a RCU read-lock 
> is.
> 
> So if you actually look for scalability to lots of CPU's, I think you'd 
> want RCU.

Certainly, although that might take a little more than a trivial change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
