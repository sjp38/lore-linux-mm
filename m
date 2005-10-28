Date: Fri, 28 Oct 2005 02:22:31 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051028002231.GC5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <20051027200434.GT5091@opteron.random> <20051027135058.2f72e706.akpm@osdl.org> <20051027213721.GX5091@opteron.random> <20051027152340.5e3ae2c6.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051027152340.5e3ae2c6.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 03:23:40PM -0700, Andrew Morton wrote:
> It's slowly becoming clearer ;)

;)

> But in the case of O_DIRECT and acls we had a plan, from day one, to extend
> the capability to many (ideally all) filesystems.

for acl I'm unsure if we really hoped for all fs to have it, it's
similar for holepunching, vfat simply can't get it ;)

> Right.  Sometime, maybe.  There's been _some_ demand for holepunching, but
> it's been fairly minor and is probably a distraction from this immediate
> and specific customer requirement.

Yes, holepunching in a real fs is a distraction at the moment, tmpfs is
the real need.

> Right.  And in the future I think it would be designed as a generalisation
> of sys_ftruncate().

Except we can't change sys_ftruncate, and they don't have a clue on
what's the fd backing the mapping, nor the offsets.

> - View it as a filesystem operation which has MM side-effects.

I suggested the fs operation too but then it's more efficient to have it
as a mm operation with fs side effects, because they don't immediatly
know fd and physical offset of the range. It's possible to fixup in
userland and to use the fs operation but it's more expensive, the vmas
are already in the kernel and we can use them.

> - Initially access it via sys_ipc()  (or madvise, I guess.  Both are a bit odd)
> 
> - Later access it via sys_[hole]punch()
> 
> Alternatively, access it via sys_[hole]punch() immediately, but I'm not
> sure that userspace can get access to the shm area's fd?

The ipc is not a problem, all data is in tmpfs, it's not ipc shared
memory. The problem is translating from virtual range to fd/physical
range, that something the kernel can do faster internally.

The app is not open source so I've to trust them it's true kernel will
lookup it faster and cheaper with the vma.

I like both of the fs and mmap apis being available, and for the mmap
one madvise just looks normal. madvise is already destructive for
anonymous memory, we're just going to make it destructive for filebacked
mappings too the same way. Infact perhaps we can make MADV_TRUNCATE
fallback into MADV_FREE (current MADV_DONTNEED) mode when on anonymous
memory. I don't see anything fundamentally wrong with such an API, as
long as kernel internals remains sane (i.e. we don't run into
fundamental locking problems etc..).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
