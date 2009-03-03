Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 92E5A6B0099
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 08:14:20 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n23DECTm002430
	for <linux-mm@kvack.org>; Tue, 3 Mar 2009 18:44:12 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n23DEKj82937050
	for <linux-mm@kvack.org>; Tue, 3 Mar 2009 18:44:20 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n23DEBvV027829
	for <linux-mm@kvack.org>; Wed, 4 Mar 2009 00:14:12 +1100
Date: Tue, 3 Mar 2009 18:44:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/4] Memory controller soft limit patches (v3)
Message-ID: <20090303131410.GT11421@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090302060519.GG11421@balbir.in.ibm.com> <20090302152128.e74f51ef.kamezawa.hiroyu@jp.fujitsu.com> <20090302063649.GJ11421@balbir.in.ibm.com> <20090302160602.521928a5.kamezawa.hiroyu@jp.fujitsu.com> <20090302124210.GK11421@balbir.in.ibm.com> <c31ccd23cb41f0f7594b3f56b20f0165.squirrel@webmail-b.css.fujitsu.com> <20090302174156.GM11421@balbir.in.ibm.com> <20090303085914.555089b1.kamezawa.hiroyu@jp.fujitsu.com> <20090303111244.GP11421@balbir.in.ibm.com> <52c02febf1e87a4f0a6e81124e00876a.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <52c02febf1e87a4f0a6e81124e00876a.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-03 20:50:56]:

> Balbir Singh wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-03
> > 08:59:14]:
> >> But, on NUMA, because memcg just checks "usage" and doesn't check
> >> "usage-per-node", there can be memory shortage and this kind of
> >> soft-limit
> >> sounds attractive for me.
> >>
> >
> >
> > Could you please elaborate further on this?
> >
> Try to explain by artificial example..
> .
> Assume a system with 4 nodes, and 1G of memory per node.
> ==
>      Node0 -- 1G
>      Node1 -- 1G
>      Node2 -- 1G
>      Node3 -- 1G
> ==
> And assume there are 3 memory cgroups of following hard-limit.
> ==
>     GroupA -- 1G
>     GroupB -- 0.6G
>     GroupC -- 0.6G
> ==
> If the machine is not-NUMA and 4G SMP, we expect 1.8G of free memory and
> we can assume "global memory shortage" is a rare event.
> 
> But on NUMA, memory usage can be following.
> ==
>      GroupA -- 950M of usage
>      GrouoB -- 550M of usage
>      GroupC -- 550M of usage
> and
>      Node0 -- usage=1G
>      Node1 -- usage=1G
>      Node2 -- usage=50M
>      Node2 -- Usage=0
> ==
> In this case, kswapd will work on Node0, and Node1.
> Softlimit will have chance to work. If the user declares GroupA's softlimit
> is 800M, GroupA will be victim in this case.
>

Yes, GroupA is the victim, but if GroupA has not allocated from a
particular node, we can ensure that we don't reclaim from that node
even while doing soft limit reclaim.
 
> But we have to admit this is hard-to-use scheduling paramter. Almost all
> administrator will not be able to set proper value.
> A useful case I can think of is creating some "victim" group and guard
> other groups from global memory reclaim. I think I need some study about
> how-to-use softlimit. But we'll need this kind of paramater,anyway and
> I don't have onjection to add this kind of scheduling parameter.
> But implementation should be simple at this stage and we should
> find best scheduling algorithm under use-case finally...
> 

Yes and it should be correct and reliable and not based on heuristics
that are hard to prove as correct or even acceptable. Let me work on
the comments so far and refresh the patches.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
