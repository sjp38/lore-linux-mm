From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Date: Wed, 8 Mar 2006 19:39:23 +1100
References: <200603081013.44678.kernel@kolivas.org> <200603081228.05820.kernel@kolivas.org> <200603080951.38316.jk-lkml@sci.fi>
In-Reply-To: <200603080951.38316.jk-lkml@sci.fi>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603081939.23791.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Knutar <jk-lkml@sci.fi>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Wednesday 08 March 2006 18:51, Jan Knutar wrote:
> On Wednesday 08 March 2006 03:28, Con Kolivas wrote:
> > Anything that does disk access delays prefetch fine. Things that only do
> > heavy cpu do not delay prefetch. Anything reading from disk will be
> > noticeable during 3d gaming.
>
> What exactly makes the disk accesses noticeable? Is it because they steal
> time from the disk that the game otherwise would need, or do the disk
> accesses themselves consume noticeable amounts of CPU time?
> Or, do bits of the game's executable drop from memory to make room for the
> new stuff being pulled in from memory, causing the game to halt while it
> waits for its pages to come back? On a related note, through advanced use
> of handwaving and guessing, this seems to be the thing that kills my destop
> experience (*buzzword alert*) most often. Checksumming a large file seems
> to be less of an impact than things that seek alot, like updatedb.
>
> I remember playing vegastrike on my linux desktop machine few years ago,
> the game leaked so much memory that it filled my 2G swap rather often,
> unleashing OOM killer mayhem. I "solved" this by putting swap on floppy at
> lower priority than the 2G, and a 128M swap file as "backup" at even lower
> priority than the floppy. I didn't notice the swapping to harddrive, but
> when it started to swap to floppy, it made the game run a bit slower for a
> few seconds, plus the floppy light went on, and I knew I had 128M left to 
> save my position and quit.
>
> If I needed floppy to make disk access noticeable on my very low end
> machine... What are these new fancy things doing to make HD access
> noticeable?

It's the cumulative effect of the cpu used by the in kernel code paths and the 
kprefetchd kernel thread. Even running ultra low priority, if they read a lot 
from the hard drive it costs us cpu time (seen as I/O wait in top for 
example). Swap prefetch _never_ displaces anything from ram; it only ever 
reads things from swap if there is generous free ram available. Not only that 
but if it reads something from swap it is put at the end of the "least 
recently used" list meaning that if _anything_ needs ram, these are the first 
things displaced again.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
