Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6F4916B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 04:40:53 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n548eoH8028647
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Jun 2009 17:40:50 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 34C5C45DE51
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 17:40:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EF5845DD72
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 17:40:50 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DEECBE08004
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 17:40:49 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C294E08002
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 17:40:49 +0900 (JST)
Date: Thu, 4 Jun 2009 17:39:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] remove memory.limit v.s. memsw.limit comparison.
Message-Id: <20090604173918.3b2c68f5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090604083110.GD7504@balbir.in.ibm.com>
References: <20090604141043.9a1064fd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090604083110.GD7504@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Jun 2009 16:31:10 +0800
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-04 14:10:43]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Removes memory.limit < memsw.limit at setting limit check completely.
> > 
> > The limitation "memory.limit <= memsw.limit" was added just because
> > it seems sane ...if memory.limit > memsw.limit, only memsw.limit works.
> > 
> > But To implement this limitation, we needed to use private mutex and make
> > the code a bit complated.
> > As Nishimura pointed out, in real world, there are people who only want
> > to use memsw.limit.
> > 
> > Then, this patch removes the check. user-land library or middleware can check
> > this in userland easily if this really concerns.
> > 
> > And this is a good change to charge-and-reclaim.
> > 
> > Now, memory.limit is always checked before memsw.limit
> > and it may do swap-out. But, if memory.limit == memsw.limit, swap-out is
> > finally no help and hits memsw.limit again. So, let's allow the condition
> > memory.limit > memsw.limit. Then we can skip unnecesary swap-out.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> We can't change behaviour this way without breaking userspace scripts,
> API and code. What does it mean for people already using these
> features? Does it break their workflow?
> 

Hopefully no breaks to current users's workflow.
Because this just has influences to "error path" like below

 echo 200M > memory.memsw.limit
 echo 300M > memory.limit
 => ERROR

If the user program made in sane way, above case will never happens because
they set memsw.limit to be greater than memory.limit and above is treated as error.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
