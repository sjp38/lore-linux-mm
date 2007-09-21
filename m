Date: Fri, 21 Sep 2007 18:02:47 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFC][PATCH] page->mapping clarification [1/3] base functions
In-Reply-To: <20070921095054.6386bae1.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0709211716220.20783@blonde.wat.veritas.com>
References: <20070919164308.281f9960.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0709201120510.8801@schroedinger.engr.sgi.com>
 <20070921095054.6386bae1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, ricknu-0@student.ltu.se, Magnus Damm <magnus.damm@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007, KAMEZAWA Hiroyuki wrote:
> On Thu, 20 Sep 2007 11:26:47 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > I am still a bit confused as to what the benefit of this is.
> > 
> Honestly, I have 3 purposes, 2 for readability/clarificaton and 1 for my trial.
> 
> 1. Clarify page cache <-> inode relationship before *new concept of page cache*,
>    yours or someone else's is introduced.
> 
> 2. There are some places using PAGE_MAPPING_ANON directly. I don't want to see
>    following line in .c file. 
>    ==
>    anon_vma = (struct anon_vma *)(mapping - PAGE_MAPPING_ANON);
>    ==
> 
> 3. I want to *try* page->mapping overriding... store  memory resource controller's   
>    information in page->mapping. By this, memory controller doesn't enlarge sizeof
>    struct page. (works well in my small test.)
>    Before doing that, I have to hide page->mapping from direct access.

My own vote (nothing more) would be for you to set this aside until
some future time when there aren't a dozen developers all trampling
over each other in this area.

They're invasive little changes affecting all filesystems, whereas what
we've done so far with page->mapping hasn't affected filesystems at all.

Purposes 1 and 2 don't score very high in my book (though I too regret
how mm/migrate.c copied that PAGE_MAPPING_ANON stuff from it's rightful
home in mm/rmap.c: maybe we should wrap that).  There's no end to the
wrappers we can add, but they're not always helpful.

3: well, saving memory is good, but I think it could wait until some
other time, particularly since the memory controller isn't in yet.

Wouldn't it be easier to do something with page->lru than page->mapping?
Everybody is interested in page->mapping, not so many in page->lru.
(Though perhaps it wouldn't work out so well, since you don't need to
get uniquely from mapping to page, whereas you do from lru to page.)

If we were to attack page->mapping to save memory from struct page,
then we should consider Magnus Damm's idea too: he suggested it could
be replaced by a pointer to the radixtree slot (something else needed
in the anon case), from which "index" could be deduced via alignment
instead of keeping it in struct page (details to be filled in ...)

Of course, my particular prejudice is that I promised months ago to
free up the PG_swapcache bit by using a PAGE_MAPPING_SWAP bit instead.
That patch got buried while I tried to think up a suitable name for
a further page_mapping() variant that turned out to be needed - guess
I should look through your collection to see if I can steal one ;)
Beyond the unsatisfactory naming, that work has been long done
(and like PAGE_MAPPING_ANON, doesn't touch filesystems at all).

Or should I now leave PG_swapcache as is,
given your designs on page->mapping?

Hugh

p.s. Sorry to niggle, but next time, please say [PATCH 1/3] etc.
rather than [PATCH] Long Description [1/3], so it's easier to
sort the mail subjects by eye in limited columns - thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
