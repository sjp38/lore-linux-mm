Subject: Re: [patch 0/5] [RFC] Conversion of reverse map locks to semaphores
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <Pine.LNX.4.64.0806270844040.12950@schroedinger.engr.sgi.com>
References: <20080626003632.049547282@sgi.com>
	 <1214556789.2801.19.camel@twins.programming.kicks-ass.net>
	 <Pine.LNX.4.64.0806270844040.12950@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 27 Jun 2008 18:38:07 +0200
Message-Id: <1214584687.12348.8.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, apw@shadowen.org, Ingo Molnar <mingo@elte.hu>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-06-27 at 08:46 -0700, Christoph Lameter wrote:
> On Fri, 27 Jun 2008, Peter Zijlstra wrote:
> 
> > > Also it seems that a semaphore helps RT and should avoid busy spinning
> > > on systems where these locks experience significant contention.
> > 
> > Please be careful with the wording here. Semaphores are evil esp for RT.
> > But luckily you're referring to a sleeping RW lock, which we call
> > RW-semaphore (but is not an actual semaphore).
> > 
> > You really scared some people saying this ;-)
> 
> Well we use the term semaphore for sleeping locks in the kernel it seems.

We have an actual mutex implementation, which is oddly enough called a
mutex, not binary-semaphore-with-owner-semantics.

> Maybe you could get a patch done that renames the struct to 
> sleeping_rw_lock or so? That would finally clear the air. This is the 
> second or third time we talk about a semaphore not truly being a 
> semaphore.

Yes indeed. It mainly comes from the fact that some people drop the rw
prefix, creating the implession they talk about an actual semaphore
(which we also still have).

About that rename - it's come up before, and while I would not mind to
do such a rename, we've failed to come up with a decent name. I think
people will object to the length of your proposed one.

We could of course go for the oxymoron: rw_mutex, but I think that was
shot down once before.

> > Depending on the contention stats you could try an adaptive spin on the
> > readers. I doubt adaptive spins on the writer would work out well, with
> > the natural plenty-ness of readers..
> 
> That depends on the frequency of lock taking and the contention. If you 
> have a rw lock then you would assume that writers are rare so this is 
> likely okay.

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
