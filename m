Date: Fri, 16 Mar 2007 00:15:27 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
Message-ID: <20070315231527.GG6687@v2.random>
References: <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <1173905741.8763.36.camel@kleikamp.austin.ibm.com> <20070314213317.GA22234@rhlx01.hs-esslingen.de> <1173910138.8763.45.camel@kleikamp.austin.ibm.com> <45F8A301.90301@cse.ohio-state.edu> <Pine.GSO.4.64.0703150045550.18191@cpu102.cs.uwaterloo.ca> <20070315110735.287c8a23.akpm@linux-foundation.org> <20070315214923.GE6687@v2.random> <20070315150601.682036cf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070315150601.682036cf.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ashif Harji <asharji@cs.uwaterloo.ca>, dingxn@cse.ohio-state.edu, shaggy@linux.vnet.ibm.com, andi@rhlx01.fht-esslingen.de, linux-mm@kvack.org, npiggin@suse.de, jack@suse.cz, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 03:06:01PM -0700, Andrew Morton wrote:
> On Thu, 15 Mar 2007 22:49:23 +0100
> Andrea Arcangeli <andrea@suse.de> wrote:
> 
> > On Thu, Mar 15, 2007 at 11:07:35AM -0800, Andrew Morton wrote:
> > > > On Thu, 15 Mar 2007 01:22:45 -0400 (EDT) Ashif Harji <asharji@cs.uwaterloo.ca> wrote:
> > > > I still think the simple fix of removing the 
> > > > condition is the best approach, but I'm certainly open to alternatives.
> > > 
> > > Yes, the problem of falsely activating pages when the file is read in small
> > > hunks is worse than the problem which your patch fixes.
> > 
> > Really? I would have expected all performance sensitive apps to read
> > in >=PAGE_SIZE chunks. And if they don't because they split their
> > dataset in blocks (like some database), it may not be so wrong to
> > activate those pages that have two "hot" blocks more aggressively than
> > those pages with a single hot block.
> 
> But the problem which is being fixed here is really obscure: an application
> repeatedly reading the first page and only the first page of a file, always
> via the same fd.
>
> I'd expect that the sub-page-size read scenarion happens heaps more often
> than that, especially when dealing with larger PAGE_SIZEs.

Whatever that app is doing, clearly we have to keep those 4k in cache!
Like obviously the specweb demonstrated that as long as you are
_repeating_ the same read, it's correct to activate the page even if
it was reading from the same page as before.

What is wrong is to activate the page more aggressively if it's
_different_ parts of the page that are being read in a contiguous
way. I thought that the whole point of the ra.prev_page was to detect
_contiguous_ (not random) I/O made with a small buffer, anything else
doesn't make much sense to me.

In short I think taking a ra.prev_offset into account as suggested by
Dave Kleikamp is the best, it may actually benefit the obscure app too ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
