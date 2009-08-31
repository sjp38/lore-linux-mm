Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2C70D6B004F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 08:59:59 -0400 (EDT)
Date: Mon, 31 Aug 2009 20:59:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 0/4] memcg: add support for hwpoison testing
Message-ID: <20090831125941.GA20982@localhost>
References: <20090831102640.092092954@intel.com> <20090831124920.GN4770@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831124920.GN4770@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31, 2009 at 08:49:20PM +0800, Balbir Singh wrote:
> * Wu Fengguang <fengguang.wu@intel.com> [2009-08-31 18:26:40]:
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
> > Comments are welcome, thanks!
> >
> 
> I took a quick look and the patches seem OKAY to me, but I have
> question, can't we do all of this from user space? The bits about
> id export and import the ids look like they can be replaced by names
> in user space.

You mean to match by cgrp->dentry->d_name.name in kernel hwpoison_inject.c
and do this in user space?

        DIR_NAME=hwpoison
        mkdir /cgroup/$DIR_NAME
        echo $DIR_NAME > /debug/hwpoison/corrupt-filter-memcg

Looks like a good idea!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
