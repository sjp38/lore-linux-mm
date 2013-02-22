Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id DA8736B0002
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 16:04:31 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kp14so677449pab.19
        for <linux-mm@kvack.org>; Fri, 22 Feb 2013 13:04:31 -0800 (PST)
Date: Fri, 22 Feb 2013 13:03:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/7] ksm: treat unstable nid like in stable tree
In-Reply-To: <51271A7D.6020305@gmail.com>
Message-ID: <alpine.LNX.2.00.1302221250440.6100@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210019390.17843@eggly.anvils> <51271A7D.6020305@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 22 Feb 2013, Ric Mason wrote:
> On 02/21/2013 04:20 PM, Hugh Dickins wrote:
> > An inconsistency emerged in reviewing the NUMA node changes to KSM:
> > when meeting a page from the wrong NUMA node in a stable tree, we say
> > that it's okay for comparisons, but not as a leaf for merging; whereas
> > when meeting a page from the wrong NUMA node in an unstable tree, we
> > bail out immediately.
> 
> IIUC
> - ksm page from the wrong NUMA node will be add to current node's stable tree

That should never happen (and when I was checking with a WARN_ON it did
not happen).  What can happen is that a node already in a stable tree
has its page migrated away to another NUMA node.

> - normal page from the wrong NUMA node will be merged to current node's
> stable tree  <- where I miss here? I didn't see any special handling in
> function stable_tree_search for this case.

	nid = get_kpfn_nid(page_to_pfn(page));
	root = root_stable_tree + nid;

to choose the right tree for the page, and

				if (get_kpfn_nid(stable_node->kpfn) !=
						NUMA(stable_node->nid)) {
					put_page(tree_page);
					goto replace;
				}

to make sure that we don't latch on to a node whose page got migrated away.

> - normal page from the wrong NUMA node will compare but not as a leaf for
> merging after the patch

I don't understand you there, but hope my remarks above resolve it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
