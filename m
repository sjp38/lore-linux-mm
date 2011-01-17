Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AB2BC8D0039
	for <linux-mm@kvack.org>; Mon, 17 Jan 2011 14:14:13 -0500 (EST)
Date: Mon, 17 Jan 2011 20:14:00 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [LSF/MM TOPIC] memory control groups
Message-ID: <20110117191359.GI2212@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Michel Lespinasse <walken@google.com>
List-ID: <linux-mm.kvack.org>

Hello,

on the MM summit, I would like to talk about the current state of
memory control groups, the features and extensions that are currently
being developed for it, and what their status is.

I am especially interested in talking about the current runtime memory
overhead memcg comes with (1% of ram) and what we can do to shrink it.

In comparison to how efficiently struct page is packed, and given that
distro kernels come with memcg enabled per default, I think we should
put a bit more thought into how struct page_cgroup (which exists for
every page in the system as well) is organized.

I have a patch series that removes the page backpointer from struct
page_cgroup by storing a node ID (or section ID, depending on whether
sparsemem is configured) in the free bits of pc->flags.

I also plan on replacing the pc->mem_cgroup pointer with an ID
(KAMEZAWA-san has patches for that), and move it to pc->flags too.
Every flag not used means doubling the amount of possible control
groups, so I have patches that get rid of some flags currently
allocated, including PCG_CACHE, PCG_ACCT_LRU, and PCG_MIGRATION.

[ I meant to send those out much earlier already, but a bug in the
migration rework was not responding to my yelling 'Marco', and now my
changes collide horribly with THP, so it will take another rebase. ]

The per-memcg dirty accounting work e.g. allocates a bunch of new bits
in pc->flags and I'd like to hash out if this leaves enough room for
the structure packing I described, or whether we can come up with a
different way of tracking state.

Would other people be interested in discussing this?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
