Date: Fri, 16 Mar 2007 00:28:37 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
Message-ID: <20070315232837.GH6687@v2.random>
References: <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <45F96CCB.4000709@redhat.com> <20070315162944.GI8321@wotan.suse.de> <Pine.LNX.4.64.0703151719380.32335@blonde.wat.veritas.com> <20070315225928.GF6687@v2.random> <1174000545.14380.22.camel@kleikamp.austin.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1174000545.14380.22.camel@kleikamp.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Chuck Ebbert <cebbert@redhat.com>, Ashif Harji <asharji@cs.uwaterloo.ca>, Miquel van Smoorenburg <miquels@cistron.nl>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 15, 2007 at 06:15:45PM -0500, Dave Kleikamp wrote:
> On Thu, 2007-03-15 at 23:59 +0100, Andrea Arcangeli wrote:
> > On Thu, Mar 15, 2007 at 05:44:01PM +0000, Hugh Dickins wrote:
> > > who removed the !offset condition, he should be consulted on its
> > > reintroduction.
> > 
> > the !offset check looks a pretty broken heuristic indeed, it would
> > break random I/O.
> 
> I wouldn't call it broken.  At worst, I'd say it's imperfect.  But
> that's the nature of a heuristic.  It most likely works in a huge
> majority of cases.

well, IMHO in the huge majority of cases the prev_page check isn't
necessary in the first place (and IMHO it hurts a lot more than it can
help, as demonstrated by specweb, since we'll bite on the good guys to
help the bad guys).

The only case where I can imagine the prev_page to make sense is to
handle contiguous I/O made with a small buffer, so clearly an
inefficient code in the first place. But if this guy is reading with
<PAGE_SIZE buffer there's no guarantee that he's reading f_pos aligned
either, hence the need of taking last_offset into account too so at
least it's a "perfect" heuristic that will reliably detect contiguous
I/O no matter in what shape or form you execute it, as long as it is
contiguous I/O.

Any other variation of behavior besides the autodetection of
contiguous I/O run in whatever buffer/aligned form, should be mandated
by userland through fadvise/madvise IMHO or we run into the toes of
the good guys.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
