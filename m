Date: Sun, 21 Mar 2004 22:49:58 -0500 (EST)
From: Rajesh Venkatasubramanian <vrajesh@umich.edu>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity
 fix
In-Reply-To: <20040322004652.GF3649@dualathlon.random>
Message-ID: <Pine.LNX.4.58.0403212241120.8267@rust.engin.umich.edu>
References: <Pine.LNX.4.44.0403150527400.28579-100000@localhost.localdomain>
 <Pine.GSO.4.58.0403211634350.10248@azure.engin.umich.edu>
 <20040322004652.GF3649@dualathlon.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: akpm@osdl.org, torvalds@osdl.org, hugh@veritas.com, mbligh@aracnet.com, riel@redhat.com, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> what about the cost of a tree rebalance, is that O(log(N)) like with the
> rbtrees?

Currently the tree is not balanced, so the tree can be totally skewed
in some corner cases. However, the maximum height of the tree can be
only 2 * BITS_PER_LONG.

Moreover, I have added an optimization to increase the maximum height
of the tree on demand. The tree height is controlled by keeping track
of the maximum file offset mapped. If the number of bits required to
represent the maximum file offset is B, then the height of the tree
can be only 2 * B. Note that currently B can only increase gradually,
it is not adjusted back to smaller value when vmas are removed from
the prio_tree. That's bit tricky to do.

There is a balanced version prio_tree proposed in the same McCreight's
paper. However, it is not interesting because it requires more memory
space in each vma and the balancing is too complex even though it is
O(log(N)). I tried to understand the gist of the balanced version,
but it was too hard to follow. So I left it in the middle. Even
McCreight claims that the balanced version is just an academic (not
too practical) excercise. If someone is really interested they can check
the paper. But, it is not too interesting. I doubt whether it will
improve the performance.

Thanks,
Rajesh



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
