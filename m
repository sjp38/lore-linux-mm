Date: Wed, 7 Jun 2000 14:41:02 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607144102.F30951@redhat.com>
References: <20000607121555.G29432@redhat.com> <Pine.LNX.4.21.0006071018320.14304-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0006071018320.14304-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Wed, Jun 07, 2000 at 10:23:35AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Hans Reiser <hans@reiser.to>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 10:23:35AM -0300, Rik van Riel wrote:
> > 
> > There is no need for subcaches at all if all of the pages can be
> > represented on the page cache LRU lists.  That would certainly
> > make balancing between caches easier.
> 
> Wouldn't this mean we could end up with an LRU cache full of
> unfreeable pages?

Rik, we need the VM to track dirty pages anyway, precisely so that
we can obtain some degree of write throttling to avoid having the
whole of memory full of dirty pages.

If we get short of memory, we really need to start flushing dirty
pages to disk independently of the task of finding free pages.  
Interrupts cannot wait for IO to complete --- they need the free 
memory immediately.  Page cleaning needs to be identified as a 
very different job from page reclaiming.  Whatever list we use to
track dirty pages can equally well be used for callbacks to 
transactional filesystems.

> This could get particularly nasty when we have a VM with
> active / inactive / scavenge lists... (like what I'm working
> on now)

Right, we definitely need a better distinction between different
lists and different types of page activity before we can do this.

> Question is, are the filesystems ready to play this game?

With an address_space callback, yes --- ext3 can certainly find
a transaction covering a given page.  I'd imagine reiserfs can do
something similar, but even if not, it's not important if the
filesystem can't do its lookup by page.  The mere fact that the
filesystem sees the VM trying to scavenge dirty pages can trigger
it into starting to flush its oldest transactions, and that is 
something that all filesystems should be able to do easily.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
