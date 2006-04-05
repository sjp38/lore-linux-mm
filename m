Subject: Re: [Lhms-devel] [RFC 0/6] Swapless Page Migration V1: Overview
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 05 Apr 2006 10:46:02 -0400
Message-Id: <1144248362.5203.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-04-03 at 23:57 -0700, Christoph Lameter wrote:
> Swapless Page migration
> 
> Currently page migration is depending on the ability to assign swap entries
> to pages. This means that page migration will not work without swap although
> that swap space is never used.
> 
> This patchset removes that dependency by introducing a special type of
> swap entry that encodes a pfn number of the page being migrated. If that
> swap pte is encountered then do_swap_page() will simply wait for the page
> to become unlocked again (meaning page migration is complete) and then refetch
> the pte. The special type of swap entry is only in use while the page to be
> migrated is locked and therefore we can hopefully get away with just a few
> supporting functions.
> 
> To some extend this covers the same ground as Lee's and Marcelo's migration
> cache. However, I hope that this approach simplifies things without opening
> up any holes. Please check.
> 

Christoph:

Does this approach still allow "migrate-on-fault" for anon pages?
Especially, in the case where the migrating page has >1 pte referencing
it?  How will the fault handler find all of the pte's referencing the
old page?  Actually, I don't think we'd want to burden the task whose
fault caused the migration with finding and replacing and replacing all
pte's referecing the old page.  Using a real cache, this isn't a problem
because we replace the old page with a new one in the cache, and the
cache ptes reference the cache entry.  Tasks are free to fault in a real
pte for the new page at any time.  I'd hate to lose this capability.  I
believe that this is one of the reasons that Marcello used a real idr-
based cache for the migration cache.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
