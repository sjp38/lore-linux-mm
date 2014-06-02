Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B6FE86B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 06:32:13 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so3274644pde.4
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 03:32:13 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id ay4si15234461pbc.122.2014.06.02.03.32.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 03:32:12 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so3266920pdj.6
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 03:32:12 -0700 (PDT)
Date: Mon, 2 Jun 2014 03:30:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 1/3] shm: add sealing API
In-Reply-To: <CANq1E4TBDdj9dGB9fP6KhN5Q1NXbehbSQ0SV+3Qvnn7f8+_=Cw@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1406020235400.1259@eggly.anvils>
References: <1397587118-1214-1-git-send-email-dh.herrmann@gmail.com> <1397587118-1214-2-git-send-email-dh.herrmann@gmail.com> <alpine.LSU.2.11.1405191911050.2970@eggly.anvils> <CANq1E4TBDdj9dGB9fP6KhN5Q1NXbehbSQ0SV+3Qvnn7f8+_=Cw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>, Jan Kara <jack@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <greg@kroah.com>, John Stultz <john.stultz@linaro.org>, Kristian Hogsberg <krh@bitplanet.net>, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>

On Fri, 23 May 2014, David Herrmann wrote:
> 
> i_mmap_mutex is the only per-object lock that is taken in the mmap()
> path and all vma_link() users can easily be changed to deal with
> errors. So I think it should be easy to make __vma_link_file() fail if
> no writable mappings are allowed. Testing for shmem-seals seems odd
> here, indeed. We could instead make i_mmap_writable work like
> i_writecount. If it's negative, no new writable mappings are allowed.
> shmem_set_seals() could then decrement it to <0 and __vma_link_file()
> just tests whether it's negative. Comments?

i_mmap_mutex is certainly the right lock, and I'm happy with making
i_mmap_writable use the negative like i_writecount if that helps.

But I have to confess that I'm annoyingly stalled on this.  The part
I do not like (although I suggested it) is giving an error return to
__vma_link_file() and hence to vma_link().

Because successful return from file->f_op->mmap() is supposed to be
mmap's point of no return, and if we allow vma_link() to fail, then the
file->f_op->mmap() ought to be undone in a way never needed before.

Now, you know and I know that the vma_link() can only fail on sealed
shmem objects, and shmem_mmap() doesn't do anything that we need to
recover from (I don't think we need worry too much about the atime
update in file_accessed()).  But error from vma_link() does set a
trap (or a puzzle) for the unwary, and I'd prefer to avoid it.
We can comment it, but it still feels dirty.

I'm inclined to say that your shmem_mmap() (which already checks
sealed against shared) ought to manage i_mmap_writable itself (under
i_mmap_mutex); but then we need a funny little VM_flag for shmem_mmap()
to tell __vma_link_file() that i_mmap_writable++ has already been done;
or else some dance of ->opens and ->closes to keep its accounting right.

As I say, I am annoyingly stalled on this: so I'd better just let you
get on with it, and see how I feel about whatever you come up with.

> >
> > There is also, or may be, a small issue of sparse (holey) files.
> > I do have a question on that in comments on your next patch, and
> > the answer here may depend on what you want in memfd_create().
> >
> > What I'm thinking of here is that once a sparse file is sealed
> > against writing, we must be sure not to give an error when reading
> > its holes: whereas there are a few unlikely ways in which reading
> > the holes of a sparse tmpfs file can give -ENOMEM or -ENOSPC.
> >
> > Most of the memory allocations here can in fact only fail when the
> > allocating process has already been selected for OOM-kill: that is
> > not guaranteed forever, but it is how __alloc_pages_slowpath()
> > currently behaves on ordinary low-order allocations, and will be
> > hard to change if we ever do so.  Though I dislike relying upon
> > this, I think we can allow reading holes to fail, if the process
> > is going to be forcibly killed before it returns to userspace.
> >
> > But there might still be an issue with vm_enough_memory(),
> > and there might still be an issue with memcg limits.
> >
> > We do already use the ZERO_PAGE instead of allocating when it's a
> > simple read; and on the face of it, we could extend that to mmap
> > once the file is sealed.  But I am rather afraid to do so - for
> > many years there was an mmap /dev/zero case which did that, but
> > it was an easily forgotten case which caught us out at least
> > once, so I'm reluctant to reintroduce it now for sealing.
> >
> > Anyway, I don't expect you to resolve the issue of sealed holes:
> > that's very much my territory, to give you support on.
> 
> Why not require users to use mlock() if they want to protect
> themselves against OOM situations? At least the man-page says that
> mlock() guarantess that all pages in the specified range are loaded. I
> didn't verify whether that includes holes, though. And if
> RLIMIT_MEMLOCK is too small, users ought to access the object in
> smaller chunks.

Fair enough.
mlock() does instantiate the holes, in shmem's case at least.
mlock() is an mm operation, whereas in general we have a file here,
which is not necessariy mmap'ed.  It's a pity to ask the user to
mmap+mlock to achieve that effect; but okay, that does the job.

> And it's not specific to sparse files. Any other page may be swapped
> out and the swap-in can fail due to ENOMEM (page-table allocations,
> tree-inserts, and so on). But you definitely know better what to do
> here, so suggestions welcome.

You're right that OOM can hit you, even when just swapping in a page
that was properly instantiated before.  But those pages are better
accounted than holes: I still feel that the holes could be seen as
a sealed bomb, which explodes into OOM when read by the caller.

> 
> Anyway, sealing is not meant to protect against OOM situations. I
> mean, any mapping is subject to OOM, so processes that care should
> have a suitable infrastructure via SIGBUS or mlock() for all mappings,
> including sealed files. Furthermore, write-sealing is meant to prevent
> targeted attacks that modify data while it is being parsed. We
> properly protect users against that. OOM is an orthogonal issue, imho.

But I'm happy to hear that OOM doesn't trouble you, that you see it
as orthogonal.  Sealing does prompt me again to look into reworking
the issue of sparse files (never well handled in shmem), but from
what you say that's not urgent - a relief to both of us, thank you.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
