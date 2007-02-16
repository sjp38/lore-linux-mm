From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
Date: Fri, 16 Feb 2007 12:04:02 +0100
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0702160208530.21862@schroedinger.engr.sgi.com> <1171621056.24923.61.camel@twins>
In-Reply-To: <1171621056.24923.61.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200702161204.03271.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Martin Bligh <mbligh@mbligh.org>, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Friday, 16 February 2007 11:17, Peter Zijlstra wrote:
> On Fri, 2007-02-16 at 02:10 -0800, Christoph Lameter wrote:
> > On Fri, 16 Feb 2007, Peter Zijlstra wrote:
> > 
> > > On Thu, 2007-02-15 at 18:48 -0800, Andrew Morton wrote:
> > > 
> > > > The two swsusp bits can be removed: they're only needed at suspend/resume
> > > > time and can be replaced by an external data structure.
> > > 
> > > I once had a talk with Rafael, and he said it would be possible to rid
> > > us of PG_nosave* with the now not so new bitmap code that is used to
> > > handle swsusp of highmem pages.
> > 
> > Well we can just shift the stuff into the power subsystem I think. Like 
> > this? Compiles but not tested.
> 
> That would work, however as Andrew pointed out, this data is only ever
> used at suspend/resume time. I think we can postpone allocating this
> bitmap until then and free it afterwards.
> 
> However I'm quite out of my depths here, so I'll leave more constructive
> comments to Rafael.

The PageNosave bits may also used during the initialization.  On x86_64 the
arch code uses them to mark the pages that shouldn't be saved by swsusp.

However, the PageNosaveFree bits can be allocated during the suspend, as
they aren't needed before.

Thus what I'd like to do would be to use the Christoph's approach to allocate
the PageNosave bits on the architectures that need them (i386 doesn't, for
example) and handle the rest using memory bitmaps in snapshot.c.

Greetings,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
