Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 5C7596B0028
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 01:19:32 -0500 (EST)
Received: by mail-ia0-f170.google.com with SMTP id k20so3506860iak.15
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 22:19:31 -0800 (PST)
Message-ID: <1359613162.1587.0.camel@kernel>
Subject: Re: [PATCH v6 00/15] memory-hotplug: hot-remove physical memory
From: Simon Jeons <simon.jeons@gmail.com>
Date: Thu, 31 Jan 2013 00:19:22 -0600
In-Reply-To: <5109E59F.5080104@cn.fujitsu.com>
References: <1357723959-5416-1-git-send-email-tangchen@cn.fujitsu.com>
	  <1359463973.1624.15.camel@kernel> <5108F2B3.3090506@cn.fujitsu.com>
	 <1359595344.1557.13.camel@kernel> <5109E59F.5080104@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Tang,
On Thu, 2013-01-31 at 11:31 +0800, Tang Chen wrote:
> Hi Simon,
> 
> Please see below. :)
> 
> On 01/31/2013 09:22 AM, Simon Jeons wrote:
> >
> > Sorry, I still confuse. :(
> > update node_states[N_NORMAL_MEMORY] to node_states[N_MEMORY] or
> > node_states[N_NORMAL_MEMOR] present 0...ZONE_MOVABLE?
> >
> > node_states is what? node_states[N_NORMAL_MEMOR] or
> > node_states[N_MEMORY]?
> 
> Are you asking what node_states[] is ?
> 
> node_states[] is an array of nodemask,
> 
>      extern nodemask_t node_states[NR_NODE_STATES];
> 
> For example, node_states[N_NORMAL_MEMOR] represents which nodes have 
> normal memory.
> If N_MEMORY == N_HIGH_MEMORY == N_NORMAL_MEMORY, node_states[N_MEMORY] is
> node_states[N_NORMAL_MEMOR]. So it represents which nodes have 0 ... 
> ZONE_MOVABLE.
> 

Sorry, how can nodes_state[N_NORMAL_MEMORY] represents a node have 0 ...
*ZONE_MOVABLE*, the comment of enum nodes_states said that
N_NORMAL_MEMORY just means the node has regular memory.  

> 
> > Why check !z1->wait_table in function move_pfn_range_left and function
> > __add_zone? I think zone->wait_table is initialized in
> > free_area_init_core, which will be called during system initialization
> > and hotadd_new_pgdat path.
> 
> I think,
> 
> free_area_init_core(), in the for loop,
>   |--> size = zone_spanned_pages_in_node();
>   |--> if (!size)
>                continue;  ----------------  If zone is empty, we jump 
> out the for loop.
>   |--> init_currently_empty_zone()
> 
> So, if the zone is empty, wait_table is not initialized.
> 
> In move_pfn_range_left(z1, z2), we move pages from z2 to z1. But z1 
> could be empty.
> So we need to check it and initialize z1->wait_table because we are 
> moving pages into it.

thanks.

> 
> 
> > There is a zone populated check in function online_pages. But zone is
> > populated in free_area_init_core which will be called during system
> > initialization and hotadd_new_pgdat path. Why still need this check?
> >
> 
> Because we could also rebuild zone list when we offline pages.
> 
> __offline_pages()
>   |--> zone->present_pages -= offlined_pages;
>   |--> if (!populated_zone(zone)) {
>                build_all_zonelists(NULL, NULL);
>        }
> 
> If the zone is empty, and other zones on the same node is not empty, the 
> node
> won't be offlined, and next time we online pages of this zone, the pgdat 
> won't
> be initialized again, and we need to check populated_zone(zone) when 
> onlining
> pages.

thanks.

> 
> Thanks. :)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
