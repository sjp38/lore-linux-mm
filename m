Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 9BACA6B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 21:40:50 -0400 (EDT)
Received: by mail-ye0-f178.google.com with SMTP id m15so1185108yen.9
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 18:40:49 -0700 (PDT)
Date: Mon, 17 Jun 2013 18:40:42 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 13/22] x86, mm, numa: Use numa_meminfo to check
 node_map_pfn alignment
Message-ID: <20130618014042.GW32663@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <1371128589-8953-14-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1371128589-8953-14-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 13, 2013 at 09:03:00PM +0800, Tang Chen wrote:
> From: Yinghai Lu <yinghai@kernel.org>
> 
> We could use numa_meminfo directly instead of memblock nid in
> node_map_pfn_alignment().
> 
> So we could do setting memblock nid later and only do it once
> for successful path.
> 
> -v2: according to tj, separate moving to another patch.

How about something like,

  Subject: x86, mm, NUMA: Use numa_meminfo instead of memblock in node_map_pfn_alignment()

  When sparsemem is used and page->flags doesn't have enough space to
  carry both the sparsemem section and node ID, NODE_NOT_IN_PAGE_FLAGS
  is set and the node is determined from section.  This requires that
  the NUMA nodes aren't more granular than sparsemem sections.
  node_map_pfn_alignment() is used to determine the maximum NUMA
  inter-node alignment which can distinguish all nodes to verify the
  above condition.

  The function currently assumes the NUMA node maps are populated and
  sorted and uses for_each_mem_pfn_range() to iterate memory regions.
  We want this to happen way earlier to support memory hotplug (maybe
  elaborate a bit more here).

  This patch updates node_map_pfn_alignment() so that it iterates over
  numa_meminfo instead and moves its invocation before memory regions
  are registered to memblock and node maps in numa_register_memblks().
  This will help memory hotplug (how...) and as a bonus we register
  memory regions only if the alignment check succeeds rather than
  registering and then failing.

Also, the comment on top of node_map_pfn_alignment() needs to be
updated, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
