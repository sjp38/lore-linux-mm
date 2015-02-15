Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8E9F16B00A8
	for <linux-mm@kvack.org>; Sat, 14 Feb 2015 22:55:33 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id nt9so32552558obb.3
        for <linux-mm@kvack.org>; Sat, 14 Feb 2015 19:55:33 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id rq3si993357oeb.51.2015.02.14.19.55.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Feb 2015 19:55:32 -0800 (PST)
Message-ID: <54E018A3.9000604@oracle.com>
Date: Sat, 14 Feb 2015 22:55:15 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2 1/3] slub: never fail to shrink cache
References: <cover.1422461573.git.vdavydov@parallels.com> <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
In-Reply-To: <012683fc3a0f9fb20a288986fd63fe9f6d25e8ee.1422461573.git.vdavydov@parallels.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Vladimir,

On 01/28/2015 11:22 AM, Vladimir Davydov wrote:
> SLUB's version of __kmem_cache_shrink() not only removes empty slabs,
> but also tries to rearrange the partial lists to place slabs filled up
> most to the head to cope with fragmentation. To achieve that, it
> allocates a temporary array of lists used to sort slabs by the number of
> objects in use. If the allocation fails, the whole procedure is aborted.
> 
> This is unacceptable for the kernel memory accounting extension of the
> memory cgroup, where we want to make sure that kmem_cache_shrink()
> successfully discarded empty slabs. Although the allocation failure is
> utterly unlikely with the current page allocator implementation, which
> retries GFP_KERNEL allocations of order <= 2 infinitely, it is better
> not to rely on that.
> 
> This patch therefore makes __kmem_cache_shrink() allocate the array on
> stack instead of calling kmalloc, which may fail. The array size is
> chosen to be equal to 32, because most SLUB caches store not more than
> 32 objects per slab page. Slab pages with <= 32 free objects are sorted
> using the array by the number of objects in use and promoted to the head
> of the partial list, while slab pages with > 32 free objects are left in
> the end of the list without any ordering imposed on them.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

It seems that this patch causes shrink to corrupt memory:

# echo 1 > /sys/kernel/slab/kmalloc-64/shrink
#
[   60.331433] =============================================================================
[   60.333052] BUG kmalloc-64 (Not tainted): Padding overwritten. 0xffff880051018f50-0xffff880051018fff
[   60.335714] -----------------------------------------------------------------------------
[   60.335714]
[   60.338530] Disabling lock debugging due to kernel taint
[   60.340140] INFO: Slab 0xffffea0001440600 objects=32767 used=65408 fp=0x          (null) flags=0x5fffff80000000
[   60.343095] CPU: 0 PID: 8634 Comm: sh Tainted: G    B           3.19.0-next-20150213-sasha-00045-g897c679-dirty #1920
[   60.345315]  ffff88001fc0ee40 00000000542c5de6 ffff88001114f908 ffffffffabb74948
[   60.346454]  0000000000000000 ffffea0001440600 ffff88001114f9e8 ffffffffa1764b4f
[   60.347582]  0000000000000007 ffff880000000028 ffff88001114f9f8 ffff88001114f9a8
[   60.349842] Call Trace:
[   60.350243]  [<ffffffffabb74948>] dump_stack+0x4f/0x7b
[   60.350975]  [<ffffffffa1764b4f>] slab_err+0xaf/0xd0
[   60.351714]  [<ffffffffa307cce0>] ? memchr_inv+0x2c0/0x360
[   60.352592]  [<ffffffffa17671b0>] slab_pad_check+0x120/0x1c0
[   60.353418]  [<ffffffffa17673a4>] __free_slab+0x154/0x1f0
[   60.354209]  [<ffffffffa141c365>] ? trace_hardirqs_on_caller+0x475/0x610
[   60.355168]  [<ffffffffa1767478>] discard_slab+0x38/0x60
[   60.355909]  [<ffffffffa176d478>] __kmem_cache_shrink+0x258/0x300
[   60.356801]  [<ffffffffa1764770>] ? print_tracking+0x70/0x70
[   60.357621]  [<ffffffffa1764770>] ? print_tracking+0x70/0x70
[   60.358448]  [<ffffffffa16c8460>] kmem_cache_shrink+0x20/0x30
[   60.359279]  [<ffffffffa17665db>] shrink_store+0x1b/0x30
[   60.360048]  [<ffffffffa17647af>] slab_attr_store+0x3f/0xf0
[   60.360951]  [<ffffffffa1764770>] ? print_tracking+0x70/0x70
[   60.361778]  [<ffffffffa193c56a>] sysfs_kf_write+0x11a/0x180
[   60.362601]  [<ffffffffa193c450>] ? sysfs_file_ops+0x170/0x170
[   60.363447]  [<ffffffffa1939ea1>] kernfs_fop_write+0x271/0x3b0
[   60.364348]  [<ffffffffa17ba386>] vfs_write+0x186/0x5d0
[   60.365112]  [<ffffffffa17bd146>] SyS_write+0x126/0x270
[   60.365837]  [<ffffffffa17bd020>] ? SyS_read+0x270/0x270
[   60.366608]  [<ffffffffa141c365>] ? trace_hardirqs_on_caller+0x475/0x610
[   60.367580]  [<ffffffffa3091d7b>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   60.368566]  [<ffffffffabbea3ad>] system_call_fastpath+0x16/0x1b
[   60.369435] Padding ffff880051018f50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   60.370750] Padding ffff880051018f60: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   60.372077] Padding ffff880051018f70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[   60.373450] Padding ffff880051018f80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[   60.374763] Padding ffff880051018f90: bb bb bb bb bb bb bb bb c8 8d 01 51 00 88 ff ff  ...........Q....
[   60.376083] Padding ffff880051018fa0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   60.377457] Padding ffff880051018fb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   60.378768] Padding ffff880051018fc0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   60.380084] Padding ffff880051018fd0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   60.381475] Padding ffff880051018fe0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   60.382798] Padding ffff880051018ff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   60.384121] FIX kmalloc-64: Restoring 0xffff880051018f50-0xffff880051018fff=0x5a
[...]

And basically a lot more of the above.



Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
