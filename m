Date: Fri, 14 Sep 2007 14:42:51 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH/RFC 0/14] Page Reclaim Scalability
In-Reply-To: <1189804264.5826.5.camel@lappy>
Message-ID: <alpine.LFD.0.999.0709141422110.16478@woody.linux-foundation.org>
References: <20070914205359.6536.98017.sendpatchset@localhost>
 <1189804264.5826.5.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>


On Fri, 14 Sep 2007, Peter Zijlstra wrote:
> 
> Also at Cambridge, Linus said that rw-spinlocks are usually a mistake.
>
> Their spinning nature can cause a lot of cacheline bouncing.

They seem to tend to exacerbate any locking problems, at least on x86. The 
rw-spinlocks are more expensive than regular spinlocks, and while in 
theory they should allow nice parallel work by multiple readers, in 
practice the serialization and cost of locking itself seems to just make 
things worse.

But we do use them for some things. The tasklist_lock is one, and I don't 
think we could/should make that one be a regular spinlock: the tasklist 
lock is one of the most "outermost" locks we have, so we often have not 
only various process list traversal inside of it, but we have other (much 
better localized) spinlocks going on inside of it, and as a result we 
actually do end up having real work with real parallelism.

[ But in the case of tasklist_lock, the bigger reason is likely that it 
  also has a semantic reason to prefer rwlocks: you can do reader locks 
  from interrupt context, without having to disable interrupts around 
  other reader locks.

  So in the case of tasklist_lock, I think the *real* advantage is not any 
  amount of extra scalability, but the fact that rwlocks end up allowing 
  us to disable interrupts only for the few operations that need it for 
  writing! ]

So the rwlocks have certainly been successful at times. They just have 
been less successful than people perhaps expected. They're certainly not 
very "cheap", and not really scalable to many readers like a RCU read-lock 
is.

So if you actually look for scalability to lots of CPU's, I think you'd 
want RCU.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
