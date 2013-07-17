Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 3270E6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 06:36:16 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Jul 2013 20:28:30 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 55A832CE802D
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 20:36:09 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6HAZvw83539446
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 20:35:59 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6HAa6HL017986
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 20:36:06 +1000
Date: Wed, 17 Jul 2013 06:36:05 -0400
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: zswap: How to determine whether it is compressing swap pages?
Message-ID: <20130717103604.GA31112@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1674223.HVFdAhB7u5@merkaba>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1674223.HVFdAhB7u5@merkaba>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Steigerwald <Martin@lichtvoll.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 17, 2013 at 12:04:38PM +0200, Martin Steigerwald wrote:
>Hi Seth, hi everyone,
>
>Yesterday I build 3.11-rc1 with CONFIG_ZSWAP and wanted to test it.
>
>I added zswap.enabled=1 and get:
>
>martin@merkaba:~> dmesg | grep zswap
>[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.11.0-rc1-tp520+ 
>root=/dev/mapper/merkaba-debian ro rootflags=subvol=root init=/bin/systemd 
>cgroup_enable=memory threadirqs i915.i915_enable_rc6=7 zcache zswap.enabled=1
>[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.11.0-rc1-tp520+ 
>root=/dev/mapper/merkaba-debian ro rootflags=subvol=root init=/bin/systemd 
>cgroup_enable=memory threadirqs i915.i915_enable_rc6=7 zcache zswap.enabled=1
>[    1.452443] zswap: loading zswap
>[    1.452465] zswap: using lzo compressor
>
>
>I did a stress -m 1 --vm-keep --vm-bytes 4G on this 8 GB ThinkPad T520 in 
>order to allocate some swap.
>

You can check /sys/kernel/debug/frontswap/succ_stores, if succ_stores is
0 it means that the memory pressure is still not heavy and none pages
need be swapped out.

>Still I think zswap didn't do anything:
>
>merkaba:/sys/kernel/debug/zswap> grep . *
>duplicate_entry:0
>pool_limit_hit:0
>pool_pages:0
>reject_alloc_fail:0
>reject_compress_poor:0
>reject_kmemcache_fail:0
>reject_reclaim_fail:0
>stored_pages:0
>written_back_pages:0
>
>
>However:
>
>merkaba:/sys/kernel/slab/zswap_entry> grep . *
>aliases:9
>align:8
>grep: alloc_calls: Die angeforderte Funktion ist nicht implementiert
>cache_dma:0
>cpu_partial:0
>cpu_slabs:4 N0=4
>destroy_by_rcu:0
>grep: free_calls: Die angeforderte Funktion ist nicht implementiert
>hwcache_align:0
>min_partial:5
>objects:2550 N0=2550
>object_size:48
>objects_partial:0
>objs_per_slab:85
>order:0
>partial:0
>poison:0
>reclaim_account:0
>red_zone:0
>remote_node_defrag_ratio:100
>reserved:0
>sanity_checks:0
>slabs:30 N0=30
>slabs_cpu_partial:0(0)
>slab_size:48
>store_user:0
>total_objects:2550 N0=2550
>trace:0
>
>It has some objects it seems.
>
>
>How do I know whether zswap actually does something?
>
>Will zswap work even with zcache enabled? As I understand zcache compresses 
>swap device pages on the block device level in addition to compressing read 
>cache pages of usual filesystems. Which one takes precedence, zcache or zswap? 
>Can I disable zcache for swap device?
>
>

zcache compression in file-cache and swap-cache layer.
zram compression in block layer.
zswap compression in swap-cache layer.

>
>Here is dmesg for zcache:
>
>martin@merkaba:~> dmesg | grep zcache
>[    0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.11.0-rc1-tp520+ 
>root=/dev/mapper/merkaba-debian ro rootflags=subvol=root init=/bin/systemd 
>cgroup_enable=memory threadirqs i915.i915_enable_rc6=7 zcache zswap.enabled=1
>[    0.000000] Kernel command line: BOOT_IMAGE=/vmlinuz-3.11.0-rc1-tp520+ 
>root=/dev/mapper/merkaba-debian ro rootflags=subvol=root init=/bin/systemd 
>cgroup_enable=memory threadirqs i915.i915_enable_rc6=7 zcache zswap.enabled=1
>[    1.453531] zcache: using lzo compressor
>[    1.453634] zcache: cleancache enabled using kernel transcendent memory and 
>compression buddies
>[    1.453679] zcache: frontswap enabled using kernel transcendent memory and 
>compression buddies
>[    1.453722] zcache: frontswap_ops overridden
>[    5.358288] zcache: created ephemeral local tmem pool, id=0
>[    8.155684] zcache: created persistent local tmem pool, id=1
>[    8.331680] zcache: created ephemeral local tmem pool, id=2
>[    8.593235] zcache: created ephemeral local tmem pool, id=3
>[    8.743330] zcache: created ephemeral local tmem pool, id=4
>

This means zcache is configured for compressing file-cache pages and anonymous pages.

Regards,
Wanpeng Li 

>
>Thanks,
>-- 
>Martin 'Helios' Steigerwald - http://www.Lichtvoll.de
>GPG: 03B0 0D6C 0040 0710 4AFA  B82F 991B EAAC A599 84C7
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
