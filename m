Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id A8C856B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 12:19:22 -0400 (EDT)
Message-ID: <4FC647FB.90202@parallels.com>
Date: Wed, 30 May 2012 20:16:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 16/28] memcg: kmem controller charge/uncharge infrastructure
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-17-git-send-email-glommer@parallels.com> <20120530130416.GD25094@somewhere.redhat.com> <4FC61B4E.2060206@parallels.com> <20120530133736.GF25094@somewhere.redhat.com> <4FC622B5.9080600@parallels.com> <20120530135319.GG25094@somewhere.redhat.com> <4FC626DA.3030408@parallels.com> <20120530153256.GA27008@somewhere.redhat.com>
In-Reply-To: <20120530153256.GA27008@somewhere.redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/30/2012 07:33 PM, Frederic Weisbecker wrote:
> On Wed, May 30, 2012 at 05:55:38PM +0400, Glauber Costa wrote:
>> On 05/30/2012 05:53 PM, Frederic Weisbecker wrote:
>>> On Wed, May 30, 2012 at 05:37:57PM +0400, Glauber Costa wrote:
>>>> On 05/30/2012 05:37 PM, Frederic Weisbecker wrote:
>>>>> Right. __mem_cgroup_get_kmem_cache() fetches the memcg of the owner
>>>>> and calls memcg_create_cache_enqueue() which does css_tryget(&memcg->css).
>>>>> After this tryget I think you're fine. And in-between you're safe against
>>>>> css_set removal due to rcu_read_lock().
>>>>>
>>>>> I'm less clear with __mem_cgroup_new_kmem_page() though...
>>>>
>>>> That one does not get memcg->css but it does call mem_cgroup_get(),
>>>> that does prevent against the memcg structure being freed, which I
>>>> believe to be good enough.
>>>
>>> What if the owner calls cgroup_exit() between mem_cgroup_from_task()
>>> and mem_cgroup_get()? The css_set which contains the memcg gets freed.
>>> Also the reference on the memcg doesn't even prevent the css_set to
>>> be removed, does it?
>> It doesn't, but we don't really care. The css can go away, if the
>> memcg structure stays.
>
> Ah right, the memcg itself is only freed at destroy time.
>
>> The caches will outlive the memcg anyway,
>> since it is possible that you delete it, with some caches still
>> holding objects that
>> are not freed (they will be marked as dead).
>
> I guess I need to look at how the destroy path is handled in your patchset
> then. Or how you ensure that __mem_cgroup_new_kmem_page() can't race against
> destroy.
Appreciate that, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
