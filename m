Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E093B6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 06:42:25 -0400 (EDT)
Message-ID: <51E6750A.9060900@oracle.com>
Date: Wed, 17 Jul 2013 18:42:18 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: zswap: How to determine whether it is compressing swap pages?
References: <1674223.HVFdAhB7u5@merkaba>
In-Reply-To: <1674223.HVFdAhB7u5@merkaba>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Steigerwald <Martin@lichtvoll.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Martin,

On 07/17/2013 06:04 PM, Martin Steigerwald wrote:
> Hi Seth, hi everyone,
>
> Yesterday I build 3.11-rc1 with CONFIG_ZSWAP and wanted to test it.
>
> I added zswap.enabled=1 and get:
>
> martin@merkaba:~> dmesg | grep zswap
> [    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.11.0-rc1-tp520+
> root=/dev/mapper/merkaba-debian ro rootflags=subvol=root init=/bin/systemd
> cgroup_enable=memory threadirqs i915.i915_enable_rc6=7 zcache zswap.enabled=1
> [    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.11.0-rc1-tp520+
> root=/dev/mapper/merkaba-debian ro rootflags=subvol=root init=/bin/systemd
> cgroup_enable=memory threadirqs i915.i915_enable_rc6=7 zcache zswap.enabled=1
> [    1.452443] zswap: loading zswap
> [    1.452465] zswap: using lzo compressor
>
>
> I did a stress -m 1 --vm-keep --vm-bytes 4G on this 8 GB ThinkPad T520 in
> order to allocate some swap.
>

Thank you for your testing.
I'm glad to see there is new people interested with memory compression.

> Still I think zswap didn't do anything:
>
> merkaba:/sys/kernel/debug/zswap> grep . *
> duplicate_entry:0
> pool_limit_hit:0
> pool_pages:0
> reject_alloc_fail:0
> reject_compress_poor:0
> reject_kmemcache_fail:0
> reject_reclaim_fail:0
> stored_pages:0
> written_back_pages:0
>
>
> However:
>
> merkaba:/sys/kernel/slab/zswap_entry> grep . *
> aliases:9
> align:8
> grep: alloc_calls: Die angeforderte Funktion ist nicht implementiert
> cache_dma:0
> cpu_partial:0
> cpu_slabs:4 N0=4
> destroy_by_rcu:0
> grep: free_calls: Die angeforderte Funktion ist nicht implementiert
> hwcache_align:0
> min_partial:5
> objects:2550 N0=2550
> object_size:48
> objects_partial:0
> objs_per_slab:85
> order:0
> partial:0
> poison:0
> reclaim_account:0
> red_zone:0
> remote_node_defrag_ratio:100
> reserved:0
> sanity_checks:0
> slabs:30 N0=30
> slabs_cpu_partial:0(0)
> slab_size:48
> store_user:0
> total_objects:2550 N0=2550
> trace:0
>
> It has some objects it seems.
>
>
> How do I know whether zswap actually does something?
>
> Will zswap work even with zcache enabled? As I understand zcache compresses
> swap device pages on the block device level in addition to compressing read
> cache pages of usual filesystems. Which one takes precedence, zcache or zswap?
> Can I disable zcache for swap device?
>

Please disable zcache and try again.

>
>
> Here is dmesg for zcache:
>
> martin@merkaba:~> dmesg | grep zcache
> [    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.11.0-rc1-tp520+
> root=/dev/mapper/merkaba-debian ro rootflags=subvol=root init=/bin/systemd
> cgroup_enable=memory threadirqs i915.i915_enable_rc6=7 zcache zswap.enabled=1
> [    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.11.0-rc1-tp520+
> root=/dev/mapper/merkaba-debian ro rootflags=subvol=root init=/bin/systemd
> cgroup_enable=memory threadirqs i915.i915_enable_rc6=7 zcache zswap.enabled=1
> [    1.453531] zcache: using lzo compressor
> [    1.453634] zcache: cleancache enabled using kernel transcendent memory and
> compression buddies
> [    1.453679] zcache: frontswap enabled using kernel transcendent memory and
> compression buddies
> [    1.453722] zcache: frontswap_ops overridden
> [    5.358288] zcache: created ephemeral local tmem pool, id=0
> [    8.155684] zcache: created persistent local tmem pool, id=1
> [    8.331680] zcache: created ephemeral local tmem pool, id=2
> [    8.593235] zcache: created ephemeral local tmem pool, id=3
> [    8.743330] zcache: created ephemeral local tmem pool, id=4
>
>
> Thanks,
>

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
