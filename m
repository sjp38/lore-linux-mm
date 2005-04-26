Subject: Re: [PATCH]: VM 8/8 shrink_list(): set PG_reclaimed
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <1114493245.25240.4.camel@npiggin-nld.site>
References: <16994.40728.397980.431164@gargle.gargle.HOWL>
	 <20050425212911.31cf6b43.akpm@osdl.org>
	 <1114493245.25240.4.camel@npiggin-nld.site>
Content-Type: text/plain
Date: Tue, 26 Apr 2005 15:48:19 +1000
Message-Id: <1114494499.25240.19.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nikita Danilov <nikita@clusterfs.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-26 at 15:27 +1000, Nick Piggin wrote:
> On Mon, 2005-04-25 at 21:29 -0700, Andrew Morton wrote:
> > Nikita Danilov <nikita@clusterfs.com> wrote:
> > >
> > > 
> > > set PG_reclaimed bit on pages that are under writeback when shrink_list()
> > > looks at them: these pages are at end of the inactive list, and it only makes
> > > sense to reclaim them as soon as possible when writeout finishes.
> > > 
> > 
> > Makes sense, I guess.  It would be nice to know how many pages actually get
> > this treatment, and under what situations.
> > 
> > To address the race which Nick identified I think we can do it this way?
> > 
> 
> I did the same patch a while back and I had a feeling this didn't work
> either. I can't immediately see a race...


Somewhere, a light-bulb flickers...

shrink_list():                | end_page_writeback():
------------------------------|---------------------------------------                              
if (PageWriteback(page)) {    |
  if (!PageReclaim(page)) {   |
                              | if (!TestClearPageReclaim(page)) {
    SetPageReclaim(page);     |
    if (!PageWriteback(page)) |
      ClearPageReclaim(page); |
                              |   if (!test_clear_page_writeback(page))
                              |     BUG();

          |
          |
          V
PageReclaim && !PageWriteback == BUG


And yes, IIRC I actually did hit this race when testing - probably this
*exact* code (granted it took a while :P)

-- 
SUSE Labs, Novell Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
