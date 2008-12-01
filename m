Subject: Re: [PATCH 6/8] mm: remove try_to_munlock from vmscan
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0811241928260.3700@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
	 <Pine.LNX.4.64.0811232202040.4142@blonde.site>
	 <1227548092.6937.23.camel@lts-notebook>
	 <Pine.LNX.4.64.0811241928260.3700@blonde.site>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 15:16:54 -0500
Message-Id: <1228162614.18834.92.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-11-24 at 19:29 +0000, Hugh Dickins wrote:
> On Mon, 24 Nov 2008, Lee Schermerhorn wrote:
> > On Sun, 2008-11-23 at 22:03 +0000, Hugh Dickins wrote:
> > 
<snip>
> 
> > > 
> > > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> > > ---
> > > I've not tested this against whatever test showed the need for that
> > > try_to_munlock() in shrink_page_list() in the first place.  Rik or Lee,
> > > please, would you have the time to run that test on the next -mm that has
> > > this patch in, to check that I've not messed things up?  Alternatively,
> > > please point me to such a test - but I think you've been targeting
> > > larger machines than I have access to - thanks.
> > 
> > I will rerun my test workload when this shows up in mmotm.  
> 
> Great, thanks a lot.

Hugh:  I got a chance to start my test workload on 28-rc6-mmotm-081130
today [after finding the patch for the "BUG_ON(!dot)" boot-time panic].
I added a couple of temporary vmstat counters to count attempts to free
swap space in the vmscan "cull" path and successful frees, so I could
tell that we were exercising your changes.

Unfortunately, both my x86_64 and ia64 platforms eventually [after an
hour and a half or so] hit a null pointer deref [Nat consumption on
ia64] in __get_user_pages().  In both cases, __get_user_pages was called
while ps(1) was trying to read the task's command line via /proc.

The ia64 platform eventually locked up.  I rebooted the x86_64 and hit a
"kernel BUG at fs/dcache.c:666".  I don't know that these were related
to your changes, so I'll report them separately.

I did manage to grab some selected vmstats from the run on the x86_64,
after couple of hours of running [it stayed up longer than the ia64]:

egrep '^pgp|^pswp|^pgfau|^pgmaj|^unev|^swap_' /proc/vmstat
pgpgin 288501203
pgpgout 89224219
pswpin 1063928
pswpout 1637706
pgfault 1471335469
pgmajfault 517119
unevictable_pgs_culled 108794397
unevictable_pgs_scanned 28835840
unevictable_pgs_rescued 260444075
unevictable_pgs_mlocked 250282969
unevictable_pgs_munlocked 239272025
unevictable_pgs_cleared 6750236
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0
swap_try_free_mlocked_pgs 823799
swap_freed_mlocked_pgs 823799

the last two items are the temporary counters where we
try_to_free_swap() in the vmscan cull path.

I tested this by mmap()ing a largish [20G] anon segment, writing to each
page to populate it, then mlocking the segment.  Other tests kept the
system under memory pressure so that quite a few of the pages of the
anon segment got swapped out before I mlocked it.  The fact that I hit
these counters indicates that many of the mlocked pages were culled by
vmscan rather than by mlock itself--possibly because we recently removed
the lru_drain_all() from mlock, so we don't necessarily see all of the
pages on the lru on return from get_user_pages() in mlock.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
