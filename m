Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA18787
	for <linux-mm@kvack.org>; Wed, 29 Jan 2003 17:43:59 -0800 (PST)
Date: Wed, 29 Jan 2003 18:00:54 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Linus rollup
Message-Id: <20030129180054.03ac0d48.akpm@digeo.com>
In-Reply-To: <20030130013522.GP1237@dualathlon.random>
References: <20030129022617.62800a6e.akpm@digeo.com>
	<1043879752.10150.387.camel@dell_ss3.pdx.osdl.net>
	<20030129151206.269290ff.akpm@digeo.com>
	<20030129.163034.130834202.davem@redhat.com>
	<20030129172743.1e11d566.akpm@digeo.com>
	<20030130013522.GP1237@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: davem@redhat.com, shemminger@osdl.org, rmk@arm.linux.org.uk, ak@muc.de, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org, rth@twiddle.net
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> On Wed, Jan 29, 2003 at 05:27:43PM -0800, Andrew Morton wrote:
> > @@ -82,11 +85,12 @@ static inline int fr_write_trylock(frloc
> >  
> >  	if (ret) {
> >  		++rw->pre_sequence;
> > -		wmb();
> > +		mb();
> >  	}
> 
> this isn't needed
> 
> 
> if we hold the spinlock, the serialized memory can't be change under us,
> so there's no need to put a read barrier, we only care that pre_sequence
> is visible before the chagnes are visible and before post_sequence is
> visible, hence only wmb() (after spin_lock and pre_sequence++) is
> needed there and only rmb() is needed in the read-side.
> 

OK, thanks muchly.

Lots more updates.  Here's the version which I currently have.  Looks like
fr_write_lock() and fr_write_unlock() need to be switched back to rmb()?



#ifndef __LINUX_FRLOCK_H
#define __LINUX_FRLOCK_H

/*
 * Fast read-write spinlocks.
 *
 * Fast reader/writer locks without starving writers. This type of
 * lock for data where the reader wants a consitent set of information
 * and is willing to retry if the information changes.  Readers never
 * block but they may have to retry if a writer is in
 * progress. Writers do not wait for readers. 
 *
 * Generalization on sequence variables used for gettimeofday on x86-64 
 * by Andrea Arcangeli
 *
 * This is not as cache friendly as brlock. Also, this will not work
 * for data that contains pointers, because any writer could
 * invalidate a pointer that a reader was following.
 *
 * Expected reader usage:
 * 	do {
 *	    seq = fr_read_begin();
 * 	...
 *      } while (seq != fr_read_end());
 *
 * On non-SMP the spin locks disappear but the writer still needs
 * to increment the sequence variables because an interrupt routine could
 * change the state of the data.
 */

#include <linux/config.h>
#include <linux/spinlock.h>
#include <linux/preempt.h>

typedef struct {
	unsigned pre_sequence;
	unsigned post_sequence;
	spinlock_t lock;
} frlock_t;

/*
 * These macros triggered gcc-3.x compile-time problems.  We think these are
 * OK now.  Be cautious.
 */
#define FR_LOCK_UNLOCKED { 0, 0, SPIN_LOCK_UNLOCKED }
#define frlock_init(x)	do { *(x) = (frlock_t) FR_LOCK_UNLOCKED; } while (0)

/* Update sequence count only
 * Assumes caller is doing own mutual exclusion with other lock
 * or semaphore.
 */
static inline void fr_write_begin(frlock_t *rw)
{
	preempt_disable();
	rw->pre_sequence++;
	mb();
}

static inline void fr_write_end(frlock_t *rw)
{
	mb();
	rw->post_sequence++;
	BUG_ON(rw->post_sequence != rw->pre_sequence);
	preempt_enable();
}

/* Lock out other writers and update the count.
 * Acts like a normal spin_lock/unlock.
 */
static inline void fr_write_lock(frlock_t *rw)
{
	spin_lock(&rw->lock);
	rw->pre_sequence++;
	mb();
}	

static inline void fr_write_unlock(frlock_t *rw) 
{
	mb();
	rw->post_sequence++;
	spin_unlock(&rw->lock);
}

static inline int fr_write_trylock(frlock_t *rw)
{
	int ret = spin_trylock(&rw->lock);

	if (ret) {
		++rw->pre_sequence;
		wmb();
	}
	return ret;
}

static inline unsigned fr_read_begin(const frlock_t *rw) 
{
	unsigned ret = rw->post_sequence;
	rmb();
	return ret;
	
}

/* End of reader calculation -- fetch last writer start token */
static inline unsigned fr_read_end(const frlock_t *rw)
{
	rmb();
	return rw->pre_sequence;
}

/*
 * Possible sw/hw IRQ protected versions of the interfaces.
 */
#define fr_write_lock_irqsave(lock, flags)				\
	do { local_irq_save(flags);	fr_write_lock(lock); } while (0)
#define fr_write_lock_irq(lock)						\
	do { local_irq_disable();	fr_write_lock(lock); } while (0)
#define fr_write_lock_bh(lock)						\
        do { local_bh_disable();	fr_write_lock(lock); } while (0)

#define fr_write_unlock_irqrestore(lock, flags)				\
	do { fr_write_unlock(lock); local_irq_restore(flags); } while(0)
#define fr_write_unlock_irq(lock)					\
	do { fr_write_unlock(lock); local_irq_enable(); } while(0)
#define fr_write_unlock_bh(lock)					\
	do { fr_write_unlock(lock); local_bh_enable(); } while(0)

#define fr_read_begin_irqsave(lock, flags)				\
	({ local_irq_save(flags);	fr_read_begin(lock); })

#define fr_read_end_irqrestore(lock, flags)				\
	({	unsigned ret = fr_read_end(lock);			\
		local_irq_save(flags);					\
		ret;							\
	})

#endif /* __LINUX_FRLOCK_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
