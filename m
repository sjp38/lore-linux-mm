Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 87D346B0005
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 20:10:18 -0500 (EST)
Received: by mail-oa0-f45.google.com with SMTP id o6so6598810oag.4
        for <linux-mm@kvack.org>; Fri, 01 Mar 2013 17:10:17 -0800 (PST)
Message-ID: <51315174.4020200@gmail.com>
Date: Sat, 02 Mar 2013 09:10:12 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] ksm: treat unstable nid like in stable tree
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210019390.17843@eggly.anvils> <51271A7D.6020305@gmail.com> <alpine.LNX.2.00.1302221250440.6100@eggly.anvils> <51303CAB.3080406@gmail.com> <alpine.LNX.2.00.1303011139270.7398@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303011139270.7398@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Hi Hugh,
On 03/02/2013 04:03 AM, Hugh Dickins wrote:
> On Fri, 1 Mar 2013, Ric Mason wrote:
>> I think the ksm implementation for num awareness  is buggy.
> Sorry, I just don't understand your comments below,
> but will try to answer or question them as best I can.
>
>> For page migratyion stuff, new page is allocated from node *which page is
>> migrated to*.
> Yes, by definition.
>
>> - when meeting a page from the wrong NUMA node in an unstable tree
>>      get_kpfn_nid(page_to_pfn(page)) *==* page_to_nid(tree_page)
> I thought you were writing of the wrong NUMA node case,
> but now you emphasize "*==*", which means the right NUMA node.

Yes, I mean the wrong NUMA node. During page migration, new page has 
already been allocated in new node and old page maybe freed.  So 
tree_page is the page in new node's unstable tree, page is also new node 
page, so get_kpfn_nid(page_to_pfn(page)) *==* page_to_nid(tree_page).

>
>>      How can say it's okay for comparisons, but not as a leaf for merging?
> Pages in the unstable tree are unstable (and it's not even accurate to
> say "pages in the unstable tree"), they and their content can change at
> any moment, so I cannot assert anything of them for sure.
>
> But if we suppose, as an approximation, that they are somewhat likely
> to remain stable (and the unstable tree would be useless without that
> assumption: it tends to work out), but subject to migration, then it makes
> sense to compare content, no matter what NUMA node it is on, in order to
> locate a page of the same content; but wrong to merge with that page if
> it's on the wrong NUMA node, if !merge_across_nodes tells us not to.
>
>
>> - when meeting a page from the wrong NUMA node in an stable tree
>>     - meeting a normal page
> What does that line mean, and where does it fit in your argument?

I distinguish pages in three kinds.
- ksm page which already in stable tree in old node
- page in unstable tree in old node
- page not in any trees in old node

So normal page here I mean page not in any trees in old node.

>
>>     - meeting a page which is ksm page before migration
>>       get_kpfn_nid(stable_node->kpfn) != NUMA(stable_node->nid) can't capture
>> them since stable_node is for tree page in current stable tree. They are
>> always equal.
> When we meet a ksm page in the stable tree before it's migrated to another
> NUMA node, yes, it will be on the right NUMA node (because we were careful
> only to merge pages from the right NUMA node there), and that test will not
> capture them.  It's for capturng a ksm page in the stable tree after it has
> been migrated to another NUMA node.

ksm page migrated to another NUMA node still not freed, why? Who take 
page count of it? If not  freed, since new page is allocated in new 
node, it is the copy of current ksm page, so current ksm doesn't change, 
get_kpfn_nid(stable_node->kpfn) *==* NUMA(stable_node->nid).

>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
