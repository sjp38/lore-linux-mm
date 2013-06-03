From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 01/13] x86: get pg_data_t's memory from other node
Date: Mon, 3 Jun 2013 08:31:09 +0800
Message-ID: <45927.5093199269$1370219502@news.gmane.org>
References: <1369387762-17865-1-git-send-email-tangchen@cn.fujitsu.com>
 <1369387762-17865-2-git-send-email-tangchen@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UjIgO-0004Cj-4D
	for glkm-linux-mm-2@m.gmane.org; Mon, 03 Jun 2013 02:31:32 +0200
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id C4E126B0032
	for <linux-mm@kvack.org>; Sun,  2 Jun 2013 20:31:27 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 3 Jun 2013 05:57:08 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 1CDA21258054
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 06:03:22 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r530V8wu52691168
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 06:01:08 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r530VBem007193
	for <linux-mm@kvack.org>; Mon, 3 Jun 2013 00:31:13 GMT
Content-Disposition: inline
In-Reply-To: <1369387762-17865-2-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, tj@kernel.org, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 24, 2013 at 05:29:10PM +0800, Tang Chen wrote:
>From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
>If system can create movable node which all memory of the
>node is allocated as ZONE_MOVABLE, setup_node_data() cannot
>allocate memory for the node's pg_data_t.
>So, use memblock_alloc_try_nid() instead of memblock_alloc_nid()
>to retry when the first allocation fails.
>
>As noticed by Chen Gong <gong.chen@linux.intel.com>, memblock_alloc_try_nid()
>will call panic() if it fails to allocate memory. So we don't need to
>check the return value.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>---
> arch/x86/mm/numa.c |    7 +------
> 1 files changed, 1 insertions(+), 6 deletions(-)
>
>diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
>index 11acdf6..af18b18 100644
>--- a/arch/x86/mm/numa.c
>+++ b/arch/x86/mm/numa.c
>@@ -214,12 +214,7 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
> 	 * Allocate node data.  Try node-local memory and then any node.
> 	 * Never allocate in DMA zone.
> 	 */
>-	nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
>-	if (!nd_pa) {
>-		pr_err("Cannot find %zu bytes in node %d\n",
>-		       nd_size, nid);
>-		return;
>-	}
>+	nd_pa = memblock_alloc_try_nid(nd_size, SMP_CACHE_BYTES, nid);
> 	nd = __va(nd_pa);
>
> 	/* report and initialize */
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
