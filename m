Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1B90A6B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 07:56:03 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9KBu0Ym011269
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Oct 2009 20:56:00 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E508C45DE4F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 20:55:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B194F45DE50
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 20:55:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 87DA2E78002
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 20:55:59 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 359B3E38002
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 20:55:59 +0900 (JST)
Message-ID: <c18f2c2738f6a584b431324b38f21970.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20091019213415.32729.86034.stgit@bob.kio>
References: <20091019212740.32729.7171.stgit@bob.kio>
    <20091019213415.32729.86034.stgit@bob.kio>
Date: Tue, 20 Oct 2009 20:55:58 +0900 (JST)
Subject: Re: [PATCH 1/5] mm: add numa node symlink for memory section in
 sysfs
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Gary Hade <garyhade@us.ibm.com>, Badari Pulavarty <pbadari@us.ibm.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alex Chiang wrote:
> Commit c04fc586c (mm: show node to memory section relationship with
> symlinks in sysfs) created symlinks from nodes to memory sections, e.g.
>
> /sys/devices/system/node/node1/memory135 -> ../../memory/memory135
>
> If you're examining the memory section though and are wondering what
> node it might belong to, you can find it by grovelling around in
> sysfs, but it's a little cumbersome.
>
> Add a reverse symlink for each memory section that points back to the
> node to which it belongs.
>
> Cc: Gary Hade <garyhade@us.ibm.com>
> Cc: Badari Pulavarty <pbadari@us.ibm.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Alex Chiang <achiang@hp.com>

2 yeas ago, I wanted to add this symlink. But don't...because
some vendor's host has no 1-to-1 relationship between a memsection
and a node. (I don't remember precisely, sorry....s390?)

Then, a memsection can be under prural nodes.

At brief look, this patch provides 1-to-1 relationship between them.
If it's ok for all stake-holders, I welcome this.

Thanks,
-Kame

> ---
>
>  Documentation/ABI/testing/sysfs-devices-memory |   14 +++++++++++++-
>  Documentation/memory-hotplug.txt               |   11 +++++++----
>  drivers/base/node.c                            |   11 ++++++++++-
>  3 files changed, 30 insertions(+), 6 deletions(-)
>
> diff --git a/Documentation/ABI/testing/sysfs-devices-memory
> b/Documentation/ABI/testing/sysfs-devices-memory
> index 9fe91c0..bf1627b 100644
> --- a/Documentation/ABI/testing/sysfs-devices-memory
> +++ b/Documentation/ABI/testing/sysfs-devices-memory
> @@ -60,6 +60,19 @@ Description:
>  Users:		hotplug memory remove tools
>  		https://w3.opensource.ibm.com/projects/powerpc-utils/
>
> +
> +What:		/sys/devices/system/memoryX/nodeY
> +Date:		October 2009
> +Contact:	Linux Memory Management list <linux-mm@kvack.org>
> +Description:
> +		When CONFIG_NUMA is enabled, a symbolic link that
> +		points to the corresponding NUMA node directory.
> +
> +		For example, the following symbolic link is created for
> +		memory section 9 on node0:
> +		/sys/devices/system/memory/memory9/node0 -> ../../node/node0
> +
> +
>  What:		/sys/devices/system/node/nodeX/memoryY
>  Date:		September 2008
>  Contact:	Gary Hade <garyhade@us.ibm.com>
> @@ -70,4 +83,3 @@ Description:
>  		memory section directory.  For example, the following symbolic
>  		link is created for memory section 9 on node0.
>  		/sys/devices/system/node/node0/memory9 -> ../../memory/memory9
> -
> diff --git a/Documentation/memory-hotplug.txt
> b/Documentation/memory-hotplug.txt
> index bbc8a6a..57e7e9c 100644
> --- a/Documentation/memory-hotplug.txt
> +++ b/Documentation/memory-hotplug.txt
> @@ -160,12 +160,15 @@ Under each section, you can see 4 files.
>  NOTE:
>    These directories/files appear after physical memory hotplug phase.
>
> -If CONFIG_NUMA is enabled the
> -/sys/devices/system/memory/memoryXXX memory section
> -directories can also be accessed via symbolic links located in
> -the /sys/devices/system/node/node* directories.  For example:
> +If CONFIG_NUMA is enabled the memoryXXX/ directories can also be accessed
> +via symbolic links located in the /sys/devices/system/node/node*
> directories.
> +
> +For example:
>  /sys/devices/system/node/node0/memory9 -> ../../memory/memory9
>
> +A backlink will also be created:
> +/sys/devices/system/memory/memory9/node0 -> ../../node/node0
> +
>  --------------------------------
>  4. Physical memory hot-add phase
>  --------------------------------
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 1fe5536..3108b21 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -268,6 +268,7 @@ static int get_nid_for_pfn(unsigned long pfn)
>  /* register memory section under specified node if it spans that node */
>  int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
>  {
> +	int ret;
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
>
>  	if (!mem_blk)
> @@ -284,9 +285,15 @@ int register_mem_sect_under_node(struct memory_block
> *mem_blk, int nid)
>  			continue;
>  		if (page_nid != nid)
>  			continue;
> -		return sysfs_create_link_nowarn(&node_devices[nid].sysdev.kobj,
> +		ret = sysfs_create_link_nowarn(&node_devices[nid].sysdev.kobj,
>  					&mem_blk->sysdev.kobj,
>  					kobject_name(&mem_blk->sysdev.kobj));
> +		if (ret)
> +			return ret;
> +
> +		return sysfs_create_link_nowarn(&mem_blk->sysdev.kobj,
> +				&node_devices[nid].sysdev.kobj,
> +				kobject_name(&node_devices[nid].sysdev.kobj));
>  	}
>  	/* mem section does not span the specified node */
>  	return 0;
> @@ -315,6 +322,8 @@ int unregister_mem_sect_under_nodes(struct
> memory_block *mem_blk)
>  			continue;
>  		sysfs_remove_link(&node_devices[nid].sysdev.kobj,
>  			 kobject_name(&mem_blk->sysdev.kobj));
> +		sysfs_remove_link(&mem_blk->sysdev.kobj,
> +			 kobject_name(&node_devices[nid].sysdev.kobj));
>  	}
>  	return 0;
>  }
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
