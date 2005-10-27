Date: Thu, 27 Oct 2005 22:04:34 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051027200434.GT5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051027112054.10e945ae.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: pbadari@us.ibm.com, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 11:20:54AM -0700, Andrew Morton wrote:
> googling MADV_DISCARD comes up with basically nothing.  MADV_TRUNCATE comes
> up with precisely nothing.
> 
> Why does tmpfs need this feature?  What's the requirement here?  Please
> spill the beans ;)

MADV_TRUNCATE is a name I made up myself last month. During a
presentation at suse labs conf some people at SUSE even complained that
it may not be the right name (they intended the word truncate as
reducing the i_size), but it made sense to me since internally
what it does is a truncate_range (plus truncate also increases the size,
it's not only a "truncate" anyway).

The idea is to implement a sys_truncate_range, but using the mappings so
the user doesn't need to keep track of which parts of the file have to
be truncated, and it only needs to know which part of the address space
is obsolete. This will be the first API that allows to re-create holes
in files.

I'm not a buzzword(tm) producer, so if you don't like the name feel free
to rename it, I don't actually care about names. For now MADV_TRUNCATE
is a placeholder name, which quite clearly explains what the syscall
does.

> Comment on the patch: doing it via madvise sneakily gets around the
> problems with partial-page truncation (we don't currently have a way to
> release anything but the the tail-end of a page's blocks).
> 
> But if we start adding infrastructure of this sort people are, reasonably,
> going to want to add sys_holepunch(fd, start, len) and it's going to get
> complexer.

Yes, I also wanted to add both a sys_truncate_range and a MADV_TRUNCATE,
but the partner only needs MADV_TRUNCATE and they don't care about the
sys_truncate_range, so it got higher prio.

When I received MADV_DISCARD patch I suggested Badari to actually
implement the MADV_TRUNCATE, in the short term we only care about tmpfs
of course (the same would apply to a sys_truncate_range), but I think
the MADV_TRUNCATE API is cleaner for the long term than a tmpfs specific
hack.

Some app allocates large tmpfs files, then when some task quits and some
client disconnect, some memory can be released. However the only way to
release tmpfs-swap is to MADV_TRUNCATE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
