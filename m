Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: use-once & 'rescuing' pages from inactive-dirty
Date: Fri, 24 Aug 2001 02:03:18 +0200
References: <3B8543A6.1000904@ucla.edu>
In-Reply-To: <3B8543A6.1000904@ucla.edu>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20010823235653Z16346-32383+1063@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On August 23, 2001 07:55 pm, Benjamin Redelings I wrote:
> Hello Daniel and others,
> 	Firstly, I'd like to report that, with 2.4.9+SetPagReferenced+vma-merge, 
> I can actually run mozilla on a 64Mb box while 'find' is running, which 
> hasn't been true for a long time.  Previously, I could run netscape, 
> somewhat, but mozilla wants an RSS of 25-35Mb as opposed to 10-15Mb so 
> mozilla would just barely run.  I would get delays of minutes repainting 
> pages and stuff while find was running, though mozilla worked fine when 
> 'find' wasn't running.
> 	So, maybe the use-once patch is actually working now.

Yes, that's similar to my experience.

> 	Now, this did NOT work with 2.4.9, but it requited the SetPageReferenced 
> fix to work.  Daniel, you said that a SetPageReferenced, or something, 
> needed to be added to a few other paths, to 'rescue' other types of 
> pages before they got the end of the inactive-dirty list.
> 	a) if you make a patch, for these other places, I'd be glad to test it :)

Tomorrow.

> 	b) shouldn't the swap pages get referenced if they are used twice?  What 
> makes swap pages, mmap pages, etc. different from normal file pages, so 
> that they have to get 'rescued' with a SetPageReferenced?

Swap pages don't get explicitly touched, they get touched by memory reference 
instructions that set the hardware referenced bit.  Unfortunately, we don't 
have any good way of finding that bit except by scanning all the process page 
tables.  It takes far to long to complete a complete scan cycle to be useful 
for this application.

I have thought about various hacks to get around this, for example, we could 
keep a ring buffer full of pointers to the pte's of recently created pages 
just for this purpose.  IMHO, this is too much mechanism for something that 
doesn't exhibit such a clearcut separation into "streaming" and "random" 
access patterns as file IO does.

If we could have reverse pte mapping (pte address(es) can be determined from 
struct page) then it gets easy.  Rik has produced a patch for this which is 
in the pre-pre-pre-alpha stage.  We'd have to fight this one by Linus, who is 
philosophically opposed (we do admittedly have a very clever scheme for 
getting by without them) but might be convinced by a patch that demonstrated 
clearcut benefits, and of course, stability.  There are other benefits to 
reverse maps as well: fairer aging (cache and swap both aged in the same way 
by the same code); better performance with sparsely populated mmaps (because 
we don't waste time checking pte's that aren't mapped); and possibly reduced 
L1 cache pressure (because we touch less memory in the vmscan).  FreeBSD uses 
rmaps, although IMHO, Rik's design is nicer because it costs just 4 bytes per 
struct page vs an additional 28 bytes per mapped page in the BSD design.  If 
you need any more cheerleading for the concept, ask Rik ;-)

If there turns out to be a good reason why rmaps are bad - I don't see one 
personally - then I could look at some uglier hack for doing use-once on swap 
pages, or just leave it as it is.

> Does the 
> fact that swap pages need to be rescued imply that the inactive-dirty 
> list really isn't long enough for use-once, in practice?  Does the 
> performance increase perhaps come from having swapped-in pages have a 
> higher PAGE_AGE_START (in a sense) than file pages?

It's much simpler than that.  The use-once strategy starts all pages on the 
inactive list instead of the active list, introducing the requirement that 
pages be rescued soon after being first created.  Setting the Referenced bit 
carries out the rescue.

It would be nice if there was an easy way to specify whether a page should 
start on active or inactive but the page cache just isn't factored that way.  
Besides, there are other subtle benefits to starting the page on the inactive 
list: an initial burst of references on the page is treated as one reference 
for aging purposes, and any readahead page that isn't actually used will be 
dropped early.  For swap the latter may be a real help since we do tend to 
agressively read in large chunks of swap just because it's cheap to do so.  
So reading one byte from the middle of a large, swapped out array might read 
the whole thing in.  If we do not proceed to access the other pages of the 
array within a second or so then they will be dropped because they were never 
mapped into pte's, and so never SetReferenced.  With a monster like Mozilla, 
this can't help but relieve memory pressure.

> Because that would 
> give preference to 'mozilla' pages over 'find' pages, and explain why I 
> can run mozilla...
> 	Anyway, just wondering.  Thanks!

Actually, I'd never tested it with find and this is a very useful report.  
Find touches only metadata, i.e., directories.  In the case of ext2, that now 
means mostly page cache pages because of Al's dir-in-pcache patch.  The 
second time a directory page is looked up in the page cache its Referenced 
bit will be set, which gives something quite similar to the file IO use-once 
behaviour.  Other file systems, using buffers for directories, will set the 
Referenced bit on the first access to each diretory block (touch_buffer) 
which is also fine, it is neither better nor worse than what we had before.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
