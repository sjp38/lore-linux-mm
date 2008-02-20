Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1K55RBD025283
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 16:05:27 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1K54c3p1290332
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 16:04:38 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1K54c2h025945
	for <linux-mm@kvack.org>; Wed, 20 Feb 2008 16:04:38 +1100
Message-ID: <47BBB3E8.1060206@linux.vnet.ibm.com>
Date: Wed, 20 Feb 2008 10:30:24 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, hugh@veritas.com, "riel@redhat.com" <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> I'd like to start from RFC.
> 
> In following code
> ==
>   lock_page_cgroup(page);
>   pc = page_get_page_cgroup(page);
>   unlock_page_cgroup(page);
> 
>   access 'pc' later..
> == (See, page_cgroup_move_lists())
> 

Hi, KAMEZAWA-San,

I assume that when you say page_cgroup_move_lists(), you mean
mem_cgroup_move_lists().

> There is a race because 'pc' is not a stable value without lock_page_cgroup().
> (mem_cgroup_uncharge can free this 'pc').
> 
> For example, page_cgroup_move_lists() access pc without lock.
> There is a small race window, between page_cgroup_move_lists()
> and mem_cgroup_uncharge(). At uncharge, page_cgroup struct is immedieately
> freed but move_list can access it after taking lru_lock.
> (*) mem_cgroup_uncharge_page() can be called without zone->lru lock.
> 
> This is not good manner.

Yes, correct. Thanks for catching this. I'll try and review all functions, to
see if there are other violations of correct locking.

> .....
> There is no quick fix (maybe). Moreover, I hear some people around me said
> current memcontrol.c codes are very complicated.
> I agree ;( ..it's caued by my work.
> 
> I'd like to fix problems in clean way.
> (Note: current -rc2 codes works well under heavy pressure. but there
>  is possibility of race, I think.)
> 

I am not looking at the patch below, since I saw that Hugh Dickins has also
posted his fixes and updates. We could review them and then see what else needs
to be done


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
