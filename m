Subject: Re: [Lhms-devel] [RFC 0/6] Swapless Page Migration V1: Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0604051032130.1768@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
	 <1144248362.5203.22.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604050925110.1387@schroedinger.engr.sgi.com>
	 <1144256328.5203.36.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604051032130.1768@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 05 Apr 2006 14:52:19 -0400
Message-Id: <1144263139.5203.59.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-04-05 at 10:43 -0700, Christoph Lameter wrote:
> On Wed, 5 Apr 2006, Lee Schermerhorn wrote:
> 
> > > We never allow a faulting in of the new page before migration is 
> > > complete. The replacing of the swap ptes with real ptes was always done 
> > > after migration was complete. Same thing here.
> > 
> > Unless we're talking about different things [happens], my migrate-on-
> > fault patches do this.  Pages are unmapped from ptes and left hanging in
> > the cache until some task touches them.  Then the migration occurs, if
> 
> Well you can only umap file backed pages. These are still working the same 
> way. Anonymous pages can only be remapped in a different way not unmapped.
> "unmap" of anonymous pages in todays kernels really means remap to swap 
> space.

My point exactly.  And to get them to migrate on fault [which I want to
do], I need to unmap them and leave them that way until some task
touches them.

> 
> 
> If you put the anonymous pages on swap then you can still have the old 
> behavior but then you would require swap space.

Or a migration cache that behaves like swap, but doesn't actually
reserve disk space.

Note:  my traces show that the current [2.6.17-rc1] migration mechanism
only uses one swap entry at a time, per running instance of migration.
So, I don't think there is a hurry to eliminate this usage for "direct
migration".  If we accept migrate on fault, then pages can lay around in
the swap cache for some time.  That would motivate us to investigate a
solution that doesn't reserve swap.  


> > In any case, I don't think we want to be walking reverse maps and other
> > task's pte's in one task's page fault path.  Perhaps "migrate-on-fault"
> > and "auto-migration" are not going to go anywhere, but if they do, we'll
> > need something like the existing swap/migration cache behavior, where
> > the temporary ptes reference a single [reference counted] cache entry
> > that points at either the old or new page.
> 
> No we certainly do not want to walk reverse maps in critical sections of 
> the code.
> 
> I think the opportunistic lazy migration that we were talking about before 
> would be fine with this scheme. You just check the refcount during the 
> fault and then migrate the page if this would establish the first 
> mapcount.

The pages must exist in a cache with mapcount==0 at fault time [swap or
migration cache for anon pages] for this to work, right?

> 
> Pushing pages into the migration cache from the scheduler in order to 
> migrate them later when references are to be reestablished will no longer 
> work.

:-(, I know...

>  
> Would not swap be a more appropriate mechanism there? I mean the 
> functionality that you want is almost exactly the same as swap. The 
> checking of the mapcounts can then work the same way as opportunistic lazy 
> migration.

Yes.  We've discussed this before.  Swap works just fine for this.  My
current migrate-on-fault and auto-migration series does not change this.
The issue that we still need to work out [assuming these patches go
forward] is whether it's perferable to let such pages hang around in the
swap cache tying up swap device space that they never intend to use, or
to implement a pseudo-swap device like the migration cache to hold the
pte entries of unmapped anon pages.  I put the migration cache work on
hold to work up the aforementioned patch series.  I could do this,
because it works with swap.  If you remove the use of swap in
try_to_unmap(), etc., my patches would either have to put it back or
ressurect the migration cache sooner than planned.  As it stands,
migrate-on-fault is a relatively small change to the in-kernel migration
mechanism.

Lee



  

 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
