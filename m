Date: Sun, 15 Jun 2003 03:17:32 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.71-mm1
Message-Id: <20030615031732.7a9bd6f5.akpm@digeo.com>
In-Reply-To: <16108.18479.941335.176904@gargle.gargle.HOWL>
References: <20030615015024.6d868168.akpm@digeo.com>
	<16108.18479.941335.176904@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Neil Brown <neilb@cse.unsw.edu.au> wrote:
>
> On Sunday June 15, akpm@digeo.com wrote:
> > 
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.71/2.5.71-mm1/
> > 
> > 
> > Mainly a resync.
> > 
> > . Manfred sent me a revised unmap-page-debugging patch which promptly
> >   broke.  All slab changes have been dropped out so he can have a clear run
> >   at that.
> > 
> > . New toy.  Called, for the lack of a better name, "sleepometer":
> > 
> 
> New toy seems to be lacking mainspring...
> 
> In particular,  sleepo.h cannot be found :-(
> 

oops.


#ifndef SLEEPOMETER_H
#define SLEEPOMETER_H

#include <linux/spinlock.h>
#include <asm/linkage.h>

struct sleepo_data {
	spinlock_t lock;
	unsigned long nr_sleeps;
	unsigned long long total_usecs;
	unsigned long long max_usecs;
	const char *file;
	const char *sleep_type;
	int line;
	struct sleepo_data *next;
};

void sleepo_io_schedule(void);
long sleepo_io_schedule_timeout(long timeout);
asmlinkage void sleepo_schedule(void);
void sleepo_preempt_schedule(void);
signed long sleepo_schedule_timeout(signed long timeout);
void sleepo_begin(const char *file, int line,
		const char *sleep_type, struct sleepo_data *sd);
void sleepo_end(struct sleepo_data *sd);
void sleepo_start(const char *file, int line,
		const char *sleep_type, struct sleepo_data *sd);
void sleepo_stop(struct sleepo_data *sd);

#define schedule()							\
	do {								\
		static struct sleepo_data sd;				\
									\
		sleepo_start(__FILE__, __LINE__, "schedule", &sd);	\
		sleepo_schedule();					\
		sleepo_stop(&sd);					\
	} while (0)

#define preempt_schedule()						\
	do {								\
		static struct sleepo_data sd;				\
									\
		sleepo_start(__FILE__, __LINE__, "preempt_schedule" &sd);\
		sleepo_preempt_schedule();				\
		sleepo_stop(&sd);					\
	} while (0)

#define io_schedule()							\
	do {								\
		static struct sleepo_data sd;				\
									\
		sleepo_start(__FILE__, __LINE__, "io_schedule", &sd);	\
		sleepo_io_schedule();					\
		sleepo_stop(&sd);					\
	} while (0)

#define schedule_timeout(t)						\
	({								\
		static struct sleepo_data sd;				\
		long ret;						\
									\
		sleepo_start(__FILE__, __LINE__, "schedule_timeout", &sd);\
		ret = sleepo_schedule_timeout(t);			\
		sleepo_stop(&sd);					\
		ret;							\
	})

#define io_schedule_timeout(t)						\
	({								\
		static struct sleepo_data sd;				\
		long ret;						\
									\
		sleepo_start(__FILE__, __LINE__, "io_schedule_timeout", &sd);\
		ret = sleepo_io_schedule_timeout(t);			\
		sleepo_stop(&sd);					\
		ret;							\
	})

#endif		/* SLEEPOMETER_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
