Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 3EBFC6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 04:42:11 -0400 (EDT)
Message-ID: <515A9A0C.7030503@parallels.com>
Date: Tue, 2 Apr 2013 12:42:52 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: don't do cleanup manually if mem_cgroup_css_online()
 fails
References: <515A8A40.6020406@huawei.com> <515A90ED.7010208@huawei.com> <515A91B4.3090607@parallels.com> <515A9819.5090603@huawei.com>
In-Reply-To: <515A9819.5090603@huawei.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 04/02/2013 12:34 PM, Li Zefan wrote:
> On 2013/4/2 16:07, Glauber Costa wrote:
>> On 04/02/2013 12:03 PM, Li Zefan wrote:
>>> On 2013/4/2 15:35, Li Zefan wrote:
>>>> If memcg_init_kmem() returns -errno when a memcg is being created,
>>>> mem_cgroup_css_online() will decrement memcg and its parent's refcnt,
>>>
>>>> (but strangely there's no mem_cgroup_put() for mem_cgroup_get() called
>>>> in memcg_propagate_kmem()).
>>>
>>> The comment in memcg_propagate_kmem() suggests it knows mem_cgroup_css_free()
>>> will be called in failure, while mem_cgroup_css_online() doesn't know.
>>>
>> This is a bit suspicious. At first your analysis seems fair, but I've
>> extensively tested memcg teardown process with kmemcg (and even
>> uncovered some bugs at that), and it works when and how expected.
>>
> 
> Because this bug is in a failure path, and seems the only way to get into
> this path is -ENOMEM.
> 
Yes, but I tend to test that with manually introduced error codes.

For what is worth, I just did it. And indeed, by ignoring kmemcg
initialization and failing with ENOMEM here triggers a bug. Your patch
fixes it. I tested both failing all non-root, and letting the first
succeed and failing the second if the parent is use_hierarchy. Both
cases have a bug initially that you fix.

If that is allowed to proceed, kmemcg initialization and teardown works
as expected.

>> Also, note that this teardown code long predates kmemcg.
>>
> 
> Maybe this bug was introduced when ss->create() was changed to ss->css_alloc()
> and ss->css_online(), and before that change ss->destroy() won't be called
> if ss->create() failed.
> 
Yes, this is possible,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
