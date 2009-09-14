Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EBBD46B004D
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 23:17:59 -0400 (EDT)
Message-ID: <4AADB5EE.9090902@redhat.com>
Date: Mon, 14 Sep 2009 11:18:06 +0800
From: Danny Feng <dfeng@redhat.com>
MIME-Version: 1.0
Subject: Re: [GIT BISECT] BUG kmalloc-8192: Object already free from kmem_cache_destroy
References: <1252866835.13780.37.camel@dhcp231-106.rdu.redhat.com>
In-Reply-To: <1252866835.13780.37.camel@dhcp231-106.rdu.redhat.com>
Content-Type: multipart/mixed;
 boundary="------------040408020607040807040307"
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: cl@linux-foundation.org, penberg@cs.helsinki.fi, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040408020607040807040307
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

On 09/14/2009 02:33 AM, Eric Paris wrote:
> 2a38a002fbee06556489091c30b04746222167e4 is first bad commit
> commit 2a38a002fbee06556489091c30b04746222167e4
> Author: Xiaotian Feng<dfeng@redhat.com>
> Date:   Wed Jul 22 17:03:57 2009 +0800
>
>      slub: sysfs_slab_remove should free kmem_cache when debug is enabled
>
>      kmem_cache_destroy use sysfs_slab_remove to release the kmem_cache,
>      but when CONFIG_SLUB_DEBUG is enabled, sysfs_slab_remove just release
>      related kobject, the whole kmem_cache is missed to release and cause
>      a memory leak.
>
>      Acked-by: Christoph Lameer<cl@linux-foundation.org>
>      Signed-off-by: Xiaotian Feng<dfeng@redhat.com>
>      Signed-off-by: Pekka Enberg<penberg@cs.helsinki.fi>
>
> CONFIG_SLUB_DEBUG=y
> CONFIG_SLUB=y
> CONFIG_SLUB_DEBUG_ON=y
> # CONFIG_SLUB_STATS is not set
>
> I created a very simple kernel module which consisted only of:
>
> static int __init kmem_cache_test_init_module(void)
> {
> 	struct kmem_cache *test_cachep;
>
> 	test_cachep = kmem_cache_create("test_cachep", 32, 0, 0, NULL);
> 	if (test_cachep)
> 		kmem_cache_destroy(test_cachep);
>
>          return 0;
> }
>
> Before this patch it works just fine.  After this patch I get a bug like
> this:
>
> [   59.921431] kmem_cache_test_init_module:
> [   59.922415] =============================================================================
> [   59.922418] BUG kmalloc-8192: Object already free
> [   59.922419] -----------------------------------------------------------------------------
> [   59.922420]
> [   59.922453] INFO: Allocated in kmem_cache_create+0x70/0x320 age=1 cpu=3 pid=1781
> [   59.922458] INFO: Freed in kmem_cache_release+0x23/0x40 age=0 cpu=3 pid=1781
> [   59.922461] INFO: Slab 0xffffea0000373cc0 objects=3 used=1 fp=0xffff8800087fa048 flags=0x200000000040c3
> [   59.922463] INFO: Object 0xffff8800087fa048 @offset=8264 fp=0xffff8800087fc090
> [   59.922463]
> [   59.922465] Bytes b4 0xffff8800087fa038:  00 00 00 00 00 00 00 00 5a 5a 5a 5a 5a 5a 5a 5a ........ZZZZZZZZ
> [   59.922477]   Object 0xffff8800087fa048:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [   59.922487]   Object 0xffff8800087fa058:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [snip]
> [   59.923261]   Object 0xffff8800087fb028:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [   59.923261]   Object 0xffff8800087fb038:  6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkkkk
> [   59.923261]  Redzone 0xffff8800087fc048:  bb bb bb bb bb bb bb bb                         A>>A>>A>>A>>A>>A>>A>>A>>
> [   59.923261]  Padding 0xffff8800087fc088:  5a 5a 5a 5a 5a 5a 5a 5a                         ZZZZZZZZ
> [   59.923261] Pid: 1781, comm: insmod Not tainted 2.6.31-rc2 #33
> [   59.923261] Call Trace:
> [   59.923261]  [<ffffffff81142e1b>] print_trailer+0xfb/0x160
> [   59.923261]  [<ffffffff81142ec9>] object_err+0x49/0x70
> [   59.923261]  [<ffffffff81146166>] __slab_free+0x266/0x3c0
> [   59.923261]  [<ffffffff811463ac>] kfree+0xec/0x220
> [   59.923261]  [<ffffffff81146c4e>] ? kmem_cache_destroy+0x20e/0x230
> [   59.923261]  [<ffffffffa02d1000>] ? kmem_cache_test_init_module+0x0/0x67 [cache_test]
> [   59.923261]  [<ffffffffa02d1000>] ? kmem_cache_test_init_module+0x0/0x67 [cache_test]
> [   59.923261]  [<ffffffff81146c4e>] kmem_cache_destroy+0x20e/0x230
> [   59.923261]  [<ffffffffa02d1000>] ? kmem_cache_test_init_module+0x0/0x67 [cache_test]
> [   59.923261]  [<ffffffffa02d104f>] kmem_cache_test_init_module+0x4f/0x67 [cache_test]
> [   59.923261]  [<ffffffff8100a07b>] do_one_initcall+0x4b/0x1a0
> [   59.923261]  [<ffffffff810b5f08>] sys_init_module+0x108/0x260
> [   59.923261]  [<ffffffff81014282>] system_call_fastpath+0x16/0x1b
> [   59.923261] FIX kmalloc-8192: Object at 0xffff8800087fa048 not freed
>
>
I think I got the real problem, that's introduced from former commit 
a0e1d1be204612ee83b3afe8aa24c5d27e63d464,  this results kmem_cache 
always be freed at kmem_cache_create....
Can following patch fix this issue?




--------------040408020607040807040307
Content-Type: text/x-patch;
 name="0001-slub-fix-kmem_cache-wrongly-freed-in-kmem_cache_cre.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-slub-fix-kmem_cache-wrongly-freed-in-kmem_cache_cre.pat";
 filename*1="ch"


--------------040408020607040807040307--
