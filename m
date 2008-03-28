Date: Fri, 28 Mar 2008 06:45:17 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: down_spin() implementation
Message-ID: <20080328124517.GQ16721@parisc-linux.org>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <1FE6DD409037234FAB833C420AA843ECE9EB1C@orsmsx424.amr.corp.intel.com> <20080327141508.GL16721@parisc-linux.org> <200803281101.25037.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200803281101.25037.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Luck, Tony" <tony.luck@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 28, 2008 at 11:01:24AM +1100, Nick Piggin wrote:
> Uhm, how do you use this exactly? All other holders of this
> semaphore must have preempt disabled and not sleep, right? (and
> so you need a new down() that disables preempt too)

Ah, I see what you're saying.  The deadlock would be (on a single CPU
machine), task A holding the semaphore, being preempted, task B taking
a spinlock (thus non-preemptable), then calling down_spin() which will
never succeed.

That hadn't occurred to me -- I'm not used to thinking about preemption.
I considered interrupt context and saw how that would deadlock, so just
put a note in the documentation that it wasn't usable from interrupts.

So it makes little sense to add this to semaphores.  Better to introduce
a spinaphore, as you say.

> struct {
>   atomic_t cur;
>   int max;
> } ss_t;
> 
> void spin_init(ss_t *ss, int max)
> {
> 	&ss->cur = ATOMIC_INIT(0);
> 	&ss->max = max;
> }
> 
> void spin_take(ss_t *ss)
> {
>   preempt_disable();
>   while (unlikely(!atomic_add_unless(&ss->cur, 1, &ss->max))) {
>     while (atomic_read(&ss->cur) == ss->max)
>       cpu_relax();
>   }
> }

I think we can do better here with:

	atomic_set(max);

and

	while (unlikely(!atomic_add_unless(&ss->cur, -1, 0)))
		while (atomic_read(&ss->cur) == 0)
			cpu_relax();

It still spins on the spinaphore itself rather than on a local cacheline,
so there's room for improvement.  But it's not clear whether it'd be
worth it.

> About the same number as down_spin(). And it is much harder to
> misuse. So LOC isn't such a great argument for this kind of thing.

LOC wasn't really my argument -- I didn't want to introduce a new data
structure unnecessarily.  But the pitfalls (that I hadn't seen) of
mixing down_spin() into semaphores are just too awful.

I'll pop this patch off the stack of semaphore patches.  Thanks.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
