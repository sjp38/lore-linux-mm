Date: Tue, 6 Jun 2000 20:06:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: journaling & VM  (was: Re: reiserfs being part of the kernel: it's
 not just the code)
In-Reply-To: <20000606205447.T23701@redhat.com>
Message-ID: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Jun 2000, Stephen C. Tweedie wrote:

> It wasn't a journaling API we were talking about for this.  The
> problem is much more central to the VM than that --- basically,
> the VM currently assumes that any existing page can be evicted
> from memory with very little extra work.  It just isn't prepared
> for the situation that you have with transactions,


> journaling itself, but the transactional requirements which are
> the problem --- basically the VM cannot do _anything_ about
> individual pages which are pinned by a transaction, but rather
> we need a way to trigger a filesystem flush, AND to prevent more
> dirtying of pages by the filesystem (these are two distinct
> problems), or we just lock up under load on lower memory boxes.

This is especially tricky in the case of a large mmap()ed
file. We'll have to restrict the maximum number of read-write
mapped pages from such a file in order to keep the system
stable...

(try mmap002 from quintela's MM test suite with a journaling
FS for a nice change...)

> A reservation API which lets all transactional filesystems
> reserve the right to dirty a certain number of pages in advance
> of actually needing them is really needed to avoid such lockups.  
> The reservation call can stall if the memory limit has been
> reached, providing flow control to the filesystem; and a
> notification list can start committing and flushing older
> transactions when that happens.

Indeed we need this. Since I seem to be coordinating the VM
changes at the moment anyway, I'd love to work together with
the journaling folks on solving this problem...

It will require some changes in the page fault path and some
other areas...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
