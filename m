Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D0D0C6B0047
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 01:31:00 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0G6Uwgn012393
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jan 2009 15:30:58 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 24F1C45DE51
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 15:30:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 01B1045DE4E
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 15:30:58 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D7E2FE08003
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 15:30:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C1231DB8040
	for <linux-mm@kvack.org>; Fri, 16 Jan 2009 15:30:57 +0900 (JST)
Date: Fri, 16 Jan 2009 15:29:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] memcg: panic when rmdir()
Message-Id: <20090116152953.894c8c7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <497025E8.8050207@cn.fujitsu.com>
References: <497025E8.8050207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jan 2009 14:15:04 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Found this when testing memory resource controller, can be triggered
> with:
> - CONFIG_CGROUP_MEM_RES_CTLR_SWAP=n
> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y
> - or CONFIG_CGROUP_MEM_RES_CTLR_SWAP=y && boot with noswapaccount
> 
> # mount -t cgroup -o memory xxx /mnt
> # mkdir /mnt/0
> # for pid in `cat /mnt/tasks`; do echo $pid > /mnt/0/tasks; done
> # echo "low limit" > /mnt/0/tasks
> # do whatever to allocate some memory
> # swapoff -a
> killed (by OOM)
> # for pid in `cat /mnt/0/tasks`; do echo $pid > /mnt/tasks; done
> # rmdir /mnt/0
> 

Hmm, it seems css->refcnt is bad (css->refcnt < 0). maybe css_put is not
called without css_get().

will chase. thank you for testing.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
