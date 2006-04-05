Date: Wed, 5 Apr 2006 10:43:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Lhms-devel] [RFC 0/6] Swapless Page Migration V1: Overview
In-Reply-To: <1144256328.5203.36.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0604051032130.1768@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
  <1144248362.5203.22.camel@localhost.localdomain>
 <Pine.LNX.4.64.0604050925110.1387@schroedinger.engr.sgi.com>
 <1144256328.5203.36.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Apr 2006, Lee Schermerhorn wrote:

> > We never allow a faulting in of the new page before migration is 
> > complete. The replacing of the swap ptes with real ptes was always done 
> > after migration was complete. Same thing here.
> 
> Unless we're talking about different things [happens], my migrate-on-
> fault patches do this.  Pages are unmapped from ptes and left hanging in
> the cache until some task touches them.  Then the migration occurs, if

Well you can only umap file backed pages. These are still working the same 
way. Anonymous pages can only be remapped in a different way not unmapped.
"unmap" of anonymous pages in todays kernels really means remap to swap 
space.

If you put the anonymous pages on swap then you can still have the old 
behavior but then you would require swap space.

> In any case, I don't think we want to be walking reverse maps and other
> task's pte's in one task's page fault path.  Perhaps "migrate-on-fault"
> and "auto-migration" are not going to go anywhere, but if they do, we'll
> need something like the existing swap/migration cache behavior, where
> the temporary ptes reference a single [reference counted] cache entry
> that points at either the old or new page.

No we certainly do not want to walk reverse maps in critical sections of 
the code.

I think the opportunistic lazy migration that we were talking about before 
would be fine with this scheme. You just check the refcount during the 
fault and then migrate the page if this would establish the first 
mapcount.

Pushing pages into the migration cache from the scheduler in order to 
migrate them later when references are to be reestablished will no longer 
work.
 
Would not swap be a more appropriate mechanism there? I mean the 
functionality that you want is almost exactly the same as swap. The 
checking of the mapcounts can then work the same way as opportunistic lazy 
migration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
