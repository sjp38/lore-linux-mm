From: Andi Kleen <andi@firstfloor.org>
Message-Id: <20080318209.039112899@firstfloor.org>
Subject: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Date: Tue, 18 Mar 2008 02:09:34 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchkit is an experimental optimization I played around with 
some time ago.

This is more a prototype still, but I wanted to push it out 
so that other people can play with it.

The basic idea is that most programs have the same working set
over multiple runs. So instead of demand paging all the text pages
in the order the program runs save the working set to disk and prefetch
it at program start and then save it at program exit.

This allows some optimizations: 
- it can avoid unnecessary disk seeks because the blocks will be fetched in 
sorted offset order instead of program execution order. 
- batch kernel entries (each demand page exception has some
overhead just for entering the kernel). This keeps the caches hot too.
- The prefetch could be in theory done in the background while the program 
runs (although that is not implemented currently)

Some details on the implementation:

To do all this we need a bitmap space somewhere in the ELF executable. I originally
hoped to use a standard ELF PHDR for this, which are already parsed by the
Linux ELF loader. However the problem is that PHDRs are part of the 
mapped program image and inserting any new ones requires relinking
the program. Since relinking programs just to get this would be 
rather heavy-handed I used a hack by setting another bitflag 
in the gnu_execstack header and when it is set let the kernel
look for ELF SHDRs at the end of the file. Disadvantage is that
this costs a seek, but it allows easily to update existing 
executables with a simple too.

The seek overhead would be gone if the linkers are taught to 
always generate a PBITMAP bitmap header.

I also considered external bitmap files, but just putting it into the ELF
files and keeping it all together seemed much nicer policywise.

Then there is some probability of thrashing the bitmap, e.g. when
a program runs in different modi with totally different working sets
(a good example of this would be busybox). I haven't found
a good heuristic to handle this yet (e.g. one possibility would
be to or the bitmap instead of rewriting it on exit) this is something
that could need further experimentation. Also one doesn't want
too many bitmap updates of course so there is a simple heuristic 
to not update bitmaps more often than a sysctl configurable 
interval.  

User tools:
ftp://ftp.firstfloor.org/pub/ak/pbitmap/pbitmap.c 
is a simple program to a pbitmap shdrs to an existing ELF executable.

Base kernel:
Again 2.6.25-rc6

Drawbacks: 
- No support for dynamic libraries right now (except very clumpsily
through the mmap_slurp hack). This is the main reason it is not 
very useful for speed up desktops currently. 

- Executable files have to be writable by the user executing it
currently to get bitmap updates. It would be possible to let the 
kernel bypass this, but I haven't thought too much about the security 
implications of it.
However any user can use the bitmap data written by a user with
write rights.

That's currently one of the bigger usability issues (together
with the missing shared library support) and why it is more 
a prototype than a fully usable solution.

Possible areas of improvements if anybody is interested:
- Background prefetch
- Tune all the sysctl defaults
- Implement shared library support (will require glibc support)
- Do something about the executable access problem
- Experiment with more fancy heuristics to update bitmaps (like OR
or do aging etc.) 

-Andi 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
