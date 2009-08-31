Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 744816B005A
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 08:49:24 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7VCnOoj011228
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 18:19:24 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7VCnOmQ2613402
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 18:19:24 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7VCnNij017533
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 22:49:24 +1000
Date: Mon, 31 Aug 2009 18:19:20 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Message-ID: <20090831124920.GN4770@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090831102640.092092954@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090831102640.092092954@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Wu Fengguang <fengguang.wu@intel.com> [2009-08-31 18:26:40]:

> Hi all,
> 
> In hardware poison testing, we want to inject hwpoison errors to pages
> of a collection of selected tasks, so that random tasks (eg. init) won't
> be killed in stress tests and lead to test failure.
> 
> Memory cgroup provides an ideal tool for tracking and testing these target
> process pages. All we have to do is to
> - export the memory cgroup id via cgroupfs
> - export two functions/structs for hwpoison_inject.c
> 
> This might be an unexpected usage of memory cgroup. The last patch and this
> script demonstrates how the exported interfaces are to be used to limit the
> scope of hwpoison injection.
> 
> 	test -d /cgroup/hwpoison && rmdir /cgroup/hwpoison
> 	mkdir /cgroup/hwpoison
> 
> 	usemem -m 100 -s 100 &   # eat 100MB and sleep 100s
> 	echo `pidof usemem` > /cgroup/hwpoison/tasks
> 
> ==>     memcg_id=$(</cgroup/hwpoison/memory.id)
> ==>     echo $memcg_id > /debug/hwpoison/corrupt-filter-memcg
> 
> 	# hwpoison all pfn
> 	pfn=0
> 	while true
> 	do      
> 		let pfn=pfn+1
> 		echo $pfn > /debug/hwpoison/corrupt-pfn
> 		if [ $? -ne 0 ]; then
> 			break
> 		fi
> 	done
> 
> Comments are welcome, thanks!
>

I took a quick look and the patches seem OKAY to me, but I have
question, can't we do all of this from user space? The bits about
id export and import the ids look like they can be replaced by names
in user space.
 
> Cheers,
> Fengguang
> -- 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
