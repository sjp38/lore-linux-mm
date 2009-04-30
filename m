Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9514E6B004D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 04:22:10 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id n3U8KVm8026641
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:20:31 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3U8MO1U1212536
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:22:25 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3U8MOWT019866
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 18:22:24 +1000
Date: Thu, 30 Apr 2009 10:22:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH mmotm] memcg: fix mem_cgroup_update_mapped_file_stat
	oops
Message-ID: <20090430045240.GA4430@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0904292209550.30874@blonde.anvils> <20090430090646.a1443096.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090430090646.a1443096.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-30 09:06:46]:

> On Wed, 29 Apr 2009 22:13:33 +0100 (BST)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > CONFIG_SPARSEMEM=y CONFIG_CGROUP_MEM_RES_CTLR=y cgroup_disable=memory
> > bootup is oopsing in mem_cgroup_update_mapped_file_stat().  !SPARSEMEM
> > is fine because its lookup_page_cgroup() contains an explicit check for
> > NULL node_page_cgroup, but the SPARSEMEM version was missing a check for
> > NULL section->page_cgroup.
> > 
> Ouch, it's curious this bug alive now.. thank you.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> I think this patch itself is sane but.. Balbir, could you see "caller" ?
> It seems strange.

Ideally we need to have a disabled check in
mem_cgroup_update_mapped_file_stat(), but it seems as if this fix is
better and fixes a larger scenario and the root cause of
lookup_page_cgroup() OOPSing. It would not hurt to check for
mem_cgroup_disabled() though, but too many checks might spoil the
party for frequent operations.

Kame, do you mean you wanted me to check if I am using
lookup_page_cgroup() correctly?

Hugh, Thank you very much for finding and fixing the problem!
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
