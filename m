Date: Fri, 1 Aug 2008 10:06:23 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] Update Unevictable LRU and Mlocked Pages documentation
Message-ID: <20080801100623.4aae3e37@bree.surriel.com>
In-Reply-To: <489313AC.3080605@linux-foundation.org>
References: <1217452439.7676.26.camel@lts-notebook>
	<4891C8BC.1020509@linux-foundation.org>
	<1217515429.6507.7.camel@lts-notebook>
	<489313AC.3080605@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 01 Aug 2008 08:46:20 -0500
Christoph Lameter <cl@linux-foundation.org> wrote:

> Yes I know and I think the rationale is not convincing if the justification
> of the additional LRU is primarily for page migration.

Basically there are two alternatives:

1) treat unevictable pages just like we treat other pages in the
   system, which means we get to use the same code to manipulate
   them, the same code to isolate them (for migrate, etc), the
   same code to keep track of the statistics, etc...

2) treat unevictable pages differently (not put them on a list)
   and have special statistics code, special code to isolate
   them, special code to detect them, etc...

Because pretty much every time we move a page onto or off of the
unevictable list, we also touch the list_head in the page for 
other reasons (typically to add the page to or remove from a normal
LRU list), we thought it would make the most sense to go with the
approach that needs the least amount of special code for the
unevictable pages.

Besides, a locked page is locked - it should go through fewer
list manipulations than the normal file and anon pages ever will,
so if the list manipulation shows up as a bottleneck it will show
up as a bottleneck for the evictable pages first...

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
