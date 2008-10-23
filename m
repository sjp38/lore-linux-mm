Date: Thu, 23 Oct 2008 09:08:58 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081023070858.GC30765@wotan.suse.de>
References: <20081021112137.GB12329@wotan.suse.de> <87mygxexev.fsf@basil.nowhere.org> <20081022103112.GA27862@wotan.suse.de> <20081022184624.GB31902@cynthia.pants.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081022184624.GB31902@cynthia.pants.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brad Boyer <flar@allandria.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 22, 2008 at 11:46:24AM -0700, Brad Boyer wrote:
> On Wed, Oct 22, 2008 at 12:31:13PM +0200, Nick Piggin wrote:
> > The problem I've had with testing is that it's hard to trigger a specific
> > path for a given error, because write IO especially can be quite non
> > deterministic, and the filesystem or kernel may give up at various points.
> > 
> > I agree, but I just don't know exactly how they can be turned into
> > standard tests. Some filesystems like XFS seem to completely shut down
> > quite easily on IO errors. Others like ext2 can't really unwind from
> > a failure in a multi-block operation (eg. allocating a block to an
> > inode) if an error is detected, and it just gets ignored.
> > 
> > I am testing, but mainly just random failure injections and seeing if
> > things go bug or go undetected etc.
> 
> Something that might be useful for this kind of testing is a block
> device that is just a map onto a real block device but allows the
> user to configure it to generate various errors. If we could set it
> to always error on either read or write of particular block ranges,
> or randomly choose blocks to error from a pattern it could easily
> trigger many of the error paths. There was something like this on the
> Sega Dreamcast developer kit. The special version of the system used
> by developers had this sort of thing implemented in hardware in the
> link to the optical drive and this made error testing much easier. It
> should be possible to do something similar with a software driver.

We have this failure injection stuff for the block layer, which is
what I've been using. Probably it doesn't quite cover the possible
failure modes of block devices, but it seems to be a reasonable start.

It could use some extending to distinguish reads vs writes, and data
vs metadata, as Dave pointed out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
