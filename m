From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 02/13] acpi: Print Hot-Pluggable Field in SRAT.
Date: Mon, 3 Jun 2013 08:50:09 +0800
Message-ID: <35850.8942103528$1370220632@news.gmane.org>
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com>
 <1369387762-17865-3-git-send-email-tangchen@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UjIya-0002yz-VO
	for glkm-linux-mm-2@m.gmane.org; Mon, 03 Jun 2013 02:50:21 +0200
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 91F5B6B0032
	for <linux-mm@kvack.org>; Sun,  2 Jun 2013 20:50:18 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 3 Jun 2013 06:14:51 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 7F7E9394004F
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 06:20:13 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r530o69m6029780
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 06:20:07 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r530oAEX019173
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 10:50:11 +1000
Content-Disposition: inline
In-Reply-To: <1369387762-17865-3-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 24, 2013 at 05:29:11PM +0800, Tang Chen wrote:
>The Hot-Pluggable field in SRAT suggests if the memory could be
>hotplugged while the system is running. Print it as well when
>parsing SRAT will help users to know which memory is hotpluggable.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>---
> arch/x86/mm/srat.c |    9 ++++++---
> 1 files changed, 6 insertions(+), 3 deletions(-)
>
>diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
>index 443f9ef..5055fa7 100644
>--- a/arch/x86/mm/srat.c
>+++ b/arch/x86/mm/srat.c
>@@ -146,6 +146,7 @@ int __init
> acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
> {
> 	u64 start, end;
>+	u32 hotpluggable;
> 	int node, pxm;
>
> 	if (srat_disabled())
>@@ -154,7 +155,8 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
> 		goto out_err_bad_srat;
> 	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) == 0)
> 		goto out_err;
>-	if ((ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE) && !save_add_info())
>+	hotpluggable = ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE;
>+	if (hotpluggable && !save_add_info())
> 		goto out_err;
>
> 	start = ma->base_address;
>@@ -174,9 +176,10 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
>
> 	node_set(node, numa_nodes_parsed);
>
>-	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]\n",
>+	printk(KERN_INFO "SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx] %s\n",
> 	       node, pxm,
>-	       (unsigned long long) start, (unsigned long long) end - 1);
>+	       (unsigned long long) start, (unsigned long long) end - 1,
>+	       hotpluggable ? "Hot Pluggable" : "");
>
> 	return 0;
> out_err_bad_srat:
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
