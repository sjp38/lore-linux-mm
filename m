Date: Wed, 7 Jun 2000 12:12:43 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607121243.F29432@redhat.com>
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva> <393DA31A.358AE46D@reiser.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <393DA31A.358AE46D@reiser.to>; from hans@reiser.to on Tue, Jun 06, 2000 at 06:19:22PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 06, 2000 at 06:19:22PM -0700, Hans Reiser wrote:
> 
> There are two issues to address:
> 
> 1) If a buffer needs to be flushed to disk, how do we let the FS flush
> everything else that it is optimal to flush at the same time as that buffer. 
> zam's allocate on flush code addresses that issue for reiserfs, and he has some
> general hooks implemented also.  He is guessed to be two weeks away.

That's easy to deal with using address_space callbacks from shrink_mmap.
shrink_mmap just calls into the filesystem to tell it that something
needs to be done.  The filesystem can, in response, flush as much data
as it wants to in addition to the page requested --- or can flush none
at all if the page is pinned.  The address_space callbacks should be
thought of as hints from the VM that the filesystem needs to do 
something.  shrink_mmap will keep on trying until it finds something
to free if nothing happens on the first call.

> 2) If multiple kernel subsystem page pinners pin memory, how do we keep them
> from deadlocking.  Chris as you know is the reiserfs guy for that.

Use reservations.  That's the point --- you reserve in advance, so that 
the VM can *guarantee* that you can continue to pin more pages up to
the maximum you have reserved.  You take a reservation before starting
a fs operation, so that if you need to block, it doesn't prevent the
running transaction from being committed.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
