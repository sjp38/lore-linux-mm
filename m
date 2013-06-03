From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 11/13] x86, memblock, mem-hotplug: Free hotpluggable
 memory reserved by memblock.
Date: Mon, 3 Jun 2013 10:57:45 +0800
Message-ID: <2854.17194613746$1370228292@news.gmane.org>
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com>
 <1369387762-17865-12-git-send-email-tangchen@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UjKyA-00086b-S0
	for glkm-linux-mm-2@m.gmane.org; Mon, 03 Jun 2013 04:58:03 +0200
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id CD2776B0032
	for <linux-mm@kvack.org>; Sun,  2 Jun 2013 22:57:59 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 3 Jun 2013 12:44:21 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 87DA63578051
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 12:57:48 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r532hPc724510650
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 12:43:26 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r532vkdm028677
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 12:57:47 +1000
Content-Disposition: inline
In-Reply-To: <1369387762-17865-12-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 24, 2013 at 05:29:20PM +0800, Tang Chen wrote:
>We reserved hotpluggable memory in memblock. And when memory initialization
>is done, we have to free it to buddy system.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>This patch free memory reserved by memblock with flag MEMBLK_HOTPLUGGABLE.
>
>Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>---
> include/linux/memblock.h |    1 +
> mm/memblock.c            |   20 ++++++++++++++++++++
> mm/nobootmem.c           |    3 +++
> 3 files changed, 24 insertions(+), 0 deletions(-)
>
>diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>index 0f01930..08c761d 100644
>--- a/include/linux/memblock.h
>+++ b/include/linux/memblock.h
>@@ -69,6 +69,7 @@ int memblock_free(phys_addr_t base, phys_addr_t size);
> int memblock_reserve(phys_addr_t base, phys_addr_t size);
> int memblock_reserve_local_node(phys_addr_t base, phys_addr_t size, int nid);
> int memblock_reserve_hotpluggable(phys_addr_t base, phys_addr_t size, int nid);
>+void memblock_free_hotpluggable(void);
> void memblock_trim_memory(phys_addr_t align);
> void memblock_mark_kernel_nodes(void);
> bool memblock_is_kernel_node(int nid);
>diff --git a/mm/memblock.c b/mm/memblock.c
>index 0c55588..54de398 100644
>--- a/mm/memblock.c
>+++ b/mm/memblock.c
>@@ -568,6 +568,26 @@ int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)
> 	return __memblock_remove(&memblock.reserved, base, size);
> }
>
>+static void __init_memblock memblock_free_flags(unsigned long flags)
>+{
>+	int i;
>+	struct memblock_type *reserved = &memblock.reserved;
>+
>+	for (i = 0; i < reserved->cnt; i++) {
>+		if (reserved->regions[i].flags == flags)
>+			memblock_remove_region(reserved, i);
>+	}
>+}
>+
>+void __init_memblock memblock_free_hotpluggable()
>+{
>+	unsigned long flags = 1 << MEMBLK_HOTPLUGGABLE;
>+
>+	memblock_dbg("memblock: free all hotpluggable memory");
>+
>+	memblock_free_flags(flags);
>+}
>+
> static int __init_memblock memblock_reserve_region(phys_addr_t base,
> 						   phys_addr_t size,
> 						   int nid,
>diff --git a/mm/nobootmem.c b/mm/nobootmem.c
>index 5e07d36..cd85604 100644
>--- a/mm/nobootmem.c
>+++ b/mm/nobootmem.c
>@@ -165,6 +165,9 @@ unsigned long __init free_all_bootmem(void)
> 	for_each_online_pgdat(pgdat)
> 		reset_node_lowmem_managed_pages(pgdat);
>
>+	/* Hotpluggable memory reserved by memblock should also be freed. */
>+	memblock_free_hotpluggable();
>+
> 	/*
> 	 * We need to use MAX_NUMNODES instead of NODE_DATA(0)->node_id
> 	 *  because in some case like Node0 doesn't have RAM installed
>-- 
>1.7.1
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
