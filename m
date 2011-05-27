Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C54006B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 23:12:36 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B9B343EE0AE
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:12:32 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A14A045DE55
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:12:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8564E45DE4D
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:12:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 723D01DB803C
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:12:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 39B0B1DB802C
	for <linux-mm@kvack.org>; Fri, 27 May 2011 12:12:32 +0900 (JST)
Date: Fri, 27 May 2011 12:05:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH v3 0/10] memcg async reclaim
Message-Id: <20110527120539.91778598.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110527114837.8fae7f00.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110526141047.dc828124.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikcdOGkJWxS0Sey8C1ereVk8ucvQQ@mail.gmail.com>
	<20110527114837.8fae7f00.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Fri, 27 May 2011 11:48:37 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 26 May 2011 18:49:26 -0700
> Ying Han <yinghan@google.com> wrote:
 
> > Hmm.. I noticed a very strange behavior on a simple test w/ the patch set.
> > 
> > Test:
> > I created a 4g memcg and start doing cat. Then the memcg being OOM
> > killed as soon as it reaches its hard_limit. We shouldn't hit OOM even
> > w/o async-reclaim.
> > 
> > Again, I will read through the patch. But like to post the test result first.
> > 
> > $ echo $$ >/dev/cgroup/memory/A/tasks
> > $ cat /dev/cgroup/memory/A/memory.limit_in_bytes
> > 4294967296
> > 
> > $ time cat /export/hdc3/dd_A/tf0 > /dev/zero
> > Killed
> > 
> > real	0m53.565s
> > user	0m0.061s
> > sys	0m4.814s
> > 
> 
> Hmm, what I see is
> ==
> root@bluextal kamezawa]# ls -l test/1G
> -rw-rw-r--. 1 kamezawa kamezawa 1053261824 May 13 13:58 test/1G
> [root@bluextal kamezawa]# mkdir /cgroup/memory/A
> [root@bluextal kamezawa]# echo 0 > /cgroup/memory/A/tasks
> [root@bluextal kamezawa]# echo 300M > /cgroup/memory/A/memory.limit_in_bytes
> [root@bluextal kamezawa]# echo 1 > /cgroup/memory/A/memory.async_control
> [root@bluextal kamezawa]# cat test/1G > /dev/null
> [root@bluextal kamezawa]# cat /cgroup/memory/A/memory.reclaim_stat
> recent_scan_success_ratio 83
> limit_scan_pages 82
> limit_freed_pages 49
> limit_elapsed_ns 242507
> soft_scan_pages 0
> soft_freed_pages 0
> soft_elapsed_ns 0
> margin_scan_pages 218630
> margin_freed_pages 181598
> margin_elapsed_ns 117466604
> [root@bluextal kamezawa]#
> ==
> 
> I'll turn off swapaccount and try again.
> 

A bug found....I added memory.async_control file to memsw.....file set by mistake.
Then, async_control cannot be enabled when swapaccount=0. I'll fix that.

So, how do you enabled async_control ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
