Message-Id: <l03130308b7439bb9f187@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 6 Jun 2001 09:39:39 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > I'm resending the reapswap patch for inclusion into -ac series.
>>
>> Isn't it broken in this state?  Checking page_count, page->buffers and
>> PageSwapCache without the appropriate locks is dangerous.
>
>We hold the pagemap_lru_lock, so there will be no one doing lookups on
>this swap page (get_swapcache_page() locks pagemap_lru_lock).
>
>Am I overlooking something here?

Probably a good idea to hold the individual page's lock anyway.

BTW, does this clear out an area of allocated swap which all processes have
finished using?  For example, if a large process dies and leaves part of
itself in the swapcache, the swap space covered by this is currently not
retrieved until the swapcache is given enough pressure.  I *think* this is
what you're trying to address here, just want to be sure.

This is particularly relevant because I now have code which gives "new"
pages a low initial age, but swapped-in pages get a high initial age.
Since the dead process's swapcache pages have likely been swapped in
shortly before it's demise, they get very high ages and a new process
replacing the old one has an uphill struggle to force out the old pagecache
entries.  This hurts the MySQL compilation a lot with 32Mb or 48Mb physical
- but even without the "high age on swapin" patch, it must surely hurt
performance (albeit to a lesser degree).

*** UPDATE *** : I applied the patch, and it really does help.  Compile
time for MySQL is down to ~6m30s from ~8m30s with 48Mb physical, and the
behaviour after the monster file is finished is much improved.  For
reference, the MySQL compile takes ~5min on this box with all 256Mb
available.  It's a 1GHz Athlon.

>I've been saying for sometime now that I think only kswapd should do
>the page aging part. If we don't do it this way, heavy VM loads will make
>each memory intensive task age down other processes pages, so we see
>ourselves in a "unmapping/faulting" storm. Imagine what happens to
>interactivity in such a case.

Interesting observation.  Something else though, which kswapd is guilty of
as well: consider a page shared among many processes, eg. part of a
library.  As kswapd scans, the page is aged down for each process that uses
it.  So glibc gets aged down many times more quickly than a non-shared
page, precisely the opposite of what we really want to happen.  With
exponential-decay aging, and multiple processes doing the aging in this
manner, highly important things like glibc get muscled out in very short
order...

Maybe aging up/down needs to be done on a linear page scan, rather than a
per-process scan, and reserve the per-process scan for choosing process
pages to move into the swap arena.

Another point - when a page is earmarked for swapping out (allocated space,
moved into the swapcache area, etc) and is then re-referenced before it is
completely deallocated, it remains in the swapcache and is still allocated
in the swap region.  This seems backwards to me, and appears to be the
reason why "cache bloat" is visible on 2.4.5 systems - it isn't really
cache, but pages which are used by processes yet are still given space they
don't need, on disk.  It also neatly explains the large swap usage of 2.4
systems in general.  I fiddled temporarily with attempting to fix this, but
I couldn't figure out the correct way to deallocate a page from swap and
move it out of swapcache.

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
