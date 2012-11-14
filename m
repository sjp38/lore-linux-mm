Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id DE4BA6B004D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 07:06:34 -0500 (EST)
Message-ID: <50A38936.2010406@parallels.com>
Date: Wed, 14 Nov 2012 16:06:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 28/29] slub: slub-specific propagation changes.
References: <1351771665-11076-1-git-send-email-glommer@parallels.com> <1351771665-11076-29-git-send-email-glommer@parallels.com> <509A83F8.6040402@oracle.com> <509B5673.8020801@parallels.com> <509C7A77.3020206@gmail.com>
In-Reply-To: <509C7A77.3020206@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>, Dave Jones <davej@redhat.com>

On 11/09/2012 07:37 AM, Sasha Levin wrote:
> On 11/08/2012 01:51 AM, Glauber Costa wrote:
>> On 11/07/2012 04:53 PM, Sasha Levin wrote:
>>> On 11/01/2012 08:07 AM, Glauber Costa wrote:
>>>> SLUB allows us to tune a particular cache behavior with sysfs-based
>>>> tunables.  When creating a new memcg cache copy, we'd like to preserve
>>>> any tunables the parent cache already had.
>>>>
>>>> This can be done by tapping into the store attribute function provided
>>>> by the allocator. We of course don't need to mess with read-only
>>>> fields. Since the attributes can have multiple types and are stored
>>>> internally by sysfs, the best strategy is to issue a ->show() in the
>>>> root cache, and then ->store() in the memcg cache.
>>>>
>>>> The drawback of that, is that sysfs can allocate up to a page in
>>>> buffering for show(), that we are likely not to need, but also can't
>>>> guarantee. To avoid always allocating a page for that, we can update the
>>>> caches at store time with the maximum attribute size ever stored to the
>>>> root cache. We will then get a buffer big enough to hold it. The
>>>> corolary to this, is that if no stores happened, nothing will be
>>>> propagated.
>>>>
>>>> It can also happen that a root cache has its tunables updated during
>>>> normal system operation. In this case, we will propagate the change to
>>>> all caches that are already active.
>>>>
>>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>>> CC: Christoph Lameter <cl@linux.com>
>>>> CC: Pekka Enberg <penberg@cs.helsinki.fi>
>>>> CC: Michal Hocko <mhocko@suse.cz>
>>>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>>> CC: Johannes Weiner <hannes@cmpxchg.org>
>>>> CC: Suleiman Souhlal <suleiman@google.com>
>>>> CC: Tejun Heo <tj@kernel.org>
>>>> ---
>>>
>>> Hi guys,
>>>
>>> This patch is making lockdep angry! *bark bark*
>>>
>>> [  351.935003] ======================================================
>>> [  351.937693] [ INFO: possible circular locking dependency detected ]
>>> [  351.939720] 3.7.0-rc4-next-20121106-sasha-00008-g353b62f #117 Tainted: G        W
>>> [  351.942444] -------------------------------------------------------
>>> [  351.943528] trinity-child13/6961 is trying to acquire lock:
>>> [  351.943528]  (s_active#43){++++.+}, at: [<ffffffff812f9e11>] sysfs_addrm_finish+0x31/0x60
>>> [  351.943528]
>>> [  351.943528] but task is already holding lock:
>>> [  351.943528]  (slab_mutex){+.+.+.}, at: [<ffffffff81228a42>] kmem_cache_destroy+0x22/0xe0
>>> [  351.943528]
>>> [  351.943528] which lock already depends on the new lock.
>>> [  351.943528]
>>> [  351.943528]
>>> [  351.943528] the existing dependency chain (in reverse order) is:
>>> [  351.943528]
>>> -> #1 (slab_mutex){+.+.+.}:
>>> [  351.960334]        [<ffffffff8118536a>] lock_acquire+0x1aa/0x240
>>> [  351.960334]        [<ffffffff83a944d9>] __mutex_lock_common+0x59/0x5a0
>>> [  351.960334]        [<ffffffff83a94a5f>] mutex_lock_nested+0x3f/0x50
>>> [  351.960334]        [<ffffffff81256a6e>] slab_attr_store+0xde/0x110
>>> [  351.960334]        [<ffffffff812f820a>] sysfs_write_file+0xfa/0x150
>>> [  351.960334]        [<ffffffff8127a220>] vfs_write+0xb0/0x180
>>> [  351.960334]        [<ffffffff8127a540>] sys_pwrite64+0x60/0xb0
>>> [  351.960334]        [<ffffffff83a99298>] tracesys+0xe1/0xe6
>>> [  351.960334]
>>> -> #0 (s_active#43){++++.+}:
>>> [  351.960334]        [<ffffffff811825af>] __lock_acquire+0x14df/0x1ca0
>>> [  351.960334]        [<ffffffff8118536a>] lock_acquire+0x1aa/0x240
>>> [  351.960334]        [<ffffffff812f9272>] sysfs_deactivate+0x122/0x1a0
>>> [  351.960334]        [<ffffffff812f9e11>] sysfs_addrm_finish+0x31/0x60
>>> [  351.960334]        [<ffffffff812fa369>] sysfs_remove_dir+0x89/0xd0
>>> [  351.960334]        [<ffffffff819e1d96>] kobject_del+0x16/0x40
>>> [  351.960334]        [<ffffffff8125ed40>] __kmem_cache_shutdown+0x40/0x60
>>> [  351.960334]        [<ffffffff81228a60>] kmem_cache_destroy+0x40/0xe0
>>> [  351.960334]        [<ffffffff82b21058>] mon_text_release+0x78/0xe0
>>> [  351.960334]        [<ffffffff8127b3b2>] __fput+0x122/0x2d0
>>> [  351.960334]        [<ffffffff8127b569>] ____fput+0x9/0x10
>>> [  351.960334]        [<ffffffff81131b4e>] task_work_run+0xbe/0x100
>>> [  351.960334]        [<ffffffff81110742>] do_exit+0x432/0xbd0
>>> [  351.960334]        [<ffffffff81110fa4>] do_group_exit+0x84/0xd0
>>> [  351.960334]        [<ffffffff8112431d>] get_signal_to_deliver+0x81d/0x930
>>> [  351.960334]        [<ffffffff8106d5aa>] do_signal+0x3a/0x950
>>> [  351.960334]        [<ffffffff8106df1e>] do_notify_resume+0x3e/0x90
>>> [  351.960334]        [<ffffffff83a993aa>] int_signal+0x12/0x17
>>> [  351.960334]

First: Sorry I took so long, I had some problems in my way back from
Spain...

I just managed to reproduce it, by following the callchain. In summary:

1) when we store an attribute, we will call sysfs_get_active(), that
will hold the sd->dep_map lock, where 'sd' is the specific dirent.

2) ->store() is called with that held.

3) ->store() will hold the slab_mutex

4) While destroying the cache, with the slab_mutex held, we will
eventually get to kobject_put(), that deep down in the callchain will
resort to sysfs_addrm_finish, that can hold that lock again.

In summary, creating a kmem limited memcg, storing an argument in the
global cache, and then deleting the memcg should trigger this. The funny
thing is that I had a test exactly like this in which it didn't trigger,
and now I know why: I was storing attributes for "dentry", which can
stay around for longer until it completely runs out of objects, which
will depend on the vmscan shrinkers kicking in. storing to a more short
lived cache will easily trigger this - Thanks!

During __kmem_cache_create, we drop the slab_mutex around
sysfs_slab_add. Although the justification for that is a bit different,
I think this is generally sane and the same could be done here.

I will send a patch for this - and other issues - shortly.

Thanks again, Sasha.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
