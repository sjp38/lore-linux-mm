Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 4/4] IA64: SPARSE_VIRTUAL 16M page size support
Date: Thu, 5 Apr 2007 15:50:02 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A0153594A@scsmsx411.amr.corp.intel.com>
In-Reply-To: <20070404230635.20292.81141.sendpatchset@schroedinger.engr.sgi.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Dave Hansen <hansendc@us.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> This implements granule page sized vmemmap support for IA64.

Christoph,

Your calculations here are all based on a granule size of 16M, but
it is possible to configure 64M granules.

With current sizeof(struct page) == 56, a 16M page will hold enough
page structures for about 4.5G of physical space (assuming 16K pages),
so a 64M page would cover 18G.

4.5G is possibly a bit wasteful (for a system with only a handful
of GBytes per node, and nodes that are not physically contiguous).
18G is definitely going to result in lots of wasted page structs
(that refer to non-existant physical memory around the edges of
each node).

Maybe a granule is not the right unit of allocation ... perhaps 4M
would work better (4M/56 ~= 75000 pages ~= 1.1G)?  But if this is
too small, then a hard-coded 16M would be better than a granule,
because 64M is (IMHO) too big.

-Tony

P.S. This patch breaks the build for tiger_defconfig, zx1_defconfig
etc.  But you may have fit on the "grand-unified theory" of mem_map
management ... so if the benchmarks come in favourably we could
drop all the other CONFIG options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
