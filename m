Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 1A9666B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:31:15 -0400 (EDT)
Message-ID: <4F980A42.6040308@parallels.com>
Date: Wed, 25 Apr 2012 11:29:22 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/23] slab: provide kmalloc_no_account
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1335138820-26590-5-git-send-email-glommer@parallels.com> <4F975703.3080005@jp.fujitsu.com>
In-Reply-To: <4F975703.3080005@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 04/24/2012 10:44 PM, KAMEZAWA Hiroyuki wrote:
> (2012/04/23 8:53), Glauber Costa wrote:
> 
>> Some allocations need to be accounted to the root memcg regardless
>> of their context. One trivial example, is the allocations we do
>> during the memcg slab cache creation themselves. Strictly speaking,
>> they could go to the parent, but it is way easier to bill them to
>> the root cgroup.
>>
>> Only generic kmalloc allocations are allowed to be bypassed.
>>
>> The function is not exported, because drivers code should always
>> be accounted.
>>
>> This code is mosly written by Suleiman Souhlal.
>>
>> Signed-off-by: Glauber Costa<glommer@parallels.com>
>> CC: Christoph Lameter<cl@linux.com>
>> CC: Pekka Enberg<penberg@cs.helsinki.fi>
>> CC: Michal Hocko<mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner<hannes@cmpxchg.org>
>> CC: Suleiman Souhlal<suleiman@google.com>
> 
> 
> Seems reasonable.
> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> 
> Hmm...but can't we find the 'context' in automatic way ?
> 

Not that I can think of. Well, actually, not without adding some tests
to the allocation path I'd rather not (like testing for the return
address and then doing a table lookup, etc)

An option would be to store it in the task_struct. So we would allocate
as following:

memcg_skip_account_start(p);
do_a_bunch_of_allocations();
memcg_skip_account_stop(p);

The problem with that, is that it is quite easy to abuse.
but if we don't export that to modules, it would be acceptable.

Question is, given the fact that the number of kmalloc_no_account() is
expected to be really small, is it worth it?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
