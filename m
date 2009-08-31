Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D27136B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 19:48:21 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7VNmP92009684
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Sep 2009 08:48:25 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AFF545DE54
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 08:48:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F04F45DE51
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 08:48:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E5071DB803C
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 08:48:25 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B249EE18009
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 08:48:24 +0900 (JST)
Date: Tue, 1 Sep 2009 08:46:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Message-Id: <20090901084626.ac4c8879.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090831102640.092092954@intel.com>
References: <20090831102640.092092954@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, lizf@cn.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 31 Aug 2009 18:26:40 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

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

I don't like this.

1. plz put all under CONFIG_DEBUG_HWPOISON or some
2. plz don't export memcg's id. you can do it without it.
3. If I was you, just adds following file

	memory.hwpoison_test
   Then, if you allow test
	#echo 1 >	memory.hwpoison_test

4. I can't understand why you need this. I wonder you can get pfn via
   /proc/<pid>/????. And this may insert HWPOISON to page-cache of shared
   library and "unexpected" process will be poisoned.

Thanks,
-Kame

> Comments are welcome, thanks!
> 
> Cheers,
> Fengguang
> -- 
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
