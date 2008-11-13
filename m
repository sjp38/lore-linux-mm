Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAD0miXu030190
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:48:44 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAD0ndK9716810
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:49:39 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAD0nUwA032394
	for <linux-mm@kvack.org>; Thu, 13 Nov 2008 11:49:30 +1100
Message-ID: <491B7978.7010300@linux.vnet.ibm.com>
Date: Thu, 13 Nov 2008 06:18:56 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/6] memcg: free all at rmdir
References: <20081112122606.76051530.kamezawa.hiroyu@jp.fujitsu.com> <20081112122656.c6e56248.kamezawa.hiroyu@jp.fujitsu.com> <20081112160758.3dca0b22.akpm@linux-foundation.org> <491B7395.8040606@linux.vnet.ibm.com> <20081112164637.b6f3cb78.akpm@linux-foundation.org>
In-Reply-To: <20081112164637.b6f3cb78.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, menage@google.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 13 Nov 2008 05:53:49 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> Andrew Morton wrote:
>>> On Wed, 12 Nov 2008 12:26:56 +0900
>>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>>
>>>> +5.1 on_rmdir
>>>> +set behavior of memcg at rmdir (Removing cgroup) default is "drop".
>>>> +
>>>> +5.1.1 drop
>>>> +       #echo on_rmdir drop > memory.attribute
>>>> +       This is default. All pages on the memcg will be freed.
>>>> +       If pages are locked or too busy, they will be moved up to the parent.
>>>> +       Useful when you want to drop (large) page caches used in this memcg.
>>>> +       But some of in-use page cache can be dropped by this.
>>>> +
>>>> +5.1.2 keep
>>>> +       #echo on_rmdir keep > memory.attribute
>>>> +       All pages on the memcg will be moved to its parent.
>>>> +       Useful when you don't want to drop page caches used in this memcg.
>>>> +       You can keep page caches from some library or DB accessed by this
>>>> +       memcg on memory.
>>> Would it not be more useful to implement a per-memcg version of
>>> /proc/sys/vm/drop_caches?  (One without drop_caches' locking bug,
>>> hopefully).
>>>
>>> If we do this then we can make the above "keep" behaviour non-optional,
>>> and the operator gets to choose whether or not to drop the caches
>>> before doing the rmdir.
>>>
>>> Plus, we get a new per-memcg drop_caches capability.  And it's a nicer
>>> interface, and it doesn't have the obvious races which on_rmdir has,
>>> etc.
>>>
>> Andrew, I suspect that will not be easy, since we don't track address spaces
>> that belong to a particular memcg. If page cache ends up being shared across
>> memcg's, dropping them would impact both mem cgroups.
>>
> 
> walk the LRUs?

We do that for the force_empty() interface we have. Although we don't
differentiate between cache and RSS at the moment.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
