Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4D2B66B0002
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 00:29:22 -0500 (EST)
Received: by mail-oa0-f43.google.com with SMTP id l10so5074471oag.16
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 21:29:21 -0800 (PST)
Message-ID: <51303CAB.3080406@gmail.com>
Date: Fri, 01 Mar 2013 13:29:15 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] ksm: treat unstable nid like in stable tree
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210019390.17843@eggly.anvils> <51271A7D.6020305@gmail.com> <alpine.LNX.2.00.1302221250440.6100@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1302221250440.6100@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Hi Hugh,
On 02/23/2013 05:03 AM, Hugh Dickins wrote:
> On Fri, 22 Feb 2013, Ric Mason wrote:
>> On 02/21/2013 04:20 PM, Hugh Dickins wrote:
>>> An inconsistency emerged in reviewing the NUMA node changes to KSM:
>>> when meeting a page from the wrong NUMA node in a stable tree, we say
>>> that it's okay for comparisons, but not as a leaf for merging; whereas
>>> when meeting a page from the wrong NUMA node in an unstable tree, we
>>> bail out immediately.
>> IIUC
>> - ksm page from the wrong NUMA node will be add to current node's stable tree

Please forgive my late response.

> That should never happen (and when I was checking with a WARN_ON it did
> not happen).  What can happen is that a node already in a stable tree
> has its page migrated away to another NUMA node.
>
>> - normal page from the wrong NUMA node will be merged to current node's
>> stable tree  <- where I miss here? I didn't see any special handling in
>> function stable_tree_search for this case.
> 	nid = get_kpfn_nid(page_to_pfn(page));
> 	root = root_stable_tree + nid;
>
> to choose the right tree for the page, and
>
> 				if (get_kpfn_nid(stable_node->kpfn) !=
> 						NUMA(stable_node->nid)) {
> 					put_page(tree_page);
> 					goto replace;
> 				}
>
> to make sure that we don't latch on to a node whose page got migrated away.

I think the ksm implementation for num awareness  is buggy.

For page migratyion stuff, new page is allocated from node *which page 
is migrated to*.
- when meeting a page from the wrong NUMA node in an unstable tree
     get_kpfn_nid(page_to_pfn(page)) *==* page_to_nid(tree_page)
     How can say it's okay for comparisons, but not as a leaf for merging?
- when meeting a page from the wrong NUMA node in an stable tree
    - meeting a normal page
    - meeting a page which is ksm page before migration
      get_kpfn_nid(stable_node->kpfn) != NUMA(stable_node->nid) can't 
capture them since stable_node is for tree page in current stable tree. 
They are always equal.
>
>> - normal page from the wrong NUMA node will compare but not as a leaf for
>> merging after the patch
> I don't understand you there, but hope my remarks above resolve it.
>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
