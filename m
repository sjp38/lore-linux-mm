Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 745B36B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 03:21:48 -0400 (EDT)
Message-ID: <5153EFB3.5070002@parallels.com>
Date: Thu, 28 Mar 2013 11:22:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
References: <1364373399-17397-1-git-send-email-mhocko@suse.cz> <20130327161527.GA7395@htj.dyndns.org> <20130327161905.GN16579@dhcp22.suse.cz> <CAOS58YPsrZNU9qDeMgJG3-Hkn0cBaigz16eTS5M57G95E8fxUQ@mail.gmail.com> <20130327162707.GO16579@dhcp22.suse.cz>
In-Reply-To: <20130327162707.GO16579@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/27/2013 08:27 PM, Michal Hocko wrote:
> On Wed 27-03-13 09:21:02, Tejun Heo wrote:
>> On Wed, Mar 27, 2013 at 9:19 AM, Michal Hocko <mhocko@suse.cz> wrote:
>>>> Maybe the name could signify it's part of memcg?
>>>
>>> kmem_ prefix is used for all CONFIG_MEMCG_KMEM functions. I understand
>>> it clashes with sl?b naming but this is out of scope of this patch IMO.
>>
>> Oh, it's not using kmemcg? I see. Maybe we can rename later.
> 
> Some parts use memcg_kmem_* other kmem_. A cleanup would be nice.
> Glauber?
> 
I have been using kmem_ only in functions that will deal directly with
the slab caches and with the single purpose of operating them.

kmem_cache_destroy_work_func => worker interface to kmem_cache_destroy
kmem_cache_destroy_memcg_children => cache destructor iterator
kmem_cache_dup => interface to kmem_cache_create

All the other functions start with memcg_
Analogously, all slab-side functions that deal with memcg *ends* with
_memcg. except the functions that are only there to operate memcg data
structures:

memcg_update_all_caches.

In general, those functions could very well live in the other file (slab
or memcg), but they need to take locks or manipulate data structures
that are internal to slab/memcg.

I believe this is a sound convention.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
