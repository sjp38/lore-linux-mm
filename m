Received: from chiara.csoma.elte.hu (chiara.csoma.elte.hu [157.181.71.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA10364
	for <linux-mm@kvack.org>; Sun, 23 May 1999 11:50:22 -0400
Date: Sun, 23 May 1999 17:49:18 +0200 (CEST)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: [PATCHES]
In-Reply-To: <m1k8tzsuo1.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.990523171206.21583A-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 May 1999, Eric W. Biederman wrote:

> LT>  - Ingo just did the page cache / buffer cache dirty stuff, this is going
> LT>    to clash quite badly with his changes I suspect.
> 
> Interesting. I have been telling folks I've been working on this for
> quite a while. I wish I'd heard about him or vis versa. 

i'm mainly working on these two areas:

 - merging ext2fs (well, this means basically any block-based filesystem,
   but ext2fs is the starting point) data buffers into the page cache.

 - redesigning the page cache for SMP (mainly because i was touching
   things and introducing bugs anyway) [on my box the page cache is
   already completely parallel on SMP, we drop the kernel lock on entry
   into page-cache routines and re-lock it only if we call
   filesystem-specific code or buffer-cache code. (in this patch the
   ll_rw_block IO layer is being executed outside the kernel lock as well,
   and appears to work quite nicely.]

the design/implementation is this: we put dirty and clean block-device
pages into the buffer-cache as well. bdflush automatically takes care of
undirtying buffers (pages). I've modified ext2fs to to have block
allocation/freeing separated from read/write/truncate activities, and now
ext2fs uses (a modified version of) generic_file_write(). This brought
some fuits already: whenever we write big enough to modify a full,
uncached page, we can now overwrite the page-cache page without first
having to read it. (security issues taken care of as well) [the old
mechanizm was that we first allocated the data block which was memset to
zero deep inside ext2fs's block allocation path, then we read the block if
this was a partial write, then we overwrote it with data from user-space. 
yuck.]

the current state of the patch is that it's working and brings a nice
performance jump on SMP boxes on disk-benchmarks and is stable even under
heavy stress-testing. Also (naturally) dirty buffers show up only once, in
the page cache. I've broken some things though (swapping and NFS
side-effects are yet untested), i'm currently working on cleaning the
impact on these things up, once it's cleaned up (today or tomorrow) i'll
Cc: you as well.

i didnt know about you working on this until Stephen Tweedie told me, then
i quickly looked at archives and (maybe wrongly?) thought that while our
work does collide patch-wise but is quite orthogonal conceptually. I've
tried to sync activities with others working in this area (Andrea for
example). I completely overlooked that you are working on the block-cache
side as well, would you mind outlining the basic design? 

one thing i saw in one of your earlier mails: an undirtification mechanizm
in the page cache, although i've still got to see your patch (is it
available somewhere?). Originally i thought about doing it that way too,
but then i have avoided to have the page-writeout mechanizm in the
page-cache according to Linus's suggestion. I'm now pretty much convinced
that this is the right way: future optimizations will enable us to delay
the filesystem block allocation part completely (apart from bumping free
space estimation counters up and down and thus avoiding the async 'out of
free space' problem).

I'd like the page cache end up in a design where we can almost completely
avoid any filesystem overhead for quickly created/destroyed and/or fully
cached files. I'd like to have a very simple unaliased pagecache and no
filesystem overhead, on big RAM boxes. This was the orignal goal of the
page cache as well, as far as i remember. Turning the page-cache into a
buffer-cache again doesnt make much sense IMO... Right now (profiled on my
patch) for cached midsize file-IO the main non-data-copying overhead is
block allocation.  Block allocation _has_ to be complex on a true
block-device or otherwise the filesystem is simply not trying hard enough
to avoid fragmentation.  This is a fundamental conflict. And we will avoid
the data copying overhead with better IO syscalls.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
