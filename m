Subject: Minor [?] page migration bug in check_pte_range()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Tue, 14 Aug 2007 11:25:48 -0400
Message-Id: <1187105148.6281.38.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I was testing memory policy and page migration with memtoy commands,
something like this:

	# create/map an 8 page anon segment
	anon a1 8p
	map a1
	# write to fault in new pages with default/local policy
	touch a1 w
	# on what node do the pages get allocated?
	where a1
	# attempt to install interleave policy and migrate pages
	mbind a1 interleave+move <node-list>
	# where <node-list> includes the node where the pages reside
	# what happened?
	where a1

What I see is that when you attempt to install an interleave policy and
migrate the pages to match that policy, any pages on nodes included in
the interleave node mask will not be migrated to match policy.  This
occurs because of the clever, but overly simplistic test in
check_pte_range():

	if (node_isset(nid, *nodes) == !!(flags & MPOL_MF_INVERT))
		continue;

Fixing this would, I think, involve checking each page against the
location dictated by the new policy.  Altho' I don't think this is a
performance critical path, it is the inner-most loop of check_range().

Is this worth addressing, do you think?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
