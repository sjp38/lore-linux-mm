Date: Wed, 7 Jun 2000 22:49:08 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607224908.K30951@redhat.com>
References: <393E8AEF.7A782FE4@reiser.to> <Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva> <20000607205819.E30951@redhat.com> <ytt1z29dxce.fsf@serpe.mitica> <20000607222421.H30951@redhat.com> <yttvgzlcgps.fsf@serpe.mitica>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <yttvgzlcgps.fsf@serpe.mitica>; from quintela@fi.udc.es on Wed, Jun 07, 2000 at 11:40:47PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 11:40:47PM +0200, Juan J. Quintela wrote:
> Hi
> Fair enough, don't put pinned pages in the LRU, *why* do you want put
> pages in the LRU if you can't freed it when the LRU told it: free that
> page?

Because even if the information about which page is least recently
used doesn't help you, the information about which filesystems are
least active _does_ help.

> Ok. New example.  You have the 10 (put here any number) older
> pages in the LRU.  That pages are pinned in memory, i.e. you can't
> remove them.  You will call the ->flush() function in each of them
> (put it any name for the method).  Now, the same fs has a lot of new
> pages in the LRU that are being used actively, but are not pinned in
> this precise instant.  Each time that we call the flush method, we
> will free some dirty pages, not the pinned ones, evidently. We will
> call that flush function 10 times consecutively.  Posibly we will
> flush all the pages from the cache for that fs, and for not good
> reason.

No, Rik was explicitly allowing the per-fs flush functions to 
indicate how much progress was being made, to avoid this.

> I will be also very happy with only one place where doing the aging,
> cleaning, ... of _all_ the pages, but for that place we need a policy,
> and that policy _must_ be honored (almost) always or it doesn't make
> sense and we will arrive to unstable/unfair situations.

We _have_ to have separate mechanisms for page cleaning and for page
reclaim.  Interrupt load requires that we free pages rapidly on 
demand, regardless of whether the page cleaner is stalled in the 
middle of a write operation or not.

> I am working just now in a patch that will allow pages to be defered
> the write of mmaped pages from the swap_out function to shrink_mmap
> time.  The same that we do with swap pages actually, but for fs pages
> mmaped in processes.  That would help that.  But note that in this
> case, I put in the LRU pages that can be freed.  I can't understand
> putting pages that are not freeable.

We are talking about separate queues for the different page types ---
you obviously don't want to pollute the clean (inactive?) list with
pinned pages.  Within the list of pinned pages (or dirty pages), we
still want to maintain enough ordering so that we go to the filesystems
in the right order when we start cleaning pages.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
