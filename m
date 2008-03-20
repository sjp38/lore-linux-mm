Date: Thu, 20 Mar 2008 10:00:05 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH prototype] [0/8] Predictive bitmaps for ELF executables
Message-ID: <20080320090005.GA25734@one.firstfloor.org>
References: <20080318209.039112899@firstfloor.org> <20080318003620.d84efb95.akpm@linux-foundation.org> <20080318141828.GD11966@one.firstfloor.org> <20080318095715.27120788.akpm@linux-foundation.org> <20080318172045.GI11966@one.firstfloor.org> <20080318104437.966c10ec.akpm@linux-foundation.org> <20080319083228.GM11966@one.firstfloor.org> <20080319020440.80379d50.akpm@linux-foundation.org> <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a36005b50803191545h33d1a443y57d09176f8324186@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 19, 2008 at 03:45:16PM -0700, Ulrich Drepper wrote:
> On Wed, Mar 19, 2008 at 2:04 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >  The requirement to write to an executable sounds like a bit of a
> >  showstopper.
> 
> Agreed.  In addition, it makes all kinds of tools misbehave.  I can
> see extensions to the ELF format and those would require relinking
> binaries, but without this you create chaos.  ELF is so nice because

What chaos exactly? For me it looks rather that a separatate database
would be a recipe for chaos. e.g. for example how would you make sure
the database keeps track of changing executables?

The only minor issue is rpm -Va and similar, but that can be handled
in the same way as prelinking is handled there by using filter scripts
that reset the bitmap before taking a checksum.

Also the current way does not require relinking by using the shdr hack.
I have a simple program that adds a bitmap shdr to any executable.
But if the binutils leanred about this and added a bitmap phdr (it 
tends to be only a few hundred bytes even on very large executables)
one seek could be avoided.


> it describes the entire file and we can handle everything according to
> rules.  If you just somehow magically patch some new data structure in
> this will break things.

Can you elaborate what you think will be broken?

> 
> Furthermore, by adding all this data to the end of the file you'll

We are talking about 32bytes for each MB worth of executable.
You can hardly call that "all that data". Besides the prefetcher supports
in theory larger page sizes, so if you wanted you could even reduce
that even more by e.g. using 64k prefetch blocks. But the overhead
is so tiny that it doesn't make much difference.

> normally create unnecessary costs.  The parts of the binaries which
> are used at runtime start at the front.  At the end there might be a
> lot of data which isn't needed at runtime and is therefore normally
> not read.

Yes as I said using the SHDR currently requires an additional seek
(although in practice i expect it to be served out of the track
buffer of the hard disk if the executable is not too large and is
continuous on disk). If binutils were taught of generating a phdr
that minor problem would go away.
 
> 
> 
> >  if it proves useful, build it all into libc..
> 
> I could see that.  But to handle it efficiently kernel support is
> needed.  Especially since I don't think the currently proposed

I agree.

> "learning mode" is adequate.  Over many uses of a program all kinds of

It is not too bad, but could be certainly better. I outlined
some possible ways to improve the algorithms in my original way.
It would be a nice research project for someone to investigate
the various ways (anyone interested?)

> pages will be needed.  Far more than in most cases.  The prefetching
> should really only cover the commonly used code paths in the program.

Sorry that doesnt make sense. Anything that is read at startup
has to be prefetched, even if that code is only executed once.
Otherwise the whole scheme is rather useless.
Because even a single access requires the IO to read it from
disk.

> If you pull in everything, this will have advantages if you have that
> much page cache to spare.  In that case just prefetching the entire

Yes that is what the "mmap_flush" hack (last patch does) I actually
have some numbers on a older kernel and in some cases it really
does quite well. But it also has a few problems (e.g. interaction
with data mmaps and memory waste) that are unpleasant.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
