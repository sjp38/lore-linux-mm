Date: Fri, 24 Oct 2008 03:05:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
Message-ID: <20081024010504.GA5004@wotan.suse.de>
References: <20081021112137.GB12329@wotan.suse.de> <87mygxexev.fsf@basil.nowhere.org> <20081022103112.GA27862@wotan.suse.de> <20081022230715.GX18495@disturbed> <20081023070711.GB30765@wotan.suse.de> <20081023094416.GA6640@fogou.chygwyn.com> <20081023111500.GB7693@wotan.suse.de> <20081023224804.GD18495@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081023224804.GD18495@disturbed>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steve@chygwyn.com, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 24, 2008 at 09:48:04AM +1100, Dave Chinner wrote:
> On Thu, Oct 23, 2008 at 01:15:00PM +0200, Nick Piggin wrote:
> > On Thu, Oct 23, 2008 at 10:44:16AM +0100, steve@chygwyn.com wrote:
> > > Hi,
> > > 
> > > On Thu, Oct 23, 2008 at 09:07:11AM +0200, Nick Piggin wrote:
> > > > On Thu, Oct 23, 2008 at 10:07:15AM +1100, Dave Chinner wrote:
> > > [snip]
> > > > 
> > > > > You could do the same thing for metadata read operations. e.g. build
> > > > > a large directory structure, then do read operations on it (readdir,
> > > > > stat, etc) and inject errors into each of those. All filesystems
> > > > > should return the (EIO) error to the application in this case.
> > > > > 
> > > > > Those two cases should be pretty generic and deterministic - they
> > > > > both avoid the difficult problem of determining what the response
> > > > > to an I/O error during metadata modifcation should be....
> > > > 
> > > > Good suggestion.
> > > > 
> > > > I'll see what I can do. I'm using the fault injection stuff, which I
> > > > don't think can distinguish metadata, so I might just have to work
> > > > out a bio flag or something we can send down to the block layer to
> > > > distinguish.
> > > > 
> > > > Thanks,
> > > > Nick
> > > >
> > > 
> > > Don't we already have such a flag? I know that its not set in all
> > > the correct places in GFS2 so far, but I've gradually been fixing
> > > them to include BIO_RW_META where appropriate.
> >  
> > That should probably work. It seems to be very incomplete (GFS2
> > being one of the few exceptions). Though adding more support in
> > ext2 and buffer layer should be enough for me to start with,
> > and shouldn't be too hard.

I have a patch for (most of) buffer and ext2 btw. Seems to work OK.

 
> I've posted patches to tag XFS metadata with BIO_RW_META in the
> past, but that patch set had performance implications for different I/O
> schedulers so it never went further than just a patch. If I

Hmm, yes CFQ does do something with meta requests. It's a pity you
can't just add the annotations and file bugs with CFQ if it hurts
performance :P


> leave all the BIO_RW_SYNC tagging for the metadata bios, then
> a single line change to add BIO_RW_META should not have any
> performance impact....

Sorry, I don't understand what you mean here. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
