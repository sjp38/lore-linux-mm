Date: Wed, 23 Feb 2000 12:14:37 +0100 (MET)
From: Richard Guenther <richard.guenther@student.uni-tuebingen.de>
Subject: Re: mmap/munmap semantics
In-Reply-To: <m1hff0fuiu.fsf@flinx.hidden>
Message-ID: <Pine.LNX.4.10.10002231157350.5002-100000@linux14.zdv.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 22 Feb 2000, Eric W. Biederman wrote:
> Richard Guenther <richard.guenther@student.uni-tuebingen.de> writes:
> 
> > Hi!
> > 
> > With the ongoing development of GLAME there arise the following
> > problems with the backing-store management, which is a mmaped
> > file and does "userspace virtual memory management":
> 
> For this to be a productive discussion we need to know why 
> you want this.  What advantage do your changes/proposals provide.
> 
> Most of this sounds like you want to zero memory quickly.
> Does your code care that the memory is zero, or can you get away
> with simply getting memory quickly?

No, I do not want to simply zero the memory quickly. The main goal is
to avoid needless disk io. I'll try to elaborate on the use of the
GLAME (Audio processing tool) "swapfile":
- The swapfile is the backing store (large, preallocated, either a file
  or a complete disk) for audio tracks.
- The swapfile is organized into clusters (as is virtual memory into
  pages) who are reference counted and may be shared between multiple
  audio tracks.
- Access to the data of the audio tracks goes through handling out a
  memory map of one swapfile cluster at a time (clusters are not fixed
  in size but at least page aligned)
- Those memory maps of the clusters are cached to aviod the disk io
  of mmap/munmap sequences, a cluster is mmapped at most one time
  (from the GLAME program) but the address of the mapping is handed out
  possibly n times to the worker threads (this is reference counted).
- If the reference count of a cluster (not the mapping) drops to zero,
  it is no longer used by any of the audio tracks which populate the
  swapfile.
  Now I want to munmap the mapping of the no longer used swapfile cluster
  _without_ generating any disk io (i.e. I do not care about the actual
  contents of the swapfile at the place of the cluster).
  This cannot be done at the moment?
- If a cluster is mmaped the first time the semantics of the GLAME
  swapfile require it to be zeroed. At the moment I achieve this by
  mmapping the cluster and zeroing it by reading from /dev/zero - this
  is fine, but ideally I do not want the disk copy of the cluster to
  change (to these zeros) until somebody actually _writes_ to the mapping.
  I.e. ideally I want to have a clean ro mmap of /dev/zero, handle a
  SIGSEGV in user space and somehow exchange the private mapping of
  /dev/zero with a shared rw mapping of the swapfile (of course inclusive
  zeroing this mapping first) and just continue. 

So I have sort of virtual memory management with a automatic updated
disk copy - but please with the least amount of disk io possible.

Does this sound reasonable?

Richard.

> > - I cannot see a way to mmap a part of the file but set the
> >   contents initially to zero, i.e. I want to setup an initially
> >   dirty zero-mapping which is assigned to a part of the file.
> Why dirty?

This would be the easiest way - I want the zeroes written back to
disk.

> >   Currently I'm just mmaping the part and do the zeroing by
> >   reading from /dev/zero (which does as I understand from the
> >   kernel code just create this zero mappings) - is there a more
> >   portable way to achieve this?
> memset...

Portable, yes - efficient? certainly no in the read only case.

> > - I need to "drop" a mapping sometimes without writing the contents
> >   back to disk - 
> 
> You do know that with a shared mapping the kernel can write
> the contents back to disk whenever it feels like it.
> What is the benefit of not writing things to disk?

I know that the kernel can write back to disk at any time it likes. I do
not care about this possibility. But at a certain point I know I will
not need the contents of a _part_ of the file anymore. So I want to
avoid syncing back a huge amount of memory to disk at munmap time if
I know I wont need the data. (huge amount == 4 to 32 MB usually)

> >   I cannot see a way to do this with linux currently.
> >   Ideally a hole could be created in the mmapped file on drop time -
> >   is this possible at all with the VFS/ext2 at the moment (creating
> >   a hole in a file by dropping parts of it)?
> Again why do you want this?

See my above description

> > 
> > So for the first case we could add a flag to mmap like MAP_ZERO to
> > indicate a zero-map (dirty).
> 
> Possibly. madavise(MADV_WILLNEED)  sounds probably like what you
> want. (After using ftruncate to zero everything quickly).

I'm satisfied with the read from /dev/zero approach, but ideally - see
above - I really want to switch from a private to a shared mapping
on-demand (on write).

> > For the second case either the munmap call needs to be extended or
> > some sort of madvise with a MADV_CLEAN flag? 
> Poking holes is probably not what you want.  The zeroing cost
> will be paid somewhere.

Ok, I got this. Creating holes is no longer on my wishlist - but avoiding
nedless disk io is.

> > Or we can just adjust
> > mprotect(PROT_NONE) and subsequent munmap() to do the dropping?
> 
> This is definetly not right. mprotect(PROT_NONE) has very clear
> semantics, as does munmap, and this suggestion would break them.

Ok, just an idea.


Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
