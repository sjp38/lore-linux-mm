Message-ID: <393DA31A.358AE46D@reiser.to>
Date: Tue, 06 Jun 2000 18:19:22 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Tue, 6 Jun 2000, Stephen C. Tweedie wrote:
> 
> > It wasn't a journaling API we were talking about for this.  The
> > problem is much more central to the VM than that --- basically,
> > the VM currently assumes that any existing page can be evicted
> > from memory with very little extra work.  It just isn't prepared
> > for the situation that you have with transactions,
> 
> > journaling itself, but the transactional requirements which are
> > the problem --- basically the VM cannot do _anything_ about
> > individual pages which are pinned by a transaction, but rather
> > we need a way to trigger a filesystem flush, AND to prevent more
> > dirtying of pages by the filesystem (these are two distinct
> > problems), or we just lock up under load on lower memory boxes.
> 
> This is especially tricky in the case of a large mmap()ed
> file. We'll have to restrict the maximum number of read-write
> mapped pages from such a file in order to keep the system
> stable...
> 
> (try mmap002 from quintela's MM test suite with a journaling
> FS for a nice change...)
> 
> > A reservation API which lets all transactional filesystems
> > reserve the right to dirty a certain number of pages in advance
> > of actually needing them is really needed to avoid such lockups.
> > The reservation call can stall if the memory limit has been
> > reached, providing flow control to the filesystem; and a
> > notification list can start committing and flushing older
> > transactions when that happens.
> 
> Indeed we need this. Since I seem to be coordinating the VM
> changes at the moment anyway, I'd love to work together with
> the journaling folks on solving this problem...
> 
> It will require some changes in the page fault path and some
> other areas...
> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/               http://www.surriel.com/


quite happy to see you drive it, I suggest to check with zam as he has some code
in progress.

There are two issues to address:

1) If a buffer needs to be flushed to disk, how do we let the FS flush
everything else that it is optimal to flush at the same time as that buffer. 
zam's allocate on flush code addresses that issue for reiserfs, and he has some
general hooks implemented also.  He is guessed to be two weeks away.

2) If multiple kernel subsystem page pinners pin memory, how do we keep them
from deadlocking.  Chris as you know is the reiserfs guy for that.

Hans
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
