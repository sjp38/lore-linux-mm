Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E513C6B0034
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 21:05:38 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 23 Jul 2013 10:55:11 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 3DD6F3578052
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 11:05:30 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6N0o79H32243918
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 10:50:07 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6N15Sxh026961
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 11:05:29 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 05/10] mm, hugetlb: fix and clean-up node iteration code to alloc or free
In-Reply-To: <20130722162336.GJ24400@dhcp22.suse.cz>
References: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com> <1374482191-3500-6-git-send-email-iamjoonsoo.kim@lge.com> <20130722162336.GJ24400@dhcp22.suse.cz>
Date: Tue, 23 Jul 2013 06:35:15 +0530
Message-ID: <87r4eqm6gk.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

Michal Hocko <mhocko@suse.cz> writes:

> On Mon 22-07-13 17:36:26, Joonsoo Kim wrote:
>> Current node iteration code have a minor problem which do one more
>> node rotation if we can't succeed to allocate. For example,
>> if we start to allocate at node 0, we stop to iterate at node 0.
>> Then we start to allocate at node 1 for next allocation.
>> 
>> I introduce new macros "for_each_node_mask_to_[alloc|free]" and
>> fix and clean-up node iteration code to alloc or free.
>> This makes code more understandable.
>
> I don't know but it feels like you are trying to fix an awkward
> interface with another one. Why hstate_next_node_to_alloc cannot simply
> return MAX_NUMNODES once the loop is done and start from first_node next
> time it is called? We wouldn't have the bug you are mentioning and you
> do not need scary looking macros.
>

Even though the macros looks confusing, the changes do help rest of the
code. for ex: I liked how it made alloc simpler.

 +	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
 +		page = alloc_fresh_huge_page_node(h, node);

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
