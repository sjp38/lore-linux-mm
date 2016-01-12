Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 11 Jan 2016 20:17:39 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 09/13] aio: add support for async openat()
Message-ID: <20160112011739.GD16499@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org> <150a0b4905f1d7274b4c2c7f5e3f4d8df5dda1d7.1452549431.git.bcrl@kvack.org> <CA+55aFw8j_3Vkb=HVoMwWTPD=5ve8RpNZeL31CcKQZ+HRSbfTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw8j_3Vkb=HVoMwWTPD=5ve8RpNZeL31CcKQZ+HRSbfTA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 04:22:28PM -0800, Linus Torvalds wrote:
> On Mon, Jan 11, 2016 at 2:07 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> > Another blocking operation used by applications that want aio
> > functionality is that of opening files that are not resident in memory.
> > Using the thread based aio helper, add support for IOCB_CMD_OPENAT.
> 
> So I think this is ridiculously ugly.
> 
> AIO is a horrible ad-hoc design, with the main excuse being "other,
> less gifted people, made that design, and we are implementing it for
> compatibility because database people - who seldom have any shred of
> taste - actually use it".
> 
> But AIO was always really really ugly.
> 
> Now you introduce the notion of doing almost arbitrary system calls
> asynchronously in threads, but then you use that ass-backwards nasty
> interface to do so.
> 
> Why?

Understood, but there are some reasons behind this.  The core aio submit
mechanism is modeled after the lio_listio() call in posix.  While the
cost of performing syscalls has decreased substantially over the last 10
years, the cost of context switches has not.  Some AIO operations really
want to do part of the work in the context of the original submitter for
the work.  That was/is a critical piece of the async readahead
functionality in this series -- without being able to do a quick return
to the caller when all the cached data is allready resident in the
kernel, there is a significant performance degradation in my tests.  For
other operations which are going to do blocking i/o anyways, the cost of
the context switch often becomes noise.

The async readahead also fills a fills a hole in the proposed extensions
to preadv()/pwritev() -- they need some way to trigger and know when a
readahead operation has completed.  One needs a completion queue of some
sort to figure out which operation has completed in a reasonable
efficient manner.  The futex doesn't really have the ability to do this.

Thread dispatching is another problem the applications I work on
encounter, and AIO helps in this particular area because a thread that
is running hot can simply check the AIO event ring buffer for new events
in its main event loop.  Userspace fundamentally *cannot* do a good job of
dispatching work to threads.  The code I've see other developers come up
with ends up doing things like epoll() in one thread followed by
dispatching the receieved events to different threads.  This ends up
making multiple expensive syscalls (since locking and cross CPU bouncing
is required) when the kernel could just direct things to the right
thread in the first place.

There are a lot of requirements bringing additional complexity that start
to surface once you look at how some of these applications are actually
written.

> If you want to do arbitrary asynchronous system calls, just *do* it.
> But do _that_, not "let's extend this horrible interface in arbitrary
> random ways one special system call at a time".
> 
> In other words, why is the interface not simply: "do arbitrary system
> call X with arguments A, B, C, D asynchronously using a kernel
> thread".

We've had a few proposals to do this, none of which have really managed 
to tackle all the problems that arose.  If we go down this path, we will 
end up needing a table of what syscalls can actually be performed 
asynchronously, and flags indicating what bits of context those syscalls
require.  This does end up looking a bit like how AIO does things
depending on how hard you squint.

I'm not opposed to reworking how AIO dispatches things.  If we're willing 
to relax some constraints (like the hard enforced limits on the number
of AIOs in flight), things can be substantially simplified.  Again,
worries about things like memory usage today are vastly different than
they were back in the early '00s, so the decisions that make sense now
will certainly change the design.

Cancellation is also a concern.  Cancellation is not something that can
be sacrificed.  Without some mechanism to cancel operations that are in
flight, there is no way for a process to cleanly exit.  This patch
series nicely proves that signals work very well for cancellation, and
fit in with a lot of the code we already have.  This implies we would
need to treat threads doing async operations differently from normal
threads.  What happens with the pid namespace?

> That's something that a lot of people might use. In fact, if they can
> avoid the nasty AIO interface, maybe they'll even use it for things
> like read() and write().
> 
> So I really think it would be a nice thing to allow some kind of
> arbitrary "queue up asynchronous system call" model.
> 
> But I do not think the AIO model should be the model used for that,
> even if I think there might be some shared infrastructure.
> 
> So I would seriously suggest:
> 
>  - how about we add a true "asynchronous system call" interface
> 
>  - make it be a list of system calls with a futex completion for each
> list entry, so that you can easily wait for the end result that way.
> 
>  - maybe (and this is where it gets really iffy) you could even pass
> in the result of one system call to the next, so that you can do
> things like
> 
>        fd = openat(..)
>        ret = read(fd, ..)
> 
>    asynchronously and then just wait for the read() to complete.
> 
> and let us *not* tie this to the aio interface.
> 
> In fact, if we do it well, we can go the other way, and try to
> implement the nasty AIO interface on top of the generic "just do
> things asynchronously".
> 
> And I actually think many of your kernel thread parts are good for a
> generic implementation. That whole "AIO_THREAD_NEED_CRED" etc logic
> all makes sense, although I do suspect you could just make it
> unconditional. The cost of a few atomics shouldn't be excessive when
> we're talking "use a thread to do op X".
> 
> What do you think? Do you think it might be possible to aim for a
> generic "do system call asynchronously" model instead?

Maybe it's not too bad to do -- the syscall() primitive is reasonably 
well defined and is supported across architectures, but we're going to 
need new wrappers for *every* syscall supported.  Odds are the work will 
have to be done incrementally to weed out which syscalls are safe and 
which are not, but there is certainly no reason we can't reuse syscall 
numbers and the same argument layout.

Chaining things becomes messy.  There are some cases where that works,
but at least on the applications I've worked on, there tends to be a
fair amount of logic that needs to be run before you can figure out what
and where the next operation is.  The canonical example I can think of
is the case where one is retreiving data from disk.  The first operation
is a read into some table to find out where data is located, the next
operation is a search (binary search in the case I'm thinking of) in the
data that was just read to figure out which record actually contains the
data the app cares about, followed by a read to actually fetch the data
the user actually requires.

And it gets more complicated: different disk i/os need to be issued with
different priorities (something that was not included in what I just
posted today, but is work I plan to propose for merging in the future).
In some cases the priority is known beforehand, but in other cases it
needs to be adjusted dynamically depending on information fetched (users
don't like it if huge i/os completely starve their smaller i/os for
significant amounts of time).

> I'm adding Ingo the to cc, because I think Ingo had a "run this list
> of system calls" patch at one point - in order to avoid system call
> overhead. I don't think that was very interesting (because system call
> overhead is seldom all that noticeable for any interesting system
> calls), but with the "let's do the list asynchronously" addition it
> might be much more intriguing. Ingo, do I remember correctly that it
> was you? I might be confused about who wrote that patch, and I can't
> find it now.

I'd certainly be interested in hearing more ideas concerning
requirements.

Sorry for the giant wall of text...  Nothing is simple! =-)

		-ben

>                Linus

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
