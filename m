Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id E069F6B0005
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 20:28:37 -0500 (EST)
Received: by mail-oa0-f50.google.com with SMTP id l20so12017547oag.9
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 17:28:37 -0800 (PST)
Message-ID: <51369BB9.6030608@gmail.com>
Date: Wed, 06 Mar 2013 09:28:25 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] ksm: treat unstable nid like in stable tree
References: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils> <alpine.LNX.2.00.1302210019390.17843@eggly.anvils> <51271A7D.6020305@gmail.com> <alpine.LNX.2.00.1302221250440.6100@eggly.anvils> <51303CAB.3080406@gmail.com> <alpine.LNX.2.00.1303011139270.7398@eggly.anvils> <51315174.4020200@gmail.com> <alpine.LNX.2.00.1303011833490.23290@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1303011833490.23290@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Ric Mason <ric.masonn@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,
On 03/02/2013 10:57 AM, Hugh Dickins wrote:

How ksm treat a ksm forked page? IIUC, it's not merged in ksm stable 
tree. It will just be ignore?

> On Sat, 2 Mar 2013, Ric Mason wrote:
>> On 03/02/2013 04:03 AM, Hugh Dickins wrote:
>>> On Fri, 1 Mar 2013, Ric Mason wrote:
>>>> I think the ksm implementation for num awareness  is buggy.
>>> Sorry, I just don't understand your comments below,
>>> but will try to answer or question them as best I can.
>>>
>>>> For page migratyion stuff, new page is allocated from node *which page is
>>>> migrated to*.
>>> Yes, by definition.
>>>
>>>> - when meeting a page from the wrong NUMA node in an unstable tree
>>>>       get_kpfn_nid(page_to_pfn(page)) *==* page_to_nid(tree_page)
>>> I thought you were writing of the wrong NUMA node case,
>>> but now you emphasize "*==*", which means the right NUMA node.
>> Yes, I mean the wrong NUMA node. During page migration, new page has already
>> been allocated in new node and old page maybe freed.  So tree_page is the
>> page in new node's unstable tree, page is also new node page, so
>> get_kpfn_nid(page_to_pfn(page)) *==* page_to_nid(tree_page).
> I don't understand; but here you seem to be describing a case where two
> pages from the same NUMA node get merged (after both have been migrated
> from another NUMA node?), and there's nothing wrong with that,
> so I won't worry about it further.
>
>>>>      - meeting a page which is ksm page before migration
>>>>        get_kpfn_nid(stable_node->kpfn) != NUMA(stable_node->nid) can't
>>>> capture
>>>> them since stable_node is for tree page in current stable tree. They are
>>>> always equal.
>>> When we meet a ksm page in the stable tree before it's migrated to another
>>> NUMA node, yes, it will be on the right NUMA node (because we were careful
>>> only to merge pages from the right NUMA node there), and that test will not
>>> capture them.  It's for capturng a ksm page in the stable tree after it has
>>> been migrated to another NUMA node.
>> ksm page migrated to another NUMA node still not freed, why? Who take page
>> count of it?
> The old page, the one which used to be a ksm page on the old NUMA node,
> should be freed very soon: since it was isolated from lru, and its page
> count checked, I cannot think of anything to hold a reference to it,
> apart from migration itself - so it just needs to reach putback_lru_page(),
> and then may rest awhile on __lru_cache_add()'s pagevec before being freed.
>
> But I don't see where I said the old page was still not freed.
>
>> If not  freed, since new page is allocated in new node, it is
>> the copy of current ksm page, so current ksm doesn't change,
>> get_kpfn_nid(stable_node->kpfn) *==* NUMA(stable_node->nid).
> But ksm_migrate_page() did
> 		VM_BUG_ON(stable_node->kpfn != page_to_pfn(oldpage));
> 		stable_node->kpfn = page_to_pfn(newpage);
> without changing stable_node->nid.
>
> Hugh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
