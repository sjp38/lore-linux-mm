Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4DE266B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 22:25:33 -0400 (EDT)
Date: Tue, 1 Sep 2009 10:25:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Message-ID: <20090901022514.GA11974@localhost>
References: <20090831102640.092092954@intel.com> <20090901084626.ac4c8879.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090901084626.ac4c8879.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 01, 2009 at 07:46:26AM +0800, KAMEZAWA Hiroyuki wrote:
> On Mon, 31 Aug 2009 18:26:40 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > Hi all,
> > 
> > In hardware poison testing, we want to inject hwpoison errors to pages
> > of a collection of selected tasks, so that random tasks (eg. init) won't
> > be killed in stress tests and lead to test failure.
> > 
> > Memory cgroup provides an ideal tool for tracking and testing these target
> > process pages. All we have to do is to
> > - export the memory cgroup id via cgroupfs
> > - export two functions/structs for hwpoison_inject.c
> > 
> > This might be an unexpected usage of memory cgroup. The last patch and this
> > script demonstrates how the exported interfaces are to be used to limit the
> > scope of hwpoison injection.
> > 
> > 	test -d /cgroup/hwpoison && rmdir /cgroup/hwpoison
> > 	mkdir /cgroup/hwpoison
> > 
> > 	usemem -m 100 -s 100 &   # eat 100MB and sleep 100s
> > 	echo `pidof usemem` > /cgroup/hwpoison/tasks
> > 
> > ==>     memcg_id=$(</cgroup/hwpoison/memory.id)
> > ==>     echo $memcg_id > /debug/hwpoison/corrupt-filter-memcg
> > 
> > 	# hwpoison all pfn
> > 	pfn=0
> > 	while true
> > 	do      
> > 		let pfn=pfn+1
> > 		echo $pfn > /debug/hwpoison/corrupt-pfn
> > 		if [ $? -ne 0 ]; then
> > 			break
> > 		fi
> > 	done
> > 
> 
> I don't like this.
> 
> 1. plz put all under CONFIG_DEBUG_HWPOISON or some
> 2. plz don't export memcg's id. you can do it without it.

No problem.

My intention was, as memcg users grow in future, the export of
memcg functions and maybe its id will be generally useful then.

Matching by memcg dir name is acceptable for our case, however
won't be suitable for general use: there are file name uniqueness,
string escaping and efficiency issues.

> 3. If I was you, just adds following file
> 
> 	memory.hwpoison_test
>    Then, if you allow test
> 	#echo 1 >	memory.hwpoison_test

No that would look ugly in the long term. I'd rather go for dir name
matching for now.

> 4. I can't understand why you need this. I wonder you can get pfn via
>    /proc/<pid>/????. And this may insert HWPOISON to page-cache of shared
>    library and "unexpected" process will be poisoned.

Sorry I should have explained this. It's mainly for correctness.
When a user space tool queries the task PFNs in /proc/pid/pagemap and
then send to /debug/hwpoison/corrupt-pfn, there is a racy window that
the page could be reclaimed and allocated by some one else. It would
be awkward to try to pin the pages in user space. So we need the
guarantees provided by /debug/hwpoison/corrupt-filter-memcg, which
will be checked inside the page lock with elevated reference count.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
