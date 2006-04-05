Subject: Re: [Lhms-devel] [RFC 0/6] Swapless Page Migration V1: Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0604050925110.1387@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
	 <1144248362.5203.22.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604050925110.1387@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 05 Apr 2006 12:58:48 -0400
Message-Id: <1144256328.5203.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-04-05 at 09:28 -0700, Christoph Lameter wrote:
> On Wed, 5 Apr 2006, Lee Schermerhorn wrote:
> 
> > Does this approach still allow "migrate-on-fault" for anon pages?
> 
> I am not aware of something that would be in the way.
> 
> > Especially, in the case where the migrating page has >1 pte referencing
> > it?  How will the fault handler find all of the pte's referencing the
> > old page?  Actually, I don't think we'd want to burden the task whose
> 
> The fault handler can find these via the reverse maps.
> 
> > fault caused the migration with finding and replacing and replacing all
> > pte's referecing the old page.  Using a real cache, this isn't a problem
> > because we replace the old page with a new one in the cache, and the
> > cache ptes reference the cache entry.  Tasks are free to fault in a real
> > pte for the new page at any time.  I'd hate to lose this capability.  I
> > believe that this is one of the reasons that Marcello used a real idr-
> > based cache for the migration cache.
> 
> We never allow a faulting in of the new page before migration is 
> complete. The replacing of the swap ptes with real ptes was always done 
> after migration was complete. Same thing here.

Unless we're talking about different things [happens], my migrate-on-
fault patches do this.  Pages are unmapped from ptes and left hanging in
the cache until some task touches them.  Then the migration occurs, if
mapcount+policy so indicate, the new page replaces the old page in the
cache, the fault handler inserts a real pte referencing the new page and
removes one reference from the cache entry.  In the case of migration
cache, if this was the last pte reference, the entry is freed.  For the
swap cache, the page still references the swap entry and will until
explicitly removed.  If other task's ptes reference the cache entry, it
remains available, pointing at the new page, to resolve subsequent page
faults by those tasks.

Series starts with: 
http://marc.theaimsgroup.com/?l=linux-mm&m=114200021231527&w=4

I've been reworking these patches against your reorganized migration
code in 2.6.17-rc1.  I planned to resubmit after refreshing against 17-
rc1-mm1.  Unfortunately, 17-rc1-mm1 doesn't boot on my platform [sans
any of my patches], so now I'm investigating that...

In any case, I don't think we want to be walking reverse maps and other
task's pte's in one task's page fault path.  Perhaps "migrate-on-fault"
and "auto-migration" are not going to go anywhere, but if they do, we'll
need something like the existing swap/migration cache behavior, where
the temporary ptes reference a single [reference counted] cache entry
that points at either the old or new page.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
