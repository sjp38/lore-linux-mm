Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 6F5CB6B0006
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 00:05:48 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id j5so7127760iaf.28
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 21:05:47 -0800 (PST)
Date: Tue, 5 Mar 2013 21:05:10 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/7] ksm: treat unstable nid like in stable tree
In-Reply-To: <5136ABEE.8000501@gmail.com>
Message-ID: <alpine.LNX.2.00.1303052031320.29433@eggly.anvils>
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210019390.17843@eggly.anvils> <51271A7D.6020305@gmail.com> <alpine.LNX.2.00.1302221250440.6100@eggly.anvils> <51303CAB.3080406@gmail.com> <alpine.LNX.2.00.1303011139270.7398@eggly.anvils>
 <51315174.4020200@gmail.com> <alpine.LNX.2.00.1303011833490.23290@eggly.anvils> <5136ABEE.8000501@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 6 Mar 2013, Ric Mason wrote:
[ I've deleted the context because that was about the unstable tree,
  and here you have moved to asking about a case in the stable tree. ]
> 
> For the case of a ksm page is migrated to a different NUMA node and migrate
> its stable node to  the right tree and collide with an existing stable node.
> get_kpfn_nid(stable_node->kpfn) != NUMA(stable_node->nid) can capture nothing

That's not so: as I've pointed out before, ksm_migrate_page() updates
stable_node->kpfn for the new page on the new NUMA node; but it cannot
(get the right locking to) move the stable_node to its new tree at that time.

It's moved out once ksmd notices that it's in the wrong NUMA node tree -
perhaps when one its rmap_items reaches the head of cmp_and_merge_page(),
or perhaps here in stable_tree_search() when it matches another page
coming in to cmp_and_merge_page().

You may be concentrating on the case when that "another page" is a ksm
page migrated from a different NUMA node; and overlooking the case of
when the matching ksm page in this stable tree has itself been migrated.

> since stable_node is the node in the right stable tree, nothing happen to it
> before this check. Did you intend to check get_kpfn_nid(page_node->kpfn) !=
> NUMA(page_node->nid) ?

Certainly not: page_node is usually NULL.  But I could have checked
get_kpfn_nid(stable_node->kpfn) != nid: I was duplicating the test
from cmp_and_merge_page(), but here we do have local variable nid.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
