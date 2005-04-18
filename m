From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16996.6304.930404.72906@gargle.gargle.HOWL>
Date: Tue, 19 Apr 2005 00:29:20 +0400
Subject: Re: [PATCH]: VM 3/8 PG_skipped
In-Reply-To: <1113846712.10810.111.camel@localhost>
References: <16994.40579.617974.423522@gargle.gargle.HOWL>
	<Pine.LNX.4.61.0504181111390.8456@chimarrao.boston.redhat.com>
	<1113846712.10810.111.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen writes:
 > On Mon, 2005-04-18 at 11:12 -0400, Rik van Riel wrote:
 > > On Sun, 17 Apr 2005, Nikita Danilov wrote:
 > > 
 > > > Don't call ->writepage from VM scanner when page is met for the first time
 > > > during scan.
 > > 
 > > > Reason behind this is that ->writepages() will perform more efficient 
 > > > writeout than ->writepage(). Skipping of page can be conditioned on 
 > > > zone->pressure.
 > > 
 > > Agreed, in order to write out blocks of pages at once from
 > > the pageout code, we'll need to wait with writing until the
 > > dirty bit has been propagated from the ptes to the pages.
 > 
 > Is there a way to do this without consuming a page->flags bit?  We're
 > starting to run really low on them.

Cannot think of one immediately. (Not counting that last fad of using
least significant bit of pointer to store something: page->mapping,
page->lru.next, and page->lru.prev, plus PAGE_CACHE_SHIFT bits in the
page->virtual :-)).

One possible route is to move flags that are used by file systems only
(PG_mappedtodisk, PG_error) into the per-mapping radix-tree.

Also, PG_skipped only makes sense for pages on inactive list, so we can
use some otherwise invalid combination (e.g., PageActive(pg) &&
!PageLRU(pg)), but this will complicate code that temporarily privatizes
pages from LRU.

 > 
 > -- Dave
 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
