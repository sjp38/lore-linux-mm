Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id C31DD6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 20:15:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5BF783EE0C0
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:15:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F83C45DE5D
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:15:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 25A1145DE5A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:15:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 11E26E38005
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:15:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BD67C1DB804D
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 09:15:47 +0900 (JST)
Message-ID: <4F98933F.6020300@jp.fujitsu.com>
Date: Thu, 26 Apr 2012 09:13:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/23] slab: provide kmalloc_no_account
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1335138820-26590-5-git-send-email-glommer@parallels.com> <4F975703.3080005@jp.fujitsu.com> <4F980A42.6040308@parallels.com>
In-Reply-To: <4F980A42.6040308@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

(2012/04/25 23:29), Glauber Costa wrote:

> On 04/24/2012 10:44 PM, KAMEZAWA Hiroyuki wrote:
>> (2012/04/23 8:53), Glauber Costa wrote:
>>
>>> Some allocations need to be accounted to the root memcg regardless
>>> of their context. One trivial example, is the allocations we do
>>> during the memcg slab cache creation themselves. Strictly speaking,
>>> they could go to the parent, but it is way easier to bill them to
>>> the root cgroup.
>>>
>>> Only generic kmalloc allocations are allowed to be bypassed.
>>>
>>> The function is not exported, because drivers code should always
>>> be accounted.
>>>
>>> This code is mosly written by Suleiman Souhlal.
>>>
>>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>>> CC: Christoph Lameter<cl@linux.com>
>>> CC: Pekka Enberg<penberg@cs.helsinki.fi>
>>> CC: Michal Hocko<mhocko@suse.cz>
>>> CC: Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>> CC: Johannes Weiner<hannes@cmpxchg.org>
>>> CC: Suleiman Souhlal<suleiman@google.com>
>>
>>
>> Seems reasonable.
>> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>>
>> Hmm...but can't we find the 'context' in automatic way ?
>>
> 
> Not that I can think of. Well, actually, not without adding some tests
> to the allocation path I'd rather not (like testing for the return
> address and then doing a table lookup, etc)
> 
> An option would be to store it in the task_struct. So we would allocate
> as following:
> 
> memcg_skip_account_start(p);
> do_a_bunch_of_allocations();
> memcg_skip_account_stop(p);
> 
> The problem with that, is that it is quite easy to abuse.
> but if we don't export that to modules, it would be acceptable.
> 
> Question is, given the fact that the number of kmalloc_no_account() is
> expected to be really small, is it worth it?
> 

ok, but.... There was an idea __GFP_NOACCOUNT, which is better ?
Are you afraid that__GFP_NOACCOUNT can be spread too much rather than kmalloc_no_account() ?


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
