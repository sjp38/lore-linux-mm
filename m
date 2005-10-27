Date: Thu, 27 Oct 2005 15:23:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-Id: <20051027152340.5e3ae2c6.akpm@osdl.org>
In-Reply-To: <20051027213721.GX5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain>
	<200510271038.52277.ak@suse.de>
	<20051027131725.GI5091@opteron.random>
	<1130425212.23729.55.camel@localhost.localdomain>
	<20051027151123.GO5091@opteron.random>
	<20051027112054.10e945ae.akpm@osdl.org>
	<20051027200434.GT5091@opteron.random>
	<20051027135058.2f72e706.akpm@osdl.org>
	<20051027213721.GX5091@opteron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> On Thu, Oct 27, 2005 at 01:50:58PM -0700, Andrew Morton wrote:
> > This is what I'm asking about.  What's the requirement?  What's the
> > application?  What's the workload?  What's the testcase?  All that old
> > stuff.  This should have been the very, very first thing which Badari
> > presented to us.
> 
> I mentioned the reason we need that feature at the end of the last email.

It's slowly becoming clearer ;)

> > If we do it this way then we should do it for other filesystems.  And then
> 
> Why do you think so? Even O_DIRECT and the acl were not supported by all
> the fs immediately, what's wrong with that? This is normal procedure as
> far as I can tell. If -ENOSYS is returned, it means the app should
> fallback to some other way to do the truncate by hand (depending on the
> app, bzero could work or some other app can be ok with doing nothing at
> all if -ENOSYS is returned).

But in the case of O_DIRECT and acls we had a plan, from day one, to extend
the capability to many (ideally all) filesystems.

We have no such plan for holepunching!

Maybe we _should_ have such a plan, but we've never discussed it.

If we _do_ have such a plan (or might in the future) then what would the
API look like?  I think sys_holepunch(fd, start, len), so we should start
out with that.

If we don't have such a plan, and we don't think that we ever will have
such a plan, then what should the API look like?

Using madvise is very weird, because people will ask "why do I need to mmap
my file before I can stick a hole in it?"

None of the other madvise operations call into the filesystem in this manner.

A broad question is: is this capability an MM operation or a filesytem
operation?  truncate, for example, is a filesystem operation which
sometimes has MM side-effects.  madvise is an mm operation and with this
patch, it gains FS side-effects, only they're really, really significant
ones.

So I'm struggling to work out where all this is headed, and how we should
think about it all.

> > we should do it for files which _aren't_ mmapped.  And then we should do it
> > on a finer-than-PAGE_SIZE granularity.
> 
> I agree with this. I also suggested doing all of it, not just the mmap
> interface.

Right.  Sometime, maybe.  There's been _some_ demand for holepunching, but
it's been fairly minor and is probably a distraction from this immediate
and specific customer requirement.

> However the only thing they care about is the mmap interface,
> and this is why this is coming first. Also note, my MADV_TRUNCATE is by
> coincidence needed by IBM too, the testcase I was trying to improve was
> not an IBM workload, I learnt about the IBM effort only a few days ago.
> But others happen to need it for the very same reason (no, not Oracle,
> but Oracle would benefit from it too of course).
> 
> > IOW: we're unlikely to implement MADV_TRUNCATE for anything other than
> > tmpfs, in which case MADV_TRUNCATE will remain a tmpfs specific hack, no?
> 
> In 2.6 yes. But in the future it's an API we can extend to work on more
> fs with well defined semantics.

Right.  And in the future I think it would be designed as a generalisation
of sys_ftruncate().

> What's the benefit in having MADV_DISCARD that works on tmpfs, and then
> some day in the future to add a MADV_TRUNCATE that works on other fs too?
> 
> The retval of MADV_TRUNCATE will still be an error in both cases for
> older kernels. So we may go for the more generic API in the first place
> IMHO.
> 
> The less MADV_MESS there is the better and the more explicit the name is
> the better too.
> 
> > Or to swap it out.
> 
> Ok, the whole point is to release the swap. This stuff is already in
> completely swap for ages, nobody touched it for ages, but it's bad for
> performance and for swap fragmentation if after a peak of load 16G
> remains always in swap when infact the app could release all the
> swap after the load went down (if only it could use MADV_TRUNCATE).

ah-hah.

hm.   Tossing ideas out here:

- Implement the internal infrastructure as you have it

- View it as a filesystem operation which has MM side-effects.

- Initially access it via sys_ipc()  (or madvise, I guess.  Both are a bit odd)

- Later access it via sys_[hole]punch()

Alternatively, access it via sys_[hole]punch() immediately, but I'm not
sure that userspace can get access to the shm area's fd?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
