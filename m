Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA15830
	for <linux-mm@kvack.org>; Mon, 23 Nov 1998 16:27:51 -0500
Date: Mon, 23 Nov 1998 22:18:07 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Linux-2.1.129..
In-Reply-To: <m1n25idwfr.fsf@flinx.ccr.net>
Message-ID: <Pine.LNX.3.96.981123215719.6004B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>, "Dr. Werner Fink" <werner@suse.de>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 23 Nov 1998, Eric W. Biederman wrote:

> The simplest model (and what we use for disk writes) is after
> something becomes dirty to wait a little bit (in case of more
> writes, (so we don't flood the disk)) and write the data to disk. 

This waiting is also a good thing if we want to do proper
I/O clustering. I believe DU has a switch to only write
dirty data when there's more than XX kB of contiguous data
at that place on the disk (or the data is old).

> Ideally/Theoretically I think that is what we should be doing for
> swap as well, as it would spread out the swap writes across evenly
> across time.  And should leave most of our pages clean. 

Something like this is easily accomplished by pushing the
non-accessed pages into swap cache and swap simultaneously,
remapping the page from swap cache when we want to access
it again.

In order to spread out the disk I/O evenly (why would we
want to do this? -- writing is cheap once the disk head
is in the right place) we might want to implement a BSIisd
'laundry' list...

> But that is obviously going a little far for 2.2.  We already have
> our model of only try to clean pages when we need memory (ouch!) 

This really hurts and can be bad for application stability
when we're under a lot of pressure but there's still swap
space left.

> The correct ratio (of pages to free from each source) (compuated
> dynamically) would be:  (# of process pages)/(# of pages) 
> 
> Basically for every page kswapd frees shrink_mmap must also free one
> page.  Plus however many pages shrink_mmap used to return. 

This is clearly wrong. We can remap the page (soft fault)
from the swap cache, thereby removing the page from the
'inactive list' but not freeing the memory -- after all,
this hidden aging is the main purpose for this system...

I propose we maintain somewhat of a ratio of active/inactive
pages to keep around, so that all unmapped pages get a healthy
amount of aging and we always have enough memory we can easily
free by means of shrink_mmap().

This would give a kswapd() somewhat like the following:

if (nr_free_pages < free_pages_high && inactive_pages)
	shrink_mmap(GFP_SOMETHING);
if (inactive_pages * ratio < active_pages)
	do_try_to_swapout_pages(GFP_SOMETHING);

With things like shrink_dcache_memory(), shm_swap() and
kmem_cache_reap() folded in in the right places and
swap_tick() adjusted to take the active/inactive ratio
into account (get_free_page() too?).

A system like this would have much smoother swapout I/O,
giving higher possible loads on the VM system. Combined
with things like swapin readahead (Stephen, Ingo where
is it?:=) and 'real swapping' it will give a truly
scalable VM system...

Only for multi-gigabyte boxes we might want to bound
the number of inactive pages to (say) 16 MBs in order
to avoid a very large number of soft page faults that
use up too much CPU (Digital Unix seems to be slowed
down a lot by this -- it's using a 1:2 active/inactive
ratio even on our local 1GB box :)...

regards,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
