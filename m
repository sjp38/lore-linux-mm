Received: from alogconduit1ah.ccr.net (root@alogconduit1al.ccr.net [208.130.159.12])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA11867
	for <linux-mm@kvack.org>; Sun, 23 May 1999 14:31:59 -0400
Subject: Re: [PATCHES]
References: <Pine.LNX.3.96.990523171206.21583A-100000@chiara.csoma.elte.hu>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 May 1999 13:34:11 -0500
In-Reply-To: Ingo Molnar's message of "Sun, 23 May 1999 17:49:18 +0200 (CEST)"
Message-ID: <m1emk7skik.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "IM" == Ingo Molnar <mingo@chiara.csoma.elte.hu> writes:

My current patches can be found at:
http://www.ccr.net/ebiederm/files
in:
patches9.tar.gz
and soon in
shmfs-0.1.011.tar.gz  (Which should go out later today).

shmfs is my filesystem that resides in swap & the page cache.
Currently it doesn't work with swap-off, but that is in progress.

IM> On 23 May 1999, Eric W. Biederman wrote:

LT> - Ingo just did the page cache / buffer cache dirty stuff, this is going
LT> to clash quite badly with his changes I suspect.
>> 
>> Interesting. I have been telling folks I've been working on this for
>> quite a while. I wish I'd heard about him or vis versa. 

IM> i'm mainly working on these two areas:

IM>  - merging ext2fs (well, this means basically any block-based filesystem,
IM>    but ext2fs is the starting point) data buffers into the page cache.

IM>  - redesigning the page cache for SMP (mainly because i was touching
IM>    things and introducing bugs anyway) [on my box the page cache is
IM>    already completely parallel on SMP, we drop the kernel lock on entry
IM>    into page-cache routines and re-lock it only if we call
IM>    filesystem-specific code or buffer-cache code. (in this patch the
IM>    ll_rw_block IO layer is being executed outside the kernel lock as well,
IM>    and appears to work quite nicely.]

- I added support for large files for much the same reason.

my summary of patches is:
The patches included are:
eb1 --- Allow reuse of page->buffers if you aren't the buffer cache
eb2 --- Allow old old a.out binaries to run even if we can't mmap them
	properly because their data isn't page aligned.
eb3 --- Muck with page offset.
eb4 --- Allow registration and unregistration for functions needed by
	swap off.  This allows a modular filesystem to reside in swap...
eb5 --- Large file support, basically this removes unused bits from all
	of the relevant interfaces.   I also begin to handle PAGE_CACHE_SIZE
	!= PAGE_SIZE
eb6 --- Introduction of struct vm_store, and associated cleanups.
	In particular get_inode_page.
	vm_store is a variation on the inode struct which is
	lighter weight.  
	vm_stores's seperates out the vm layer from the vfs layer more,
	making things like the swap_cache easier to build, and cleaner.
	This is potentially very useful and the cost is low.
eb7 --- Actuall patch for dirty buffers in the page cache.
	I'm fairly well satisfied except for generic_file_write.
	Which I haven't touched.
	It looks like I need 2 variations on generic_file_write at the
	moment. 
	1) for network filesystems that can get away without filling
	   the page on a partial write.
	2) for block based filesystems that must fill the page on a
	   partial write because they can't write arbitrary chunks of
	   data.
eb8 -- Misc things I use, Included simply for reference.

IM> the design/implementation is this: we put dirty and clean block-device
IM> pages into the buffer-cache as well. bdflush automatically takes care of
IM> undirtying buffers (pages). I've modified ext2fs to to have block
IM> allocation/freeing separated from read/write/truncate activities, and now
IM> ext2fs uses (a modified version of) generic_file_write(). 

Yes the current version of generic_file_write() which doesn't read
before writing is interesting. . .

IM> This brought
IM> some fuits already: whenever we write big enough to modify a full,
IM> uncached page, we can now overwrite the page-cache page without first
IM> having to read it. (security issues taken care of as well) [the old
IM> mechanizm was that we first allocated the data block which was memset to
IM> zero deep inside ext2fs's block allocation path, then we read the block if
IM> this was a partial write, then we overwrote it with data from user-space. 
IM> yuck.]

I don't think I ever traced it deep enough to see the memset.
But I follow.  It sounds like you have made some nice performance
improvements.  The first version of my stuff is just after unlocking potential.

IM> the current state of the patch is that it's working and brings a nice
IM> performance jump on SMP boxes on disk-benchmarks and is stable even under
IM> heavy stress-testing. Also (naturally) dirty buffers show up only once, in
IM> the page cache. I've broken some things though (swapping and NFS
IM> side-effects are yet untested), i'm currently working on cleaning the
IM> impact on these things up, once it's cleaned up (today or tomorrow) i'll
IM> Cc: you as well.

Cool.  If you are really that close to done we can probably
synchronise our work and submit the result to Linus.  I think we are
conceptually orthogonal except for handle dirty data in the page
cache.  And that _needs_ synchronizing.

My patches that don't depend on dirty data in the page cache, (large
files, no need to support unaligned mappings, etc) I'm going to send in
now.

IM> i didnt know about you working on this until Stephen Tweedie told me, then
IM> i quickly looked at archives and (maybe wrongly?) thought that while our
IM> work does collide patch-wise but is quite orthogonal conceptually.

Except that we both handle dirty data in the page cache...
Hmm.  You must not subscribe to linux-mm@kvack.org (It's a majordomo list)
There isn't a linux-vfs list out there anywhere is there?

IM>  I've
IM> tried to sync activities with others working in this area (Andrea for
IM> example). I completely overlooked that you are working on the block-cache
IM> side as well, would you mind outlining the basic design? 

Well I'm trying to eliminate the buffer cache...

My work on dirty pages sets up a bdflush like mechanism on top of the page
cache.  So for anything that can fit in the page cache the buffer cache
simply isn't needed.   Where the data goes when it is written simply doesn't
matter.

This means that everyone can reuse the same mechanism for keeping track of 
what is dirty and what isn't.  As this a significant kernel tuning issue
I thinks it's better (if possible) to share the code between all of
the filesystems.

Further the mechanism for writing handling dirty buffers doesn't need
to be tied to the disk buffers.  As far as I can tell bdflush doesn't
really care that data is going to disk except that:
(a) it calls ll_rw_block(instead of calling through a function) and
(b) it names all of the buffers by their destination on the disk.

Something as brilliant as that could happily sit at the page cache
level and be reusable, by all filesystems.

This also allows allocation on write and other fun tricks.

I have recoverd the buffer pointer in struct page, and put it to use
as a generic pointer.  A block based filesystem will probably use
is as a pointer to buffers, but NFS can use it for something else..

IM> one thing i saw in one of your earlier mails: an undirtification mechanizm
IM> in the page cache, although i've still got to see your patch (is it
IM> available somewhere?). Originally i thought about doing it that way too,
IM> but then i have avoided to have the page-writeout mechanizm in the
IM> page-cache according to Linus's suggestion. 

I'm not familiar with that suggestion.
I do know the page writeout mechanism shouldn't be in shrink-mmap...

IM>  I'm now pretty much convinced
IM> that this is the right way: future optimizations will enable us to delay
IM> the filesystem block allocation part completely (apart from bumping free
IM> space estimation counters up and down and thus avoiding the async 'out of
IM> free space' problem).

I've played with things a couple of different ways, (so I'm not
certain what you saw).

I can already delay the filesystem block allocation, though I currently don't
do that in shmfs because last time I played with that it wasn't working too
well.  Mainly because I had a pretty stupid on demand allocator, instead
of allocating for all dirty pages of a file at once.

What I do now is allocate blocks when they are written too, (which works great
without contention).  With contention a delayed strategy almost certainly
will do better.  The other limiting factor of my fs is I'm using swap
pages so I'm not totally in control, of block allocation.

IM> I'd like the page cache end up in a design where we can almost completely
IM> avoid any filesystem overhead for quickly created/destroyed and/or fully
IM> cached files. I'd like to have a very simple unaliased pagecache and no
IM> filesystem overhead, on big RAM boxes. 
IM> This was the orignal goal of the
IM> page cache as well, as far as i remember. Turning the page-cache into a
IM> buffer-cache again doesnt make much sense IMO... 

An unaliased pagecache?  I'm not quite certain what you mean by that.

I don't intend to turn it into a buffer-cache, but I was thinking of
sitting what must remains of the buffer-cache in page-cache inode, like swap
is now.

And the low over head sounds good to me too.  Right now there are a
couple of paths I would like to clean up.  In particular dirtying
mapped pages, in the swap out routines.  

If/when all of the filesystems are converted over I can just about do
it with a simple mark_page_dirty call, (except this doesn't handle fs
that want to track on a finer granularity what is dirty...)
So I'll probably wind up calling something like updatepage.
Except right now updatepage has way too much overhead.



Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
