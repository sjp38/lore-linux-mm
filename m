Date: Thu, 15 Jul 2004 16:36:35 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: [PATCH] /dev/zero page fault scaling
In-Reply-To: <Pine.LNX.4.44.0407152038160.8010-100000@localhost.localdomain>
Message-ID: <Pine.SGI.4.58.0407151611300.116400@kzerza.americas.sgi.com>
References: <Pine.LNX.4.44.0407152038160.8010-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jul 2004, Hugh Dickins wrote:

> On Thu, 15 Jul 2004, Brent Casavant wrote:
> >
> > Hmm.  There's more of the same lurking in here.  I moved on to the next
> > page fault scaling problem on the list, namely with SysV shared memory
> > segments.  I'll give you one guess which cacheline is the culprit in that
> > case.
> >
> > Unless I'm mistaken, we don't need to track sbinfo for SysV segments
> > either.  So my next task is to figure out how to turn on the SHMEM_NOSBINFO
> > bit for that case as well.
>
> You should find that you've already fixed that one with your first patch:
> the shared writable /dev/zero mappings and the SysV shared memory live in
> the same internal mount.  But if you find that the SysV shm is still a
> problem with your patch, then either I'm confused or your patch is wrong.

My patch is slightly wrong.  Note that it special cases the "dev/zero"
inode name to perform the detection.  This doesn't catch the SYSV%08x
path from newseg() in ipc/shm.c.

Given that I imagine we don't want a bug in the tmpfs case when a file
is named "SYSV*", I've reworked the patch to let the caller of
shmem_file_setup() pass the desired behavior in the flags argument.

But with your new patch that problem has probably disappeared anyway.
Let me give it a spin and let you know.  I won't be able to do that
until Monday as our 512P machine is booked up the rest of today.
Maybe I'll come in to work to look at it this weekend, but probably not.
Gotta have a life too. :)

> By the way, just curious, but can you tell us what it is that is making
> so much use of the shared writable /dev/zero mappings?  I thought they
> were just an odd corner not used very much; ordinary anonymous memory
> doesn't involve tmpfs objects.

It's actually an artifical test program that nails this particular
code path.  However it was written to simulate a situation that
can happen in MPI codes.  My guess (the original investigation was
over a year ago) is that SGI's MPI folks first noticed this with SysV
segments, and then after the test program was written we found that
the same thing applied to /dev/zero.

> Your patch, by the way, seemed to be against 2.6.8-rc1 or 2.6.8-rc1-mm1
> or recent bk: applied cleanly to those rather than 2.6.6 or 2.6.7.
> So I've done my NULL sbinfo version below against that too.

Yeah, figures.  I wasn't sure exactly what the contents of the tree
I patched against were.  Usually doesn't metter to me.  Thanks for
being forgiving on it. :)

> This is really an agglommeration of several patches: NULL sbinfo based
> on (but eliminating) your SHMEM_NOSBINFO; a holey file panic fix which
> I sent Linus and lkml earlier on (which I wouldn't have found for weeks
> if you hadn't prompted me to look again here: thank you!); and replacing
> the shmem_inodes list of all by shmem_swaplist list of those which might
> have pages on swap, a less significant scalability enhancement.  I'll
> break it up into smaller patches when I come to submit it in a couple
> of weeks.  I've done basic testing, but it will need more later on
> (I'm unfamiliar with MS_NOUSER, not sure if my use of it is correct).
> I'm as likely to find a 512P machine as a basilisk, so scalability
> testing I leave to you.

Yeah, I saw the holey file thing fly by earlier today.  Good eye.

Will most definitely do.  I suspect that the NULL sbinfo will make my
SysV shared memory scaling bug go away too.

> I felt a little vulnerable, in making this scalability improvement
> for the invisible internal mount, that next someone (you?) would
> make the same complaint of the visible tmpfs mounts.  So now, if
> you "mount -t tmpfs -o nr_blocks=0 -o nr_inodes=0 tmpfs /wherever",
> the 0s will be interpreted to give a NULL-sbinfo unlimited mount.
> Generally inadvisable (unless /proc/sys/vm/overcommit_memory 2 is
> independently enforcing strict memory accounting), but useful to
> have as a more scalable option.

I don't think anyone at SGI will complain about a problem with tmpfs
mounts.  Undoubtedly the same problem exists there, but somehow I don't
see people doing heavy parallel page faulting on mmap()ed regular files.

But, as always, I reserve the right to be wrong. :)

But if someone does complain, we (you, wli, and I) have already
thought about some possible solutions -- so we're a step ahead!

Thanks for all your help with this.  I greatly appreciate it.  I'll
run your patch through some paces and let you know what it turns up.

Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
