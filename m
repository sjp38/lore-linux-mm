Subject: Re: New version of frlock (now called seqlock)
From: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030130235026.GX18538@dualathlon.random>
References: <1043969416.10155.619.camel@dell_ss3.pdx.osdl.net>
	 <3E39B8E6.5F668D28@digeo.com>  <20030130235026.GX18538@dualathlon.random>
Content-Type: multipart/mixed; boundary="=-DfZuzP2FWxiTd9g8UihQ"
Message-Id: <1043972110.10155.630.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Date: 30 Jan 2003 16:15:10 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@digeo.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andi Kleen <ak@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-DfZuzP2FWxiTd9g8UihQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2003-01-30 at 15:50, Andrea Arcangeli wrote:
> On Thu, Jan 30, 2003 at 03:44:38PM -0800, Andrew Morton wrote:
> > Stephen Hemminger wrote:
> > > 
> > > This is an update to the earlier frlock.
> > > 
> > 
> > Sorry, but I have lost track of what version is what.  Please
> > let me get my current act together and then prepare diffs
> > against (or new versions of) that.
> > 
> > You appear to have not noticed my earlier suggestions wrt
> > coding tweaks and inefficiencies in the new implementation.
> > 
> > - SEQ_INIT and seq_init can go away.
> > 
> > - do seq_write_begin/end need wmb(), or mb()?  Probably, we
> >   should just remove these functions altogether.

Since nothing uses them yet, yes, just more to go wrong.


> > 	+static inline int seq_read_end(const seqcounter_t *s, unsigned iv)
> > 	+{
> > 	+       mb();
> > 	+       return (s->counter != iv) || (iv & 1);
> > 	+}
> > 
> >   So the barriers changed _again_!  Could we please at least
> >   get Richard Henderson and Andrea to agree that this is the
> >   right way to do it?

That was actually a typo. Should be rmb().


> the right way is the one used by x86-64 vgettimeofday and
> i_size_read/write in my tree (and frlock in my tree too for x86
> gettimeofday)
> 
> that is pure rmb() in read_lock and pure wmb() in write_lock
> 
> never mb()
> 
> The only place where mb() could be somehow interesting is the
> write_begin/end but it's mostly a theorical interest, and we both think
> that write_begin/end is pointless, since the lock part is useless for
> them, and in turn write_begin/end aren't that clean anyways.
> 

Rather than splitting it into two pieces, counter and lock+counter;
go back to one structure, ince no place is using just the counter alone.
I will merge all this back tomorrow.
	

-- 
Stephen Hemminger <shemminger@osdl.org>
Open Source Devlopment Lab

--=-DfZuzP2FWxiTd9g8UihQ
Content-Disposition: attachment; filename=seqlock.h
Content-Type: text/x-c-header; name=seqlock.h; charset=UTF-8
Content-Transfer-Encoding: 7bit

#ifndef __LINUX_SEQLOCK_H
#define __LINUX_SEQLOCK_H
/*
 * Reader/writer consistent mechanism without starving writers. This type of
 * lock for data where the reader wants a consitent set of information
 * and is willing to retry if the information changes.  Readers never
 * block but they may have to retry if a writer is in
 * progress. Writers do not wait for readers. 
 *
 * This is not as cache friendly as brlock. Also, this will not work
 * for data that contains pointers, because any writer could
 * invalidate a pointer that a reader was following.
 *
 * Expected reader usage:
 * 	do {
 *	    seq = seq_read_begin(&foo);
 * 	...
 *      } while (seq_read_end(&foo, seq));
 *
 *
 * Based on x86_64 vsyscall gettimeofday 
 * by Keith Owens and Andrea Arcangeli
 */

#include <linux/config.h>
#include <linux/spinlock.h>
#include <linux/preempt.h>

/* Combination of spinlock for writing and sequence update for readers */
typedef struct {
	unsigned long sequence;
	spinlock_t lock;
} seqlock_t;

/*
 * These macros triggered gcc-3.x compile-time problems.  We think these are
 * OK now.  Be cautious.
 */
#define SEQ_LOCK_UNLOCKED { SEQ_INIT, SPIN_LOCK_UNLOCKED }
#define seqlock_init(x)	do { *(x) = (seqlock_t) SEQ_LOCK_UNLOCKED; } while (0)


/* Lock out other writers and update the count.
 * Acts like a normal spin_lock/unlock.
 * Don't need preempt_disable() because that is in the spin_lock already.
 */
static inline void seq_write_lock(seqlock_t *rw)
{
	spin_lock(&rw->lock);
	++rw->sequence;
	wmb();			
}	

static inline void seq_write_unlock(seqlock_t *rw) 
{
	wmb();
	rw->sequence++;
	spin_unlock(&rw->lock);
}

static inline int seq_write_trylock(seqlock_t *rw)
{
	int ret = spin_trylock(&rw->lock);

	if (ret) {
		++rw->sequence;
		wmb();			
	}
	return ret;
}

/* Start of read calculation -- fetch last complete writer token */
static inline unsigned seq_read_begin(const seqlock_t *s)
{
	unsigned ret = s->sequence;
	rmb();
	return ret;
}

/* End of read calculation -- check if sequence matches */
static inline int seq_read_end(const seqlock_t *s, unsigned iv)
{
	rmb();
	return unlikely((s->sequence != iv) || (iv & 1));
}


/*
 * Possible sw/hw IRQ protected versions of the interfaces.
 */
#define seq_write_lock_irqsave(lock, flags)				\
	do { local_irq_save(flags);	seq_write_lock(lock); } while (0)
#define seq_write_lock_irq(lock)						\
	do { local_irq_disable();	seq_write_lock(lock); } while (0)
#define seq_write_lock_bh(lock)						\
        do { local_bh_disable();	seq_write_lock(lock); } while (0)

#define seq_write_unlock_irqrestore(lock, flags)				\
	do { seq_write_unlock(lock); local_irq_restore(flags); } while(0)
#define seq_write_unlock_irq(lock)					\
	do { seq_write_unlock(lock); local_irq_enable(); } while(0)
#define seq_write_unlock_bh(lock)					\
	do { seq_write_unlock(lock); local_bh_enable(); } while(0)

#define seq_read_lock_irqsave(lock, flags)				\
	({ local_irq_save(flags);	seqlock_read_begin(lock); })

#define seq_read_lock_irqrestore(lock, iv, flags)			\
	unlikely({int ret = seq_read_end(&(lock)->seq, iv);		\
		local_irq_save(flags);					\
		ret;							\
	})

#endif /* __LINUX_SEQLOCK_H */

--=-DfZuzP2FWxiTd9g8UihQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
