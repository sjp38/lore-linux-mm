Date: Thu, 4 May 2000 12:00:23 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <200005040042.RAA02046@pizda.ninka.net>
Message-ID: <Pine.LNX.4.21.0005041125050.664-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, quintela@fi.udc.es
List-ID: <linux-mm.kvack.org>

On Wed, 3 May 2000, David S. Miller wrote:

>   Date: 	Wed, 3 May 2000 18:26:19 +0200 (CEST)
>   From: Andrea Arcangeli <andrea@suse.de>
>
>	   ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.3/2.3.99-pre7-pre3/classzone-18.gz
>
>Btw, the path seem to be incorrect.  It should be:
>
>/pub/linux/kernel/people/andrea/patches/v2.3/2.3.99-pre7-pre3/classzone-18.gz
>
>:-)

Correct, I'm sorry for the mistake. All single patches are in the
andrea/patches directory indeed.

>One note after initial study.  I wish we could get rid of the
>"map_count" thing you added to the page struct.  Currently, when

I understand your point. My only problem is that if we'll drop the
map_count then I must be allowed to say "map_count = page_count(page) -
1". That's definitely not always true (just look the middle of
shrink_mmap).

Then all the places that does __find_lock_page are non trivial and they
should all be audited and they would break if somebody won't be carefuul
about the dependency on the map count and page count. Also the msync path
increases the page count for a very minor reason: only to have a common
exit path for the invalidate case. That trick is currently sane since the
page count can be increased at any time for any reason as far as memory
doesn't leak but such trick breaks the invariant I would need to enforce
in order to drop map_count.

So I need further information anyway (the PageOutLru bitflag wouldn't be
enough either) and so I thought I can as well grab an integer for its
dedicated purpose.

The above are the only reasons that made me to add the map_count. I
preferred to not break the current relaxed page->count semantic and to
allow everybody to grab as many times they want the page_count as now, and
the page count will remain relevant only to the freelist, and it have no
meaning respect to the number of ptes where the page is mapped to.

Basically using page_count(page) for the map count seems a pain and
something we don't want to do as far I can see.

If you have clever idea on how to get rid of the map_count they will be
very appreciated indeed. Thanks.

>we turn off wait queue debugging, the page struct is an exact power
>of 2 on both 64-bit and 32-bit architectures.  With the map_count
>there now, it will not be an exact power of two in size on 32-bit
>machines :-(

I seen the problem with 32bit archs since the first place (and the problem
is not only alignment but memory waste in general) but my argument here is
that we'd better choose to drop page->virtual if HIGHMEM is disabled (that
field is very less useful than map_count when HIGHMEM is disabled and so
it should go away from the binary image first IMHO ;-). (and page->virtual
should be dropped unconditionally on 64bit archs... even when HIGHMEM is
enabled)

On 64bit archs the map_count doesn't waste memory anyway because it gets
packeted in the same word with the 32bit page->count (both count and
map_count are 32bits wide) while the page->virtual instead waste lots of
memory even now on 64bit archs.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
