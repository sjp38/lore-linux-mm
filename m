From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
Date: Mon, 7 Jan 2008 20:01:30 +1100
References: <20071218211539.250334036@redhat.com> <200801031707.14607.nickpiggin@yahoo.com.au> <20080103085525.GB10813@elte.hu>
In-Reply-To: <20080103085525.GB10813@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200801072001.30986.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Mike Travis <travis@sgi.com>, Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <peterz@infradead.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Thursday 03 January 2008 19:55, Ingo Molnar wrote:
> * Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > > Have you done anything more with allowing > 256 CPUS in this
> > > spinlock patch?  We've been testing with 1k cpus and to verify with
> > > -mm kernel, we need to "unpatch" these spinlock changes.
> >
> > Hi Mike,
> >
> > Actually I had it in my mind that 64 bit used single-byte locking like
> > i386, so I didn't think I'd caused a regression there.
> >
> > I'll take a look at fixing that up now.
>
> thanks - this is a serious showstopper for the ticket spinlock patch.
>
> ( which has otherwise been performing very well in x86.git so far - it
>   has passed a few thousand bootup tests on 64-bit and 32-bit as well,
>   so we are close to it being in a mergable state. Would be a pity to
>   lose it due to the 256 cpus limit. )

OK, this is what my test harness code looks like for > 256 CPUs
(basically the same as the in-kernel code, but some names etc. are slightly
different).

It passes my basic tests, and performance doesn't seem to have suffered.
I was going to suggest making the <= 256 vs > 256 cases config options, but
maybe we don't need to unless some CPUs are slow at shifts / rotates? I
don't know...

After I get comments, I will come up with an incremental patch against
the kernel... It will be interesting to know whether ticket locks help
big SGI systems.

static inline void xlock(lock_t *lock)
{
        lock_t inc = 0x00010000;
        lock_t tmp;

        __asm__ __volatile__ (
                "lock ; xaddl %0, %1\n"
                "movzwl %w0, %2\n\t"
                "shrl $16, %0\n\t"
                "1:\t"
                "cmpl %0, %2\n\t"
                "je 2f\n\t"
                "rep ; nop\n\t"
                "movzwl %1, %2\n\t"
                /* don't need lfence here, because loads are in-order */
                "jmp 1b\n"
                "2:"
                :"+Q" (inc), "+m" (*lock), "=r" (tmp)
                :
                :"memory", "cc");
}

static inline int xtrylock(lock_t *lock)
{
        lock_t tmp;
        lock_t new;

        asm volatile(
                "movl %2,%0\n\t"
                "movl %0,%1\n\t"
                "roll $16, %0\n\t"
                "cmpl %0,%1\n\t"
                "jne 1f\n\t"
                "addl $0x00010000, %1\n\t"
                "lock ; cmpxchgl %1,%2\n\t"
                "1:"
                "sete %b1\n\t"
                "movzbl %b1,%0\n\t"
                :"=&a" (tmp), "=r" (new), "+m" (*lock)
                :
                : "memory", "cc");

        return tmp;
}

static inline void xunlock(lock_t *lock)
{
        __asm__ __volatile__(
                "incw %0"
                :"+m" (*lock)
                :
                :"memory", "cc");
}

                        

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
