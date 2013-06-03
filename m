From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 03/13] page_alloc, mem-hotplug: Improve movablecore to
 {en|dis}able using SRAT.
Date: Mon, 3 Jun 2013 08:52:59 +0800
Message-ID: <47950.4805327908$1370220799@news.gmane.org>
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com>
 <1369387762-17865-4-git-send-email-tangchen@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UjJ1I-00042n-Hx
	for glkm-linux-mm-2@m.gmane.org; Mon, 03 Jun 2013 02:53:08 +0200
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 98A136B0036
	for <linux-mm@kvack.org>; Sun,  2 Jun 2013 20:53:06 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 3 Jun 2013 10:42:18 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 96E182CE8051
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 10:53:01 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r530cUkm25231376
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 10:38:30 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r530r0Dn024042
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 10:53:01 +1000
Content-Disposition: inline
In-Reply-To: <1369387762-17865-4-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 24, 2013 at 05:29:12PM +0800, Tang Chen wrote:
>The Hot-Pluggable Fired in SRAT specified which memory ranges are hotpluggable.
>We will arrange hotpluggable memory as ZONE_MOVABLE for users who want to use
>memory hotplug functionality. But this will cause NUMA performance decreased
>because kernel cannot use ZONE_MOVABLE.
>
>So we improve movablecore boot option to allow those who want to use memory
>hotplug functionality to enable using SRAT info to arrange movable memory.
>
>Users can specify "movablecore=acpi" in kernel commandline to enable this
>functionality.
>
>For those who don't use memory hotplug or who don't want to lose their NUMA
>performance, just don't specify anything. The kernel will work as before.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Suggested-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>---
> include/linux/memory_hotplug.h |    3 +++
> mm/page_alloc.c                |   13 +++++++++++++
> 2 files changed, 16 insertions(+), 0 deletions(-)
>
>diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>index b6a3be7..18fe2a3 100644
>--- a/include/linux/memory_hotplug.h
>+++ b/include/linux/memory_hotplug.h
>@@ -33,6 +33,9 @@ enum {
> 	ONLINE_MOVABLE,
> };
>
>+/* Enable/disable SRAT in movablecore boot option */
>+extern bool movablecore_enable_srat;
>+
> /*
>  * pgdat resizing functions
>  */
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index f368db4..b9ea143 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -208,6 +208,8 @@ static unsigned long __initdata required_kernelcore;
> static unsigned long __initdata required_movablecore;
> static unsigned long __meminitdata zone_movable_pfn[MAX_NUMNODES];
>
>+bool __initdata movablecore_enable_srat = false;
>+
> /* movable_zone is the "real" zone pages in ZONE_MOVABLE are taken from */
> int movable_zone;
> EXPORT_SYMBOL(movable_zone);
>@@ -5025,6 +5027,12 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
> 	}
> }
>
>+static void __init cmdline_movablecore_srat(char *p)
>+{
>+	if (p && !strcmp(p, "acpi"))
>+		movablecore_enable_srat = true;
>+}
>+
> static int __init cmdline_parse_core(char *p, unsigned long *core)
> {
> 	unsigned long long coremem;
>@@ -5055,6 +5063,11 @@ static int __init cmdline_parse_kernelcore(char *p)
>  */
> static int __init cmdline_parse_movablecore(char *p)
> {
>+	cmdline_movablecore_srat(p);
>+
>+	if (movablecore_enable_srat)
>+		return 0;
>+
> 	return cmdline_parse_core(p, &required_movablecore);
> }
>
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
