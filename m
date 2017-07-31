Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5586B05D1
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 04:02:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a186so22504051wmh.9
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 01:02:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o80si63646wme.162.2017.07.31.01.02.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Jul 2017 01:02:24 -0700 (PDT)
Subject: Re: [PATCH v3] cpuset: fix a deadlock due to incomplete patching of
 cpusets_enabled()
References: <9e14ff85-1680-e76d-1b71-22301c16c286@suse.cz>
 <20170731040113.14197-1-dmitriyz@waymo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7e68a8ed-af45-e288-3461-f80ffaa542ae@suse.cz>
Date: Mon, 31 Jul 2017 10:02:20 +0200
MIME-Version: 1.0
In-Reply-To: <20170731040113.14197-1-dmitriyz@waymo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dima Zavin <dmitriyz@waymo.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Christopher Lameter <cl@linux.com>, Li Zefan <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Cliff Spradlin <cspradlin@waymo.com>

On 07/31/2017 06:01 AM, Dima Zavin wrote:
> In codepaths that use the begin/retry interface for reading
> mems_allowed_seq with irqs disabled, there exists a race condition that
> stalls the patch process after only modifying a subset of the
> static_branch call sites.
> 
> This problem manifested itself as a dead lock in the slub
> allocator, inside get_any_partial. The loop reads
> mems_allowed_seq value (via read_mems_allowed_begin),
> performs the defrag operation, and then verifies the consistency
> of mem_allowed via the read_mems_allowed_retry and the cookie
> returned by xxx_begin. The issue here is that both begin and retry
> first check if cpusets are enabled via cpusets_enabled() static branch.
> This branch can be rewritted dynamically (via cpuset_inc) if a new
> cpuset is created. The x86 jump label code fully synchronizes across
> all CPUs for every entry it rewrites. If it rewrites only one of the
> callsites (specifically the one in read_mems_allowed_retry) and then
> waits for the smp_call_function(do_sync_core) to complete while a CPU is
> inside the begin/retry section with IRQs off and the mems_allowed value
> is changed, we can hang. This is because begin() will always return 0
> (since it wasn't patched yet) while retry() will test the 0 against
> the actual value of the seq counter.
> 
> The fix is to use two different static keys: one for begin
> (pre_enable_key) and one for retry (enable_key). In cpuset_inc(), we
> first bump the pre_enable key to ensure that cpuset_mems_allowed_begin()
> always return a valid seqcount if are enabling cpusets. Similarly,
> when disabling cpusets via cpuset_dec(), we first ensure that callers
> of cpuset_mems_allowed_retry() will start ignoring the seqcount
> value before we let cpuset_mems_allowed_begin() return 0.
> 
> The relevant stack traces of the two stuck threads:
> 
>   CPU: 1 PID: 1415 Comm: mkdir Tainted: G L  4.9.36-00104-g540c51286237 #4
>   Hardware name: Default string Default string/Hardware, BIOS 4.29.1-20170526215256 05/26/2017
>   task: ffff8817f9c28000 task.stack: ffffc9000ffa4000
>   RIP: smp_call_function_many+0x1f9/0x260
>   Call Trace:
>     ? setup_data_read+0xa0/0xa0
>     ? ___slab_alloc+0x28b/0x5a0
>     smp_call_function+0x3b/0x70
>     ? setup_data_read+0xa0/0xa0
>     on_each_cpu+0x2f/0x90
>     ? ___slab_alloc+0x28a/0x5a0
>     ? ___slab_alloc+0x28b/0x5a0
>     text_poke_bp+0x87/0xd0
>     ? ___slab_alloc+0x28a/0x5a0
>     arch_jump_label_transform+0x93/0x100
>     __jump_label_update+0x77/0x90
>     jump_label_update+0xaa/0xc0
>     static_key_slow_inc+0x9e/0xb0
>     cpuset_css_online+0x70/0x2e0
>     online_css+0x2c/0xa0
>     cgroup_apply_control_enable+0x27f/0x3d0
>     cgroup_mkdir+0x2b7/0x420
>     kernfs_iop_mkdir+0x5a/0x80
>     vfs_mkdir+0xf6/0x1a0
>     SyS_mkdir+0xb7/0xe0
>     entry_SYSCALL_64_fastpath+0x18/0xad
> 
>   ...
> 
>   CPU: 2 PID: 1 Comm: init Tainted: G L  4.9.36-00104-g540c51286237 #4
>   Hardware name: Default string Default string/Hardware, BIOS 4.29.1-20170526215256 05/26/2017
>   task: ffff8818087c0000 task.stack: ffffc90000030000
>   RIP: int3+0x39/0x70
>   Call Trace:
>     <#DB> ? ___slab_alloc+0x28b/0x5a0
>     <EOE> ? copy_process.part.40+0xf7/0x1de0
>     ? __slab_alloc.isra.80+0x54/0x90
>     ? copy_process.part.40+0xf7/0x1de0
>     ? copy_process.part.40+0xf7/0x1de0
>     ? kmem_cache_alloc_node+0x8a/0x280
>     ? copy_process.part.40+0xf7/0x1de0
>     ? _do_fork+0xe7/0x6c0
>     ? _raw_spin_unlock_irq+0x2d/0x60
>     ? trace_hardirqs_on_caller+0x136/0x1d0
>     ? entry_SYSCALL_64_fastpath+0x5/0xad
>     ? do_syscall_64+0x27/0x350
>     ? SyS_clone+0x19/0x20
>     ? do_syscall_64+0x60/0x350
>     ? entry_SYSCALL64_slow_path+0x25/0x25
> 
> Reported-by: Cliff Spradlin <cspradlin@waymo.com>
> Signed-off-by: Dima Zavin <dmitriyz@waymo.com>

Looks good. Could you verify it fixes the issue, or was it too hard to
reproduce? Also is this a stable candidate patch, and can you identify
an exact commit hash it fixes?

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> 
> v3:
>  - Changed the implementation based on Peter Zijlstra's suggestion. Now
>    using two keys for begin/retry instead of hacking the state into the
>    cookie.
>  - Rebased and tested on top of v4.13-rc3.
> 
> v4:
>  - Moved the cached cpusets_enabled() state into the cookie, turned
>    the cookie into a struct and updated all the other call sites.
>  - Applied on top of v4.12 since one of the callers in page_alloc.c changed.
>    Still only tested on v4.9.36 and compile tested against v4.12.
> 
>  include/linux/cpuset.h | 19 +++++++++++++++++--
>  kernel/cgroup/cpuset.c |  1 +
>  2 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> index 119a3f9604b0..e5a684c04c70 100644
> --- a/include/linux/cpuset.h
> +++ b/include/linux/cpuset.h
> @@ -18,6 +18,19 @@
>  
>  #ifdef CONFIG_CPUSETS
>  
> +/*
> + * Static branch rewrites can happen in an arbitrary order for a given
> + * key. In code paths where we need to loop with read_mems_allowed_begin() and
> + * read_mems_allowed_retry() to get a consistent view of mems_allowed, we need
> + * to ensure that begin() always gets rewritten before retry() in the
> + * disabled -> enabled transition. If not, then if local irqs are disabled
> + * around the loop, we can deadlock since retry() would always be
> + * comparing the latest value of the mems_allowed seqcount against 0 as
> + * begin() still would see cpusets_enabled() as false. The enabled -> disabled
> + * transition should happen in reverse order for the same reasons (want to stop
> + * looking at real value of mems_allowed.sequence in retry() first).
> + */
> +extern struct static_key_false cpusets_pre_enable_key;
>  extern struct static_key_false cpusets_enabled_key;
>  static inline bool cpusets_enabled(void)
>  {
> @@ -32,12 +45,14 @@ static inline int nr_cpusets(void)
>  
>  static inline void cpuset_inc(void)
>  {
> +	static_branch_inc(&cpusets_pre_enable_key);
>  	static_branch_inc(&cpusets_enabled_key);
>  }
>  
>  static inline void cpuset_dec(void)
>  {
>  	static_branch_dec(&cpusets_enabled_key);
> +	static_branch_dec(&cpusets_pre_enable_key);
>  }
>  
>  extern int cpuset_init(void);
> @@ -115,7 +130,7 @@ extern void cpuset_print_current_mems_allowed(void);
>   */
>  static inline unsigned int read_mems_allowed_begin(void)
>  {
> -	if (!cpusets_enabled())
> +	if (!static_branch_unlikely(&cpusets_pre_enable_key))
>  		return 0;
>  
>  	return read_seqcount_begin(&current->mems_allowed_seq);
> @@ -129,7 +144,7 @@ static inline unsigned int read_mems_allowed_begin(void)
>   */
>  static inline bool read_mems_allowed_retry(unsigned int seq)
>  {
> -	if (!cpusets_enabled())
> +	if (!static_branch_unlikely(&cpusets_enabled_key))
>  		return false;
>  
>  	return read_seqcount_retry(&current->mems_allowed_seq, seq);
> diff --git a/kernel/cgroup/cpuset.c b/kernel/cgroup/cpuset.c
> index ca8376e5008c..8d5151688504 100644
> --- a/kernel/cgroup/cpuset.c
> +++ b/kernel/cgroup/cpuset.c
> @@ -63,6 +63,7 @@
>  #include <linux/cgroup.h>
>  #include <linux/wait.h>
>  
> +DEFINE_STATIC_KEY_FALSE(cpusets_pre_enable_key);
>  DEFINE_STATIC_KEY_FALSE(cpusets_enabled_key);
>  
>  /* See "Frequency meter" comments, below. */
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
